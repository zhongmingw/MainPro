--[[

]]

local ThingAI = class("ThingAI")

local FIX_POSITION = {Vector2.New(2359,1395), Vector2.New(2759,1395), Vector2.New(2759,1695)}
local SKILL = {511001,512001,512002}
function ThingAI:ctor(thing)
    self.thing = thing
    self.timer = 0
    self.moveIndex = 1
end

function ThingAI:update()
    if not self.thing or not self.thing.mBody.isLoaded then return end
    if self.thing.CurStateID == 0 then --如果是待机
        self.timer = self.timer + 1
        print("****************", self.timer)
        if self.timer > 20 then
            local arr = ArrayList.New()
            arr:Add(FIX_POSITION[self.moveIndex])
            self.thing:MoveToPath(arr, nil)
            self.moveIndex = (self.moveIndex)%3 + 1
            self.timer = 0
        else
            local msg = {skillId = SKILL[self.moveIndex]}
            mgr.FightMgr:otherBattle(msg, self.thing)
        end
    end
end

return ThingAI