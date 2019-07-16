local ShengXiaoBaoZangPanel = class("ShengXiaoBaoZangPanel", import("game.base.Ref"))

local GEAR_NUM = 5

local NO_ACTIVE = 0
local ACTIVE = 1

local LESS_FOUR = 0		-- 激活小于四挡
local ACTIVE_FOUR = 1	-- 激活四挡
local ACTIVE_FIVE = 2	-- 激活五档

local function setInfo(self)
	local info = cache.ShengXiaoCache:getBaoZangInfo()
	if nil == info then
		return
	end

	local money = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)
	local bzCfg = nil
	for k, v in pairs(self.gearList) do
		bzCfg = conf.ShengXiaoConf:getBaoZangCfg(k)
		v.control.selectedIndex = info.stageMax >= k and ACTIVE or NO_ACTIVE
		if k == 1 and info.freeTimes > 0 then
			v.text.text = string.format(language.kagee55, language.kagee56)
			v.red.visible = true
		elseif nil ~= bzCfg then
			if k < 4 or info.stageMax >= k then
				local iconUrl = UIItemRes.moneyIcons[MoneyType.bindCopper]
				local icon = mgr.TextMgr:getImg(iconUrl)
				v.text.text = string.format(language.kagee55, icon .. bzCfg.copper[1][2])
				if info.stageMax >= k then
					v.red.visible = money >= bzCfg.copper[1][2]
				else
					v.red.visible = false
				end
			else
				v.red.visible = false
			end
		else
			v.text.text = ""
			v.red.visible = false
		end
	end

	if nil ~= self.gearEffect then
		self.parent:removeUIEffect(self.gearEffect)
		self.gearEffect = nil
	end

	self.gearEffect = self.parent:addEffect(4020219, self.gearList[info.stageMax].effectRoot)

	if info.stageMax < 4 then
		self.gearCtrl.selectedIndex = LESS_FOUR
	elseif info.stageMax == 4 then
		self.gearCtrl.selectedIndex = ACTIVE_FOUR
	else
		self.gearCtrl.selectedIndex = ACTIVE_FIVE
	end

	local bgIndex = nil ~= self.clickIndex and self.clickIndex or info.stageMax
	self.bgImg.url = UIPackage.GetItemURL("kagee" , UIItemRes.kageeIcon[bgIndex])
end

-- 用元宝进行召唤
local function starCallByGold(self, callType)
	-- local money = cache.PlayerCache:getTypeMoney(MoneyType.gold)
	local bzCfg = conf.ShengXiaoConf:getBaoZangCfg(5)
	local rate = callType == 2 and 10 or 1
	-- if money < (bzCfg.gold[1][2] * rate) then
	-- 	GComAlter(language.kagee60)
	-- 	return
	-- end

	if cache.ShengXiaoCache:getGoldTipState() then
		proxy.ShengXiaoProxy:sendGetBaoZangInfo(callType, 5, MoneyType.gold)
		return
	end
	local params = {}
	params.rightHandler = function(value)
		cache.ShengXiaoCache:setGoldTipState(value)
		proxy.ShengXiaoProxy:sendGetBaoZangInfo(callType, 5, MoneyType.gold)
	end
	params.leftHandler = function(value)
		cache.ShengXiaoCache:setGoldTipState(value)
	end
	local iconUrl = UIItemRes.moneyIcons[MoneyType.gold]
	local icon = mgr.TextMgr:getImg(iconUrl)
	local costGold = callType == 2 and bzCfg.gold[2][2] or bzCfg.gold[1][2]
	params.content = string.format(
						language.kagee62,
						icon,
						costGold,
						language.gonggong21[rate])

	mgr.ViewMgr:openView2(ViewName.Alert23, params)
end

function ShengXiaoBaoZangPanel:ctor(mParent)
	self.parent = mParent
	self.view = self.parent.baoZangObj
	self.gearList = {}
	self.packTime = os.time()

	self:initView()
end

function ShengXiaoBaoZangPanel:initView()
	local tenCallBtn = self.view:GetChild("n5")
	tenCallBtn.onClick:Add(self.onClickTenCallBtn, self)

	local onceCallBtn = self.view:GetChild("n7")
	onceCallBtn.onClick:Add(self.onClickOnceCallBtn, self)

	local bindCallBtn = self.view:GetChild("n6")
	bindCallBtn.onClick:Add(self.onClickBindCallBtn, self)

	local helpBtn = self.view:GetChild("n3")
	helpBtn.onClick:Add(self.onClickHelpBtn, self)

	self.wareBtn = self.view:GetChild("n63")
	self.wareBtn.onClick:Add(self.onClickWareBtn, self)

	self.effectRoot = self.view:GetChild("n65")

	self.gearCtrl = self.view:GetController("c1")

	for i = 1, GEAR_NUM do
		local item = self.view:GetChild("gear" .. i)
		local text = self.view:GetChild("geartext" .. i)
		item.data = {index = i}
		item.onClick:Add(self.onClickGearItem, self)
		self.gearList[i] = {
			control = item:GetController("c1"),
			text = text,
			red = item:GetChild("red"),
			effectRoot = item:GetChild("effectRoot"),
			item = item,
		}
	end

	self.redImg = self.view:GetChild("red")
	self.bgImg = self.view:GetChild("bg")
end

-- 召唤十次
function ShengXiaoBaoZangPanel:onClickTenCallBtn()
	starCallByGold(self, 2)
end

-- 召唤一次
function ShengXiaoBaoZangPanel:onClickOnceCallBtn()
	starCallByGold(self, 1)
end

-- 绑定元宝召唤
function ShengXiaoBaoZangPanel:onClickBindCallBtn()
	local money = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
	local bzCfg = conf.ShengXiaoConf:getBaoZangCfg(4)
	if money < bzCfg.bind_gold[1][2] then
		GComAlter(language.kagee59)
		return
	end
	if cache.ShengXiaoCache:getBindGoldTipState() then
		proxy.ShengXiaoProxy:sendGetBaoZangInfo(1, 4, MoneyType.bindGold)
		return
	end

	local params = {}
	params.rightHandler = function(value)
		cache.ShengXiaoCache:setBindGoldTipState(value)
		proxy.ShengXiaoProxy:sendGetBaoZangInfo(1, 4, MoneyType.bindGold)
	end
	params.leftHandler = function(value)
		cache.ShengXiaoCache:setBindGoldTipState(value)
	end
	local iconUrl = UIItemRes.moneyIcons[MoneyType.bindGold]
	local icon = mgr.TextMgr:getImg(iconUrl)
	params.content = string.format(
						language.kagee62,
						icon,
						bzCfg.bind_gold[1][2],
						language.gonggong21[1])
	mgr.ViewMgr:openView2(ViewName.Alert23, params)
end

-- 帮助
function ShengXiaoBaoZangPanel:onClickHelpBtn()
	GOpenRuleView(1175)
end

-- 临时仓库
function ShengXiaoBaoZangPanel:onClickWareBtn()
	proxy.ShengXiaoProxy:sendGetBaoZangWareInfo(0)
	mgr.ViewMgr:openView2(ViewName.ShengXiaoBaoZangWareView)
end

-- 档次格子
function ShengXiaoBaoZangPanel:onClickGearItem(context)
	local cell = context.sender
    local data = cell.data
    local info = cache.ShengXiaoCache:getBaoZangInfo()
	if nil == info then
		return
	end
	if data.index > info.stageMax then
		GComAlter(language.kagee58)
		return
	end
	local money = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)
	local bzCfg = conf.ShengXiaoConf:getBaoZangCfg(data.index)
	if info.freeTimes <= 0 then
		if money < bzCfg.copper[1][2] then
			GComAlter(language.kagee57)
			return
		end
	elseif data.index ~= 1 and money < bzCfg.copper[1][2] then
		GComAlter(language.kagee57)
		return
	end
	self.clickIndex = data.index
	proxy.ShengXiaoProxy:sendGetBaoZangInfo(1, data.index, MoneyType.bindCopper)
end

function ShengXiaoBaoZangPanel:getBaoZangWarePos()
	local btn = self.wareBtn
	local pos = btn:LocalToGlobal(btn.xy)
    return {x = pos.x + btn.width / 2, y = pos.y + btn.height / 2}
end

function ShengXiaoBaoZangPanel:playEff()
    local effectId = 4020106
    local cdTime = os.time() - self.packTime
    local confEffectData = conf.EffectConf:getEffectById(effectId)
    local confTime = confEffectData and confEffectData.durition_time or 0
    if cdTime >= confTime then
        self.parent:addEffect(effectId, self.effectRoot)
        self.packTime = os.time()
    end
end

function ShengXiaoBaoZangPanel:flush()
	GSetMoneyPanel(self.view, self.parent:viewName())
	setInfo(self)

	self.redImg.visible = cache.ShengXiaoCache:isShowBaoZangWareRed()
end

return ShengXiaoBaoZangPanel