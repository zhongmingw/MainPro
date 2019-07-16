--
-- Author: 
-- Date: 2018-10-31 15:19:33
--

local TuoDanAward = class("TuoDanAward", base.BaseView)

function TuoDanAward:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end

function TuoDanAward:initView()
    local clsoeBtn = self.view:GetChild("n2")
    self:setCloseBtn(clsoeBtn)
    self.awardList = self.view:GetChild("n7")
    self.awardList.itemRenderer = function (index,obj)
        self:setAwardData(index,obj)
    end
    self.awardList.numItems = 0
    self.awardList:SetVirtual()
end

function TuoDanAward:initData(data)
    self.confData = data.awardData
    self.awardList.numItems = #self.confData
end

function TuoDanAward:setAwardData(index,obj)
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

return TuoDanAward