--
-- Author: 
-- Date: 2018-06-29 14:12:50
--

local RankAward = class("RankAward", base.BaseView)

function RankAward:ctor()
    RankAward.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function RankAward:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    self.awardsList = self.view:GetChild("n6")
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.awardsList:SetVirtual()
    self.rank = self.view:GetChild("n5")
    self.rank.text = ""
end

function RankAward:initData(data)
    self.myRank = data.myRank
    self.actId = data.actId
    if data.pre then
        self.confData = conf.ActivityConf:getRankAwardsByActId(data.actId,data.pre)
    else
        self.confData = conf.ActivityConf:getRankAwardsByActId(data.actId)
    end
    self.awardsList.numItems = #self.confData

    local sex = cache.PlayerCache:getSex()
    local rankStr 
    if self.myRank == 0 then 
        self.rank.text = language.flower05[sex]..language.flower11
    else
        for k,v in pairs(self.confData) do
            if self.myRank >= v.rank[1] and self.myRank <= v.rank[2] then 
                if v.rank[1] == v.rank[2] then 
                    self.rank.text = language.flower05[sex]..string.format(language.flower06,tostring(v.rank[1]))
                else
                    self.rank.text = language.flower05[sex]..string.format(language.flower06_01,tostring(v.rank[1]),tostring(v.rank[2]))
                end
                break
            end
        end
    end
end

function RankAward:onController()
    self.awardsList.numItems = #self.confData
    
end

function RankAward:cellData( index,obj )
    local data = self.confData[index+1]
    if data then 
        local rank = obj:GetChild("n1")
        if data.rank[1] == data.rank[2] then 
            rank.text = string.format(language.flower06,data.rank[1])
        elseif data.rank[2] > 11 then
            rank.text = language.rechargeRank15
        else
            rank.text = string.format(language.flower06_01,data.rank[1],data.rank[2])
        end
        local awardList = obj:GetChild("n3")
        local awardData
        if self.c1.selectedIndex == 0 then
            awardData = data.awards_ns
        elseif self.c1.selectedIndex == 1 then
            awardData = data.awards_hh
        end
        GSetAwards(awardList,awardData)
    end
end

return RankAward