--
-- Author: 
-- Date: 2017-12-26 20:59:25
--

local YdXdzzRankView = class("YdXdzzRankView", base.BaseView)

function YdXdzzRankView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function YdXdzzRankView:initView()
    local closeBtn = self.view:GetChild("n2"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n7")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.titleIcon = self.view:GetChild("n16")
end


function YdXdzzRankView:initData(data)
    proxy.ActivityProxy:send(1470103)
end

function YdXdzzRankView:setData(data)
    self.data = data
    self.view:GetChild("n19").text = data.score
    local rank = language.rank04
    if data.rank > 0 then
        rank = data.rank
    end
    self.view:GetChild("n21").text = rank
    local count = conf.ActivityWarConf:getSnowGlobal("award_count") or 0
    local numItems = 10 + count
    self.listView.numItems = #self.data.rankList > numItems and #self.data.rankList or numItems
end

function YdXdzzRankView:celldata( index,obj )
    local data = self.data.rankList[index+1]
    local rankTxt = obj:GetChild("n1")
    local nameTxt = obj:GetChild("n2")
    local numTxt = obj:GetChild("n3")
    local bgIcon = obj:GetChild("n9")
    local numIcon = obj:GetChild("n10")
    numIcon.visible = true
    if index == 0 then
        bgIcon.url = UIPackage.GetItemURL("_panels" , "meili_008")
        numIcon.url = UIPackage.GetItemURL("_others" , "meili_003")
    elseif index == 1 then
        bgIcon.url = UIPackage.GetItemURL("_panels" , "meili_009")
        numIcon.url = UIPackage.GetItemURL("_others" , "meili_004")
    elseif index == 2 then
        bgIcon.url = UIPackage.GetItemURL("_panels" , "meili_010")
        numIcon.url = UIPackage.GetItemURL("_others" , "meili_005")
    else
        bgIcon.url = UIPackage.GetItemURL("_others" , "ditu_004")
        numIcon.visible = false
    end
    local rank = index + 1
    if data then
        rankTxt.text = data.rank
        nameTxt.text = data.roleName
        numTxt.text = data.score
    else
        rankTxt.text = rank
        nameTxt.text = language.rank03
        numTxt.text = 0
    end 
    local rankAwardData = {}
    if rank > 10 then
        rankAwardData = conf.ActivityWarConf:getSnowZsAward(rank - 10)
        if rankAwardData then
            rankTxt.text = rankAwardData.rank_range[1].."-"..rankAwardData.rank_range[2]
        else
            rankTxt.text = ""
        end
        nameTxt.text = ""
        numTxt.text = ""
        obj:GetChild("n4").visible = false
    else
        obj:GetChild("n4").visible = true
        rankAwardData = conf.ActivityWarConf:getSnowAward(4,rank)
    end
    local rankAwards = rankAwardData and rankAwardData.items or {}
    local listView = obj:GetChild("n16")
    listView.itemRenderer = function(index,obj)
        local award = rankAwards[index + 1]
        local itemData = {mid = award[1],amount = award[2],bind = award[3]}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #rankAwards
end

return YdXdzzRankView