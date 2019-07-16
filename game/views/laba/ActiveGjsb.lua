--
-- Author: 
-- Date: 2018-01-10 14:47:55
-- 挂机双倍

local ActiveGjsb = class("ActiveGjsb",import("game.base.Ref"))

function ActiveGjsb:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end
function ActiveGjsb:initPanel()
    local panelObj = self.mParent:getPanelObj(1184)

    local decTxt = panelObj:GetChild("n10")
    decTxt.text = language.labaGjsb01
    self.timeText = panelObj:GetChild("n9")
    local goHookBtn = panelObj:GetChild("n16")
    goHookBtn.onClick:Add(self.goHook,self)
end

function ActiveGjsb:goHook()
    GOpenView({id = 1189})
end

function ActiveGjsb:setData(data)
    self.data = data

    self.timeText.text = GToTimeString8(data.actStartTime).."—"..GToTimeString8(data.actEndTime)

end

return ActiveGjsb