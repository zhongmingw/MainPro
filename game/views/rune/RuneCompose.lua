--
-- Author: 
-- Date: 2018-02-22 14:35:48
--
--符文合成
local RuneCompose = class("RuneCompose",import("game.base.Ref"))

function RuneCompose:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId
    self:initPanel()
    self.init = true
    self.dressIndexs = {}--身上符文孔位置
    self.packIndexs = {}--背包符文孔位置
end

function RuneCompose:initPanel()
    self.colorTypes = conf.RuneConf:getFuwenColorTypes()
    local panelObj = self.mParent:getChoosePanelObj(self.moduleId)
    self.c1 = panelObj:GetController("c1")--选中符文是否解锁控制器
    self.listView = panelObj:GetChild("n2")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end

    self.materialList = {}--材料
    for i=5,7 do
        table.insert(self.materialList, panelObj:GetChild("n"..i))
    end
    self.chosseItem = panelObj:GetChild("n8")
    self.attriTexts = {}
    table.insert(self.attriTexts, panelObj:GetChild("n10"))--符文属性1
    table.insert(self.attriTexts, panelObj:GetChild("n11"))--符文属性2

    panelObj:GetChild("n13").text = language.rune08

    local composeBtn = panelObj:GetChild("n14")
    composeBtn.onClick:Add(self.onClickCompose,self)
end

function RuneCompose:setData(data)
    if not data or data.reqType == 1 then
        self.init = true
        self.choosekey = 1
    end
    self.stoneNum = data and data.stoneNum or 0
    self.towerMaxLevel = data and data.towerMaxLevel or 0--塔最高层
    self:setListViewData()
    self.init = false
    if data.reqType == 2 then
        mgr.ViewMgr:openView2(ViewName.RuenDekaronView, data)
    end
end

function RuneCompose:setListViewData()
    local num = 0
    self.listView.numItems = 0
    for k,v in pairs(self.colorTypes) do
        local color = v.id
        if self.init then
            if k == 1 then
                v.open = 1
            else
                v.open = 0
            end
        end
        num = num + 1
        local url = UIPackage.GetItemURL("rune" , "ComposeColorItem")
        local obj = self.listView:AddItemFromPool(url)
        self:cellColorData(v,obj)
        if v.open == 1 then
            self.num = num
            local items = conf.RuneConf:getFuwenComposesByColor(color)
            for k,data in pairs(items) do
                num = num + 1
                local url = UIPackage.GetItemURL("rune" , "ComposeItem")
                local obj = self.listView:AddItemFromPool(url)
                self:cellRuneData(data,obj,k)
            end
        end
    end
    if self.num then
        self.listView:ScrollToView(self.num - 1)
        self.num = nil
    end
end

function RuneCompose:cellColorData(data,obj)
    local titleName = obj:GetChild("title")
    titleName.text = data.name
    local ctrl = obj:GetController("button")
    ctrl.selectedIndex = data.open or 0
    obj.data = data
    obj.onClick:Add(self.onClickColorSuit,self)
end

function RuneCompose:cellRuneData(data,obj,k)
    obj:GetChild("n8").text = conf.ItemConf:getName(data.id)
    obj.data = data
    obj.data.index = k
    obj.onClick:Add(self.onClickItem,self)
    local index = self.choosekey or 1
    if k == index then
        obj.selected = true
        local context = {sender = obj}
        self:onClickItem(context)
    end
end

function RuneCompose:onClickColorSuit(context)
    local data = context.sender.data
    for k,v in pairs(self.colorTypes) do
        if data.id == v.id then
            if v.open == 0 then--关
                self.colorTypes[k].open = 1
            else
                self.colorTypes[k].open = 0
            end
        else
            self.colorTypes[k].open = 0
        end
    end
    self.choosekey = 1
    self:setListViewData()
end
--选择要合成的符文
function RuneCompose:onClickItem(context)
    local data = context.sender.data
    self.chossData = data
    if self.towerMaxLevel >= data.tower_lv then
        self.c1.selectedIndex = 0
        self:setMaterialData()
        self:setAttiData()
    else
        GComAlter(string.format(language.rune23, data.tower_lv))
        self.c1.selectedIndex = 1
    end
    self.choosekey = data.index
end
--设置材料
function RuneCompose:setMaterialData()
    local itemId = conf.RuneConf:getFuwenGlobal("fuwen_compose_itemid")
    local material = {}
    table.insert(material, {[1] = itemId,[2] = self.chossData.stone_num})
    for k,v in pairs(self.chossData.cost_items) do
        table.insert(material, v)
    end
    self.dressIndexs = {}--身上符文孔位置
    self.packIndexs = {}--背包符文孔位置
    for k,v in pairs(self.materialList) do
        local items = material[k]
        if items then
            v.visible = true
            local amount = items[2] or 0
            local itemData = {mid = items[1],amount = 1, bind = items[2] or 0}
            GSetItemData(v:GetChild("n0"), itemData, true)
            local packData = cache.RuneCache:getEquipFwDataById(items[1]) 
            if packData then
                table.insert(self.dressIndexs, packData.index)
            else
                packData = cache.RuneCache:getPackDataMaxId(items[1])
                if packData then
                    table.insert(self.packIndexs, packData.index) 
                else
                    packData = cache.PackCache:getPackDataById(items[1])
                end
            end
            local packAmount = packData and packData.amount or 0
            if k == 1 then
                packAmount = self.stoneNum
            end
            local color = 14
            if packAmount ~= 0 and packAmount >= amount then color = globalConst.RuneCompose01 end
            v:GetChild("n2").text = mgr.TextMgr:getTextColorStr(packAmount.."/"..amount, color)
        else
            v.visible = false
        end
    end
end
--设置要合成的属性
function RuneCompose:setAttiData()
    for i=1,2 do
        self.attriTexts[i].text = ""
    end
    local itemData = {mid = self.chossData.id,amount = 1, bind = 0}
    GSetItemData(self.chosseItem, itemData, true)
    local type = conf.ItemConf:getFwType(self.chossData.id)
    local id = mgr.RuneMgr:getAttiId(self.chossData.color,type,1)
    local confData = conf.RuneConf:getFuwenlevelup(id)
    local t = GConfDataSort(confData)
    for k,v in pairs(t) do--当前属性
        self.attriTexts[k].text = conf.RedPointConf:getProName(v[1]).."+"..mgr.TextMgr:getTextColorStr(GProPrecnt(v[1],v[2]), globalConst.RuneCompose01)
    end
end
--合成
function RuneCompose:onClickCompose()
    proxy.RuneProxy:send(1500105,{reqType = 2,dressIndexs = self.dressIndexs,packIndexs = self.packIndexs,itemId = self.chossData and self.chossData.id or 0})
end

return RuneCompose