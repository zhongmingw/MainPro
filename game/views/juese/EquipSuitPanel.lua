--
-- Author: ohf
-- Date: 2017-02-09 17:37:57
--
--套装区域
local EquipSuitPanel = class("EquipSuitPanel",import("game.base.Ref"))

local equipNum = 12
local suitType1 = 1
local suitType2 = 2

function EquipSuitPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function EquipSuitPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n13")
    self.panelObj = panelObj
    self:initSuitList(panelObj)
    self:initEquip(panelObj)
    self:initAtt(panelObj)
end

function EquipSuitPanel:initSuitList(panelObj)
    self.listView = panelObj:GetChild("n169")
    self.listView.itemRenderer = function(index,obj)
        self:cellSuitData(index, obj)
    end
end

function EquipSuitPanel:cellSuitData(index, cell)
    local num = index + 1
    local data = self.mSuitData[num]
    local iconObj = cell:GetChild("n2")
    iconObj.url = UIItemRes.makeImg[num]
    local labelObj = cell:GetChild("n3")
    labelObj.url = UIPackage.GetItemURL(UICommonRes[8] , data.font)
    cell.data = data
    cell.onClick:Add(self.onClickSuit,self)
end

function EquipSuitPanel:initEquip(panelObj)
    self.mSuitData = conf.ForgingConf:getAllSuit()
    self.listView.numItems = #self.mSuitData
    self.equipList = {}--装备列表
    self.enabledList = {}--激活列表
    for i=1,equipNum do
        local num = 70 + i
        local item = panelObj:GetChild("n"..num)
        table.insert(self.equipList, item)
        local imgJh = item:GetChild("n4")
        imgJh.visible = false
        table.insert(self.enabledList, imgJh)
    end
    self.modelPanel = panelObj:GetChild("n3")
    self.touchModel = panelObj:GetChild("n98")
end

--添加模型
function EquipSuitPanel:addModel()
    local equip_ids = conf.ForgingConf:getEquipSuit(self.mSuitId).equip_ids
    local skinClothes = conf.ItemConf:getEquipSkins(equip_ids[1])--套装衣服外观
    local skinWuqis = conf.ItemConf:getEquipSkins(equip_ids[2])--武器外观
    local skins1 = skinClothes and skinClothes[self.sex] or cache.PlayerCache:getSkins(Skins.clothes)--衣服
    local skins2 = skinWuqis and skinWuqis[self.sex] or cache.PlayerCache:getSkins(Skins.wuqi)--武器
    local skins3 = cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
    local skins5 = cache.PlayerCache:getSkins(Skins.shenbing) --神兵
    if self.mType == suitType2 then--源计划套装
        skins1 = self:getSkinsModules(Skins.clothes)[self.sex]
        skins2 = self:getSkinsModules(Skins.wuqi)[self.sex]
        skins3 = self:getSkinsModules(Skins.xianyu)[1]
        skins5 = self:getSkinsModules(Skins.shenbing)[1]
    end

    local modelObj
    if not self.modelObj or self.modelObj:isDispose()  then
        modelObj = self.mParent:addModel(skins1,self.modelPanel)
        self.cansee = modelObj:setSkins(nil,skins2,skins3)
        self.modelObj = modelObj
    else
        modelObj = self.modelObj
        self.cansee = modelObj:setSkins(skins1,skins2,skins3)
    end
    
    modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
    modelObj:setRotation(RoleSexModel[self.sex].angle)
    local effect = self.mParent:addEffect(4020102,self.panelObj:GetChild("n100"))
    effect.LocalPosition = Vector3(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight,500)
    if skins5 > 0 and skins2>0 then
        modelObj:addWeaponEct(skins5.."_ui")
    end
    self.panelObj:GetChild("n88").visible = self.cansee
    self.modelObj:modelTouchRotate(self.touchModel, self.sex)
end
--特殊时装外观
function EquipSuitPanel:getSkinsModules(skinType)
    local suitData = conf.ForgingConf:getEquipSuit(self.mSuitId)
    local key = 1
    for k,v in pairs(suitData.equip_ids) do
        if v == skinType then
            key = k
            break
        end
    end
    return suitData.modules[key]
end

function EquipSuitPanel:initAtt(panelObj)
    self.suitLabel = panelObj:GetChild("n35")--几阶套装装载器
    local listView = panelObj:GetChild("n93")
    listView.itemRenderer = function(index,panelAtt)
        self.powerText = panelAtt:GetChild("n2")
        self.powerText.text = 0
        local progressDesc = panelAtt:GetChild("n7")
        self.suitGressNum = panelAtt:GetChild("n8")--进度条显示数
        self.suitGressNum.text = "0/10"
        self.progressObj = panelAtt:GetChild("n1")--进度条
        self.progressObj.value = 0
        self.progressObj.max = equipNum
        --已激活标记
        self:initJh(panelAtt)
        
    end
    listView.numItems = 1
    local jhBtn = panelObj:GetChild("n52")
    self.jhBtn = jhBtn
    jhBtn.onClick:Add(self.onClickJh,self)
    self.attiList2 = {}
    local panel2 = panelObj:GetChild("n99")
    for i=31,37 do
        local atti = panel2:GetChild("n"..i)
        table.insert(self.attiList2, atti)
    end
    self.powerText2 = panel2:GetChild("n2")
end
--已激活标记
function EquipSuitPanel:initJh(panelAtt)
    self.descJhList = {}
    local descJh1 = panelAtt:GetChild("n9")--3件
    table.insert(self.descJhList, descJh1)
    self.descjh1 = panelAtt:GetChild("n10")
    self.descjh1.text = language.gonggong09
    self.attiListView1 = panelAtt:GetChild("n37")
    self.attiListView1:SetVirtual()
    self.attiListView1.itemRenderer = function(index,obj)
        self:cellAttiData1(index, obj)
    end

    local descJh2 = panelAtt:GetChild("n21")--5件
    table.insert(self.descJhList, descJh2)
    self.descjh2 = panelAtt:GetChild("n22")
    self.descjh2.text = language.gonggong09
    self.attiListView2 = panelAtt:GetChild("n38")
    self.attiListView2:SetVirtual()
    self.attiListView2.itemRenderer = function(index,obj)
        self:cellAttiData2(index, obj)
    end

    local descJh3 = panelAtt:GetChild("n29")--10件
    table.insert(self.descJhList, descJh3)
    self.descjh3 = panelAtt:GetChild("n30")
    self.descjh3.text = language.gonggong09
    self.attiListView3 = panelAtt:GetChild("n39")
    self.attiListView3:SetVirtual()
    self.attiListView3.itemRenderer = function(index,obj)
        self:cellAttiData3(index, obj)
    end
end
--设置各属性值
function EquipSuitPanel:cellAttiData(index,cell)
    local data = self.attiData[index + 1]
    cell:GetChild("n1").text = conf.RedPointConf:getProName(data[1]).."+"..GProPrecnt(data[1],data[2])
end
function EquipSuitPanel:cellAttiData1(index,cell)
    local data = self.attiData1[index + 1]
    cell:GetChild("n1").text = conf.RedPointConf:getProName(data[1]).."+"..GProPrecnt(data[1],data[2])
end
function EquipSuitPanel:cellAttiData2(index,cell)
    local data = self.attiData2[index + 1]
    cell:GetChild("n1").text = conf.RedPointConf:getProName(data[1]).."+"..GProPrecnt(data[1],data[2])
end
function EquipSuitPanel:cellAttiData3(index,cell)
    local data = self.attiData3[index + 1]
    cell:GetChild("n1").text = conf.RedPointConf:getProName(data[1]).."+"..GProPrecnt(data[1],data[2])
end

function EquipSuitPanel:setForviewIndex(index)
    self.childIndex = index
end
--更新套装信息
function EquipSuitPanel:setData(data)
    self.dressEquips = data.dressEquips--穿戴过的装备id
    self.activedEffects = data.activedEffects or {}--已激活的套装效果
    self.fashionSuits = data.fashionSuits or {}--时装套装数据
    if self.childIndex then
        self.mSuitId = 1000 + self.childIndex
    else
        self.mSuitId = self.mSuitData[1].id
    end
    self.childIndex = nil
    self.mType = conf.ForgingConf:getEquipSuit(self.mSuitId).type
    self:setListViewSelect(self.mSuitId)
    local roleData = cache.PlayerCache:getData()
    local roleIcon = roleData and roleData.roleIcon or cache.PlayerCache:getRoleIcon()
    self.sex = GGetMsgByRoleIcon(roleIcon).sex
    --添加模型
    self:addModel()
    self:refreshRed()
    self:setAttiEquip()
end
--刷新红点
function EquipSuitPanel:refreshRed()
    self.redList = {}
    for k,v1 in pairs(self.mSuitData) do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local redPoint = cell:GetChild("n4")
            local num1 = 0--记录当前套装有激活了多少个
            for _,v2 in pairs(self.activedEffects) do
                local pex = tonumber(string.sub(v2,1,4))
                if v1.id == pex then
                    num1 = num1 + 1
                end
            end
            local num2 = 0--记录当前套装有多少件装备穿过
            local dressSuits = self.dressEquips
            if v1.type == suitType2 then
                dressSuits = self.fashionSuits[v1.id] and self.fashionSuits[v1.id].idList or {}
            end
            for _,id1 in pairs(v1.equip_ids) do
                for _,id2 in pairs(dressSuits) do
                    if id1 == id2 then
                        num2 = num2 + 1
                    end
                end
            end
            local effectList = conf.ForgingConf:getSuitEffect(v1.id)--记录当前套装的激活条件
            local num3 = 0
            for _,v in pairs(effectList) do
                if num2 >= v.equip_num then
                    num3 = num3 + 1
                end
            end
            local len = #effectList
            if num1 < len and num1 < num3 then
                redPoint.visible = true
                self.redList[v1.id] = true
            else
                redPoint.visible = false
                self.redList[v1.id] = false
            end
        end
    end
end

function EquipSuitPanel:setListViewSelect(suitId)
    self.mSuitId = suitId
    for i=1,#self.mSuitData do
        local data = self.mSuitData[i]
        if suitId == data.id then
            local suitObj = self.listView:GetChildAt(i - 1)
            suitObj.selected = true
        else
            local suitObj = self.listView:GetChildAt(i - 1)
            suitObj.selected = false
        end
    end
    
end
--激活返回
function EquipSuitPanel:updateSuitId(suiltEffectId)
    table.insert(self.activedEffects, suiltEffectId)
    self:setListViewSelect(self.mSuitId)
    self:refreshRed()
    self:setAttiEquip()
end

function EquipSuitPanel:setAttiEquip()
    self:setEquipData()--设置装备信息
    self:setAttData()--设置属性信息
    self:setAttData2()
    self.jhBtn:GetChild("red").visible = self.redList[self.mSuitId]
end

function EquipSuitPanel:onClickSuit(context)
    local data = context.sender.data
    self.mType = data.type
    self.mSuitId = data.id
    self:addModel()
    self:setAttiEquip()
end
--装备信息
function EquipSuitPanel:setEquipData()
    local equip_ids = conf.ForgingConf:getEquipSuit(self.mSuitId).equip_ids
    self.dressIds = {}
    if self.mType == suitType1 then
        for k,v in pairs(self.equipList) do
            local mid = equip_ids[k]
            self.enabledList[k].visible = false
            local data = clone(cache.PackCache:getEquipDataById(mid))
            data.isquan = true
            if self.dressEquips then
                for _,equipId in pairs(self.dressEquips) do
                    if mid == equipId then
                        self.enabledList[k].visible = true
                        table.insert(self.dressIds, equipId)
                    end
                end
            end
            if k <= 10 then
                v.visible = true

                GSetItemData(v:GetChild("n3"), data, true)
            else
                v.visible = false
            end
        end
    else
        local suitData = conf.ForgingConf:getEquipSuit(self.mSuitId)
        local suitTypes = suitData.equip_ids
        local skinsPros = suitData.skinsPros
        for k,v in pairs(self.equipList) do
            local type = suitTypes[k]
            local mid = skinsPros[k][1]
            if type == Skins.clothes or type == Skins.wuqi then
                mid = skinsPros[k][self.sex]
            end
            
            v.visible = true
            local bind = 0
            self.enabledList[k].visible = false
            if self.fashionSuits then
                local suits = self.fashionSuits[self.mSuitId] and self.fashionSuits[self.mSuitId].idList or {}
                for _,skinType in pairs(suits) do
                    if type == skinType then
                        self.enabledList[k].visible = true
                        bind = 1
                        table.insert(self.dressIds, skinType)
                    end
                end
            end
            local data = {mid = mid, amount = 0,bind = bind}
            data.isquan = true
            GSetItemData(v:GetChild("n3"), data, true)
        end
    end
end
--设置对应属性
function EquipSuitPanel:setAttData()
    if not self.mSuitId then return end
    local data = conf.ForgingConf:getEquipSuit(self.mSuitId)
    self.suitLabel.url = UIPackage.GetItemURL(UICommonRes[8] , tostring(data.font))
    local effects = self:getEffects(self.mSuitId)
    local effectId = effects[1] or 0
    for k,v in pairs(effects) do--找出最大的激活id
        if v >= effectId then
            effectId = v
        end
    end

    local effectMaxNum = nil
    if effectId > 0 then
        effectMaxNum = conf.ForgingConf:getSuitEffectById(effectId).equip_num
    end

    local jhLen = #effects--标记是否已激活
    local equipLen = #self.dressIds--已经手记了多少装备
    local maxNum = 10
    if self.mType == suitType2 then
        maxNum = equipNum
    end
    self.suitGressNum.text = equipLen.."/"..maxNum
    self.progressObj.value = equipLen
    self.progressObj.max = maxNum

    local effectList = conf.ForgingConf:getSuitEffect(self.mSuitId)--对应套装激活
    for k,v in pairs(self.descJhList) do
        v.text = string.format(language.forging11, effectList[k].equip_num) 
    end
    self.jhBtn.visible = true
    self.descjh1.text = language.gonggong09
    self.descjh2.text = language.gonggong09
    self.descjh3.text = language.gonggong09
    if jhLen >= 1 then
        self.descjh1.text = language.gonggong10
    end
    if jhLen >= 2 then
        self.descjh2.text = language.gonggong10
    end
    if jhLen >= 3 then
        self.descjh3.text = language.gonggong10
        self.jhBtn.visible = false
    end

    if effectMaxNum then
        local data = conf.ForgingConf:getSuitEffect(self.mSuitId,effectMaxNum,true)--设置已激活总属性
        self.powerText.text = data.power--战斗力
    end
------------------------------------------------------------------------------
    local data1 = conf.ForgingConf:getSuitEffectById(effectList[1].id)
    local t = GConfDataSort(data1)
    self.attiData1 = t
    self.attiListView1.numItems = #t

    local confData = effectList[2]
    local data2 = conf.ForgingConf:getSuitEffect(self.mSuitId,confData.equip_num,true)
    local t = GConfDataSort(data2)
    self.attiData2 = t
    self.attiListView2.numItems = #t

    local confData = effectList[3]
    local data3 = conf.ForgingConf:getSuitEffect(self.mSuitId,confData.equip_num,true)
    local t = GConfDataSort(data3)
    self.attiData3 = t
    self.attiListView3.numItems = #t
end
--初始化属性值
function EquipSuitPanel:getInitAtti(data)
    local attiData = data
    local t = GConfDataSort(attiData)
    for k,v in pairs(t) do
        v[2] = 0
    end
    return t
end
--激活套装
function EquipSuitPanel:onClickJh()
    if self.mSuitId then
        local effectList = conf.ForgingConf:getSuitEffect(self.mSuitId)
        local effects = {}
        for k,v in pairs(self.activedEffects) do--寻找对应的激活id
            local pex = tonumber(string.sub(v, 1, 4))
            if pex == self.mSuitId then
                table.insert(effects, v)
            end
        end
        local actLen = #effects
        local jhLen = #self.dressIds
        local index = 0
        local num = #effectList
        for i=1,num do
            if actLen < i and jhLen >= effectList[i].equip_num then
                index = i
                break
            end
        end
        local id = self.mSuitId * 100 + index
        if index == 0 then
            GComAlter(language.forging17)
            return
        end
        proxy.ForgingProxy:send(1100107,{suiltEffectId = id})
    end
end
--基础属性
function EquipSuitPanel:setAttData2()
    local data = {}
    local power = 0
    local suitData = conf.ForgingConf:getEquipSuit(self.mSuitId)
    local equip_ids = suitData.equip_ids
    if self.mType == suitType1 then
        for _,mid in pairs(equip_ids) do
            local attData = conf.ItemArriConf:getItemAtt(mid)
            local attiPower = conf.ItemConf:getPower(mid) or 0
            power = power + attiPower--累加战斗力
            if attData then
                -- printt(attData)
                for k,v in pairs(attData) do
                    if string.find(k,"att_") then
                        if not data[k] then
                            data[k] = 0
                        end
                        data[k] = data[k] + v
                    end
                end
            end
        end
    else--源计划基础属性
        for k,type in pairs(equip_ids) do
            local skinsAttId = suitData.skinsAttIds[k]
            local confData = nil
            if type == Skins.clothes or type == Skins.wuqi then
                confData = conf.RoleConf:getFashData(skinsAttId[self.sex])
            elseif type == Skins.xianyu then
                confData = conf.ZuoQiConf:getSkinsByIndex(skinsAttId[1], 3)
            elseif type == Skins.zuoqi then
                confData = conf.ZuoQiConf:getSkinsByIndex(skinsAttId[1], 0)
            elseif type == Skins.shenbing then
                confData = conf.ZuoQiConf:getSkinsByIndex(skinsAttId[1], 1)
            elseif type == Skins.fabao then
                confData = conf.ZuoQiConf:getSkinsByIndex(skinsAttId[1], 2)
            elseif type == Skins.xianqi then
                confData = conf.ZuoQiConf:getSkinsByIndex(skinsAttId[1], 4)
            elseif type == Skins.huobanxianyu then
                confData = conf.HuobanConf:getSkinsByModel(skinsAttId[1], 1)
            elseif type == Skins.huobanshenbing then
                onfData = conf.HuobanConf:getSkinsByModel(skinsAttId[1], 2)
            elseif type == Skins.huobanfabao then
                onfData = conf.HuobanConf:getSkinsByModel(skinsAttId[1], 3)
            elseif type == Skins.huobanxianqi then
                onfData = conf.HuobanConf:getSkinsByModel(skinsAttId[1], 4)
            elseif type == Skins.huobanteshu then
                confData = conf.HuobanConf:getSkinsByModel(skinsAttId[1], 0)
            end
            if confData then
                for k,v in pairs(confData) do
                    if string.find(k,"att_") then
                        if not data[k] then
                            data[k] = 0
                        end
                        data[k] = data[k] + v
                    end
                end
                local confPower = confData.power or 0
                power = power + confPower--累加战斗力
            end
        end
    end
    local attiData = conf.ForgingConf:getSuitInitEffect(self.mSuitId)
    local t = GConfDataSort(attiData)
    for k,v in pairs(t) do
        self.attiList2[k].text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(data[1],data[2])
    end
    local t = GConfDataSort(data)
    for k,v in pairs(t) do
        local attId = v[1]
        local value = v[2]
        self.attiList2[k].text = conf.RedPointConf:getProName(attId).." "..GProPrecnt(attId,value)
    end
    self.powerText2.text = power
end

function EquipSuitPanel:getEffects(suitId)
    local effects = {}
    if self.activedEffects then
        for k,v in pairs(self.activedEffects) do--找出改套装的所有激活id
            local mid = tonumber(string.sub(tostring(v), 1, 4))
            if suitId == mid then
                table.insert(effects, v)
            end
        end
    end
    return effects
end

return EquipSuitPanel