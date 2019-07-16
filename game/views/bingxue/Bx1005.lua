--
-- Author: 
-- Date: 2019-01-08 11:21:23
--

local Bx1005 = class("Bx1005",import("game.base.Ref"))

function Bx1005:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Bx1005:onTimer()
    -- body
    if not self.data then return end
    -- local netTime = mgr.NetMgr:getServerTime()
    -- local leftTime = self.nextStartTime-netTime
    -- self.timeTxt.text = language.ydact015 .. GTotimeString(self.nextStartTime-netTime)
    -- if leftTime<=0 then
    --     self.timeTxt.visible =false
    --     self.gowarBtn.visible =true
    --     self.lastTime = self.nextStartTime
    --     proxy.ActivityWarProxy:send(1470101)
    -- end
    -- --超过活动时间段
    -- if self.lastTime then
    --     if netTime-self.lastTime>1200 then
    --         self.timeTxt.visible =true
    --         self.gowarBtn.visible =false
    --         self.lastTime =nil
    --     end
    -- end

    if self.leftSec > 0 then
        --self.timeTxt.text = language.ydact05 .. GTotimeString(self.leftSec)
        -- if not self.activeStart or self.activeStart==0 then
        --     proxy.ActivityWarProxy:send(1470101)
        -- end
        
        self.timeTxt.visible =false
        self.gowarBtn.visible =true
        self.gowarBtn:GetChild("red").visible = true
        self.leftSec = self.leftSec - 1
    else
        if self.nextStartTime-netTime<0 then
            proxy.ActivityWarProxy:send(1470101)
        end
        self.timeTxt.visible =true
        self.gowarBtn.visible =false
        self.gowarBtn:GetChild("red").visible = false
        local netTime = mgr.NetMgr:getServerTime()
        if self.nextStartTime-netTime <= 0 then
            proxy.ActivityWarProxy:send(1470101)
        end
        self.timeTxt.text = language.ydact015 .. GTotimeString(self.nextStartTime-netTime)
    end
end

-- 变量名：leftSec 说明：活动剩余时间
-- 变量名：nextStartTime   说明：下次开启时间
function Bx1005:addMsgCallBack(data)
    -- body
    self.data = data

    self.leftSec = data.leftSec
    printt("剩余时间：",data)
    self.nextStartTime = data.nextStartTime
    if self.leftSec > 0 then
        --self.gowarBtn:GetChild("red").visible = true
        --self.activeStart =1--活动开始
        self.timeTxt.visible =false
        self.gowarBtn.visible =true
        self.timeTxt.text = language.ydact05 .. GTotimeString(self.leftSec)
    else
        --self.gowarBtn:GetChild("red").visible = false
        --self.activeStart =0
        self.timeTxt.visible =true
        self.gowarBtn.visible =false
        local netTime = mgr.NetMgr:getServerTime()
        self.timeTxt.text = language.ydact015 .. GTotimeString(self.nextStartTime-netTime)
    end
end

function Bx1005:initView()
    self.gowarBtn = self.view:GetChild("n6")
    self.gowarBtn.onClick:Add(self.onClickGoWar,self)
    self.gowarBtn:GetChild("red").visible = true
    local dec = self.view:GetChild("n4")
    dec.text=mgr.TextMgr:getTextByTable(language.bxHlxz01)
    self.timeTxt =self.view:GetChild("n7")
    --self.timeTxt.visible =false
    --self.gowarBtn.visible =true
    --self.isInWar = false--是否进入了雪地作战
    
    -- local awardYl = self.view:GetChild("n1")
    -- awardYl.onClick:Add(self.onClickAwardYl,self)
end

function Bx1005:onClickGoWar()
    -- local netTime = mgr.NetMgr:getServerTime()
    -- local leftTime = self.nextStartTime-netTime>0 and self.nextStartTime-netTime or 0
    if self.leftSec and self.leftSec > 0 then
        mgr.FubenMgr:gotoFubenWar(XdzzScene)
    else
        GComAlter(language.acthall03)
    end
end

return Bx1005