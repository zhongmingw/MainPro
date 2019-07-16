--
-- Author: yr
-- Date: 2017-03-06 17:14:47
--

local QualityMgr = class("QualityMgr")

function QualityMgr:ctor()
    self.qLevel = GameUtil.GetGameQuality()

    self.vFaQi = true
    self.vBody = true
    self.vTime = 0
    self.vPet = true
    self.vMonster = true
    self.vCamera = true

    self.mFrameCount = 0
    self.mLastFrameTime = Time.getTime()
    self.mLastFps = 30
    self.mLastGcTime = Time.getTime()
    if g_var.platform == Platform.ios then
        self.unloadTime = 300
    else
        self.unloadTime = 600
    end

    self.seePlayerNumbers = 0   --同屏可视初始化玩家
    self.screenPlayerCount = 0

end

--设置游戏整体质量
function QualityMgr:setQuality(level)
    --self.qLevel = level
    --GameUtil.SetGameQuality(level)
    --UPlayerPrefs.SetInt("GameQuality",level)
end

function QualityMgr:getQuality()
    local qlevel = self:getGameQuality()
    if qlevel == 3 or qlevel == 0 then
        return 0
    elseif qlevel == 2 then
        return 1
    else
        return 2
    end 
end

function QualityMgr:getGameQuality()
    return UPlayerPrefs.GetInt("GameQuality")
end
--隐藏其他玩家
function QualityMgr:hitAllPlayers(b)
    self:setHitAllPlayers(b)
    self:setIntPrefs("GamePlayers",b)
    self:setHitAllPets(b)
end

function QualityMgr:setHitAllPlayers(b)
    local players = mgr.ThingMgr:objsByType(ThingType.player)
    if players then
        for k, v in pairs(players) do
            local kind = v.data and v.data.kind or 0
            if kind ~= PlayerKind.statue then
                if not b then--如果是屏蔽玩家
                    v:hitFaQi(b)
                    v:hitWing(b)
                    v:hitChenghao(b)
                else--如果是取消屏蔽玩家
                    if self:getAllFaQi() then
                        v:hitFaQi(b)
                    end
                    if self:getAllWing() then
                        v:hitWing(b)
                    end
                    if self:getAllChenghao() then
                        v:hitChenghao(b)
                    end
                    --特殊场景
                    if mgr.FubenMgr:isMeiliBeach(cache.PlayerCache:getSId()) then
                        local view = mgr.ViewMgr:get(ViewName.BeachMainView)
                        if view then
                            view:resetPlayer(v)
                        end
                    end
                end
            end
        end
    end
    self.vBody = b
    UnityObjMgr:PlayerRender(b)
end
--隐藏其他玩家的伙伴
function QualityMgr:hitAllPets(b)
    self:setHitAllPets(b)
    self:setIntPrefs("GamePets",b)
end
--特殊屏蔽宠物
function QualityMgr:setShieldAllPets(b)
    self.shieldAllPets = b
    if b then
        if self.vPet then
            UnityObjMgr:PetRender(b)
        end
    else
        UnityObjMgr:PetRender(false)
    end
end

function QualityMgr:setHitAllPets(b)
    local pets = mgr.ThingMgr:objsByType(ThingType.pet)
    if pets then
        for k, v in pairs(pets) do
            local ownerData = v.ownerData
            local roleId = ownerData and ownerData.roleId or 0
            local kind = ownerData and ownerData.kind or 0
            if v.ownerData and roleId ~= cache.PlayerCache:getRoleId() and kind ~= PlayerKind.statue then
                v:hitHeadBar(b)
                v:hitFaQi(enable)
            end
        end
    end
    self.vPet = b
    UnityObjMgr:PetRender(b)
end
--隐藏怪物
function QualityMgr:hitAllMonsters(b)
    self:setAllMonsters(b)
    self:setIntPrefs("GameMonsters",b)
end
--
function QualityMgr:setAllMonsters(b)
    self.vMonster = b
    UnityObjMgr:MonsterRender(b)
end
--隐藏其他玩家的法器
function QualityMgr:hitAllFaQi(b)
    self:setAllFaQi(b)
    self:setIntPrefs("GameFaQi",b)
end

function QualityMgr:setAllFaQi(b)
    local players = mgr.ThingMgr:objsByType(ThingType.player)
    if players then
        for k, v in pairs(players) do
            v:hitFaQi(b)
        end
    end
    self.vFaQi = b
end
--隐藏其他玩家的称号
function QualityMgr:hitAllChenghao(b)
    local players = mgr.ThingMgr:objsByType(ThingType.player)
    if players then--玩家称号
        for k, v in pairs(players) do
            local kind = v.data and v.data.kind or 0
            if kind ~= PlayerKind.statue then
                v:hitChenghao(b)
            end
        end
    end
    local pets = mgr.ThingMgr:objsByType(ThingType.pet)
    if pets then--宠物称号
        for k, v in pairs(pets) do
            local ownerData = v.ownerData
            local roleId = ownerData and ownerData.roleId or 0
            local kind = ownerData and ownerData.kind or 0
            if v.ownerData and roleId ~= cache.PlayerCache:getRoleId() and kind ~= PlayerKind.statue then
                v:hitChenghao(b)
            end
        end
    end
    self:setIntPrefs("GameChenghao",b)
end
--隐藏技能特效
function QualityMgr:hitAllSkillEffect(b)
    -- local players=mgr.ThingMgr:objsByType(ThingType.player)
    -- if players then--玩家称号
    --     for k, v in pairs(players) do
    --         local kind = v.data and v.data.kind or 0
    --         if kind ~= PlayerKind.statue then
    --            --隐藏特效
           
    --         end
    --     end
    -- end
    self:setIntPrefs("GameSkillEffect",b)
end

--隐藏其他玩家的仙羽
function QualityMgr:hitAllWing(b)
    local players = mgr.ThingMgr:objsByType(ThingType.player)
    if players then
        for k, v in pairs(players) do
            local kind = v.data and v.data.kind or 0
            if kind ~= PlayerKind.statue then
                v:hitWing(b)
            end
        end
    end
    self:setIntPrefs("GameWing",b)
end

----自动拒绝好友申请
function QualityMgr:hitAllFriendShenQing(b)

    self:setIntPrefs("GameFriendShenQing",b)
end

----自动屏蔽陌生人私聊
function QualityMgr:hitAllStrangerChat(b)
    self:setIntPrefs("GameStrangerChat",b)
end

function QualityMgr:setIntPrefs(key,b)
    local enable = 1--屏蔽
    if b then
        enable = 0
    end
    UPlayerPrefs.SetInt(key,enable)
end

function QualityMgr:getAllFaQi()
    return self:returnIntPrefs("GameFaQi")
end

function QualityMgr:getAllPets()
    return self:returnIntPrefs("GamePets")
end

function QualityMgr:getShieldAllPets()
    return self.shieldAllPets
end

function QualityMgr:getAllPlayer()
    return self:returnIntPrefs("GamePlayers")
end

function QualityMgr:getAllChenghao()
    return self:returnIntPrefs("GameChenghao")
end

function QualityMgr:getAllMonsters()
    return self:returnIntPrefs("GameMonsters")
end

function QualityMgr:getAllWing()
    return self:returnIntPrefs("GameWing")
end
function QualityMgr:getAllSkillEffect()
    return self:returnIntPrefs("GameSkillEffect")
end

function QualityMgr:getAllFriendShenQing()

    return self:returnIntPrefs("GameFriendShenQing")
end
function QualityMgr:getAllStrangerChat()
    return self:returnIntPrefs("GameStrangerChat")
end



function QualityMgr:returnIntPrefs(key)
    local enable = UPlayerPrefs.GetInt(key)
    if enable == 0 then
        return true
    else
        return false
    end
end

--游戏性能动态处理
function QualityMgr:update()
    self:gameFps()
end

--根据性能获取不同资源
function QualityMgr:getResQua(resId)
    --[[local xn = conf.XingNengConf:getInfoById(resId)
    if xn and self.qLevel <= 1 then
        if xn["low"] then
            return "_2"
        end
    end]]
    return ""
end

--根据当前fps是否屏蔽其他玩家的技能特效
function QualityMgr:hitOtherFightEcts()
    if self.mLastFps < 20 then
        return true
    end
    return false
end

function QualityMgr:addSeePlayerNums()
    if self.seePlayerNumbers > 15 then
        return false
    end
    self.seePlayerNumbers = self.seePlayerNumbers + 1
    return true
end
function QualityMgr:delSeePlayerNums()
    self.seePlayerNumbers = self.seePlayerNumbers - 1
end


function QualityMgr:gameFps()
    self.mFrameCount = self.mFrameCount + 1
    local curTime = Time.getTime()
    if curTime - self.mLastFrameTime >= 4 then
        local fps = self.mFrameCount / (curTime - self.mLastFrameTime)
        self.mLastFps = fps
        self.mFrameCount = 0
        self.mLastFrameTime = curTime
        --性能评级-2分钟内fps的平均值
        self:autoHit()
        --界面显示fps
        if g_system_info then
            local view = mgr.ViewMgr:get(ViewName.DebugView)
            if view then
                view:setFps(fps)
            end
        end
    end

    -- 定期进行一次UnloadUnusedAssets
    if g_var.platform == Platform.ios then
        if curTime - self.mLastGcTime > self.unloadTime then
            self.mLastGcTime = curTime
            collectgarbage("collect")
            if g_var.gameFrameworkVersion >= 3 then
                Resources.UnloadUnusedAssets()
            end
            --UPoolMgr:DelUnUsedPoolObject(300, false)
            print(" ########################### UnloadUnusedAssets ########################### ")
        end
    end
end

function QualityMgr:updateGCTime()
    self.mLastGcTime = Time.getTime()
end

function QualityMgr:autoHit()
    local osTime = os.time()
    if self.mLastFps < 20 then
        if self.vPet == true then
            UnityObjMgr:PetRender(false)
            self.vPet = false
        end
    end

    if self.mLastFps < 15 then
        if self.vFaQi == true then
            self:setAllFaQi(false)
        end
    end

    if self.mLastFps < 10 then
        if self.vBody == true then
            UnityObjMgr:PlayerRender(false)
            self.vBody = false
        end
    end

    if self.mLastFps > 20 then
        if self.vBody == false and self:getAllPlayer() then
            UnityObjMgr:PlayerRender(true)
            self.vBody = true
        end
        
    end

    if self.mLastFps > 24 then
        if self:getShieldAllPets() then
            return
        end
        if self.vPet == false and self:getAllPets() then
            UnityObjMgr:PetRender(true)
            self.vPet = true
        end
    end
end

function QualityMgr:beginSample(name)
    if g_debug_view then
        GameUtil.BeginSample(name)
    end
end

function QualityMgr:endSample()
    if g_debug_view then
        GameUtil.EndSample()
    end
end


return QualityMgr

--[[
性能参数优化：
    1、30fps、CPU频率为1.3GHz、20%的有效工作量分给Draw call。
    那么每一帧可以处理的Draw call为：25K*1.3*0.2/30=216

]]