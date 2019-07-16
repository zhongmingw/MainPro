--
-- Author: yr
-- Date: 2017-01-11 21:36:18
--

local AIPlayer = class("AIPlayer", import(".Player"))

local PetCancel
local PetIdle = 0
local PetWalk = 1
local PetPatrol = 2
local PetFight = 3
local UpdateTime = 0.5

function AIPlayer:ctor()
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

function AIPlayer:bodyLoad()
    if not self.timer then
        self.timer = mgr.TimerMgr:addTimer(UpdateTime, -1, handler(self, self.update), "Pet")
        self.stateTime = os.time()
    end
end

--初始化数据
function AIPlayer:setData(ownerData, ownerType)
    self:setBaseData(ownerData)

    self:updateWeaponEct(ownerData.skins[Skins.shenbing])
    if ownerData.skins[Skins.fabao] and ownerData.skins[Skins.fabao]~= 0 then
        self:addFaBao(ownerData.skins[Skins.fabao])
    end
    if ownerData.skins[Skins.xianqi] and ownerData.skins[Skins.xianqi]~= 0 then
        self:addXianQi(ownerData.skins[Skins.xianqi])
    end
end

--[[
    --如果距离大于300则移动到主人旁边
        --进入待机状态
            --判断是否进入攻击状态
            --否则进入巡逻状态-停留5秒
]]
function AIPlayer:update()
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
end

--ai战斗
function AIPlayer:enterFight()
    self.curState = PetFight
    self.fightTime = os.time()
end

function AIPlayer:createFightMsg()
    local fightData = {}
    fightData.opt = 1
    fightData.atkId = self:getID()
    fightData.uTargets = {}
    local monsters = mgr.ThingMgr:objsByType(ThingType.monster)
    fightData.mTargets = {}
    local i = 1
    for k, v in pairs(monsters) do
        i = i + 1
        local ft = {}
        ft.roleId = k
        ft.hurts = {{setp=1,hurts={},buffs={}}}
        ft.hurts[1].hurts[401] = 1
        table.insert(fightData.mTargets, ft)
        if i > 5 then
            break
        end 
    end
    local sex = math.floor(self.data.roleIcon / 100000000)
    local s = self.skills[sex][math.random(9)]
    fightData.skillId = s
    fightData.atkPox = self:getPosition().x
    fightData.atkPoy = self:getPosition().z
    fightData.tarPox = 0
    fightData.tarPoy = 0
    mgr.FightMgr:thingBattle(fightData)
end

function AIPlayer:dispose()
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
    self.super.dispose(self)
end

return AIPlayer