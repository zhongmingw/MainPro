--
-- Author: 
-- Date: 2018-02-22 14:36:25
--
--符文分解
local RuneSplit = class("RuneSplit",import("game.base.Ref"))

local XYCOLOR = 6--稀有品质

function RuneSplit:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId
    self:initPanel()
    self.decmColors = {}--分解品质
    self.indexs = {}--分解的indexs
    self.chooseRunes = {}--分解的道具
end

function RuneSplit:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(self.moduleId)

    panelObj:GetChild("n6").text = language.rune07
    --符文列表
    self.listView = panelObj:GetChild("n7")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
    --品质选项
    self.checkListView = panelObj:GetChild("n8")
    self.checkListView.itemRenderer = function(index,obj)
        self:cellCheckData(index, obj)
    end

    local splitBtn = panelObj:GetChild("n9")
    splitBtn.onClick:Add(self.onClickSplit,self)

    self.spiltItemsList = panelObj:GetChild("n10")
    self.spiltItemsList.itemRenderer = function(index,obj)
        self:cellItemsData(index, obj)
    end
    self.spiltItemsList.numItems = 0
end

function RuneSplit:setData(data)
    self.decmColors = {}
    self.indexs = {}--分解的indexs
    self.chooseRunes = {}--分解的符文
    self.colors = conf.RuneConf:getFuwenGlobal("fuwen_colors")
    self.checkListView.numItems = #self.colors--品质选项
    self:setSpiltItems()
    if data.reqType == 2 then
        GOpenAlert3(data.items)
    end
end
--刷新背包
function RuneSplit:refreshPack()
    self:setChooseItems()
end

function RuneSplit:cellData(index,obj)
    local data = self.fwDatas[index + 1]
    local item = obj:GetChild("n0")
    item:GetController("c1").selectedIndex = 2
    item:GetController("c2").selectedIndex = data.choose or 0--是否选中
    item.icon = mgr.ItemMgr:getItemIconUrlByMid(data.mid)
    obj:GetChild("n1").text = mgr.RuneMgr:getRuneName(data)
    local attriTexts = {}
    table.insert(attriTexts, obj:GetChild("n2"))--符文属性加成1
    table.insert(attriTexts, obj:GetChild("n3"))--符文属性加成2
    attriTexts[1].text = ""
    attriTexts[2].text = ""
    local id = mgr.RuneMgr:getDataAttiId(data)
    local confData = conf.RuneConf:getFuwenlevelup(id)
    local t = GConfDataSort(confData)
    for k,v in pairs(t) do
        attriTexts[k].text = conf.RedPointConf:getProName(v[1]).."+"..mgr.TextMgr:getTextColorStr(GProPrecnt(v[1],v[2]), 7)
    end
    obj.data = data
    obj.onClick:Add(self.onClickRune,self)
end

function RuneSplit:cellCheckData(index, obj)
    local color = index + 1
    local btn = obj:GetChild("n0")
    btn.selected = false
    btn.data = color
    btn.onClick:Add(self.onClickCheck,self)
    if color <= 2 then
        btn.selected = true
        self:onClickCheck({sender = btn})
    end
    obj:GetChild("n1").text = mgr.TextMgr:getQualityStr1(self.colors[color],color)
end
--分解获得
function RuneSplit:cellItemsData(index, obj)
    local data = self.spiltItems[index + 1]
    obj:GetChild("n0").url = mgr.ItemMgr:getItemIconUrlByMid(data[1])
    obj:GetChild("n1").text = "+"..data[2]
end
--选中符文
function RuneSplit:onClickRune(context)
    local sender = context.sender
    local data = sender.data
    local c2 = sender:GetChild("n0"):GetController("c2")
    if c2.selectedIndex == 1 then
        c2.selectedIndex = 0
        for i=1,#self.indexs do
            local index = self.indexs[i]
            if index == data.index then
                table.remove(self.chooseRunes,i)
                table.remove(self.indexs,i)
                break
            end
        end
    else
        printt(data)
        table.insert(self.chooseRunes, data)
        table.insert(self.indexs, data.index)
        c2.selectedIndex = 1
    end
    self:setSpiltItems()
end

function RuneSplit:setSpiltItems()
    self.spiltItems = {}
    for k,v in pairs(self.chooseRunes) do
        local color = conf.ItemConf:getQuality(v.mid)
        local id = mgr.RuneMgr:getDataAttiId(v)
        local confData = conf.RuneConf:getFuwenlevelup(id)
        local items = confData and confData.explain_item or {}
        for k,v1 in pairs(items) do
            local isNotFind = true
            for k,v2 in pairs(self.spiltItems) do
                if v1[1] == v2[1] then
                    isNotFind = false
                    v2[2] = v2[2] + v1[2]
                end
            end
            if isNotFind then
                table.insert(self.spiltItems, clone(v1))
            end
        end 
    end
    self.spiltItemsList.numItems = #self.spiltItems
end

function RuneSplit:onClickCheck(context)
    local btn = context.sender
    local color = btn.data
    local colors = {}
    if btn.selected then--只发打钩的过去
        self.decmColors[color] = true
    else
        self.decmColors[color] = false
    end
    self:setChooseItems()
end

function RuneSplit:setChooseItems()
    self.chooseRunes = {}--分解的符文
    self.indexs = {}--分解的indexs
    self.fwDatas = cache.RuneCache:getPackData()
    for k,v in pairs(self.fwDatas) do
        local color = conf.ItemConf:getQuality(v.mid)
        if self.decmColors[color] then
            v.choose = 1
            table.insert(self.chooseRunes, v)
            table.insert(self.indexs, v.index)
        else
            v.choose = 0
        end
    end
    self.listView.numItems = #self.fwDatas--符文列表
    self:setSpiltItems()
end
--一键分解
function RuneSplit:onClickSplit()
    if #self.indexs <= 0 then
        GComAlter(language.rune24)
        return
    end
    local isHaveXy = false
    for k,v in pairs(self.chooseRunes) do
        local color = conf.ItemConf:getQuality(v.mid)
        local cons = conf.ItemConf:getContainType(v.mid)
        if color >= XYCOLOR or #cons >= 2 then
            isHaveXy = true
            break
        end
    end
    if isHaveXy then
        local param = {}
        param.type = 2
        param.sure = function()
            proxy.RuneProxy:send(1500104,{reqType = 1,indexs = self.indexs})
        end
        param.richtext = language.rune29
        GComAlter(param)
    else
        proxy.RuneProxy:send(1500104,{reqType = 1,indexs = self.indexs})
    end
end

return RuneSplit