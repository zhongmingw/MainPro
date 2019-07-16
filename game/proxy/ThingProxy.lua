--
-- Author: yr
-- Date: 2017-01-13 16:13:55
--

local ThingProxy = class("ThingProxy",base.BaseProxy)

function ThingProxy:init()
    self:add(8020101, self.rThingAppear)  --登录玩家怪物出现  出现广播（玩家、怪物）
    self:add(8040102, self.rJump)  --战斗广播
    self:add(8020103, self.rPlayerDisappear)  --玩家移除
    self:add(8020104, self.rChangeScene)  --切换场景返回
    self:add(8020105, self.rMonsterDisappear)  --怪物移除
    self:add(8020106, self.rMonsterAppear)  --怪物出现
    self:add(8020107, self.rPlayerAppear)  --玩家出现
    self:add(8020109, self.rMonsterListDisappear)  --玩家移除列表
    self:add(8020110, self.rPlayerDead)  --玩家死亡
    self:add(8020111, self.rPlayerRevive)  --玩家复活
    self:add(8020112, self.rChangePosition)  --玩家场景位置改变
    self:add(8040101, self.rThingBattle)  --战斗广播
    self:add(8040201, self.rAddBuff)  --添加buff
    self:add(8040202, self.rRemoveBuff)  --移除buff
    self:add(8040204, self.rChangePKState)  --pk模式修改
    self:add(8020203, self.rAttrisRound)  --广播属性给周围玩家
    self:add(5020207, self.rUseXiaoFeiXie)  --可以使用小飞鞋
    self:add(8040205, self.rPickCollect) --开始采集广播

    self:add(8020113,self.add8020113)
    self:add(8020114,self.add8020114)-- 复活广播(部件)
    self:add(8020115,self.add8020115)-- 移除广播(部件)
    self:add(8020116,self.add8020116)-- 更新组件属性


    self:add(8020204,self.add8020204) --广播自己的buff列表 

    self:add(8040206,self.add8040206)--广播采集动作移除

    
    --
    self.bData = {}
end

local function checkChangeSid(sId)
    -- body
    if not sId then
        return false
    end
    --切换场景前先检测是否可以跳转
    local confdata = conf.SceneConf:getSceneById(sId)
    if not confdata then
        return false
    end
    if confdata.lvl and confdata.lvl > cache.PlayerCache:getRoleLevel() then
        return false
    end

    return true
end

--切换场景
function ThingProxy:sChangeScene(sId, x, y, t, ext)
    if not checkChangeSid(sId) then
        GComAlter(language.map03)
        return
    end
    CClearRankView()
    self:send(1020101, {sceneId=sId, pox=x, poy=y, type=t, ext01=ext})
end
function ThingProxy:rChangeScene(data)
    self:closeView()
    --场景切换的时候请求新的buff
    self:send(1810206)

    -- local ls = cache.PlayerCache:getSId()
    -- if ls.."" ~= "204001" then
    --     gRole:flyUp(function() end)
    -- end
    
    if gRole then
        gRole:stopAI()
        gRole:cancelSit()
        mgr.HookMgr:cancelHook()
    end

    mgr.SceneMgr:changeMap(data.sceneId, data.mapId, data.pox, data.poy)
end
--广播自己的buff列表
function ThingProxy:add8020204(data)
    --mgr.BuffMgr:init()
    --plog("推送buff")
    local param = {
        roleId = cache.PlayerCache:getRoleId()
    }
    mgr.BuffMgr:removeThingBuff(param)

     --改变自己的buff
    cache.PlayerCache:setBuffsData(data.buffs)

    if gRole then
        mgr.BuffMgr:addThingBuff(cache.PlayerCache:getData())
        --避免 变身形态 但是没有变身buff
        if gRole.isChangeBody then
            if not mgr.BuffMgr:isChangeBody() then
                plog("恢复形态")
                gRole:restoreBody()
            end
        end
    end 
end


--改变坐标
function ThingProxy:rChangePosition(data)
    mgr.SceneMgr:changeMap2(data.sceneId,data.roleId, data.pox, data.poy)
end
--跳跃
function ThingProxy:sJump(data)
    --printt(data)
    self:send(1810204, data)
end
function ThingProxy:rJump(data)
    mgr.JumpMgr:otherJump(data)
end
--请求变身
function ThingProxy:sChangeBody()
    self:send(1810203, {flag=1})
end
--请求小飞鞋
function ThingProxy:sXiaoFeiXie(sId,x,y)
    --新手地图任务未完成不能切换
    local id = cache.PlayerCache:getSId()
    if tonumber(id) == 204001 then
        if not cache.TaskCache:isfinish(1017) then
            GComAlter(language.gonggong87)
            GgoToMainTask()
            return 
        end
    end
    if not checkChangeSid(sId) then
        GComAlter(language.map03)
        return
    end


    self.xfx = {sId, x, y}
    self:send(1020207)
end
--广播周围玩家属性
function ThingProxy:rAttrisRound(data)
    local player
    local isMe = false
    if gRole and data.roleId == gRole:getID() then
        player = gRole
        isMe = true
    else
        player = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
        if not player then
            player = mgr.ThingMgr:getObj(ThingType.monster, data.roleId)
        end
    end
    if player then
        player:refreshScore(data.attris)
        if data.attris64 and data.attris64[101] then
            data.attris[101] = data.attris64[101]
        end
        player:updateAttris(data.attris)
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view and isMe then
            view:updateRoleInfo()
        end
       


        if data.attris and data.attris[520] and data.attris[520] == 1 then
            player:addSpringEffect()
        end
    end
end

function ThingProxy:rUseXiaoFeiXie(data)
    if data.suc == 1 and self.xfx then
        mgr.JumpMgr:feiXieJump(self.xfx[1], self.xfx[2], self.xfx[3])


        -- if not cache.PlayerCache:VipIsActivate(1) then --不是白银vip
        --     if cache.PlayerCache:getAttribute(10309) > 0 then --原来的次数>0
        --         --飞起一个字
        --         GComAlter(string.format(language.map06,data.leftFlyCount))
        --     end
        --     cache.PlayerCache:setAttribute(10309,data.leftFlyCount)
        -- end
    else
        if g_ios_test then    --EVE 屏蔽
            GComAlter(language.gonggong76)
        else
            GComAlter(language.map02)
        end 
    end
    self.xfx = nil
end
--死亡复活
function ThingProxy:sRevive(type)
    if mgr.FubenMgr:isQingYuanFuben(cache.PlayerCache:getSId()) then
        GComAlter(language.kuafu70)
        return
    end
    self:send(1020105, {reviveType=type})
end

function ThingProxy:rAddBuff(data)
    mgr.BuffMgr:addBuff(data)
    local  view = mgr.ViewMgr:get(ViewName.BuffView)
    if view then
        view:addBuff(data)
    end
end
function ThingProxy:rRemoveBuff(data)
    mgr.BuffMgr:removeBuff(data)
    local  view = mgr.ViewMgr:get(ViewName.BuffView)
    if view then
        view:removeBuff(data)
    end
end

function ThingProxy:sChangeSceneComplete()
    -- plog("切换场景完成--->>")
    -- print(debug.traceback())
    self:send(1020102,{width=gScreenSize.width, height=gScreenSize.height})
end

--玩家/怪物 出现广播[登录]
function ThingProxy:rThingAppear(data)
    -- plog("出现广播--->>")
    -- printt(data)
    
    local view = mgr.ViewMgr:get(ViewName.BeachMainView)
    if view then
        view:clearList()
    end
    --mgr.BuffMgr:removeThingBuff(data)
    mgr.ThingMgr:pushThingsQueue(data)
    --仙域禁地处理
    -- local view1 = mgr.ViewMgr:get(ViewName.TrackView)
    -- if view1 and view1.bossTrack.rankWorldList then
    --     local data1 = {}
    --     for k,v in pairs(view1.bossTrack.rankWorldList) do
    --         data1[v.roleId] = v
    --     end
    --     for k,v in pairs(data.monsters) do
    --         if not data1[v.roleId] and v.sceneId == 258003 then
    --             local data2 = v
    --             data2.nextRefreshTime = 0
    --             table.insert(view1.bossTrack.rankWorldList, data2)
    --             print("插入了~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    --         end
    --     end
    -- end
end
function ThingProxy:rPlayerAppear(data)
    --mgr.BuffMgr:removeThingBuff(data)
    --printt("rPlayerAppear 8020107",data)
    mgr.ThingMgr:pushAppearQueue(data.userInfo, ThingType.player)
end
--玩家 移除
function ThingProxy:rPlayerDisappear(data)
    local id = data.roleId
    local dJumps = data.dJumps
    mgr.ThingMgr:removeObj(ThingType.pet, id, true)

    mgr.FightMgr:playerDead(data)

    if #dJumps > 0 then
        mgr.JumpMgr:otherJump(dJumps[1], true)
    else
        mgr.ThingMgr:removeObj(ThingType.player, id, true)
    end
end
--玩家死亡
function ThingProxy:rPlayerDead(data)
    mgr.ThingMgr:playerDead(data)


end
function ThingProxy:rPlayerRevive(data)
    mgr.ThingMgr:playerRevive(data)
end
--怪物 出现
function ThingProxy:rMonsterAppear(data)
    mgr.ThingMgr:pushAppearQueue(data.monsterInfo, ThingType.monster)
end
--怪物 移除
function ThingProxy:rMonsterDisappear(data)
    mgr.ThingMgr:monsterDead(data)
end
function ThingProxy:rMonsterListDisappear(data)
    mgr.ThingMgr:monsterListDisappear(data)
end
--  移除广播(部件)
function ThingProxy:add8020113(data)
    for k , v in pairs(data.dWidgets) do
        local data = {roleId = v}
        mgr.ThingMgr:widgetDead(data)
    end
end
-- 复活广播(部件)
function ThingProxy:add8020114( data )
    -- body
    for k , v in pairs(data.widgets) do
        mgr.ThingMgr:pushAppearQueue(v, ThingType.monster)
    end
end
--  移除广播(部件)
function ThingProxy:add8020115( data )
    -- body
    mgr.ThingMgr:widgetDead(data)
end
--玩家释放技能
function ThingProxy:sRoleBattle(skillInfo)
    self.bData.uTargets = skillInfo.mHitPlayers
    self.bData.mTargets = skillInfo.mHitMonsters
    self.bData.skillId = skillInfo.mSkillId
    self.bData.opt = skillInfo.mAttackTag
    local p = gRole:getPosition()
    self.bData.atkPox = p.x
    self.bData.atkPoy = p.z
    self.bData.lockType = skillInfo.mLockType
    if skillInfo.mDir then
        self.bData.tarPox = skillInfo.mDir.x
        self.bData.tarPoy = skillInfo.mDir.z
    else
        self.bData.tarPox = 0
        self.bData.tarPoy = 0
    end
    self:send(1810201, self.bData)
    -- for i=1, #skillInfo.mHitMonsters do
    --     print("受击目标：", skillInfo.mHitMonsters[i])
    -- end
end

function ThingProxy:sNpcBattle(fightData)
    self:send(1810201, fightData)
end

--跨服场景内部传送
function ThingProxy:crossTransfer(param)
    self:send(1810601,param)
end
--战斗广播
function ThingProxy:rThingBattle(data)
    mgr.FightMgr:thingBattle(data)

    if gRole then
        gRole:isFightByOher(data)
    end
    mgr.FightMgr:checkFight_fujin(data)
end
--pk模式广播
function ThingProxy:rChangePKState(data)
    if data.status == 0 then
        printt("pk广播>>>>>>>>>>>>",data)
        if data.roleId == cache.PlayerCache:getRoleId() then
            gRole:changePkState(data.pkState)
        else
            local thing = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
            if thing then
                thing:updatePKState(data.pkState)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--广播开始采集
function ThingProxy:rPickCollect( data )
    -- printt("广播开始采集",data)
    if data.status == 0 then
        if data.type == 3 then--快速采集
            if data.roleId == gRole:getID() then
                local mConf = conf.NpcConf:getNpcById(data.mid)
                if mConf.buff then
                    local buffData = conf.BuffConf:getBuffConf(mConf.buff[1][1])
                    if buffData.id == 9006107 then--爆炸buff 非持续
                        GComAlter(buffData.desc)
                    else
                        GComAlter(language.fuben179..buffData.desc)
                    end
                end
            end
            return--快速采集不能调采集动作
        end
        if data.roleId == gRole:getID() then--自己
            gRole:collect(function(state)
                if 1 == state then
                    local param = {}
                    param.func = function()
                    end
                    --跨服三界争霸的箱子
                    local obj = mgr.ThingMgr:getObj(ThingType.monster, data.mRoleId)
                    if obj then
                        if obj:getKind() == MonsterKind.sjchest or obj:getKind() == MonsterKind.collection or obj:getKind() == MonsterKind.crystal then
                            local mConf = conf.NpcConf:getNpcById(obj:getMId())
                            param.pickUseTime = math.ceil(mConf.done_time / 1000)
                        end
                        if obj:getKind() == MonsterKind.crystal or obj:getKind() == MonsterKind.collection then
                            print("为了保险再缓存采集id",data.mRoleId)
                            mgr.HookMgr:setPickRoleId(data.mRoleId) 
                        end
                    end
                    if not mgr.ViewMgr:get(ViewName.PickAwardsView) then
                        if param.pickUseTime > 1 then
                            mgr.ViewMgr:openView2(ViewName.PickAwardsView,param)
                        else
                            if gRole and not gRole:isDeadState() then
                                mgr.HookMgr:setPickRoleId("0") 
                                gRole:idleBehaviour()
                            end
                        end
                    end
                else
                    local obj = mgr.ThingMgr:getObj(ThingType.monster, data.mRoleId)
                    if obj then
                        local view = mgr.ViewMgr:get(ViewName.PickAwardsView)
                        if view then
                            if obj:getKind() == MonsterKind.sjchest then--跨服三界争霸的箱子
                                mgr.TimerMgr:addTimer(1,1,function()--延迟发送 避免和服务器时间对不上
                                    proxy.KuaFuProxy:sendMsg(1810501,{roleId = data.mRoleId,reqType=2})
                                end)
                                view:closeView()
                            end
                        end
                        if obj:getKind() == MonsterKind.collection or obj:getKind() == MonsterKind.crystal then--采集物
                            if gRole:isDeadState() then
                                CClearPickView()
                                GCancelPick()
                            end
                        end
                    end
                end
            end)
        else
            local player = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
            if player then
                player:collect(function(state)
                end)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ThingProxy:add8020116(data)
    -- body
    if data.status == 0 then
        --更新对应组件v
        --printt("add8020116",data)
        for k ,v in pairs(data.widgets) do
            local monster = mgr.ThingMgr:getObj(ThingType.monster, v.roleId)
            if monster then
                monster:updateData(v)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ThingProxy:add8040206( data )
    -- body
    if data.status == 0 then
        --取消采集动作
        local player = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
        if player then
            player:idleBehaviour()
        end
    else
        GComErrorMsg(data.status)
    end
end

function ThingProxy:closeView()
    mgr.ViewMgr:closeAllView2()

    --仙盟圣火特殊
    local view = mgr.ViewMgr:get(ViewName.FlameView)
    if view then
        view:closeView()
    end
    -- local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
    -- if view then
    --     view:closeView()
    -- end
    -- local view = mgr.ViewMgr:get(ViewName.BossView)
    -- if view then
    --     view:closeView()
    -- end
   
end

return ThingProxy