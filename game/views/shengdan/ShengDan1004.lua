--
-- Author: 
-- Date: 2018-12-10 14:37:31
--激战boss

local ShengDan1004 = class("ShengDan1004",import("game.base.Ref"))

function ShengDan1004:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function ShengDan1004:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)
    
    panelObj:GetChild("n1").text = language.shengdan02

    
    local goBtn = panelObj:GetChild("n4")
    goBtn:GetChild("red").visible = false

    goBtn.onClick:Add(self.onGoFuben,self)
end

function ShengDan1004:setData(data)

end

function ShengDan1004:onTimer()

end

function ShengDan1004:onGoFuben()
    GOpenView({id = 1049})
end


return ShengDan1004