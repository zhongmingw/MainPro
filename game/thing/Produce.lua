--[[--
  采集物
]]

local Produce = class("Produce")

function Produce:ctor()
end

function Produce:setData(data)
    self.produce = mgr.EffectMgr:playCommonEffect(data["body_id"], UnitySceneMgr.pStateTransform)
    local rotate = StaticVector3.vector3X60 + StaticVector3.vector3Z180
    self.produce.LocalRotation = rotate
    self.produce.Scale = StaticVector3.scaleXYZ80
    self.position = Vector3.New(data.pos[1],-1500,data.pos[2])
    self.produce.LocalPosition = self.position
end

function Produce:getPosition()
    return self.position or Vector3.zero
end

function Produce:dispose()
    mgr.EffectMgr:removeEffect(self.produce)
end

return Produce