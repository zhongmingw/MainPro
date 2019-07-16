--
-- Author: 
-- Date: 2018-12-20 14:01:40
--

local JiYiRankView = class("JiYiRankView", base.BaseView)

function JiYiRankView:ctor()
    JiYiRankView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function JiYiRankView:initView()
    local closeBtn = self.view:GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.awardsList = self.view:GetChild("n5")
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.awardsList:SetVirtual()
end

function JiYiRankView:initData(data)
    self.confData = conf.DongZhiConf:getRankData()
    self.awardsList.numItems = #self.confData
end


function JiYiRankView:cellData( index,obj )
    local data = self.confData[index+1]
    if data then 
        local rank = obj:GetChild("n2")
        -- local color
        -- if index <= 2 then
        --     color = 5- index
        -- else
        --     color =2
        -- end
        local str = ""
        if data.ranking[1] == data.ranking[2] then 
            str = string.format(language.flower06,data.ranking[1])
        elseif data.ranking[2] > 11 then
            str = language.rechargeRank15
        else
            str = string.format(language.flower06_01,data.ranking[1],data.ranking[2])
        end
        rank.text =str-- mgr.TextMgr:getQualityStr1(str,color) 
        local awardList = obj:GetChild("n4")
        local awardData = data.awards
        GSetAwards(awardList,awardData)
    end
end

return JiYiRankView