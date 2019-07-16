--
-- Author: 
-- Date: 2017-09-16 12:40:07
--

local SeeCameoPanel = class("SeeCameoPanel",import("game.base.Ref"))

local CameoNum = 6

function SeeCameoPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function SeeCameoPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n26")
    local equipPanel = panelObj:GetChild("n0")
    self.controller = equipPanel:GetController("c1")--主控制器
    self.controller.onChanged:Add(self.selelctPart,self)--给控制器获取点击事件
    self.equipList = {}
    for i=71,82 do
        local equipObj = equipPanel:GetChild("n"..i)
        for j=1,CameoNum do
            local cameoStar = equipObj:GetChild("n"..j)
            cameoStar.visible = true
            cameoStar.enabled = false
        end
        table.insert(self.equipList, equipObj)
    end
    self.equipObj = panelObj:GetChild("n19")--要镶嵌的装备部位
    self.equipIcon = self.equipObj:GetChild("icon")
    self.cameoList = {}
    for i=1,CameoNum do
        local cameoObj = panelObj:GetChild("n2"..i)--宝石icon
        table.insert(self.cameoList, cameoObj)
    end
    self.textPower = panelObj:GetChild("n20")--战斗力

    local attriBtn = panelObj:GetChild("n61")--
    attriBtn.onClick:Add(self.onClickAttr,self)

    local suitBtn = panelObj:GetChild("n62")--
    suitBtn.onClick:Add(self.onClickSuit,self)
end

function SeeCameoPanel:setData(data,equips)
    self.data = data
    self.equips = equips
    self:setEquipCameo()
    self:selelctPart()
end

function SeeCameoPanel:getEquipByIndex(index)
    for k,v in pairs(self.equips) do
        if v.index == index then
            return v
        end
    end
end
--j就是宝石的总战斗力
function SeeCameoPanel:getCameoPower(part)
    local power = 0
    for k,v in pairs(self.data.partInfos) do
        if v.part == part then
            for _,id in pairs(v.gemMap) do
                if id > 0 then
                    local attiPower = conf.ItemConf:getPower(id)or 0
                    power = power + attiPower
                end
            end
        end
    end
    return power
end

--当前部位镶嵌的宝石
function SeeCameoPanel:selelctPart()
    local selectedIndex = self.controller.selectedIndex
    local part = selectedIndex + 1
    local data = self.data.partInfos[part]--返回该部位的数据
    if not data then return end
    self.equipIcon.url = UIItemRes.partSee[part]
    local power = self:getCameoPower(part)
    for i=1,6 do
        self.cameoList[i].url = ""
    end
    for k,v in pairs(data.gemMap) do
        local cameoStar = self.equipObj:GetChild("n"..k)
        self.cameoList[k].touchable = true
        if v > 0 then
            local src = conf.ItemConf:getSrc(v)
            self.cameoList[k].url =  ResPath.iconRes(src) 
        else
            self.cameoList[k].url = ""
        end
    end
    self:setEquipData(self.equipObj,part)
    self.textPower.text = power
end
--十个部位的宝石数据
function SeeCameoPanel:setEquipCameo()
    local data = self.data.partInfos
    if not data then
        return
    end
    local redNum = 0
    for _,v in pairs(data) do
        local equipObj = self.equipList[v.part]
        self:setEquipData(equipObj,v.part)
    end
end
--装备信息
function SeeCameoPanel:setEquipData(equipObj,part)
    local icon = equipObj:GetChild("icon")
    local equip = equipObj:GetChild("n11")
    local equipData = self:getEquipByIndex(Pack.equip + part)--同部位的装备
    
    local partInfos = self.data.partInfos[part]

    for i = 1 , 6 do
        local cameoStar = equipObj:GetChild("n"..i)
        if cameoStar then
            cameoStar.visible = true
            cameoStar.enabled = false
        end
    end

    for k,v in pairs(partInfos.gemMap) do
        local cameoStar = equipObj:GetChild("n"..k)
        if cameoStar and v ~= 0 then
            cameoStar.visible = true
            cameoStar.enabled = true
        end
    end


    if equipData then
        local tt = clone(equipData)
        tt.isquan = true
        icon.visible = false
        GSetItemData(equip,tt)
    else
        equip.visible = false
        icon.visible = true
    end
end

--宝石套装
function SeeCameoPanel:onClickSuit(context)
    if not self.data then return end
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        --刷新锻造装备套装数据
        proxy.ForgingProxy:send(1100108,{roleId = self.data.roleId,svrId = self.data.svrId})
        view:setData(7)
    end)
end
--宝石总属性
function SeeCameoPanel:onClickAttr(context)
    if not self.data then return end
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        view:setForgData(self.data.partInfos)
        view:setData(6)
    end)
end

return SeeCameoPanel