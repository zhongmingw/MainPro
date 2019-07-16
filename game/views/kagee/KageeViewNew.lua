local KageeViewNew = class("KageeViewNew", base.BaseView)

local XianMaiPanel = import(".XianMaiPanel")
local ShengXiaoBaoZangPanel = import(".ShengXiaoBaoZangPanel")
local ShengXiaoPanel = import(".ShengXiaoPanel")

local XIAN_MAI = 0		-- 仙脉
local BAO_ZANG = 2		-- 宝藏
local SHENG_XIAO = 1	-- 生肖

local XIAN_MAI_ID = 1070	-- 仙脉模块ID
local BAO_ZANG_ID = 1441	-- 宝藏模块ID
local SHENG_XIAO_ID = 1442	-- 生肖模块ID

local PANEL_INDEX = {
	[XIAN_MAI_ID] = XIAN_MAI,
	[BAO_ZANG_ID] = BAO_ZANG,
	[SHENG_XIAO_ID] = SHENG_XIAO,
}

local MODULE_INDEX = {
	[XIAN_MAI] = XIAN_MAI_ID,
	[BAO_ZANG] = BAO_ZANG_ID,
	[SHENG_XIAO] = SHENG_XIAO_ID,
}

-- 红点
local RED_POINTS = {
	[XIAN_MAI] = 10217,
	[BAO_ZANG] = 30257,
	[SHENG_XIAO] = 20217,
}

function KageeViewNew:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true

    self.viewList = {}
    self.panelObjList = {}
end

function KageeViewNew:initView()
	-- 窗口
	local win = self.view:GetChild("n0")
	local closeBnt = win:GetChild("n7")
	self:setCloseBtn(closeBnt)

	self.shengXiaoObj = self.view:GetChild("n28")
	self.panelObjList[SHENG_XIAO] = self.shengXiaoObj

	self.baoZangObj = self.view:GetChild("n30")
	self.panelObjList[BAO_ZANG] = self.baoZangObj

	self.xianMaiObj = self.view:GetChild("n31")
	self.panelObjList[XIAN_MAI] = self.xianMaiObj

	self.leftControl = self.view:GetController("c1")
	self.leftControl.onChanged:Add(self.onLeftControlChange, self)

	self.kageeBtn = self.view:GetChild("n17")
	self.baoZangBtn = self.view:GetChild("n19")
	self.shengXiaoBtn = self.view:GetChild("n18")

	self.kageeRed = self.kageeBtn:GetChild("n5")
	self.baoZangRed = self.baoZangBtn:GetChild("n5")
	self.ShengXiaoRed = self.shengXiaoBtn:GetChild("n5")
end

function KageeViewNew:initData(data)
	local param1 = {panel = self.kageeRed, ids = {RED_POINTS[XIAN_MAI]}}
	mgr.GuiMgr:registerRedPonintPanel(param1, self:viewName())

	local param2 = {panel = self.baoZangRed, ids = {RED_POINTS[BAO_ZANG]}}
	mgr.GuiMgr:registerRedPonintPanel(param2, self:viewName())

	local param3 = {panel = self.ShengXiaoRed, ids = {RED_POINTS[SHENG_XIAO]}}
	mgr.GuiMgr:registerRedPonintPanel(param3, self:viewName())

	self.oldIndex = 0
	self.isFirst = true
	if nil ~= data then
		local index = PANEL_INDEX[data.moduleId or XIAN_MAI_ID]
		if index == self.leftControl.selectedIndex then
			self:onLeftControlChange()
		else
			self.leftControl.selectedIndex = index
		end
	else
		self:onLeftControlChange()
	end

	self.kageeBtn.visible = mgr.ModuleMgr:CheckSeeView(XIAN_MAI_ID)
	self.baoZangBtn.visible = mgr.ModuleMgr:CheckSeeView(BAO_ZANG_ID)
	self.shengXiaoBtn.visible = mgr.ModuleMgr:CheckSeeView(SHENG_XIAO_ID)

	self:refreshReds()
end

function KageeViewNew:onLeftControlChange()
	local selectIndex = self.leftControl.selectedIndex

	-- 检测当前系统是否开放
	if not mgr.ModuleMgr:CheckView({id = MODULE_INDEX[selectIndex], falg = true}) then
        self.leftControl.selectedIndex = self.oldIndex
        return
    end

    self.oldIndex = selectIndex
	if selectIndex == XIAN_MAI then	-- 仙脉
		if nil == self.viewList[XIAN_MAI] then
			self.viewList[XIAN_MAI] = XianMaiPanel.new(self)
		end
        proxy.KageeProxy:send(1150101,{reqType = 0,ywId = 0})
	elseif selectIndex == BAO_ZANG then -- 宝藏
		if nil == self.viewList[BAO_ZANG] then
			self.viewList[BAO_ZANG] = ShengXiaoBaoZangPanel.new(self)
		end

		-- 请求数据
		proxy.ShengXiaoProxy:sendGetBaoZangInfo(0)
		proxy.ShengXiaoProxy:sendGetBaoZangWareInfo(0)

	elseif selectIndex == SHENG_XIAO then -- 生肖
		if nil == self.viewList[SHENG_XIAO] then
			self.viewList[SHENG_XIAO] = ShengXiaoPanel.new(self)
		end
		self.viewList[SHENG_XIAO]:flush()
	end

	-- 第一次由服务器刷新
	if not self.isFirst then
		self:refreshRedPoint()
	end

	self.isFirst = false
end

-- 刷新红点
function KageeViewNew:refreshRedPoint()
	local selectIndex = self.leftControl.selectedIndex
	self:refreshAppointRed(selectIndex)
end

-- 刷新除了当前选中标签以外的红点
function KageeViewNew:refreshReds()
	local selectIndex = self.leftControl.selectedIndex
	for i = 0, 2 do
		if selectIndex ~= i then
			self:refreshAppointRed(i)
		end
	end
end

-- 刷新指定的红点
function KageeViewNew:refreshAppointRed(index)
	local var = RED_POINTS[index]
	if nil == var then
		return
	end
	local isShowRed = false
	if index == BAO_ZANG then
		isShowRed = cache.ShengXiaoCache:isShowBaoZangRed()
	elseif index == SHENG_XIAO then
		isShowRed = cache.ShengXiaoCache:isShowSxAllRed()
	elseif index == XIAN_MAI then
		isShowRed = cache.PlayerCache:getRedPointById(attConst.A10217) > 0
	end

	if isShowRed then
		cache.PlayerCache:setRedpoint(var, 1)
        mgr.GuiMgr:updateRedPointPanels(var)
        mgr.GuiMgr:refreshRedBottom()
	else
		mgr.GuiMgr:redpointByID(var, cache.PlayerCache:getRedPointById(var))
	end
end

function KageeViewNew:getBaoZangWarePos()
	if nil == self.viewList[BAO_ZANG] then
		return {x = 0, y = 0}
	end
	return self.viewList[BAO_ZANG]:getBaoZangWarePos()
end

function KageeViewNew:playEff()
	if nil == self.viewList[BAO_ZANG] then
		return
	end
	self.viewList[BAO_ZANG]:playEff()
end

function KageeViewNew:flush(data)
	local selectIndex = self.leftControl.selectedIndex
	local view = self.viewList[selectIndex]
	local obj = self.panelObjList[selectIndex]
	if nil ~= view
		and nil ~= view.flush
		and nil ~= obj
		and obj.visible then

		view:flush(data)
		self:refreshRedPoint()
	end
end


return KageeViewNew