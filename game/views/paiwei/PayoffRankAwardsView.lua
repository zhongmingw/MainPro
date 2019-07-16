--
-- Author: Your Name
-- Date: 2018-01-08 16:00:43
--

local PayoffRankAwardsView = class("PayoffRankAwardsView", base.BaseView)

function PayoffRankAwardsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function PayoffRankAwardsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    --奖励列表
    self.awardsList1 = self.view:GetChild("n20")
    self.awardsList1.numItems = 0
    self.awardsList1.itemRenderer = function(index,obj)
        self:awardsCell1(index, obj)
    end
    self.awardsList1:SetVirtual()
    self.awardsList2 = self.view:GetChild("n32")
    self.awardsList2.numItems = 0
    self.awardsList2.itemRenderer = function(index,obj)
        self:awardsCell2(index, obj)
    end
    self.awardsList2:SetVirtual()
    --押注列表
    self.guessList = self.view:GetChild("n26")
    self.guessList.numItems = 0
    self.guessList.itemRenderer = function(index,obj)
        self:guessCell(index, obj)
    end
    self.guessList:SetVirtual()

    self:onController()
end

function PayoffRankAwardsView:onController()
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    if self.c1.selectedIndex == 0 then
        self.awardsConf1 = conf.QualifierConf:getPayoffAwards()
        self.awardsConf2 = conf.QualifierConf:getSeverAwards()
        self.awardsList1.numItems = #self.awardsConf1
        self.awardsList2.numItems = #self.awardsConf2
    elseif self.c1.selectedIndex == 1 then
        self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
        proxy.QualifierProxy:sendMsg(1480303,{reqType = 0,stakeTeamId = 0})
    end
end

function PayoffRankAwardsView:onTimer()
    local netTime = mgr.NetMgr:getServerTime()
    local day = GGetWeekDayByTimestamp(netTime)
    if day == 0 then day = 7 end
    local teamStartDay = conf.QualifierConf:getValue("jhs_week_day")
    -- print("时间",day)
    if day == teamStartDay[1] then
        local TimeTab = os.date("*t",netTime)
        local startTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0)
        local overTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0) + conf.QualifierConf:getValue("start_diff")
        if (netTime >= startTime - 1 and netTime <= startTime + 1) or
            (netTime >= overTime - 1 and netTime <= overTime + 1) then
            proxy.QualifierProxy:sendMsg(1480303,{reqType = 0,stakeTeamId = 0})
        end
    end
end

function PayoffRankAwardsView:initData(data)
    self.awardsConf1 = conf.QualifierConf:getPayoffAwards()
    self.awardsConf2 = conf.QualifierConf:getSeverAwards()
    self.c1.selectedIndex = data.index
end

function PayoffRankAwardsView:awardsCell1( index,obj )
    local data = self.awardsConf1[index+1]
    if data then
        local rankTxt = obj:GetChild("n2")
        local awardsList = obj:GetChild("n0")
        local decTxt = obj:GetChild("n3")
        decTxt.text = language.qualifier36
        if data.rank then
            if data.rank[1] == data.rank[2] then
                rankTxt.text = string.format(language.qualifier35,data.rank[1])
            else
                rankTxt.text = string.format(language.qualifier35,data.rank[1]) .. "-" .. data.rank[2]
            end
        end
        awardsList.numItems = 0
        for k,v in pairs(data.item) do
            local mId = v[1]
            local amount = v[2]
            local bind = v[3]
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local cell = awardsList:AddItemFromPool(url)
            GSetItemData(cell, {mid = mId,amount = amount,bind = bind},true)
        end
    end
end

function PayoffRankAwardsView:awardsCell2( index,obj )
    local data = self.awardsConf2[index+1]
    if data then
        local rankTxt = obj:GetChild("n2")
        local awardsList = obj:GetChild("n0")
        local decTxt = obj:GetChild("n3")
        decTxt.text = language.qualifier37
        if data.rank then
            if data.rank[1] == data.rank[2] then
                rankTxt.text = string.format(language.qualifier35,data.rank[1])
            else
                rankTxt.text = string.format(language.qualifier35,data.rank[1]) .. "-" .. data.rank[2]
            end
        end
        awardsList.numItems = 0
        for k,v in pairs(data.item) do
            local mId = v[1]
            local amount = v[2]
            local bind = v[3]
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local cell = awardsList:AddItemFromPool(url)
            GSetItemData(cell, {mid = mId,amount = amount,bind = bind},true)
        end
    end
end

function PayoffRankAwardsView:guessCell( index,obj )
    local data = self.stakes[index+1]
    if data then
        local decTxt = obj:GetChild("n1")
        decTxt.text = language.qualifier40
        local teamNameTxt = obj:GetChild("n2")
        local sumStake = obj:GetChild("n4")
        local myStake = obj:GetChild("n6")
        local c1 = obj:GetController("c1")
        local winImg = obj:GetChild("n9")
        winImg.visible = false
        --押注按钮
        local stakeBtn = obj:GetChild("n7")
        if self.guessData.stage == 1 then
            c1.selectedIndex = 0
        elseif self.guessData.stage == 2 then
            c1.selectedIndex = 1
            if data.teamId == self.guessData.winTeamId then
                stakeBtn.visible = true
                winImg.visible = true
            else
                stakeBtn.visible = false
                winImg.visible = false
            end
        end
        if data.awardSign == 1 then
            c1.selectedIndex = 2
        end
        teamNameTxt.text = data.teamName
        sumStake.text = data.stakeValue
        myStake.text = data.myStake
        stakeBtn.data = data
        stakeBtn.onClick:Add(self.onClickStake,self)
    end
end

function PayoffRankAwardsView:onClickStake(context)
    local data = context.sender.data
    if self.guessData.stage == 0 then
        GComAlter(language.qualifier26)
    elseif self.guessData.stage == 1 then
        if self.leftStake > 0 then
            local gold = cache.PlayerCache:getTypeMoney(MoneyType.gold)
            local bindGold = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
            local needYb = conf.QualifierConf:getValue("jhs_stake_cfg")
            local param = {}
            param.type = 2
            param.richtext = string.format(language.qualifier59,needYb[2])
            param.sure = function()
                -- body
                if gold+bindGold >= needYb[2] then
                    proxy.QualifierProxy:sendMsg(1480303,{reqType = self.guessData.stage,stakeTeamId = data.teamId})
                else
                    GComAlter(language.gonggong18)
                end
            end
            param.cancel = function()
                -- body
            end
            GComAlter(param)
        else
            GComAlter(language.qualifier22)
        end
    else
        if data.myStake > 0 then
            proxy.QualifierProxy:sendMsg(1480303,{reqType = self.guessData.stage,stakeTeamId = data.teamId})
        else
            GComAlter(language.qualifier43)
        end
    end
end


-- 变量名：reqType 说明：0:显示 1:押注 2:领取
-- 变量名：stakeTeamId 说明：押注的队伍id
-- 变量名：stakes  说明：押注列表
-- 变量名：items   说明：道具列表
-- 变量名：stage   说明：0:暂未开始 1:押注阶段 2:领取阶段
-- 变量名：winTeamId   说明：赢的队伍id
-- 变量名：stakeCount  说明：我的当前押注数量
--竞猜数据返回
function PayoffRankAwardsView:setGuessData(data)
    self.guessData = data
    self.stakes = {}
    self:stakesSort()
    -- 变量名：teamId   说明：队伍id
    -- 变量名：stakeValue  说明：总押注
    -- 变量名：myStake 说明：我的押注
    -- printt("押注列表",data)
    self.maxStake = conf.QualifierConf:getValue("jhs_stake_max")
    local maxStakeTxt = self.view:GetChild("n30")
    maxStakeTxt.text = self.maxStake
    self.leftStake = self.maxStake - data.stakeCount
    self.guessList.numItems = #self.stakes
    
end

--竞猜数据排序>>获胜队伍优先
function PayoffRankAwardsView:stakesSort()
    local data = self.guessData.stakes
    for k,v in pairs(data) do
        if v.teamId == self.guessData.winTeamId then
            data[k].sign = 1
        else
            data[k].sign = 0
        end
    end
    table.sort(data,function(a,b)
        if a.sign and b.sign then
            return a.sign > b.sign
        elseif a.sign then
            return true
        else
            return false
        end
    end)
    self.stakes = data
end

function PayoffRankAwardsView:doClearView(clear)
    self.rankings = {}
end

return PayoffRankAwardsView