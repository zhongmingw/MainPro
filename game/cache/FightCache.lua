local FightCache = class("FightCache",base.BaseCache)

function FightCache:init()
    self.mSkillPool = {}
    self.mSkillList = {}
    self.mCount = 1
    mgr.TimerMgr:addTimer(1, -1, function()
        self:removeUnUsedSkill()
    end, "skillCache")
end

function FightCache:createSkillInfo(sId)
    local p = self.mSkillPool[tostring(sId)]
    local s
    if p and #p > 0 then
        s = table.remove(p, 1)
        s.mTotalTime = os.time()
    else
        s = fight.SkillInfo.new()
        s:setKey(tostring(self.mCount))
        self.mCount = self.mCount + 1
        -- print("创建技能数据>>>>>>", sId)
    end
    self.mSkillList[s.mKey] = s
    return s
end

function FightCache:removeToPool(sObj)
    local k = sObj.mKey
    self.mSkillList[k] = nil
    sObj:reset()
    local p = self.mSkillPool[tostring(sObj.mSkillId)]
    if not p then
        self.mSkillPool[tostring(sObj.mSkillId)] = {}
    end
    table.insert(self.mSkillPool[tostring(sObj.mSkillId)], sObj)
end

function FightCache:removeUnUsedSkill()
    local maxLoop = 0
    for k, v in pairs(self.mSkillList) do
        maxLoop = maxLoop + 1
        if maxLoop > 50 then
            return
        end
        local valid = v:getValid()
        if valid == false or (os.time() - v.mTotalTime > 6) then
            self:removeToPool(v) 
        end
    end
end

function FightCache:getSkillInfo(key)
    local skill = self.mSkillList[key]
    --self.mSkillList[key] = nil
    return skill
end

function FightCache:dumpInfo()
    local count = table.nums(self.mSkillList)
    local count2 = table.nums(self.mSkillPool)

    print("技能缓存信息>>","无效技能：",count, "池中技能：", count2)
end

return FightCache