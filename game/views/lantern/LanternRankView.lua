--
-- Author: 
-- Date: 2018-01-31 17:17:48
--

local LanternRankView = class("LanternRankView", base.BaseView)

function LanternRankView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function LanternRankView:initView()
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


function LanternRankView:initData(data)
    proxy.ActivityProxy:send(1030181)
end

function LanternRankView:setData(data)
    self.data = data
    self.view:GetChild("n19").text = data.myRankInfo.score
    local rank = language.rank04
    if data.myRankInfo.ranking > 0 then
        rank = data.myRankInfo.ranking
    end
    self.view:GetChild("n21").text = rank
    local numItems = math.max(10, #self.data.scoreRankings)
    self.listView.numItems = numItems
end

function LanternRankView:celldata( index,obj )
    local data = self.data.scoreRankings[index+1]
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
        rankTxt.text = data.ranking
        nameTxt.text = data.roleName
        numTxt.text = data.score
    else
        rankTxt.text = rank
        nameTxt.text = language.rank03
        numTxt.text = 0
    end 
end

return LanternRankView