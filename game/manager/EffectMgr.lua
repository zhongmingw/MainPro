--[[--
特效管理
]]

local EffectMgr = class("EffectMgr")
local SelectRule = require("game.fight.SelectRule")

function EffectMgr:ctor()
    UEffectMgr:RegisterFun(function(effect)
        self:onEffectCallBack(effect)
    end)

    --UI限时特效存储
    self.uiEffects = {}

    self.preloadEcts = {}
end

--特效回调触发
function EffectMgr:onEffectCallBack(effect)
    local skillInfo = effect.ExtendData
    if effect.NextEffect == "began" then  --特效开始

    elseif effect.NextEffect == "end" then  --特效播放完毕

    elseif effect.NextEffect == "hit" then  --特效触发受击
        self:hitEffect(effect, skillInfo)
    else  --触发下一个效果
        self:playBattleEffect(effect.NextEffect, skillInfo)
    end
    effect.ExtendData = nil
end

function EffectMgr:preLoadEffect(effId, pool)
    if not effId then return end
    local effectConf = conf.EffectConf:getEffectById(effId.."")
    if not effectConf then return end
    local resUrl = ResPath.effectResUI(effectConf["effect_id"])
    local effect = UEffectMgr:NewEffect(resUrl,nil,-1,pool)
    local function effectLoaded()
        if pool then
            self:removeEffect(effect)
        end
    end
    if effect.IsLoaded then
        effectLoaded()
    else
        effect:RegisterLua(function()
            effectLoaded()
        end)
    end
    effect.Visible = false
    if not pool then
        self.preloadEcts[tostring(effId)] = effect
    end
    return effect
end

function EffectMgr:getPreloadEct(effId)
    local ect = self.preloadEcts[tostring(effId)]
    if ect then
        local effectConf = conf.EffectConf:getEffectById(effId.."")
        local durition = effectConf["durition_time"]
        ect.Visible = true
        ect.RunTimes = 0
        ect.DuritionTime = durition
        self.preloadEcts[tostring(effId)] = nil
    end
    return ect
end

--ui特效
function EffectMgr:playUIEffect(effId, parent)
    if not effId then return end
    local effectConf = conf.EffectConf:getEffectById(effId.."")
    if not effectConf then
       -- plog("无特效id"..effId)
        return
    end
    local durition = effectConf["durition_time"]
    local ext = effectConf["ext"] or ""
    local resUrl = ResPath.effectResUI(effectConf["effect_id"])..ext
    --print("resUrl",resUrl)
    local pool = false
    if effectConf["pool"] then
        pool = true
    end
    local effect = UEffectMgr:NewEffect(resUrl,nil,durition,pool)
    local function effectLoaded()
        ------------------------------------------
        --父容器不可见的时候是无法加特效的。直接清理特效
        if parent and parent.visible == false then
            self:removeEffect(effect)
            return
        end
        ------------------------------------------
        --TODO特效加载完毕
        local go = effect.mGameObject
        go.name = "ui_"..effId
        -------------------------------------------
        if pool and durition ~= -1 then   --特殊处理，ui会索引特效对象而不能用对象池。外面包装一个GameObject供销毁
            go = GameObject.New()
            effect.Parent = go.transform
        end
        -------------------------------------------
        local goWrapper = GoWrapper.New(go)
        if parent then
            parent:SetNativeObject(goWrapper)
        end
        --[循环播放]需要记录，界面关闭要移除
        --[时间移除]不用记录，内部自动管理
        if durition == -1 then  
            self.uiEffects[effect.Name] = goWrapper
        end
    end
    if effect.IsLoaded then
        effectLoaded()
    else
        effect:RegisterLua(function()
            effectLoaded()
        end)
    end
    if effectConf["fzh"] then
        effect.LocalRotation = StaticVector3.vector3Z180
    end
    if effectConf["scale"] then
        effect.Scale = Vector3.New(effectConf["scale"], effectConf["scale"], effectConf["scale"])
    end
    return effect, durition
end

--播放杂七杂八的特效| 镜头特效，场景特效, buff特效
function EffectMgr:playCommonEffect(effectId, parent, loop, func, ispool)
    local effectConf = conf.EffectConf:getEffectById(effectId)
    local eId, durition, fzh, scale, eType, rotate
    local pool = ispool or false
    if not effectConf then
        eId = effectId
        durition = loop or -1
        rotate = Vector3.zero
    else
        eType = effectConf["layer"]
        eId = effectConf["effect_id"]
        durition = loop or effectConf["durition_time"]
        if effectConf["pool"] then
            pool = true
        end   
    end

    if eType == 1 then --身上
        rotate = StaticVector3.vector3Z180
        scale = Vector3.one
    elseif eType == 3 then  --场景上
        rotate = StaticVector3.vector3X60 + StaticVector3.vector3Z180
        scale = StaticVector3.scaleXYZ80
    elseif eType == 5 then
        rotate = StaticVector3.vector3Z180
        scale = Vector3.one
    elseif eType == 6 then
        rotate = Vector3.zero
        scale = Vector3.one
    end

    local resId = ResPath.effectResUI(eId)
    local effect = UEffectMgr:NewEffect(resId,parent,durition,pool)
    if effect.IsLoaded then
        if func then
            func()
        end
    else
        if func then
            effect:RegisterLua(function()
                func()
            end)
        end 
    end
    if rotate then
        effect.LocalRotation = rotate
    end
    if scale then
        effect.Scale = scale
    end
    effect.LocalPosition = Vector3.zero
    return effect,durition
end

--播放战斗特效
function EffectMgr:playBattleEffect(effectId, skillInfo)
    if g_ios_test then   --EVE 屏蔽技能特效
        return
    end
    if not mgr.QualityMgr:getAllSkillEffect() then
        return
    end
    --无特效
    if not effectId then
        cache.FightCache:removeToPool(skillInfo)
        return 
    end
    --无特效配置
    local effectConf = conf.EffectConf:getEffectById(effectId)
    if not effectConf then
        cache.FightCache:removeToPool(skillInfo)
        return 
    end
    --攻击目标已经清理
    if skillInfo.mAttack then
        if skillInfo.mAttack:isDispose() then
            cache.FightCache:removeToPool(skillInfo)
            return
        end
    end

    local resId = ""
    if gRole.isChangeBody and effectConf["effect_id_bs"] then
        resId = ResPath.effectRes(effectConf["effect_id_bs"])
    else
        if effectConf["effect_id"] then
            resId = ResPath.effectRes(effectConf["effect_id"])
        end
    end
    --效果持续时间
    local durition = effectConf["durition_time"]
    --效果的容器
    local eType = effectConf["layer"]
    local parent, scale, rotate, zRotate
    if eType == 1 then --释放者身上
        rotate = skillInfo.mAttack:getModelLocalRotation()+StaticVector3.vector3Z180
        parent = skillInfo.mAttack:getEffectTransform()
        scale = Vector3.one
    elseif eType == 2 then  --受击对象上层
        rotate = StaticVector3.vector3X60 + StaticVector3.vector3Z180
        parent = skillInfo.mHitTars[1]:getEffectTransform()
        scale = Vector3.one
    elseif eType == 3 then  --场景上
        rotate = StaticVector3.vector3X60 + StaticVector3.vector3Z180
        parent = UnitySceneMgr.pStateTransform
        scale = StaticVector3.scaleXYZ80
    elseif eType == 4 then  --场景上方向性
        rotate = skillInfo.mAttack:getBodyRotation()
        parent = UnitySceneMgr.pStateTransform
        scale = StaticVector3.scaleXYZ80
    elseif eType == 7 then
        rotate = skillInfo.mAttack:getModelLocalRotation()
        parent = UnitySceneMgr.pStateTransform
        scale = StaticVector3.scaleXYZ80
    elseif eType == 8 then--人物上（暂用）
        rotate =  StaticVector3.vector3Z180
        parent = skillInfo.mAttack:getEffectTransform()
        scale = Vector3.one
    else
        scale = Vector3.one
        rotate = Vector3.one
    end
    
    local effect = UEffectMgr:NewEffect(resId,parent,durition,true)
    effect.Scale = scale
    effect.LocalRotation = rotate
    effect.EffectId = tostring(effectId)
    --特效深度
    local depth
    if effectConf["depth"] then
        depth = Vector3.New(0,effectConf["depth"],0)
    else
        depth = Vector3.zero
    end
     
    --效果的相对坐标
    local p = effectConf["pos"]
    if p then
        if p[1]==1 then --相对坐标
            effect.LocalPosition = Vector3.New(p[2],0,p[3]) + depth
        elseif p[1] == 2 then
            effect.LocalPosition =  skillInfo.mAttack:getPosition() + skillInfo.mAttack:getDirection() * p[2] + depth
        elseif p[1] == 3 then
            if skillInfo.mDir then
                effect.LocalPosition =  skillInfo.mDir + depth
            else
                effect.LocalPosition =  skillInfo.mAttack:getPosition() + skillInfo.mAttack:getDirection() * p[2] + depth
            end
        end
    end
    --触发点
    local nextEffect = effectConf["next_effect"]
    if nextEffect then
        for i=1,#nextEffect do
            effect:AddTrigerTime(nextEffect[i][1], nextEffect[i][2].."")
        end
    end
    --受击音效
    if effectConf["sound"] then
        mgr.SoundMgr:playSound(effectConf["sound"])
    end

    effect.ExtendData = skillInfo 
end

--受击处理
function EffectMgr:hitEffect(effect, skillInfo)
    --print("EffectMgr:hitEffect(effect, skillInfo)", skillInfo.mAttackTag)
    local function tarHurt(tarIds, t)
        for i=1, #tarIds do
            local tar
            if tarIds[i] == gRole:getID() then
                tar = gRole
            else
                tar = mgr.ThingMgr:getObj(t, tarIds[i])
            end
            if tar then
                skillInfo.mHitTars = {tar}
                local eNums = UEffectMgr:GetEffectNum()
                if eNums <= 23 then
                    self:playBattleEffect(skillInfo.mHitEId, skillInfo)
                end
                tar:beHurt()
            end
        end
    end
    if skillInfo.mHitMonsters and #skillInfo.mHitMonsters > 0 then
        tarHurt(skillInfo.mHitMonsters, ThingType.monster)
    end
    if skillInfo.mHitPlayers and #skillInfo.mHitPlayers > 0 then
        tarHurt(skillInfo.mHitPlayers, ThingType.player)
    end
    --主角攻击需要做些战斗节奏
    if skillInfo.mAttackTag == 1 then
        local effectConf = conf.EffectConf:getEffectById(effect.EffectId)
        --闪白效果
        if effectConf["c_ect"] then
            UnityCamera:CameraEffectByName(effectConf["c_ect"])
        end
        --是否震屏
        if effectConf["shock"] then
            --0.04秒放大10个点， 0.04秒到缩小5个点， 0.04秒还原0
            UnityCamera:RoleJumpCameraShake(-5,0.04,3,0.04,0,0.04)
        end
    end
    --该技能释放完毕回收技能
    cache.FightCache:removeToPool(skillInfo)
end

function EffectMgr:removeEffect(e)
    UEffectMgr:RemoveEffect(e)
end

function EffectMgr:removeEffectByName(name)
    UEffectMgr:RemoveEffectByName(name)
end

function EffectMgr:removeUIEffect(e)
    local go = self.uiEffects[e.Name]
    if go then
        self:removeEffect(e)
        go.wrapTarget = nil
    end
    self.uiEffects[e.Name] = nil
    go = nil
end

return EffectMgr