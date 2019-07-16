--
-- Author: ohf
-- Date: 2017-02-06 21:13:30
--
--打造区域
local MakePanel = class("MakePanel",import("game.base.Ref"))

local maxRed = 99

function MakePanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function MakePanel:initPanel()
    self.isSelect = false
    local panelObj = self.mParent.view:GetChild("n8")
    self.mSuitData = conf.ForgingConf:getAllSuit()
    self.listView = panelObj:GetChild("n1")

    self.equipObj = panelObj:GetChild("n7")
    self.equipObj.visible = false
    self.equipName = panelObj:GetChild("n14")
    self.equipName.text = ""
    self.proObj = panelObj:GetChild("n9")--打造道具
    self.proObj.visible = false
    self.proName = panelObj:GetChild("n15")--打造道具名字
    self.proName.text = ""
    self.protext = panelObj:GetChild("n16")--打造道具数量
    self.protext.text = ""
    self.moneyText = panelObj:GetChild("n17")
    self.moneyText.text = ""

    self.rateText = panelObj:GetChild("n24")
    self.rateText.text = ""

    self.checkBox = panelObj:GetChild("n19")
    self.checkBox.onChanged:Add(self.onCheck,self)--给控制器获取点击事件

    local checkDesc = panelObj:GetChild("n20")
    checkDesc.text = language.forging10
    local makeBtn = panelObj:GetChild("n4")
    makeBtn.onClick:Add(self.onClickMake,self)
    local helpBtn = panelObj:GetChild("n6")--帮助
    helpBtn.onClick:Add(self.onClickHelp, self)
    local buyProBtn = panelObj:GetChild("n10")
    buyProBtn.onClick:Add(self.onClickBuyPro,self)
end

function MakePanel:setChildIndex(index)
    self.index = index
end
--套装选择
function MakePanel:cellSuitData1(data,cell)
    local controller = cell:GetController("c1")--主控制器
    controller.selectedIndex = data.open
    local iconObj = cell:GetChild("n0")
    local confData = conf.ForgingConf:getEquipSuit(data.id)
    iconObj.url = UIPackage.GetItemURL(UICommonRes[8] , confData.font)
    local redObj = cell:GetChild("n8")
    -- local redText = cell:GetChild("n9")
    -- redText.text = ""
    if data.redNum <= 0 then
        redObj.visible = false
    else
        redObj.visible = true
    end
    cell.data = data
    cell.onClick:Add(self.onClickSuitItem,self)
end
--套装2
function MakePanel:cellSuitData2(mid,cell,k)
    local itemData = cache.PackCache:getPackDataById(mid,true)
    itemData.isquan = true
    local confData = conf.ForgingConf:getMakeData(mid)
    local bind = confData and confData.got[3] or 0
    itemData["mIndex"] = k
    itemData["bind"] = bind
    cell.data = itemData

    local itemObj = cell:GetChild("n1")
    GSetItemData(itemObj, itemData)
    local nameText = cell:GetChild("n6")
    nameText.text = conf.ItemConf:getName(mid)
    local getObj = cell:GetChild("n5")
    local ungetObj = cell:GetChild("n4")
    local redObj = cell:GetChild("n2")
    redObj.visible = self:isRedPoint(confData)
    local numText = cell:GetChild("n3")
    local amount = itemData.amount
    local dressEquips = self.dressEquips or {}
    for _,id in pairs(dressEquips) do
        if id == mid then
            amount = 1
            break
        end
    end
    numText.visible = false
    if amount <= 0 then
        getObj.visible = false
        ungetObj.visible = true
    else
        getObj.visible = true
        ungetObj.visible = false
    end
    cell.onClick:Add(self.onClickEquip,self)
    local key = self.mIndex or 1
    if k == key then
        cell.selected = true
        local context = {sender = cell}
        self:onClickEquip(context)
    end
end

function MakePanel:setChoose()
    self.checkBox.selected = true
    self.isSelect = true
end

function MakePanel:setData(data)
    if data then
        self.dressEquips = data.dressEquips
    end
    if self.isRef or self.index then--打造返回就重新算红点
        for k,data in pairs(self.mSuitData) do
            if self.index then
                if self.index == data.id - 1000 then
                    data.open = 1
                else
                    data.open = 0
                end
            end
            local redNum = self:getSuitEquipNum(data.equip_ids)--套装数量
            data.redNum = redNum or 0
        end
        self:setSelectData(self.makeData)
    else
        for k,data in pairs(self.mSuitData) do
            local redNum = self:getSuitEquipNum(data.equip_ids)--套装数量
            data.redNum = redNum or 0
        end
    end
    self.isRef = nil
    self.index = nil
    self:setListViewData()
end

function MakePanel:setListViewData()
    local num = 0
    self.listView.numItems = 0
    -- self.listView:SetVirtual()
    for k,data in pairs(self.mSuitData) do
        if data.type == 1 then
            num = num + 1
            local url = UIPackage.GetItemURL("forging" , "MakeItem")
            local obj = self.listView:AddItemFromPool(url)
            self:cellSuitData1(data,obj)
            if data.open == 1 then
                self.num = num
                local equip_ids = data.equip_ids
                if self.isSelect then
                    equip_ids = self:getSuitEquipData(equip_ids)
                end
                for k,mid in pairs(equip_ids) do
                    local confData = conf.ForgingConf:getMakeData(mid)
                    if confData then
                        num = num + 1
                        local url = UIPackage.GetItemURL("forging" , "MakeEquipItem")
                        local obj = self.listView:AddItemFromPool(url)
                        self:cellSuitData2(mid, obj, k)
                    end
                end
            end
        end
    end
    if self.num then
        self.listView:ScrollToView(self.num - 1)
        self.num = nil
    end
end
--判断哪些装备可打造
function MakePanel:getSuitEquipData(equip_ids)
    if equip_ids then
        local data = {}
        for _,id in pairs(equip_ids) do
            local confData = conf.ForgingConf:getMakeData(id)
            if confData and self:isMakeData(confData) then
                table.insert(data, id)
            end
        end
        return data
    end
end
--判断该套装下有多少未获得并且可打造的装备
function MakePanel:getSuitEquipNum(equip_ids)
    local num = 0
    if equip_ids then
        for _,id in pairs(equip_ids) do
            local confData = conf.ForgingConf:getMakeData(id)
            if confData and self:isRedPoint(confData) then
                num = num + 1
            end
        end
    end
    return num
end
--是否可以打造
function MakePanel:isMakeData(data)
    local proId = data.cost_item[1]
    local proData = cache.PackCache:getPackDataById(proId)
    local amount = proData.amount
    local confNum = data.cost_item[2]
    local bmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0--绑定铜钱
    local money = cache.PlayerCache:getTypeMoney(MoneyType.copper) or 0--非绑定
    local cost_money = data.cost_money
    local needLvl = data.need_lvl or 0
    local playerLv = cache.PlayerCache:getRoleLevel()
    if amount >= confNum and (money >= cost_money or bmoney >= cost_money) and playerLv >= needLvl then
        return true
    end
end
--是否显示红点
function MakePanel:isRedPoint(data)
    local unGet = self:isMakeData(data)--是否可以打造
    local dressEquips = self.dressEquips or {}
    for _,id in pairs(dressEquips) do
        if id == data.id then
            unGet = false
            break
        end
    end
    return unGet
end
--套装预览
function MakePanel:onClickSuitItem(context)
    local cell = context.sender
    local data = cell.data
    self.mIndex = nil
    for k,v in pairs(self.mSuitData) do
        if data.id == v.id then
            if v.open == 0 then--关
                self.mSuitData[k].open = 1
            else
                self.mSuitData[k].open = 0
            end
        else
            self.mSuitData[k].open = 0
        end
    end
    self:setListViewData()
end
--设置目标数据
function MakePanel:onClickEquip(context)
    local cell = context.sender
    local data = cell.data
    
    self:setSelectData(data)
    self.makeData = data
end

function MakePanel:setSelectData(data)
    local bmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0--绑定铜钱
    local money = cache.PlayerCache:getTypeMoney(MoneyType.copper) or 0--非绑定
    if data then
        local itemId = data.mid
        self.equipObj.visible = true
        GSetItemData(self.equipObj, data, true)--要打造的装备
        
        self.equipName.text = conf.ItemConf:getName(itemId)

        local confData = conf.ForgingConf:getMakeData(itemId)
        if confData then
            local proId = confData.cost_item[1]
            self.proName.text = conf.ItemConf:getName(proId)
            local proData = cache.PackCache:getPackDataById(proId)
            self.proData = proData
            local t = clone(proData)
            t.isquan = true
            GSetItemData(self.proObj, t, true)--道具
            local amount = proData.amount
            local confNum = confData.cost_item[2]
            local color = 14
            self.isPros = false--判断道具是否够
            if amount >= confNum then
                color = 7
                self.isPros = true
            end
            local cost_money = confData.cost_money or 0
            if money >= cost_money or bmoney >= cost_money then
                self.isMoney = true--判断钱够不够
            else
                self.isMoney = false
            end
            self.protext.text = mgr.TextMgr:getTextColorStr(amount.."/"..confNum, color)
            self.moneyText.text = cost_money
            proxy.ForgingProxy:send(1100105,{itemId = data.mid,reqType = 0})
            self.mIndex = data.mIndex--记录是列表第几个
        else
            self.proData = nil
            self.protext.text = ""
            self.moneyText.text = ""
            self.proObj.visible = false
        end
    end
end
--返回最终的概率
function MakePanel:updateRate(data)
    self.rateText.text = string.format(language.forging30, data.sucRate / 100) .."%"
end

function MakePanel:setRef()
    self.isRef = true
end
--打造
function MakePanel:onClickMake()
    if not self.makeData then return end
    local confData = conf.ForgingConf:getMakeData(self.makeData.mid)
    local needLvl = confData and confData.need_lvl or 0
    local playerLv = cache.PlayerCache:getRoleLevel()
    if playerLv < needLvl then
        GComAlter(string.format(language.forging40, needLvl))
        return
    end
    if not self.isPros then
        GComAlter(language.gonggong11)
        return
    end
    if not self.isMoney then
        GComAlter(language.gonggong29)
        return
    end
    if self.makeData then
        proxy.ForgingProxy:send(1100105,{itemId = self.makeData.mid,reqType = 1})
    else
        GComAlter(language.forging9)
    end
end
--复选框
function MakePanel:onCheck()
    self.isSelect = self.checkBox.selected--仅显示已打造选项
    self:setData()
end
--帮助
function MakePanel:onClickHelp()
    GOpenRuleView(1006)
end

function MakePanel:onClickBuyPro()
    if self.proData then
        GGoBuyItem(self.proData)
    else
        GComAlter(language.forging28)
    end
end

function MakePanel:clear()
    self.mSuitData = conf.ForgingConf:getAllSuit()
    -- self.isSelect = false
    -- self.checkBox.selected = false
end

return MakePanel