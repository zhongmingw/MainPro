--[[--
战斗数据
]]

local SkillInfo = class("SkillInfo")

function SkillInfo:ctor()
    self.mBaseInfo = USkillInfo.New()
    self.mKey = ""
    self.mSkillId = 0
    self.mAttack = nil  --进攻者
    self.mHitTars = {}  --受击目标
    self.mCoolTime = 0  --冷却时间
    self.mAction = 0  --技能对目标的作用
    self.mStartEId = ""  --技能触发效果
    self.mHitEId= ""  --技能伤害效果
    self.mDir = nil
    self.mAreaType = 0 --作用目标选择规则
    self.mHitMonsters = {}  --攻击对象怪物
    self.mHitPlayers = {}  --攻击对象人物
    self.mAttackTag = 0
    self.dongzuo = nil
    self.mAttackCount = nil
    self.mHitId = nil
    self.mLockType = 0
    self.mTotalTime = os.time()
end

function SkillInfo:getCSharp()
    return self.mBaseInfo
end
function SkillInfo:setKey(key)
    self.mKey = key
    self.mBaseInfo.key = key
end
function SkillInfo:getValid()
    if g_var.gameFrameworkVersion < 12 then
        return true
    end
    return self.mBaseInfo.valid
end
--设置技能id
function SkillInfo:setSId(id)
    self.mSkillId = id
    self.mBaseInfo.skillId = id
end
--设置动作
function SkillInfo:setActionName(name)
    self.dongzuo = name
    if name then
        self.mBaseInfo.animaName = name
    end
end
--设置特效id
function SkillInfo:setStartEId(id)
    self.mStartEId = tostring(id)
end
--动作触发点
function SkillInfo:setActionSpot(spot)
    if spot and #spot>0 then
        local aSpot = ArrayList.New()
        for j=1, #actionSpot do
            aSpot:Add(actionSpot[j])
        end
        self.mBaseInfo.actionSpot = aSpot
    end
end
--设置攻击者
function SkillInfo:setAttack(t)
    self.mAttack = t
    self.mBaseInfo.mAttackTar = t.character
end
--添加受击对象
function SkillInfo:addTars(tarId, t)
    if tarId == self.mLockTar then  --如果是第一个不用添加了。
        -- print("锁定目标：", tarId)
        return
    end
    if t == ThingType.monster then
        table.insert(self.mHitMonsters, tarId)
    elseif t == ThingType.player then
        table.insert(self.mHitPlayers, tarId)
    end
end
--设置主角主攻目标
function SkillInfo:addSelectTar(t, tarId)
    if t == ThingType.monster then
        table.insert(self.mHitMonsters, tarId)
        self.mLockType = 2
    elseif t == ThingType.player then
        table.insert(self.mHitPlayers, tarId)
        self.mLockType = 1
    end
    self.mLockTar = tarId
end

--受击特效
function SkillInfo:setHitEId(id)
    self.mHitEId = id
end
--技能方向
function SkillInfo:setSkillDir(vec)
    if vec then
        self.mDir = vec
        self.mBaseInfo.fightDir = self.mDir
    else
        self.mDir = nil
        self.mBaseInfo.fightDir = Vector3.zero
    end
end
--设置技能攻击目标
function SkillInfo:setHitTar(tar)
    if tar then
        self.mHitId = tar:getID()
        self.mDir = tar:getPosition()
        self.mBaseInfo.fightDir = self.mDir
    else
        self.mHitId = 0
        self.mDir = nil
        self.mBaseInfo.fightDir = Vector3.zero
    end
end
--重置技能数据
function SkillInfo:reset()
    self.mHitId = 0
    self.mAttack = nil
    if g_var.gameFrameworkVersion >= 12 then
        self.mBaseInfo.valid = true
    end
    self.mBaseInfo.mAttackTar = nil
    self.mHitTars = {}
    self.mAction = 0
    self.mLockTar = 0
    self.mLockType = 0
    self.mHitMonsters = {}
    self.mHitPlayers = {}
end

return SkillInfo