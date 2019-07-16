--
-- Author: ohf
-- Date: 2017-03-27 12:04:22
--
--资源找回
local ResFindPanel = class("ResFindPanel",import("game.base.Ref"))

function ResFindPanel:ctor(mParent,panel)
    self.mParent = mParent
    self.panelObj = panel
    self:initPanel()
end

function ResFindPanel:initPanel()
    self.contTypes = conf.ActivityConf:getResourceTypes()
    self.listView = self.panelObj:GetChild("n0")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    
    local copperFindBtn = self.panelObj:GetChild("n2")
    self.copperFindBtn = copperFindBtn
    copperFindBtn.onClick:Add(self.onClickCopper,self)
    local goldFindBtn = self.panelObj:GetChild("n3")
    self.goldFindBtn = goldFindBtn
    
    goldFindBtn.onClick:Add(self.onClickGold,self)
    local copperAllFindBtn = self.panelObj:GetChild("n4")
    self.copperAllFindBtn = copperAllFindBtn
    self.redPoint1 = copperAllFindBtn:GetChild("red")
    copperAllFindBtn.onClick:Add(self.onClickCopperAll,self)
    local goldAllFindBtn = self.panelObj:GetChild("n5")
    self.goldAllFindBtn = goldAllFindBtn
    self.redPoint2 = goldAllFindBtn:GetChild("red")
    goldAllFindBtn.onClick:Add(self.onClickGoldAll,self)

    local desc1 = self.panelObj:GetChild("n6")
    desc1.text = language.welfare13
    local desc2 = self.panelObj:GetChild("n7")
    desc2.text = language.welfare14
end

function ResFindPanel:initRed()
    local redNum = cache.PlayerCache:getRedPointById(attConst.A20113)
    if redNum > 0 then
        self.redPoint1.visible = true
        self.redPoint2.visible = true
    else
        self.redPoint1.visible = false
        self.redPoint2.visible = false
    end
end

function ResFindPanel:sendMsg()
    proxy.ActivityProxy:send(1030113,{reqType = 0,type = 0})
end

function ResFindPanel:setData(data)
    self.listView.numItems = 0
    self.resourceList = data.resourceList or {}
    self.resourceData = {}
    for k,v1 in pairs(self.resourceList) do
        for k,v2 in pairs(self.contTypes) do
            if v1.resourceType == v2.id then
                table.insert(self.resourceData, v2)
            end
        end
    end
    local len = #self.resourceData
    if len <= 0 then
        self.copperFindBtn.enabled = false
        self.goldFindBtn.enabled = false
        self.copperAllFindBtn.enabled = false
        self.goldAllFindBtn.enabled = false
        self.redPoint1.visible = false
        self.redPoint2.visible = false
        local redNum = cache.PlayerCache:getRedPointById(attConst.A20113)
        mgr.GuiMgr:redpointByID(attConst.A20113,redNum)
    else
        self.copperFindBtn.enabled = true
        self.goldFindBtn.enabled = true
        self.copperAllFindBtn.enabled = true
        self.goldAllFindBtn.enabled = true
        cache.PlayerCache:setRedpoint(attConst.A20113, 1)
        mgr.GuiMgr:redpointByID(attConst.A20113,0)
    end
    self.listView.numItems = len
    self:initRed()
end

function ResFindPanel:cellData(index,cell)
    local data = self.resourceData[index + 1]
    local title = cell:GetChild("n2")
    local resData = self:getResourceData(data.id)
    title.url = UIPackage.GetItemURL("welfare" , data.font_title)
    cell.data = resData
    local listView = cell:GetChild("n3")
    local awards = resData.itemInfos or {}
    listView.itemRenderer = function(index,obj)
        local awardData = awards[index + 1]
        local itemData = {mid = awardData.mid,amount = awardData.amount,bind = awardData.bind}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #awards
    if index == 0 then
        cell.selected = true
        local context = {data = cell}
        self:onClickItem(context)
    end
end

function ResFindPanel:setVisible(visible)
    self.panelObj.visible = visible
end

function ResFindPanel:onClickItem(context)
    local cell = context.data
    local data = cell.data
    self.resData = data
end
--返回对应奖励
function ResFindPanel:getResourceData(type)
    for k,v in pairs(self.resourceList) do
        if v.resourceType == type then
            return v
        end
    end
    return {}
end
--铜钱找回
function ResFindPanel:onClickCopper()
    self:openTipView(1)
end
--元宝找回
function ResFindPanel:onClickGold()
    self:openTipView(2)
end
--全部铜钱找回
function ResFindPanel:onClickCopperAll()
    self:sendAllMsg(3)
end
--全部元宝找回
function ResFindPanel:onClickGoldAll()
    self:sendAllMsg(4) 
end

function ResFindPanel:openTipView(index)
    mgr.ViewMgr:openView(ViewName.ResTipView, function(view)
        view:setData(self.resData,index)
    end)
end

function ResFindPanel:sendAllMsg(index)
    local money = 0
    for k,v in pairs(self.resourceList) do
        local confData = conf.ActivityConf:getResourceData(v.resourceId)
        if index == 4 then
            local confMoney = confData and confData.cost_yb[2] or 0
            local yb = confMoney * v.notFinishCount
            money = money + yb
        else
            local confMoney = confData and confData.cost_tq[2] or 0
            local tq = confMoney * v.notFinishCount
            money = money + tq
        end
    end
    local myb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local mtq = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)
    local text = language.welfare19
    local strColor = 14
    if index == 4 then
        text = language.welfare20
        if myb >= money then
            strColor = 7
        end
    else
        text = language.welfare19
        if mtq >= money then
            strColor = 7
        end
    end
    local param = {
        {text = text[1],color = 11},
        {text = money,color = strColor},
        {text = text[2],color = 11}
    }
    local param = {type = 2,richtext = mgr.TextMgr:getTextByTable(param),sure = function()
        proxy.ActivityProxy:send(1030113,{reqType = index,type = 0})
    end}
    GComAlter(param)
end

return ResFindPanel