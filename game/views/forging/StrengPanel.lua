--
-- Author: ohf 
-- Date: 2017-02-07 14:38:26
--
--强化区域
local StrengPanel = class("StrengPanel",import("game.base.Ref"))

local equipNum = 12
local effectId = 4020106

function StrengPanel:ctor(mParent)
    self.mParent = mParent
    self.strengTime = 0--刚刚强化的时间
    self.strenLev = 0--当前强化等级
    self.maxLv = 0--最大强化等级
    self.costMoney = 0--强化铜钱
    self.costMoney2 = 0--一键强化铜钱
    self:initPanel()
end

function StrengPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n11")
    self.attCurText = panelObj:GetChild("n31")--当前属性
    self.attCurText.text =  ""--conf.RedPointConf:getProName(v).." "..0      --language.jueseprops[v]
    self.attNextText = panelObj:GetChild("n41")--下一级属性
    self.attNextText.text =  ""
    self.curPowerText = panelObj:GetChild("n38")--当前战力
    self.curPowerText.text = 0
    self.nextPowerText = panelObj:GetChild("n48")--下一级战力
    self.nextPowerText.text = 0
    self.curEquipObj = panelObj:GetChild("n54")--当前装备
    self.nextEquipObj = panelObj:GetChild("n55")--下一级装备

    local equipPanel = panelObj:GetChild("n0")
    self.controller = equipPanel:GetController("c1")--主控制器
    self.equipList = {}
    for i=1,equipNum do
        local num = i + 70
        local equipObj = equipPanel:GetChild("n"..num)
        equipObj.onClick:Add(self.onClickTip,self)
        table.insert(self.equipList,equipObj)
    end

    self.goldText1 = panelObj:GetChild("n49")--强化金钱
    self.goldText1.text = 0
    self.goldText2 = panelObj:GetChild("n50")--一键强化金钱
    self.goldText2.text = 0
    local strengBtn = panelObj:GetChild("n29")--强化按钮
    self.strengBtn = strengBtn
    strengBtn.data = 1
    strengBtn.onClick:Add(self.onClickStreng,self)

    local descText = panelObj:GetChild("n26")
    descText.text = language.forging4
    self.strenText = panelObj:GetChild("n27")
    self.arrowLast = panelObj:GetChild("n22")--最后的箭头

    self.yjqhBtn = panelObj:GetChild("n30")--一键强化
    self.yjqhBtn.data = 2
    self.yjqhBtn.onClick:Add(self.onClickStreng,self)

    local helpBtn = panelObj:GetChild("n51")--帮助
    helpBtn.onClick:Add(self.onClickHelp, self)

    local strenAttiBtn = panelObj:GetChild("n56")
    strenAttiBtn.onClick:Add(self.onClickStrenAtt, self)
end
--刷新红点
function StrengPanel:refreshRed()
    local redKey = attConst.A10229
    local redNum = cache.PlayerCache:getRedPointById(redKey) or 0
    local money = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
    local redVisile = false
    if redNum > 0 then
        if money >= self.costMoney and self.strenLev < self.maxLv then
            redVisile = true
        end
    else
        GCloseAdvTip(1029)
    end
    self.yjqhBtn:GetChild("red").visible = redVisile
    self.strengBtn:GetChild("red").visible = redVisile
end

function StrengPanel:setData()
    self.isRef = true
    self:setStrengData()
    self:playEffect()
end

function StrengPanel:setStrengData()
    local selectedIndex = self.controller.selectedIndex
    local part = selectedIndex + 1
    self.part = part
    local data = cache.PackCache:getForgData(part)--返回该部位的数据
    if data then
        local strenLev = data.strenLev
        self.strenLev = strenLev
        self.strenText.text = strenLev
        self.maxLv,self.nextLvl = self:getMaxLvAndNextLv(strenLev,part)
        self:setAttCurData()
        self:setAttNextData()
        self:refreshEquip()
    end
    self:refreshRed()
end

function StrengPanel:getMaxLvAndNextLv(strenLev,part)
    local maxLvl = conf.ForgingConf:getValue("streng_maxlvl")--强化最高等级
    local nextLvl = strenLev + 1--下一级强化等级
    if strenLev >= maxLvl then nextLvl = strenLev end
    local strengMaxlvl = conf.ForgingConf:getValue("streng_noteq_maxlvl")--无装备强化最高等级
    local equip = cache.PackCache:getEquipDataByPart(part)
    if equip then
        local stageLvl = conf.ItemConf:getStagelvl(equip.mid) or 0
        local confDzData = conf.ForgingConf:getStageDuanzao(stageLvl)
        strengMaxlvl = confDzData and confDzData.streng_max_lvl or strengMaxlvl
    else
        if strenLev >= strengMaxlvl then
            strengMaxlvl = strenLev
        end
    end
    return strengMaxlvl,nextLvl
end
--当前强化
function StrengPanel:setAttCurData()
    local confData = conf.ForgingConf:getStrenAttData(self.strenLev,self.part) or {}
    for k ,v in pairs(confData) do
        if string.find(k,"att_") then --这个是属性
            local strList = string.split(k, "_")
            self.attCurText.text =  conf.RedPointConf:getProName(strList[2]).." "..v
        end
    end
    self.curPowerText.text = confData and confData.power or 0--战斗力
    self:setEquipData(self.curEquipObj,self.part)
    self.curEquipObj.icon = UIItemRes.part[self.part]
    local curText = self.curEquipObj:GetChild("n8")--当前部位
    if self.strenLev > 0 then
        curText.visible = true
        if self.strenLev >= self.maxLv then--最大值
            curText.text = language.forging3 
        else
            curText.text = "+"..self.strenLev
        end
    else
        curText.visible = false
    end
end
--下级强化
function StrengPanel:setAttNextData()
    self:setEquipData(self.nextEquipObj,self.part)
    self.nextEquipObj.icon = UIItemRes.part[self.part]
    local nextText = self.nextEquipObj:GetChild("n8")--下级部位
    nextText.visible = true
    if self.strenLev >= self.maxLv then--最大值
        nextText.text = language.forging3 
        self.arrowLast.visible = false
        self.attNextText.text = language.gonggong13
        self.nextPowerText.text = language.gonggong13
    else
        local strenLev = self.strenLev + 1
        nextText.text = "+"..strenLev
        self.arrowLast.visible = true
        local nextConfData = conf.ForgingConf:getStrenAttData(self.nextLvl,self.part) or {}
        for k ,v in pairs(nextConfData) do
            if string.find(k,"att_") then --这个是属性
                local strList = string.split(k, "_")
                self.attNextText.text = v
            end
        end
        self.nextPowerText.text = nextConfData and nextConfData.power or 0
    end
    --消耗铜钱
    self.costMoney = self:getConstMoney(self.part,self.strenLev)
    self.goldText1.text = self.costMoney--強化所需要的金钱

    self.costMoney2 = 0
    local forgData = cache.PackCache:getForgData()--锻造数据
    local strengMaxlvl = self:getMaxLvAndNextLv(self.strenLev,self.part)
    if strengMaxlvl > self.strenLev then
        for i=self.strenLev,strengMaxlvl - 1 do
            self.costMoney2 = self.costMoney2 + self:getConstMoney(self.part,i)
        end
    end
    self.goldText2.text = self.costMoney2--一键强化所消耗的铜钱
end

function StrengPanel:getConstMoney(part,strenLev)
    local constMoney = 0
    local id = conf.ForgingConf:getForgingPart(part) * 1000 + strenLev
    local data = conf.ForgingConf:getEquipStren(id)
    if data then
        constMoney = data.cost_money
    end
    return constMoney
end

function StrengPanel:refreshEquip()
    local forgData = cache.PackCache:getForgData()
    local money = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
    local redNum = 0
    for k,v in pairs(self.equipList) do
        local data = forgData[k]
        if data then
            local arrow = v:GetChild("n9")
            local strengMaxlvl = self:getMaxLvAndNextLv(data.strenLev,data.part)
            --消耗铜钱
            local constMoney = 0
            local id = conf.ForgingConf:getForgingPart(k) * 1000 + data.strenLev
            local confData = conf.ForgingConf:getEquipStren(id)
            if confData and tonumber(confData.id) == id then
                constMoney = confData.cost_money
            end
            if money >= constMoney and data.strenLev < strengMaxlvl then
                arrow.visible = true
                redNum = redNum + 1
            else
                arrow.visible = false
            end
            local lvText = v:GetChild("n8")
            if data.strenLev > 0 then
                lvText.visible = true
                lvText.text = "+"..data.strenLev
            else
                lvText.visible = false
            end
            self:setEquipData(v,k)
        end
    end
    local cacheRed = cache.PlayerCache:getRedPointById(attConst.A10229)
    if cacheRed > 0 and redNum == 0 then--如果没有可强化的就刷新红点
        mgr.GuiMgr:redpointByVar(attConst.A10229,0)
    end
end

--装备信息
function StrengPanel:setEquipData(obj,part)
    local icon = obj:GetChild("icon")
    local equipObj = obj:GetChild("n11")
    local equipData = cache.PackCache:getEquipDataByPart(part)--同部位的装备
    if equipData then
        icon.visible = false
        local _tt = clone(equipData)
        _tt.isquan = true
        GSetItemData(equipObj,_tt)
    else
        equipObj.visible = false
        icon.visible = true
    end
end
--强化特效
function StrengPanel:playEffect()
    local cdTime = Time.getTime() - self.strengTime
    local confEffectData = conf.EffectConf:getEffectById(effectId)
    local confTime = confEffectData and confEffectData.durition_time or 0
    if cdTime >= confTime * 0.5 then
        if cache.PackCache:getIsStreng() then
            local effectPanel = self.nextEquipObj:GetChild("n10")
            self.mParent:addEffect(effectId, effectPanel)
            self.strengTime = Time.getTime()
            mgr.SoundMgr:playSound(Audios[2])
        end 
    end
    cache.PackCache:setIsStreng(nil)
end

function StrengPanel:onClickTip()
    -- local selectedIndex = self.controller.selectedIndex
    -- local part = selectedIndex + 1
    -- local data = cache.PackCache:getForgData(part)
    -- if data then
    --     mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
    --         view:setData(1,data)
    --     end)
    -- end
    self:setStrengData()
end

function StrengPanel:onClickStreng(context)
    if not self.isRef then return end
    if self.strenLev >= self.maxLv then
        GComAlter(language.forging14)
        return
    end
    local forgData = cache.PackCache:getForgData()
    local money = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
    local tag = context.sender.data--=1单次强化,=2一键强化
    --根据活动条件弹窗alert6
    local confChargeData = conf.VipChargeConf:getDataById(7)
    -- if GFirstChargeIsOpen() and not GGetFirstChargeState(confChargeData.charge_grade) then 
        local param = {}
        param.mId = MoneyPro2[MoneyType.bindCopper]
        if not GGetFirstChargeState(confChargeData.charge_grade) then
            param.index = 7
        else
            param.index = nil
        end
        if money < self.costMoney and tag == 1 then--强化不够钱
            GGoBuyItem(param)
            return
        end
        if money < self.costMoney and tag == 2 then--一键强化不够钱
            GGoBuyItem(param)
            return
        end
    -- end
    local selectedIndex = self.controller.selectedIndex
    local part = selectedIndex + 1
    local tag = context.sender.data--=1单次强化,=2一键强化
    proxy.ForgingProxy:send(1100102,{reqType = tag,part = part})
end

function StrengPanel:clear()
    self.isRef = nil
end

--帮助
function StrengPanel:onClickHelp()
    GOpenRuleView(1003)
end

function StrengPanel:onClickStrenAtt()
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        view:setData(9)
    end)
end

return StrengPanel