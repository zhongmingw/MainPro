--
-- Author: 
-- Date: 2018-07-03 22:05:34
--

local HeFuFanLi = class("HeFuFanLi", base.BaseView)

function HeFuFanLi:ctor()
    HeFuFanLi.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function HeFuFanLi:initView()
    local btnClose = self.view:GetChild("n1")
    self:setCloseBtn(btnClose)
    local chargeBtn = self.view:GetChild("n9")  --充值按钮
    chargeBtn.onClick:Add(self.onClickCharge,self)
    self.leftTimes = self.view:GetChild("n10")
end
function HeFuFanLi:initData()
    local endTime = cache.PlayerCache:getRedPointById(30154)
    local nowTime =mgr.NetMgr:getServerTime()
    self.time = endTime-nowTime
    if self.timertick then 
        self:removeTimer(self.timertick)
        self.timertick = nil
    end
    if not self.timertick then 
        self:onTimer()
        self.timertick = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function HeFuFanLi:onTimer()
    if self.time then 
        self.leftTimes.text = GGetTimeData2(self.time)
        if self.time <= 0 then 
            self:onClickClose()
        end
        self.time = self.time - 1
    end
end

function HeFuFanLi:onClickCharge()
    GGoVipTequan(0)
    self:closeView()
end

function HeFuFanLi:onClickClose()
    if self.timertick then
        self:removeTimer(self.timertick)
        self.timertick = nil
    end
    self:closeView()
end

return HeFuFanLi