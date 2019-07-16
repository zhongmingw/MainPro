--
-- Author: 
-- Date: 2018-01-17 21:58:44
--
-- 挂机双倍
local WeekGjsb = class("WeekGjsb",import("game.base.Ref"))

function WeekGjsb:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end
function WeekGjsb:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1193)

    local decTxt = panelObj:GetChild("n10")
    decTxt.text = language.weekend07
    self.timeText = panelObj:GetChild("n9")
    local goHookBtn = panelObj:GetChild("n16")
    goHookBtn.onClick:Add(self.goHook,self)
end

function WeekGjsb:goHook()
    GOpenView({id = 1189})
end

function WeekGjsb:setData(data)
    self.data = data
    
    self.timeText.text = GToTimeString8(data.actStartTime).."—"..GToTimeString8(data.actEndTime)

end

return WeekGjsb