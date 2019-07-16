--[[--
 NPC
]]

local Npc = class("Npc", import(".Thing"))

function Npc:ctor()
    self.headHeight = StaticVector3.playerHeadH
    self.tType = ThingType.npc
    --self.character = GameFramework.XNpc.New()
    self.character = UnityObjMgr:CreateThing(self.tType)
    self.headRes = "NpcHeadView"
    self:createHeadBar()
    self.delayDelTime = 0
end

function Npc:setData(data)
    local npcConf = conf.NpcConf:getNpcById(data.id)
    self:setID(data.id)
    local pos = npcConf["pos"]
    self.character.MapPosition = Vector3.New(pos[1], 0, pos[2])
    if npcConf["delay_del"] then
        self.delayDelTime = npcConf["delay_del"]
    end
    if npcConf.type == 5 then
        self.character.BodyID = ResPath.monsterRes(npcConf["body_id"])
    else
        self.character.BodyID = ResPath.npcRes(npcConf["body_id"])
    end
    
    if npcConf["height"] then
        self.headHeight = Vector3.New(0,-npcConf["height"],0)
        self.headBar.position = self.headHeight
    end
    if npcConf["shadow"] then
        self:hideShadow()
    end
    local str = npcConf.name--..mgr.TextMgr:getImg(UIItemRes.other02)
    if str then  --如果npc不配name属性。则去掉头顶信息
        self:setTitleName(str)
        if npcConf.type == 1 then
            if cache.TaskCache.npcTask[data.id] then
                if cache.TaskCache:CheckISLevelOver() then
                    self:addWenHao()
                else
                    self:removeWenHao()
                end
            else
                self:removeWenHao()
            end
        elseif npcConf.type == 5 then
            self:removeWenHao()
        end
        self.headBar.visible = true
    else
        self.headBar.visible = false
    end 
end

function Npc:dead()
    if not self.character then return end
    mgr.ThingMgr:removeObj(self:getType(), self:getID())
    local function beDead()
        self.character:PlayAnimationByName("dead")
        local p = GMath.dirDistanceB(gRole:getPosition(), self:getPosition(), 1000)
        local endPos = Vector2.New(p.x, p.z)
        --print("pos:", p.x, p.z, self:getPosition().x, self:getPosition().z)
        UTransition.TweenDead(self.character, endPos, 0.4 , function()
            mgr.TimerMgr:addTimer(1, 1, function()
                local parent = UnitySceneMgr.pStateTransform
                local e = mgr.EffectMgr:playCommonEffect(4040111, parent)
                if e then
                    e.LocalPosition = self:getPosition()
                end
                self:dispose()
            end)
        end)
    end
    if self.delayDelTime > 0 then
        mgr.TimerMgr:addTimer(self.delayDelTime, 1, function()
            beDead()
        end, "MovieDead")
    else
        beDead()
    end
end

function Npc:dead2()
    if not self.character then return end
    mgr.ThingMgr:removeObj(self:getType(), self:getID())
    self:dispose()
end

function Npc:setParent()
    self.character.Parent = UnitySceneMgr.pStateTransform
end

function Npc:removeWenHao()
    if self.headBar then
        self.headBar:GetChild("n1").url = nil 
        self.headBar:GetTransition("t0"):Stop()
    end
end

function Npc:addWenHao()
    if self.headBar then
        self.headBar:GetTransition("t0"):Play()
        self.headBar:GetChild("n1").url = UIItemRes.head01
    end
end

return Npc