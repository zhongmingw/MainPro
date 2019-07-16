--
-- Author:wzm
-- Date: 2017-02-16 
--
local VipAttributePanel = import(".VipAttributePanel")
local VipChargePanel = import(".VipChargePanel")
local MonthCardPanel = import(".MonthCardPanel")

local VipChargeView = class("VipChargeView", base.BaseView)

function VipChargeView:ctor()
    self.super.ctor(self)
    self.uiClear = UICacheType.cacheTime
    self.uiLevel = UILevel.level2-- bxp
end

function VipChargeView:initData(data)
    local window2 = self.view:GetChild("n0")
    --local moneyPanel = window2:GetChild("n9")
    GSetMoneyPanel(window2,self:viewName())
    local closeBtn = window2:GetChild("btn_close") 

    self:vipChargeRedPoint()
    self:monthCardRedPoint()
    
    closeBtn.onClick:Add(self.onClickClose,self)
    local leftSeverTime = cache.VipChargeCache:getOnlineTime()--缓存的记录点
    local nowSeverTime = mgr.NetMgr:getServerTime() --当前服务器的时间点
    --在线时间
    -- self.actTime = cache.PlayerCache:getRedPointById(10108)+nowSeverTime-leftSeverTime
    --充值活动倒计时
    self.lastTime = 3
    self.timer = self:addTimer(1, -1, handler(self, self.timerClick))

    self.controllerC1 = self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onController1,self)
    self:onController1()
    self:GoToPage(data.index)
end

--vip升级红点
function VipChargeView:vipChargeRedPoint()
    local var = cache.VipChargeCache:getVipGradeUpRedPoint()
    if var > 0 then
        self.view:GetChild("n2"):GetChild("n4").visible = true
    else
        self.view:GetChild("n2"):GetChild("n4").visible = false
    end
end
--月卡红点
function VipChargeView:monthCardRedPoint()
    local var = cache.PlayerCache:getRedPointById(20201)
    -- print("20201>>>>>>>>>>>",var)
    if var > 0 then
        self.view:GetChild("n3"):GetChild("n4").visible = true
    else
        self.view:GetChild("n3"):GetChild("n4").visible = false
    end
end


function VipChargeView:initView()
    --按钮：充值，VIP，特权
    local btnCharge = self.view:GetChild("n1")
    btnCharge:GetChild("title").text = language.vip01

    local btnVIP = self.view:GetChild("n2")
    if g_ios_test then    --EVE 屏蔽掉VIP分栏(IOS屏蔽文档里没有，这是策划要求的)
        btnVIP.visible = false
        return
    end 
    btnVIP:GetChild("title").text = language.vip02
    local btnMonthCard = self.view:GetChild("n3")
    btnMonthCard.title = language.vip37

end

function VipChargeView:setData()
    --首冲活动倒计时
    local severTime = mgr.NetMgr:getServerTime() --当前服务器的时间点
    self.lastTime = cache.VipChargeCache:getRechargeList().actLastTime - severTime
    self.VipChargePanel:setFirstChargeActTime(self.lastTime)
end
--获取活动结束时间
function VipChargeView:getLastTime()
    return self.lastTime
end

--跳转用 page 0 充值 1 vip属性加成
function VipChargeView:GoToPage( page )
    -- body
    self.controllerC1.selectedIndex = page or 0

    -- print("当前页：",page)
    if page == 1 then 
        proxy.VipChargeProxy:sendDiscountedPacksMsg()
    end 
end

function VipChargeView:onController1()
    -- body
    if 0 == self.controllerC1.selectedIndex then  --充值信息 
        if not self.VipChargePanel then
            self.VipChargePanel = VipChargePanel.new(self)
        end
        self.VipChargePanel:updateChongzhi()
    elseif 1 == self.controllerC1.selectedIndex then --VIP加成信息
        if not self.VipAttributePanel then
            self.VipAttributePanel = VipAttributePanel.new(self)
        else
            self.VipAttributePanel:initView()
        end

        proxy.VipChargeProxy:sendDiscountedPacksMsg()
    elseif 2 == self.controllerC1.selectedIndex then
        if not self.monthCardPanel then
            self.monthCardPanel = MonthCardPanel.new(self)
        end
        proxy.ActivityProxy:sendMsg(1030512,{reqType = 0,pos = 1,awardId = 0})
    end
end

function VipChargeView:add5030512(data)
    if self.monthCardPanel then
        self.monthCardPanel:addMsgCallBack(data)
    end
end

function VipChargeView:timerClick()
    -- body
    -- local vipLv = cache.PlayerCache:getVipLv()
    -- if vipLv<1 then
    --     self.actTime = self.actTime + 1  --在线时间计时
    --     if self.VipAttributePanel then
    --         self.VipAttributePanel:setTimeBar(self.actTime)
    --     end
    -- end
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1 --首冲活动倒计时
        if self.VipChargePanel then
            self.VipChargePanel:setFirstChargeActTime(self.lastTime)
        end
    elseif not self.isIn then
        self.isIn = true
        if self.VipChargePanel then
            self.VipChargePanel:setFirstChargeActTime(self.lastTime)
        end
    end
end

function VipChargeView:onClickClose()
    -- body
    self:closeView()
end

return VipChargeView