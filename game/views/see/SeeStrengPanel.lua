--
-- Author: 
-- Date: 2017-09-16 12:39:45
--

local SeeStrengPanel = class("SeeStrengPanel",import("game.base.Ref"))

local equipNum = 12

function SeeStrengPanel:ctor(mParent)
    self.mParent = mParent
    self.strengTime = 0--刚刚强化的时间
    self.strenLev = 0--当前强化等级
    self.maxLv = 0--最大强化等级
    self.costMoney = 0
    self:initPanel()
end

function SeeStrengPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n24")
    self.attCurText = panelObj:GetChild("n31")--当前属性
    self.attCurText.text =  ""
    self.attNextText = panelObj:GetChild("n41")--下一级属性
    self.attNextText.text =  ""
    self.curPowerText = panelObj:GetChild("n38")--当前战力
    self.curPowerText.text = 0
    self.nextPowerText = panelObj:GetChild("n48")--下一级战力
    self.nextPowerText.text = 0
    self.curEquipObj = panelObj:GetChild("n49")--当前装备
    self.nextEquipObj = panelObj:GetChild("n50")--下一级装备

    local equipPanel = panelObj:GetChild("n0")
    self.controller = equipPanel:GetController("c1")--主控制器
    self.equipList = {}
    for i=1,equipNum do
        local num = i + 70
        local equipObj = equipPanel:GetChild("n"..num)
        equipObj.onClick:Add(self.onClickTip,self)
        table.insert(self.equipList,equipObj)
    end

    self.strenText = panelObj:GetChild("n27")
    self.arrowLast = panelObj:GetChild("n22")--最后的箭头
    
    local strenAttiBtn = panelObj:GetChild("n51")
    strenAttiBtn.onClick:Add(self.onClickStrenAtt, self)
end

function SeeStrengPanel:getEquipByIndex(index)
    for k,v in pairs(self.equips) do
        if v.index == index then
            return v
        end
    end
end

function SeeStrengPanel:setData(data,equips)
    self.data = data
    self.equips = equips
    self:setStrengData()
end

function SeeStrengPanel:setStrengData()
    local selectedIndex = self.controller.selectedIndex
    local part = selectedIndex + 1
    self.part = part
    local data = cache.PackCache:getForgData(part)--返回该部位的数据
    if data then
        local strenLev = data.strenLev
        self.strenLev = strenLev
        self.strenText.text = strenLev
        local maxLvl = conf.ForgingConf:getValue("streng_maxlvl")--强化最高等级
        local nextLvl = strenLev + 1--下一级强化等级
        if strenLev >= maxLvl then nextLvl = strenLev end
        self.nextLvl = nextLvl
        local strengMaxlvl = conf.ForgingConf:getValue("streng_noteq_maxlvl")--无装备强化最高等级
        local equip = self:getEquipByIndex(Pack.equip + self.part)
        if equip then
            local stageLvl = conf.ItemConf:getStagelvl(equip.mid) or 0
            local confDzData = conf.ForgingConf:getStageDuanzao(stageLvl)
            strengMaxlvl = confDzData and confDzData.streng_max_lvl or nextLvl
        else
            strengMaxlvl = nextLvl
        end
        self.maxLv = strengMaxlvl
        self:setAttCurData()
        self:setAttNextData()
        self:refreshEquip()
    end
end
--当前强化
function SeeStrengPanel:setAttCurData()
    local confData = conf.ForgingConf:getStrenAttData(self.strenLev,self.part) or {}
    for k ,v in pairs(confData) do
        if string.find(k,"att_") then --这个是属性
            local strList = string.split(k, "_")
            self.attCurText.text =  conf.RedPointConf:getProName(strList[2]).." "..v
        end
    end
    self.curPowerText.text = confData and confData.power or 0--战斗力
    self:setEquipData(self.curEquipObj,self.part)
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
function SeeStrengPanel:setAttNextData()
    self:setEquipData(self.nextEquipObj,self.part)
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
end

function SeeStrengPanel:refreshEquip()
    for k,v in pairs(self.equipList) do
        local data = self.data.partInfos[k]
        if data then
            local lvText = v:GetChild("n8")
            local arrow = v:GetChild("n9")
            arrow.visible = false
            if data.strenLev > 0 then
                lvText.visible = true
                lvText.text = "+"..data.strenLev
            else
                lvText.visible = false
            end
            self:setEquipData(v,k)
        end
    end
end

--装备信息
function SeeStrengPanel:setEquipData(obj,part)
    local icon = obj:GetChild("icon")
    local equipObj = obj:GetChild("n11")
    local equipData = self:getEquipByIndex(Pack.equip + part)--同部位的装备
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

function SeeStrengPanel:onClickTip()
    local selectedIndex = self.controller.selectedIndex
    local part = selectedIndex + 1
    local data = cache.PackCache:getForgData(part)
    if data then
        mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
            view:setData(1,data)
        end)
    end
    self:setStrengData()
end

function SeeStrengPanel:onClickStrenAtt()
    if not self.data then return end
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        view:setForgData(self.data.partInfos)
        view:setData(9)
    end)
end

return SeeStrengPanel