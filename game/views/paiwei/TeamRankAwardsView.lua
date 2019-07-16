--
-- Author: Your Name
-- Date: 2018-01-08 16:00:43
--

local TeamRankAwardsView = class("TeamRankAwardsView", base.BaseView)

function TeamRankAwardsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function TeamRankAwardsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    --排行榜
    self.rankList = self.view:GetChild("n8")
    self.rankList.numItems = 0
    self.rankList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.rankList:SetVirtual()
    --奖励列表
    self.awardsList = self.view:GetChild("n20")
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function(index,obj)
        self:awardsCell(index, obj)
    end
    self.awardsList:SetVirtual()
    --押注列表
    self.guessList = self.view:GetChild("n26")
    self.guessList.numItems = 0
    self.guessList.itemRenderer = function(index,obj)
        self:guessCell(index, obj)
    end
    self.guessList:SetVirtual()

    self:onController()
    self.view:GetChild("n16").text = language.qualifier49
end

function TeamRankAwardsView:onController()
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    if self.c1.selectedIndex == 0 then
        proxy.QualifierProxy:sendMsg(1480206,{reqType = 0})
    elseif self.c1.selectedIndex == 1 then
        self.rankings = {}
        proxy.QualifierProxy:sendMsg(1480208,{page = 1})
    elseif self.c1.selectedIndex == 2 then
        self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
        proxy.QualifierProxy:sendMsg(1480212,{reqType = 0,stakeSId = 0})
    end
end

function TeamRankAwardsView:onTimer()
    local netTime = mgr.NetMgr:getServerTime()
    local day = GGetWeekDayByTimestamp(netTime)
    local teamStartDay = conf.QualifierConf:getValue("zd_week_day")
    -- print("时间",day)
    if day == teamStartDay[1] then
        local TimeTab = os.date("*t",netTime)
        local startTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0)
        local overTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0) + conf.QualifierConf:getValue("start_diff")
        if (netTime >= startTime - 1 and netTime <= startTime + 1) or
            (netTime >= overTime - 1 and netTime <= overTime + 1) then
            proxy.QualifierProxy:sendMsg(1480212,{reqType = 0,stakeSId = 0})
        end
    end
end

function TeamRankAwardsView:initData(data)
    self.c1.selectedIndex = data.index
end

function TeamRankAwardsView:cellData( index,obj )

    if index + 1 >= self.rankList.numItems then
        if not self.rankings then
            return 
        end 
        if self.maxPage == self.page then 
            --没有下一页了
            --return
        elseif self.page and self.page < self.maxPage then
            local param = {page=self.page+1}
            proxy.RankProxy:sendRankMsg(1480208,param)
        end
    end
    local data = self.rankings[index+1]
    if data then
        local bgIcon = obj:GetChild("n0")
        local numIcon = obj:GetChild("n1")
        numIcon.visible = true
        if index == 0 then
            bgIcon.url = UIPackage.GetItemURL("paiwei" , "meili_008")
            numIcon.url = UIPackage.GetItemURL("paiwei" , "meili_003")
        elseif index == 1 then
            bgIcon.url = UIPackage.GetItemURL("paiwei" , "meili_009")
            numIcon.url = UIPackage.GetItemURL("paiwei" , "meili_004")
        elseif index == 2 then
            bgIcon.url = UIPackage.GetItemURL("paiwei" , "meili_010")
            numIcon.url = UIPackage.GetItemURL("paiwei" , "meili_005")
        else
            bgIcon.url = UIPackage.GetItemURL("_others" , "ditu_004")
            numIcon.visible = false
        end
        local rank = obj:GetChild("n2")
        local teamName = obj:GetChild("n3")
        local captainName = obj:GetChild("n4")
        local power = obj:GetChild("n5")
        local pwLev = obj:GetChild("n6")
        local stars = obj:GetChild("n8")
        rank.text = data.rank
        teamName.text = data.teamName
        captainName.text = data.captainName or ""
        power.text = data.power
        local pwData = conf.QualifierConf:getPwsTeamDataByLv(data.pwLev)
        pwLev.text = pwData.name
        stars.text = pwData.stars

        local roleId = data.captainRoleId
        local uId = string.sub(roleId,1,3)
        obj:GetChild("n9").visible = false
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
           obj:GetChild("n9").visible = true
        end
    end
end

function TeamRankAwardsView:awardsCell( index,obj )
    local data = self.awardsConf[index+1]
    if data then
        local needLv = obj:GetChild("n1")
        local stateTxt = obj:GetChild("n2")
        local c1 = obj:GetController("c1")
        local getBtn = obj:GetChild("n7")
        local listView = obj:GetChild("n4")
        local pwData = conf.QualifierConf:getPwsTeamDataByLv(data.con)
        needLv.text = pwData.name .. pwData.stars .. language.gonggong118
        getBtn.data = data
        getBtn.onClick:Add(self.onClickGet,self)
        -- print("奖励。。。。。。。。。")
        listView.numItems = 0
        for k,v in pairs(data.item) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local item = listView:AddItemFromPool(url)
            local mId = v[1]
            local amount = v[2]
            local bind = v[3]
            local info = {mid = mId,amount = amount,bind = bind}
            GSetItemData(item,info,true)
        end
        local flag = false
        for k,v in pairs(self.awardsData.awardSigns) do
            if k == data.id then
                flag = true
            end
        end
        local pwLev = self.awardsData.pwLev
        if pwLev >= data.con then
            c1.selectedIndex = 1
        else
            c1.selectedIndex = 0
        end
        if flag then
            c1.selectedIndex = 2
        end
    end
end

function TeamRankAwardsView:guessCell( index,obj )
    local data = self.stakes[index+1]
    if data then
        local decTxt = obj:GetChild("n1")
        decTxt.text = language.qualifier41
        local svrId = obj:GetChild("n2")
        local sumStake = obj:GetChild("n4")
        local myStake = obj:GetChild("n6")
        local c1 = obj:GetController("c1")
        local winImg = obj:GetChild("n9")
        winImg.visible = false
        --押注按钮
        local stakeBtn = obj:GetChild("n7")
        stakeBtn.data = data
        stakeBtn.onClick:Add(self.onClickStake,self)
        if self.guessData.stage == 1 then
            c1.selectedIndex = 0
        elseif self.guessData.stage == 2 then
            c1.selectedIndex = 1
            local flag = false
            for k,v in pairs(self.guessData.winSid) do
                if v == data.agentServerId then
                    flag = true
                    break
                end
            end
            if flag then
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
        svrId.text = GTransformServerId(data.agentServerId)
        sumStake.text = data.stakeValue
        myStake.text = data.myStake
    end
end

function TeamRankAwardsView:onClickStake(context)
    local data = context.sender.data
    if self.guessData.stage == 0 then
        GComAlter(language.qualifier26)
    elseif self.guessData.stage == 1 then
        if self.leftStake > 0 then
            local gold = cache.PlayerCache:getTypeMoney(MoneyType.gold)
            local bindGold = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
            local needYb = conf.QualifierConf:getValue("zd_stake_cfg")
            local param = {}
            param.type = 2
            local str = string.format(language.qualifier59,needYb[2])
            param.richtext = str
            param.sure = function()
                -- body
                if gold+bindGold >= needYb[2] then
                    proxy.QualifierProxy:sendMsg(1480212,{reqType = self.guessData.stage,stakeSId = data.agentServerId})
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
            proxy.QualifierProxy:sendMsg(1480212,{reqType = self.guessData.stage,stakeSId = data.agentServerId})
        else
            GComAlter(language.qualifier43)
        end
    end
end

function TeamRankAwardsView:onClickGet(context)
    local data = context.sender.data
    proxy.QualifierProxy:sendMsg(1480206,{reqType = 1,cfgId = data.id})
end

-- 变量名：awardSigns  说明：已领取的奖励配置id
-- 变量名：cfgId   说明：奖励配置id
-- 变量名：items   说明：奖励
-- 变量名：reqType 说明： 0:显示 1:领取
function TeamRankAwardsView:setAwardsData(data)
    printt("组队排位赛目标奖励",data)
    self.awardsData = data

    self.awardsConf = {}
    local confData = conf.QualifierConf:getPwsTeamAimAwardsData()
    for k,v in pairs(confData) do
        if data.awardSigns[v.id] then--已领取的放到最后
            confData[k].sort = 1
        else
            confData[k].sort = 0
        end
        table.insert(self.awardsConf,v)
    end
    table.sort(self.awardsConf,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        elseif a.id ~= b.id then
            return a.id < b.id
        end
    end)
    self.awardsList.numItems = #self.awardsConf
    self.awardsList:ScrollToView(0,false)
    local myDuanwei = self.view:GetChild("n22")
    local myPwData = conf.QualifierConf:getPwsTeamDataByLv(data.pwLev)
    -- print("组队排位赛目标奖励",#self.awardsConf)
    myDuanwei.text = myPwData.name .. myPwData.stars .. language.gonggong118
end
--排行榜数据返回
function TeamRankAwardsView:setRankData(data)
    self.pwData = data
    for k,v in pairs(data.rankList) do
        table.insert(self.rankings,v)
    end
    self.page = data.page
    self.maxPage = data.pageSum
    self.rankList.numItems = #self.rankings
    local myRankTxt = self.view:GetChild("n6")
    myRankTxt.text = data.myRank > 0 and data.myRank or language.rank04
    local myDuanwei = self.view:GetChild("n7")
    local myPwData = conf.QualifierConf:getPwsTeamDataByLv(data.myPwLev)
    -- print("000000000000",myDuanwei,myPwData,data.myPwLev)
    myDuanwei.text = myPwData.name .. myPwData.stars .. language.gonggong118
end

-- 变量名：stakes  说明：押注列表
-- 变量名：reqType 说明：0:显示 1:押注 2:领取
-- 变量名：stakeCount  说明：我的当前押注数量
-- 变量名：stakeSId    说明：押注的服务器id
-- 变量名：cfgId   说明：领取的配置id
-- 变量名：items   说明：道具列表
-- 变量名：stage 说明：0:暂未开始 1:押注阶段 2:领取阶段
-- 变量名：winSid  说明：赢的服务器id
--竞猜数据返回
function TeamRankAwardsView:setGuessData(data)
    self.guessData = data
    self.stakes = {}
    printt("押注列表",data)
    self:stakesSort()
    -- 变量名：agentServerId   说明：服务器id
    -- 变量名：stakeValue  说明：总押注
    -- 变量名：myStake 说明：我的押注
    self.maxStake = conf.QualifierConf:getValue("zd_stake_max")
    local maxStakeTxt = self.view:GetChild("n30")
    maxStakeTxt.text = self.maxStake
    self.leftStake = self.maxStake - data.stakeCount
    self.guessList.numItems = #self.stakes
    
end

--竞猜数据排序>>获胜队伍优先
function TeamRankAwardsView:stakesSort()
    local data = self.guessData.stakes
    for k,v in pairs(data) do
        for _,winSid in pairs(self.guessData.winSid) do
            if winSid == v.agentServerId then
                data[k].sign = 1
                break
            else
                data[k].sign = 0
            end
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

function TeamRankAwardsView:doClearView(clear)
    self.rankings = {}
end

return TeamRankAwardsView