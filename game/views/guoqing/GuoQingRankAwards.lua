--
-- Author: Your Name
-- Date: 2018-09-20 17:09:36
--

local GuoQingRankAwards = class("GuoQingRankAwards", base.BaseView)

function GuoQingRankAwards:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function GuoQingRankAwards:initView()
    local closeBtn = self.view:GetChild("n1")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n5")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end

function GuoQingRankAwards:initData(data)
    self.confData = conf.ActivityConf:getLanternRankAwards()
    self.listView.numItems = #self.confData
end

function GuoQingRankAwards:cellData(index,obj)
    local data = self.confData[index + 1]
    local rank1 = data.ranking[1]
    local rank2 = data.ranking[2]
    local rankStr = ""
    if rank1 == rank2 then
        rankStr = rank1
    else
        rankStr = rank1.."-"..rank2
    end
    obj:GetChild("n1").text = "第".. rankStr .."名"
    local listView = obj:GetChild("n2")
    local awards = data.awards or {}
    listView.itemRenderer = function(index, obj)
        local award = awards[index + 1]
        local itemData = {mid = award[1], amount = award[2], bind = award[3]}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #awards
end

return GuoQingRankAwards