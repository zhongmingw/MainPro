--
-- Author: yr
-- Date: 2017-07-19 12:14:30
-- 野外挂机，寻找最近的怪物挂机

local FieldHook = class("FieldHook", import(".BaseHook"))

function FieldHook:ctor()
    
end

function FieldHook:enter()
    self.super.enter(self)
    local sId = cache.PlayerCache:getSId()
    local sConf = conf.SceneConf:getSceneById(sId)
    local ms = sConf["monsters"]
    if not ms then
        return
    end
    local minDis = 10000000
    local mNear
    for i=1,#ms do
        local mc = conf.MonsterConf:getInfoById(ms[i][2])
        local mPos = Vector3.New(0, gRolePoz, 0)
        if mc["pos"] then
            mPos.x = mc["pos"][1]
            mPos.z = mc["pos"][2]
            local dis = GMath.distance(gRole:getPosition(), mPos)
            if dis < minDis then
                minDis = dis
                mNear = mPos
            end
        else
            plog("@策划：怪物配置的pos字段没有配")
        end
    end
    if mNear then
        self:setHookPoint(mNear)
    end
    self:update()
end

function FieldHook:checkCanAttack()
    return true
end



return FieldHook