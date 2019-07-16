--
-- Author: 
-- Date: 2017-12-26 16:18:20
--

local WarSkillView = class("WarSkillView", base.BaseView)

function WarSkillView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function WarSkillView:initView()
    self.testSkillIds = {
        5150201,
        5150301,
        5150401,
    }
    self.baseSkillId = 5150101
    self.skillIcons = {}

    self.coolDataTwo = {}
    self.coolData = {}
    self.skillCounts = {}
    self.skillBtnList = {}
    local baseBtn = self.view:GetChild("n302")
    table.insert(self.skillBtnList, baseBtn)
    baseBtn.onClick:Add(self.onClickSkillEvent, self)
    for i=5,7 do
        local skillBtn = self.view:GetChild("n30"..i)
        skillBtn.onClick:Add(self.onClickSkillEvent, self)
        table.insert(self.skillBtnList, skillBtn)
    end
    local changeTarBtn = self.view:GetChild("nchangetar")
    changeTarBtn.onClick:Add(self.onChangeSelectTar, self)
    local pickBtn = self.view:GetChild("n9")
    pickBtn.onClick:Add(self.onClickPick,self)
end

function WarSkillView:initData(data)
    self:setMainView()
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isXdzzWar(sId) then
        self.testSkillIds = {5150101,5150201,5150301,5150401}--技能1,2,3
        self.baseSkillId = 5150101
        local skillIcons = conf.ActivityWarConf:getSnowGlobal("skill_icons")
        self.skillIcons = {}
        for k,v in pairs(skillIcons) do
            table.insert(self.skillIcons, UIPackage.GetItemURL("track" , v))
        end
    end
    self:setBtnIcon()
    self:setSkillsCout(data.skills)
end

function WarSkillView:setBtnIcon()
    local sex = cache.PlayerCache:getSex()
    for k,btn in pairs(self.skillBtnList) do
        local mask = btn:GetChild("n6").asImage
        mask.fillAmount = 0
        local skillId = self.testSkillIds[k]
        local data = conf.SkillConf:getSkillConfByid(skillId)
        local preid = data and data.s_pre
        local coolTime = data and data.cool_time
        self.coolData[skillId] = {totalTime = coolTime, curTime = coolTime, btn=btn, cool=false}
        if k > 1 then
            btn.icon = self.skillIcons[k - 1]
        end
    end
end

function WarSkillView:setSkillsCout(skills)
    self.skillCounts = skills or self.skillCounts
    for i=2, 4 do
        local btn = self.skillBtnList[i]
        local skillId = self.testSkillIds[i]
        btn:GetChild("n12").text = self.skillCounts[skillId] or 0
    end
end

function WarSkillView:setData(data)

end

function WarSkillView:onClickSkillEvent(context)
    local btn = context.sender
    local key = btn.name
    if key == "n302" then--普通攻击
        self:skillAttack(self.testSkillIds[1])
    elseif key == "n305" then--技能1
        self:skillAttack(self.testSkillIds[2])
    elseif key == "n306" then--技能2
        self:skillAttack(self.testSkillIds[3])
    elseif key == "n307" then--技能3
        self:skillAttack(self.testSkillIds[4])
    end
end

function WarSkillView:skillAttack(skillId)
    if skillId ~= 5150401 then
        if gRole and gRole:isDingShen() then return end--眩晕冰冻无法操作
    end
    local count = self.skillCounts[skillId] or 0
    if self.baseSkillId ~= skillId then
        if count == 0 then
            GComAlter(language.ydact014)
            return
        else
            self.skillCounts[skillId] = self.skillCounts[skillId] - 1
        end
        mgr.InputMgr:IsJoystick()
        gRole:skillAttack(skillId)
        self:setSkillsCout()
    else
        mgr.InputMgr:IsJoystick()
        mgr.FightMgr:roleBattle(skillId)
    end
    self:coolDown(skillId)
end

function WarSkillView:coolDown(skillId)
    if not skillId then
        return
    end
    if not self.coolData[skillId] then return end
    for i=1, 4 do
        local key = self.testSkillIds[i]
        local coolInfo = self.coolData[key]
        if not coolInfo.cool then
            local data = conf.SkillConf:getSkillConfByid(skillId)
            local coolTime = data and data.cool_time
            if key == skillId then
                coolInfo.totalTime = coolTime
                coolInfo.curTime = coolTime
                coolInfo.cool = true
            else
                coolInfo.totalTime = 1
                coolInfo.curTime = 1
            end
            local btn = coolInfo.btn
            btn.touchable = false
            local totalT = coolInfo.totalTime
            local cutT = coolInfo.curTime
            local mask = btn:GetChild("n6").asImage
            local shap = btn:GetChild("n9")
            local delay = 0.2
            mask.fillAmount = 1-(totalT - cutT) / totalT
            local coolTimer = self:addTimer(delay, math.ceil(totalT/delay), function()
                self.coolData[key].curTime = self.coolData[key].curTime - delay
                local mask = btn:GetChild("n6").asImage
                mask.fillAmount = 1-(totalT - self.coolData[key].curTime) / totalT
                if self.coolData[key].curTime < 0.1 then
                    btn.touchable = true
                    self.coolData[key].curTime = self.coolData[key].totalTime
                    self.coolData[key].cool = false
                    mask.fillAmount = 0

                    if key == skillId then 
                        if shap.data then
                            self:removeUIEffect(shap.data)
                            shap.data = nil
                        end
                        shap.data = self:addEffect(4020106,shap)
                        shap.data.LocalPosition = Vector3.New(shap.width/2,-shap.height/2,-50)
                    end
                end
            end)
        end
        
    end
end
--拾取最近的采集物
function WarSkillView:onClickPick()
    if self.pickCdTime and Time.getTime() - self.pickCdTime <= 1 then
        return
    end
    if mgr.ViewMgr:get(ViewName.PickAwardsView) then
        return
    end
    local obj
    local things = mgr.ThingMgr:objsByType(ThingType.monster)
    local dis = 0
    for k, v in pairs(things) do
        if v:getKind() == MonsterKind.collection then
            local data = v.data
            local pos = Vector3.New(data.pox,gRolePoz,data.poy)
            local distance = GMath.distance(gRole:getPosition(), pos)
            if dis == 0 then
                dis = distance
            end
            if distance <= dis then
                dis = distance
                obj = v
            end 
        end
    end
    if obj then
        local data = obj.data
        local p = Vector3.New(data.pox, gRolePoz, data.poy)
        gRole:moveToPoint(p, PickDistance, function()
            proxy.ThingProxy:send(1810302,{roleId = obj:getID(),reqType = 1})
        end)
        self.pickCdTime = Time.getTime()
    end
end

function WarSkillView:onChangeSelectTar()
    fight.SelectRule:changeSelectThing()
end

function WarSkillView:setMainView()
    local t = {
        ["n211"] = 1,["n212"] = 1,["n278"] = 1,["n127"] = 1,["n363"] = 1,
        ["n357"] = 1,["n259"] = 1,["n126"] = 1,["n331"] = 1,["n123"] = 1,
        ["n364"] = 1,["n372"] = 1,["n125"] = 1,["n276"] = 1,["n140"] = 1,
        ["n130"] = 1,["n133"] = 1,["n381"] = 1,["n275"] = 1,["n378"] = 1,
        ["n376"] = 1,["n285"] = 1,["n223"] = 1,["n361"] = 1,["n2801"] = 1,
        ["n218"] = 1,["n219"] = 1,["n360"] = 1,["n195"] = 1,["n193"] = 1,
        ["n292"] = 1,["n293"] = 1,["n294"] = 1,["n295"] = 1,["n296"] = 1,
        ["n297"] = 1,["n298"] = 1,["n299"] = 1,["n300"] = 1,["n182"] = 1,
        ["n134"] = 1,["n135"] = 1,["n136"] = 1,["n137"] = 1,["n358"] = 1,
        ["n356"] = 1,["n501"] = 1,["n177"] = 1,
    }
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:setInfoVisble(t)
    end
end

return WarSkillView