--
-- Author: yr
-- Date: 2017-04-21 14:23:44
--

local Ref = class("Ref")

function Ref:ctor()
    
end

function Ref:removeAllEvent()
    local mapping = self.EventDelegates or {}
    for k, v in pairs(mapping) do
        local listener = v["listener"]
        listener:Remove(k, self)
    end
    self.EventDelegates = {}
end

function Ref:clearFairygui()
    for k, v in pairs(self) do
        self[k] = nil
    end
end


return Ref