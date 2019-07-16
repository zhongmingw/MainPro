--[[--
  目标选择规则
]]

local SelectRule = class("SelectRule")

function SelectRule:ctor()
    self.thingList = {}
    self.changeIndex = 0
    self.refreshTime = 0
end

function SelectRule:selectTars(skillInfo)
    if not skillInfo.mDir then return end  --没有攻击方向表示没有目标
    local areaConf = conf.FightConf:getAreaById(skillInfo.mAreaType)
    local t = areaConf["type"]
    if t == 1 then
        self:radiusRule(skillInfo, areaConf)
    elseif t == 2 then
        self:rectRule(skillInfo, areaConf)
    end
end

function SelectRule:radiusRule(skillInfo, areaConf)
    local center
    if areaConf["center"] == 1 then
        center = skillInfo.mAttack:getPosition()
    elseif areaConf["center"] == 2 then
        center = skillInfo.mDir
    end
    local radio = areaConf["radius"]
    local things = mgr.ThingMgr:objsByType(ThingType.monster)
    local maxCount = skillInfo.mAttackCount or 10

    if maxCount <= 1 then
        return
    end

    local maxNum = maxCount
    for k, v in pairs(things) do
        if v:canBeSelect() then
            local tpos = v:getPosition()
            local dis = GMath.distance(center, tpos)
            if dis <= radio then
                skillInfo:addTars(k, ThingType.monster)
                maxNum = maxNum - 1
                if maxNum <= 0 then
                    break
                end
            end
        end
    end

    local maxNum = maxCount
    local things = mgr.ThingMgr:objsByType(ThingType.player)
    for k, v in pairs(things) do
        if v:canBeSelect() then
            local tpos = v:getPosition()
            local dis = GMath.distance(center, tpos)
            if dis <= radio then
                skillInfo:addTars(k, ThingType.player)
                maxNum = maxNum - 1
                if maxNum <= 0 then
                    break
                end
            end
        end  
    end
end

function SelectRule:rectRule(skillInfo, areaConf)
    local yuandian = skillInfo.mAttack:getPosition()
    local from = (skillInfo.mDir - yuandian).normalized
    local radio = areaConf["radius"]
    local function checkRule(things, t, mount)
        local maxNum = mount
        for k, v in pairs(things) do
            if v:canBeSelect() then
                local tpos = v:getPosition()
                local to = (tpos - yuandian).normalized
                local jd = Vector3.Angle(from,to)
                if jd <= 90 then
                    local dis = GMath.distance(yuandian, tpos)
                    if dis < 1000 then
                        local chuizhi = math.sin(jd)*dis
                        if math.abs(chuizhi) <= radio then
                            skillInfo:addTars(k, t)
                        end
                        maxNum = maxNum - 1
                        if maxNum <= 0 then
                            break
                        end
                    end
                end
            end 
        end
    end
    local mts = mgr.ThingMgr:objsByType(ThingType.monster)
    local maxCount = skillInfo.mAttackCount or 15
    checkRule(mts, ThingType.monster, maxCount)
    local pts = mgr.ThingMgr:objsByType(ThingType.player)
    checkRule(pts, ThingType.player, maxCount)
end

function SelectRule:changeSelectThing(refresh)
    local count = #self.thingList
    if refresh or count <= 0 or (os.time() - self.refreshTime) > 5 then
        self.refreshTime = os.time()
        self.thingList = {}
        local center = gRole:getPosition()
        local function thingByDis(t)
            local things = mgr.ThingMgr:objsByType(t)
            for k, v in pairs(things) do
                if v:canBeSelect() then
                    local dis = 0
                    if g_var.gameFrameworkVersion >= 12 then
                        dis = v:getDistance()
                    else
                        tpos = v:getPosition()
                        dis = GMath.distance(center, tpos)
                    end
                    if dis <= 600 then
                        len = #self.thingList
                        if len == 0 then
                            local obj = {d=dis,type=t,id=k}
                            self.thingList[1] = obj
                        else
                            local suc = false
                            for i=1, len do
                                local obj = self.thingList[i]
                                if obj.d > dis then
                                    suc = true
                                    local nObj = {d=dis,type=t,id=k}
                                    table.insert(self.thingList, i, nObj)
                                    break
                                end
                            end
                            if suc == false then
                                local nObj = {d=dis,type=t,id=k}
                                table.insert(self.thingList, nObj)
                            end
                        end
                    end
                end
            end
        end

        thingByDis(ThingType.player)
        thingByDis(ThingType.monster)
    end
    count = #self.thingList
    if count > 0 then
        self.changeIndex = (self.changeIndex % count) + 1
        local obj = self.thingList[self.changeIndex]
        mgr.FightMgr:changeBattleTarget(false, obj.type, obj.id)
    end
end

return SelectRule