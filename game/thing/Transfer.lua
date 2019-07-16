--[[--
  传送阵
]]

local Transfer = class("Transfer")

function Transfer:ctor()
    self.nextInfo = nil
    self.id = nil
    self.using = false
    self.markTime = 0
end

function Transfer:setData(data)
    self.data = data
    self.id = data.id
    self.position = Vector3.New(data.pos[1],-1500,data.pos[2])
    self.type = data["type"]
    if data["body_id"] then
        self.transfer = mgr.EffectMgr:playCommonEffect(data["body_id"], UnitySceneMgr.pStateTransform)
        local rotate = StaticVector3.vector3X60 + StaticVector3.vector3Z180
        self.transfer.LocalRotation = rotate
        self.transfer.Scale = StaticVector3.scaleXYZ80
        self.transfer.LocalPosition = self.position
    end
    if self.type == 4 then
        self.nextInfo = data["jump_pos"]
    else
        self.nextInfo = data["to_pos"]
    end
end

function Transfer:getPosition()
    return self.position or Vector3.zero
end

function Transfer:dispose()
    if self.transfer then
        mgr.EffectMgr:removeEffect(self.transfer)
    end
    self.transfer = nil
end

return Transfer