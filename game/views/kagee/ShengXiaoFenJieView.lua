local ShengXiaoFenJieView = class("ShengXiaoFenJieView", base.BaseView)

local ROW = 8		-- 最小行数
local COLUNM = 8

local COLOR_DEF = {
	[1] = 3,
	[2] = 4,
	[3] = 5,
	[4] = 6,
}
local STAR_DEF = {
	1, 2, 3, 4, 5, 6, 7, 8, 9, 11,
}

local function setDecomposeNum(self)
	local num = 0
	for k, v in pairs(self.selectItems) do
		local cfg = conf.ShengXiaoConf:getDecomposeCfg(v.mid)
		if nil ~= cfg and nil ~= cfg.items then
			num = num + cfg.items[1][2]
		end
	end
	self.decomposeNum.text = num
end

local function setSelectItems(self)
	self.selectItems = {}
	for k, v in pairs(self.packArray) do
		local itemCfg = conf.ItemConf:getItem(v.mid)
		if itemCfg.color <= COLOR_DEF[self.curQualityIndex]
			and itemCfg.stage_lvl <= STAR_DEF[self.curStarIndex] then

			self.selectItems[k] = v
		end
	end
	self.itemList:RefreshVirtualList()

	local packNums = #self.packArray
	packNums = ((packNums / COLUNM) > ROW)
				and (packNums + COLUNM * 4)
				or (ROW * COLUNM)
	self.itemList.numItems = packNums

	setDecomposeNum(self)
end

local function getPackArray(self)
	local list = {}
	local packList = cache.PackCache:getShengXiaoData()
	for k, v in pairs(packList) do
		local itemCfg = conf.ItemConf:getItem(v.mid)
		if itemCfg.stage_lvl <= 11 then
			table.insert(list, v)
		end
	end
	return list
end

local function setBagList(self)
	self.packArray = getPackArray(self)
end

function ShengXiaoFenJieView:ctor()
	self.super.ctor(self)
	self.uiClear = UICacheType.cacheTime
	self.uiLevel = UILevel.level2
end

function ShengXiaoFenJieView:initView()
	local decomposeBtn = self.view:GetChild("n14")
	decomposeBtn.onClick:Add(self.onClickDecomposeBtn, self)

	self.qualityBtn = self.view:GetChild("n24")
	self.qualityBtn.onClick:Add(self.onClickQualityBtn, self)

	self.starBtn = self.view:GetChild("n21")
	self.starBtn.onClick:Add(self.onClickStarBtn, self)

	self.decomposeNum = self.view:GetChild("n16")

	self.itemList = self.view:GetChild("n3")
	self.itemList.numItems = 0
	self.itemList.itemRenderer = function(index, obj)
		self:refreshItemCell(index, obj)
	end
	self.itemList:SetVirtual()

	self.qualityList = self.view:GetChild("n6")
	self.qualityList.numItems = #language.kagee47[2]
	self.qualityList.itemRenderer = function(index, obj)
		self:refreshQualityCell(index, obj)
	end
	self.qualityList:SetVirtual()

	self.starList = self.view:GetChild("n10")
	self.starList.numItems = #language.kagee47[1]
	self.starList.itemRenderer = function(index, obj)
		self:refreshStarCell(index, obj)
	end
	self.starList:SetVirtual()

	self.qualityListRoot = self.view:GetChild("n7")
	self.starListRoot = self.view:GetChild("n11")
	self.qualityText = self.view:GetChild("n25")
	self.starText = self.view:GetChild("n22")

	local closeBtn = self.view:GetChild("n0"):GetChild("n7")
	closeBtn.onClick:Add(self.onClickClose, self)
end

function ShengXiaoFenJieView:initData(data)
	self.selectItems = {}
	self.starListRoot.visible = false
	self.qualityListRoot.visible = false
	self.curQualityIndex = 1
	self.curStarIndex = 1
	self.qualityText.text = language.kagee47[2][1]
	self.starText.text = language.kagee47[1][1]

	setBagList(self)
	setSelectItems(self)
end

function ShengXiaoFenJieView:onClickDecomposeBtn()
	if nil == next(self.selectItems) then
		GComAlter(language.kagee64)
		return
	end
	local indexs = {}
	for k, v in pairs(self.selectItems) do
		table.insert(indexs, v.index)
	end
	self.selectItems = {}
	proxy.ShengXiaoProxy:sendDecompose(indexs)
end

function ShengXiaoFenJieView:onClickQualityBtn()
	local value = self.qualityListRoot.visible
	self.qualityListRoot.visible = not value
	self.starListRoot.visible = false
	if not value then
		self.qualityList.numItems = 0
		self.qualityList.numItems = #language.kagee47[2]
	end
end

function ShengXiaoFenJieView:onClickStarBtn()
	local value = self.starListRoot.visible
	self.starListRoot.visible = not value
	self.qualityListRoot.visible = false
	if not value then
		self.starList.numItems = 0
		self.starList.numItems = #language.kagee47[1]
	end
end

-- 格子列表
function ShengXiaoFenJieView:refreshItemCell(index, obj)
	local item = obj:GetChild("n5")
	obj.selected = nil ~= self.selectItems[index + 1]
	local itemData = self.packArray[index + 1] or {}
	obj.touchable = nil ~= itemData.mid
	local info = {
			mid = itemData.mid,
			amount = itemData.amount,
			bind = itemData.bind,
			isquan = true}
	GSetItemData(item, info)
	item.data = {index = index, itemData = itemData}
	item.onClick:Add(self.onClickItemCell, self)
end

function ShengXiaoFenJieView:onClickItemCell(context)
	local cell = context.sender
    local data = cell.data
    local selected = self.selectItems[data.index + 1]
    self.selectItems[data.index + 1] = nil == selected and data.itemData or nil
    setDecomposeNum(self)
end

-- 品质选择列表
function ShengXiaoFenJieView:refreshQualityCell(index, obj)
	obj:GetChild("title").text = language.kagee47[2][index + 1]
	obj.data = {index = index}
	obj.selected = (index + 1) == self.curQualityIndex
	obj.onClick:Add(self.onClickQualityCell, self)
end

-- 星级选择列表
function ShengXiaoFenJieView:refreshStarCell(index, obj)
	obj:GetChild("title").text = language.kagee47[1][index + 1]
	obj.data = {index = index}
	obj.selected = (index + 1) == self.curStarIndex
	obj.onClick:Add(self.onClickStarCell, self)
end

function ShengXiaoFenJieView:onClickQualityCell(context)
	local cell = context.sender
    local data = cell.data
    self.qualityListRoot.visible = false
    if self.curQualityIndex == data.index + 1 then
    	return
    end
    self.qualityText.text = language.kagee47[2][data.index + 1]
    self.curQualityIndex = data.index + 1

    setBagList(self)
    setSelectItems(self)
end

function ShengXiaoFenJieView:onClickStarCell(context)
	local cell = context.sender
    local data = cell.data
    self.starListRoot.visible = false
    if self.curStarIndex == data.index + 1 then
    	return
    end
    self.starText.text = language.kagee47[1][data.index + 1]
    self.curStarIndex = data.index + 1

    setBagList(self)
    setSelectItems(self)
end

function ShengXiaoFenJieView:onClickClose()
	self:closeView()
end

function ShengXiaoFenJieView:flush()
	setBagList(self)
	setSelectItems(self)
end

return ShengXiaoFenJieView