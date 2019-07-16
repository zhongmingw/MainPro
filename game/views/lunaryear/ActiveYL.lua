--
-- Author: EVE 
-- Date: 2018-01-31 19:53:32
-- 小年登录

local ActiveYL = class("ActiveYL",import("game.base.Ref"))

function ActiveYL:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ActiveYL:initPanel()
    local panelObj = self.mParent:getPanelObj(3053)

    -- self.timeText = panelObj:GetChild("n9")
    -- local decTxt = panelObj:GetChild("n10") 
    -- decTxt.text = language.labaBoss01

    --时间和内容
    local actDuration = conf.ActivityWarConf:getSnowGlobal("act_duration")
    panelObj:GetChild("n9").text = self:getTime(actDuration[1]).."—"..self:getTime(actDuration[2])
    panelObj:GetChild("n10").text = language.lunaryear06

    local goBossBtn = panelObj:GetChild("n16")
    goBossBtn.onClick:Add(self.goBoss,self)
end

function ActiveYL:goBoss()
    GOpenView({id = 1049})
end

function ActiveYL:getTime(time)
    local timeTab = os.date("*t",time)
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

function ActiveYL:setData(data)
    self.data = data

    -- self.timeText.text = GToTimeString8(data.actStartTime).."—"..GToTimeString8(data.actEndTime)

end

return ActiveYL