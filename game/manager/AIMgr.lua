local AIMgr = class("AIMgr")
local ThingAI = require("game.thing.ai.ThingAI")

function AIMgr:ctor()
    self.ai = {}
end

function AIMgr:addAI(thing)
    local ai = ThingAI.new(thing)
    table.insert(self.ai, ai)
end

function AIMgr:update()
    for i=1, #self.ai do
      self.ai[i]:update()
    end
end



return AIMgr