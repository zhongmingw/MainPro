--
-- Author: Your Name
-- Date: 2018-09-18 14:32:34
--
local Dz1002 = class("Dz1002",import("game.base.Ref"))

function Dz1002:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Dz1002:onTimer()
    -- body
    if not self.data then return end

end


function Dz1002:addMsgCallBack(data)
    -- body
    printt("",data)


end

function Dz1002:onClickGet(context)

    self.parent:closeView()
    GOpenView({id = 1049})
end

function Dz1002:initView()
    
   
    local Btn = self.view:GetChild("n4")
    Btn.onClick:Add(self.onClickGet,self)

    local Text = self.view:GetChild("n3")
    Text.text = language.dz04

end


return Dz1002