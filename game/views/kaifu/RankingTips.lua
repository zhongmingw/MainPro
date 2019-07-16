--
-- Author: EVE
-- Date: 2017-08-02 21:25:10
--

local RankingTips = class("RankingTips", base.BaseView)

function RankingTips:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function RankingTips:initView()
    -- plog("哈口~~~~~~~~~~~~~~~~~")
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onCloseView, self)

    self.oursScore = self.view:GetChild("n5")   --积分
    self.oursScore.text = ""
    self.listGangView = self.view:GetChild("n8") --仙盟排行
    self:initListGangView()
end

function RankingTips:initListGangView()
    self.listGangView.numItems = 0
    self.listGangView.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listGangView:SetVirtual()
end

function RankingTips:itemData(index, obj)
    local data = self.rankingInfos[index+1]
    local controllerC1 = obj:GetController("c1")
    if data and data ~= "" then
        controllerC1.selectedIndex = 1
        local ranking = obj:GetChild("n7")  --名次
        ranking.text = data.ranking
        local gangName = obj:GetChild("n8")  --仙盟名
        gangName.text = data.gangName
        local score =obj:GetChild("n11")   --积分
        score.text = data.score
        local bossNum = obj:GetChild("n12") --BOSS归属
        bossNum.text = data.bossNum
        local warWinTimes = obj:GetChild("n13") --仙盟战胜利
        warWinTimes.text = data.warWinTimes
    else
        local ranking = obj:GetChild("n7")  --名次
        ranking.text = index + 1
        controllerC1.selectedIndex = 0
    end 

    local setRankingBG = index + 1  --设置排名背景图
    local bg = obj:GetChild("n3")
    local rankingBG = obj:GetChild("n5")
    if setRankingBG == 1 then
        bg.url = UIPackage.GetItemURL("_panels" , "meili_008")
        rankingBG.url = UIPackage.GetItemURL("_others" , "meili_003")     
    elseif setRankingBG == 2 then
        bg.url = UIPackage.GetItemURL("_panels" , "meili_009")
        rankingBG.url = UIPackage.GetItemURL("_others" , "meili_004")
    elseif setRankingBG == 3 then
        bg.url = UIPackage.GetItemURL("_panels" , "meili_010")
        rankingBG.url = UIPackage.GetItemURL("_others" , "meili_005")
    else
        bg.url = UIPackage.GetItemURL("_others" , "ditu_004")
        rankingBG.url = ""
    end
end

function RankingTips:initData(data)
    -- printt(data)
    -- plog("~~~~~~~~~~~~~~~~~~22222222222222")
    self.data = data
    self.rankingInfos = self.data.rankingInfos

    self.oursScore.text = self.data.myGangScore
    self.listGangView.numItems = 5
end

function RankingTips:onCloseView()
    self:closeView()
end

return RankingTips