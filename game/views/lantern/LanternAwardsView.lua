--
-- Author: 
-- Date: 2018-01-31 10:59:28
--
--奖励预览
local LanternAwardsView = class("LanternAwardsView", base.BaseView)

function LanternAwardsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function LanternAwardsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self:setCloseBtn(self.view:GetChild("n2"))
    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end

function LanternAwardsView:initData(data)
    self.confData = conf.ActivityConf:getKeJuRankAwards()--科举排行奖励
    self.listView.numItems = #self.confData
end

function LanternAwardsView:cellData(index, obj)
    local data = self.confData[index + 1]
    local rank1 = data.ranking[1]
    local rank2 = data.ranking[2]
    local rankStr = ""
    if rank1 == rank2 then
        rankStr = rank1
    else
        rankStr = rank1.."-"..rank2
    end
    obj:GetChild("n0").text = "第"..mgr.TextMgr:getTextColorStr(rankStr, 7).."名"
    local listView = obj:GetChild("n1")
    local awards = data.awards or {}
    listView.itemRenderer = function(index, obj)
        local award = awards[index + 1]
        local itemData = {mid = award[1], amount = award[2], bind = award[3]}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #awards
end

return LanternAwardsView