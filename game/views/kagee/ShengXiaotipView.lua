local ShengXiaotipView = class("ShengXiaotipView", base.BaseView)

function ShengXiaotipView:ctor()
	self.super.ctor(self)
	self.uiClear = UICacheType.cacheTime
	self.uiLevel = UILevel.level2
end

function ShengXiaotipView:initView()
	self.noAttr = self.view:GetChild("n6")

	self.listView = self.view:GetChild("n3")
	self.listView.numItems = 0
	self.listView.itemRenderer = function(index, obj)
		self:refreshAttrCell(index, obj)
	end
	self.listView:SetVirtual()

	local closeBtn = self.view:GetChild("n0"):GetChild("n2")
	closeBtn.onClick:Add(self.onClickClose, self)
end

function ShengXiaotipView:initData(data)
	local allAttrs = conf.ShengXiaoConf:getAllSpecialAttrs()
	allAttrs = GConfDataSort(allAttrs)
	if nil == next(allAttrs) then
		self.listView.numItems = 0
		self.noAttr.visible = true
	else
		self.listView.numItems = #allAttrs
		self.noAttr.visible = false
	end
end

function ShengXiaotipView:refreshAttrCell(index, obj)
	local content = obj:GetChild("str")
	local allAttrs = conf.ShengXiaoConf:getAllSpecialAttrs()
	allAttrs = GConfDataSort(allAttrs)
	local attName = conf.RedPointConf:getProName(allAttrs[index + 1][1])
	content.text = attName .. ":" .. mgr.TextMgr:getTextColorStr(allAttrs[index + 1][2], 7)
end

function ShengXiaotipView:onClickClose()
	self:closeView()
end

return ShengXiaotipView