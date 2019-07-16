--
-- Author: 
-- Date: 2017-09-19 19:39:05
--

local AwakenHallPanel = class("AwakenHallPanel",import("game.base.Ref"))

function AwakenHallPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function AwakenHallPanel:initPanel()
    self.confData = conf.SceneConf:getAwakenBoss()
    local panelObj = self.mParent.view:GetChild("n10")
    self.listView = panelObj:GetChild("n2")--剑神列表
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)

    self.bgImg = panelObj:GetChild("n4")

    self.awardsListView = panelObj:GetChild("n10")--掉落奖励
    self.awardsListView:SetVirtual()
    self.awardsListView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end

    panelObj:GetChild("n5").text = mgr.TextMgr:getTextByTable(language.awaken12)
    panelObj:GetChild("n6").text = mgr.TextMgr:getTextByTable(language.awaken13)
    panelObj:GetChild("n12").text = mgr.TextMgr:getTextByTable(language.awaken24)

    self.timeText = panelObj:GetChild("n8")
    self.timeText.text = ""

    self.tiredText = panelObj:GetChild("n13")
    self.tiredText.text = language.awaken14..mgr.TextMgr:getTextColorStr(0, 7)

    local buyTiredBtn = panelObj:GetChild("n14")--购买疲劳
    buyTiredBtn.onClick:Add(self.onClickBuyTired,self)

    local warBtn = panelObj:GetChild("n7")
    warBtn.onClick:Add(self.onClickWar,self)

    self.crossText = panelObj:GetChild("n15")
    self.crossText.text = ""
end

function AwakenHallPanel:setData(data)
    self.mData = data
    local tired = data and data.tired or 0
    self.tiredText.text = language.awaken14..mgr.TextMgr:getTextColorStr(tired, 7)
    self.listView.numItems = #self.confData
    local leftPlayTime = self.mData and self.mData.leftPlayTime or 0
    self.timeText.text = language.awaken25..mgr.TextMgr:getTextColorStr(GTotimeString(leftPlayTime), 15)
end

function AwakenHallPanel:cellData(index, obj)
    local sceneData = self.confData[index + 1]
    obj:GetChild("n4").text = sceneData and sceneData.name or ""
    local crossImg = obj:GetChild("n6")
    local cross = sceneData.cross or 0--是不是跨服
    if cross > 0 then
        crossImg.visible = true
    else
        crossImg.visible = false
    end
    local lv = sceneData and sceneData.lvl or ""
    obj:GetChild("n8").text = "Lv"..lv

    local arleayKill = obj:GetChild("n5")
    local sceneValue = self.mData and self.mData.sceneMap[sceneData.id] or 0
    if sceneValue == 1 then--1已死亡
        arleayKill.visible = true
    else
        arleayKill.visible = false
    end
    local arleayRef = obj:GetChild("n7")
    arleayRef.text = language.gonggong39
    if sceneValue == 2 then--2已刷新
        arleayRef.visible = true
    else
        arleayRef.visible = false
    end
    local model = sceneData.model or 0
    obj.data = {data = sceneData, index = index, model = model}
    local key = cache.FubenCache:getAwakenWarIndex()
    if index == key then
        obj.selected = true
        local context = {data = obj}
        self:onClickItem(context)
    end
end

function AwakenHallPanel:cellAwardsData(index, obj)
    local award = self.awards[index + 1]
    local itemData = {mid = award[1],amount = award[2],bind = award[3]}
    GSetItemData(cell, itemData, true)
end

function AwakenHallPanel:onClickWar()
    local leftPlayTime = self.mData and self.mData.leftPlayTime or 0
    if leftPlayTime <= 0 then
        mgr.ViewMgr:openView2(ViewName.AwakenBuyFag, self.mData)
    else
        if self.sceneId then
            mgr.FubenMgr:gotoFubenWar(self.sceneId)
        end
    end
end

function AwakenHallPanel:onClickItem(context)
    local cell = context.data
    local change = cell.data
    local data = change.data
    self.awards = data and data.normal_drop or {}
    self.awardsListView.numItems = #self.awards
    self.sceneId = data.id
    local cross = data.cross or 0--是不是跨服
    if cross > 0 then
        local crossWillOpenTime = self.mData and self.mData.crossWillOpenTime or 0
        if mgr.NetMgr:getServerTime() >= crossWillOpenTime then
            self.crossText.text = ""
        else
            local timeTab = os.date("*t",crossWillOpenTime)
            self.crossText.text = string.format(language.awaken35, timeTab.day)
        end
    else
        self.crossText.text = ""
    end
end

function AwakenHallPanel:onClickBuyTired()
    if not self.mData then return end
    local leftBuyTiredCount = self.mData.leftBuyTiredCount
    if leftBuyTiredCount > 0 then
        mgr.ViewMgr:openView2(ViewName.AwakenBuyFag, self.mData)
    else
        GComAlter(language.awaken28)
    end
end

function AwakenHallPanel:clear()
    self.listView.numItems = 0
end

return AwakenHallPanel