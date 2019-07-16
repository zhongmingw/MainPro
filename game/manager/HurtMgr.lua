--[[--
伤害飘字管理
]]

local HurtMgr = class("HurtMgr")

function HurtMgr:ctor()
    self.serverHurts = {}
    self.pools0 = {}
    self.pools1 = {}
    self.pools2 = {}
    self.pools3 = {}
    self.pools4 = {}
    self.labelCount = 0
end
--缓存服务端伤害数据
function HurtMgr:addServerHurts(data)
    --data.markTime = os.time()
    --data.step = 1
    --table.insert(self.serverHurts, data)

    self:handleHurt(data, 1)
end
--每帧刷伤害
function HurtMgr:update()
    --plog("HurtMgr:update()>>", #self.serverHurts)
    --[[local hLen = #self.serverHurts
    if hLen > 0 then
        for i=hLen, 1, -1 do
            local h = self.serverHurts[i]
            local skillConf = conf.FightConf:getSkillById(h.skillId)
            if not skillConf then
                table.remove(self.serverHurts, i)
                break
            end
            local netDelay = 0  --网络延迟补偿时间
            if gRole and h.atkId == gRole:getID() then
                netDelay = 0.2
            end
            local dTime = os.time() - h.markTime + netDelay
            local hDelays = skillConf["hurt_delay"]
            local step = h.step
            if skillConf and dTime >= hDelays[step] then
                self:handleHurt(h, step)
                if step == #hDelays then
                    table.remove(self.serverHurts, i)
                    break
                else
                    h.step = step + 1
                end
            end
        end
    end]]
end
--处理伤害数据
function HurtMgr:handleHurt(data, step)
    local function addHurts(fightTargets, t)
        local len = #fightTargets
        for i=1, len do
            self:flutHurt(fightTargets[i], t, data.atkId, data.opt, step, data.skillId)
        end
    end

    if data.uTargets then
        addHurts(data.uTargets, ThingType.player)
    end
    if data.mTargets then
        addHurts(data.mTargets, ThingType.monster)
    end
end
--单个事物的受击处理
function HurtMgr:flutHurt(fightTarget, t, atkId, opt, step, skillId)
    local tar
    local jianhao = ""
    local hurtId = fightTarget.roleId
    local hurtType
    if gRole and hurtId == gRole:getID() then  --玩家自己
        tar = gRole
        jianhao = "-"
        hurtType = ThingType.role
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isCollectTreasure(sId) or mgr.FubenMgr:isShenShou(sId) then--天晶洞窟活动打断采集--神兽岛
            --打断进度条
            -- if opt ~= 2 then--怪物攻击不打断
                CClearPickView()
                GCancelPick()
            -- end
        end
    else
        tar = mgr.ThingMgr:getObj(t, hurtId)
        if fightTarget.roleId == "1" then
            jianhao = "-"
        else
            jianhao = ""
        end
        hurtType = t
    end
    if tar then
        --伤害
        local hurtInfos = fightTarget.hurts 
        if hurtInfos then
            if hurtInfos[step] then
                local map = hurtInfos[step].hurts
                local shanghai = nil
                local piaozi = 0
                local hitTar = tar
                local isPet = ""
                if opt == 3 then
                    isPet = "f"
                elseif opt == 6 then
                    isPet = "g"
                elseif opt == 7 then
                    isPet = "h"
                end

                local fontType = 0--普通伤害
                for k, v in pairs(map) do
                    if k == 401 then  --普通伤害
                        tar:updateHp(v, atkId)
                        shanghai = isPet..jianhao..v
                        fontType = 0
                    elseif k == 402 then  --暴击伤害
                        tar:updateHp(v, atkId)
                        shanghai = isPet.."a"..jianhao..v
                        fontType = 1
                    elseif k == 403 then  --闪避
                        shanghai = isPet.."b"
                        piaozi = 90
                    elseif k == 404 then  --卓越伤害
                        tar:updateHp(v, atkId)
                        shanghai = isPet.."c"..jianhao..v
                        fontType = 3
                    elseif k == 405 then  --格挡
                        tar:updateHp(v, atkId)
                        shanghai = isPet.."d"..jianhao..v
                        piaozi = -120
                        fontType = 2
                    elseif k == 406 then  --反弹伤害
                        local atkTar
                        if opt == 1 or opt == 3 then
                            jianhao = "-"
                            if gRole:getID() == atkId then
                                atkTar = gRole
                            else
                                atkTar = mgr.ThingMgr:getObj(ThingType.player, atkId)
                            end
                        elseif opt == 2 then
                            jianhao = ""
                            atkTar = mgr.ThingMgr:getObj(ThingType.monster, atkId)
                        end
                        if atkTar then
                            atkTar:updateHp(v, atkId)
                            shanghai = "e"..jianhao..v
                            piaozi = -90
                            hitTar = atkTar
                            fontType = 0
                        else
                            plog("[异常]-HurtMgr:flutHurt>>反弹伤害找不到目标",atkId, opt)
                        end
                    elseif k == 407 then  -- 影卫伤害
                        tar:updateHp(v, atkId)
                        shanghai = jianhao..v
                        fontType = 1
                    elseif k == 408 then  -- BUFF伤害加成(+)/降低(-)
                        tar:updateHp(v, atkId)
                        shanghai = jianhao..v
                        fontType = 0
                    end
                    if shanghai then
                    
                        self:displayLabel(hitTar, atkId, shanghai, piaozi,fontType, skillId, hurtId, hurtType)
                    end
                end
            end
        end
        --Buffs 伤害
        local buffs = fightTarget.buffs
        if buffs then
            
        end
    end
end

function HurtMgr:thingHurt(tar, atkId, v)
    --print("@触发回血", v)
    --tar:updateHp(-v)
    if v > 0 then
        self:displayLabel(tar, atkId, "+"..v, 0,4)
    else
        if tar:getID() ~= gRole:getID() then
            v = -1*v
        end
        self:displayLabel(tar, atkId, v, 0,0)
    end
    
end

--[[
** 0、普通伤害红色
** 1、暴击黄色
** 2、格挡蓝色
** 3、卓越伤害紫色
]]
function HurtMgr:displayLabel(tar, atkId, v, t, fontType, skillId, hurtId, hurtType)
    if atkId ~= gRole:getID() and self.labelCount > 20 then
        return
    end
    if skillId and tar:getHp() > 0 then
        local skillConf = conf.FightConf:getSkillById(skillId)
        local delay = skillConf["hurt_delay"][1]
        mgr.TimerMgr:addTimer(delay, 1, function()
            local hurtTar = mgr.ThingMgr:getObj(hurtType, hurtId)
            if hurtTar then
                local label = self:createLabel(v, fontType)
                hurtTar.headBar:AddChildAt(label,hurtTar.headBar.numChildren)
                self:tweenLabel(label, t, fontType)
            end
        end, "hurtMgr")
    else
        local label = self:createLabel(v, fontType)
        tar.headBar:AddChildAt(label,tar.headBar.numChildren)
        self:tweenLabel(label, t, fontType)
    end
end

function HurtMgr:createLabel(str, fontType)
    local label
    local pools = self["pools"..fontType]
    if #pools > 0 then
        label = table.remove(pools, 1)
        label.visible = true
    else
        label = UIPackage.CreateObject("head", "HurtLabel"..fontType)
    end
    label:GetChild("n0").text = str
    label:SetXY(40,80)
    self.labelCount = self.labelCount + 1
    return label
end

function HurtMgr:tweenLabel(label, move, t)
    --mgr.QualityMgr:beginSample("HurtMgr:tweenLabel")
    UTransition.TweenBattleFly2(label, move, function()
        local pools = self["pools"..t]
        if #pools < 12 then
            label:RemoveFromParent()
            label.visible = false
            label.alpha = 1
            table.insert(pools, label)
        else
            label:Dispose()
        end
        self.labelCount = self.labelCount - 1
    end)
    --mgr.QualityMgr:endSample()
end

function HurtMgr:dispose(isThorough)
    self.serverHurts = {}
    if isThorough then
        for i=0, 4 do
            local pools = self["pools"..i]
            for i=#pools, 1, -1 do
                local label = pools[i]
                label:Dispose()
            end
            self["pools"..i] = {}
        end
        if UIPackage.GetByName("head") then
            UIPackage.RemovePackage("head")
        end
        
    end
end

return HurtMgr