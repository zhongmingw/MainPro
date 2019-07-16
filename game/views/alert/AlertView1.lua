--
-- Author: Your Name
-- Date: 2017-01-03 16:18:07
--

local AlertView1 = class("AlertView1", base.BaseView)

function AlertView1:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level4--策划反应，有时候飘字被覆盖，所以提前一层
end

function AlertView1:initView()
    self.richText = self.view:GetChild("n1")
end

function AlertView1:setData(data_)
    self.richText.text = data_.richtext 
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
    self.timer = self:addTimer(2.5, 1, function()
        self:onCloseView()
    end)
end

function AlertView1:onCloseView()
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
    self:closeView()
end

return AlertView1