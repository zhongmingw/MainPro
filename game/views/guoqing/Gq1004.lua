--
-- Author: Your Name
-- Date: 2018-09-18 14:38:56
--激战BOSS
local Gq1004 = class("Gq1004",import("game.base.Ref"))

function Gq1004:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Gq1004:onTimer()
    -- body
    if not self.data then return end
    if self.leftTime then
        self.leftTime = self.leftTime - 1
        self.timeTxt.text = language.kaifu15 .. GGetTimeData2(self.leftTime)
    end
end

    
-- 变量名：leftTime    说明：活动剩余时间
function Gq1004:addMsgCallBack(data)
    -- body
    printt("激战BOSS",data)
    self.data = data
    self.leftTime = data.leftTime
    self.timeTxt.text = language.kaifu15 .. GGetTimeData2(self.leftTime)
end

function Gq1004:initView()
    -- body
    local gowarBtn = self.view:GetChild("n4")
    gowarBtn:GetChild("red").visible = false
    gowarBtn.onClick:Add(self.onClickGoWar,self)

    self.timeTxt = self.view:GetChild("n5")

    local decTxt = self.view:GetChild("n3")
    decTxt.text = mgr.TextMgr:getTextByTable(language.gq11)
end

function Gq1004:onClickGoWar()
    GOpenView({id = 1049})
end

return Gq1004