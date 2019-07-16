--
-- Author: EVE
-- Date: 2017-08-03 21:05:41
--

local TipsView = class("TipsView", base.BaseView)

function TipsView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function TipsView:initView()
    self.btnClose = self.view:GetChild("n4"):GetChild("n2")
    self.btnClose.onClick:Add(self.onCloseView,self)

    self.text = self.view:GetChild("n3")
    self.text.text = nil
    self:setText()
end

function TipsView:setText()
    local numText = #language.friend50
    local str = ""
    for i=1,numText do
        str = str .. language.friend50[i]
        if i < numText then 
          str = str .. "\n"  
        end  
    end
    self.text.text = str
end

function TipsView:onCloseView()
    self:closeView()
end

return TipsView