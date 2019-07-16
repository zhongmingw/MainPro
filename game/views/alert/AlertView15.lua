--
-- Author: 
-- Date: 2017-07-20 19:23:25
--

local AlertView15 = class("AlertView15", base.BaseView)

function AlertView15:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level5 
    --self.isBlack = true
end

function AlertView15:initData(data)
    -- body
    --避免错误10秒关闭自己
    if self.time then
        self:removeTimer(self.time)
    end
    self.time = self:addTimer(10, 1, function()
        -- body
        self:closeView()
    end)
    --开始播放特效
    if not data then
        self:closeView()
        return
    end
    local id = 0
    local callback
    if type(data) == "table" then
        id = data.id

        callback = data.callback
    else
        id = data 
    end

    local effect , delay = self:addEffect(id,self.panel) 
    if id == 4020169 then
        effect.LocalPosition = Vector3(573.16,-555,0)
    else
        effect.LocalPosition = Vector3(self.panel.actualWidth/2,-self.panel.actualHeight/2,0)
    end
    
    if delay ~= -1 then
        self:addTimer(delay, 1, function()
            -- body
            if callback then
                callback()
            end
            self:closeView()
        end)
    end
end

function AlertView15:initView()
    self.panel = self.view:GetChild("n0")
end

function AlertView15:setData(data_)

end

return AlertView15