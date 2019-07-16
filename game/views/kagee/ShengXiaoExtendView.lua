local ShengXiaoExtendView = class("ShengXiaoExtendView", base.BaseView)

local ATTR_NUM = 6

local function setInfo(self)
	local level = cache.ShengXiaoCache:getSkillMax()
	local curCfg = conf.ShengXiaoConf:getSKillExtendCfg(level)
	local nextCfg = conf.ShengXiaoConf:getSKillExtendCfg(level + 1)

	local isMax = nil == nextCfg
	self.lock.visible = isMax or nil == curCfg.cost_item
	self.extendBtn.grayed = isMax

	nextCfg = nextCfg and nextCfg or curCfg
	local curAttrs = GConfDataSort(curCfg)
	local nextAttrs = GConfDataSort(nextCfg)

	local curAttr = nil
	local nextAttr = nil
	for k, v in pairs(self.curAttrList) do
		curAttr = curAttrs[k]
		nextAttr = nextAttrs[k]
		v.root.visible = nil ~= curAttr
		self.nextAttrList[k].root.visible = nil ~= nextAttr
		if nil ~= curAttr then
			local attName = conf.RedPointConf:getProName(curAttr[1])
			v.name.text = attName
			self.nextAttrList[k].name.text = attName
			v.value.text = curAttr[2]
			self.nextAttrList[k].value.text = nextAttr[2]
		end
	end
	if nil ~= curCfg.cost_item then
		self.costNum.visible = true

		local mid = curCfg.cost_item[1][1]
		local needCount = curCfg.cost_item[1][2]
		local info = {mid = mid, amount = 0, bind = 0}
		GSetItemData(self.itemCell, info, true)
		local itemData = cache.PackCache:getPackDataById(mid, true)
		local myCount = itemData.amount
		local textData = {
	        {text = myCount, color = 7},
	        {text = "/" .. needCount, color = 7},
		}
		if needCount > myCount then
		    textData[1].color = 14
		end
		self.costNum.text = mgr.TextMgr:getTextByTable(textData)
	else
		GSetItemData(self.itemCell, {})
		self.costNum.visible = false
	end
	self.itemRoot.touchable = nil ~= curCfg.cost_item
end

function ShengXiaoExtendView:ctor()
	self.super.ctor(self)
	self.uiClear = UICacheType.cacheTime
	self.uiLevel = UILevel.level2

	self.curAttrList = {}
	self.nextAttrList = {}
end

function ShengXiaoExtendView:initView()
	local curCom = self.view:GetChild("n3")

	local nextCom = self.view:GetChild("n4")
	local nextTitle = nextCom:GetChild("n1")
	nextTitle.text = language.kagee32

	for i = 1, ATTR_NUM do
		local curAttrRoot = curCom:GetChild("attr" .. i)
		local curName = curAttrRoot:GetChild("name")
		local curValue = curAttrRoot:GetChild("value")

		local nextAttrRoot = nextCom:GetChild("attr" .. i)
		local nextName = nextAttrRoot:GetChild("name")
		local nextValue = nextAttrRoot:GetChild("value")

		self.curAttrList[i] = {
			root = curAttrRoot,
			name = curName,
			value = curValue,
		}
		self.nextAttrList[i] = {
			root = nextAttrRoot,
			name = nextName,
			value = nextValue,
		}
	end

	self.extendBtn = self.view:GetChild("n7")
	self.extendBtn.onClick:Add(self.onClickExtendBtn, self)

	self.itemRoot = self.view:GetChild("n14")
	self.itemCell = self.itemRoot:GetChild("n5")
	self.costNum = self.view:GetChild("n12")
	self.lock = self.view:GetChild("lock")

	local closeBtn = self.view:GetChild("n0"):GetChild("n7")
	closeBtn.onClick:Add(self.onClickClose, self)
end

function ShengXiaoExtendView:initData(data)
	setInfo(self)
end

function ShengXiaoExtendView:onClickExtendBtn()
	local level = cache.ShengXiaoCache:getSkillMax()
	local curCfg = conf.ShengXiaoConf:getSKillExtendCfg(level)
	local nextCfg = conf.ShengXiaoConf:getSKillExtendCfg(level + 1)
	if nil == nextCfg then
		GComAlter(language.kagee36)
		return
	end
	if nil ~= curCfg.cost_item then
		local mid = curCfg.cost_item[1][1]
		local needCount = curCfg.cost_item[1][2]
		local itemData = cache.PackCache:getPackDataById(mid, true)
		local myCount = itemData.amount
		if needCount > myCount then
			GComAlter(language.kagee35)
			return
		end
	end
	proxy.ShengXiaoProxy:sendExtendSkill()
end

function ShengXiaoExtendView:onClickClose()
	self:closeView()
end

function ShengXiaoExtendView:flush()
	setInfo(self)
end

return ShengXiaoExtendView