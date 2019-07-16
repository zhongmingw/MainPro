--
-- Author: yr
-- Date: 2017-01-11 21:36:18
--

local Pet = class("Pet", import(".Thing"))

local PetCancel
local PetIdle = 0
local PetWalk = 1
local PetPatrol = 2
local PetFight = 3
local UpdateTime = 0.4

function Pet:ctor()
    self.headHeight = StaticVector3.petHeadH
    self.headRes = "HeadView3"
    self.tType = ThingType.pet
    self.character = UnityObjMgr:CreateThing(self.tType)
    self.ownerID = 0
    self.ownerType = 0
    self.curState = PetIdle
    self.stateTime = 0
    self.patrolPos = Vector3.New(0,-1500,0)
    self:regisCallBack()
    self:createHeadBar()

    self.attackId = nil
    self.attackType = 0
    self.fightTime = 0
    self.notTime = false

    self.path = ArrayList.New()
    self.nextPoint = Vector2.zero

    self.canSee = true
    self.waitAppear = true
    self.newpet = false
    self.xiantong = false
    self.speaklasttime = 0
end

function Pet:isNewPet()
    -- body
    return self.newpet or self.xiantong
    -- local id = string.sub(self.ownerID,1,string.utf8len(self.ownerID)-1 )
    -- if id == cache.PlayerCache:getRoleId() then
    --     return true
    -- end
    -- return false
end

function Pet:bodyLoad()
    if self:isNewPet() then
        return
    end
    if self.ownerData.roleId ~= cache.PlayerCache:getRoleId() and mgr.FubenMgr:isWenDing(cache.PlayerCache:getSId()) then
        return
    end
    self:updateWeaponEct(self.ownerData.skins[Skins.huobanshenbing])
    if self.ownerData.skins[Skins.huobanfabao] and self.ownerData.skins[Skins.huobanfabao]~= 0 then
        self:addFaBao(self.ownerData.skins[Skins.huobanfabao])
    end
    if self.ownerData.skins[Skins.huobanxianqi] and self.ownerData.skins[Skins.huobanxianqi]~= 0 then
        self:addXianQi(self.ownerData.skins[Skins.huobanxianqi])
    end
end

--初始化数据
function Pet:setData(ownerData, ownerType,flag,flag2)
    self.newpet = flag
    self.xiantong = flag2
    self.ownerData = ownerData
    self:setID(ownerData.roleId)
    self.ownerID = ownerData.roleId
    self.ownerType = ownerType
    local ownerKind = ownerData.kind or 0
    if ownerKind == PlayerKind.statue then--城主雕像的宠物
        self:ignoreHide(true)
        self.notTime = true
        self:setPosition(ownerData.pox + StatuePosX, ownerData.poy + StatuePosY)
        self:setModelLocalRotation(StaticVector3.diaoxiangPet)
    else
        self:setPosition(ownerData.pox, ownerData.poy)
    end
    if self:isMaster() then
        self.waitAppear = false
    end
    local id = 0
    if self:isNewPet() then
        if self.xiantong then
            self:setID(ownerData.xiantong_id)
            id = self.ownerData.skins[Skins.xiantong]
            if id == 0 then
                return
            end
             local condata = conf.MarryConf:getPetItem(id)
            if not condata then
                print("缺少仙童配置id",id)
                return
            end
            self:updtePetName(ownerData.xtName)
            self:setSkins(condata.model)
            self:setChenghao(1)
        else
            self:setID(ownerData.newpetid)
            id = self.ownerData.skins[Skins.newpet]
            if id == 0 then
                return
            end
            local condata = conf.PetConf:getPetItem(id)
            if not condata then
                print("缺少宠物配置id",id)
                return
            end
            self:updtePetName(ownerData.petName)
            self:setSkins(condata.model)
            self:setChenghao(1)
        end
    else
        id = self.ownerData.skins[Skins.huobanteshu]
        if not id or id==0 then
            id = self.ownerData.skins[Skins.huoban]
        end
        self:setSkins(id,nil,self.ownerData.skins[Skins.huobanxianyu])
        self:setPetName(ownerData)
        self:setChenghao(ownerData.partnerLevel)
    end
    if ownerData and ownerData.roleId ~= cache.PlayerCache:getRoleId() and ownerData.kind ~= 7 then
        local isPlayer = mgr.QualityMgr:getAllPlayer()
        local isPets = mgr.QualityMgr:getAllPets() or mgr.QualityMgr:getShieldAllPets()
        local isChenghao = mgr.QualityMgr:getAllChenghao()
        local enable = false
        local titleEnabled = false
        if isPlayer then
            if not isPets then
                enable = false
                titleEnabled = false
            else
                enable = true
                if not isChenghao then
                    titleEnabled = false
                else
                    titleEnabled = true
                end
            end
        else
            titleEnabled = false
            enable = false
        end
        self:hitChenghao(titleEnabled)
        self:hitHeadBar(enable)
        self:hitFaQi(enable)
    end

    if self:getID() == "1" or self:getID() == "2" or ownerKind == PlayerKind.statue then  --竞技场强制不隐藏-神坑
        self:ignoreHide(true)
    end

    if not self.timer and not self.notTime then
        self.timer = mgr.TimerMgr:addTimer(UpdateTime, -1, handler(self, self.update), "Pet")
        self.stateTime = os.time()
    end 
end

--屏蔽别人称号
function Pet:hitChenghao(isVisible)
    local title = self.headBar:GetChild("n10")
    if self:isNewPet() then
        title.visible = false
        return
    end

    --print("isVisible",self:getPetID(),isVisible)
    title.visible = isVisible
end

function Pet:setChenghao(lv)
    if self:isNewPet() or self:isSee() == false then
        if self.headBar then
            local title = self.headBar:GetChild("n10")
            title.visible = false
        end
        
        return
    end
    local confdata = conf.HuobanConf:getDataByLv(lv,0)
    local max = conf.HuobanConf:getValue("endmaxjie",0) or 11
    local jie = confdata.jie
    if jie <= 0 or jie > max then
        jie = 1
    end
    local title = self.headBar:GetChild("n10")
    title.url = ResPath:petChengHao(jie)
    title.visible = true
    --問鼎屏蔽
    if self.ownerData then
        if mgr.FubenMgr:isWenDing(cache.PlayerCache:getSId()) and self.ownerData.roleName ~= cache.PlayerCache:getRoleName() then
            title.visible = false
        end
    end
end

function Pet:updateWeaponEct(eId)
    if eId and eId ~= 0 then
        self:addShenBing(eId)
        --self:addThingEct("weaponect", "weapon", eId)
    end
end
--設置夥伴名字
function Pet:setPetName(ownerData)
    local name = ""
    local confdata = conf.HuobanConf:getSkinsByModel(ownerData.skins[Skins.huoban],0)
    local typeDec = ""
    --场景中灵童的类型标志删除
    -- if confdata and confdata.type then
    --     for k ,v in pairs(confdata.type) do
    --         typeDec = typeDec..mgr.TextMgr:getImg(UIItemRes.imagefons03[v])
    --     end
    -- end
    if ownerData.partnerName and ownerData.partnerName~="" then
        name = ownerData.partnerName
    else
        name = confdata and confdata.name or ""
    end
    self.titleName = name
    if self.headBar then
        local label = self.headBar:GetChild("name")--..
        -- if mgr.FubenMgr:isWenDing(cache.PlayerCache:getSId()) and ownerData.roleName ~= cache.PlayerCache:getRoleName() then
        --     label.text = language.wending06[1]
        -- else
            --如果是玩家自己的宠物添加标记-减少dc
            label.text = name
            -- if self:isMaster() then
            --     label.text = name..typeDec
            -- else
            --     label.text = name
            -- end
        -- end
    end
end

function Pet:updtePetName(name)
    if self.headBar then
        self.headBar:GetChild("name").text = name or self.titleName
    end
end

function Pet:isMaster()
    if self.ownerID == cache.PlayerCache:getRoleId() then
        return true
    elseif self:isNewPet() then
        return true
    end
    return false
end

function Pet:isSceneDispose()
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isXdzzWar(sId) or mgr.FubenMgr:isCdmhWar(sId) then 
        if self.ownerData then
            local roleId = self.ownerData.roleId
            if self.ownerData.newpetid and roleId ~= cache.PlayerCache:getRoleId() then
                mgr.ThingMgr:removeObj(ThingType.pet, roleId, true)
                mgr.ThingMgr:removeObj(ThingType.pet, self.ownerData.newpetid, true)
            end
        end
        return true
    end
    return false
end
--[[
    --如果距离大于300则移动到主人旁边
        --进入待机状态
            --判断是否进入攻击状态
            --否则进入巡逻状态-停留5秒
]]
function Pet:update()
    --宠物ai
    if self:isSceneDispose() then return end

    local owner = mgr.ThingMgr:getObj(self.ownerType, self.ownerID)
    if not owner then
        plog("宠物的主人不存在"..self.ownerID)
        return
    end

    local oPos = owner:getPosition()
    local dis = GMath.distance(oPos, self:getPosition())
    if dis > 800 then
        self:stopAI()
        self:setPosition(oPos.x, oPos.z)
    elseif dis > 200 then
        self.curState = PetWalk
        --TODO 跟随
        --local path = ArrayList.New()
        --path:Add(Vector2.New(oPos.x, oPos.z))
        self.nextPoint.x = oPos.x
        self.nextPoint.y = oPos.z
        self.path:Clear()
        self.path:Add(self.nextPoint)     
        self:moveToPath(self.path, 50, function()
            self.curState = PetCancel
        end)
    else
        if self.curState == PetWalk then
            return
        end
        if self.curState == PetFight then
            if os.time() - self.fightTime > 1.5 then
                self.curState = PetCancel
                return
            end
            self.stateTime = self.stateTime + UpdateTime
            if os.time() - self.stateTime > 1.2 then
                --TOOD 战斗
                --print("self.newpet",self.newpet,"self.xiantong",self.xiantong)
                if self.newpet then
                    local id = self.ownerData.skins[Skins.newpet]
                    if id == 0 then
                        return
                    end
                    local condata = conf.PetConf:getPetItem(id)
                    if not condata or not condata.init_skill then
                        return
                    end
                    local sid = condata.init_skill[1]
                    local skillConf = conf.PetConf:getPetSkillById(sid)
                    if not skillConf or not skillConf.skillid then
                        return
                    end

                    mgr.FightMgr:newPetBattle(skillConf.skillid )
                elseif self.xiantong then
                    local id = self.ownerData.skins[Skins.xiantong]
                    if id == 0 then
                        return
                    end
                    local condata = conf.MarryConf:getPetItem(id)
                    if not condata or not condata.init_skill then
                        return
                    end
                    local sid = condata.init_skill[1]
                    local skillConf = conf.MarryConf:getPetSkillById(sid)
                    if not skillConf or not skillConf.skillid then
                        return
                    end

                    mgr.FightMgr:newXianTongBattle(skillConf.skillid )
                else
                    mgr.FightMgr:petBattle(5030101)
                end
                self.stateTime = os.time()
                --self.fightTime = os.time()
                --self.curState = PetCancel
            end
        else
            if self.curState == PetPatrol then --巡逻 
                self.stateTime = self.stateTime + UpdateTime
                if self.stateTime > 3 then
                    self.stateTime = 0
                    self.curState = PetCancel
                end
            else  
                if self.curState == PetIdle then
                    self.stateTime = self.stateTime + UpdateTime
                    if self.stateTime > 3 then  
                        self.curState = PetPatrol
                        --TODO 进入巡逻
                        self.patrolPos.x = oPos.x + math.random(-80,80)
                        self.patrolPos.z = oPos.z + math.random(-80,80)
                        self.character:PetPatrol(self.patrolPos)
                        self.stateTime = 0
                    end
                else
                    --TODO 进入待机
                    self.curState = PetIdle
                end
            end
        end
    end


    if not self:isNewPet() and self.ownerID == cache.PlayerCache:getRoleId() then
        --说个话

        if self.speaklasttime == 0 then
            self.speaklasttime = os.time()
        end
        local petSpeakDelay = conf.HuobanConf:getValue("petSpeakDelay",0)
        if os.time() - self.speaklasttime >= petSpeakDelay then
            self.speaklasttime = os.time() --记录说话时间
            --需要区分玩家等级段，每个等级段配置不同的文本内容
            local confdata = conf.HuobanConf:getwordListByRoleLv()
            if confdata and confdata.world then
                if self.lastconf and self.lastconf.lv_begin == confdata.lv_begin  then
                    --每个等级段内容有多条，播放时，随机抽取（但不会连续抽取2条同样的内容）
                    if self.lastid then
                        --移除上次说过的
                        for k ,v in pairs(confdata.world) do
                            if v == self.lastid then
                                table.remove(confdata.world,k)
                                break
                            end
                        end
                    end
                end
                self.lastid = nil 
                self.lastconf = confdata
                --随机一个
                local number = #confdata.world
                if number > 0 then
                    local key = math.random(1,number)
                    self.lastid = confdata.world[key]
                    local cc = conf.HuobanConf:getHuobanWord(self.lastid)
                    if cc and cc.txt then
                        local txt = self.headBar:GetChild("n12")
                        if txt then
                            txt.text = cc.txt
                        end
                        local t0 = self.headBar:GetTransition("t0")
                        if t0 then
                            t0:Play()
                        end
                    end
                end
            end
        end
    end
end

--设置外部
function Pet:setSkins(body, weapon, wing)
    self.bodySrc = body
    self.weaponSrc = weapon
    self.wingSrc = wing
    if self:isSee() == false then
        --print("???",body)
        return
    end
    if body then
        --神兵特效
        if self.shenBingEct then
            mgr.EffectMgr:removeEffect(self.shenBingEct)
            self.shenBingEct = nil
        end
        self.character.BodyID = ResPath.petRes(body)
    end
    if weapon then
        self.character.WeaponID = ResPath.weaponRes(weapon)
    end
    if self.ownerData.roleId ~= cache.PlayerCache:getRoleId() and mgr.FubenMgr:isWenDing(cache.PlayerCache:getSId()) then
        self.character.WingID = "0"
        return
    end
    if wing then
        if wing == 0 then
            self.character.WingID = "0"
        else
            self.character.WingID = ResPath.wingRes(wing)
        end
    end
end

--宠物战斗
function Pet:enterFight()
    self.curState = PetFight
    self.fightTime = os.time()
    self.stateTime = 0
end

function Pet:dispose()
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
    self.path = nil
    self.nextPoint = nil
    self.super.dispose(self)
end

return Pet