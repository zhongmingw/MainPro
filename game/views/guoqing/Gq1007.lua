--
-- Author: Your Name
-- Date: 2018-09-18 14:38:56
--疯弹作战
local Gq1007 = class("Gq1007",import("game.base.Ref"))

function Gq1007:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Gq1007:onTimer()
    -- body
    if not self.data then return end
    if self.leftSec > 0 then
        self.timeTxt.text = language.ydact05 .. GTotimeString(self.leftSec)
        self.leftSec = self.leftSec - 1
    else
        local netTime = mgr.NetMgr:getServerTime()
        self.timeTxt.text = language.ydact015 .. GTotimeString(self.nextStartTime-netTime)
    end
end

-- 变量名：leftSec 说明：活动剩余时间
-- 变量名：nextStartTime   说明：下次开启时间
function Gq1007:addMsgCallBack(data)
    -- body
    printt("疯弹作战",data)
    self.data = data
    self.leftSec = data.leftSec
    self.nextStartTime = data.nextStartTime
    if self.leftSec > 0 then
        self.gowarBtn:GetChild("red").visible = true
        self.timeTxt.text = language.ydact05 .. GTotimeString(self.leftSec)
    else
        self.gowarBtn:GetChild("red").visible = false
        local netTime = mgr.NetMgr:getServerTime()
        self.timeTxt.text = language.ydact015 .. GTotimeString(self.nextStartTime-netTime)
    end
end

function Gq1007:initView()
    self.gowarBtn = self.view:GetChild("n5")
    self.gowarBtn.onClick:Add(self.onClickGoWar,self)
    self.gowarBtn:GetChild("red").visible = false
    self.timeTxt = self.view:GetChild("n10")
    local dec1 = self.view:GetChild("n6")
    dec1.text = language.gq24
    local dec2 = self.view:GetChild("n7")
    dec2.text = language.gq25
    local dec3 = self.view:GetChild("n8")
    dec3.text = language.gq26
    local dec4 = self.view:GetChild("n9")
    dec4.text = language.gq27
    
    -- local awardYl = self.view:GetChild("n1")
    -- awardYl.onClick:Add(self.onClickAwardYl,self)
end

function Gq1007:onClickGoWar()
    if self.leftSec and self.leftSec > 0 then
        mgr.FubenMgr:gotoFubenWar(XdzzScene)
    else
        GComAlter(language.acthall03)
    end
end

-- function Gq1007:onClickAwardYl()
    
-- end

return Gq1007