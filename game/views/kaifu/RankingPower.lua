--
-- Author: EVE
-- Date: 2017-09-21 12:09:37
--

local RankingPower = class("RankingPower", base.BaseView)

function RankingPower:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function RankingPower:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onCloseView, self)
    self.titleImg = self.view:GetChild("n4")
    self.rankingList = self.view:GetChild("n3")
    self:initRankingList()
end

function RankingPower:initRankingList()
    self.rankingList.numItems = 0
    self.rankingList.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.rankingList:SetVirtual()
end

function RankingPower:itemData(index, obj)
    local data = self.data.powerRankings[index+1]
    local controllerC1 = obj:GetController("c1")
    local titleTxt = obj:GetChild("n7")
    if self.id == 1051 then
        titleTxt.text = language.kaifu63
    elseif self.id == 1075 then
        titleTxt.text = language.powerRanking01_1
    elseif self.id == 1091 then 
        titleTxt.text = language.shenqirank06
    elseif self.id == 1249 then 
        titleTxt.text = language.shenqirank06
    else
        titleTxt.text = language.kaifu62
    end
    local ranking = obj:GetChild("n2")  --名次
    ranking.text = index + 1
    if data and data ~= "" then
        controllerC1.selectedIndex = 0
        local name = obj:GetChild("n3")  --名字
        name.text = data.roleName
        local level = obj:GetChild("n4")  --等级
        level.text = data.power
    else
        controllerC1.selectedIndex = 1
    end 

    local setRankingBG = index + 1  --设置排名背景图
    local bg = obj:GetChild("n0")
    local rankingBG = obj:GetChild("n1")
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

function RankingPower:initData(data)
    self.data = data.data
    self.id = data.id
    -- printt(self.data)
    -- plog("哈利路亚~~22222~~~~~~~~") 
    if self.id == 1051 then
        self.titleImg.url = UIPackage.GetItemURL("kaifu" , "kaifupaihang_059")
    elseif self.id == 1075 then
        self.titleImg.url = UIPackage.GetItemURL("kaifu" , "kaifupaihang_070")
    elseif self.id == 1091 then --神器战力排行
        self.titleImg.url = UIPackage.GetItemURL("kaifu" , "kaifupaihang_074")
    elseif self.id == 1249 then --这个是模块id
        self.titleImg.url = UIPackage.GetItemURL("kaifu" , "kaifupaihang_074")
    else
        self.titleImg.url = UIPackage.GetItemURL("kaifu" , "kuafuzhanlipaihang_006")
    end
    if self.id == 1049 then 
        self.rankingList.numItems = 10
    else
        self.rankingList.numItems = 20
    end
end

function RankingPower:onCloseView()
    self:closeView()
end

return RankingPower