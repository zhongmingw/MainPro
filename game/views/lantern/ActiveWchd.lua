--
-- Author: 
-- Date: 2018-01-30 15:57:02
--
--五彩花灯
local ActiveWchd = class("ActiveWchd",import("game.base.Ref"))

function ActiveWchd:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ActiveWchd:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1210)
    local goFubenBtn = panelObj:GetChild("n16")
    goFubenBtn.onClick:Add(self.goFuben,self)
    --时间标题
    panelObj:GetChild("n7").text = language.lantern01
    --活动标题
    panelObj:GetChild("n8").text = language.lantern02
    --活动内容
    panelObj:GetChild("n10").text = language.lantern03
    self.timeTxt = panelObj:GetChild("n9")
end

function ActiveWchd:goFuben()
    GOpenView({id = 1049})
end

function ActiveWchd:setData(data)
    local startTab = os.date("*t",data.actStartTime)
    local endTab = os.date("*t",data.actEndTime)
    local startTxt = self:getTime(startTab)
    local endTxt = self:getTime(endTab)
    self.timeTxt.text = startTxt .. "—" .. endTxt
end

function ActiveWchd:getTime(timeTab)
    if not timeTab then return end
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end


return ActiveWchd