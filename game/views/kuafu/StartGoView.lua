--
-- Author: 
-- Date: 2017-07-04 15:41:04
--

local StartGoView = class("StartGoView", base.BaseView)

function StartGoView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function StartGoView:initData(data)
    -- body
    self.time = data.time or 5
    self.data = data
    if data.opaque and data.opaque == 1 then--可穿透
        self.view.opaque = false
        self.time = 3
    else
        self.view.opaque = true
    end
    self.labtext.text = self.time
    if self.timeer then
        self:removeTimer(self.timeer)
    end
    self.timeer = self:addTimer(1,-1,handler(self,self.onTimer))
end

function StartGoView:onTimer()
    -- body
    self.time  = self.time - 1

    self.labtext.text = self.time
    if self.time <= 0 then
        self:oncloseView()
    end

end

function StartGoView:initView()
    self.labtext = self.view:GetChild("n2")
end

function StartGoView:setData(data_)

end

function StartGoView:oncloseView()
    -- body
    if self.data and self.data.sceneId then
        mgr.FubenMgr:gotoFubenWar(self.data.sceneId)
    end
    self:closeView()
end

return StartGoView