--
-- Author: 
-- Date: 2018-07-06 15:04:08
--

local MarryRankAward = class("MarryRankAward", base.BaseView)

function MarryRankAward:ctor()
    MarryRankAward.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function MarryRankAward:initView()
    local closeBtn = self.view:GetChild("n10")
    self:setCloseBtn(closeBtn)

    self.awardsList = self.view:GetChild("n6")
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.awardsList:SetVirtual()
end

function MarryRankAward:initData(data)
    self.confData = conf.ActivityConf:getMarryRankAwardsByActId(data.actId)
    self.awardsList.numItems = #self.confData
end


function MarryRankAward:cellData( index,obj )
    local data = self.confData[index+1]
    if data then 
        local rank = obj:GetChild("n1")
        local color
        if index <= 2 then
            color = 5- index
        else
            color =2
        end
        local str = ""
        if data.rank[1] == data.rank[2] then 
            str = string.format(language.flower06,data.rank[1])
        elseif data.rank[2] > 11 then
            str = language.rechargeRank15
        else
            str = string.format(language.flower06_01,data.rank[1],data.rank[2])
        end
        rank.text = mgr.TextMgr:getQualityStr1(str,color) 
        local awardList = obj:GetChild("n3")
        local awardData = data.awards
        GSetAwards(awardList,awardData)
    end
end

return MarryRankAward