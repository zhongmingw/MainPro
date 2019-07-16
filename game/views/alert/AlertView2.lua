--
-- Author: Your Name
-- Date: 2017-01-03 16:31:14
--

local AlertView2 = class("AlertView2", base.BaseView)

function AlertView2:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function AlertView2:initView()
    self.view:Center()
    self.richText = self.view:GetChild("n8")
    self.oldx = self.richText.x
    self.btnLeft = self.view:GetChild("n9")
    self.btnLeft.onClick:Add(self.onBtnLeftCallBack,self)

    self.btnRight = self.view:GetChild("n10")
    self.btnRight.onClick:Add(self.onBtnRightCallBack,self)

    local btnClose = self.view:GetChild("n7")
    btnClose.onClick:Add(self.onCloseView,self)

    self.lab = self.view:GetChild("n12")
    self.lab.visible = false
end

function AlertView2:setData(data_)
    self.data = data_
    self.lab.text = data_.richtext 
    self.richText.text = data_.richtext 
    
    if self.lab.actualWidth <  self.richText.actualWidth then
       self.richText.x = self.oldx + (self.richText.width - self.lab.width)/2
    else
        self.richText.x = self.oldx
    end

    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil 
    end

    if self.data.timer then
        self._serverTime = mgr.NetMgr:getServerTime()
        self.timer =  self:addTimer(1,self.data.timer,handler(self,self.onTimer))
    end

    if self.data.sureIcon then
        self.btnRight.icon = self.data.sureIcon
    else
        self.btnRight.icon = "ui://_imgfonts/juesexinxishuxin_013"
    end
    if self.data.cancelIcon then
        self.btnLeft.icon = self.data.cancelIcon
    else
        self.btnLeft.icon = "ui://_imgfonts/juesexinxishuxin_014"
    end
end
--时间到了默认回调
function AlertView2:onTimer()
    -- body
    local _timer = mgr.NetMgr:getServerTime()
    --plog(_timer,"_timer")
    if _timer - self._serverTime >=self.data.timer then
        self:onCloseView()
    end

    -- self.data.timer = self.data.timer - 1
    -- --plog("self.data.timer",self.data.timer)
    -- if self.data.timer <= 0 then
    --     self:onCloseView()
    -- end
end

function AlertView2:onBtnLeftCallBack()
    -- body
    if self.data.cancel then 
        self.data.cancel()
    end
    self:closeView() 
end

function AlertView2:onBtnRightCallBack()
    -- body
    if self.data.sure then 
        self.data.sure()
    end
    self:closeView()
end

function AlertView2:onCloseView()
    -- body
    if self.data.closefun then 
        self.data.closefun()
    end
    self:closeView()
end

return AlertView2