--
-- Author: EVE
-- Date: 2017-08-24 21:55:20
--

local RankingLevel = class("RankingLevel", base.BaseView)

function RankingLevel:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function RankingLevel:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onCloseView, self)

    self.rankingList = self.view:GetChild("n3")
    self:initRankingList()
end

function RankingLevel:initRankingList()
    self.rankingList.numItems = 0
    self.rankingList.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.rankingList:SetVirtual()
end

function RankingLevel:itemData(index, obj)
    local data = self.data.rankInfos[index+1]
    local controllerC1 = obj:GetController("c1")

    local ranking = obj:GetChild("n2")  --名次
    ranking.text = index + 1
    if data and data ~= "" then
        controllerC1.selectedIndex = 0
        local name = obj:GetChild("n3")  --名字
        name.text = data.roleName
        local level = obj:GetChild("n4")  --等级
        level.text = data.level..language.kaifuchongji02
        local exp = obj:GetChild("n5")  --经验 
        -- plog("玩家等级处理：",data.roleName,data.percent,conf.RoleConf:getRoleExpById(data.level))
        if data.level == 500 then   
            exp.text = nil
        else
            exp.text = (math.floor(data.exp*1000/conf.RoleConf:getRoleExpById(data.level))/10).."%"
        end 
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

function RankingLevel:initData(data)
    self.data = data
    -- printt(self.data)
    -- plog("哈利路亚~~22222~~~~~~~~") 

    self.rankingList.numItems = 20
end

function RankingLevel:onCloseView()
    self:closeView()
end

return RankingLevel