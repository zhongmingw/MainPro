--
-- Author: 
-- Date: 2017-09-20 20:03:42
--
--分解区域
local SplitResPanel = class("SplitResPanel",import("game.base.Ref"))

function SplitResPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function SplitResPanel:initPanel()
    self.panelObj = self.mParent.view:GetChild("n14")
    self.splitListView = self.panelObj:GetChild("n2")--分解材料
    self.splitListView:SetVirtual()
    self.splitListView.itemRenderer = function(index,obj)
        self:cellSplitData(index, obj)
    end
    self.splitListView.onClickItem:Add(self.onClickSplit,self)

    self.resListView = self.panelObj:GetChild("n3")--分解材料
    self.resListView:SetVirtual()
    self.resListView.itemRenderer = function(index,obj)
        self:cellResData(index, obj)
    end

    local addBtn = self.panelObj:GetChild("n14")
    addBtn.onClick:Add(self.onClickAdd,self)
    local splitBtn = self.panelObj:GetChild("n13")
    splitBtn.onClick:Add(self.onClickActSplit,self)

    self:initPros()
end

function SplitResPanel:initPros()
    local panel = self.panelObj:GetChild("n0")
    self.prosListView = panel:GetChild("n31")
    self.prosListView:SetVirtual()
    self.prosListView.itemRenderer = function(index,obj)
        self:cellPackData(index, obj)
    end
    self.prosListView.scrollPane.onScrollEnd:Add(self.onPackScrollPage, self)

    self.pageBtnList = panel:GetChild("n32")--分页按钮列表
    self.pageBtnList:SetVirtual()
    self.pageBtnList.itemRenderer = function(index,btnObj)
        btnObj.data = index
    end
    self.pageBtnList.onClickItem:Add(self.onClickPackPage,self)
end

function SplitResPanel:setData()
    mgr.ItemMgr:setPackIndex(Pack.splitIndex)
    self.choosePros = {}--选择的道具
    self.resList = {}--预览的资源
    local packSplitPros = cache.PackCache:getSplitPros(true)--获取背包可以分解的物品
    self.mPackDatas = clone(packSplitPros)

    self:resetPros()
    self:onPackScrollPage()
end

function SplitResPanel:resetPros()
    local numItems = #self.mPackDatas
    if numItems <= 0 then
        numItems = 1
    end
    --数据列表
    self.prosListView.numItems = numItems
    --按钮列表
    self.pageBtnList.numItems = numItems
    self.splitListView.numItems = #self.choosePros
    self.indexs = {}
    for _,v in pairs(self.choosePros) do
        if v.mid then
            local confData = conf.ForgingConf:getEquipSplit(v.mid)
            local resItems = confData.items or {}
            for k,v1 in pairs(resItems) do
                local resData = {mid = v1[1],amount = v1[2],bind = v1[3]}
                local isFind = false
                for k,v2 in pairs(self.resList) do
                    if v2.mid == resData.mid then
                        self.resList[k].amount = self.resList[k].amount + resData.amount
                        isFind = true
                        break
                    end
                end
                if not isFind then
                    table.insert(self.resList, resData)
                end
            end
            table.insert(self.indexs, v.index)
        end
    end
    self.resListView.numItems = #self.resList
end
--选择分解道具
function SplitResPanel:setChooseItem(itemData)
    self.resList = {}
    table.insert(self.choosePros, itemData)
    self:resetPackData(itemData,1)
    self:resetPros()
end
--删除待分解的道具
function SplitResPanel:cleanChooseItem(itemData)
    if not itemData then return end 
    self.resList = {}
    for k,v in pairs(self.choosePros) do
        if v.mid == itemData.mid then
            table.remove(self.choosePros,k)
            break
        end
    end
    self:resetPackData(itemData,-1)
    self:resetPros()
end

function SplitResPanel:resetPackData(itemData,count)
    for k,list in pairs(self.mPackDatas) do
        for k,v in pairs(list) do
            if itemData then
                if v.index == itemData.index then
                    list[k].amount = list[k].amount - count
                    break
                end 
            else
                local color = conf.ItemConf:getQuality(v.mid)
                if color < ProsRareColor then
                    list[k].amount = list[k].amount - 1
                end
            end
        end
    end
end
function SplitResPanel:cellPackData(pageIndex,cell)
    local itemList = cell:GetChild("n0")
    itemList.itemRenderer = function(index, iconObj)
        local proObj = iconObj:GetChild("n5")--item
        proObj.visible = false
        local data = self.mPackDatas[pageIndex + 1]--获取分页的数据
        local iconIndex = index + 1
        if data and data[iconIndex] then
            local t = clone(data[iconIndex])
            if t.amount > 0 then
                t.isquan = true
                GSetItemData(proObj,t,true)--设置道具信息
            else
                proObj.visible = false
            end
        end
    end
    itemList.numItems = Pack.iconNum--默认数量
end
--分解的道具
function SplitResPanel:cellSplitData(index,cell)
    local itemData = self.choosePros[index + 1]
    local proObj = cell:GetChild("n5")
    local close = cell:GetChild("n7")
    local mid = itemData.mid or 0
    close.visible = true
    local t = clone(itemData)
    t.isquan = true
    cell.data = itemData
    GSetItemData(proObj,t)--设置道具信息
end
--预览的资源
function SplitResPanel:cellResData(index,cell)
    local itemData = self.resList[index + 1]
    local proObj = cell:GetChild("n5")
    local t = clone(itemData)
    t.isquan = true
    GSetItemData(proObj,t,true)--设置道具信息
end
--选页
function SplitResPanel:onClickPackPage(context)
    local btnObj = context.data
    local index = btnObj.data
    self.prosListView:ScrollToView(index,true)
end

function SplitResPanel:onPackScrollPage()
    local index = self.prosListView.scrollPane.currentPageX
    if self.pageBtnList.numItems > 0 then
        self.pageBtnList:AddSelection(index,true)
    end
end

function SplitResPanel:onClickSplit(context)
    local itemData = context.data.data
    self:cleanChooseItem(itemData)
end
--一键添加
function SplitResPanel:onClickAdd()
    if #self.mPackDatas <= 0 then
        GComAlter(language.forging48)
        return
    end
    local num = 0
    for k,list in pairs(self.mPackDatas) do
        for k,v in pairs(list) do
            if v.amount <= 0 then
                num = num + 1
            end
        end
    end
    local packData = cache.PackCache:getSplitPros()
    if num == #packData then
        GComAlter(language.forging48)
        return
    end 
    self.choosePros = {}
    for k,v in pairs(packData) do
        local color = conf.ItemConf:getQuality(v.mid)
        if color < ProsRareColor then
            local data = clone(v)
            table.insert(self.choosePros, data)
        end
    end
    self:resetPackData()
    self:resetPros()
    
end
--开始分解
function SplitResPanel:onClickActSplit()
    if not self.indexs then return end
    for k,v in pairs(self.choosePros) do
        local color = conf.ItemConf:getQuality(v.mid)
        if color and color >= ProsRareColor then
            local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(language.awaken27, 6),sure = function()
                proxy.PackProxy:sendSplit({indexs = self.indexs})
            end}
            GComAlter(param)
            return
        end
    end
    if #self.indexs > 0 then
        proxy.PackProxy:sendSplit({indexs = self.indexs})
    else
        GComAlter(language.forging49)
    end
end

function SplitResPanel:clear()
    mgr.ItemMgr:setPackIndex(0)
end

return SplitResPanel