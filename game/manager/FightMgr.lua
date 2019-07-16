--[[--
战斗管理
]]

local FightMgr = class("FightMgr")

local BASE_ATTACK = 1           --普通攻击
local SKILL_ATTACK = 2          --技能攻击
local MOVE_REACHED = 1          --移动到目标点了
local ATTACK_MAX_DIS = 1500     --攻击最远识别距离
local FLASH_MAX_DIS = 300       --闪现的最大距离
local AttackByRole = 1
local AttackByPlayer = 2
local AttackByRolePet = 3
local AttackByYW = 4
local AttackByPet = 5
local AttackByNetPet = 6
local AttackByXiantongPet = 7
function FightMgr:ctor()
    --注册回调--------------------------------
    UFightControl:RegisterFun(function(skillInfo)
        self:onTriggerCallBack(skillInfo)
    end)
    --瞬移动作
    self.flashCount = 1
    self.staticVec1 = Vector3.New(0,0,0)

    self.tarInfo = {tType = 0, tId=0}
    self.fightLog = false  --输出战斗流程log

    self.lockSwitch = false
end

function FightMgr:clear()
    self:changeBattleTarget(true, 0, 0)
end

--主角战斗
function FightMgr:roleBattle(skillId, t, id)
    --技能配置
    local skillConf = conf.FightConf:getSkillById(skillId)
    local attackEffect = skillConf["attack_effect"]
    local range = skillConf["range"]
    local t = skillConf["type"]
    if t == 3 then  --type=3表示不用攻击对象的技能
        self:rolePrepareBattle(skillId, nil)
        return      
    end
    local sId = cache.PlayerCache:getSId() or 0
    local sConf = conf.SceneConf:getSceneById(sId)
    self.lockSwitch = true
    if sConf then
        if sConf["attack_lock"] then
            self.lockSwitch = false
        end
    end
    if self:checkExit() then
        if self.lockSwitch == true then
            local target = mgr.ThingMgr:getObj(self.tarInfo.tType, self.tarInfo.tId)
            if not target or target:isDeadState() then
                self:changeBattleTarget(true, 0, 0)
            else
                if not target.isSelected then
                    mgr.ThingMgr:addSelectEct(self.tarInfo.tType, self.tarInfo.tId)
                end
                local a = gRole:getPosition()
                local b = target:getPosition()
                local c = GMath.distance(a, b)
                if c > 600 then
                    self:changeBattleTarget(true, 0, 0)
                end
            end
        else
            self:changeBattleTarget(true, 0, 0)
        end 
    end
    if not self:checkExit() then
        local lt = nil
        if t and id then
            lt = mgr.ThingMgr:getObj(t, id)
        end

        if lt then
            self:changeBattleTarget(true, t, id)
        else
            local _, info = mgr.ThingMgr:getNearTar()
            if info then
                self:changeBattleTarget(true, info.type, info.objId)
            end
        end
    end
    if self:checkExit() then
        self:roleGotoTar(skillId, self.tarInfo.tType, self.tarInfo.tId, range, true)
    else
        if t == 4 then  -- type=4需要有目标才可以释放的技能
            GComAlter(language.meiyougongjimubiao)
        else
            self:rolePrepareBattle(skillId, nil)
        end
    end

    if self.fightLog then
        print("释放技能>>>>>>",skillId,t,id,self.tarInfo.tType,self.tarInfo.tId)
    end
    -- if t and id then  --锁定目标攻击
    --     self:roleGotoTar(skillId, t, id, range, true)
    --     return
    -- else
    --     --检测周围是否有目标
    --     local target, info = mgr.ThingMgr:getNearTar()
    --     if info then
    --         --攻击距离处理
    --         if range then
    --             self:roleGotoTar(skillId, info.type, info.objId, range, false)
    --             return
    --         end
    --     end
    -- end
    -- self:rolePrepareBattle(skillId, target)
end

function FightMgr:checkExit()
    if self.tarInfo.tId ~= "0" then
        return true
    end
    return false
end

-- 切换攻击目标
-- auto 自动选择目标
function FightMgr:changeBattleTarget(auto, t, id)
    self.tarInfo.tId = tostring(id)
    self.tarInfo.tType = tonumber(t)
    mgr.ThingMgr:addSelectEct(t, id)
    if self.fightLog then
        print("切换攻击目标:", t, id)
        print(debug.traceback())
    end
end

--角色移动/冲锋到攻击目标
function FightMgr:roleGotoTar(skillId, t, id, range, lock)
    --验证目标是否存在
    local target = mgr.ThingMgr:getObj(t, id)
    if not target then
        if self.fightLog then
            print("@目标不存在，停止本次攻击")
        end
        return
    end
    local a = gRole:getPosition()
    local b = target:getPosition()
    local disToTar = GMath.distance(a, b)
    if lock then
        gRole:moveToPoint(b, 280, function()
            self:roleGotoTar(skillId, t, id, range)
        end)
    elseif disToTar > ATTACK_MAX_DIS or gRole:isDingShen() then
        self:rolePrepareBattle(skillId, nil)
    elseif disToTar > FLASH_MAX_DIS then
        gRole:moveToPoint(b, 280, function()
            self:roleGotoTar(skillId, t, id, range)
        end)
    elseif disToTar > range then  
        local state = gRole:flashToPoint(b,100,0.3,"jump2",function()
            self:rolePrepareBattle(skillId, target)
        end)
        if state == false then
            gRole:moveToPoint(b, 100, function()
                self:roleGotoTar(skillId, t, id, range)
            end)
        end
        self.flashCount = self.flashCount % 3 + 1
    elseif disToTar <= range then
        self:rolePrepareBattle(skillId, target)
    end
end
--创建技能id
function FightMgr:createSkillInfo(skillId,attackTar, hitTar)
    local skillConf = conf.FightConf:getSkillById(skillId)
    if not skillConf then
        plog("技能ID不存在："..skillId)
        return
    end
    local attackEffect = skillConf["attack_effect"]
    --技能数据对象
    local skillInfo = cache.FightCache:createSkillInfo(skillId)
    skillInfo:setSId(skillId)
    skillInfo:setActionName(skillConf["action"])
    if attackEffect then
        skillInfo:setStartEId(attackEffect[1])
    else
        --plog("技能特效不存在："..skillId)
    end
    skillInfo:setHitEId(skillConf["smitten_effect"])
    --技能动作的触发点
    skillInfo:setActionSpot(skillConf["action_spot"])
    skillInfo.mAreaType = skillConf["area_type"]
    if hitTar then
        skillInfo:setHitTar(hitTar)
    else
        skillInfo:setHitTar(nil)
    end
    if skillConf["atk_num"] then
        skillInfo.mAttackCount = skillConf["atk_num"]
    end
    
    skillInfo:setAttack(attackTar)
    return skillInfo
end

--攻击范围内角色准备动手了
function FightMgr:rolePrepareBattle(skillId, target)
    local skillInfo = self:createSkillInfo(skillId, gRole, target)
    skillInfo.mAttackTag = AttackByRole
    --开始战斗伙计
    self:doBattle(skillInfo)
end

--其他事物发起攻击
function FightMgr:otherBattle(data)
    local function startOtherBattle(data, t)
        local skillInfo = self:createSkillInfo(data.skillId, t)
        if not skillInfo then return end
        --设置攻击方向
        if (data.tarPox == 0 and data.tarPoy == 0) or t.fixDir then
            skillInfo:setSkillDir()
        else
            skillInfo:setSkillDir(Vector3.New(data.tarPox, -1500, data.tarPoy))
        end
        
        skillInfo.mAttackTag = AttackByPlayer
        if data.uTargets and #data.uTargets > 0 then  --添加攻击对象
            local len = #data.uTargets
            for i = 1, len do
                skillInfo:addTars(data.uTargets[i].roleId, ThingType.player)
            end
        end
        if data.mTargets and #data.mTargets > 0 then  --添加攻击到的怪物
            local len = #data.mTargets
            for i=1,len do
                skillInfo:addTars(data.mTargets[i].roleId, ThingType.monster)
            end
        end
        --开始战斗伙计
        local at
        if data.opt == 1 then
            at = mgr.ThingMgr:getObj(ThingType.player, data.atkId)
        elseif data.opt == 2 then
            at = mgr.ThingMgr:getObj(ThingType.monster, data.atkId)
        elseif data.opt == 3 or data.opt == 6 then
            skillInfo.mAttackTag = AttackByPet
            at = mgr.ThingMgr:getObj(ThingType.pet, data.atkId)
        elseif data.opt == 7 then
            local player = mgr.ThingMgr:getObj(ThingType.player, data.atkId)
            if player then
                at = mgr.ThingMgr:getObj(ThingType.pet, player:getXianTonID())
            end
            skillInfo.mAttackTag = AttackByXiantongPet
            
        elseif data.opt == 4 then--剧情npc
            at = mgr.ThingMgr:getObj(ThingType.player, data.atkId)
        end
        if at == nil then return end
        self:doBattle(skillInfo)
    end
    local attackTar
    if data.opt == 1 then  --角色攻击
        attackTar = mgr.ThingMgr:getObj(ThingType.player, data.atkId)
        if attackTar == nil then return end
        local attackPos = attackTar:getPosition()
        local needFlash = false
        if attackPos.x ~= data.atkPox or attackPos.z ~= data.atkPoy then  --如果攻击点不等于攻击者的坐标则需要冲锋
            self.staticVec1:Set(data.atkPox, -1500, data.atkPoy)
            needFlash = attackTar:flashToPoint(self.staticVec1,0,0.2,"flash1",function()
                startOtherBattle(data, attackTar)
            end)
        end
        if needFlash == false then
            startOtherBattle(data, attackTar)
        end
        --同步攻击者的PK状态
        if attackTar.pkState ~= data.atkPkState then
            print("@攻击者PK状态不一致需要同步")
            attackTar:updatePKState(data.atkPkState)
        end
    elseif data.opt == 2 then  --怪物攻击
        attackTar = mgr.ThingMgr:getObj(ThingType.monster, data.atkId)
        if attackTar == nil then return end
        self.staticVec1:Set(data.atkPox, -1500, data.atkPoy)
        attackTar:flashToPoint(self.staticVec1,0,0.2,"walk",function()
            startOtherBattle(data, attackTar)
        end)
    elseif data.opt == 3 or data.opt == 6 or data.opt == 7 then  --宠物攻击
        if data.opt == 3  then
            attackTar = mgr.ThingMgr:getObj(ThingType.pet, data.atkId)
        elseif data.opt == 6 or data.opt == 7 then
            local player = mgr.ThingMgr:getObj(ThingType.player, data.atkId)
            --print("player",player)
            if player then
                if data.opt == 6 then
                    attackTar = mgr.ThingMgr:getObj(ThingType.pet, player:getPetID())
                else
                    attackTar = mgr.ThingMgr:getObj(ThingType.pet, player:getXianTonID())
                end
            end
        end
        --print("attackTar",attackTar,data.opt)
        if attackTar == nil then return end
        startOtherBattle(data, attackTar)
    elseif data.opt == 4 then--剧情npc攻击（参照角色攻击）
        attackTar = mgr.ThingMgr:getObj(ThingType.player, data.atkId)
        if attackTar == nil then return end
        local attackPos = attackTar:getPosition()
        local needFlash = false
        if attackPos.x ~= data.atkPox or attackPos.z ~= data.atkPoy then  --如果攻击点不等于攻击者的坐标则需要冲锋
            self.staticVec1:Set(data.atkPox, -1500, data.atkPoy)
            needFlash = attackTar:flashToPoint(self.staticVec1,0,0.2,"flash1",function()
                startOtherBattle(data, attackTar)
            end)
        end
        if needFlash == false then
            startOtherBattle(data, attackTar)
        end
    end
end

--宠物攻击
function FightMgr:petBattle(skillId)
    local rPet = mgr.ThingMgr:getObj(ThingType.pet, gRole:getID())
    if rPet then
        local skillInfo = self:createSkillInfo(skillId, rPet)
        skillInfo.mAttackTag = AttackByRolePet
        skillInfo.mLockType = self.lockType
        skillInfo.mHitMonsters = self.curHitMonsters
        skillInfo.mHitPlayers = self.curHitPlayers
        skillInfo:setSkillDir(self.curHitDir)
        self:doBattle(skillInfo)
    end
end

function FightMgr:newPetBattle(skillId)
    local rPet = mgr.ThingMgr:getObj(ThingType.pet, gRole:getPetID())
    if rPet then
        local skillInfo = self:createSkillInfo(skillId, rPet)
        skillInfo.mAttackTag = AttackByNetPet
        skillInfo.mLockType = self.lockType
        skillInfo.mHitMonsters = self.curHitMonsters
        skillInfo.mHitPlayers = self.curHitPlayers
        skillInfo:setSkillDir(self.curHitDir)
        self:doBattle(skillInfo)
    end
end

function FightMgr:newXianTongBattle( skillId )
    -- body
    local rPet = mgr.ThingMgr:getObj(ThingType.pet, gRole:getXianTonID())
    if rPet then
        local skillInfo = self:createSkillInfo(skillId, rPet)
        skillInfo.mAttackTag = AttackByXiantongPet
        skillInfo.mLockType = self.lockType
        skillInfo.mHitMonsters = self.curHitMonsters
        skillInfo.mHitPlayers = self.curHitPlayers
        skillInfo:setSkillDir(self.curHitDir)
        self:doBattle(skillInfo)
    end
end

--战斗
function FightMgr:doBattle(skillInfo)
    -- print("FightMgr:doBattle:"..skillInfo.mKey)
    if skillInfo.dongzuo then  --如果有技能动作则需要C#处理
        local success = UFightControl:DoBattle(skillInfo:getCSharp())
        if success == false then
            cache.FightCache:removeToPool(skillInfo)
        end
    else
        self:onTriggerCallBack(skillInfo:getCSharp())
    end
end

--技能动作回调触发效果
function FightMgr:onTriggerCallBack(skillInfo)
    local s = cache.FightCache:getSkillInfo(skillInfo.key)
    if not s then return end

    --TODO 发送主角攻击消息
    if s.mAttackTag == AttackByRole then  --主人战斗
        --plog("主角攻击-->发送服务端消息",s.mDir,s.mAreaType)
        if s.mDir and s.mAreaType then
            s:addSelectTar(self.tarInfo.tType, self.tarInfo.tId)  --设置主攻目标到第一位
            fight.SelectRule:selectTars(s)  --选择可攻击的其他目标
        end
        proxy.ThingProxy:sRoleBattle(s)
        --技能进入冷却
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:coolDown(s.mSkillId)
        end
        local view = mgr.ViewMgr:get(ViewName.SceneSkillView)
        if view then
            view:coolDown(s.mSkillId)
        end
        --主人宠物也进入攻击状态
        local rPet = mgr.ThingMgr:getObj(ThingType.pet, gRole:getID())
        local nPet = mgr.ThingMgr:getObj(ThingType.pet, gRole:getPetID())
        local xPet = mgr.ThingMgr:getObj(ThingType.pet, gRole:getXianTonID())
        if rPet or nPet or xPet then
            self.curHitPlayers = s.mHitPlayers
            self.curHitMonsters = s.mHitMonsters
            self.curHitDir = s.mDir
            self.lockType = s.mLockType or 0
        end
        if rPet then
            rPet:enterFight()
        end
        if nPet then
            nPet:enterFight()
        end
        if xPet then
            xPet:enterFight()
        end
    elseif s.mAttackTag == AttackByRolePet or s.mAttackTag == AttackByNetPet or s.mAttackTag ==  AttackByXiantongPet then  --主人宠物战斗| 无技能特效
        proxy.ThingProxy:sRoleBattle(s)
    end

    --如果帧频小于20帧：不播放其他玩家的特效
    if mgr.QualityMgr:hitOtherFightEcts() then
        if (s.mAttackTag == AttackByRole or s.mAttackTag == AttackByYW) then
            mgr.EffectMgr:playBattleEffect(s.mStartEId, s)
        else
            cache.FightCache:removeToPool(s)
        end   
    else
        if s.mAttackTag == AttackByRole or s.mAttackTag == AttackByYW then
            mgr.EffectMgr:playBattleEffect(s.mStartEId, s)
        else
            local eNums = UEffectMgr:GetEffectNum()
            if eNums <= 25 then
                mgr.EffectMgr:playBattleEffect(s.mStartEId, s)
            else
                cache.FightCache:removeToPool(s)
            end
        end
    end
end
--战斗广播
function FightMgr:thingBattle(data)
    if data.opt == 4 or data.opt == 5 then
        data.atkId = data.opt
        data.opt = 1
    end
    if (gRole and data.atkId ~= gRole:getID()) then  --其他玩家战斗广播,宠物id和人物一样
        self:otherBattle(data)
        if data.extAtk == 1 then
            local tar = mgr.ThingMgr:getObj(ThingType.player, data.atkId)
            if tar then
                local skillInfo = self:createSkillInfo(5070101, tar)
                skillInfo.mAttackTag = AttackByYW
                self:onTriggerCallBack(skillInfo:getCSharp())
            end
        end
    else  --主角伤害广播
        --主角宠物表现
        --print("data.skillId",data.skillId,data.opt)
        if data.opt == 7 then
            if data.skillId == 5210301 or data.skillId == 5210101 then
                --print("宠物的特殊技能",data.skillId)
                local skillInfo = self:createSkillInfo(data.skillId, gRole)
                skillInfo.mAttackTag = AttackByYW --让人触发一下这个该死的
                self:onTriggerCallBack(skillInfo:getCSharp())

            end
        end
        --主角影卫表现
        if data.extAtk == 1 then
            local skillInfo = self:createSkillInfo(5070101, gRole)
            skillInfo.mAttackTag = AttackByYW
            self:onTriggerCallBack(skillInfo:getCSharp())
        end

        if data.skillId == 5220101 or data.skillId == 5220201 or data.skillId == 5220301 then
            local skillInfo = self:createSkillInfo(data.skillId, gRole)
            skillInfo.mAttackTag = AttackByYW
            self:onTriggerCallBack(skillInfo:getCSharp())
        end

    end

    mgr.HurtMgr:addServerHurts(data)
end

--构建影卫攻击
function FightMgr:yingWeiData(data)
    plog("触发了影卫攻击")
    local tempData = {}
    tempData.opt = data.opt
    tempData.atkId = data.atkId
    tempData.skillId = 5070101
    tempData.atkPox = data.atkPox
    tempData.atkPoy = data.atkPoy
    tempData.tarPox = data.tarPox
    tempData.tarPoy = data.tarPoy
    return tempData
end

function FightMgr:removeTimer()
    -- body
    self.fuji_target = nil --解除锁定
    if self.fanjitimer then
        mgr.TimerMgr:removeTimer(self.fanjitimer)
        self.fanjitimer = nil 
    end
    if self.fanjitimer2 then
        mgr.TimerMgr:removeTimer(self.fanjitimer2)
        self.fanjitimer = nil 
    end
end

function FightMgr:checkHook()
    -- body
    if UJoystick.IsJoystick then
        self:removeTimer()
        return true
    end
    return false
end

--玩家追着一个玩家目标打
function FightMgr:fightByTarget(data)
    -- body
    if not data then
        gRole:idleBehaviour()
        self:removeTimer()
        return
    end
    local range = 800
    local target = mgr.ThingMgr:getObj(ThingType.player, data.roleId) 
    self.fuji_target = target
    if not target then
        GComAlter(language.gonggong61)
        self:removeTimer()
        return
    end

    if GMath.distance(gRole:getPosition(),target:getPosition()) > range then
        GComAlter(language.gonggong62)
        self:removeTimer()
        return
    end
    if target:getStateID() == 2 then
        self:removeTimer()
        return
    end
    
    self:removeTimer()
    self.fanjitimer = mgr.TimerMgr:addTimer(0.4, -1, function()
        -- body
        local target = mgr.ThingMgr:getObj(ThingType.player,data.roleId)
        self.fuji_target = target
        if self:checkHook() or not target then
            gRole:idleBehaviour()
            self:removeTimer()
            return
        end
        if target:getStateID() == 2 then
            gRole:idleBehaviour()
            self:removeTimer()
            return
        end
        local s
        if mgr.HookMgr.skillList then
            for k ,v in pairs(mgr.HookMgr.skillList) do
                if v then
                    s = k
                    break
                end 
            end
        end
        if not s then
            local sex = cache.PlayerCache:getSex()
            local id
            if sex == 1 then
                id = 5010100
            else
                id = 5020100
            end
            s = id + math.random(6)
            local lastId = gRole:curUseSkill()
            while(s == tonumber(lastId)) do
               s = id + math.random(6)
            end
        end
        

        self:roleGotoTar(s,ThingType.player, data.roleId,200)
    end, "fanjitimer")
end

--附件玩家
function FightMgr:fightByTarget2(data)
    -- body
    if not gRole then
        return
    end
    if not data then
        gRole:idleBehaviour()
        self:removeTimer()
        return
    end
    self.fuji_target = mgr.ThingMgr:getObj(ThingType.player, data.roleId) 
    if not self.fuji_target then
        GComAlter(language.gonggong61)
        self:removeTimer()
        return
    end

    self:removeTimer() --移除上次的锁定
    self.fanjitimer2 = mgr.TimerMgr:addTimer(0.4, -1, function()
        -- body
        self.fuji_target = mgr.ThingMgr:getObj(ThingType.player, data.roleId) -- 锁定目标
        if self:checkHook() or not self.fuji_target then
            gRole:idleBehaviour()
            self:removeTimer()
            return
        end

        if gRole.pkState == PKState.kill or self.fuji_target.character.CanSelected  then
            --杀戮下 无视其他玩家状态
            local s
            if mgr.HookMgr.skillList then
                for k ,v in pairs(mgr.HookMgr.skillList) do
                    if v then
                        s = k
                        break
                    end 
                end
            end
            if not s then
                local sex = cache.PlayerCache:getSex()
                local id
                if sex == 1 then
                    id = 5010100
                else
                    id = 5020100
                end
                s = id + math.random(6)
                local lastId = gRole:curUseSkill()
                while(s == tonumber(lastId)) do
                   s = id + math.random(6)
                end
            end
            self:roleGotoTar(s,ThingType.player, data.roleId,200)
        else
            gRole:moveToPoint(self.fuji_target:getPosition(), 150, function()
                --跟着跑
                self:removeTimer() --移除上次的锁定
                GComAlter(language.near02)
            end)
        end
    end, "fightByTarget2")
end
--战斗广播 ，伤害来源
function FightMgr:checkFight_fujin(data)
    -- body
    if self.fuji_target then
        local player = mgr.ThingMgr:getObj(ThingType.player, self.fuji_target.data.roleId)
        if not player then
            self:fujingAttOver()
            return
        end
        local player2 = mgr.ThingMgr:getObj(ThingType.player, data.atkId)
        if player2 then
            for k ,v in pairs(data.uTargets) do
                if v.roleId == self.fuji_target.data.roleId then
                    self:fujingAttAdd(player2.data)
                    break
                end
            end
        end
    end
end

function FightMgr:fujingAttOver(data)
    -- body
    local mainView = mgr.ViewMgr:get(ViewName.MainView)
    if mainView then
        if not data then
            --锁定者死亡
            if self.fuji_target then
                self.fuji_target = nil 
            end
            mainView.btnnearchouren.data = nil 
            mainView:setVisible415()
        else
            --第3人死亡
            if mainView.btnnearchouren.data and mainView.btnnearchouren.data == data.roleId then
                mainView.btnnearchouren.data = nil 
                mainView:setVisible415()
            end
        end
    end
end

function FightMgr:fujingAttAdd(data)
    -- body
    local mainView = mgr.ViewMgr:get(ViewName.MainView)
    if mainView then
        if not mainView.btnnearchouren.data then
            mainView.btnnearchouren.data = data.roleId
            mainView:setVisible415()
        end
    end 
end

function FightMgr:playerDead( data )
    -- body
    if self.fuji_target and self.fuji_target.data.roleId == data.roleId then
        self:fujingAttOver()
    else
        local mainView = mgr.ViewMgr:get(ViewName.MainView)
        if mainView and mainView.btnnearchouren.data and mainView.btnnearchouren.data == data.roleId then
            self:fujingAttOver(data)
        end
    end
end

return FightMgr