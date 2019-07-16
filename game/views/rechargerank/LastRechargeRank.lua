--
-- Author: Your Name
-- Date: 2018-07-23 11:22:53
--

local LastRechargeRank = class("LastRechargeRank", base.BaseView)



function LastRechargeRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function LastRechargeRank:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n3")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.rankName = self.view:GetChild("n4")
    self.ranking = {}
end

function LastRechargeRank:initData(data)
    -- printt("上一个榜单>>>>>>>>>",data)
    self.ranking = data.ranking
    self.rankName.url = UIPackage.GetItemURL("rechargerank",language.rechargeRank19[data.actId])

    self.listView.numItems = 10
end

function LastRechargeRank:celldata(index,obj)
    local data = self.ranking[index+1]
    local bgImg = obj:GetChild("n0")
    local rankIcon = obj:GetChild("n1")
    local rankTxt = obj:GetChild("n2")
    local nameTxt = obj:GetChild("n3")
    if index == 0 then
        bgImg.url = UIPackage.GetItemURL("_panels" , "meili_008")
        rankIcon.url = UIPackage.GetItemURL("_others" , "meili_003")
    elseif index == 1 then
        bgImg.url = UIPackage.GetItemURL("_panels" , "meili_009")
        rankIcon.url = UIPackage.GetItemURL("_others" , "meili_004")
    elseif index == 2 then
        bgImg.url = UIPackage.GetItemURL("_panels" , "meili_010")
        rankIcon.url = UIPackage.GetItemURL("_others" , "meili_005")
    else
        bgImg.url = UIPackage.GetItemURL("_others" , "ditu_004")
        rankIcon.visible = false
    end
    if data then
        rankTxt.text = data.rank
        nameTxt.text = data.name
    else
        rankTxt.text = index+1
        nameTxt.text = language.rechargeRank20
    end
end

return LastRechargeRank