--
-- Author: 
-- Date: 2018-12-18 14:19:42
--元旦boss

local YuanDan1003 = class("YuanDan1003",import("game.base.Ref"))

function YuanDan1003:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function YuanDan1003:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)

    panelObj:GetChild("n2").text = language.yuandan05
    
    local goBtn = panelObj:GetChild("n4")
    goBtn:GetChild("red").visible = false

    goBtn.onClick:Add(self.onGoFuben,self)
end

function YuanDan1003:setData(data)

end

function YuanDan1003:onTimer()

end

function YuanDan1003:onGoFuben()
    GOpenView({id = 1049})
end




return YuanDan1003