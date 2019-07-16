--
-- Author: yr
-- Date: 2017-07-18 18:51:39
--

local BaseHook = class("BaseHook")

function BaseHook:ctor()
    
end

function BaseHook:setHookData(data)
    
end

function BaseHook:enter(data)
    self.hookPoint = nil
    self.hookState = HookState.idle
    self.moveDo = HookMoveDo.fight
    self.hookCount = 0
    self.repairStep = 1  --主要是修复寻路的缺陷
end

function BaseHook:clear()
    
end

function BaseHook:changeState(sId)
    self.hookState = sId
end

function BaseHook:checkState(sId)
    if self.hookState == sId then
        return true
    else
        return false
    end
end

--获取场景存在的怪物id
function BaseHook:getSceneExitMonster()
    local things = mgr.ThingMgr:objsByType(ThingType.monster)
    for k, v in pairs(things) do
        if v:canBeSelect() then
            return v.data.mId, v:getPosition(), k
        end
    end
    return nil
end

--获取场景存在的怪物id
function BaseHook:getSceneExitPlayer()
    local things = mgr.ThingMgr:objsByType(ThingType.player)
    for k, v in pairs(things) do
        if v:canBeSelect() and v:isDeadState() == false then
            --print("寻找玩家》》》》》》")
            return v:getID(), v:getPosition()
        end
    end
    return nil
end

function BaseHook:update()
    -- print("HookState:", self.hookState)
    if self:checkState(HookState.idle) or self:checkState(HookState.moveBreak) then
        if self.hookPoint then
            local p = self.hookPoint
            --print("HookState.idle",p.x, p.z)
            local gridValue = UnityMap:GetGridValue(p)
            local myGridValue = UnityMap:GetGridValue(gRole:getPosition())
            local sId = cache.PlayerCache:getSId()
            if mgr.FubenMgr:isKuafuCityWar(sId) then--跨服城战寻路特殊处理
                if myGridValue == gridValue then
                    self:startMoveToPoint(p)
                else
                    mgr.HookMgr:cancelInterimHook()
                end
            else
                self:startMoveToPoint(p)
            end
        end
    elseif self:checkState(HookState.move) then   --移动中
        self:checkMove()
    elseif self:checkState(HookState.moveComplete) then  --移动完成
        -- print("移动完成",self.moveDo,HookMoveDo.pick)
        if self.moveDo == HookMoveDo.pick then
            self:checkPick()
        elseif self.moveDo == HookMoveDo.fight then
            self:startAttack()
        end
    elseif self:checkState(HookState.findMonster) then  --寻找怪物
        local _ , point = self:getSceneExitMonster()
        if point then
            self.hookPoint = point
            self:changeState(HookState.idle)
            self:update()
        end
    elseif self:checkState(HookState.findPlayer) then  --寻找玩家
        local _ , point = self:getSceneExitPlayer()
        if point then
            self.hookPoint = point
            self:changeState(HookState.idle)
            self:update()
        end
    elseif self:checkState(HookState.picking) then  --采集中

    elseif self:checkState(HookState.stop) then  --挂机停止中

    end
end

--移动过程中是否检查攻击
function BaseHook:checkMove()
    
end


function BaseHook:setPickRoleId(roleId)
    -- body
end

function BaseHook:getPickRoleId()
    return "0"
end

--检查是否可以攻击
function BaseHook:checkCanAttack()
    local tar = mgr.ThingMgr:getNearTar()
    if tar then
        return true
    end
    self:changeState(HookState.findMonster)
    return false
end

--开始攻击打斗
function BaseHook:startAttack()
    if not self:checkCanAttack() then
        return
    end
    self.hookCount = self.hookCount + 1
    local s = nil
    for k, v in pairs(HookCache.skillList) do
        local open = UPlayerPrefs.GetInt(string.sub(k.."",1,5).."_SkillPanel") or 0
        --print(open,k)
        if open ~= 2 then
            if not s then
                s = k 
            else
                s = math.max(k,s)
            end
        end
    end
    if s and self.hookCount > 2 then
        if self:autoChange() then
            --变身会切换模型导致攻击丢失
            --挂机会感觉停一下
            --这里延迟出个普攻
            mgr.TimerMgr:addTimer(0.1, 1, function()
                gRole:baseAttack(self.thingType, self.thingId)
            end)
        else
            gRole:skillAttack(s,self.thingType, self.thingId)
        end
        return
    end
    --检测使用有装备技能
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view and view.BtnFight then
        local id =  view.BtnFight:getCurCanUse()
        if id then
            local open = UPlayerPrefs.GetInt(string.sub(id.."",1,5).."_SkillPanel") or 0
            if open ~= 2 then
                gRole:skillAttack(id)
                return
            end
        end
    end

    local sex = cache.PlayerCache:getSex()
    local id
    if sex == 1 then
        id = 50101
    else
        id = 50201
    end
    local open = UPlayerPrefs.GetInt(string.sub(id.."",1,5).."_SkillPanel") or 0
    if open ~= 2 then
        gRole:baseAttack(self.thingType, self.thingId)
    end
end

function BaseHook:checkPick()
    local dis = GMath.distance(self.hookPoint, gRole:getPosition())
    if dis <= 55 then
        self:startPick()
    else
        self:changeState(HookState.idle)
    end
end

--开始拾取
function BaseHook:startPick()
    -- print("采集")
    self:changeState(HookState.picking)
end
--开始移动
function BaseHook:startMoveToPoint(point)
    self.hookCount = 0
    self:changeState(HookState.move)
    local s = gRole:moveToPoint(point, 50, function()
        self:changeState(HookState.moveComplete)
    end, function()
        self:moveBreakHandler()
    end)
    if not s then
        self:repairPathfinding(point)
    else
        self.repairStep = 1
    end
end

function BaseHook:moveBreakHandler()
    self:changeState(HookState.moveBreak)
end

function BaseHook:hookBreak()
    self:changeState(HookState.moveBreak)
end

function BaseHook:repairPathfinding(point)
    if self.repairStep == 1 then  --修复目标点
        if newPoint then
            point = newPoint
        end
        self:setHookPoint(point)
        self:changeState(HookState.idle)
        self.repairStep = 2
        print("@修复寻路目标点", point.x, point.z)
    elseif self.repairStep == 2 then  --修复自己的坐标
        gRole:restPosition()
        self:changeState(HookState.idle)
        self.repairStep = 3
        print("@修复自己的坐标", point.x, point.z)
    elseif self.repairStep == 3 then
        self:enter()
        self.repairStep = 1
        print("@重置挂机", point.x, point.z)
    end
end

--设置锁定目标对象
function BaseHook:setLockThing(t, id)
    self.thingType = t
    self.thingId = id
end
--设置移动点
function BaseHook:setHookPoint(point)
    -- print(debug.traceback())
    self.hookPoint = point
end

--挂机期间 尝试变身
function BaseHook:autoChange()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view and view.BtnFight then
        return view.BtnFight:AutoChange()
    end
    return false
end

--退出
function BaseHook:exit()
    return false
end

function BaseHook:dumpInfo()
    print("挂机状态：", self.hookState)
    printt("挂机坐标点：", self.hookPoint)
    print("挂机目标：", self.moveDo)
end

return BaseHook