--
-- Author: 
-- Date: 2017-08-31 14:28:41
--

local MarryGuide = class("MarryGuide", base.BaseView)

function MarryGuide:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function MarryGuide:initView()
    local btnClose = self.view:GetChild("n20")
    btnClose.onClick:Add(self.onCloseView,self)

    local btnGoon = self.view:GetChild("n23")
    btnGoon.onClick:Add(self.onCloseView,self)

    --self.bg = self.view:GetChild("n12")

end

function MarryGuide:initData()
    -- body
    --加一个特效 --花瓣
    mgr.ViewMgr:openView2(ViewName.Alert15, 4020127)
    local confData = conf.SysConf:getLoadingConfById(2)
    --self.bg.url = UIItemRes.loading01..confData.loadimg
    if self.timer then
        self:removeTimer(self.timer)
    end
    self.delay = 10
    self.timer = self:addTimer(1,-1,handler(self,self.onTimer))
end

function MarryGuide:onTimer()
    -- body
    self.delay = math.max(self.delay-1,0)
    --self.labtimer.text = string.format(language.marryiage19,self.delay)
    if self.delay < 1 then
        self:onCloseView()
    end
end

function MarryGuide:setData(data_)
    
end

function MarryGuide:onCloseView()
    -- body
    GgoToMainTask()
    self:closeView()
end

return MarryGuide