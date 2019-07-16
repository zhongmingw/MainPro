--
-- Author: 
-- Date: 2018-08-29 21:42:24
--

local DoubelBackView = class("DoubelBackView", base.BaseView)

function DoubelBackView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function DoubelBackView:initView()
    local btn = self.view:GetChild("n0"):GetChild("n6")
    self:setCloseBtn(btn)
    self.labtimer = self.view:GetChild("n6")

    local btn1 = self.view:GetChild("n4")
    btn1.onClick:Add(self.onBtnCallBack,self)
end

function DoubelBackView:initData(data)
    if data then
        self:addMsgCallBack(data)
    end

    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"DoubelBackView")

end

function DoubelBackView:onTimer( ... )
    -- body
    if not self.data then return end
    if self.data.actLeftTime <= 0 then
        GComAlter(language.kuafu106)
        self:closeView()
        return
    end

    self.data.actLeftTime = self.data.actLeftTime - 1
    self.data.actLeftTime = math.max(self.data.actLeftTime,0)
    self.labtimer.text = language.jhs01 .. mgr.TextMgr:getTextColorStr( GGetTimeData2(self.data.actLeftTime), 7)
end

function DoubelBackView:onBtnCallBack()
    -- body
    GOpenView({id = 1042})
end

function DoubelBackView:addMsgCallBack( data )
    -- body
    self.data = data 
end

return DoubelBackView