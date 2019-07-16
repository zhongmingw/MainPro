--[[--
游戏事物基类
]]

local Player = class("Player", import(".Thing"))

function Player:ctor()
    self.headHeight = StaticVector3.playerHeadH
    self.headRes = "HeadView"
    self.tType = ThingType.player
    self.character = UnityObjMgr:CreateThing(self.tType)
    self:regisCallBack()
    self.pkState = PKState.peace

    self.canSee = mgr.QualityMgr:addSeePlayerNums()
    self.waitAppear = true
    self.isHome = false --是否不允许发起攻击
    self.components = {}

    g_newpet_id = g_newpet_id + 1
    self.newpetid = g_newpet_id

    g_xiantong_id = g_xiantong_id + 1
    self.xiantong_id = g_xiantong_id
end

--初始化玩家数据
function Player:setData(data)
    local kind = data and data.kind or 0
    if kind == PlayerKind.statue then
        self.headRes = "HeadView4"
    end
    self:createHeadBar()
    self:setBaseData(data)
    --灵童
    self:addRolePet()
    --宠物
    self:addNetPet()
    --宠物
    self:addXiantong()

    self:setShield()

    if kind == PlayerKind.statue then  --竞技场强制不隐藏-神坑
        self:ignoreHide(true)
    else
        -- if data.attris[104]==nil or data.attris[104] == 0 then  --玩家死亡出现
        --     self:dead()
        -- end
    end
    --竞技场数据
    --print(">>>>>>>>>>>>>>>>>>>",cache.PlayerCache:getSId(),DiWangScene)
    local sId = cache.PlayerCache:getSId()
    if sId == ArenaScene or sId == DiWangScene or sId == YiJiScene then
        --printt("玩家数据>>>>>>>>>>>>",data)
         mgr.ViewMgr:openView2(ViewName.ArenaFightView)

        local view = mgr.ViewMgr:getData(ViewName.ArenaFightView)
        if view then
            view:setData(data)
        end
    end
    self:checkCanBeAttack()
    self:createHead()

    if self.bottomEffect then
        mgr.EffectMgr:removeEffect(self.bottomEffect)
        self.bottomEffect = nil
    end

    --检测是否是家园温泉
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isHome(sId) then
        if self.data.attris[520] and self.data.attris[520] == 1 then
            self:addSpringEffect()
        end
    end
end

--获取新宠物id
function Player:getPetID()
    return self.newpetid
end

--获取新宠物id
function Player:getXianTonID()
    return self.xiantong_id
end

--屏蔽设置
function Player:setShield()
    if self.data.roleId ~= cache.PlayerCache:getRoleId() and kind ~= PlayerKind.statue then
        local isPlayer = mgr.QualityMgr:getAllPlayer()
        local faqiEnabled = false
        local wingEnabled = false
        local titleEnabled = false
        local isFaqi = mgr.QualityMgr:getAllFaQi()
        local isWing = mgr.QualityMgr:getAllWing()
        local isChenghao = mgr.QualityMgr:getAllChenghao()
        if isPlayer then
            faqiEnabled = isFaqi
            wingEnabled = isWing
            titleEnabled = isChenghao
        else
            titleEnabled = false
            faqiEnabled = false
            wingEnabled = false
        end
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isWenDing(sId) then--问鼎改变
            self:setWenDing()
        elseif mgr.FubenMgr:isXianMoWar(sId) then--仙魔战改变
            self:setXianMo()
        elseif mgr.FubenMgr:isXdzzWar(sId) or mgr.FubenMgr:isCdmhWar(sId) then--仙魔战改变
            self:setXdzz()
        elseif mgr.FubenMgr:isMeiliBeach(sId) then
            local view = mgr.ViewMgr:get(ViewName.BeachMainView)
            if view then
                view:resetPlayer(self)
            end
        else
            self:hitChenghao(titleEnabled)
            self:hitFaQi(faqiEnabled)
            self:hitWing(wingEnabled)
        end
    end
end

function Player:createHead()
    -- body
    self:clearComponents()
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isXdzzWar(sId) or mgr.FubenMgr:isCdmhWar(sId) then
        if not self.components["xdzz"] then
            local component = UIPackage.CreateObject("head" , "ScoreItem")
            component.name = "xdzz"
            local title = component:GetChild("n0")
            local score = 0
            if self.data then
                if mgr.FubenMgr:isXdzzWar(sId) then
                    score = self.data.attris and self.data.attris[515] or 0
                else
                    score = self.data.attris and self.data.attris[516] or 0
                end
            end
            title.text = mgr.TextMgr:getTextColorStr(score, 14)
            local name = self.headBar:GetChild("name")
            if mgr.FubenMgr:isXdzzWar(sId) then
                if self:getID() == cache.PlayerCache:getRoleId() then
                    component.y = name.y - component.height
                else
                    name.text = ""
                    component.y = name.y
                end
            else
                component.y = name.y - component.height
            end
            component.x = (self.headBar.width -  component.width)/2

            self.headBar:AddChild(component)
            self.components["xdzz"] = component
        end
        self:setXdzz()
    end
end
--刷新积分
function Player:refreshScore(attris)
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

function Player:clearComponents()
    --移除多余添加控件
    for k ,v in pairs(self.components) do
        v:Dispose()
        self.components[k] = nil
    end
end
-- function Player:setMajorState( practice, func )
--     --print("其他玩家",practice)
--     -- self.super.setMajorState(self, practice, func)
-- end
function Player:setXdzz()
    if mgr.FubenMgr:isXdzzWar(cache.PlayerCache:getSId()) then
        local playerData = GGetMsgByRoleIcon(self.data.roleIcon)
        local sex = playerData.sex
        local playerSkins = conf.ActivityWarConf:getSnowGlobal("skins")
        self:setSkins(playerSkins[sex],playerSkins[3],0)
    end
    self:hitFaQi(false)
    self:hitChenghao(false)
    if self:getID() == cache.PlayerCache:getRoleId() then
        local pet = mgr.ThingMgr:getObj(ThingType.pet, self:getID())
        if pet then
            pet:updtePetName("")
            pet:setVisible(false)
        end
        local pet = mgr.ThingMgr:getObj(ThingType.pet, self:getPetID())
        if pet then
            pet:updtePetName("")
            pet:setVisible(false)
        end
        local pet = mgr.ThingMgr:getObj(ThingType.pet, self:getXianTonID())
        if pet then
            pet:updtePetName("")
            pet:setVisible(false)
        end
    end
    for i = 0 , self.headBar.numChildren-1 do
        local var = self.headBar:GetChildAt(i)
        if not (var.name == "name" or var.name == "blood" or var.name == "xdzz") then
            var.visible = false
        end
    end
end
--如果在问鼎的时候
function Player:setWenDing()
    --bxp 九重天显示玩家模型 陈烘需求 2018/7/13
    -- if self.data.roleId == cache.PlayerCache:getRoleId() then
        local data = self.data
        local skins = data.skins
        self.skins = skins
        self:setSkins(skins[1], skins[2], skins[3])
    -- else
    --     local playerData = GGetMsgByRoleIcon(self.data.roleIcon)
    --     local sex = playerData.sex
    --     local playerSkins = conf.WenDingConf:getValue("player_skins")
    --     local mySkins = playerSkins[sex]
    --     self:setSkins(mySkins[1],mySkins[2],mySkins[3])
    -- end
    if cache.WenDingCache:getflagHoldRoleId() == self.data.roleId then
        if cache.WenDingCache:getflagHoldRoleId() ~= cache.PlayerCache:getRoleId() then
            self:updateRoleTitle(ResPath.titleRes(UIItemRes.wending02))
        end
        -- self:updateRoleName(language.wending06[2])
    else
        self:hitChenghao(false)
    end
    self:hitFaQi(false)
end
--如果在仙魔战的时候
function Player:setXianMo()
    local campId = self.data and self.data.attris[514] or 0--阵营id
    if cache.PlayerCache:getRoleId() == self.data.roleId then--如果是自己
        campId = cache.XianMoCache:getCampId()
    end
    local playerData = GGetMsgByRoleIcon(self.data.roleIcon)
    local sex = playerData.sex
    local playerSkins = {}
    if campId == 1 then--仙
        playerSkins = conf.XianMoConf:getValue("xian_skins")
    elseif campId == 2 then--魔
        playerSkins = conf.XianMoConf:getValue("mo_skins")
    end
    if #playerSkins > 0 then
        local mySkins = playerSkins[sex]
        self:setSkins(mySkins[1],mySkins[2],0)
    end
    if campId == cache.XianMoCache:getCampId() then
        self:setCanSelect(false)
    else
        self:setCanSelect(true)
    end
    self:hitChenghao(false)
    self:hitFaQi(false)
end
--玩家在家园的时候
function Player:setHome(flag)
    -- body
    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.data.roleId)

    local petnew = mgr.ThingMgr:getObj(ThingType.pet, self:getPetID())

    local petxiantong = mgr.ThingMgr:getObj(ThingType.pet, self:getXianTonID())

    self.isHome = flag
    if not flag then
        local data = self.data
        local skins = data.skins
        self.skins = skins
        if mgr.FubenMgr:isMeiliBeach(cache.PlayerCache:getSId()) then
            local playerSkins = conf.BeachConf:getValue("wenquan_skins")
            local playerData = GGetMsgByRoleIcon(self.data.roleIcon)
            local mySkins = playerSkins[playerData.sex]
            self.skins = _skins
            self:setSkins(mySkins[1], mySkins[2], mySkins[3])

            if pet then
                pet:setVisible(false)
            end
            if petnew then
                petnew:setVisible(false)
            end
            if petxiantong then
                petxiantong:setVisible(false)
            end
            self:hitFaQi(false)
        else
            self:setSkins(skins[1], skins[2], skins[3])

            if pet then
                pet:setVisible(true)
            end
            self:hitFaQi(true)

            if petnew then
                petnew:setVisible(true)
            end
            if petxiantong then
                petxiantong:setVisible(true)
            end
        end

        if self.bottomEffect then
            mgr.EffectMgr:removeEffect(self.bottomEffect)
            self.bottomEffect = nil
        end

    else
        local playerData = GGetMsgByRoleIcon(self.data.roleIcon)
        local sex = playerData.sex
        local playerSkins = conf.HomeConf:getValue("wenquan_skins")
        local mySkins = playerSkins[sex]
        self:setSkins(mySkins[1],0,0)

        -- local id = conf.HomeConf:getValue("effect_id")
        -- self:addBottomEffect(id)

        if pet then
            pet:setVisible(false)
        end

        if petnew then
            petnew:setVisible(false)
        end

        if petxiantong then
            petxiantong:setVisible(false)
        end

        self:hitFaQi(false)
    end
end

function Player:addSpringEffect()
    -- body
    local sId = cache.PlayerCache:getSId()
    if not mgr.FubenMgr:isHome(sId) then
        return --不是家园退出
    end
    local id = conf.HomeConf:getValue("effect_id")
    self:addBottomEffect(id)
end

--沙滩
-- function Player:setBeach(flag,mySkins)
--     -- body
--     local pet = mgr.ThingMgr:getObj(ThingType.pet, self.data.roleId)
--     self.isHome = flag --不允许发起攻击
--     if flag then
--         if pet then
--             pet:setVisible(false)
--         end
--         self:hitFaQi(false)
--         --按位置换皮肤
--         if mySkins then
--             self:setSkins(mySkins,0,0)

--     else
--         --不在沙滩场景 回复
--         local data = self.data
--         local skins = data.skins
--         self.skins = skins
--         self:setSkins(skins[1], skins[2], skins[3])
--         if pet then
--             pet:setVisible(true)
--         end
--         self:hitFaQi(true)
--     end
-- end

function Player:getData()
    -- body
    return self.data
end

--初始化灵童
function Player:addRolePet()
    if not self.data then
        return
    end
    if not self.data.skins[Skins.huoban] or self.data.skins[Skins.huoban] == 0 then
        return
    end
    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.data.roleId)
    if not pet  then
        pet = mgr.ThingMgr:addPet(self.data, self.tType, self.canSee)
    else
        pet.canSee = self.canSee
        local id = self.data.skins[Skins.huobanteshu]
        if id and id~=0 then
            pet:setSkins(id)
        else
            pet:setSkins(self.data.skins[Skins.huoban])
        end
        pet:setPetName(self.data)
        pet:setChenghao(self.data.partnerLevel)
    end
end

function Player:addNetPet()
    -- body

    if not self.data then
        return
    end
    if not self.data.skins[Skins.newpet] or self.data.skins[Skins.newpet] == 0 then
        return
    end
    --print("self.newpetid",self.newpetid)
    self.data.newpetid = self.newpetid

    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.newpetid)
    if not pet then
        pet = mgr.ThingMgr:addPetNew(self.data, self.tType, self.canSee)
    else
        pet.canSee = self.canSee
        local id = self.data.skins[Skins.newpet]
        if not id or id == 0 then
            return
        end
        local condata = conf.PetConf:getPetItem(id)
        pet:setSkins(condata.model)
        pet:updtePetName(self.data.petName)
    end
end

function Player:addXiantong()
    -- body
    if not self.data then
        return
    end
    --print(self.data.skins[Skins.xiantong],"self.data.skins[Skins.xiantong]")
    if not self.data.skins[Skins.xiantong] or self.data.skins[Skins.xiantong] == 0 then
        return
    end
    --print("self.newpetid",self.newpetid)
    self.data.xiantong_id = self.xiantong_id

    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.xiantong_id)
    if not pet then
        pet = mgr.ThingMgr:addXianTongNew(self.data, self.tType, self.canSee)
    else
        pet.canSee = self.canSee
        local id = self.data.skins[Skins.xiantong]
        if not id or id == 0 then
            return
        end
        local condata = conf.MarryConf:getPetItem(id)
        pet:setSkins(condata.model)
        pet:updtePetName(self.data.xtName)
    end
end

--设置速度
function Player:setSpeed(value)
    self.character.Speed = value
    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.data.roleId)
    if pet then
        pet:setSpeed(value)
    end
end

function Player:addPetXianyu(id)
    -- body
    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.data.roleId)
    if pet then
        pet:setSkins(nil,nil,id)
    end
end

function Player:addPetShenbing(id)
    -- body
    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.data.roleId)
    if pet then
        pet:updateWeaponEct(id)
    end
end

function Player:addPetFabao(id)
    -- body
    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.data.roleId)
    if pet then
        pet:addFaBao(id)
    end
end
function Player:addPetXiqian(id)
    -- body
    local pet = mgr.ThingMgr:getObj(ThingType.pet, self.data.roleId)
    if pet then
        pet:addXianQi(id)
    end
end

--玩家出现调用
--组队如果是同屏的需要调用
--主角主动切换的时候遍历所有同屏玩家调用
function Player:checkCanBeAttack()
    local pk = cache.PlayerCache:getPKState()
    if pk == PKState.peace or self.pkState == PKState.invalid then--or self.pkState == PKState.peace then
        self.character.CanSelected = false
    elseif pk == PKState.kill then--杀戮模式
        self.character.CanSelected = true
    elseif pk == PKState.team then --主角是组队模式
        local gId = cache.PlayerCache:getGangId()
        local tId = cache.TeamCache:getTeamId()
        if self.data.gangId == "0" then  --没有帮派
            if self.data.teamId == 0 then  --没有组队
                self.character.CanSelected = true
            else
                if self.data.teamId == tId then --和主角一队
                    self.character.CanSelected = false
                else
                    self.character.CanSelected = true
                end
            end
        else
            if self.data.gangId == gId then
                self.character.CanSelected = false
            else
                if self.data.teamId == 0 then  --没有组队
                    self.character.CanSelected = true
                else
                    if self.data.teamId == tId then --和主角一队
                        self.character.CanSelected = false
                    else
                        self.character.CanSelected = true
                    end
                end
            end
        end
    elseif pk == PKState.server then
        local sId = cache.PlayerCache:getServerId()
        --print("@PK 模式切换",pk,":",self.pkState,"->",self.data.mainSvrId,sId)
        if self.data.mainSvrId == sId then
            self.character.CanSelected = false
        else
            self.character.CanSelected = true
        end
    elseif pk == PKState.camp then--阵营模式
        local campId = self.data and self.data.attris[514] or 0--阵营id
        local sId = cache.PlayerCache:getSId()
        -- print("是否是争霸赛>>>>>>>>>>>>>>>>>",mgr.FubenMgr:isXianLvPKzbs(sId),"场景id",sId,"队伍id",cache.XianLvCache:getTeamId(),"阵营id",campId)
        if mgr.FubenMgr:isXianMoWar(sId) then--仙魔战
            if campId == cache.XianMoCache:getCampId() then
                self.character.CanSelected = false
            else
                self.character.CanSelected = true
            end
        elseif mgr.FubenMgr:isPaiWeiSai(sId) or mgr.FubenMgr:isTeamPaiWeiSai(sId) or mgr.FubenMgr:isPlayoffPaiWeiSai(sId) then--排位赛
            --print("当前阵营id",campId,cache.PwsCache:getTeamId())
            if campId == cache.PwsCache:getTeamId() then
                self.character.CanSelected = false
            else
                self.character.CanSelected = true
            end
        elseif mgr.FubenMgr:isXianLvPKhxs(sId) or mgr.FubenMgr:isXianLvPKzbs(sId) or mgr.FubenMgr:isXianLvPKhxs_2(sId) or mgr.FubenMgr:isXianLvPKzbs_2(sId) then--仙侣pk
            local teamId = cache.XianLvCache:getTeamId()
            -- print(type(campId),type(teamId),"阵营id",campId,"队伍id",teamId)
            if campId == cache.XianLvCache:getTeamId() or not cache.XianLvCache:getTeamId() then
                self.character.CanSelected = false
            else
                self.character.CanSelected = true
            end
            -- print("是否可选择",self.character.CanSelected)
        else
            self.character.CanSelected = true
        end
    end
end

function Player:canBeSelect()
    if self:getGridValue() == 7 then  --安全区域中
        return false
    end
    return self.character.CanSelected
end

function Player:updatePKState(s)
    if s and self.data.attris then  --玩家自己更新pk模式
        self.data.attris[511] = s
        self.pkState = s
        self:checkCanBeAttack()
    end
end

function Player:dead(killId)
    -- print("@玩家死亡了~")
    --print(debug.traceback())
    if self.faBaoEct then
        self.faBaoEct.Visible = false
    end
    if self.xianQiEct then
        self.xianQiEct.Visible = false
    end
    self.character:Dead()
    self.data["isDead"] = true
    local view = mgr.ViewMgr:get(ViewName.PlayerHpView)
    if view then
        local data = view:getData()
        local roleId = data and data.roleId or 0
        if roleId == self.data.roleId then
            view:closeView()
        end
    end
    if self.data then
        mgr.BuffMgr:removeThingBuff({roleId = self.data.roleId})
    end

    mgr.FightMgr:playerDead(self.data)
    --mgr.ThingMgr:removeObj(self:getType(), self:getID())
end
function Player:revive(data)
    --print("@玩家复活了~")
    -- if self.faBaoEct then
    --     self.faBaoEct.Visible = true
    -- end
    -- if self.xianQiEct then
    --     self.xianQiEct.Visible = true
    -- end
    self.character:Revive()
    self:setMaxHp(data.maxHp)
    self:setHp(data.currHp)
    self.data["isDead"] = false
    self:setFaqiEnabled()
    self:restoreBody()
end

function Player:isDeadState()
    return self.data["isDead"] or false
end

function Player:updateHp(value)
    if self.hp == nil then
        print("@玩家血量异常！")
        return
    end
    if self.hp > 0 then
        self:setHp(self.hp - value)
    else--玩家已经死亡了就不处理加减血逻辑
        self:setHp(0)
    end
    local sId = cache.PlayerCache:getSId()
    if sId == ArenaScene or sId == DiWangScene or sId == YiJiScene then
        local view = mgr.ViewMgr:get(ViewName.ArenaFightView)
        if view then
            view:updateHp(self.data.roleId,self:getHp())
        end
    end
    local view = mgr.ViewMgr:get(ViewName.PlayerHpView)
    if view then
        local data = view:getData()
        local roleId = data and data.roleId or 0
        if roleId == self.data.roleId then
            view:setHp(self.data)
        end
    end
end

--身体模型加载完毕回调
function Player:bodyLoad()
    --print("111Player bodyLoad")
    if self.hp == 0 then
        --print("")
        self:dead()
    end
    self:thingEcts()
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isWenDing(sId)
        or mgr.FubenMgr:isXianMoWar(sId)
        --[[or mgr.FubenMgr:isMeiliBeach(sId)--]] then
        return
    end
    if self.data.kind == PlayerKind.statue_new then
        return
    end

    if not self.isHome then
        if self.data.skins[Skins.xianqi] and  self.data.skins[Skins.xianqi] ~= 0 then
            self:addXianQi(self.data.skins[Skins.xianqi]) --4040201
        end
        if self.data.skins[Skins.fabao] and self.data.skins[Skins.fabao] ~= 0 then
            self:addFaBao(self.data.skins[Skins.fabao])  --4040301
        end
    else
        if self.shenBingEct then
            mgr.EffectMgr:removeEffect(self.shenBingEct)
            self.shenBingEct = nil
        end
    end
end

function Player:thingEcts()
    self:updateWeaponEct(self.data.skins[Skins.shenbing])  --4040401

    if self.data.skins and self.data.skins[Skins.qilinbi] and  self.data.skins[Skins.qilinbi]~=0 then
        self:addBodyEct(self.data.skins[Skins.qilinbi])
    end
    if self.data.skins and self.data.skins[Skins.halo] and  self.data.skins[Skins.halo]~=0 then
        self:addHaloEct(self.data.skins[Skins.halo])
    end
    if self.data.skins and self.data.skins[Skins.headwear] and  self.data.skins[Skins.headwear]~=0 then
        self:addHeadEct(self.data.skins[Skins.headwear])
    end
    if self.data.skins and self.data.skins[Skins.mianju] and  self.data.skins[Skins.mianju]~=0 then
        self:addMianJuEct(self.data.skins[Skins.mianju])
    end

    if self.data.skins and self.data.skins[Skins.qibing] and  self.data.skins[Skins.qibing]~=0 then
        self:addQiBingEct(self.data.skins[Skins.qibing])
    end
end

function Player:updateWeaponEct(eId)
    if eId and eId ~= 0 then
        self:addShenBing(eId)
        --self:addThingEct("weaponect", "weapon", eId)
    end
end

--变身
function Player:changeBody(args)
    self.skins = args
    self:setSkins(args[1], args[2], args[3])
    self.isChangeBody = true
    if isSelf then  --变身音效
        if self.sex == 1 then --男
            mgr.SoundMgr:playSound("nanbianshen")
        else
            mgr.SoundMgr:playSound("nvbianshen")
        end
    end
    --震屏
    UnityCamera:RoleJumpCameraShake(-5,0.04,3,0.04,0,0.04)
    self:setHeadBarPos()
end
function Player:restoreBody()
    if self.isChangeBody == true then
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isWenDing(sId) then--问鼎改变
            self:setWenDing()
        elseif mgr.FubenMgr:isXianMoWar(sId) then--仙魔战改变
            self:setXianMo()
        elseif mgr.FubenMgr:isXdzzWar(sId)or mgr.FubenMgr:isCdmhWar(sId) then--雪战改变
            self:setXdzz()
        elseif mgr.FubenMgr:isMeiliBeach(sId) then --沙滩
            local view = mgr.ViewMgr:get(ViewName.BeachMainView)
            if view then
                view:resetPlayer(self)
            end
        else
            local data = self.data
            local skins = data.skins
            self.skins = skins
            self:setSkins(skins[1], skins[2], skins[3])
        end
        --移除特效
        if self.bottomEffect then
            mgr.EffectMgr:removeEffect(self.bottomEffect)
            self.bottomEffect = nil
        end
        self.isChangeBody = false
    end
    self:setHeadBarPos()
end

function Player:flyUp(func)
    self.character:FlyUp(function()
        if self.xianQiEct then
            self.xianQiEct.Visible = false
        end
        if func then
            func()
        end
    end)
end

function Player:flyDown(func)
    self.character:FlyDown(function()
        -- if self.xianQiEct then
        --     self.xianQiEct.Visible = true
        -- end
        if func then
            func()
        end
    end)
    self:setFaqiEnabled()
end

function Player:setFaqiEnabled(b)
    local isPlayer = mgr.QualityMgr:getAllPlayer()
    local faqiEnabled = b
    local isFaqi = mgr.QualityMgr:getAllFaQi()
    if isPlayer then
        if not isFaqi then
            faqiEnabled = false
        else
            faqiEnabled = true
        end
    end
    local roleId = self.data and self.data.roleId or 0
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isWenDing(sId) then
        if roleId ~= cache.PlayerCache:getRoleId() and kind ~= PlayerKind.statue then
            faqiEnabled = false
        end
    elseif mgr.FubenMgr:isXianMoWar(sId) or mgr.FubenMgr:isXdzzWar(sId) then
        faqiEnabled = false
    end
    self:hitFaQi(faqiEnabled)
end

function Player:addMovieEct(ectId)
    if not self.movieEct then
        local parent = self:getRoot()
        self.movieEct = mgr.EffectMgr:playCommonEffect(ectId, parent)
        self.movieEct.LocalPosition = Vector3.zero
        self.movieEct.LocalRotation = StaticVector3.vector3Z180
    end
end
function Player:delMovieEct()
    if self.movieEct then
        mgr.EffectMgr:removeEffect(self.movieEct)
    end
    self.movieEct = nil
end

function Player:dispose()
    self:clearComponents()
    self:delMovieEct()
    if self.bottomEffect then
        mgr.EffectMgr:removeEffect(self.bottomEffect)
        self.bottomEffect = nil
    end
    if self.canSee == true then
        mgr.QualityMgr:delSeePlayerNums()
    end
    --清理新宠物
    --local pet = mgr.ThingMgr:getObj(ThingType.pet, self:getPetID())
    mgr.ThingMgr:removeObj(ThingType.pet, self:getPetID(), true)
    mgr.ThingMgr:removeObj(ThingType.pet, self:getXianTonID(), true)


    self:disposeExtend()
end


function Player:addBottomEffect(id)
    -- body
    self.bottomEffectID = id
    if self.bottomEffect then
        mgr.EffectMgr:removeEffect(self.bottomEffect)
        self.bottomEffect = nil
    end
    local bodyTransform = self.character.mRoot.mTransform
    self.bottomEffect = mgr.EffectMgr:playCommonEffect(id, bodyTransform)
    self.bottomEffect.LocalRotation = StaticVector3.vector3Z180
    self.bottomEffect.Scale = Vector3.one
end



return Player