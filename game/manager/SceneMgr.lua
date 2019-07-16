--[[--
场景管理
]]
local SceneMgr = class("SceneMgr")

function SceneMgr:ctor()
    --注册方法--------------------------------------
    UnitySceneMgr:RegisterMapLuaFunc(function(step, rate)
        self:onMapLoadProgress(step, rate)
    end)
    UnitySceneMgr:RegisterSceneLuaFunc(function(rate)
        self:onLoadSuccess(rate)
    end)
    ------------------------------------------------

    self.curLoadScene = nil
    self.mapId = 0
    self.curSceneName = nil
    self.firstFlag = true
    self.firstFlag2 = true --用于新活动提示bxp
end

function SceneMgr:getCurScene()
    return self.curSceneName
end


--加载场景
function SceneMgr:loadScene(sceneName)
    if self.curLoadScene then return end  --如果正在加载场景
    self.curLoadScene = sceneName
    unity.changeScene(sceneName)
end

--场景切换完成
function SceneMgr:onLoadSuccess()
    --1、进入更新界面，首次资源的拷贝和检查更新
    --2、更新完毕进入登陆界面
    --3、如果是 
        --新号先进入新手战斗再进入创建角色和性别后进入游戏
        --旧号则直接进入游戏
    --self:enterMainScene()
    if self.curLoadScene == SceneRes.LOGIN_SCENE then
        self:enterLoginScene()
        self.curSceneName = SceneRes.LOGIN_SCENE
        --UnityCamera:CameraEctSwitch(false)
    elseif self.curLoadScene == SceneRes.MAIN_SCENE then
        self:enterMainScene()
        self.curSceneName = SceneRes.MAIN_SCENE
    end
    self.curLoadScene = nil
    
end

function SceneMgr:onMapLoadProgress(step, rate)
    if step == "mapimg" then  --06-地图图片加载中......
        local view = mgr.ViewMgr:get(ViewName.LoadingView)
        if view then
            view:setProgress(rate)
        end
        if rate == 1 then
            if view then view:closeView() end
            if self.firstFlag then
                self:onMapImgLoadComplete()
            end
        end
    elseif step == "mapdata" then  --03-地图数据加载完成
        print("@地图数据加载完毕")
        if g_var.gameFrameworkVersion < 12 then
            self:onMapDataLoadComplete()
            UnitySceneMgr:LateGC()
            if not self.firstFlag then
                self:onMapImgLoadComplete()
            end
        end
    elseif step == "smallmap" then
        print("@小地图加载完毕")
        self:onMapDataLoadComplete()
        UnitySceneMgr:LateGC()
        if not self.firstFlag then
            self:onMapImgLoadComplete()
        end
    end
end

--进入登录场景
function SceneMgr:enterLoginScene()
    mgr.ViewMgr:init()
    mgr.ViewMgr:openView(ViewName.LoginView)
    mgr.SoundMgr:setMusicVolume(mgr.SoundMgr:getMusicVolume())
    mgr.SoundMgr:playBgMusic("yewai_chuanghao")
    mgr.SoundMgr:setMusicEnable(mgr.SoundMgr:getMusicEnable())
    mgr.SoundMgr:setSoundVolume(mgr.SoundMgr:getSoundVolume())
    mgr.SoundMgr:setSoundEnable(mgr.SoundMgr:getSoundEnable())
end

--进入主场景
function SceneMgr:enterMainScene()
    local log = UPlayerPrefs.GetInt("debug_log_view")
    if log == 1 then
        if g_var.gameFrameworkVersion < 12 then
            GameUtil.ExtendFunc(1001)
        else
            GameUtil.ExtendFunc(1001,"")
        end
    end
    self:clearLoginRes()
    --01-初始化主场景/显示主界面UI
    UnitySceneMgr:EnterMainScene()
    --02-加载角色场景
    local sId = cache.PlayerCache:getSId()
    local mapModuleId = cache.PlayerCache:getMapModelId()
    self:changeMap(sId,mapModuleId)
end

--清理登录界面和更新界面遗留下来的资源
function SceneMgr:clearLoginRes()
    if UIPackage.GetByName("update") then
        UIPackage.RemovePackage("update") --清理更新资源
    end
    if UIPackage.GetByName("update2") then
        UIPackage.RemovePackage("update2") --清理更新资源
    end
    --此资源有预加载需要卸载两次
    UnityResMgr:UnloadAssetBundle("res/bgs/login/login_"..g_var.packId, true)
    UnityResMgr:UnloadAssetBundle("res/bgs/login/login_"..g_var.packId, true)
    UnityResMgr:UnloadAssetBundle("res/bgs/login/logo_"..g_var.packId, true)
end

--=========================开放接口均在此处=====================================
-- 01-通知服务端切换场景-proxy.ThingProxy:sChangeScene(sId, x, y, t)
-- 切换地图--登录/服务端返回
-- 
function SceneMgr:changeMap(sId, mapModuleId, x, y)
  
    plog("切换地图",sId, mapModuleId, x, y)
    if sId == 0 then
        plog("sId",sId)
        GComAlter(language.map03)
        return
    end
    self.lastSid = cache.PlayerCache:getSId()
    cache.PlayerCache:updatePosition(x, y)
    cache.PlayerCache:setSId(sId)
    cache.PlayerCache:setMapModelId(mapModuleId)
    local mapConf = conf.SceneConf:getSceneById(sId)
    if not mapConf then
        plog("@策划：场景不存在", sId)
        return
    end
    local mapId = mapModuleId
    if not mapModuleId or mapModuleId and mapModuleId <= 0 then
        mapId = mapConf["map_id"]
    end
    --上一场景的需要特别的操作
    self:retSetLastScene()
    --清理工作
    mgr.ThingMgr:dispose()
    if self.mapId ~= 0 and self.mapId == mapModuleId then
        self.mapId = mapId
        self:onMapDataLoadComplete()
        self:onMapImgLoadComplete()
        return
    end
    

    --当前地图id
    self.mapId = mapId
    --弹出加载页，加载页中处理加载地图等各种清理
    function handlerInLoad()
        UnitySceneMgr.isInitMain = false
        --清理地图数据
        UnitySceneMgr:ChangeMap(mapId)
        --清理ui
        mgr.ViewMgr:clearCache(true)
        --清理怪物缓存 / 清理npc缓存
        cache.ResCache:clear()
        if self.lastSid then
            local lastMapConf = conf.SceneConf:getSceneById(self.lastSid)
            if lastMapConf then
                local npcs = lastMapConf["npc"]
                if npcs then
                    for i=1, #npcs do
                        local npcConf = conf.NpcConf:getNpcById(npcs[i])
                        local res = ResPath.npcRes(npcConf["body_id"])
                        if g_var.gameFrameworkVersion >= 2 then
                            UnitySceneMgr:ClearMonsterPool(res, false, false)
                        else
                            UnitySceneMgr:ClearMonsterPool(res, true, false)
                        end
                    end
                end
            end
        end

        --清理对象池 10分钟没有使用过的 10*60
        if g_var.gameFrameworkVersion >= 2 then
            UPoolMgr:DelUnUsedPoolObject(600, false)
        end 
        if g_var.gameFrameworkVersion >= 9 and g_var.platform == "ios" then
            UPoolMgr:Dispose()
            UnityResMgr:Dispose(false)
        end

        collectgarbage("collect")
        mgr.QualityMgr:updateGCTime()   --更新一下时间。没有必要再gc一次

        --预加载资源
        if g_need_preload then
            print("@启动了预加载特效")
            for k, v in pairs(PreLoadEct) do
                mgr.EffectMgr:preLoadEffect(v, false)
            end
            self:preloadSkill()
            g_need_preload = false
        end

        --手动gc
        --UnitySceneMgr:LateGC()
    end

    --开始加载地图
    if self.firstFlag then
        mgr.ViewMgr:openView(ViewName.LoadingView, function()
            mgr.TimerMgr:addTimer(0.1, 1, function()
                handlerInLoad()
            end)
        end)
    else
        if self.lastSid.."" ~= "204001" then
            local funFunc = function()
                gRole:flyUp(function() end)
                mgr.TimerMgr:addTimer(0.3, 1, function()
                    gRole:setVisible(false)
                    handlerInLoad()
                end)
            end

            if g_var.gameFrameworkVersion >= 12 then
                funFunc()
            else
                if not mgr.FubenMgr:isWenDing(sId) and not mgr.FubenMgr:isXianMoWar(sId) and not mgr.FubenMgr:isWenDing(self.lastSid) and not mgr.FubenMgr:isXianMoWar(self.lastSid) then
                    funFunc()
                else
                    handlerInLoad()
                end
            end
        else
            handlerInLoad()
        end
    end
end

function SceneMgr:retSetLastScene()
    -- body
    if not mgr.FubenMgr:isHome(cache.PlayerCache:getSId()) then
        local view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if view then
            view:closeView()
        end
    end
    if not mgr.FubenMgr:isMeiliBeach(cache.PlayerCache:getSId()) then
        local view = mgr.ViewMgr:get(ViewName.BeachMainView)
        if view then
            view:closeView()
        end
    end
    
    if mgr.FubenMgr:isHome(self.lastSid) then
        if gRole then
            gRole:setHome()
        end
    -- elseif mgr.FubenMgr:isDayTaskFuben(self.lastSid) then
    --     --print("上一场景是日常副本")
    --     local data = cache.TaskCache:getdailyTasks()
    --     if data then
    --         if data[1].taskStatu == 1 or data[1].taskStatu ==0 then
    --             local condata = conf.TaskConf:getTaskById(data[1].taskId)
    --             if condata.task_type == 4 then
    --                 mgr.TaskMgr:isfinish(condata)
    --             end
    --         end
    --     end
    elseif mgr.FubenMgr:isMeiliBeach(self.lastSid) then
        if gRole then
            gRole:setHome()
        end
    end
end

--相同场景切换
function SceneMgr:changeMap2(sId, roleId, x, y)
    cache.PlayerCache:setSId(sId)
    local rId = cache.PlayerCache:getRoleId()
    if rId == roleId then
        cache.PlayerCache:updatePosition(x, y)
        if not gRole then
            mgr.ThingMgr:addRole()  --04-初始化主角
        else
            gRole:readyChangeScene()
        end
    else
        local p = mgr.ThingMgr:getObj(ThingType.player, roleId)
        if p then
            p:setPosition(x,y)
            -- print("11111111111111",x,y)
        end        
    end
end

function SceneMgr:preloadSkill()
    local sex = cache.PlayerCache:getSex()
    local skills = {{4010109,4010101,4010102,4010103,4010104,4010105,4010106},
                    {4010209,4010201,4010202,4010203,4010204,4010205,4010206}}
    local loadList = skills[sex]
    for k, v in pairs(loadList) do
        mgr.EffectMgr:preLoadEffect(v, true)
    end
end

--<地图数据> 02-加载完成->需要做什么处理请在此处
function SceneMgr:onMapDataLoadComplete()
    if not gRole then
        mgr.ThingMgr:addRole()  --04-初始化主角
    else
        mgr.HookMgr:cancelHook()
        gRole:idleBehaviour()
        gRole:readyChangeScene()
    end
    UnityCamera:MoveCameraLua(true) --05-加载地图图片

    local mv = mgr.ViewMgr:get(ViewName.MainView)
    if not mv then
        mgr.ViewMgr:openView(ViewName.MainView,function(view)
            proxy.ChatProxy:send(1060103)--请求一下私聊列表
            view:setVisible()
            view:onController3()
        end)
    else
        mv:onController3()
        mv:setVisible()
    end
end

--<地图图片> 03-加载完毕->一般的操作都在此处
function SceneMgr:onMapImgLoadComplete()
    UnitySceneMgr.isInitMain = true
    --TODO 通知服务端切换场景完成-服务端可以开始广播玩家出现了
    proxy.ThingProxy:sChangeSceneComplete()
    
    --TODO 开始动起来~\(≧▽≦)/~啦啦啦 通知服务端场景切换完成返回，需要处理啥的在此处
    --进入不同场景需要处理的事情
    self:enterMap()
    --渲染场景事物 npc 采集物 跳跃点
    local sId = cache.PlayerCache:getSId()
    mgr.ThingMgr:initDynList(sId, self.mapId)
       
    --如果是竞技场处理
    local roleVisibled = true
    if sId == ArenaScene or sId == DiWangScene or sId == YiJiScene then
        roleVisibled = false
        if cache.PlayerCache:getSId() == ArenaScene then
            cache.FubenCache:setFubenModular(1046)
        end
    else
        mgr.XinShouMgr:enterGame()
    end
    
    --开始任务
    --如何是飞鞋状态则掉落下来
    if gRole:getStateID() == RoleAI.fly then
        --是否是结婚直接跳转路径
        -- print("flyDown>>>>>>>>>>>>>>>",debug.traceback())
        mgr.TimerMgr:addTimer(0.3,1,function()
            gRole:setVisible(roleVisibled)
            gRole:flyDown(function()
                self:checkLabaFly()--bxp
                self:checLunarYearFly() --小年活动煮饺子
                if cache.PlayerCache:getAttribute(10321) > 0 then
                --避免继续任务 2次
                else
                    if not g_ios_test then
                        if not cache.GuideCache:getNotGoon() then
                            cache.GuideCache:setNotGoon(true)
                            mgr.TaskMgr.mState = 2
                        end
                        mgr.TaskMgr:resumeTask()
                    end
                end
            end)
        end)
    else
        gRole:setVisible(roleVisibled)
        if not g_ios_test then
            mgr.TaskMgr:resumeTask()
        end
    end
    --检测是否进入了副本
    if not self.firstFlag then 
        mgr.FubenMgr:checkFuben(sId)
        
        if mgr.FubenMgr:checkScene() then
            self:closeSectTipView()
        end
        if sId == ArenaScene or sId == DiWangScene or sId == YiJiScene then--竞技场显示玩家
            mgr.QualityMgr:setHitAllPlayers(true)
            --竞技场要隐藏自己的宠物
            if gRole then
                local petnew = mgr.ThingMgr:getObj(ThingType.pet, gRole:getPetID())
                if petnew then
                    petnew:setVisible(false)
                end
                local petxiantong = mgr.ThingMgr:getObj(ThingType.pet, gRole:getXianTonID())
                if petxiantong then
                    petxiantong:setVisible(false)
                end
            end
        else
            if not mgr.QualityMgr:getAllPlayer() and mgr.QualityMgr.vBody then
                mgr.QualityMgr:setHitAllPlayers(false)
            end
            --
            if gRole then
                local petnew = mgr.ThingMgr:getObj(ThingType.pet, gRole:getPetID())
                if petnew then
                    petnew:setVisible(true)
                end
                local petxiantong = mgr.ThingMgr:getObj(ThingType.pet, gRole:getXianTonID())
                if petxiantong then
                    petxiantong:setVisible(true)
                end
            end
        end
    end
    --第一次进入游戏需要处理的事情
    self:firstEnterGame()
    --提示地图是否下载完毕
    if self.mapId.."" ~= "204001" and g_mapview_loaded == false and g_extend_res then
        local has = PathTool.CheckResDown("down_sign/d"..self.mapId..".txt")
        if not has then
            --TODO 弹框提示，您的网络慢，资源还在下载中
            local params = {richtext = language.wangluobujia, type = 5}
            GComAlter(params)
            g_mapview_loaded = true
        end
    end
    --场景切换完成刷新一下buff列表
    mgr.BuffMgr:refreshBuff()
    --场景切换清理三界争霸跟随
    cache.KuaFuCache:setIsAuto(false)
    self:checkSceneInfo()
end
--bxp检测从腊八活动飞往主城
function SceneMgr:checkLabaFly()
    if cache.ActivityCache:getLabaFly() then 
        mgr.ViewMgr:openView2(ViewName.LabaZhouView)
        cache.ActivityCache:setLabaFly(false)
    end
end

--小年活动煮饺子飞往主城
function SceneMgr:checLunarYearFly()
    if cache.ActivityCache:getLunarYearFly() then 
        mgr.ViewMgr:openView2(ViewName.DumplingsView)
        cache.ActivityCache:setLunarYearFly(false)
    end
end

--检测场景信息
function SceneMgr:checkSceneInfo()
    --场景切换完成 检查场景技能
    self:checkSceneSkill()
    local sId = cache.PlayerCache:getSId()
    --仙盟圣火界面
    if sId == 230001 then
        GOpenView({id = 1129})
    end

    if mgr.FubenMgr:isDayTaskFuben(self.lastSid) then
        --print("上一场景是日常副本")
        local data = cache.TaskCache:getdailyTasks()
        if data then
            if data[1].taskStatu == 1 or data[1].taskStatu ==0 then
                local condata = conf.TaskConf:getTaskById(data[1].taskId)
                if condata.task_type == 4 then
                    mgr.TaskMgr:isfinish(condata)
                end
            end
        end
    end
end

function SceneMgr:checkSceneSkill( ... )
    local view = mgr.ViewMgr:get(ViewName.SceneSkillView)
    if view then
        view:initData()
    else
        mgr.ViewMgr:openView2(ViewName.SceneSkillView)
    end
end

--进入不同的map需要处理的事情
function SceneMgr:enterMap()
    local sId = cache.PlayerCache:getSId()
    local sceneConf = conf.SceneConf:getSceneById(sId)
    --加载场景的镜头特效
    if self.cameraEct then
        mgr.EffectMgr:removeEffect(self.cameraEct)
        self.cameraEct = nil
    end
    local mapConf = conf.SceneConf:getMapEffect(self.mapId)
    if mapConf then
        local ect = mapConf["ect"]
        if ect then
            self.cameraEct = mgr.EffectMgr:playCommonEffect(ect, UnityCamera.CameraTransform)  
        end
    end

    --是否需要闪白
    if sceneConf["scene_sb"] then
        UnityCamera:CameraEctSwitch(true)
    else
        UnityCamera:CameraEctSwitch(false)
    end
    --播放背景音乐
    if sceneConf["sound"] then
        mgr.SoundMgr:playBgMusic(sceneConf["sound"])
    end
end

--第一次进入游戏
function SceneMgr:firstEnterGame()
    if not self.firstFlag then
        return
    end


    --mgr.XinShouMgr:enterGame()
    --plog("cache.PlayerCache:getRedPointById(10308)",cache.PlayerCache:getRedPointById(10308))
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then--刷新一下血条
        local hp = cache.PlayerCache:getAttribute(104)
        local maxhp = cache.PlayerCache:getAttribute(105)
        view:updateBlood(hp,maxhp)
    end
    --部分上线的飘字
    self:loginSectTips()
    self.firstFlag = false
    mgr.TimerMgr:addTimer(1, 1, function( ... )
        mgr.QualityMgr:hitAllPets(mgr.QualityMgr:getAllPets())
        mgr.QualityMgr:hitAllPlayers(mgr.QualityMgr:getAllPlayer())
        mgr.QualityMgr:hitAllMonsters(mgr.QualityMgr:getAllMonsters())
    end)

    if cache.PlayerCache:getRedPointById(10308) > 0 then
        mgr.TimerMgr:addTimer(1.4,1,function( ... )
            -- body
            if not g_ios_test then
                GgoToMainTask()
            end
        end) 
        --GgoToMainTask()
        -- local view = mgr.ViewMgr:get(ViewName.LoginView)
        -- if not view then
        --     mgr.ViewMgr:openView(ViewName.TopView)
        -- end
    end
    --抽奖活动每日首次登陆提示
    local data = cache.ActivityCache:get5030111()
    local var = cache.PlayerCache:getAttribute(10322) or 0
        -- print("抽奖首次登陆提示",var)
    cache.ActivityCache:setSummerPush(1)
    if data and data.acts[1038] and data.acts[1038] == 1 and var == 1 and mgr.ModuleMgr:CheckView(1111) then
        if cache.PlayerCache:getAttribute(30114) < 12 then
            mgr.ViewMgr:openView2(ViewName.GuideActive, {id = 1111})
        end
    end

    -- 活动登陆提示
    -- local index = 0
    -- for i=30119,30123 do
    --     if cache.PlayerCache:getAttribute(i) > 0 then
    --         index = i
    --     end
    -- end
    -- if index > 0 then
    --     GIsOpenWishPop(index)
    -- end
    --帮派信息
    local gangId = cache.PlayerCache:getGangId()
    -- print("首次登陆请求帮派信息",gangId)
    if gangId ~= 0 then
        proxy.BangPaiProxy:sendMsg(1250104)
    end
    
    --开启后台下载
    if g_extend_res then
        mgr.DownloadMgr:init()
    end
end

function SceneMgr:setFirstFlag2(flag)
    self.firstFlag2 = flag
end

function SceneMgr:getFirstFlag2()
    return self.firstFlag2 
end

function SceneMgr:dispose()
    self.cameraEct = nil
    --UnitySceneMgr:Dispose() UGameMgr:Dispose() 已处理
end
--部分上线要飘的字
function SceneMgr:loginSectTips()
    local zhanChangMod = cache.PlayerCache:getZhanChangMod()
    if zhanChangMod and not mgr.FubenMgr:checkScene() then
        if not g_is_banshu then
            mgr.ViewMgr:openView2(ViewName.ZhanChangTipView, zhanChangMod)  
        end
    end
    --祝福值提示
    local blessData = cache.ZuoQiCache:getBlessTipData()
    if blessData and not mgr.FubenMgr:checkScene() then
        if not g_is_banshu then
            mgr.ViewMgr:openView2(ViewName.BlessTipView, blessData)
        end
    end
    -- cache.ZuoQiCache:setBlessTipData(nil)
    local overdueLists = cache.PackCache:getPackOverdue()
    if overdueLists and not mgr.FubenMgr:checkScene() then
        if not g_is_banshu then
            mgr.ViewMgr:openView2(ViewName.OverdueTipView, overdueLists)
        end
    end
    cache.PackCache:setPackOverdue(nil)
    local time = cache.PlayerCache:getAttribute(attConst.limitPack)
    if not cache.PackCache:getIsOpenLimitTip() and time > 0 then
        if not g_is_banshu then
            mgr.ViewMgr:openView2(ViewName.LimitPackTips, {})
        end
    end
    self.loginFinsh = true--登录完成
    --离线挂机奖励
    cache.ActivityCache:setOfflineLevel(cache.PlayerCache:getRoleLevel())
    cache.ActivityCache:setOfflineExp(cache.PlayerCache:getRoleExp())
    -- print("请求离线挂机奖励")
    proxy.ActivityProxy:sendMsg(1030134)

    local fubenCanList = cache.FubenCache:getFubenCanList()
    if fubenCanList and not mgr.FubenMgr:checkScene() then
        mgr.FubenMgr:openWarTip(fubenCanList)
    end
    cache.FubenCache:cleanFubenCanList()
end

function SceneMgr:backToLoginScene(isLogout)
    if isLogout then
        mgr.SDKMgr:loginOut()
    end
    GGameClear(true)
    mgr.SceneMgr:loadScene(SceneRes.UPDATE_SCENE)
end

--关闭部分弹窗
function SceneMgr:closeSectTipView()
    local view = mgr.ViewMgr:get(ViewName.ZhanChangTipView)
    cache.PlayerCache.zhanChang = {}
    if view then
        view:closeView()
    end
    local view = mgr.ViewMgr:get(ViewName.FubenTipView)
    if view then
        view:closeView()
    end
    local view = mgr.ViewMgr:get(ViewName.AdvancedTipView)
    if view then
        cache.PackCache:cleanAdvPros()
        view:closeView()
    end
    local view = mgr.ViewMgr:get(ViewName.BlessTipView)
    if view then
        view:closeView()
    end
    local view = mgr.ViewMgr:get(ViewName.OverdueTipView)
    if view then
        view:closeView()
    end
    local view = mgr.ViewMgr:get(ViewName.ZuoqiTipView)
    if view then
        view:onClickClose()
    end
    local view = mgr.ViewMgr:get(ViewName.SkinTipsView)
    if view then
        cache.PlayerCache:cleanSkinsList(true)
        view:closeView()
    end
    local view = mgr.ViewMgr:get(ViewName.EliteBossTipView)
    if view then
        view:releaseTimer()
        view:closeView()
    end
end

return SceneMgr