--
-- Author: 
-- Date: 2018-07-25 11:46:11
--

local XianLvPKRankAward = class("XianLvPKRankAward", base.BaseView)

function XianLvPKRankAward:ctor()
    XianLvPKRankAward.super.ctor(self)
    self.uiLevel = UILevel.level2   
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function XianLvPKRankAward:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    
    local rank = self.view:GetChild("n5")

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    self.listView = self.view:GetChild("n6")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

end

function XianLvPKRankAward:initData(data)
    self.data = data or {}
    self.mulActiveId = cache.XianLvCache:getMulActiveId()
    -- print("多开id",self.mulActiveId)
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.mulActiveId)
    --前缀
    self.pre = self.mulConfData.award_pre
    self:onController()

end

function XianLvPKRankAward:onController()
    if self.c1.selectedIndex == 0 then
        if self.data.msgId and self.data.msgId == 5540101 then--跨服
            self.awardData = conf.XianLvConf:getHxsAwardByType(self.pre,2)
        elseif self.data.msgId and self.data.msgId == 5540201 then--全服
            self.awardData = conf.XianLvConf:getWorldHxsAwardByType(self.pre,2)
        end
    elseif self.c1.selectedIndex == 1 then
        if self.data.msgId and self.data.msgId == 5540101 then--跨服
            self.awardData = conf.XianLvConf:getZbsAward(self.pre)
        elseif self.data.msgId and self.data.msgId == 5540201 then--全服
            self.awardData = conf.XianLvConf:getWorldZbsAward(self.pre)
        end
    end
    self.listView.numItems = #self.awardData    
end

function XianLvPKRankAward:cellData( index,obj )
    local data = self.awardData[index+1]
    local awardList = obj:GetChild("n3")
    local title = obj:GetChild("n1")
    if data then
        GSetAwards(awardList, data.item)
        local dec = ""
        if self.c1.selectedIndex == 0 then
            dec = ""
        else
            dec = language.xianlv24[data.type]
        end
        local str = ""
        if data.rank[1] == data.rank[2] then
            str = dec..string.format(language.kaifu12,data.rank[1])
        else
            str = dec..string.format(language.kaifu11,data.rank[1],data.rank[2])
        end
        title.text = str
    end
end

return XianLvPKRankAward