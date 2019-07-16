local ShengXiaoBaoZangWareView = class("ShengXiaoBaoZangWareView", base.BaseView)

local ROW = 8		-- 最小行数
local COLUMN = 8	-- 列数

function ShengXiaoBaoZangWareView:ctor()
	self.super.ctor(self)
	self.uiClear = UICacheType.cacheTime
	self.uiLevel = UILevel.level2
end

function ShengXiaoBaoZangWareView:initView()
	local takeOutBtn = self.view:GetChild("n3")
	takeOutBtn.onClick:Add(self.onClickTakeOutBtn, self)

	self.listView = self.view:GetChild("n1")
	self.listView.numItems = 0
	self.listView.itemRenderer = function(index, obj)
		self:refreshCell(index, obj)
	end
	self.listView:SetVirtual()

	local closeBtn = self.view:GetChild("n0"):GetChild("n2")
	closeBtn.onClick:Add(self.onClickClose, self)
end

function ShengXiaoBaoZangWareView:initData(data)
	self.itemInfos = {}
end

function ShengXiaoBaoZangWareView:refreshCell(index, obj)
	local item = obj:GetChild("n5")
	GSetItemData(item, self.itemInfos[index + 1] or {}, true)
end

function ShengXiaoBaoZangWareView:onClickTakeOutBtn()
	proxy.ShengXiaoProxy:sendGetBaoZangWareInfo(1)
end

function ShengXiaoBaoZangWareView:onClickClose()
	self:closeView()
end

function ShengXiaoBaoZangWareView:flush(data)
	if nil == data then
		return
	end
	self.itemInfos = data.itemInfos
	if #data.itemInfos < ROW * COLUMN then
		self.listView.numItems = ROW * COLUMN
	else
		self.listView.numItems = #data.itemInfos + 4 * COLUMN
	end
end

return ShengXiaoBaoZangWareView