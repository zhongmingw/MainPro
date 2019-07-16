--
-- Author: 
-- Date: 2017-07-21 20:26:09
--

local FlagHoldView = class("FlagHoldView", base.BaseView)

function FlagHoldView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function FlagHoldView:initView()
    self.timeText = self.view:GetChild("n2")
    self.roleName = self.view:GetChild("n4")
end

function FlagHoldView:initData(data)
    self:releaseTimer()
    self:setData(data)
end

function FlagHoldView:setData(data)
    self.time = data.leftTime
    self.roleName.text = data.holeName or ""
    if not self.falgTimer then
        self:onTimer()
        self.falgTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function FlagHoldView:releaseTimer()
    if self.falgTimer then
        self:removeTimer(self.falgTimer)
        self.falgTimer = nil
    end
end

function FlagHoldView:onTimer()
    self.timeText.text = language.wending19..mgr.TextMgr:getTextColorStr(GTotimeString3(self.time), 7)
    if self.time <= 0 then
        self:closeView()
        return
    end
    self.time = self.time - 1
end

return FlagHoldView