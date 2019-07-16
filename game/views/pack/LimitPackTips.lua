--
-- Author: 
-- Date: 2017-05-17 19:48:29
--

local LimitPackTips = class("LimitPackTips", base.BaseView)

local Time = 9

function LimitPackTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function LimitPackTips:initData(data)
    self:releaseTimer()
    self:setData()
end

function LimitPackTips:initView()
    self:setCloseBtn(self.view:GetChild("n2"))
    self:setCloseBtn(self.view:GetChild("n3"))
    self.desc = self.view:GetChild("n4")
    self.timeText = self.view:GetChild("n5")
end

function LimitPackTips:setData()
    local time = cache.PlayerCache:getAttribute(attConst.limitPack)
    self.desc.text = language.pack27..GTotimeString(time)..language.pack28
    if not self.tipsTimer then
        self.time = Time--关闭倒计时
        self:onTimer()
        self.tipsTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    if time <= 3600 then
        cache.PackCache:setIsOpenLimitTip1(true)
    end
    cache.PackCache:setIsOpenLimitTip(true)
end

function LimitPackTips:releaseTimer()
    if self.tipsTimer then
        self:removeTimer(self.tipsTimer)
        self.tipsTimer = nil
    end
end

function LimitPackTips:onTimer()
    self.timeText.text = string.format(language.fuben11, self.time)
    if self.time <= 0 then
        
        self:releaseTimer()
        self:closeView()
        return
    end
    self.time = self.time - 1
end

return LimitPackTips
