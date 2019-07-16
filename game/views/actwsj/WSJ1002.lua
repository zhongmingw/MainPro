--
-- Author: 
-- Date: 2018-10-22 14:47:32
--

local WSJ1002 = class("WSJ1002",import("game.base.Ref"))

function WSJ1002:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function WSJ1002:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)
    panelObj:GetChild("n2").text = language.wsj02

    self.timeTxt = panelObj:GetChild("n4")
    
    local goBtn = panelObj:GetChild("n3")
    goBtn:GetChild("red").visible = false

    goBtn.onClick:Add(self.onGoFuben,self)
end

function WSJ1002:setData(data)
    self.data = data
    -- printt("data",data)
    self.leftTime = data.leftTime
    self.timeTxt.text = language.kaifu15 .. GGetTimeData2(self.leftTime)
end

function WSJ1002:onTimer()
    if not self.data then return end
    if self.leftTime then
        self.leftTime = self.leftTime - 1
        self.timeTxt.text = language.kaifu15 .. GGetTimeData2(self.leftTime)
        if self.leftTime <= 0 then
            self.mParent:closeView()
        end
    end
end

function WSJ1002:onGoFuben()
    GOpenView({id = 1049})
end


return WSJ1002