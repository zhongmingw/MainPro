--
-- Author: 
-- Date: 2017-12-26 11:10:10
--
--收集桃符
local ActiveSjtf = class("ActiveSjtf",import("game.base.Ref"))

function ActiveSjtf:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ActiveSjtf:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1167)
    local goFubenBtn = panelObj:GetChild("n16")
    goFubenBtn.onClick:Add(self.goFuben,self)
    --时间标题
    local timeTitle = panelObj:GetChild("n7")
    timeTitle.text = language.ydact01
    --活动标题
    local decTitle = panelObj:GetChild("n8")
    decTitle.text = language.ydact02
    --活动内容
    local decTxt = panelObj:GetChild("n10")
    decTxt.text = language.activeSjtf01
    self.timeTxt = panelObj:GetChild("n9")
end

function ActiveSjtf:goFuben()
    GOpenView({id = 1049})
end

function ActiveSjtf:setData(data)
    local startTab = os.date("*t",data.actStartTime)
    local endTab = os.date("*t",data.actEndTime)
    local startTxt = self:getTime(startTab)
    local endTxt = self:getTime(endTab)
    self.timeTxt.text = startTxt .. "-" .. endTxt
end
function ActiveSjtf:getTime(timeTab)
    if not timeTab then return end
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end


return ActiveSjtf