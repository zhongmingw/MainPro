--
-- Author: Your Name
-- Date: 2017-12-18 21:39:53
--排行
local Active3016 = class("Active3016",import("game.base.Ref"))

function Active3016:ctor(param)
    self.view = param
    self:initView()
end

function Active3016:initView()
    -- body
    self.personalList = self.view:GetChild("n8")
    self.personalList.numItems = 0
    self.personalList.itemRenderer = function (index,obj)
        self:personalCelldata(index, obj)
    end
    self.personalList:SetVirtual()
    self.gangList = self.view:GetChild("n9")
    self.gangList.numItems = 0
    self.gangList.itemRenderer = function (index,obj)
        self:gangCelldata(index, obj)
    end
    self.gangList:SetVirtual()
    self.timeTxt = self.view:GetChild("n3")
    self.decTxt = self.view:GetChild("n4")
end

function Active3016:personalCelldata( index,obj )
    local data = self.awardsConf[index+1]
    if data then
        local rankText = obj:GetChild("n0")
        if data.ranking[1] == data.ranking[2] then
            rankText.text = string.format(language.active38,data.ranking[1])
        else
            rankText.text = string.format(language.active39,data.ranking[1],data.ranking[2])
        end
        local list = obj:GetChild("n1")
        list.numItems = 0
        for k,v in pairs(data.awards) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local item = list:AddItemFromPool(url)
            local itemInfo = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(item, itemInfo, true)
        end
    end
end

function Active3016:gangCelldata( index,obj )
    local data = self.gangAwardsConf[index+1]
    if data then
        local rankText = obj:GetChild("n0")
        if data.ranking[1] == data.ranking[2] then
            rankText.text = string.format(language.active38,data.ranking[1])
        else
            rankText.text = string.format(language.active39,data.ranking[1],data.ranking[2])
        end
        local list = obj:GetChild("n1")
        list.numItems = 0
        for k,v in pairs(data.awards) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local item = list:AddItemFromPool(url)
            local itemInfo = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(item, itemInfo, true)
        end
    end
end

function Active3016:onTimer()
    -- body
end

function Active3016:setCurId(id)
    -- body
    
end

function Active3016:add5030165(data)
    -- body
    -- printt("排行",data)
    self.data = data
    self.awardsConf = conf.ActivityConf:getChristmasRankingAwards()
    self.gangAwardsConf = conf.ActivityConf:getChristmasGangRankingAwards()
    self.personalList.numItems = #self.awardsConf
    self.gangList.numItems = #self.gangAwardsConf
    local startTab = os.date("*t",data.actStartTime)
    local endTab = os.date("*t",data.actEndTime)
    local startTxt = startTab.month .. language.gonggong79 .. startTab.day .. language.gonggong80 .. string.format("%02d",startTab.hour) .. ":" .. string.format("%02d",startTab.min)
    local endTxt = endTab.month .. language.gonggong79 .. endTab.day .. language.gonggong80 .. string.format("%02d",endTab.hour) .. ":" .. string.format("%02d",endTab.min)
    self.timeTxt.text = startTxt .. "-" .. endTxt
    self.decTxt.text = language.active44
    --排行榜按钮
    local personalBtn = self.view:GetChild("n12")
    personalBtn.data = data.rankingInfos
    personalBtn.onClick:Add(self.onClickPersonRank,self)
    local gangBtn = self.view:GetChild("n13")
    gangBtn.data = data.gangRankingInfos
    gangBtn.onClick:Add(self.onClickGangRank,self)
end

function Active3016:onClickPersonRank(context)
    local data = context.sender.data
    data.type = 1
    mgr.ViewMgr:openView2(ViewName.ChristmasRank,data)
end

function Active3016:onClickGangRank(context)
    local data = context.sender.data
    data.type = 2
    mgr.ViewMgr:openView2(ViewName.ChristmasRank,data)
end

return Active3016