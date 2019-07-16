--
-- Author: 
-- Date: 2017-09-16 12:40:02
--

local SeeStarPanel = class("SeeStarPanel",import("game.base.Ref"))

function SeeStarPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function SeeStarPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n25")
    
    local equipPanel = panelObj:GetChild("n0")
    self.controller = equipPanel:GetController("c1")--主控制器
    self.controller.onChanged:Add(self.selelctPart,self)--给控制器获取点击事件
    self.equipList = {}
    for i=71,82 do
        local equipObj = equipPanel:GetChild("n"..i)
        table.insert(self.equipList,equipObj)
    end
    local starPanel = panelObj:GetChild("n899")
    self.starC1 = starPanel:GetController("c1")
    self.starLvText = panelObj:GetChild("n111")

    local equipCur = panelObj:GetChild("n42")--当前部位
    self.equipCur = equipCur
    self.curIcon = equipCur:GetChild("icon")
    local equipNext = panelObj:GetChild("n43")--下一级部位
    self.equipNext = equipNext
    self.nextIcon = equipNext:GetChild("icon")
    --当前
    self.defCur = panelObj:GetChild("n114")
    self.ackCur = panelObj:GetChild("n115")
    self.breathCur = panelObj:GetChild("n116")
    self.powerCur = panelObj:GetChild("n117")--战斗力
    --下一级
    self.defNext = panelObj:GetChild("n118")
    self.ackNext = panelObj:GetChild("n119")
    self.breathNext = panelObj:GetChild("n120")
    self.powerNext = panelObj:GetChild("n121")--战斗力

    --升星总属性
    local starAttBtn = panelObj:GetChild("n96")
    starAttBtn.onClick:Add(self.onClickStarAtt,self)    
    --升星套装
    local starSuitBtn = panelObj:GetChild("n100")
    starSuitBtn.onClick:Add(self.onClickStarSuit,self)   
    self.arrowLast = panelObj:GetChild("n41")
end

function SeeStarPanel:setData(data,equips)
    self.data = data
    self.equips = equips
    self:refreshEquip()
    self:selelctPart()
end

function SeeStarPanel:getEquipByIndex(index)
    for k,v in pairs(self.equips) do
        if v.index == index then
            return v
        end
    end
end

function SeeStarPanel:refreshEquip()
    local forgData = self.data.partInfos
    for k,v in pairs(self.equipList) do
        local data = forgData[k]
        if data then
            self:setEquipData(v,k)
            local lvText = v:GetChild("n8")
            self:setEquipData(v,k)
            if data.starLev > 0 then
                lvText.visible = true
                lvText.text = "+"..data.starLev
            else
                lvText.visible = false
            end
        end
    end
end

--装备信息
function SeeStarPanel:setEquipData(obj,part)
    local icon = obj:GetChild("icon")
    local equipObj = obj:GetChild("n11")
    local equipData = self:getEquipByIndex(Pack.equip + part)--同部位的装备
    if equipData then
        icon.visible = false
        local _t = clone(equipData)
        _t.isquan = true
        GSetItemData(equipObj,_t)
    else
        equipObj.visible = false
        icon.visible = true
    end
end
--选择装备部位
function SeeStarPanel:selelctPart()
    local selectedIndex = self.controller.selectedIndex
    local part = selectedIndex + 1
    local data = self.data.partInfos[part]--返回该部位的数据
    if data then
        self.curIcon.url = UIItemRes.partSee[part]
        self.nextIcon.url = UIItemRes.partSee[part]
        self.starLev = data.starLev
        local starNum = GGetStarLev(self.starLev)[2]
        self.maxlv = conf.ForgingConf:getStarMaxLv(part)
        if starNum == 0 then
            self.starC1.selectedIndex = starNum
        else
            self.starC1.selectedIndex = starNum + 10 
        end
        self.starLvText.text = self.starLev
        self.part = part
        self:setAttData()
        self:setAttNextData()
    end
end
--当前属性
function SeeStarPanel:setAttData()
    --当前
    local confData1 = conf.ForgingConf:getStarData(self.part,self.starLev)
    self.isAmount = false
    if confData1 then
        local t = GConfDataSort(confData1)
        if #t <= 0 then--没有属性的情况
            local confData2 = conf.ForgingConf:getStarData(self.part,self.starLev + 1)
            local t2 = GConfDataSort(confData2)
            for k,v in pairs(t2) do
                if k == 1 then
                    self.defCur.text = conf.RedPointConf:getProName(v[1]).." 0"
                elseif k == 2 then
                    self.ackCur.text = conf.RedPointConf:getProName(v[1]).." 0"
                elseif k == 3 then
                    self.breathCur.text = conf.RedPointConf:getProName(v[1]).." 0"
                end
            end
        else
            for k,v in pairs(t) do
                if k == 1 then
                    self.defCur.text = conf.RedPointConf:getProName(v[1]).." "..v[2]
                elseif k == 2 then
                    self.ackCur.text = conf.RedPointConf:getProName(v[1]).." "..v[2]
                elseif k == 3 then
                    self.breathCur.text = conf.RedPointConf:getProName(v[1]).." "..v[2]
                end
            end
        end
        local power = confData1.power or 0
        self.powerCur.text = conf.RedPointConf:getProName(501).." "..power

        local cost_star = confData1.cost_star
        local curText = self.equipCur:GetChild("n8")--当前部位
        if self.starLev > 0 then
            curText.visible = true
            if self.starLev >= self.maxlv then--最大值
                curText.text = language.forging3 
            else
                curText.text = "+"..self.starLev
            end
        else
            curText.visible = false
        end
    end
    self:setEquipData(self.equipCur,self.part)
end

--下一级属性
function SeeStarPanel:setAttNextData()
    local nextText = self.equipNext:GetChild("n8")--当前部位
    local confData = conf.ForgingConf:getStarData(self.part,self.starLev + 1)
    if confData then
        local t = GConfDataSort(confData)
        for k,v in pairs(t) do
            if k == 1 then
                self.defNext.text = v[2]
            elseif k == 2 then
                self.ackNext.text = v[2]
            elseif k == 3 then
                self.breathNext.text = v[2]
            end
        end
        self.powerNext.text = confData.power or 0
    else--没有下一级就是满级了
        self.defNext.text = language.forging3
        self.ackNext.text = language.forging3
        self.breathNext.text = language.forging3
        self.powerNext.text = language.forging3 
        self.arrowLast.visible = false
    end
    nextText.visible = true
    if self.starLev >= self.maxlv then--最大值
        nextText.text = language.forging3 
    else
        local starlv = self.starLev + 1
        nextText.text = "+"..starlv
    end
    self:setEquipData(self.equipNext,self.part)
end

function SeeStarPanel:onClickStarAtt()
    if not self.data then return end
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        view:setForgData(self.data.partInfos)
        view:setData(2)
    end)
end

function SeeStarPanel:onClickStarSuit()
    if not self.data then return end
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        --刷新锻造装备套装数据
        proxy.ForgingProxy:send(1100108,{roleId = self.data.roleId,svrId = self.data.svrId})
        view:setData(3)
    end)
end

return SeeStarPanel