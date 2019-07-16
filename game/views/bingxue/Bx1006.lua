--
-- Author: 
-- Date: 2019-01-08 11:21:30
--

local Bx1006 = class("Bx1006",import("game.base.Ref"))

function Bx1006:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Bx1006:onTimer()
    -- body
    if not self.data then return end
    -- if self.leftSec > 0 then
    --     self.timeTxt.text = language.ydact05 .. GTotimeString(self.leftSec)
    --     self.leftSec = self.leftSec - 1
    -- else
    --     local netTime = mgr.NetMgr:getServerTime()
    --     self.timeTxt.text = language.ydact015 .. GTotimeString(self.nextStartTime-netTime)
    -- end
end

-- 变量名：leftSec 说明：活动剩余时间
-- 变量名：nextStartTime   说明：下次开启时间
function Bx1006:addMsgCallBack(data)
    -- body
    self.data = data
    --self.leftSec = data.leftTime
    -- if self.leftSec > 0 then
    --     self.gowarBtn:GetChild("red").visible = true
    --     --self.timeTxt.text = language.ydact05 .. GTotimeString(self.leftSec)
    -- else
    --     self.gowarBtn:GetChild("red").visible = false
    --     --local netTime = mgr.NetMgr:getServerTime()
    --     --self.timeTxt.text = language.ydact015 .. GTotimeString(self.nextStartTime-netTime)
    -- end
end

function Bx1006:initView()
    self.gowarBtn = self.view:GetChild("n4")
    self.gowarBtn.onClick:Add(self.onClickGoWar,self)
    self.gowarBtn:GetChild("red").visible = false
    local dec = self.view:GetChild("n3")
    dec.text=mgr.TextMgr:getTextByTable(language.bxJzboss01)
    
    -- local awardYl = self.view:GetChild("n1")
    -- awardYl.onClick:Add(self.onClickAwardYl,self)
end

function Bx1006:onClickGoWar()
    GOpenView({id = 1049})
end

return Bx1006