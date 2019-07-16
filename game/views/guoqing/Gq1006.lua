--
-- Author: Your Name
-- Date: 2018-09-18 14:38:56
--答题助兴
local Gq1006 = class("Gq1006",import("game.base.Ref"))

function Gq1006:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Gq1006:onTimer()
    -- body
    if not self.data then return end
    if self.leftSec > 0 then
        self.timeTxt.text = language.ydact05 .. GTotimeString(self.leftSec)
        self.leftSec = self.leftSec - 1
    else
        local netTime = mgr.NetMgr:getServerTime()
        self.timeTxt.text = language.ydact015 .. GTotimeString(self.nextOpenTime-netTime)
    end
end

-- 变量名：leftSec 说明：活动剩余时间
-- 变量名：nextOpenTime    说明：下次开启时间
-- 变量名：actStartTime    说明：活动开始时间
-- 变量名：actEndTime  说明：活动结束时间
function Gq1006:addMsgCallBack(data)
    -- body
    printt("答题助兴",data)
    self.data = data
    self.leftSec = data.leftSec
    self.nextOpenTime = data.nextOpenTime
    if self.leftSec > 0 then
        self.gowarBtn:GetChild("red").visible = true
        self.timeTxt.text = language.ydact05 .. GTotimeString(self.leftSec)
    else
        self.gowarBtn:GetChild("red").visible = false
        local netTime = mgr.NetMgr:getServerTime()
        self.timeTxt.text = language.ydact015 .. GTotimeString(self.nextOpenTime-netTime)
    end
end

function Gq1006:initView()
    self.gowarBtn = self.view:GetChild("n8")
    self.gowarBtn.onClick:Add(self.onClickGoWar,self)
    self.gowarBtn:GetChild("red").visible = false
    self.timeTxt = self.view:GetChild("n10")
    local dec1 = self.view:GetChild("n4")
    dec1.text = language.gq20
    local dec2 = self.view:GetChild("n5")
    dec2.text = language.gq21
    local dec3 = self.view:GetChild("n6")
    dec3.text = language.gq22
    local dec4 = self.view:GetChild("n7")
    dec4.text = language.gq23
    local awardYl = self.view:GetChild("n9")
    awardYl.onClick:Add(self.onClickAwardYl,self)
end

function Gq1006:onClickGoWar()
    if self.leftSec and self.leftSec > 0 then
        mgr.FubenMgr:gotoFubenWar(LanternScene)
    else
        GComAlter(language.acthall03)
    end
end

function Gq1006:onClickAwardYl()
    mgr.ViewMgr:openView2(ViewName.GuoQingRankAwards)
end

return Gq1006