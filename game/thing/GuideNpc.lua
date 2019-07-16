--
-- Author: 
-- Date: 2017-08-16 16:07:46
--

local GuideNpc = class("GuideNpc", import(".Player"))

local PetCancel
local PetIdle = 0
local PetWalk = 1
local PetPatrol = 2
local PetFight = 3
local UpdateTime = 0.5

function GuideNpc:ctor()
    self.headHeight = StaticVector3.playerHeadH
    self.headRes = "HeadView"
    self.tType = ThingType.player
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


    self.path = ArrayList.New()
    self.nextPoint = Vector2.zero

    self.skills = {{5010101,5010102,5010103,5010104,5010105,5010106,5010201,5010301,5010401},
                    {5020101,5020102,5020103,5020104,5020105,5020106,5020201,5020301,5020401}}
end

function GuideNpc:bodyLoad()
    if not self.timer then
        self.timer = mgr.TimerMgr:addTimer(UpdateTime, -1, handler(self, self.update), "Pet")
        self.stateTime = os.time()
    end
end

--初始化数据
function GuideNpc:setData(ownerData, ownerType)
    self:setBaseData(ownerData)

    self:updateWeaponEct(ownerData.skins[Skins.shenbing])
    if ownerData.skins[Skins.fabao] and ownerData.skins[Skins.fabao]~= 0 then
        self:addFaBao(ownerData.skins[Skins.fabao])
    end
    if ownerData.skins[Skins.xianqi] and ownerData.skins[Skins.xianqi]~= 0 then
        self:addXianQi(ownerData.skins[Skins.xianqi])
    end
    self:setCanSelect(false)
    if self.headBar then
        for i = 0 , self.headBar.numChildren-1 do 
            local var = self.headBar:GetChildAt(i)
            if var then
                var.visible = false
            end
        end
        self.headBar:GetChild("name").visible = true
    end
end

--[[
    --如果距离大于300则移动到主人旁边
        --进入待机状态
            --判断是否进入攻击状态
            --否则进入巡逻状态-停留5秒
]]
function GuideNpc:update()
    --宠物ai
    local owner = gRole
    if not owner then
        plog("宠物的主人不存在"..self.ownerID)
        return
    end
    local oPos = owner:getPosition()
    local dis = GMath.distance(oPos, self:getPosition())
    if dis > 500 then
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
        local isFight = gRole:isFight()
        if isFight then
            self.stateTime = self.stateTime + UpdateTime
            if self.stateTime > 1 then
                --TOOD 战斗
                --mgr.FightMgr:petBattle(5030101)
                self:createFightMsg()
                self.stateTime = 0
            end
        end
    end
end

--ai战斗
function GuideNpc:enterFight()
    self.curState = PetFight
    self.fightTime = os.time()
end

function GuideNpc:createFightMsg()
    local fightData = {}
    local roleId = self.data and self.data.roleId
    fightData.opt = tonumber(roleId)
    fightData.atkId = cache.PlayerCache:getRoleId()
    fightData.uTargets = {}
    local monsters = mgr.ThingMgr:objsByType(ThingType.monster)
    fightData.mTargets = {}
    local i = 0
    for k, v in pairs(monsters) do
        i = i + 1
        table.insert(fightData.mTargets, k)
        if i > 5 then
            break
        end
    end

    local sex = math.floor(self.data.roleIcon / 100000000)
    local s = self.skills[sex][math.random(6)]
    fightData.skillId = gRole:curUseSkill() or s
    local pos = self:getPosition()
    fightData.atkPox = pos.x
    fightData.atkPoy = pos.z
    fightData.tarPox = 0
    fightData.tarPoy = 0
    -- mgr.FightMgr:thingBattle(fightData)
    proxy.ThingProxy:sNpcBattle(fightData)
end

function GuideNpc:dispose()
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
    self.super.dispose(self)
end

return GuideNpc