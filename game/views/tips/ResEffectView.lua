--
-- Author: 
-- Date: 2017-07-17 19:20:59
--

local ResEffectView = class("ResEffectView", base.BaseView)

local goldEffectId = 4020123

function ResEffectView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function ResEffectView:initData(data)
    self:setData(data)
end

function ResEffectView:initView()
    self.effect = self.view:GetChild("n0")
end

function ResEffectView:setData(data)
    self:addEffect(goldEffectId, self.effect)
    local confEffectData = conf.EffectConf:getEffectById(goldEffectId)
    local confTime = confEffectData and confEffectData.durition_time or 0
    self:addTimer(confTime, 1, function( ... )
        self:closeView()
    end)
end

return ResEffectView