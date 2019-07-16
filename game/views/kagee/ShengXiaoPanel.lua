local ShengXiaoPanel = class("ShengXiaoPanel", import("game.base.Ref"))

local ATTR_NUM = 5
local ITEM_NUM = 4

local TYPE_NUM = 3	-- 大类型

local function setStrengthenRed(self)
	local list = conf.ShengXiaoConf:getAllTypeList()
	for k, v in pairs(list) do
		if cache.ShengXiaoCache:isShowSxStrengRed(v.id) then
			self.strengthenBtnRedImg.visible = true
			return
		else
			self.strengthenBtnRedImg.visible = false
		end
	end
end

local function setOtherInfo(self)
	local score = cache.ShengXiaoCache:getScore()
	local skillMax = cache.ShengXiaoCache:getSkillMax()
	local activeNum = cache.ShengXiaoCache:getActiveSkillNum()
	self.activeSkillNum.text = activeNum .. "/" .. skillMax
	self.scoreText.text = score
end

-- 设置技能信息
local function setSkillInfo(self, info)
	if nil == info then
		return
	end
	local isActive = info.skillId > 0
	local skillLv, isCanUse = conf.ShengXiaoConf:getSkillLv(info.type)
	local isShowNoActive = cache.ShengXiaoCache:isShowNoActive(info.type)
	self.skillItem.grayed = not isCanUse
	self.noActiveSkillBtn.visible = isShowNoActive
	self.cancleActiveSkillBtn.visible = isActive
	self.activeSkillBtn.visible = (not isActive) and not isShowNoActive

	if isActive then
		if nil == self.effect then
			self.effect = self.parent:addEffect(4020170, self.effectRoot)
		end
	elseif nil ~= self.effect then
		self.parent:removeUIEffect(self.effect)
		self.effect = nil
	end

	-- 技能红点
	self.activeSkillBtnRedImg.visible = cache.ShengXiaoCache:isShowSkillRed(info.type)

	local tempSkillId = isActive and info.skillId or info.type * 1000 + skillLv
	local skillCfg = conf.ShengXiaoConf:getSkillCfg(tempSkillId)
	if nil == skillCfg then
		return
	end
	local nextSkilLCfg = conf.ShengXiaoConf:getSkillCfg(tempSkillId + 1)

	local level = isActive and info.skillId % 1000 or skillLv

	self.skillCondition.visible = nil ~= nextSkilLCfg
	if nil ~= nextSkilLCfg then
		local tempCondition = isCanUse and nextSkilLCfg.condition or skillCfg.condition
		local stageStr = tempCondition < 10 and language.kagee53 or language.kagee54
		tempCondition = tempCondition < 10 and tempCondition or (tempCondition - 10)
		local str = string.format(
			language.kagee44,
			tempCondition,
			stageStr,
			isCanUse and language.kagee43 or language.kagee42,
			isCanUse and level + 1 or skillLv,
			skillCfg.name)
		self.skillCondition.text = str
	end

	self.skillLevel.text = "LV." .. mgr.TextMgr:getTextColorStr(level, 7)

	self.skillIcon.url = UIPackage.GetItemURL("kagee" , skillCfg.skill_icon)
end

-- 设置总属性
local function setAtts(self, data)
	if nil == data then
		return
	end
	local allAttrs = conf.ShengXiaoConf:getAttrs(data.id)
	allAttrs = GConfDataSort(allAttrs)
	local attrCfg = nil
	for k, v in pairs(self.attrList) do
		attrCfg = allAttrs[k]
		if nil ~= attrCfg then
			local attName = conf.RedPointConf:getProName(attrCfg[1])
			v.name.text = attName .. ":"
			v.value.text = attrCfg[2]
		else
			v.name.text = ""
			v.value.text = ""
		end
	end
end

-- 设置装备格子数据
local function setItemInfo(self, info)
	if nil == info then
		return
	end

	local isHeadGray = false
	for k, v in pairs(self.itemList) do
		local partInfo = info.partInfos[k]
		v.item.onClick:Clear()
		v.item.visible = partInfo.itemInfo.mid > 0
		if partInfo.itemInfo.mid > 0 then
			GSetItemData(v.item, partInfo.itemInfo)
		end
		v.item.data = {data = partInfo.itemInfo,
						info = {
							id = info.type,
							isDress = true}}
		v.item.onClick:Add(self.onClickItem, self)
		v.red.visible = cache.ShengXiaoCache:isShowShengXiaoPartRed(info.type, k, true)

		if not isHeadGray and partInfo.itemInfo.mid <= 0 then
			isHeadGray = true
		end
	end

	self.packBtnRedImg.visible = false
	self.headImg.grayed = isHeadGray
	for i = 1, 4 do
		if cache.ShengXiaoCache:isShowShengXiaoPartRed(info.type, i) then
			self.packBtnRedImg.visible = true
			break
		end
	end
end

local function cellData(self, obj, data, index)
	local info = cache.ShengXiaoCache:getSxInfo(data.id)
	if nil == info then
		return
	end
	local redImg = obj:GetChild("red")
	local name = obj:GetChild("n2")
	local score = obj:GetChild("n4")
	name.text = data.name
	score.text = string.format(language.kagee34, info.power)

	local isSelect = self.curCellIndex == index
	if isSelect then
		setItemInfo(self, info)
		setAtts(self, data)
		setSkillInfo(self, info)
		self.headImg.url = UIPackage.GetItemURL("kagee" , data.headId)
	end

	redImg.visible = cache.ShengXiaoCache:isShowTypeRed(data.id)

	obj.selected = isSelect
    obj.data = {index = index, data = data}
    obj.onClick:Add(self.onClickCell2, self)
end

local function setListView(self)
	self.listView.numItems = 0
	local allList = conf.ShengXiaoConf:getTypeList()
	local globalCfg = conf.ShengXiaoConf:getGlobalCfg()
    for i = 1, TYPE_NUM do
    	local url = UIPackage.GetItemURL("kagee" , "ShengXiaoCell1")
        local obj = self.listView:AddItemFromPool(url)
        local c1 = obj:GetController("c1")
        local titleName = obj:GetChild("n3")
        local redImg = obj:GetChild("red")
        redImg.visible = false
        titleName.text = globalCfg["title" .. i]
        c1.selectedIndex = (i == self.curTitleIndex and self.isShowCell) and 1 or 0
        obj.data = {index = i}
        obj.onClick:Add(self.onClickTitleCell, self)
        if not self.isShowCell then
        	for i2 = 1, #allList[i] do
        		if cache.ShengXiaoCache:isShowTypeRed(allList[i][i2].id) then
	        		redImg.visible = true
	        		break
	        	end
        	end
        end
        if self.curTitleIndex == i and self.isShowCell then
        	for k, v in pairs(allList[i]) do
                local url = UIPackage.GetItemURL("kagee" , "ShengXiaoCell2")
                local obj = self.listView:AddItemFromPool(url)
                cellData(self, obj, v, self.curTitleIndex + k)
        	end
        end
    end

    self.listView:ScrollToView(self.curTitleIndex - 1, false)
end

function ShengXiaoPanel:ctor(mParent)
	self.parent = mParent
	self.view = self.parent.shengXiaoObj

	self.attrList = {}
	self.itemList = {}

	-- 当前大标题索引
	self.curTitleIndex = 1
	-- 当前选择格子索引
	self.curCellIndex = self.curTitleIndex + 1

	self.isShowCell = true

	self:initView()
end

function ShengXiaoPanel:initView()
	local skillHelpBtn = self.view:GetChild("n80")
	skillHelpBtn.onClick:Add(self.onClickSkillHelpBtn, self)

	local addBtn = self.view:GetChild("n45")
	addBtn.onClick:Add(self.onClickAddBtn, self)

	local strengthenBtn = self.view:GetChild("n46")
	strengthenBtn.onClick:Add(self.onClickStrengthenBtn, self)
	self.strengthenBtnRedImg = strengthenBtn:GetChild("red")

	local decomposeBtn = self.view:GetChild("n53")
	decomposeBtn.onClick:Add(self.onClickDecomposeBtn, self)

	local packBtn = self.view:GetChild("n54")
	packBtn.onClick:Add(self.onClickPackBtn, self)
	self.packBtnRedImg = packBtn:GetChild("red")

	-- 取消激活按钮
	self.cancleActiveSkillBtn = self.view:GetChild("n56")
	self.cancleActiveSkillBtn.onClick:Add(self.onClickCancleActiveSkillBtn, self)

	local tipBtn = self.view:GetChild("n81")
	tipBtn.onClick:Add(self.onClickTipBtn, self)

	-- 未激活按钮
	self.noActiveSkillBtn = self.view:GetChild("n82")

	-- 激活按钮
	self.activeSkillBtn = self.view:GetChild("n83")
	self.activeSkillBtn.onClick:Add(self.onClickActiveSkillBtn, self)
	self.activeSkillBtnRedImg = self.activeSkillBtn:GetChild("red")

	-- 技能条件
	self.skillCondition = self.view:GetChild("n51")

	for i = 1, ATTR_NUM do
		local attr = self.view:GetChild("attr" .. i)
		local name = attr:GetChild("name")
		local value = attr:GetChild("value")
		self.attrList[i] = {name = name, value = value}
	end

	for i = 1, ITEM_NUM do
		local item = self.view:GetChild("item" .. i)
		local propItem = item:GetChild("n2")
		local red = item:GetChild("n4")
		self.itemList[i] = {
		    rootItem = item,
		    item = propItem,
		    red = red,
		}
		item.data = {index = i}
		item.onClick:Add(self.onClickEquipItem, self)
	end

	self.headImg = self.view:GetChild("n64")
	self.skillItem = self.view:GetChild("n88")
	self.skillItem.onClick:Add(self.onClickSkillItem, self)

	self.skillIcon = self.skillItem:GetChild("n1")
	self.scoreText = self.view:GetChild("n50")
	self.activeSkillNum = self.view:GetChild("n52")
	self.skillLevel = self.view:GetChild("n72")
	self.listView = self.view:GetChild("n33")

	-- 技能特效根节点
	self.effectRoot = self.view:GetChild("effectRoot")
end

-- 技能帮助
function ShengXiaoPanel:onClickSkillHelpBtn()
	GOpenRuleView(1174)
end

-- 技能扩展
function ShengXiaoPanel:onClickAddBtn()
	mgr.ViewMgr:openView2(ViewName.ShengXiaoExtendView)
end

-- 强化
function ShengXiaoPanel:onClickStrengthenBtn()
	local allList = conf.ShengXiaoConf:getTypeList()
	local list = allList[self.curTitleIndex]
	local params = {}
	params.id = list[self.curCellIndex - self.curTitleIndex].id
	mgr.ViewMgr:openView2(ViewName.ShengXiaoStrengthenView, params)
end

-- 分解
function ShengXiaoPanel:onClickDecomposeBtn()
	mgr.ViewMgr:openView2(ViewName.ShengXiaoFenJieView)
end

-- 背包
function ShengXiaoPanel:onClickPackBtn()
	mgr.ViewMgr:openView2(ViewName.ShengXiaoPackView)
end

-- 属性tip
function ShengXiaoPanel:onClickTipBtn()
	mgr.ViewMgr:openView2(ViewName.ShengXiaotipView)
end

-- 取消激活按钮
function ShengXiaoPanel:onClickCancleActiveSkillBtn()
	local allList = conf.ShengXiaoConf:getTypeList()
	local list = allList[self.curTitleIndex]
	proxy.ShengXiaoProxy:sendActiveSkill(0, list[self.curCellIndex - self.curTitleIndex].id)
end

-- 激活按钮
function ShengXiaoPanel:onClickActiveSkillBtn()
	local num = cache.ShengXiaoCache:getActiveSkillNum()
	local maxNum = cache.ShengXiaoCache:getSkillMax()
	if num >= maxNum then
		local nextSkilLCfg = conf.ShengXiaoConf:getSKillExtendCfg(maxNum + 1)
		if nil == nextSkilLCfg then
			GComAlter(language.kagee66)
		else
			GComAlter(language.kagee65)
		end
		return
	end
	local allList = conf.ShengXiaoConf:getTypeList()
	local list = allList[self.curTitleIndex]
	proxy.ShengXiaoProxy:sendActiveSkill(1, list[self.curCellIndex - self.curTitleIndex].id)
end

-- 技能信息
function ShengXiaoPanel:onClickSkillItem()
	local allList = conf.ShengXiaoConf:getTypeList()
	local list = allList[self.curTitleIndex]
	local params = {}
	params.id = list[self.curCellIndex - self.curTitleIndex].id
	mgr.ViewMgr:openView2(ViewName.ShengXiaoSkillInfoView, params)
end

function ShengXiaoPanel:onClickTitleCell(context)
	local cell = context.sender
    local data = cell.data
    if data.index ~= self.curTitleIndex then
    	self.isShowCell = true
    else
    	self.isShowCell = not self.isShowCell
    end
    self.curTitleIndex = data.index
    self.curCellIndex = self.curTitleIndex + 1
    setListView(self)
end

function ShengXiaoPanel:onClickCell2(context)
	local cell = context.sender
    local data = cell.data
    if data.index == self.curCellIndex then
    	return
    end
    self.curCellIndex = data.index
    local allList = conf.ShengXiaoConf:getTypeList()
	local list = allList[self.curTitleIndex]
	local typeCfg = list[self.curCellIndex - self.curTitleIndex]
    local info = cache.ShengXiaoCache:getSxInfo(typeCfg.id)
	if nil == info then
		return
	end
    setItemInfo(self, info)
    setAtts(self, data.data)
    setSkillInfo(self, info)
    self.headImg.url = UIPackage.GetItemURL("kagee" , typeCfg.headId)
end

function ShengXiaoPanel:onClickItem(context)
	local cell = context.sender
    local data = cell.data
    GSeeLocalItem(data.data , data.info)
end

-- 没有装备的格子
function ShengXiaoPanel:onClickEquipItem(context)
	local cell = context.sender
    local data = cell.data
    local allList = conf.ShengXiaoConf:getTypeList()
	local list = allList[self.curTitleIndex]
	local curType = self.curCellIndex - self.curTitleIndex
    local info = cache.ShengXiaoCache:getSxInfo(list[curType].id)
	if nil == info then
		return
	end
	local partInfo = info.partInfos[data.index]
	if partInfo.itemInfo.mid <= 0 then
		mgr.ViewMgr:openView2(ViewName.ShengXiaoPackView, {type = list[curType].type})
	end
end

function ShengXiaoPanel:flush()
	setListView(self)
	setOtherInfo(self)
	setStrengthenRed(self)
end

return ShengXiaoPanel