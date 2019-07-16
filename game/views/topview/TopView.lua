--
-- Author: Your Name
-- Date: 2017-06-15 19:41:57
--

local TopView = class("TopView", base.BaseView)

function TopView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function TopView:initView()
    local node = self.view:GetChild("n0")
    local effectId = 4020122
    local effect = self:addEffect(effectId,node)
    local confEffectData = conf.EffectConf:getEffectById(effectId)
    local confTime = confEffectData and confEffectData.durition_time or 1
    self.timer = mgr.TimerMgr:addTimer(confTime - 0.3, 1,handler(self, self.onTimer))
end

function TopView:onTimer(  )
    self:onClose()
end

function TopView:onClose(data)
    GOpenView({id = 1053})
    cache.PlayerCache:setRedpoint(10308,0)
    self:closeView()
end

return TopView