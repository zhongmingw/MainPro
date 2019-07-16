--[[--
  主角
]]

local Role = class("Role", import(".Player"))

function Role:ctor()
    self.headHeight = StaticVector3.playerHeadH
    self.headRes = "HeadView4"
    self.tType = ThingType.role
    self.character = GameFramework.XRole.New()
    self:regisCallBack()
    self:createHeadBar()
    self:regisMountEvent()
    self.mFightState = false
    self.rootEct = nil
    self.components = {}

    g_newpet_id = g_newpet_id + 1
    self.newpetid = g_newpet_id

    g_xiantong_id = g_xiantong_id + 1
    self.xiantong_id = g_xiantong_id
    --buff 相关
    self.dingshen = false
end

--身体模型加载完毕回调
function Role:bodyLoad()
    self.super.bodyLoad(self)
    self:addThingEct("tuowei1","tuowei1",4040103)
    self:addThingEct("tuowei2","tuowei2",4040103)

    if not self.rootEct then
        local parent = self:getRoot()
        self.rootEct = mgr.EffectMgr:playCommonEffect(4040107, parent)
    end  
end

--初始化数据
function Role:setData(data)
    local rData = cache.PlayerCache:getData()
    self:setBaseData(rData)
    self:addRolePet()
    --宠物
    self:addNetPet()
    --仙童
    self:addXiantong()

    UnityObjMgr.Role = self.character
    UnityCamera:LookAt(self.character)
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isWenDing(sId) then
        if cache.WenDingCache:getflagHoldRoleId() == self.data.roleId then
            self:updateRoleTitle(ResPath.titleRes(UIItemRes.wending02))
        else
            self:hitChenghao(false)
        end
    elseif mgr.FubenMgr:isXianMoWar(sId) then
        self:hitChenghao(false)
    end
    self:createHead()
end

function Role:addNetPet()
    Role.super.addNetPet(self)
    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.newpetid)
    if pet then
        pet:ignoreHide(true)
    end
end

function Role:addXiantong()
    Role.super.addXiantong(self)
    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.xiantong_id)
    if pet then
        pet:ignoreHide(true)
    end
end

-- --初始化宠物
-- function Role:addRolePet()
--     -- body
--     if cache.PlayerCache:getSkins(Skins.huoban) == 0 then
--         return
--     end
--     local pet = mgr.ThingMgr:getObj(ThingType.pet, self.data.roleId)
--     if not pet   then
--         mgr.ThingMgr:addPet(self.data, self.tType)
--     else 
--         local id = cache.PlayerCache:getSkins(Skins.huobanteshu)
--         if id and id~=0 then
--             pet:setSkins(id)
--         else
--             pet:setSkins(cache.PlayerCache:getSkins(Skins.huoban))
--         end
--         if pet.ownerData and pet.ownerData.skins then
--             pet:updateWeaponEct(pet.ownerData.skins[Skins.huobanshenbing])
--         end
--         pet:setPetName(self.data)
--         pet:setChenghao(self.data.partnerLevel)
--     end
-- end


function Role:setMajorState( practice, func )
    local func = function()
        -- print("关闭双修", debug.traceback())
        proxy.PlayerProxy:send(1020412,{reqType = 2,roleId = 0})
    end
    self.super.setMajorState(self, practice, func)
end

function Role:changeBody(args)
    self.super.changeBody(self, args)
    local mainView = mgr.ViewMgr:get(ViewName.MainView)
    if mainView then
        mainView.BtnFight:coolDownBianshen()
    end
end
function Role:restoreBody()
    self.super.restoreBody(self)
    local mainView = mgr.ViewMgr:get(ViewName.MainView)
    if mainView then
        mainView.BtnFight:coolDownBianshen()
    end
end

--切换场景->切换场景之前要设置好角色的坐标
function Role:readyChangeScene()
    self.isHome = false --保证切换场景 人物可以继续攻击释放技能
    local rData = cache.PlayerCache:getData()
    self:setPosition(rData.pox, rData.poy)
    self:addRolePet()
    self:addNetPet()
    self:addXiantong()
    self:stopAI()
end

--设置外部
function Role:setSkins(body, weapon, wing)
    self:downMount()
    self.super.setSkins(self, body, weapon, wing)
end

--主角当前使用的技能
function Role:curUseSkill()
    return self.character.Skill
end
--主角基础攻击
function Role:baseAttack(t, tId)
    if self.isHome then
        plog("温泉里面不可以发动攻击")
        return
    end

    local sex = cache.PlayerCache:getSex()
    local id
    if sex == 1 then
        id = 5010100
    else
        id = 5020100
    end
    local s = id + math.random(6)
    local lastId = self:curUseSkill()
    while(s == tonumber(lastId)) do
       s = id + math.random(6)
    end
    mgr.FightMgr:roleBattle(s,t,tId)

    mgr.TaskMgr.mState = 0 --设置为自动取消任务
    mgr.ModuleMgr:closeFindPath(0) --自动寻路关闭
    mgr.FightMgr:removeTimer()--停止追着打
    cache.KuaFuCache:setIsAuto(false) --清理跟随
end
--被人攻击了
function Role:isFightByOher(data)
    -- body
    local sId = cache.PlayerCache:getSId()
    if XdzzScene == sId or mgr.FubenMgr:isPlayoffPaiWeiSai(sId)
    or mgr.FubenMgr:isPaiWeiSai(sId) or mgr.FubenMgr:isTeamPaiWeiSai(sId) then
        return
    end

    local sConf = conf.SceneConf:getSceneById(sId)
    local pkOptions = sConf and sConf.pk_options or {0}
    if sConf and pkOptions then
        for k , v in pairs(pkOptions) do
            if v == PKState.kill then
                if data.opt == 1 then
                    for k ,v in pairs(data.uTargets) do
                        if v.roleId == cache.PlayerCache:getRoleId() then
                            --打回他
                            local player = mgr.ThingMgr:getObj(ThingType.player, data.atkId)
                            if player then
                                local view = mgr.ViewMgr:get(ViewName.MainHurtTips)
                                if view then
                                    view:initData(player.data)
                                else
                                    if sConf.kind ~= 2 then--野外地图不需要显示反击bxp
                                        mgr.ViewMgr:openView2(ViewName.MainHurtTips,player.data)
                                    end
                                end
                            end
                            break
                        end
                    end
                end
                break
            end
        end
    end
end

--刷新积分
function Role:refreshScore(attris)
    if self.data and self.data.attris then
        local score = 0
        if attris[515] then
            self.data.attris[515] = attris[515] or self.data.attris[515] or 0
            score = self.data.attris[515] or 0
            if self.components["xdzz"] then
                self.components["xdzz"]:GetChild("n0").text = mgr.TextMgr:getTextColorStr(score, 14)
            end
        elseif attris[516] then
            self.data.attris[516] = attris[516] or self.data.attris[516] or 0
            score = self.data.attris[516] or 0
            if self.components["xdzz"] then
                self.components["xdzz"]:GetChild("n0").text = mgr.TextMgr:getTextColorStr(score, 14)
            end
        end
    end
end

--主角技能攻击
function Role:skillAttack(s,t,id)
    if self.isHome then
        plog("温泉里面不可以发动攻击")
        return
    end
    mgr.FightMgr:roleBattle(s,t,id)
    CClearPickView()
    GCancelPick()
    mgr.TaskMgr.mState = 0 --设置为自动取消任务
    mgr.ModuleMgr:closeFindPath(0) --自动寻路关闭
    mgr.FightMgr:removeTimer()
    cache.KuaFuCache:setIsAuto(false)
end
--发送打坐
function Role:sendsit(flag)
    --打坐等级限制
    if cache.PlayerCache:getRoleLevel() < conf.SysConf:getValue("sit_lev") then
        return
    end
    --local confdata = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    if not mgr.FubenMgr:isSitDownSid() then
        GComAlter(language.dazuo09)
        return
    end

    if self:isFight() then
        if flag then
            GComAlter(language.dazuo08)
        end
        return
    end
    if self:getStateID() == RoleAI.jump then
        GComAlter(language.dazuo11)
        return
    end
    if self.isChangeBody == true then
        GComAlter(language.dazuo10)
        return
    end
    if self:getStateID() == RoleAI.move then
        --任务执行过程
        GComAlter(language.dazuo07)
        return
    end
    
    if self:isSit() then
        if self:isMajor() then--双修时可以打坐
            proxy.PlayerProxy:send(1020401)
            return
        else
            proxy.PlayerProxy:send(1020402)
            return
        end
    end
    proxy.PlayerProxy:send(1020401)
end

--打坐
function Role:sit(stopSitFunc, action)
    cache.KuaFuCache:setIsAuto(false)
    self.super.sit(self, self.stopSitFunc, action)
    if not action then
        mgr.ViewMgr:openView(ViewName.SitDownView)
    end
end

--取消打坐
function Role:cancelSit()
    --判定是否在打坐
    local view = mgr.ViewMgr:get(ViewName.SitDownView)
    if view then
        proxy.PlayerProxy:send(1020402)
        view:closeView()
    end
    self.super.cancelSit(self)
end

--坐骑 handlerMount
function Role:handlerMount()
    if self.isChangeBody then--变身期间跳过上马
        return
    end

    local state = 1
    if self:isMount() then
        state = 0
    end

    local confdata = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    if confdata.kind ~= SceneKind.mainCity 
        and confdata.kind ~= SceneKind.field 
        and  confdata.kind ~= SceneKind.xinshou then
        return
    end
    --plog("发送上马",state)
    mgr.NetMgr:send(1120201,{rideStatu=state})
end

--检查玩家是否在战斗中 | 如果玩家开始战斗到结束战斗5秒内
function Role:isFight()
    -- if os.time() - self.fightTime > 5 then
    --     return false
    -- end
    return self.mFightState
    --return mgr.BuffMgr:isFight()
end
function Role:setFightState(bool)
    self.mFightState = bool
end

--设置是否可见
function Role:setVisible(b)
    self.super.setVisible(self,b)
    if self.data and not mgr.FubenMgr:isXdzzWar(cache.PlayerCache:getSId()) then
        local pet = mgr.ThingMgr:getObj(ThingType.pet, self.data.roleId)
        if pet then
            pet:setVisible(b)
        end
    end
end

--停止ai
function Role:stopAI()
    self.super.stopAI(self)
end

--主角pk模式切换
function Role:changePkState(s)
    self.pkState = s
    cache.PlayerCache:setPKState(s)
    local players = mgr.ThingMgr:objsByType(ThingType.player)
    for k, v in pairs(players) do
        v:checkCanBeAttack() 
    end 
end

--设置玩家血量
function Role:setHp(hp)
    if not hp then
        print("@当前血量设置为空：", debug.traceback())
        return 
    end
    local oldhp = self.hp or 0
    if hp <= 0 then
        CClearPickView()
    end
    self.super.setHp(self, hp)
    --TODO 更新主界面血量
    if hp > self.maxHp then
        hp = self.maxHp
    end
    cache.PlayerCache:setAttribute(104,hp)
    cache.PlayerCache:setAttribute(105,self.maxHp)
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:updateBlood(self.hp, self.maxHp)
    end
end

function Role:inFuben()
    -- body
    if self:isMount() then
        self:downMount()
    end
end

function Role:setDingShen(b)
    self.dingshen = b
    self.character.DingShen = b
end
function Role:isDingShen()
    return self.dingshen
end

return Role