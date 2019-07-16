--
-- Author: 
-- Date: 2018-12-27 16:07:42
--奇兵战力排行


local QB1001 = class("QB1001",import("game.base.Ref"))

function QB1001:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function QB1001:initPanel()
    self.view = self.mParent.view:GetChild("n7")

    self.leftTime = self.view:GetChild("n9")  --倒计时
    self.leftTime.text = ""

    self.title = self.view:GetChild("n10")
    self.title.text = language.jianLingBorn03
    
    self.myRank = self.view:GetChild("n11")
    self.myRank.text = ""
    --奖励列表
    self.awardList = self.view:GetChild("n4")
    self.awardList.numItems = 0
    self.awardList.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end
    self.awardList:SetVirtual()
    --rank列表
    self.rankList = self.view:GetChild("n16")
    self.rankList.numItems = 0
    self.rankList.itemRenderer = function(index,obj)
        self:cellRankData(index, obj)
    end
    self.rankList:SetVirtual()
    local btn = self.view:GetChild("n7")
    btn.onClick:Add(self.onClickBtnCallBack,self)

    self.awardConfData = conf.ActivityConf:getQiBingRankAward()
    self.awardList.numItems = #self.awardConfData

end  

function QB1001:cellAwardData(index,obj)
    local data = self.awardConfData[index+1]
    local c1 = obj:GetController("c1")
    if index <= 3 then
        c1.selectedIndex = index
    else
        c1.selectedIndex = 3
    end
    if data then
        local list = obj:GetChild("n7")
        GSetAwards(list, data.awards)
    end
end

function QB1001:cellRankData(index,obj)
    local data = self.data.rankInfos[index+1]
    local c1 = obj:GetController("c1")
    if index <= 3 then
        c1.selectedIndex = index
    else
        c1.selectedIndex = 3
    end
    local rank = obj:GetChild("n6")
    local name = obj:GetChild("n0")
    local time = obj:GetChild("n2")
    
    rank.text = index+1
    if data then
        name.text = data.name
        time.text = data.power
        local roleId = data.roleId --玩家id
        local uId = string.sub(roleId,1,3)
       obj:GetChild("n9").visible = false
    if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
       obj:GetChild("n9").visible = true
    end
    else
        obj:GetChild("n9").visible = false
        name.text = language.flower08
        time.text = ""
    end
end

function QB1001:setData(data)
    self.data = data
    printt("骑兵战力排行",data)
    local rankSize = conf.ActivityConf:getValue("qibing_max_rank")--上榜人数

    if data.myRankInfo > rankSize or data.myRankInfo == 0 then
        self.myRank.text = language.flower11
    else
        self.myRank.text = string.format(language.flower06,tonumber(data.myRankInfo))
    end

    self.rankList.numItems = rankSize
end

function QB1001:onTimer()
    if self.data and self.data.leftTime then
        if self.data.leftTime > 86400 then 
            self.leftTime.text = GTotimeString7(self.data.leftTime)
        else
            self.leftTime.text = GTotimeString(self.data.leftTime)
        end
        if self.data.leftTime <= 0 then
            self.mParent:onBtnClose()
        end
        self.data.leftTime = self.data.leftTime-1
    end
end

function QB1001:onClickBtnCallBack()
    GOpenView({id = 1438})
end


return QB1001