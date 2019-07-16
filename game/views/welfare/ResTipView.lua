--
-- Author: ohf
-- Date: 2017-04-06 21:02:28
--
--资源找回弹窗
local ResTipView = class("ResTipView", base.BaseView)

function ResTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true 
    self.openTween = ViewOpenTween.scale
end

function ResTipView:initView()
    local window = self.view:GetChild("n3")
    local closeBtn = window:GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.desc = self.view:GetChild("n6")
    self.listView = self.view:GetChild("n8")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end

    local findBtn = self.view:GetChild("n4")
    findBtn.onClick:Add(self.onClickFind,self)
end

function ResTipView:setData(data,index)
    self.mIndex = index
    self.resourceType = data.resourceType
    -- printt(data)
    local confData = conf.ActivityConf:getResourceData(data.resourceId)
    if index == 1 then
        local confMoney = confData and confData.cost_tq[2] or 0
        local money = confMoney * data.notFinishCount
        self.desc.text = language.welfare21..mgr.TextMgr:getTextColorStr(money, 7)..language.welfare17
    else
        local confMoney = confData and confData.cost_yb[2] or 0
        local money = confMoney * data.notFinishCount
        self.desc.text = language.welfare21..mgr.TextMgr:getTextColorStr(money, 7)..language.welfare18
    end
    self.mData = data.itemInfos
    self.listView.numItems = #self.mData
end

function ResTipView:cellData(index,cell)
    local awardData = self.mData[index + 1]
    local amount = awardData.amount
    if self.mIndex == 1 then
        amount = math.floor(amount / 2)
    end
    if amount > 0 then
        local itemData = {mid = awardData.mid,amount = amount,bind = awardData.bind}
        GSetItemData(cell, itemData, true)
    else
        cell.visible = false
    end
end

function ResTipView:onClickFind()
    proxy.ActivityProxy:send(1030113,{reqType = self.mIndex,type = self.resourceType})
    self:closeView()
end

return ResTipView