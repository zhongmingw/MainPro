--
-- Author: 
-- Date: 2018-12-10 14:37:31
--双倍副本

local ShengDan1003 = class("ShengDan1003",import("game.base.Ref"))

function ShengDan1003:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function ShengDan1003:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)

    self.nameTxt = panelObj:GetChild("n4")
    
    self.goBtn = panelObj:GetChild("n5")
    self.goBtn:GetChild("red").visible = false
    self.goBtn.onClick:Add(self.onGoFuben,self)
end

function ShengDan1003:setData(data)
    local curDay = data.curDay or 1
    local confData = conf.ShengDanConf:getDoubleFuBenInfo(curDay)
    self.nameTxt.text = confData.name
    self.goBtn.data = confData.module_id
end

function ShengDan1003:onTimer()

end

function ShengDan1003:onGoFuben(context)
    local btn = context.sender
    local data = btn.data
    GOpenView({id = data})
end


return ShengDan1003