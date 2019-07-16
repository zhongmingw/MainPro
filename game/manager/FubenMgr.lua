--
-- Author: ohf
-- Date: 2017-05-02 16:25:16
--
--副本管理器（普通副本，boss，战场）
local FubenMgr = class("FubenMgr")

function FubenMgr:ctor()
    self.isQuit = true
    self.sceneId = 0--要进入的场景
    self.diffId = 1
end
--pid 拓展参数 单人守塔扫荡传递0
function FubenMgr:gotoFubenWar(sceneId,pid)
    if self:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    --需要离开队伍
    if self:isKuaFuWar(sceneId) then
        self:gotoFubenWar2(sceneId)
        return
    end
    --仙盟驻地提示退出当前场景
    -- print("仙盟驻地",self:isFlameScene(cache.PlayerCache:getSId()),cache.PlayerCache:getSId())
    if self:isFlameScene(cache.PlayerCache:getSId()) then
        GComAlter(language.gonggong41)
        return
    end
    self.sceneId = sceneId
    local sceneConfig = conf.SceneConf:getSceneById(sceneId)
    local lvl = sceneConfig and sceneConfig.lvl or 1
    local playLv = cache.PlayerCache:getRoleLevel()
    if playLv >= lvl then
        print("请求进入场景>>>>>>")
        proxy.ThingProxy:sChangeScene(sceneId,0,0,3,pid or 1)
    else
        GComAlter(string.format(language.gonggong07, lvl))
    end
end
--进入副本2
function FubenMgr:gotoFubenWar2(sceneId)
    if self:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    --仙盟驻地提示退出当前场景
    if self:isFlameScene(cache.PlayerCache:getSId()) then
        GComAlter(language.gonggong41)
        return
    end
    self.sceneId = sceneId
    local sceneConfig = conf.SceneConf:getSceneById(sceneId)
    local lvl = sceneConfig and sceneConfig.lvl or 1
    local playLv = cache.PlayerCache:getRoleLevel()
    if playLv >= lvl then
        if mgr.FubenMgr:isTaiGuXuanJing(sceneId) then
            local serverId = cache.TaiGuXuanJingCache:getagentServerId()
            proxy.ThingProxy:sChangeScene(sceneId,0,0,3,serverId)
        else
            proxy.ThingProxy:sChangeScene(sceneId,0,0,3,1)
        end
    else
        GComAlter(string.format(language.gonggong07, lvl))
    end
    -- local func = function()
    --     local sceneConfig = conf.SceneConf:getSceneById(sceneId)
    --     local lvl = sceneConfig and sceneConfig.lvl or 1
    --     local playLv = cache.PlayerCache:getRoleLevel()
    --     if playLv >= lvl then
    --         proxy.ThingProxy:sChangeScene(sceneId,0,0,3,1)
    --     else
    --         GComAlter(string.format(language.gonggong07, lvl))
    --     end
    -- end
    -- if self:checkSingleScene(sceneId) and cache.TeamCache:getTeamId() > 0 then
    --     local text = language.team25
    --     local param = {type = 14,richtext = mgr.TextMgr:getTextColorStr(text, 6),sure = function()
    --         proxy.TeamProxy:send(1300107)
    --         func()
    --     end}
    --     GComAlter(param)
    -- else
    --     func()
    -- end
end
--判断是否是对应场景
function FubenMgr:getJudeWarScene(sId,kindType)
    if sId then
        local sConf = conf.SceneConf:getSceneById(sId)
        local kind = sConf and sConf.kind or 0
        if kind == kindType then
            return true
        end
    end
    return false
end
--是否进入了副本
function FubenMgr:isFuben(sId)
    if self:isExpFuben(sId) 
        or self:isCopperFuben(sId) 
        or self:isPlotFuben(sId)
        or self:isTower(sId) 
        or self:isVipFuben(sId)
        or self:isJinjie(sId) 
        or self:isGangFuben(sId) 
        or self:isJuqingFuben(sId)
        or self:isMainTaskFuben(sId) 
        or self:isZhiXianTaskFuben(sId)
        or self:isDayTaskFuben(sId)--副本
        or self:isRuneTower(sId)
        or self:isYuanDanTanSuo(sId)
        or self:isShengXiao(sId) then--元旦探索
            return true
    end
end
--是否是boss副本
function FubenMgr:isBossFuben(sId)
    if sId >= BossScene.personal and sId < (BossScene.personal + PassLimit) then
        return true
    end 
    return false
end
--是否是精英boss副本
function FubenMgr:isEliteBoss(sId)
    return self:getJudeWarScene(sId,SceneKind.eliteBoss)
end
--是否是世界boss副本
function FubenMgr:isWorldBoss(sId)
    return self:getJudeWarScene(sId,SceneKind.worldBoss)
end
--是否是练级谷
function FubenMgr:isLevel(sId)
    return self:getJudeWarScene(sId,SceneKind.lianjigu)
end
--是否是问鼎之战
function FubenMgr:isWenDing(sId)
    return self:getJudeWarScene(sId,SceneKind.wending)
end
--是否是仙盟战
function FubenMgr:isGangWar(sId)
    return self:getJudeWarScene(sId,SceneKind.gangWar)
end
--是否是雪地
function FubenMgr:isXdzzWar(sId)
    return self:getJudeWarScene(sId,SceneKind.xdzz)
end
--是否是灯谜
function FubenMgr:isCdmhWar(sId)
    return self:getJudeWarScene(sId,SceneKind.lantern)
end
--是否是仙域灵塔
function FubenMgr:isXianyu(sId)
    if sId >= Fuben.xianyulingta and sId < (Fuben.xianyulingta + PassLimit) then
        return true
    end 
    return false
end
---------------------------普通副本的特殊判断（因为类型都是3）--------------
function FubenMgr:isDayTaskFuben(sId )
    -- body
    if sId >= Fuben.dayTask and sId < (Fuben.dayTask + PassLimit) then
        return true
    end 
    return false
end

--是否是进阶副本--
function FubenMgr:isJinjie(sId)
    if sId >= Fuben.advaned and sId < (Fuben.advaned + PassLimit) then
        return true
    end 
    return false
end
--是否是爬塔副本
function FubenMgr:isTower(sId)
    if sId >= Fuben.tower and sId < (Fuben.tower + PassLimit) then
        return true
    end 
    return false
end
--是否是vip副本--
function FubenMgr:isVipFuben(sId)
    if sId >= Fuben.vip and sId < (Fuben.vip + PassLimit) then
        return true
    end 
    return false
end
--是否是经验副本--
function FubenMgr:isExpFuben(sId)
    if sId >= Fuben.exp and sId < (Fuben.exp + PassLimit) then
        return true
    end
    return false 
end
--是否是剧情副本--
function FubenMgr:isPlotFuben(sId)
    if sId >= Fuben.plot and sId < (Fuben.plot + PassLimit) then
        return true
    end 
    return false
end
--是否是帮派副本
function FubenMgr:isGangFuben(sId)
    if sId >= Fuben.gang and sId < (Fuben.gang + PassLimit) then
        return true
    end 
    return false
end
--是否是特殊剧情副本--
function FubenMgr:isJuqingFuben(sId)
    if sId >= Fuben.juqing and sId < (Fuben.juqing + PassLimit) then
        return true
    end 
    return false
end
-- 是否主线 副本通关
function FubenMgr:isMainTaskFuben(sId) 
    if sId >= Fuben.mainTask and sId < (Fuben.mainTask + PassLimit) then
        return true
    end 
    return false
end
--
function FubenMgr:isZhiXianTaskFuben( sId )
    if sId >= Fuben.zhixianTask and sId < (Fuben.zhixianTask + PassLimit) then
        return true
    end 
    return false
end
--是否铜钱副本
function FubenMgr:isCopperFuben(sId)
    if sId == Fuben.copper then
        return true
    end
    return false
end
--是否符文塔
function FubenMgr:isRuneTower(sId)
    if sId >= Fuben.runetower and sId < (Fuben.runetower + PassLimit) then
        return true
    end 
    return false
end
--是否是元旦探索
function FubenMgr:isYuanDanTanSuo(sId)
    if sId >= Fuben.ydts and sId < (Fuben.ydts + PassLimit) then
        return true
    end 
    return false
end
--是否是生肖试炼
function FubenMgr:isShengXiao(sId)
    if sId >= Fuben.sxsl and sId < (Fuben.sxsl + PassLimit) then
        return true
    end 
    return false
end
--------------------------------------------------------------------
--是否皇陵战
function FubenMgr:isHuangLing(sId)
    return self:getJudeWarScene(sId,SceneKind.huangling)
end
--是否竞技场
function FubenMgr:isArena(sId)
    return self:getJudeWarScene(sId,SceneKind.jingJiChang)
end
--是否是帝王将相挑战
function FubenMgr:isDiWangScene(sId)
    return self:getJudeWarScene(sId,SceneKind.diwang)
end
--是否是遗迹探索
function FubenMgr:isYiJiScene(sId)
    return self:getJudeWarScene(sId,SceneKind.yjts)
end
--是否是跨服精英boss副本
function FubenMgr:isKuaFuBoss(sId)
    return self:getJudeWarScene(sId,SceneKind.kuafueliteBoss)
end
--是否跨服组队副本
function FubenMgr:isKuaFuTeamFuben(sId)
    return self:getJudeWarScene(sId,SceneKind.kuafueZudui)
end

--是否情缘副本
function FubenMgr:isQingYuanFuben(sId)
    return self:getJudeWarScene(sId,SceneKind.qinyuanfuben)
end

--是否是渡劫副本
function FubenMgr:isDujieFuben( sId )
    return self:getJudeWarScene(sId,SceneKind.dujie)
end
--是否是跨服三界争霸
function FubenMgr:isKuaFuWar( sId)
    return self:getJudeWarScene(sId,SceneKind.kuafuwar)
end
--是否是仙魔战
function FubenMgr:isXianMoWar( sId)
    return self:getJudeWarScene(sId,SceneKind.xianmoWar)
end
--是否是剑神殿
function FubenMgr:isAwakenWar(sId)
    return self:getJudeWarScene(sId,SceneKind.awakenBoss)
end
--是否是仙尊boss
function FubenMgr:isXianzunBoss(sId)
    return self:getJudeWarScene(sId,SceneKind.xianzunBoss)
end
--是否是boss之家
function FubenMgr:isBossHome(sId)
    return self:getJudeWarScene(sId,SceneKind.bossHome)
end
--EVE 是否仙盟驻地
function FubenMgr:isFlameScene(sId) 
    return self:getJudeWarScene(sId,SceneKind.XianmengZhudi)
end
--秘境修炼
function FubenMgr:isMjxlScene(sId)
    if sId >= Fuben.mjxl and sId < (Fuben.mjxl + PassLimit) then
        return true
    end 
    return false
end
--幻境镇妖
function FubenMgr:isHjzyScene(sId)
    return self:getJudeWarScene(sId,SceneKind.hjzy)
end

--剑神守护
function FubenMgr:isJianShengshouhu(sId)
    return self:getJudeWarScene(sId,SceneKind.jianshengshouhu)
end
--是否是仙域禁地
function FubenMgr:isXianyuJinDi(sId)
    return self:getJudeWarScene(sId,SceneKind.xianyuBoss) or self:getJudeWarScene(sId,SceneKind.kfxianyuBoss)
end
--是否是跨服仙域禁地
function FubenMgr:isKuafuXianyu(sId)
    return self:getJudeWarScene(sId,SceneKind.kuafuXianyu) or self:getJudeWarScene(sId,SceneKind.kuafuXianyu2)
end
--是否是上古神迹
function FubenMgr:isShangGuShenJi(sId)
    return self:getJudeWarScene(sId,SceneKind.sgsj) or self:getJudeWarScene(sId,SceneKind.kfsgsj)
end
--是否是五行神殿
function FubenMgr:isWuXingShenDian(sId)
    return self:getJudeWarScene(sId,SceneKind.wxsd)
end
--是否是飞升神殿
function FubenMgr:isFsFuben(sId)
    return self:getJudeWarScene(sId,SceneKind.feisheng) or self:getJudeWarScene(sId,SceneKind.feisheng1)
end
--是否是神兽岛
function FubenMgr:isShenShou(sId)
    return self:getJudeWarScene(sId,SceneKind.shenshou) or self:getJudeWarScene(sId,SceneKind.kuafushenshou)
end
--是否是万圣节除魔
function FubenMgr:isWSJChuMo(sId)
    return self:getJudeWarScene(sId,SceneKind.wsjChuMo)
end
--是否是太古玄境
function FubenMgr:isTaiGuXuanJing(sId)
    return self:getJudeWarScene(sId,SceneKind.taiguXuanJing)  or self:getJudeWarScene(sId,SceneKind.taiguXuanJing1)
end
--是否是个人家园
function FubenMgr:isHome(sId)
    -- body
    return self:getJudeWarScene(sId,SceneKind.home)
end
--是否是婚宴
function FubenMgr:isWedding(sId)
    return self:getJudeWarScene(sId,SceneKind.wedding)
end
--是否是魅力沙滩
function FubenMgr:isMeiliBeach( sId)
    -- body
    return self:getJudeWarScene(sId,SceneKind.beach)
end
--是否是单人排位赛
function FubenMgr:isPaiWeiSai(sId)
    return self:getJudeWarScene(sId, SceneKind.rankmatching)
end
--是否是组队排位赛
function FubenMgr:isTeamPaiWeiSai(sId)
    return self:getJudeWarScene(sId, SceneKind.teammatching)
end
--是否是季后排位赛
function FubenMgr:isPlayoffPaiWeiSai(sId)
    return self:getJudeWarScene(sId, SceneKind.playoff)
end
--是否跨服世界boss
function FubenMgr:isKuafuWorld(sId)
    return self:getJudeWarScene(sId, SceneKind.kuafuworld) or self:getJudeWarScene(sId, SceneKind.kfpet)
end
--是否是跨服城战
function FubenMgr:isKuafuCityWar(sId)
    return self:getJudeWarScene(sId, SceneKind.citywar)
end
--是否是仙侣Pk海选赛
function FubenMgr:isXianLvPKhxs(sId)
    return self:getJudeWarScene(sId, SceneKind.xianLvPKhxs)
end
--是否是仙侣pk争霸赛
function FubenMgr:isXianLvPKzbs(sId)
    return self:getJudeWarScene(sId, SceneKind.xianLvPKzbs)
end

--是否是仙侣Pk2海选赛
function FubenMgr:isXianLvPKhxs_2(sId)
    return self:getJudeWarScene(sId, SceneKind.xianLvPKhxs_2)
end
--是否是仙侣pk2争霸赛
function FubenMgr:isXianLvPKzbs_2(sId)
    return self:getJudeWarScene(sId, SceneKind.xianLvPKzbs_2)
end
--是否是天晶洞窟（采集探宝）
function FubenMgr:isCollectTreasure(sId)
    -- body
    return self:getJudeWarScene(sId,SceneKind.collect)
end
--是否是万神殿（五行圣殿）
function FubenMgr:isWanShenDian(sId)
    -- body
    return self:getJudeWarScene(sId,SceneKind.wanshendian) or self:getJudeWarScene(sId,SceneKind.wanshendianCross)
end
--是否是科举答题
function FubenMgr:isKeju(sId)
    -- body
    return self:getJudeWarScene(sId,SceneKind.keju) or self:getJudeWarScene(sId,SceneKind.crosskeju)
end
--是否只有查看选项目
function FubenMgr:isOnlySee()
    -- body
    local sId = cache.PlayerCache:getSId()
    if self:isKuaFuBoss(sId) 
    or self:isKuaFuTeamFuben(sId)  
    or self:isKuaFuWar(sId) then
        return true
    end

    return false

end


--检测是否进入了副本
function FubenMgr:checkFuben(sId)

    self.sceneId = 0
    self.diffId = 1
    -- print("副本id",sId)
    if self:checkScene() then
        GCloseXinshouView()
    end
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:checkMarry()
        view.taskorTeam:setItemMsg()
        --是否需要刷新主界面信息--消息返回 比界面打开快
        if cache.PlayerCache:getReset() then
            view:updateRoleInfo()
            view:refreshRed()
            view:updateBuffs(mgr.BuffMgr.buffIcons)
        end
        if cache.TaskCache:getTaskBack() then
            cache.TaskCache:setTaskBack(false)
            view:checkOpen()
            view:initFuben()
            mgr.XinShouMgr:enterGame()
        end

        if self:isFuben(sId) or self:isBossFuben(sId) then--如果是副本或者个人boss
            self:sendTrack()
            mgr.TaskMgr.mState = 0
        elseif self:isEliteBoss(sId) then--如果是精英boss
            proxy.FubenProxy:send(1330102)
            mgr.HookMgr:enterHook()
            mgr.TaskMgr.mState = 0
        elseif self:isWorldBoss(sId) then--如果是世界boss
            proxy.FubenProxy:send(1330202)
            mgr.TaskMgr.mState = 0
        elseif self:isLevel(sId) then--如果是练级谷
            mgr.TaskMgr.mState = 0
            if not g_ios_test then
                mgr.ViewMgr:openView2(ViewName.LevelTip,{})
            end
            view:setLevelPanel()
        elseif self:isArena(sId) then --如果是竞技场
            mgr.HookMgr:stopHook()--竞技场停止挂机
            local _v = mgr.ViewMgr:get(ViewName.GuideBianSheng)
            if _v then
                _v:closeView()
            end
            mgr.TaskMgr.mState = 0
            view:setInfoArena()
        elseif self:isDiWangScene(sId) then --如果是帝王将相
            mgr.HookMgr:stopHook()--帝王将相停止挂机
            local _v = mgr.ViewMgr:get(ViewName.GuideBianSheng)
            if _v then
                _v:closeView()
            end
            mgr.TaskMgr.mState = 0
            view:setInfoArena()
        elseif self:isYiJiScene(sId) then
            mgr.HookMgr:stopHook()--遗迹探索停止挂机
            local _v = mgr.ViewMgr:get(ViewName.GuideBianSheng)
            if _v then
                _v:closeView()
            end
            mgr.TaskMgr.mState = 0
            view:setInfoArena()
            cache.FubenCache:setFubenModular(1429)
        elseif self:isHuangLing(sId) then--如果是皇陵之战
            proxy.HuanglingProxy:sendMsg(1340102)
            view:setHuanglingTask()
        elseif self:isWenDing(sId) then--如果是问鼎之战
            proxy.WenDingProxy:send(1350103)
        elseif self:isGangWar(sId) then--仙盟战
            proxy.GangWarProxy:send(1360203)
        elseif self:isKuaFuBoss(sId) then
            proxy.KuaFuProxy:sendMsg(1330302)
            mgr.HookMgr:enterHook()
            mgr.TaskMgr.mState = 0
        elseif self:isKuaFuTeamFuben(sId) then
            proxy.KuaFuProxy:sendMsg(1380201) 
            cache.FubenCache:setFubenModular(1093)
        elseif self:isKuaFuWar(sId) then
            proxy.KuaFuProxy:sendMsg(1410102) 
            cache.FubenCache:setFubenModular(1094)
        elseif self:isQingYuanFuben(sId) then
            proxy.MarryProxy:sendMsg(1027105)
            cache.FubenCache:setFubenModular(1099)
        elseif self:isDujieFuben(sId) then--渡劫
            local isCaptain = cache.TeamCache:getIsCaptain(roleId)
            if isCaptain then
                cache.FubenCache:setFubenModular(1067)
            end
            self:sendTrack()
        elseif self:isXianMoWar(sId) then--仙魔战
            proxy.XianMoProxy:send(1420101)
        elseif self:isAwakenWar(sId) then--剑神殿
            proxy.AwakenProxy:send(1430103)
        elseif self:isXianzunBoss(sId) then--仙尊boss
            proxy.FubenProxy:send(1440103)
        elseif self:isBossHome(sId) then--boss之家
            proxy.FubenProxy:send(1450102)
        elseif self:isFlameScene(sId) then--EVE 仙盟驻地
            view:setFlameScene()
        elseif self:isXianyu(sId) then
            local reqType = cache.FubenCache:getXyltReqtype()
            proxy.FubenProxy:send(1027203,{reqType = reqType})
            cache.FubenCache:setXyltReqtype(0)
            --守塔：进入后自动挂机、死亡复活后自动挂机
            mgr.HookMgr:enterHook()
        elseif self:isMjxlScene(sId) then--秘境修炼
            proxy.FubenProxy:send(1027303)
        elseif self:isHjzyScene(sId) then--幻境镇妖
            proxy.FubenProxy:send(1027308)
        elseif self:isJianShengshouhu(sId) then --剑神守护
            proxy.FubenProxy:send(1027404)
            --守塔：进入后自动挂机、死亡复活后自动挂机
            mgr.HookMgr:enterHook()
        elseif self:isXianyuJinDi(sId) then --仙域禁地
            proxy.FubenProxy:send(1330403)
        elseif self:isKuafuXianyu(sId) then
            proxy.FubenProxy:send(1330603)
        elseif self:isShangGuShenJi(sId) then--上古神迹
            proxy.FubenProxy:send(1330803)
        elseif self:isWuXingShenDian(sId) then--五行神殿
            proxy.FubenProxy:send(1330903)
        elseif mgr.FubenMgr:isHome(sId) then --家园系统
            --proxy.HomeProxy:sendMsg(1460103)
            --view:setInfoArena()
            --mgr.ViewMgr:openView2(ViewName.HomeMainView)
            local view = mgr.ViewMgr:get(ViewName.HomeMainView)
            if view then
                view:initData()
            else
                mgr.ViewMgr:openView2(ViewName.HomeMainView)
            end
        elseif self:isWedding(sId) then --婚宴场景
            view:setWeddingScene()
            proxy.MarryProxy:sendMsg(1390309)
        elseif self:isXdzzWar(sId) then--雪地大作战
            mgr.ViewMgr:closeView(ViewName.GuideBianSheng)
            proxy.ActivityWarProxy:send(1470102)
        elseif self:isCdmhWar(sId) then
            print("灯谜答题>>>>>>>>>>>>>>",sId)
            proxy.ActivityWarProxy:send(1030182,{reqType = 1,answer = 0})
        elseif self:isMeiliBeach(sId) then
            --魅力沙滩
            local view = mgr.ViewMgr:get(ViewName.BeachMainView)
            if view then
                view:initData()
            else
                mgr.ViewMgr:openView2(ViewName.BeachMainView)
            end
        elseif self:isPaiWeiSai(sId) or self:isTeamPaiWeiSai(sId) or self:isPlayoffPaiWeiSai(sId) then--排位赛
            G_SetMainView(false)
            mgr.FightMgr:clear()
            if self:isPaiWeiSai(sId) then
                -- print("进入副本后请求单人排位场景信息")
                proxy.QualifierProxy:sendMsg(1480107)
                cache.PwsCache:setPwsType(1)
            elseif self:isTeamPaiWeiSai(sId) then
                cache.PwsCache:setMyHp(1)
                -- print("进入副本后请求组队排位场景信息")
                proxy.QualifierProxy:sendMsg(1480213)
                cache.PwsCache:setPwsType(2)
            elseif self:isPlayoffPaiWeiSai(sId) then
                cache.PwsCache:setMyHp(1)
                -- print("进入副本后请求季后赛排位场景信息")
                proxy.QualifierProxy:sendMsg(1480302)
                cache.PwsCache:setPwsType(3)
            end
            cache.FubenCache:setFubenModular(1169)
        elseif self:isKuafuWorld(sId) then
            proxy.FubenProxy:send(1330502)
        elseif self:isKuafuCityWar(sId) then
            proxy.CityWarProxy:sendMsg(1510104)
        elseif self:isXianLvPKhxs(sId) or self:isXianLvPKzbs(sId) then--仙侣pk
            G_SetMainView(false)
            mgr.FightMgr:clear()
            cache.XianLvCache:setMyHp(1)
            -- print("仙侣pk场景id",sId)
            if self:isXianLvPKhxs(sId) then
                proxy.XianLvProxy:sendMsg(1540109)
            elseif self:isXianLvPKzbs(sId) then
                proxy.XianLvProxy:sendMsg(1540111)
                -- print("请求争霸赛场景信息")
            end
            cache.FubenCache:setFubenModular(1280)
        elseif self:isXianLvPKhxs_2(sId) or self:isXianLvPKzbs_2(sId) then--仙侣pk2全服
            G_SetMainView(false)
            mgr.FightMgr:clear()
            cache.XianLvCache:setMyHp(1)
            if self:isXianLvPKhxs_2(sId) then
                proxy.XianLvProxy:sendMsg(1540209)
            elseif self:isXianLvPKzbs_2(sId) then
                proxy.XianLvProxy:sendMsg(1540211)
            end
            cache.FubenCache:setFubenModular(1351)
        elseif self:isCollectTreasure(sId) then--天晶洞窟采集活动
            G_SetMainView(false)
            proxy.FubenProxy:send(1028101)
        elseif mgr.FubenMgr:isFsFuben(sId) then
            G_SetMainView(false)
            proxy.FubenProxy:send(1331103)
        elseif self:isShenShou(sId) then--神兽岛
            G_SetMainView(false)
            proxy.FubenProxy:send(1331203)
        elseif self:isWanShenDian(sId) then--万神殿（五行圣殿）
            G_SetMainView(false)
            proxy.WanShenDianProxy:send(1331302)
        elseif self:getJudeWarScene(sId,SceneKind.shenshoushengyu) then
            G_SetMainView(false)
            proxy.FubenProxy:send(1331402)
        elseif self:isWSJChuMo(sId) then--万圣节除魔
            G_SetMainView(false)
            proxy.WSJProxy:send(1028201)
        elseif self:isTaiGuXuanJing(sId) then--太古玄境
            G_SetMainView(false)
            local severId = cache.TaiGuXuanJingCache:getagentServerId()
            print("服務器id~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",severId)
            proxy.TaiGuXuanJingProxy:send(1331502,{agentServerId = severId})    
        elseif self:isKeju(sId) then--科举答题
            print("科举答题>>>>>>>>>>>>>>",sId)
            proxy.ActivityProxy:send(1030658,{reqType = 1,answer = 0})
        else--如果不是战斗场景
            mgr.ViewMgr:closeView(ViewName.WarSkillView)
            mgr.QualityMgr:setShieldAllPets(true)
            if gRole then
                gRole:setData(gRole.data)
                gRole:clearComponents()
                local pet = mgr.ThingMgr:getObj(ThingType.pet, gRole:getID())
                if pet then
                    pet:updtePetName()
                    pet:setVisible(true)
                end
            end
            cache.FubenCache:setChooseBossId(0)
            mgr.ViewMgr:closeView(ViewName.MiniMapView)
            mgr.ViewMgr:closeView(ViewName.LanternDtView)
            mgr.ViewMgr:closeView(ViewName.DaTiView)
            GCloseBossHpView()
            if cache.TaskCache:isFubenTask() then--检测当前任务是不是副本任务
            --if mgr.TaskMgr:isFubenTask() then
                if not mgr.TaskMgr:checkTaskType4() then
                --if cache.TaskCache:CheckTaskID(1089)  then--并且有引导穿戴装备 不要回复界面
                        cache.FubenCache:setFubenModular(nil) 
                    --end
                end
            end
            local xianmoView = mgr.ViewMgr:get(ViewName.XianMoFightView)
            if xianmoView then
                xianmoView:closeView()
            end
            local xianmoView = mgr.ViewMgr:get(ViewName.HomeMainView)
            if xianmoView then
                xianmoView:closeView()
            end
            --渡劫界面关闭发送拒绝请求
            local dujieView = mgr.ViewMgr:get(ViewName.DujieView)
            -- print("关闭渡劫界面222",dujieView)
            if dujieView then
                dujieView:onCloseView()
            end
            local pwsView = mgr.ViewMgr:get(ViewName.RankProceedView)
            if pwsView then
                pwsView:closeView()
            end
            local xianlvView = mgr.ViewMgr:get(ViewName.XianLvPKProceedView)
            if xianlvView then
                xianlvView:closeView()
            end
            mgr.ViewMgr:closeAllView2()--关闭一切多余的窗口
            view:recoveryMain()--恢复主界面
            --副本退出后回到副本界面
            local modular = cache.FubenCache:getFubenModular()
            if modular then
               -- plog(cache.GuideCache:getGuide(),"cache.GuideCache:getGuide()")
                if modular == 1046 then --是竞技场检测是否需要引导
                    cache.GuideCache:setGuide(nil)
                    local isArenaFight = cache.ArenaCache:getIsAreanFight()
                    if isArenaFight then --竞技场进入的战斗
                        if cache.ArenaCache:getGuide() then
                            cache.GuideCache:setData(conf.XinShouConf:getOpenModule(1071))
                            cache.ArenaCache:setGuide(nil)
                        end
                        GOpenView({id = modular})
                    else             --离线挂机进入的战斗
                        GOpenView({id = 1076,childIndex = 2})
                    end
                elseif modular == 1280 then--仙侣pk
                    mgr.ViewMgr:openView(ViewName.XianLvPKMainView,function ()
                        proxy.XianLvProxy:sendMsg(1540101,{reqType = 0})
                    end,{index = 2})
                elseif modular == 1351 then--仙侣pk(全服)
                    mgr.ViewMgr:openView(ViewName.XianLvPKMainView,function ()
                        proxy.XianLvProxy:sendMsg(1540201,{reqType = 0})
                    end,{index = 2})
                elseif modular == 1429 then--遗迹探索
                    local cityId = cache.YiJiTanSuoCache:getCityId()
                    mgr.ViewMgr:openView2(ViewName.YiJiCityInfoView, {cityId = cityId})
                elseif modular == 1448 then--生肖试炼
                    GOpenView({id = 1448})
                else
                    local pwsType = cache.PwsCache:getPwsType()
                    
                    if cache.GuideCache:getGuide() and modular == 1023  then
                    else
                        if modular == 1169 then
                            if pwsType == 1 then
                                GOpenView({id = modular,childIndex = 0})
                            elseif pwsType == 2 then
                                GOpenView({id = modular,childIndex = 1})
                            else
                                GOpenView({id = modular,childIndex = 2})
                            end
                        else
                            GOpenView({id = modular})
                        end
                    end
                    if modular == 1169 then--排位赛退出显示升降级界面
                        local soloData = cache.PwsCache:getSoloOverData()
                        local teamData = cache.PwsCache:getTeamOverData()
                        if pwsType == 1 then
                            -- printt("单人结算",soloData)
                            mgr.ViewMgr:openView2(ViewName.PwsOverView,soloData)
                        elseif pwsType == 2 then
                            -- printt("组队结算",teamData)
                            -- print("组队结算")
                            -- for k,v in pairs(teamData) do
                            --     print(k,v)
                            -- end
                            mgr.ViewMgr:openView2(ViewName.PwsOverView,teamData)
                        end
                    end
                    cache.GuideCache:setGuide(nil)
                end
                cache.FubenCache:setFubenModular(nil)
            else
                if cache.GuideCache:getGuide() then
                    cache.GuideCache:setGuide(nil)
                end
            end
            
            --检测变身
            mgr.XinShouMgr:newBianshen(false)
            self:checkItems()

            if view and view.taskorTeam then
                view.taskorTeam.c2.selectedIndex = 0
            end
            --前往结婚打开界面
            if cache.PlayerCache:getAttribute(10321) > 0 then
                cache.PlayerCache:setAttribute(10321,0)
                if cache.PlayerCache.marryTime ~=0 and mgr.NetMgr:getServerTime() - cache.PlayerCache.marryTime < 10 then
                    cache.PlayerCache.marryTime = 0
                    --mgr.ViewMgr:closeAllView2()
                    mgr.ViewMgr:openView2(ViewName.MarryNpcView)
                end
            end
        end
    end
end

function FubenMgr:sendTrack()

    proxy.FubenProxy:send(1024103)
end
--退出副本 isGuide--是否有引导退出动作--
function FubenMgr:quitFuben(isGuide,quitData)
    --成就id列表清空
    local view = mgr.ViewMgr:get(ViewName.AchieveGetItem)
    if view then
        view:refreshIdList()
    end
    local trackView = mgr.ViewMgr:get(ViewName.TrackView)
    if trackView then
        trackView:hidePanel()
    end
    local view = mgr.ViewMgr:get(ViewName.TjdkTrackView)
    if view then
        view:closeView()
    end
    local view = mgr.ViewMgr:get(ViewName.FlameView)
    if view then
        view:closeView()
    end
    if not self:checkScene() then return end
    CClearPickView()
    GCancelPick()
    CClearRankView()
    if gRole then
        --采集结束
        gRole:idleBehaviour()
        gRole:stopAI()
        mgr.HookMgr:cancelHook()
    end
    local speed = 0.6
    if not self.isQuit then return end
    local quitSId = cache.PlayerCache:getSId()
    local quitFunc = function()
        self.isQuit = true
        --收起任务显示
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view and view.taskorTeam then
            view.taskorTeam.c2.selectedIndex = 1
        end
        --离开副本的时候飞一下
        -- gRole:flyUp(function()
        -- end) 
        mgr.TimerMgr:addTimer(0.25, 1, function()
            GCloseBossHpView()
            local view = mgr.ViewMgr:get(ViewName.FlagHoldView)
            if view then
                view:closeView()
            end 
            local view = mgr.ViewMgr:get(ViewName.XianMoFightView)
            if view then
                view:closeView()
            end
            proxy.FubenProxy:send(1020103,{sceneId = quitSId})
        end)
        if self:isJuqingFuben(quitSId) or self:isMainTaskFuben(quitSId) then
            print("离开副本是不要继续任务")
            cache.GuideCache:setNotGoon(false)
        else
            cache.GuideCache:setNotGoon(true)
        end
        
    end

    --npc退出
    local npcs = cache.FubenCache:getGuideNpcs()
    if #npcs > 0 then
        mgr.TimerMgr:addTimer(0.5, 1, function( ... )
            for k,roleId in pairs(npcs) do
                mgr.ThingMgr:removeGuideNpc(roleId)
            end
            cache.FubenCache:clearGuideNpcs()
            mgr.TimerMgr:addTimer(1, 1, function( ... )
                if isGuide then
                    if self:isExpFuben(quitSId) then
                        mgr.ViewMgr:openView(ViewName.FubenDekaronView, function(view)
                            view:setData(quitData)
                        end,{})
                        self.isQuit = true
                    elseif self:isTower(quitSId) then
                        local chest = cache.FubenCache:getTowerChest()
                        if chest then
                            gRole:moveToPoint(chest:getPosition(), 0, function()
                                gRole:collect(function(state)
                                    local param = {}
                                    param.func = function()--拾取完成要弹出恭喜获得
                                        mgr.ViewMgr:openView(ViewName.FubenDekaronView, function(view)
                                            view:setData(quitData)
                                        end,{})
                                        self.isQuit = true
                                        chest:dead2()
                                        cache.FubenCache:setTowerChest(nil)
                                    end
                                    mgr.ViewMgr:openView2(ViewName.PickAwardsView,param)
                                end)
                            end)
                        end
                    end
                else

                    quitFunc()
                end
            end)
        end)
    else
        mgr.TimerMgr:addTimer(speed, 1, function( ... )
            quitFunc()
        end)
    end
    self.isQuit = false
end


--场景检测（是否战斗场景）
function FubenMgr:checkScene()
    local sId = cache.PlayerCache:getSId()
    if not sId then
        return false
    end
    local sConf = conf.SceneConf:getSceneById(sId)
    local kind = sConf and sConf.kind or 0
    if kind == SceneKind.mainCity or kind == SceneKind.field 
        or kind == SceneKind.xinshou or kind == SceneKind.XianmengZhudi then
        return false
    end
    return true
end
--场景检测2（是否非练级谷的战斗场景）
function FubenMgr:checkScene2()
    local sId = cache.PlayerCache:getSId()
    local sConf = conf.SceneConf:getSceneById(sId)
    local kind = sConf and sConf.kind or 0
    if kind == SceneKind.mainCity or kind == SceneKind.field or kind == SceneKind.xinshou or kind == SceneKind.lianjigu then
        return false
    end
    return true
end
--是否是 主城 野外 或者 新手
function FubenMgr:checkScen3()
    -- body
    local sId = cache.PlayerCache:getSId()
    local sConf = conf.SceneConf:getSceneById(sId)
    local kind = sConf and sConf.kind or 0
    if kind == SceneKind.mainCity or kind == SceneKind.field 
        or kind == SceneKind.xinshou  then
        return true
    end
    return false
end
--单人玩法不可以组队的战斗场景
function FubenMgr:checkSingleScene(sId)
    if sId and type(sId) == "number" then
        local sConf = conf.SceneConf:getSceneById(sId)
        local teamEnable = sConf and sConf.team_enable or 0
        if teamEnable == 0 then
            return true
        end
    end
    return false
end

function FubenMgr:checkItems()
    local items = cache.FubenCache:getChangeItems()--检测有没有在副本之类的场景获得道具
    if items and #items > 0 then
        for k,v in pairs(items) do
            local data = cache.PackCache:getPackDataById(v.mid)
            if data and data.amount > 0 then
                mgr.ItemMgr:checkPros(v)
            end
        end
        cache.FubenCache:cleanChangeItems()
    end
    local equips = cache.FubenCache:getChangeEquips()--检测有没有在副本之类的场景获得装备
    if equips and #equips > 0 then
        mgr.ItemMgr:checkEquips(equips)
        cache.FubenCache:cleanChangeEquips()
    end
    if not mgr.ViewMgr:get(ViewName.SQuickUseView) and not self:checkScene(cache.PlayerCache:getSId()) then
        mgr.ItemMgr:checkSPros()
    end
    local skins = cache.FubenCache:getObtainSkins()--检测有没有在副本之类的场景获得外观
    if skins and not g_ios_test then   --EVE 屏蔽小弹窗
        mgr.ViewMgr:openView(ViewName.SkinTipsView, function(view)
            view:setFubenSkins(skins)
        end)
        cache.FubenCache:cleanObtainSkins()
    end
end

function FubenMgr:getSIdModular(sId)
    local modular = sId
    --plog("模块场景",modular,sId)
    if type(sId) == "number" then
        if self:isPlotFuben(sId) then--剧情副本
            modular = Fuben.plot--剧情副本代表场景
        elseif self:isVipFuben(sId) then--vip副本
            modular = Fuben.vip--vip副本代表场景
        elseif self:isTower(sId) then--爬塔副本
            modular = Fuben.tower
        elseif self:isBossFuben(sId) then--个人boss
            modular = BossScene.personal
        elseif self:isLevel(sId) then--练级谷
            modular = Fuben.level
        elseif self:isJinjie(sId) then--进阶副本
            modular = Fuben.advaned--进阶副本代表场景
        elseif self:isExpFuben(sId) then--经验副本
            modular = Fuben.exp
        elseif self:isCopperFuben(sId) then--铜钱副本
            modular = Fuben.copper
        elseif self:isDujieFuben(sId) then
            modular = Fuben.dujie     
        elseif self:isRuneTower(sId) then--符文塔
            modular = Fuben.runetower        
        elseif self:isYuanDanTanSuo(sId) then--元旦探索
            modular = Fuben.ydts    
        elseif self:isShengXiao(sId) then--生肖试炼
            modular = Fuben.sxsl    
        end
    end
    return modular
end
--副本攻打提示
function FubenMgr:openWarTip(fubenCanList)
    if g_is_banshu then
        return
    end
    if not cache.TaskCache:isfinish(TaskId) then 
        cache.PackCache:cleanAdvPros()
        return 
    end
    local list = {}
    local notTipList = cache.FubenCache:getNotTipFubens()
    for k,v in pairs(fubenCanList) do
        local sceneId = tonumber(string.sub(v,1,6))
        local sId = self:getSIdModular(sceneId)
        local notScene = notTipList[sId]
        local mod = language.fuben13[sId]
        if mgr.ModuleMgr:CheckView(mod) and not notScene then
            table.insert(list, v)
        end
    end
    if self:checkScene() then return end
    local view = mgr.ViewMgr:get(ViewName.FubenTipView)
    if view then
        view:setData(list)
    elseif not g_ios_test then  --EVE ios版属屏蔽
        -- mgr.ViewMgr:openView2(ViewName.FubenTipView,list)
    end
end

--是否在可以打坐的场景
function FubenMgr:isSitDownSid()
    -- body
    local confdata = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    if confdata.kind ~= SceneKind.mainCity 
    and confdata.kind ~= SceneKind.field 
    and confdata.kind ~= SceneKind.xinshou  then
        return false
    end

    return true
end
--是否处于跨服场景
function FubenMgr:isInKuaFuSid()
    -- body
    local sId = cache.PlayerCache:getSId()
    if self:isKuaFuBoss(sId) then
        return true
    end

    return false
end

function FubenMgr:endWar()
    local view = mgr.ViewMgr:get(ViewName.TrackView)
    if view then
        view:clear()
    end
end

return FubenMgr