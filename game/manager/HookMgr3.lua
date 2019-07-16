--
-- Author: yr
-- Date: 2017-07-18 18:57:21
--

local HookMgr3 = class("HookMgr3")

function HookMgr3:ctor()
    self.hooks = {}
    self.mCurHook = nil
    self.hooks[HookType.taskHook]        = hook.taskHook.new()
    self.hooks[HookType.fubenHook]       = hook.fubenHook.new()
    self.hooks[HookType.bossHook]        = hook.bossHook.new()
    self.hooks[HookType.gangBossHook]    = hook.gangBossHook.new()
    self.hooks[HookType.wenDingHook]     = hook.wenDingHook.new()
    self.hooks[HookType.hangLingHook]    = hook.hangLingHook.new()
    self.hooks[HookType.fieldHook]       = hook.fieldHook.new()
    self.hooks[HookType.cityHook]        = hook.cityHook.new()
    self.hooks[HookType.xianmoHook]      = hook.xianMoHook.new()
    self.hooks[HookType.awakenHook]      = hook.awakenBossHook.new()
    self.hooks[HookType.multiBossHook]   = hook.multiBossHook.new()
    self.hooks[HookType.shoutaHook]      = hook.shoutaHook.new()
    self.hooks[HookType.xmzbHook]        = hook.xmzbHook.new()
    self.hooks[HookType.pwsHook]         = hook.pwsHook.new()
    self.hooks[HookType.citywarHook]     = hook.citywarHook.new()
    self.hooks[HookType.xianLvPKHook]    = hook.xianLvPKHook.new()
    self.hooks[HookType.tjdkHook]        = hook.tjdkHook.new()
    self.hooks[HookType.xycmHook]        = hook.xycmHook.new()
    self.isHook = false
    self.timer = nil
end

function HookMgr3:enterHook(data)
    local sId = cache.PlayerCache:getSId()
    local sConf = conf.SceneConf:getSceneById(sId)
    if sConf.kind then
        if sConf.kind == SceneKind.mainCity or sConf.kind == SceneKind.xinshou then
            self:translateToHook(HookType.cityHook)
        elseif sConf.kind == SceneKind.field or sConf.kind == SceneKind.lianjigu 
            or sConf.kind == SceneKind.wanshendian 
            or sConf.kind == SceneKind.wanshendianCross then --野外搜索最近的怪物PK 
            self:translateToHook(HookType.fieldHook)
        elseif sConf.kind == SceneKind.fuben 
            or sConf.kind == SceneKind.kuafueZudui 
            or sConf.kind == SceneKind.qinyuanfuben
            or sConf.kind == SceneKind.hjzy 
            or sConf.kind == SceneKind.jianshengshouhu 
            then

            if mgr.FubenMgr:isDayTaskFuben(sId)  then
                local key = cache.FubenCache:getDayKey(sId)
                if key then
                    local fbConf = conf.FubenConf:getdailyFubenRed(key)
                    if fbConf then
                        if fbConf.kind == 2 then
                            self:translateToHook(HookType.shoutaHook)
                        else
                            self:translateToHook(HookType.fubenHook)
                        end
                    end
                end
            else
                if sId == Fuben.xianyulingta or sConf.kind == SceneKind.jianshengshouhu then
                    self:translateToHook(HookType.shoutaHook)
                else
                    self:translateToHook(HookType.fubenHook)
                end
            end
        elseif sConf.kind == SceneKind.eliteBoss 
            or sConf.kind == SceneKind.kuafueliteBoss 
            or sConf.kind == SceneKind.dujie 
            or sConf.kind == SceneKind.xianzunBoss then
            self:translateToHook(HookType.bossHook)      
        elseif sConf.kind == SceneKind.gangWar then 
            self:translateToHook(HookType.xmzbHook)    
        elseif sConf.kind == SceneKind.XianmengZhudi then --EVE 仙盟BOSS
            -- if GAreThereMonsters() then --BOSS存在才可挂机
                self:translateToHook(HookType.bossHook)
            -- end
        elseif sConf.kind == SceneKind.worldBoss or 
            sConf.kind == SceneKind.bossHome or 
            sConf.kind == SceneKind.xianyuBoss or 
            sConf.kind == SceneKind.kfxianyuBoss or 
            sConf.kind == SceneKind.kuafuworld or
            sConf.kind == SceneKind.kfpet or
            sConf.kind == SceneKind.kuafuXianyu or 
            sConf.kind == SceneKind.kuafuXianyu2 or 
            sConf.kind == SceneKind.sgsj or 
            sConf.kind == SceneKind.kfsgsj or 
            sConf.kind == SceneKind.wxsd or
            sConf.kind == SceneKind.feisheng or sConf.kind == SceneKind.feisheng1 or
            sConf.kind == SceneKind.shenshou or sConf.kind == SceneKind.kuafushenshou or
            sConf.kind == SceneKind.taiguXuanJing or sConf.kind == SceneKind.taiguXuanJing1 or
            sConf.kind == SceneKind.shenshoushengyu then--世界boss，boss之家
            self:translateToHook(HookType.multiBossHook)
        elseif sConf.kind == SceneKind.gangBoss then
            self:translateToHook(HookType.gangBossHook, data)
        elseif sConf.kind == SceneKind.huangling then --皇陵挂机
            self:translateToHook(HookType.hangLingHook)
        elseif sConf.kind == SceneKind.wending then --问鼎
            self:translateToHook(HookType.wenDingHook)
        elseif sConf.kind == SceneKind.xianmoWar then --仙魔战
            self:translateToHook(HookType.xianmoHook)
        elseif sConf.kind == SceneKind.awakenBoss then--剑神殿
            self:translateToHook(HookType.awakenHook)
        elseif sConf.kind == SceneKind.home then--家园
            local v = conf.HomeConf:getScenesInfoById(3)
            local point = Vector3.New(v.ponit[1][1], gRolePoz, v.ponit[1][2])

            mgr.JumpMgr:findPath(point,0,function()
                -- body
                local _, info = mgr.ThingMgr:getNearTar()
                if info then
                    self:startHook()
                end
            end)
        elseif sConf.kind == SceneKind.rankmatching or sConf.kind == SceneKind.teammatching or sConf.kind == SceneKind.playoff then--排位赛
            -- print("排位赛挂机",HookType.pwsHook)
            self:translateToHook(HookType.pwsHook)
        elseif sConf.kind == SceneKind.citywar then--跨服城战
            self:translateToHook(HookType.citywarHook)
        elseif sConf.kind == SceneKind.xianLvPKhxs or sConf.kind == SceneKind.xianLvPKzbs or sConf.kind == SceneKind.xianLvPKhxs_2 or sConf.kind == SceneKind.xianLvPKzbs_2 then--仙侣PK
            -- print("仙侣pk挂机>>>>>>>>>")
            self:translateToHook(HookType.xianLvPKHook)
        elseif sConf.kind == SceneKind.collect then--天晶洞窟
            self:translateToHook(HookType.tjdkHook)
        elseif sConf.kind == SceneKind.wsjChuMo then--降妖除魔
            self:translateToHook(HookType.xycmHook)
        end
    end
end

function HookMgr3:translateToHook(hookId, data)
    if self.hooks[hookId] then
        self.isHook = true
        self.mCurHook = self.hooks[hookId]
        self:addHookTimer()
        self.mCurHook:enter(data)
        self:setHookState()
        --print("@开启挂机~")
    else
        --print("@挂机不存在")
    end
end

--设置挂机数据data， checkHook-是否检查挂机
function HookMgr3:setHookData(data, checkHook)
    if self.isHook == false then
        self:enterHook()
    end
    if self.mCurHook then
        self.mCurHook:setHookData(data)
    end
end

function HookMgr3:cancelHook()
    --print("@停止挂机~")
    self.isHook = false
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
    self:setHookState()
    gRole:stopAI()
end

--=============================================================================
---------------------------旧接口优化处理--------------------------------------
--旧接口 - 只针对任务打怪挂机
function HookMgr3:startHook()
    self:translateToHook(HookType.taskHook)
end

--旧接口调用-无效
function HookMgr3:stopHook()
    -- body
end
function HookMgr3:setPickState(state)
    self.isPickState = state
end

function HookMgr3:getPickState()
    return self.isPickState
end

--皇陵挂机杀怪和boss   param hookType 1为杀怪 2为杀boss
function HookMgr3:HuanglingHook(hookType)
    self:setHookData({code=1, info=hookType}, true)
end
--皇陵挂机任务
function HookMgr3:HuanglingTaskHook(data)
    self:setHookData({code=2, info=data}, true)
end

--问鼎挂机
function HookMgr3:WendingHook(data)
    self:setHookData({code=1, info=data}, true)
end

--仙盟争霸挂机
function HookMgr3:xmzbHook(data)
    self:setHookData({code=1, info=data}, true)
end

function HookMgr3:setPickRoleId(roleId)
    self.pickRoleId = roleId
end

function HookMgr3:getPickRoleId()
    return self.pickRoleId  or "0"
end
--水晶有改变
function HookMgr3:crystalChange()
    if self.isHook then
        if self.hooks[HookType.xmzbHook] then--重新挂机避免走到不可采集的水晶位置
            self.hooks[HookType.xmzbHook]:againHook()
        end
    end
end
--采集完
function HookMgr3:finishPick(isPick)
    if isPick then--采集完了
        if self.isHook then
            if self.hooks[HookType.xmzbHook] then--完成采集
                self.hooks[HookType.xmzbHook]:againHook()
            end
        end
    else
        if self.hooks[HookType.xmzbHook] then--完成采集
            self.hooks[HookType.xmzbHook]:finishPick()
        end
    end
end


--==============================================================================
--挂机定时器
function HookMgr3:addHookTimer()
    if not self.timer then
        self.timer = mgr.TimerMgr:addTimer(0.3, -1, function()
            self:update()
        end, "HookMgr")
    end
end

--更新玩家可释放的技能
function HookMgr3:updateSkills(sId, cool)
    --print(debug.traceback())
    --print("技能冷却设置：",sId, cool)
    if cool==false then
        HookCache.skillList[sId] = 1
    else
        HookCache.skillList[sId] = nil
    end
end

function HookMgr3:update()
    if not self.mCurHook then return end
    --遥感操作停止挂机
    if UJoystick.IsJoystick then
        if not self:isInterimHook() then
            GComAlter(language.hook1)
            self.interimHook = true--临时手动挂机
            self:setHookState()
        end
        -- self:cancelHook()
        mgr.TaskMgr.mState = 0 --设置为自动取消任务
        return
    end

    if gRole and gRole.data["isDead"] == true then
        return
    end
    if self:isInterimHook() then--上一次处于临时挂机状态就重新设置
        GComAlter(language.hook2)
        self.interimHook = false--取消临时手动挂机
        self:setHookState()
    end

    self.mCurHook:update()
end
--是否临时手动挂机
function HookMgr3:isInterimHook()
    return self.interimHook
end

--设置挂机状态（如主界面的按钮）
function HookMgr3:setHookState()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view and view.BtnFight then
        view.BtnFight:setHookState()
    end
end

function HookMgr3:dumpInfo()
    if self.mCurHook then
        self.mCurHook:dumpInfo()
    end
end

return HookMgr3