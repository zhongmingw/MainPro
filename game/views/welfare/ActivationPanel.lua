--
-- Author: ohf
-- Date: 2017-03-27 12:04:45
--
--激活码
local ActivationPanel = class("ActivationPanel",import("game.base.Ref"))

function ActivationPanel:ctor(mParent,panelObj)
    self.mParent = mParent
    self.panelObj = panelObj
    self:initPanel()
end

function ActivationPanel:initPanel()
    self.inputText = self.panelObj:GetChild("n5")
    self.panelObj:GetChild("n8").text = language.welfare33
    local btn = self.panelObj:GetChild("n6")
    btn.onClick:Add(self.onClickGet,self)
end

function ActivationPanel:sendMsg()
    plog("ActivationPanel")
end

function ActivationPanel:setData(data)
    GOpenAlert3(data.items)
    self.inputText.text = ""
end

function ActivationPanel:setVisible(visible)
    self.panelObj.visible = visible
end

function ActivationPanel:onClickGet()
    local testMl = "@@#"
    if string.trim(self.inputText.text) == testMl then
        local view = mgr.ViewMgr:get(ViewName.DebugView)
        if view then
            view:closeView()
        else
            mgr.ViewMgr:openView(ViewName.DebugView)    
        end
        self.inputText.text = ""
        return
    end
    proxy.ActivityProxy:send(1030101,{giftCode = self.inputText.text})
end

return ActivationPanel