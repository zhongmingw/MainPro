local ShengXiaoStrengthenView = class("ShengXiaoStrengthenView", base.BaseView)

local ITEM_NUM = 4

local CAN_STREN_STATE = 0	-- 可以强化状态
local UP_GRADE_STATE = 1	-- 升阶状态
local MAX_STATE = 2			-- 最大等级
local NO_EQUIP_STATE = 3	-- 无装备

local STOP_ICON = "shengyin_026"		-- 停止强化图标
local ONE_KEY_ICON = "shengxiao_014"	-- 一键强化图标

local function setAttr(self)
	local list = conf.ShengXiaoConf:getAllTypeList()
	local cfg = list[self.curCellIndex]
	local info = cache.ShengXiaoCache:getSxInfo(cfg.id)
	if nil == info then
		return
	end
	local partInfo = info.partInfos[self.itemIndex]
	local attrCfgs = conf.ShengXiaoConf:getStrenCfg(self.itemIndex, partInfo.strenLevel)
	local nextCfgs = conf.ShengXiaoConf:getStrenCfg(self.itemIndex, partInfo.strenLevel + 1)
	attrCfgs = GConfDataSort(attrCfgs)
	local nextAttrCfgs = GConfDataSort(nextCfgs)
	local itemId = partInfo.itemInfo.mid or 0
	local maxLevel = conf.ShengXiaoConf:getEquipMaxStrengLv(itemId)
	local stage = conf.ItemConf:getStagelvl(itemId)

	local attrCfg = nil
	local nextAttrCfg = nil
	for k, v in pairs(self.attrList) do
		attrCfg = attrCfgs[k]
		nextAttrCfg = nextAttrCfgs[k]
		v.root.visible = nil ~= attrCfg
		v.arrow.visible = maxLevel > partInfo.strenLevel or stage < 10
		if nil ~= attrCfg then
			local attName = conf.RedPointConf:getProName(attrCfg[1])
			v.name.text = attName .. ":"
			v.curValue.text = attrCfg[2]
			if (maxLevel > partInfo.strenLevel or stage < 10) and nil ~= nextAttrCfg then
				v.nextValue.text = nextAttrCfg[2]
			else
				v.nextValue.text = ""
			end
		end
	end
	self.curLevel.text = partInfo.strenLevel
	self.levelArrow.visible = maxLevel > partInfo.strenLevel or stage < 10
	self.nextLevel.text = (maxLevel > partInfo.strenLevel or stage < 10)
							and partInfo.strenLevel + 1
							or ""
end

local function setActiveState(self)
	local list = conf.ShengXiaoConf:getAllTypeList()
	local cfg = list[self.curCellIndex]
	local info = cache.ShengXiaoCache:getSxInfo(cfg.id)
	if nil == info then
		return
	end
	local partInfo = info.partInfos[self.itemIndex]
	local strengCfg = conf.ShengXiaoConf:getStrenCfg(self.itemIndex, partInfo.strenLevel)
	local itemId = partInfo.itemInfo.mid or 0
	local stage = conf.ItemConf:getStagelvl(itemId)
	-- 判断当前选择的格子有没有装备
	if itemId <= 0 then
		self.stateControl.selectedIndex = NO_EQUIP_STATE
		self.expProgress.value = 0
		self.expProgress.max = 1
		self.progressTitle.text = 0 .. "/" .. 0
		return
	end
	local maxLevel = conf.ShengXiaoConf:getEquipMaxStrengLv(itemId)
	local quality = conf.ItemConf:getQuality(itemId)
	local isMaxLevel = partInfo.strenLevel >= maxLevel
	if isMaxLevel and stage > 10 then
		-- 6为红色品质
		if quality >= 6 and stage < 19 then
			self.stateControl.selectedIndex = UP_GRADE_STATE
		else
			self.stateControl.selectedIndex = MAX_STATE
		end
		self.expProgress.value = 1
		self.expProgress.max = 1
		self.progressTitle.text = "Max"
	else
		self.stateControl.selectedIndex = CAN_STREN_STATE
		self.expProgress.value = partInfo.exp
		local maxValue = strengCfg and strengCfg.need_exp or 0
		self.expProgress.max = maxValue
		self.progressTitle.text = partInfo.exp .. "/" .. maxValue

		local score = cache.ShengXiaoCache:getScore()
		if strengCfg.need_cost > score then
			score = mgr.TextMgr:getTextColorStr(score, 14)
		end
		self.costText.text = score .. "/" .. strengCfg.need_cost
	end

	self.oneKeyBtn.grayed = isMaxLevel and stage > 10
	self.oneKeyBtn.touchable = not isMaxLevel or stage < 10
	self.advanceBtn.grayed = isMaxLevel and stage > 10
	self.advanceBtn.touchable = not isMaxLevel or stage < 10

	setAttr(self)
end

-- 刷新当前选中装备的数据
local function flushSelectItemInfo(self)
	local list = conf.ShengXiaoConf:getAllTypeList()
	local cfg = list[self.curCellIndex]
	local info = cache.ShengXiaoCache:getSxInfo(cfg.id)
	if nil == info then
		return
	end
	local partInfo = info.partInfos[self.itemIndex]
	local mid = partInfo.itemInfo.mid > 0 and partInfo.itemInfo.mid
	local itemData = {mid = mid, amount = 0, bind = 0, isquan = true}

	local selectItem = self.itemList[self.itemIndex]
	GSetItemData(selectItem.item, itemData)
	selectItem.level.text = string.format(
							language.kagee37,
							mgr.TextMgr:getTextColorStr(
								partInfo.itemInfo.mid > 0
									and partInfo.strenLevel
									or 0, 7))
	for k, v in pairs(self.itemList) do
		v.red.visible = cache.ShengXiaoCache:isShowSxStrengPartRed(cfg.id, k)
	end
end

-- 设置所有格子的数据
local function setItemInfo(self)
	local list = conf.ShengXiaoConf:getAllTypeList()
	local cfg = list[self.curCellIndex]
	local info = cache.ShengXiaoCache:getSxInfo(cfg.id)
	if nil == info then
		return
	end
	for k, v in pairs(self.itemList) do
		local partInfo = info.partInfos[k]
		local mid = partInfo.itemInfo.mid > 0 and partInfo.itemInfo.mid
		local itemData = {mid = mid, amount = 0, bind = 0, isquan = true}
		v.lock.visible = partInfo.itemInfo.mid <= 0
		v.itemRoot.touchable = partInfo.itemInfo.mid > 0
		v.itemRoot.selected = self.itemIndex == k and partInfo.itemInfo.mid > 0
		GSetItemData(v.item, itemData)
		v.level.text = string.format(
							language.kagee37,
							mgr.TextMgr:getTextColorStr(
								partInfo.itemInfo.mid > 0
									and partInfo.strenLevel
									or 0, 7))
		v.red.visible = cache.ShengXiaoCache:isShowSxStrengPartRed(cfg.id, k)
	end
	setActiveState(self)
end

local function initLeftList(self)
	local list = conf.ShengXiaoConf:getAllTypeList()
	self.listView.numItems = #list
	self.listView:ScrollToView(self.curCellIndex - 1, false)
end

local function starStrengthen(self, reqType)
	local list = conf.ShengXiaoConf:getAllTypeList()
	local cfg = list[self.curCellIndex]
	local info = cache.ShengXiaoCache:getSxInfo(cfg.id)
	if nil == info then
		return
	end
	local partInfo = info.partInfos[self.itemIndex]
	local itemId = partInfo.itemInfo.mid
	local curStrengCfg = conf.ShengXiaoConf:getStrenCfg(self.itemIndex, partInfo.strenLevel)
	local maxLevel = conf.ShengXiaoConf:getEquipMaxStrengLv(itemId)
	local stage = conf.ItemConf:getStagelvl(itemId)
	if maxLevel <= partInfo.strenLevel then
		self:stopAutoStren()
		if stage < 10 then
			GComAlter(language.kagee63)
			return
		end
		GComAlter(language.kagee38)
		return
	end
	local score = cache.ShengXiaoCache:getScore()
	if score < curStrengCfg.need_cost then
		self:stopAutoStren()
		GComAlter(language.kagee39)
		return
	end
	-- 一键强化提升等级后停止
	if self.isAuto and partInfo.strenLevel ~= self.curStrenLv
	and self.curStrenLv ~= -1 then
		self.curStrenLv = partInfo.strenLevel
		self:stopAutoStren()
		return
	end
	self.curStrenLv = partInfo.strenLevel
	proxy.ShengXiaoProxy:sendStrengthen(0, cfg.id, self.itemIndex)
end

function ShengXiaoStrengthenView:ctor()
	self.super.ctor(self)
	self.uiClear = UICacheType.cacheTime
	self.uiLevel = UILevel.level2

	self.itemList = {}
	self.attrList = {}
end

function ShengXiaoStrengthenView:initView()
	self.oneKeyBtn = self.view:GetChild("n5")
	self.oneKeyBtn.onClick:Add(self.onClickOneKeyBtn, self)

	self.expProgress = self.view:GetChild("n18")
	self.progressTitle = self.expProgress:GetChild("title")

	self.advanceBtn = self.view:GetChild("n24")
	self.advanceBtn.onClick:Add(self.onClickAdvanceBtn, self)

	local upGradeBtn = self.view:GetChild("n40")
	upGradeBtn.onClick:Add(self.onClickUpGradeBtn, self)

	self.costText = self.view:GetChild("n13")
	-- 进度条下方文本描述
	local tipText = self.view:GetChild("n17")
	tipText.text = language.kagee68

	self.listView = self.view:GetChild("n2")
	self.listView.numItems = 0
	self.listView.itemRenderer = function(index, obj)
		self:refreshLeftCell(index, obj)
	end
	self.listView:SetVirtual()

	self.stateControl = self.view:GetController("c1")

	local levelAttr = self.view:GetChild("levelAttr")
	self.curLevel = levelAttr:GetChild("n1")
	self.levelArrow = levelAttr:GetChild("arrow")
	self.nextLevel = levelAttr:GetChild("n4")

	local closeBtn = self.view:GetChild("n0"):GetChild("n7")
	closeBtn.onClick:Add(self.onClickClose, self)

	for i = 1, ITEM_NUM do
		local lock = self.view:GetChild("lock" .. i)
		local itemRoot = self.view:GetChild("item" .. i)
		local item = itemRoot:GetChild("n5")
		local red = itemRoot:GetChild("red")
		local itemlv = self.view:GetChild("itemlv" .. i)
		itemRoot.data = {index = i}
		itemRoot.onClick:Add(self.onClickItemCell, self)
		self.itemList[i] = {
			lock = lock,
			itemRoot = itemRoot,
			item = item,
			level = itemlv,
			red = red,
		}

		if i < ITEM_NUM then
			local attrRoot = self.view:GetChild("attr" .. i)
			local name = attrRoot:GetChild("n0")
			local curValue = attrRoot:GetChild("n1")
			local arrow = attrRoot:GetChild("arrow")
			local nextValue = attrRoot:GetChild("n4")
			self.attrList[i] = {
				root = attrRoot,
				name = name,
				curValue = curValue,
				arrow = arrow,
				nextValue = nextValue,
			}
		end
	end
end

function ShengXiaoStrengthenView:initData(data)
	self.isAuto = false
	self.curStrenLv = -1

	self.curCellIndex = 1
	self.itemIndex = 1
	if nil ~= data and data.id then
		local typeCfg = conf.ShengXiaoConf:getAllTypeList()
		for k, v in pairs(typeCfg) do
			if v.id == data.id then
				self.curCellIndex = k
				break
			end
		end
	end
	initLeftList(self)
	setItemInfo(self)
	self:setOneKeyBtnIcon(ONE_KEY_ICON)
end

function ShengXiaoStrengthenView:onClickClose()
	self:closeView()
end

-- 一键进阶
function ShengXiaoStrengthenView:onClickOneKeyBtn()
	self.isAuto = not self.isAuto
	starStrengthen(self, 1)
end

-- 进阶
function ShengXiaoStrengthenView:onClickAdvanceBtn()
	self.isAuto = false
	starStrengthen(self, 0)
end

-- 升阶
function ShengXiaoStrengthenView:onClickUpGradeBtn()
	local list = conf.ShengXiaoConf:getAllTypeList()
	local cfg = list[self.curCellIndex]
	local params = {id = cfg.id, part = self.itemIndex}
	mgr.ViewMgr:openView2(ViewName.ShengXiaoJinJieView, params)
end

-- 装备格子
function ShengXiaoStrengthenView:onClickItemCell(context)
	local cell = context.sender
    local data = cell.data
    if data.index == self.itemIndex then
    	return
    end
    self.isAuto = false

    local list = conf.ShengXiaoConf:getAllTypeList()
	local cfg = list[self.curCellIndex]
	local info = cache.ShengXiaoCache:getSxInfo(cfg.id)
	if nil == info then
		return
	end
	local partInfo = info.partInfos[data.index]
	local mid = partInfo.itemInfo.mid or 0
	for k, v in pairs(self.itemList) do
		v.itemRoot.selected = data.index == k and mid > 0
	end
	if mid <= 0 then
		return
	end
    self.itemIndex = data.index
    setActiveState(self)
end

function ShengXiaoStrengthenView:onClickLeftCell(context)
	local cell = context.sender
    local data = cell.data
    if data.index + 1 == self.curCellIndex then
    	return
    end
    self.isAuto = false
    self.curCellIndex = data.index + 1

    local list = conf.ShengXiaoConf:getAllTypeList()
	local cfg = list[self.curCellIndex]
	local info = cache.ShengXiaoCache:getSxInfo(cfg.id)
	for k, v in pairs(info.partInfos) do
		if v.itemInfo.mid > 0 then
			self.itemIndex = k
			break
		end
	end

    setItemInfo(self)
end

-- 左侧列表
function ShengXiaoStrengthenView:refreshLeftCell(index, obj)
	local list = conf.ShengXiaoConf:getAllTypeList()
	local cfg = list[index + 1]
	local info = cache.ShengXiaoCache:getSxInfo(cfg.id)
	if nil == info then
		return
	end
	local name = obj:GetChild("n2")
	local power = obj:GetChild("n4")
	local redImg = obj:GetChild("red")
	name.text = cfg.name
	power.text = string.format(language.kagee34, info.power)
	redImg.visible = cache.ShengXiaoCache:isShowSxStrengRed(cfg.id)

	local isSelect = self.curCellIndex == index + 1
	obj.selected = isSelect
    obj.data = {index = index, cfg = cfg}
    obj.onClick:Add(self.onClickLeftCell, self)
end

function ShengXiaoStrengthenView:flush()
	flushSelectItemInfo(self)
	setActiveState(self)
	self.listView:RefreshVirtualList()

	if self.isAuto then
		if nil == self.timeQuest then
			self.timeQuest = self:addTimer(0.1, -1, function()
				starStrengthen(self, 1)
			end)
		end
		self:setOneKeyBtnIcon(STOP_ICON)
	else
		self:stopAutoStren()
	end
end

function ShengXiaoStrengthenView:removeTimeQuest()
	if nil ~= self.timeQuest then
		self:removeTimer(self.timeQuest)
		self.timeQuest = nil
	end
end

function ShengXiaoStrengthenView:stopAutoStren()
	self.isAuto = false
	self:setOneKeyBtnIcon(ONE_KEY_ICON)
	self:removeTimeQuest()
	self.curStrenLv = -1
end

function ShengXiaoStrengthenView:setOneKeyBtnIcon(icon)
	self.oneKeyBtn.icon = UIPackage.GetItemURL("kagee" , icon)
end

return ShengXiaoStrengthenView