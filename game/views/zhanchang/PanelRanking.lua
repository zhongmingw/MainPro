--跨服排位
local PanelRanking = class("PanelRanking", import("game.base.Ref"))

function PanelRanking:ctor(parent,view)
    -- body
    self.parent = parent
    self.view = view
    self.imgPath = nil
    self:initView()
end

function PanelRanking:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    self.aloneSoloPanel = self.view:GetChild("n28")
    self.teamPanel = self.view:GetChild("n29")
    self.payoffPanel = self.view:GetChild("n30")
    self.listView = self.view:GetChild("n19")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    -- self.listView.numItems = #language.qualifier01

    self.aloneSoloPanel:GetChild("n24").text = language.qualifier06
    self.aloneSoloPanel:GetChild("n25").text = language.qualifier07
    self.aloneSoloPanel:GetChild("n14").text = language.qualifier08
    self.aloneSoloPanel:GetChild("n15").text = language.qualifier09
end

function PanelRanking:setIndex(index)
    self.c1.selectedIndex = index
    self.titleBtn = {}
    self.listView.numItems = #language.qualifier01
    self:refreshRed()
end

--红点刷新
function PanelRanking:refreshRed()
    --标题按钮红点
    --attConst.A50121,attConst.A50122,attConst.A50123,attConst.A50124,attConst.A50125
    local t = {[1] = {attConst.A50124,attConst.A50126},[2] = {attConst.A50122,attConst.A50125,attConst.A50127},[3] = {attConst.A50123}}
    local one_week_day = conf.QualifierConf:getValue("one_week_day")
    local zd_week_day = conf.QualifierConf:getValue("zd_week_day")
    local jhs_week_day = conf.QualifierConf:getValue("jhs_week_day")
    local dayTab = {[1] = one_week_day,[2] = zd_week_day,[3] = jhs_week_day}
    for k,value in pairs(t) do
        local btn = self.titleBtn[k]
        local redNum = 0
        for _,id in pairs(value) do
            redNum = redNum + cache.PlayerCache:getRedPointById(id)
        end
        local netTime = mgr.NetMgr:getServerTime()
        local day = GGetWeekDayByTimestamp(netTime)
        if day == 0 then day = 7 end
        local flag = false
        for _,d in pairs(dayTab[k]) do
            if d == day then
                flag = true
                break
            end
        end
        if flag then
            redNum = redNum + cache.PlayerCache:getRedPointById(attConst.A50121)
        end
        -- local enterRed = 
        if redNum > 0 then
            btn:GetChild("n5").visible = true
        else
            btn:GetChild("n5").visible = false
        end
    end
    local soloAwardsBtn = self.aloneSoloPanel:GetChild("n3")
    if cache.PlayerCache:getRedPointById(attConst.A50124) > 0 then
        soloAwardsBtn:GetChild("red").visible = true
    else
        soloAwardsBtn:GetChild("red").visible = false
    end
    local teamAwardsBtn = self.teamPanel:GetChild("n12")
    if cache.PlayerCache:getRedPointById(attConst.A50125) > 0 then
        teamAwardsBtn:GetChild("red").visible = true
    else
        teamAwardsBtn:GetChild("red").visible = false
    end
    local teamGuessBtn = self.teamPanel:GetChild("n20")
    if cache.PlayerCache:getRedPointById(attConst.A50122) > 0 then
        teamGuessBtn:GetChild("red").visible = true
    else
        teamGuessBtn:GetChild("red").visible = false
    end
    local payoffGuessBtn = self.payoffPanel:GetChild("n23")
    if cache.PlayerCache:getRedPointById(attConst.A50123) > 0 then
        payoffGuessBtn:GetChild("red").visible = true
    else
        payoffGuessBtn:GetChild("red").visible = false
    end
end

function PanelRanking:onController()
    if self.c1.selectedIndex == 0 then
        print("请求单人排位")
        proxy.QualifierProxy:sendMsg(1480101)
    elseif self.c1.selectedIndex == 1 then
        print("请求组队排位")
        proxy.QualifierProxy:sendMsg(1480201)
    elseif self.c1.selectedIndex == 2 then
        print("请求季后赛")
        proxy.QualifierProxy:sendMsg(1480301)
    end
end

function PanelRanking:cellData( index,obj )
    local text = language.qualifier01[index+1]
    if text then
        obj:GetChild("title").text = text
        obj.data = index
        if self.c1.selectedIndex == index then
            obj.selected = true
        else
            obj.selected = false
        end
        table.insert(self.titleBtn,obj)
        obj.onClick:Add(self.onClickCall,self)
    end
end

function PanelRanking:onClickCall(context)
    local obj = context.sender
    local index = obj.data
    self.c1.selectedIndex = index
    obj.selected = true
end

-- 变量名：playCount   说明：已挑战次数
-- 变量名：winRate 说明：胜率
-- 变量名：joinCount   说明：参与次数
-- 变量名：buyCount    说明：已购买次数
-- 变量名：pwLev   说明：排位等级
-- 变量名：matchStatu  说明：0:未开始匹配 1:已开始匹配
-- map<int32,int32>
-- 变量名：targetAwardSigns    说明：已领取的目标奖励
-- 变量名：open    说明：1:已开启 0:未开启
function PanelRanking:setSoloData(data)
    -- body
    printt("单人排位信息",data)
    self.aloneData = data
    local guizeBtn = self.aloneSoloPanel:GetChild("n13")
    guizeBtn.data = {type = 1}
    guizeBtn.onClick:Add(self.onClickGuize,self)
    local windRateTxt = self.aloneSoloPanel:GetChild("n16")
    local joinCountTxt = self.aloneSoloPanel:GetChild("n17")
    windRateTxt.text = data.winRate .. "%"
    joinCountTxt.text = data.joinCount
    
    local rankAwardsBtn = self.aloneSoloPanel:GetChild("n3")
    rankAwardsBtn.data = 0
    rankAwardsBtn.onClick:Add(self.onClickRankInfo,self)
    local rankInfoBtn = self.aloneSoloPanel:GetChild("n2")
    rankInfoBtn.data = 1
    rankInfoBtn.onClick:Add(self.onClickRankInfo,self)
    --段位信息
    local pwData = conf.QualifierConf:getPwsDataByLv(data.pwLev)
    local gradingIcon = self.aloneSoloPanel:GetChild("n28")
    local lvIcon = self.aloneSoloPanel:GetChild("n30")
    gradingIcon.url = UIPackage.GetItemURL("paiwei",pwData.img)
    lvIcon.url = UIPackage.GetItemURL("paiwei",pwData.lv_img)
    local starPanel = self.aloneSoloPanel:GetChild("n11")
    local starsNum = self.aloneSoloPanel:GetChild("n35")
    print("当前段位",pwData.stars,pwData.max_stars)
    if pwData.max_stars then
        for i=1,5 do
            if i <= pwData.max_stars then
                starPanel:GetChild("n"..i-1).visible = true
            else
                starPanel:GetChild("n"..i-1).visible = false
            end
            if i <= pwData.stars then
                starPanel:GetChild("n"..i+9).visible = true
            else
                starPanel:GetChild("n"..i+9).visible = false
            end
        end
        starsNum.visible = false
    else
        starsNum.visible = true
        starsNum.text = "*" .. pwData.stars
        for i=1,5 do
            if i == 1 then
                starPanel:GetChild("n"..i-1).visible = true
                starPanel:GetChild("n"..i+9).visible = true
            else
                starPanel:GetChild("n"..i-1).visible = false
                starPanel:GetChild("n"..i+9).visible = false
            end
        end
    end
    --单人目标奖励
    local bar = self.aloneSoloPanel:GetChild("n8")
    local maxCount = conf.QualifierConf:getValue("one_free_max")
    bar.max = maxCount
    bar.value = data.playCount
    local boxBtnList = {}
    local boxEffect = {}
    for i=5,7 do
        table.insert(boxBtnList,self.aloneSoloPanel:GetChild("n"..i))
        table.insert(boxEffect,self.aloneSoloPanel:GetChild("n"..i+27))
    end
    print("目标奖励",data.playCount)
    --目标奖励
    local awardsData = conf.QualifierConf:getPwsAwardsData()
    for k,v in pairs(boxBtnList) do
        print(k,v,awardsData[k].con)
        local flag = 0
        if awardsData[k].con <= data.playCount then
            flag = 1
            if data.targetAwardSigns[awardsData[k].id] then
                flag = 2
            end
        end
        if flag == 0 then--无法领取
            boxEffect[k].visible = false
            v:GetChild("icon").url = UIPackage.GetItemURL("paiwei",UIItemRes.boxClose[k])
        elseif flag == 1 then--可领取
            boxEffect[k].visible = true
            v:GetChild("icon").url = UIPackage.GetItemURL("paiwei",UIItemRes.boxClose[k])
        elseif flag == 2 then--已领取
            boxEffect[k].visible = false            
            v:GetChild("icon").url = UIPackage.GetItemURL("paiwei",UIItemRes.boxOpen[k])
        end
        v.data = {flag = flag,cId = awardsData[k].id,awards = awardsData[k].item,type = 1}
        v.onClick:Add(self.onClickGetAimAwards,self)
    end
    --今日已参与次数
    local todayCount = self.aloneSoloPanel:GetChild("n19")
    local textData = {
        {text = language.qualifier03[1],color = 5},
        {text = "(" .. data.playCount .. "/" .. maxCount .. ")",color = 4},
        {text = language.qualifier03[2],color = 5},
    }
    todayCount.text = mgr.TextMgr:getTextByTable(textData)
    --剩余挑战次数
    local lastCount = self.aloneSoloPanel:GetChild("n26")
    local lastcountNum = maxCount + data.buyCount - data.playCount
    lastCount.text = lastcountNum
    local addBtn = self.aloneSoloPanel:GetChild("n27")
    addBtn.data = {buyCount = data.buyCount,type = 1}
    addBtn.onClick:Add(self.onClickAdd,self)
    --开始匹配
    local startBtn = self.aloneSoloPanel:GetChild("n12")
    startBtn.data = {open = data.open,type = 1,lastCount = lastcountNum}
    startBtn.onClick:Add(self.onClickStart,self)
    if data.open == 1 then
        startBtn.grayed = false
        startBtn.touchable = true
        startBtn:GetChild("red").visible = true
    else
        startBtn.grayed = true
        startBtn.touchable = false
        startBtn:GetChild("red").visible = false
    end
end

--领取单人目标奖励后刷新
function PanelRanking:refreshAward(data)
    self.aloneData.targetAwardSigns = data.targetAwardSigns
    self:setSoloData(self.aloneData)
end

--购买挑战次数后刷新
function PanelRanking:refreshLastCount(count)
    self.aloneData.buyCount = count
    self:setSoloData(self.aloneData)
end

function PanelRanking:onClickAdd(context)
    local data = context.sender.data
    if (self.aloneData and self.aloneData.open ~= 1 and data.type == 1) or (self.teamData and self.teamData.open ~= 1 and data.type == 2) then
        GComAlter(language.qualifier17)
        return
    end
    local isSoloBuy = cache.PwsCache:getIsSoloBuy()
    local isTeamBuy = cache.PwsCache:getIsTeamBuy()
    if (self.aloneData and self.aloneData.open == 1 and isSoloBuy) 
        or (self.teamData and self.teamData.open == 1 and isTeamBuy) then
        local maxBuyCount = conf.QualifierConf:getValue("one_buy_max")
        local cost = conf.QualifierConf:getValue("one_buy_cfg")[2]
        if isTeamBuy then
            cost = conf.QualifierConf:getValue("zd_buy_cfg")[2]
            maxBuyCount = conf.QualifierConf:getValue("zd_buy_max")
        end
        local lastBuyCount = maxBuyCount - data.buyCount
        local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        local moneyBy = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
        if moneyYb + moneyBy >= cost then
            if lastBuyCount > 0 then
                if data.type == 1 then
                    proxy.QualifierProxy:sendMsg(1480105,{count = 1})
                elseif data.type == 2 then
                    proxy.QualifierProxy:sendMsg(1480209,{count = 1})
                end
            else
                GComAlter(language.kuafu77)
            end
        else
            GComAlter(language.gonggong18)
        end
        return
    end
    mgr.ViewMgr:openView2(ViewName.LastCountBuyView, data)
end

function PanelRanking:onClickGetAimAwards(context)
    local data = context.sender.data
        print("领取00000",data.flag)
    if data.flag == 1 then
        print("领取")
        if data.type == 1 then
            proxy.QualifierProxy:sendMsg(1480104,{cfgId = data.cId})
        elseif data.type == 2 then
            proxy.QualifierProxy:sendMsg(1480207,{cfgId = data.cId})
        end
    elseif data.flag == 0 then 
        mgr.ViewMgr:openView2(ViewName.AwardsTipsView, {awards = data.awards})
        -- GComAlter(language.qualifier11)
    elseif data.flag == 2 then
        GComAlter(language.qualifier12)
    end
end

function PanelRanking:onClickStart(context)
    local data = context.sender.data
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    if data.open == 1 then
        print("已开启")
        if data.lastCount and data.lastCount > 0 then
            local netTime = mgr.NetMgr:getServerTime()
            local day = GGetWeekDayByTimestamp(netTime)
            local startDelay = conf.QualifierConf:getValue("start_diff")
            local overDelay = conf.QualifierConf:getValue("act_sec")
            local TimeTab = os.date("*t",netTime)
            local openTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0) + startDelay
            local overTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0) + startDelay + overDelay
            if data.type == 1 then
                -- if netTime >= openTime and netTime <= overTime then
                    proxy.QualifierProxy:sendMsg(1480106,{reqType = 1})
                -- else
                    -- GComAlter(language.qualifier51)
                -- end
            elseif data.type == 2 then
                local roleId = cache.PlayerCache:getRoleId()
                local teamList = cache.PwsCache:getTeamList()
                local teamInfo = cache.PwsCache:getTeamInfo()
                if teamInfo.captainRoleId == roleId then
                    if day == 6 then
                        if netTime >= openTime and netTime <= overTime then
                            proxy.QualifierProxy:sendMsg(1480205,{reqType = 5})                            
                        else
                            GComAlter(language.qualifier28)
                        end
                    else
                        GComAlter(language.qualifier28)                        
                    end
                else
                    GComAlter(language.qualifier20)
                end
            end
        else
            if not data.lastCount then
                if data.type == 3 then--季后赛
                    if data.canJoin == 1 then
                        print("进入季后赛场景")
                        proxy.ThingProxy:send(1020101,{sceneId = 246001,type = 3})
                    else
                        GComAlter(language.qualifier32)
                    end
                end
            else
                GComAlter(language.qualifier16)
            end
        end
    else
        GComAlter(language.qualifier13)
    end
end

--单人
function PanelRanking:onClickRankInfo(context)
    local index = context.sender.data
    mgr.ViewMgr:openView2(ViewName.RankAwardsView,{index = index})
end

--组队
function PanelRanking:onClickTeamRankInfo(context)
    local index = context.sender.data
    mgr.ViewMgr:openView2(ViewName.TeamRankAwardsView,{index = index})
end

function PanelRanking:onClickGuize(context)
    local data = context.sender.data
    if data.type == 1 then
        GOpenRuleView(1074)
    elseif data.type == 2 then
        GOpenRuleView(1075)
    elseif data.type == 3 then
        GOpenRuleView(1083)
    end
end

-- 变量名：canJoin 说明：1:有资格 0:没有资格
-- 变量名：teamId  说明：队伍id,大于0表示有队伍
-- array<PwsTeamMemInfo>
-- 变量名：members 说明：成员
-- PwsTeamInfo
-- 变量名：teamInfo    说明：队伍信息
-- 变量名：open    说明：1:已开启 0:未开启
-- 变量名：matchStatu  说明：1:正在匹配中 0:未匹配
-- 变量名：playCount   说明：已挑战次数
-- 变量名：winRate 说明：胜率
-- 变量名：joinCount   说明：已挑战次数
-- 变量名：buyCount    说明：已购买次数
-- map<int32,int32>
-- 变量名：targetAwardSigns    说明：目标奖励已领取的
--组队排位
function PanelRanking:setTeamData(data)
    printt("组度排位赛",data)
    self.teamData = data
    local timeDec = self.teamPanel:GetChild("n17")
    timeDec.text = language.qualifier44
    local guizeBtn = self.teamPanel:GetChild("n15")
    guizeBtn.data = {type = 2}
    guizeBtn.onClick:Add(self.onClickGuize,self)
    local creatTeamBtn = self.teamPanel:GetChild("n31")
    creatTeamBtn.onClick:Add(self.onClickCreate,self)
    local selectIconBtn = self.teamPanel:GetChild("n35")
    selectIconBtn.onClick:Add(self.onClickSelect,self)
    local windRateTxt = self.teamPanel:GetChild("n5")
    local joinCountTxt = self.teamPanel:GetChild("n6")
    windRateTxt.text = data.winRate .. "%"
    joinCountTxt.text = data.joinCount

    local rankAwardsBtn = self.teamPanel:GetChild("n12")
    rankAwardsBtn.data = 0
    rankAwardsBtn.onClick:Add(self.onClickTeamRankInfo,self)
    local guessBtn = self.teamPanel:GetChild("n20")
    guessBtn.data = 2
    guessBtn.onClick:Add(self.onClickTeamRankInfo,self)
    -- local promote = conf.QualifierConf:getValue("one_promote_zd_count")--取消排位赛前90才可以参加组队赛的限制
    self.teamPanel:GetChild("n45").text = language.qualifier27_1--string.format(language.qualifier27_1,promote)

    --组队目标奖励
    local bar = self.teamPanel:GetChild("n22")
    local maxCount = conf.QualifierConf:getValue("zd_free_max")
    bar.max = maxCount
    bar.value = data.playCount
    local boxBtnList = {}
    local boxEffect = {}
    for i=24,26 do
        table.insert(boxBtnList,self.teamPanel:GetChild("n"..i))
        table.insert(boxEffect,self.teamPanel:GetChild("n"..i+17))
    end
    print("目标奖励",data.playCount)
    --目标奖励
    local awardsData = conf.QualifierConf:getPwsTeamAwardsData()
    for k,v in pairs(boxBtnList) do
        print(k,v,awardsData[k].con)
        local flag = 0
        if awardsData[k].con <= data.playCount then
            flag = 1
            if data.targetAwardSigns[awardsData[k].id] then
                flag = 2
            end
        end
        if flag == 0 then--无法领取
            boxEffect[k].visible = false
            v:GetChild("icon").url = UIPackage.GetItemURL("paiwei",UIItemRes.boxClose[k])
        elseif flag == 1 then--可领取
            boxEffect[k].visible = true
            v:GetChild("icon").url = UIPackage.GetItemURL("paiwei",UIItemRes.boxClose[k])
        elseif flag == 2 then--已领取
            boxEffect[k].visible = false            
            v:GetChild("icon").url = UIPackage.GetItemURL("paiwei",UIItemRes.boxOpen[k])
        end
        v.data = {flag = flag,cId = awardsData[k].id,awards = awardsData[k].item,type = 2}
        v.onClick:Add(self.onClickGetAimAwards,self)
    end
    
    --剩余挑战次数
    local lastCount = self.teamPanel:GetChild("n8")
    local lastcountNum = maxCount + data.buyCount - data.playCount
    lastCount.text = lastcountNum
    local addBtn = self.teamPanel:GetChild("n2")
    addBtn.data = {buyCount = data.buyCount,type = 2}
    addBtn.onClick:Add(self.onClickAdd,self)
    --开始匹配
    local startBtn = self.teamPanel:GetChild("n14")
    startBtn.data = {open = data.open,type = 2,lastCount = lastcountNum}
    startBtn.onClick:Add(self.onClickStart,self)
    if data.open == 1 then
        local netTime = mgr.NetMgr:getServerTime()
        local day = GGetWeekDayByTimestamp(netTime)
        if day == 6 then
            local TimeTab = os.date("*t",netTime)
            local openTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,19,40)
            local overTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,20,10)
            if netTime >= openTime and netTime <= overTime and data.canJoin == 1 then
                startBtn.grayed = false
                startBtn.touchable = true
                startBtn:GetChild("red").visible = true
            else
                startBtn.grayed = true
                startBtn.touchable = false
                startBtn:GetChild("red").visible = false
            end
        else
            startBtn.grayed = true
            startBtn.touchable = false
            startBtn:GetChild("red").visible = false
        end
    else
        startBtn.grayed = true
        startBtn.touchable = false
        startBtn:GetChild("red").visible = false
    end
    --队伍成员展示
    self:showMembers(data)
    
end

--队伍成员排序
function PanelRanking:membersSort(teamMembers)
    local members = {}
    local teamInfo = cache.PwsCache:getTeamInfo()
    for k,v in pairs(teamMembers) do
        if teamInfo.captainRoleId == v.roleId then
            table.insert(members,v)
            break
        end
    end
    for k,v in pairs(teamMembers) do
        if teamInfo.captainRoleId ~= v.roleId then
            table.insert(members,v)
        end
    end
    return members
end

--队伍成员展示
function PanelRanking:showMembers(data)
    --段位信息
    local pwData = conf.QualifierConf:getPwsTeamDataByLv(data.teamInfo.pwLev)
    local gradingIcon = self.teamPanel:GetChild("n18")
    local lvIcon = self.teamPanel:GetChild("n19")
    gradingIcon.url = UIPackage.GetItemURL("paiwei",pwData.img)
    lvIcon.visible = false--lvIcon.url = UIPackage.GetItemURL("paiwei",pwData.lv_img)
    
    local starPanel = self.teamPanel:GetChild("n13")
    local starsNum = self.teamPanel:GetChild("n44")
    print("当前段位",pwData.stars,pwData.max_stars)
    if pwData.max_stars then
        for i=1,5 do
            if i <= pwData.max_stars then
                starPanel:GetChild("n"..i-1).visible = true
            else
                starPanel:GetChild("n"..i-1).visible = false
            end
            if i <= pwData.stars then
                starPanel:GetChild("n"..i+9).visible = true
            else
                starPanel:GetChild("n"..i+9).visible = false
            end
        end
        starsNum.visible = false
    else
        starsNum.visible = true
        starsNum.text = "*" .. pwData.stars
        for i=1,5 do
            if i == 1 then
                starPanel:GetChild("n"..i-1).visible = true
                starPanel:GetChild("n"..i+9).visible = true
            else
                starPanel:GetChild("n"..i-1).visible = false
                starPanel:GetChild("n"..i+9).visible = false
            end
        end
    end
    local rolePanelList = {}
    for i=37,39 do
        table.insert(rolePanelList,self.teamPanel:GetChild("n"..i))
    end

    --没有资格的不显示段位
    if self.teamData.canJoin == 1 then
        self.teamPanel:GetChild("n45").visible = false
    else
        self.teamPanel:GetChild("n45").visible = true
        self.teamPanel:GetChild("n18").visible = false
        self.teamPanel:GetChild("n19").visible = false
        self.teamPanel:GetChild("n13").visible = false
        self.teamPanel:GetChild("n44").visible = false
    end
    -- teamInfo
    -- captainRoleId   说明：队长角色id
    -- captainName 说明：队长名字
    -- teamName    说明：队伍名字
    -- icon    说明：图标
    -- pwLev   说明：排位等级
    -- teamId  说明：队伍id
    local teamIcon = self.teamPanel:GetChild("n10")
    
    if data.teamInfo.teamId > 0 then--有队伍
        -- members
        -- roleId  说明：角色id
        -- roleName    说明：角色名字
        -- level   说明：等级
        -- power   说明：战力
        -- roleIcon    说明：头像
        -- skinMap 说明：外观
        if data.teamInfo.icon > 0 then
            local imgData = conf.QualifierConf:getTeamIconById(data.teamInfo.icon)
            teamIcon.url = UIPackage.GetItemURL("paiwei",imgData.icon)
        end
        self.teamPanel:GetChild("n31").visible = false
        self.teamPanel:GetChild("n40").visible = true
        self.teamPanel:GetChild("n40").text = data.teamInfo.teamName
        local members = self:membersSort(data.members)
        for i=1,#rolePanelList do
            local heroModel = rolePanelList[i]
            if members[i] then
                local skinMap = members[i].skinMap
                local sex = members[i].sex
                local modelObj = self.parent:addModel(skinMap[1],heroModel)
                modelObj:setSkins(nil,skinMap[2],skinMap[3])
                modelObj:setPosition(50,-500,800)
                modelObj:setRotation(RoleSexModel[sex].angle)
                modelObj:setScale(150)
                self.teamPanel:GetChild("n"..31+i).visible = false
            else
                local modelObj = self.parent:addModel(GuDingmodel[1],heroModel)
                modelObj:setPosition(50,-500,800)
                modelObj:setRotation(RoleSexModel[1].angle)
                modelObj:setScale(150)
                self.teamPanel:GetChild("n"..31+i).visible = true
            end
            self.teamPanel:GetChild("n"..45+i).onClick:Add(self.onClickOpenList,self)
            self.teamPanel:GetChild("n"..31+i).onClick:Add(self.onClickOpenList,self)
        end
    else--没有队伍
        local imgData = conf.QualifierConf:getTeamIconById(1)
        teamIcon.url = UIPackage.GetItemURL("paiwei",imgData.icon)
        self.teamPanel:GetChild("n31").visible = true
        self.teamPanel:GetChild("n40").visible = false
        for i=1,#rolePanelList do
            local heroModel = rolePanelList[i]
            local modelObj = self.parent:addModel(GuDingmodel[1],heroModel)
            modelObj:setPosition(50,-500,800)
            modelObj:setRotation(RoleSexModel[1].angle)
            modelObj:setScale(150)
            self.teamPanel:GetChild("n"..31+i).visible = true
            self.teamPanel:GetChild("n"..45+i).onClick:Add(self.onClickOpenList,self)
            self.teamPanel:GetChild("n"..31+i).onClick:Add(self.onClickOpenList,self)
        end
    end
end

--领取组队目标奖励后刷新
function PanelRanking:refreshTeamAward(data)
    self.teamData.targetAwardSigns = data.targetAwardSigns
    self:setTeamData(self.teamData)
end

--购买组队挑战次数后刷新
function PanelRanking:refreshTeamLastCount(count)
    self.teamData.buyCount = count
    self:setTeamData(self.teamData)
end

--打开战队列表
function PanelRanking:onClickOpenList()
    local teamInfo = cache.PwsCache:getTeamInfo()
    local teamList = cache.PwsCache:getTeamList()
    local canJoin = self.teamData.canJoin
    if teamInfo.teamId ~= 0 then
        mgr.ViewMgr:openView2(ViewName.TeamInformation,{})
    else
        local netTime = mgr.NetMgr:getServerTime()
        local day = GGetWeekDayByTimestamp(netTime)
        local overDay = conf.QualifierConf:getValue("one_week_day")
        local teamStartDay = conf.QualifierConf:getValue("zd_week_day")
        local payoffDay = conf.QualifierConf:getValue("jhs_week_day")
        local delayTime = conf.QualifierConf:getValue("act_sec") + conf.QualifierConf:getValue("start_diff")
        if day == 0 then day = 7 end
        if overDay[3] and day == overDay[3] then
            local TimeTab = os.date("*t",netTime)
            local openTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0) + delayTime
            if netTime >= openTime then
                if canJoin == 1 then
                    mgr.ViewMgr:openView(ViewName.PwsTeamListView,function()
                        proxy.QualifierProxy:sendMsg(1480202,{page = 1,reqType = 0})
                    end)
                else
                    GComAlter(language.qualifier27_2)
                --     local promote = conf.QualifierConf:getValue("one_promote_zd_count")
                --     GComAlter(string.format(language.qualifier27,promote))
                end
            else
                GComAlter(language.qualifier28)
            end
        elseif day == teamStartDay[1] then
            local TimeTab = os.date("*t",netTime)
            local overTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0) + delayTime
            if netTime < overTime then
                if canJoin == 1 then
                    mgr.ViewMgr:openView(ViewName.PwsTeamListView,function()
                        proxy.QualifierProxy:sendMsg(1480202,{page = 1,reqType = 0})
                    end)
                else
                    GComAlter(language.qualifier27_2)
                --     local promote = conf.QualifierConf:getValue("one_promote_zd_count")
                --     GComAlter(string.format(language.qualifier27,promote))
                end
            else
                GComAlter(language.qualifier42)
            end
        elseif day == payoffDay[1] then
            GComAlter(language.qualifier58)
        else
            GComAlter(language.qualifier28)
        end
    end
end

--创建战队
function PanelRanking:onClickCreate()
    local canJoin = self.teamData.canJoin

    local netTime = mgr.NetMgr:getServerTime()
    local day = GGetWeekDayByTimestamp(netTime)
    local overDay = conf.QualifierConf:getValue("one_week_day")
    local teamStartDay = conf.QualifierConf:getValue("zd_week_day")
    local payoffDay = conf.QualifierConf:getValue("jhs_week_day")
    local delayTime = conf.QualifierConf:getValue("act_sec") + conf.QualifierConf:getValue("start_diff")
    if day == 0 then day = 7 end
    if overDay[3] and day == overDay[3] then
        local TimeTab = os.date("*t",netTime)
        local openTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0) + delayTime
        if netTime >= openTime then
            if canJoin == 1 then
                mgr.ViewMgr:openView2(ViewName.SetUpTeam,{})
            else
                GComAlter(language.qualifier27_2)
            --     local promote = conf.QualifierConf:getValue("one_promote_zd_count")
            --     GComAlter(string.format(language.qualifier27,promote))                
            end
        else
            GComAlter(language.qualifier28)
        end
    elseif day == teamStartDay[1] then
        local TimeTab = os.date("*t",netTime)
        local overTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0) + delayTime
        if netTime < overTime then
            if canJoin == 1 then
                mgr.ViewMgr:openView2(ViewName.SetUpTeam,{})
            else
                GComAlter(language.qualifier27_2)
            --     local promote = conf.QualifierConf:getValue("one_promote_zd_count")
            --     GComAlter(string.format(language.qualifier27,promote))
            end
        else
            GComAlter(language.qualifier42)
        end
    elseif day == payoffDay[1] then
        GComAlter(language.qualifier58)
    else
        GComAlter(language.qualifier28)
    end
end
--修改战队头像弹框
function PanelRanking:onClickSelect()
    -- mgr.ViewMgr:openView2(ViewName.TeamIconSelect,{type = 1})
end

-- 季后赛信息
-- 变量名：vsInfos 说明：对决信息
-- 变量名：open    说明：0:未开启 1:已开启
-- 变量名：canJoin 说明：1:有资格 0:没有资格
function PanelRanking:setPayoffData(data)
    self.payoffData = data
    printt("季后赛信息",data)
    local timeDec1 = self.payoffPanel:GetChild("n15")
    local timeDec2 = self.payoffPanel:GetChild("n17")
    local timeDec3 = self.payoffPanel:GetChild("n19")
    local timeDec4 = self.payoffPanel:GetChild("n21")
    timeDec1.text = language.qualifier45
    timeDec2.text = language.qualifier46
    timeDec3.text = language.qualifier47
    timeDec4.text = language.qualifier48
    self.bgImg = self.payoffPanel:GetChild("n0")
    self.bgImg.url = UIItemRes.bangpai04
    local guizeBtn = self.payoffPanel:GetChild("n25")
    guizeBtn.data = {type = 3}
    guizeBtn.onClick:Add(self.onClickGuize,self)
    -- 变量名：round   说明：回合
    -- 变量名：aName   说明：a玩家
    -- 变量名：bName   说明：b玩家
    -- 变量名：aTeamId 说明：a队伍id
    -- 变量名：bTeamId 说明：b队伍id
    -- 变量名：winTeamId   说明：赢得队伍id
    self.firstData = {}
    self.secondData = {}
    for k,v in pairs(data.vsInfos) do
        if v.round == 1 then
            table.insert(self.firstData,v)
        else
            table.insert(self.secondData,v)
        end
    end
    local firstList = self.payoffPanel:GetChild("n12")
    firstList.numItems = 0
    firstList.itemRenderer = function(index,obj)
        self:PayoffCell1(index, obj)
    end
    firstList:SetVirtual()
    firstList.numItems = 2--#self.firstData
    local secondList = self.payoffPanel:GetChild("n13")
    secondList.numItems = 0
    secondList.itemRenderer = function(index,obj)
        self:PayoffCell2(index, obj)
    end
    secondList:SetVirtual()
    secondList.numItems = 2--#self.secondData

    local startBtn = self.payoffPanel:GetChild("n24")
    startBtn.data = {open = data.open,type = 3,canJoin = data.canJoin}
    startBtn.onClick:Add(self.onClickStart,self)
    if data.open == 1 then
        startBtn.grayed = false
        startBtn.touchable = true
        startBtn:GetChild("red").visible = true
    else
        startBtn.grayed = true
        startBtn.touchable = false
        startBtn:GetChild("red").visible = false
    end
    --竞技奖励按钮和竞猜按钮
    local awardsBtn = self.payoffPanel:GetChild("n22")
    awardsBtn.data = {index = 0}
    awardsBtn.onClick:Add(self.onClickPayoffAwards,self)
    local guessBtn = self.payoffPanel:GetChild("n23")
    guessBtn.data = {index = 1}
    guessBtn.onClick:Add(self.onClickPayoffAwards,self)

    self:payoffPanelState()
end

function PanelRanking:onClickPayoffAwards(context)
    local data = context.sender.data
    mgr.ViewMgr:openView2(ViewName.PayoffRankAwardsView, data)
end

function PanelRanking:PayoffCell1( index,obj )
    local data = self.firstData[index+1]
    local nameTxt1 = obj:GetChild("n0")
    local nameTxt2 = obj:GetChild("n4")
    local isWinImg1 = obj:GetChild("n5")
    local isWinImg2 = obj:GetChild("n7")
    obj:GetChild("n8").visible = false
    obj:GetChild("n9").visible = false
    if data then
        local aCaptainRoleId = data.aCaptainRoleId
        local bCaptainRoleId = data.bCaptainRoleId
        local auId = string.sub(aCaptainRoleId,1,3)
        local buId = string.sub(bCaptainRoleId,1,3)
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(auId) and tonumber(auId) ~= 0 then
           obj:GetChild("n8").visible = true
        end
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(buId) and tonumber(buId) ~= 0 then
           obj:GetChild("n9").visible = true
        end
        nameTxt1.text = data.aName
        nameTxt2.text = data.bName
        if data.aTeamId == 0 then
            nameTxt1.text = "— —"            
        end
        if data.bTeamId == 0 then
            nameTxt2.text = "— —"
        end
        if data.winTeamId > 0 then
            if data.winTeamId == data.aTeamId then
                isWinImg1.visible = true
                isWinImg2.visible = false
            else
                isWinImg1.visible = false
                isWinImg2.visible = true                
            end
        else
            isWinImg1.visible = false
            isWinImg2.visible = false
        end
    else
        nameTxt1.text = "— —"
        nameTxt2.text = "— —"
        isWinImg1.visible = false
        isWinImg2.visible = false
    end
end

function PanelRanking:PayoffCell2( index,obj )
    local data = self.secondData[index+1]
    local nameTxt1 = obj:GetChild("n0")
    local nameTxt2 = obj:GetChild("n4")
    local isWinImg1 = obj:GetChild("n5")
    local isWinImg2 = obj:GetChild("n7")

    if data then
        local aCaptainRoleId = data.aCaptainRoleId
        local bCaptainRoleId = data.bCaptainRoleId
        local auId = string.sub(aCaptainRoleId,1,3)
        local buId = string.sub(bCaptainRoleId,1,3)
        obj:GetChild("n8").visible = false
        obj:GetChild("n9").visible = false
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(auId) and tonumber(auId) ~= 0 then
           obj:GetChild("n8").visible = true
        end
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(buId) and tonumber(buId) ~= 0 then
           obj:GetChild("n9").visible = true
        end
        nameTxt1.text = data.aName
        nameTxt2.text = data.bName
        if data.aTeamId == 0 then
            nameTxt1.text = "— —"           
        end
        if data.bTeamId == 0 then
            nameTxt2.text = "— —"
        end
        if data.winTeamId > 0 then
            if data.winTeamId == data.aTeamId then
                isWinImg1.visible = true
                isWinImg2.visible = false
            else
                isWinImg1.visible = false
                isWinImg2.visible = true
            end
        else
            isWinImg1.visible = false
            isWinImg2.visible = false
        end
    else
        nameTxt1.text = "— —"
        nameTxt2.text = "— —"
        isWinImg1.visible = false
        isWinImg2.visible = false
    end
end

--季后赛面板变化
function PanelRanking:payoffPanelState()
    local netTime = mgr.NetMgr:getServerTime()
    local day = GGetWeekDayByTimestamp(netTime)
    local TimeTab = os.date("*t",netTime)
    -- print("计时器",day)
    if day == 0 then day = 7 end
    --季后赛
    local firstRoundStartTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,19,40)
    local firstRoundOvertTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,19,55)
    local secondRoundStartTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,19,55)
    local secondRoundOvertTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,20,10)
    local payoffDay = conf.QualifierConf:getValue("jhs_week_day")
    local titleText = self.payoffPanel:GetChild("n2")
    local firstRoundTime = self.payoffPanel:GetChild("n17")
    local secondRoundTime = self.payoffPanel:GetChild("n19")
    if day == payoffDay[1] then
        if netTime < firstRoundStartTime then--季后赛未进行
            -- print("季后赛未进行")
            titleText.text = language.qualifier54
            firstRoundTime.text = mgr.TextMgr:getTextColorStr(firstRoundTime.text, 5)
            secondRoundTime.text = mgr.TextMgr:getTextColorStr(secondRoundTime.text, 5)
        elseif netTime >= firstRoundStartTime and netTime < firstRoundOvertTime then--季后赛第一轮
            -- print("季后赛第一轮")
            titleText.text = language.qualifier55
            firstRoundTime.text = mgr.TextMgr:getTextColorStr(firstRoundTime.text, 10)
            secondRoundTime.text = mgr.TextMgr:getTextColorStr(secondRoundTime.text, 5)
        elseif netTime >= secondRoundStartTime and netTime <= secondRoundOvertTime then--季后赛第二轮
            -- print("季后赛第二轮")
            titleText.text = language.qualifier56
            firstRoundTime.text = mgr.TextMgr:getTextColorStr(firstRoundTime.text, 5)
            secondRoundTime.text = mgr.TextMgr:getTextColorStr(secondRoundTime.text, 10)
        else--季后赛结束
            -- print("季后赛结束")
            titleText.text = language.qualifier57
            firstRoundTime.text = mgr.TextMgr:getTextColorStr(firstRoundTime.text, 5)
            secondRoundTime.text = mgr.TextMgr:getTextColorStr(secondRoundTime.text, 5)
        end
    else--季后赛未进行
        -- print("季后赛未进行22")
        titleText.text = language.qualifier54
        firstRoundTime.text = mgr.TextMgr:getTextColorStr(firstRoundTime.text, 5)
        secondRoundTime.text = mgr.TextMgr:getTextColorStr(secondRoundTime.text, 5)
    end
end

function PanelRanking:onTimer()
    self:payoffPanelState()
end

function PanelRanking:clear()
    -- self.bgImg.url = ""
end

return PanelRanking
