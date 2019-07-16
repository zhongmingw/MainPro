local ShengXiaoPackView = class("ShengXiaoPackView", base.BaseView)

local ITEM_NUM = 4

local COLUNM = 4 -- 列数
local ROW = 8 -- 最小行数

local function setItemInfo(self)
	local allList = conf.ShengXiaoConf:getAllTypeList()
	local info = cache.ShengXiaoCache:getSxInfo(allList[self.curType].id)
	if nil == info then
		return
	end
	local isHeadGray = false
	for k, v in pairs(self.itemList) do
		local partInfo = info.partInfos[k]
		v.item.visible = partInfo.itemInfo.mid > 0
		if partInfo.itemInfo.mid > 0 then
			GSetItemData(v.item, partInfo.itemInfo)
			local typeCfg = conf.ShengXiaoConf:getAllTypeList()
			v.item.data = {
					data = partInfo.itemInfo,
					info = {
						id = typeCfg[self.curType].id,
						isDress = true}}
			v.item.onClick:Add(self.onClickEquipItem, self)
		end
		if not isHeadGray and partInfo.itemInfo.mid <= 0 then
			isHeadGray = true
		end
		self.headImg.grayed = isHeadGray
	end

	-- 技能激活条件
	local isActive = info.skillId > 0
	local skillLv, isCanUse = conf.ShengXiaoConf:getSkillLv(info.type)
	local tempSkillId = isActive and info.skillId or info.type * 1000 + skillLv
	local skillCfg = conf.ShengXiaoConf:getSkillCfg(tempSkillId)
	if nil == skillCfg then
		return
	end
	local nextSkilLCfg = conf.ShengXiaoConf:getSkillCfg(tempSkillId + 1)
	self.skillCondition.visible = nil ~= nextSkilLCfg
	self.skillTipBtn.visible = nil ~= nextSkilLCfg

	if nil ~= nextSkilLCfg then
		local tempCondition = isCanUse and nextSkilLCfg.condition or skillCfg.condition
		local stageStr = tempCondition < 10 and language.kagee53 or language.kagee54
		tempCondition = tempCondition < 10 and tempCondition or (tempCondition - 10)

		local str = string.format(
			language.kagee45,
			tempCondition,
			stageStr,
			isCanUse and language.kagee43 or language.kagee42)

		self.skillCondition.text = str .. language.kagee46
	end
end

local function getPackArray(self)
	local typeCfg = conf.ShengXiaoConf:getAllTypeList()
	local sxType = typeCfg[self.curType].type
	return cache.ShengXiaoCache:getPackArray(sxType)
end

local function setBagList(self)
	self.packArray = getPackArray(self)
	local packNums = #self.packArray
	packNums = ((packNums / COLUNM) > ROW)
				and (packNums + COLUNM * 4)
				or (ROW * COLUNM)
	self.listView.numItems = packNums
end

function ShengXiaoPackView:ctor()
	self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
	self.itemList = {}
end

function ShengXiaoPackView:initView()
	-- 窗口
	local win = self.view:GetChild("n0")
	local closeBnt = win:GetChild("n7")
	self:setCloseBtn(closeBnt)

	local helpBtn = self.view:GetChild("n11")
	helpBtn.onClick:Add(self.onClickHelpBtn, self)

	self.sxTypeBtn = self.view:GetChild("n24")
	self.sxTypeBtn.onClick:Add(self.onClickSxTypeBtn, self)

	for i = 1, ITEM_NUM do
		local item = self.view:GetChild("item" .. i)
		local propItem = item:GetChild("n2")
		self.itemList[i] = {
		    rootItem = item,
		    item = propItem,
		}
	end

	self.headImg = self.view:GetChild("n31")

	self.skillCondition = self.view:GetChild("n12")
	self.skillTipBtn = self.view:GetChild("n11")

	self.listView = self.view:GetChild("n14")
	self.listView.numItems = 0
	self.listView.itemRenderer = function(index, obj)
		self:refreshBagCell(index, obj)
	end
	self.listView:SetVirtual()

	self.typeList = self.view:GetChild("n18")
	self.typeList.numItems = #conf.ShengXiaoConf:getAllTypeList()
	self.typeList.itemRenderer = function(index, obj)
		self:refreshTypeCell(index, obj)
	end
	self.typeList:SetVirtual()

	self.typeListRoot = self.view:GetChild("n19")
end

function ShengXiaoPackView:initData(data)
	mgr.ItemMgr:setPackIndex(Pack.shengXiao)

	self.curType = 1
	local typeCfg = conf.ShengXiaoConf:getAllTypeList()
	if nil ~= data then
		for k, v in pairs(typeCfg) do
			if v.type == data.type then
				self.curType = k
				break
			end
		end
	end
	self.sxTypeBtn.text = typeCfg[self.curType].name
	self.typeListRoot.visible = false

	setBagList(self)

	setItemInfo(self)

	self.headImg.url = UIPackage.GetItemURL("kagee" , typeCfg[self.curType].headId)
end

-- 帮助
function ShengXiaoPackView:onClickHelpBtn()
	GOpenRuleView(1169)
end

-- 背包列表
function ShengXiaoPackView:refreshBagCell(index, obj)
	local item = obj:GetChild("n5")
	local itemData = self.packArray[index + 1] or {}
	obj.touchable = nil ~= itemData.mid
	obj.selected = false
	itemData.isArrow = true
	itemData.isquan = true
	GSetItemData(item, itemData)
	local typeCfg = conf.ShengXiaoConf:getAllTypeList()
	item.data = {
			data = itemData,
			info = {
				isPack = true,
				id = typeCfg[self.curType].id}}
	item.onClick:Add(self.onClickPackItem, self)
end

-- 生肖类型列表
function ShengXiaoPackView:refreshTypeCell(index, obj)
	local typeCfg = conf.ShengXiaoConf:getAllTypeList()
	obj.title = typeCfg[index + 1].name
	obj.data = {index = index}
	obj.selected = (index + 1) == self.curType
	if (index + 1) == self.curType then
		self.headImg.url = UIPackage.GetItemURL("kagee" , typeCfg[index + 1].headId)
	end
	obj.onClick:Add(self.onClickTypeCell, self)
end

function ShengXiaoPackView:onClickSxTypeBtn()
	local value = self.typeListRoot.visible
	self.typeListRoot.visible = not value
	if not value then
		self.typeList.numItems = 0
		self.typeList.numItems = #conf.ShengXiaoConf:getAllTypeList()
		self.typeList:ScrollToView(self.curType - 1, false)
	end
end

function ShengXiaoPackView:onClickTypeCell(context)
	local cell = context.sender
    local data = cell.data
    self.typeListRoot.visible = false
    if self.curType == data.index + 1 then
    	return
    end
    local typeCfg = conf.ShengXiaoConf:getAllTypeList()
    self.sxTypeBtn.text = typeCfg[data.index + 1].name
    self.curType = data.index + 1
    self.headImg.url = UIPackage.GetItemURL("kagee" , typeCfg[data.index + 1].headId)

    setItemInfo(self)
    setBagList(self)
end

function ShengXiaoPackView:onClickPackItem(context)
	local cell = context.sender
    local data = cell.data
	GSeeLocalItem(data.data , data.info)
end

function ShengXiaoPackView:onClickEquipItem(context)
	local cell = context.sender
    local data = cell.data
	GSeeLocalItem(data.data , data.info)
end

function ShengXiaoPackView:flush()
	setItemInfo(self)
	setBagList(self)
end

function ShengXiaoPackView:doClearView(clear)
	mgr.ItemMgr:setPackIndex(0)
end

return ShengXiaoPackView