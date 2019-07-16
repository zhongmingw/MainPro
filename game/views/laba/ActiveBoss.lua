--
-- Author: 
-- Date: 2018-01-11 16:07:46
--

local ActiveBoss = class("ActiveBoss",import("game.base.Ref"))

function ActiveBoss:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end
function ActiveBoss:initPanel()
    local panelObj = self.mParent:getPanelObj(1186)
    self.timeText = panelObj:GetChild("n9")
    local decTxt = panelObj:GetChild("n10")
    decTxt.text = language.labaBoss01
    local goBossBtn = panelObj:GetChild("n16")
    goBossBtn.onClick:Add(self.goBoss,self)
end
function ActiveBoss:goBoss()
    GOpenView({id = 1049})
end

function ActiveBoss:setData(data)
    self.data = data

    self.timeText.text = GToTimeString8(data.actStartTime).."—"..GToTimeString8(data.actEndTime)

end

return ActiveBoss