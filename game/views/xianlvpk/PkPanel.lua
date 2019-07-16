--
-- Author: 
-- Date: 2018-07-23 15:10:44
--

local PkPanel = class("PkPanel",import("game.base.Ref"))

function PkPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function PkPanel:initPanel()
    self.view = self.mParent.view:GetChild("n4")
    self.c1 = self.view:GetController("c1")
    --提示描述
    self.decArr = {}
    for i=2,7 do
        local dec = self.view:GetChild("n"..i)
        table.insert(self.decArr,dec)
    end
    --队伍信息
    self.teamInfoArr = {}
    for i=8,13 do
        local info = self.view:GetChild("n"..i)
        table.insert(self.teamInfoArr,info)
    end
    
    --比赛类型
    self.matchTypeIcon = self.view:GetChild("n15")
    self.date1 = self.view:GetChild("n16")
    self.date2 = self.view:GetChild("n17")
    --奖励按钮
    local awardBtn = self.view:GetChild("n19")
    awardBtn.onClick:Add(self.onClickAward,self)
    --排行榜
    local rankBtn = self.view:GetChild("n20")
    rankBtn.onClick:Add(self.onClickRank,self)
    --海选Panel
    self.haiXuanPanel = self.view:GetChild("n108")
    --竞猜panel
    self.guessPanel = self.view:GetChild("n109")
    --鼓舞
    self.guWuBtn = self.view:GetChild("n112")
    self.guWuBtn.onClick:Add(self.onClickGuWu,self)
    self:initHaiXuanPanel()
    self:initGuessPanel()
    -- self:setHaiXuanPanel()


end

--初始海选Panel
function PkPanel:initHaiXuanPanel()
    self.haixuanC1 =self.haiXuanPanel:GetController("c1")
    self.goBtn = self.haiXuanPanel:GetChild("n31")
    self.goBtnIcon = self.haiXuanPanel:GetChild("n32")
    self.goBtn.onClick:Add(self.onClickGoBtn,self)
    --队伍战力
    self.teamPowerNum = self.haiXuanPanel:GetChild("n27")
    self.teamPowerTitle = self.haiXuanPanel:GetChild("n43")
    --自己的形象信息
    self.selfModelCom = self.haiXuanPanel:GetChild("n21")
    self.selfRoleName = self.selfModelCom:GetChild("n25")
    self.selfPower = self.selfModelCom:GetChild("n26")
    --伴侣形象信息
    self.coupleModelCom = self.haiXuanPanel:GetChild("n25")
    self.coupeName = self.coupleModelCom:GetChild("n25")
    self.couplePower = self.coupleModelCom:GetChild("n26")

    self.boxArr = {}
    for i=39,42 do
        local info = self.haiXuanPanel:GetChild("n"..i)
        -- info.onClick:Add(self.getStageAward,self)
        table.insert(self.boxArr,info)
    end
    self.progressBar = self.haiXuanPanel:GetChild("n34")
    self.barController = self.progressBar:GetController("c1")

end

function PkPanel:initGuessPanel()
    local dec = self.guessPanel:GetChild("n64")
    dec.text = language.xianlv11
    self.guessC1 = self.guessPanel:GetController("c1")
    -- self:onGuessChange()
    self.guessC1.onChanged:Add(self.onGuessChange,self)

    
    self.first = self.guessPanel:GetChild("first")--冠军
    self.third = self.guessPanel:GetChild("third")--季军


    
    self.vsInfoList = {}
    local t = {}--1组
    t.team1 = self.guessPanel:GetChild("n43")
    t.team2 = self.guessPanel:GetChild("n44")
    t.yaBtn = self.guessPanel:GetChild("n56")
    t.group = 1
    table.insert(self.vsInfoList,t)
    local t = {}--2组
    t.team1 = self.guessPanel:GetChild("n45")
    t.team2 = self.guessPanel:GetChild("n46")
    t.yaBtn = self.guessPanel:GetChild("n57")
    t.group = 2
    table.insert(self.vsInfoList,t)
    local t = {}--3组
    t.team1 = self.guessPanel:GetChild("n49")
    t.team2 = self.guessPanel:GetChild("n50")
    t.yaBtn = self.guessPanel:GetChild("n59")
    t.group = 3
    table.insert(self.vsInfoList,t)
    local t = {}--4组
    t.team1 = self.guessPanel:GetChild("n47")
    t.team2 = self.guessPanel:GetChild("n48")
    t.yaBtn = self.guessPanel:GetChild("n58")
    t.group = 4
    table.insert(self.vsInfoList,t)

end

--stage:1:报名阶段、2:海选赛、3:争霸赛第一场预告4：争霸赛第一场进行中、5：争霸赛第二场预告、6：争霸赛第二场进行中、7：全部结束
function PkPanel:addMsgCallBack(data)
    if data then
        printt("仙侣pk信息",data)
        self.data = data
        --设置面板显示
        if data.stage == 1 or data.stage == 2 then
            self.c1.selectedIndex = 0--海选
            self.guWuBtn.data = 1--鼓舞类型
        elseif data.stage == 7 then
            self.c1.selectedIndex = 2--比赛结束
        elseif data.stage ~= 0 then--等于0是后端没有数据返回默认是0
            self.guWuBtn.data = 2
            self.c1.selectedIndex = 1--竞猜
        end
        --设置鼓舞按钮可见性
        if data.stage == 7 or data.stage == 1 then
            self.guWuBtn.visible = false
        elseif data.stage == 2 then
            self.guWuBtn.visible = true
        else
            if self.data.hxRank <= 0 then--已淘汰
                self.guWuBtn.visible = false
            else
                self.guWuBtn.visible = true
            end
        end
        --天地榜对决信息切换
        self:onGuessChange()
        self:setHaiXuanPanel()
        self:setLeftPanel()
        -- self:setGuessPanel()

    end
end
--stage:1:报名阶段、2:海选赛、3:争霸赛第一场预告4：争霸赛第一场进行中、5：争霸赛第二场预告、6：争霸赛第二场进行中、7：全部结束

function PkPanel:onClickGuWu(context)
    if not self.data then return end
    if self.data.join and self.data.join == 0 then
        GComAlter(language.xianlv27)
        return
    end
    --type 1:海选鼓舞，2：争霸鼓舞
    local type = context.sender.data
    local max = conf.XianLvConf:getValue("inspire_max")
    print("已鼓舞次数",self.data.inspireCount,"最大",max)
    if self.data.inspireCount < max then
        local guWuCost
        if self.data.stage == 1 or self.data.stage == 2 then
            guWuCost = conf.XianLvConf:getValue("inspire_cost")
        else
            guWuCost = conf.XianLvConf:getValue("inspire_cost02")
        end
        local t = clone(language.xianlv17)
        t[1].text = string.format(t[1].text,tonumber(guWuCost[2]))
        -- t[2].text = string.format(t[2].text,10)--属性加成TODO
        local str = mgr.TextMgr:getTextByTable(t)
        local param = {
            type = 14,
            richtext = str,
            sure = function ()
                local msgId
                if self.data.msgId == 5540101 then
                    msgId = 1540106
                elseif self.data.msgId == 5540201 then
                    msgId = 1540206
                end
                proxy.XianLvProxy:sendMsg(msgId)
            end
        }
        GComAlter(param)
    else
        GComAlter(language.xianlv18)
    end
end

function PkPanel:setHaiXuanPanel()
    local dec1 = self.haiXuanPanel:GetChild("n29")
    local joinCost = conf.XianLvConf:getValue("sign_up_cost")
    dec1.text = string.format(language.xianlv05,joinCost[2])
    local dec2 = self.haiXuanPanel:GetChild("n30")
    dec2.text = language.xianlv06

    local sex = cache.PlayerCache:getSex()
    local spouse = sex == 1 and 2 or 1--伴侣的性别
    --设置自己的模型显示
    self:setModel(true,self.selfModelCom,sex)
    self.selfRoleName.text = cache.PlayerCache:getRoleName()
    self.selfPower.text = language.xianlv15..cache.PlayerCache:getRolePower()
    --成员信息
    if cache.PlayerCache:getCoupleName() == "" then
        self.haixuanC1.selectedIndex = 0

        self:setModel(false,self.coupleModelCom,spouse)
        self.coupeName.text = language.xianlv08--暂无
        self.couplePower.text = language.xianlv08
        self.teamPowerTitle.visible = true
        self.teamPowerNum.visible = false
        self.teamPowerTitle.text = language.xianlv08

        self.goBtn.data = 1
        self.goBtnIcon.url = UIItemRes.xianlv01[4]--前往结婚

    else
        local teamPower = 0
        for k,v in pairs(self.data.memberInfo) do
            teamPower = teamPower + v.power
            if v.roleId ~= cache.PlayerCache:getRoleId() then
                self:setModel(true,self.coupleModelCom,spouse,v.skinMap)
                self.coupeName.text = v.roleName
                self.couplePower.text = language.xianlv15..v.power
            end
        end
        self.teamPowerTitle.visible = false
        self.teamPowerNum.visible = true
        self.teamPowerNum.text = teamPower
        --是否报名0:未报名，1:已报名
        if self.data.stage == 1 then --报名阶段
            self.haixuanC1.selectedIndex = 0
            if self.data.join and self.data.join == 0 then
                self.goBtn.data = 2--未报名
                self.goBtnIcon.url = UIItemRes.xianlv01[5]--报名参赛
            elseif self.data.join and self.data.join == 1 then
                self.goBtn.data = 3--已报名
                self.goBtnIcon.url = UIItemRes.xianlv01[6]--参与匹配
            end
        elseif self.data.stage == 2 then--海选阶段
            if self.data.join == 0 then
                self.haixuanC1.selectedIndex = 0
                -- if cache.PlayerCache:getCoupleName() == "" then
                --     self.goBtn.data = 1
                --     self.goBtnIcon.url = UIItemRes.xianlv01[4]--前往结婚
                -- else
                    self.goBtn.data = 2--未报名
                    self.goBtnIcon.url = UIItemRes.xianlv01[5]--报名参赛
                -- end
            else
                self.haixuanC1.selectedIndex = 1
                self.goBtn.data = 4
                self.goBtnIcon.url = UIItemRes.xianlv01[6]--参与匹配
            end
        end
    end
    self:setHaiXunaPlan()
end

--设置模型
--isReale是否是真人
function PkPanel:setModel(isReale,modelCom,sex,skins)
    local panel = modelCom:GetChild("n27")
    local addIcon = modelCom:GetChild("n24")
    addIcon.onClick:Add(self.goMarry,self)
    if isReale then
        addIcon.visible = false
        local skins1 = skins and skins[1] or cache.PlayerCache:getSkins(Skins.clothes)--衣服
        local skins2 = skins and skins[2] or cache.PlayerCache:getSkins(Skins.wuqi)--武器
        local skins3 = skins and skins[3] or cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
        local skins5 = skins and skins[5] or cache.PlayerCache:getSkins(Skins.shenbing) --神兵
        local modelObj
        modelObj,cansee = self.mParent:addModel(skins1,panel)
        modelObj:setSkins(nil,skins2,skins3)
        modelObj:setPosition(panel.actualWidth/2,-panel.actualHeight-40,100)
        modelObj:setRotation(RoleSexModel[sex].angle)
        modelObj:setScale(100)
        -- if skins5 > 0 and skins2>0 then
            -- modelObj:addWeaponEct(skins5.."_ui")
        -- end
    else
        addIcon.visible = true
        local modelObj = self.mParent:addModel(GuDingmodel[1],panel)
        modelObj:setPosition(panel.actualWidth/2,-panel.actualHeight-40,100)
        modelObj:setRotation(RoleSexModel[sex].angle)
        modelObj:setScale(100)
    end
end
--设置海选赛比赛进度
function PkPanel:setHaiXunaPlan()
    local targetAwardSigns = cache.XianLvCache:getTargetAwardSigns()
    self.max = conf.XianLvConf:getValue("hxs_max_join_count")
    self.progressBar.max = self.max
    self.progressBar.value = self.data.hxsJoinCount
    local index = 0
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActiveId)
    --前缀
    local pre = self.mulConfData and self.mulConfData.award_pre
    local confData = {}
    if self.data.msgId == 5540101 then--跨服
        confData = conf.XianLvConf:getHxsAwardByType(pre,1)
    elseif self.data.msgId == 5540201 then--全服
        confData = conf.XianLvConf:getWorldHxsAwardByType(pre,1)
    end
    for k,v in pairs(confData) do
        if self.data.hxsJoinCount >= v.win_count then
            index = index +1
        end
        local title = self.boxArr[k]:GetChild("n39")
        title.text = string.format(language.xianlv07,v.win_count)
        local box = self.boxArr[k]:GetChild("n35")
        box.data = {cfgId = v.id,winCount = v.win_count,item = v.item}
        box.onClick:Add(self.getStageAward,self)
        local redImg = self.boxArr[k]:GetChild("red")
        if not targetAwardSigns[v.id] then
            box.url = UIItemRes.xianlvBoxClose[k]
            if self.data.hxsJoinCount >= v.win_count  then
                redImg.visible = true--可领取
            else
                redImg.visible = false--不可领
            end
        else
            box.url = UIItemRes.xianlvBoxOpen[k]
            redImg.visible = false--已领取
        end
    end

    -- for k,v in pairs(self.boxArr) do
    --     v.x = self.progressBar.x +(confData[k].win_count/self.max*self.progressBar.width)
    -- end
    self.barController.selectedIndex = index
end
--获取阶段奖励
function PkPanel:getStageAward(context)
    local targetAwardSigns = cache.XianLvCache:getTargetAwardSigns()
    local data = context.sender.data
    local cfgId = data.cfgId
    local winCount = data.winCount
    if targetAwardSigns[cfgId] then
        GComAlter(language.czccl07)
        return
    end
    local msgId
    if self.data.msgId == 5540101 then
        msgId = 1540104
    elseif self.data.msgId == 5540201 then
        msgId = 1540204
    end
    if self.data.hxsJoinCount >= winCount and not targetAwardSigns[cfgId] then
        proxy.XianLvProxy:sendMsg(msgId,{reqType = 1,cfgId = cfgId})
    else
        mgr.ViewMgr:openView2(ViewName.XianLvPKRewardView,data.item)
        -- GComAlter(language.jianLingBorn05)
    end
end
--设置左侧面板
function PkPanel:setLeftPanel()
    for k,v in pairs(self.decArr) do
        v.text = language.xianlv03[k]
    end
    if self.data.teamInfo.teamName == "" then
        for k,v in pairs(self.teamInfoArr) do
            if k == 5 then
                v.text = language.xianlv09--未报名
            else
                v.text = language.xianlv08--暂无
            end
        end
    else
        --名字
        self.teamInfoArr[1].text = self.data.teamInfo.teamName
        --战力
        self.teamInfoArr[2].text = self.data.teamInfo.power
        --场次
        self.teamInfoArr[3].text = self.data.teamInfo.joinCount
        --胜率
        self.teamInfoArr[4].text = self.data.teamInfo.joinCount == 0 and "0%" or math.floor(self.data.teamInfo.winCount/self.data.teamInfo.joinCount * 100) .."%"
        --目标
        self.teamInfoArr[6].text = language.xianlv04
    end
    local channelId = cache.PlayerCache:getRedPointById(10327)
    local actConfData = conf.ActivityConf:getActiveById(1114)--没用， 防空
    local startTime = self.data.startTime or actConfData.startTime
    local hxsTime = conf.XianLvConf:getValue("hxs_race_time")--海选赛时间
    local zbsTime1 = conf.XianLvConf:getValue("zbs_race_time01")--争霸赛第一场时间
    local zbsTime2 = conf.XianLvConf:getValue("zbs_race_time02")--争霸赛第二场时间
    local date = 0 --比赛日期
    local raceTime = hxsTime--{} --比赛时间
    local stage = self.data.stage
--stage:1:报名阶段、2:海选赛、3:争霸赛第一场预告4：争霸赛第一场进行中、5：争霸赛第二场预告、6：争霸赛第二场进行中、7：全部结束
    if self.data.curDay == 1 then--第一天
        date = startTime
        if stage == 1 or stage == 2 then
            self.matchTypeIcon.url = UIItemRes.xianlv02[1]--海选赛
            raceTime = hxsTime
        elseif stage == 3 then
            date = startTime + 86400--第二天
            self.matchTypeIcon.url = UIItemRes.xianlv02[2]--争霸赛第一场
            raceTime = zbsTime1
        end
    elseif self.data.curDay == 2 then--第二天
        date = startTime + 86400--第二天
        if stage == 3 then
            raceTime = zbsTime1
            self.matchTypeIcon.url = UIItemRes.xianlv02[2]--争霸赛第一场
        elseif stage == 4 then
            raceTime = zbsTime1
            self.matchTypeIcon.url = UIItemRes.xianlv02[2]--争霸赛第一场
        elseif stage == 5 then
            raceTime = zbsTime2
            self.matchTypeIcon.url = UIItemRes.xianlv02[3]--争霸赛第二场
        elseif stage == 6 then
            raceTime = zbsTime2
            self.matchTypeIcon.url = UIItemRes.xianlv02[3]--争霸赛第二场
        elseif stage == 7 then
        end
    end
    --当前状态
    if stage == 1 then
        if self.data and self.data.join and self.data.join == 1 then
            self.teamInfoArr[5].text = language.xianlv10
        elseif self.data and self.data.join and self.data.join == 0 then
            self.teamInfoArr[5].text = language.xianlv09
        end
    elseif stage == 2 then
        self.teamInfoArr[5].text = language.xianlv21--"海选赛"
    elseif stage > 2  then
        if self.data.hxRank <= 0 then
            self.teamInfoArr[5].text = language.xianlv23--"已淘汰"
        else 
            self.teamInfoArr[5].text = language.xianlv22--"争霸赛"
            if stage == 7 then
                local myTeamId = self.data.teamInfo.teamId
                local myRankType = 0--我的上榜类型
                local flag = false
                for k,v in pairs(self.data.vsInfo) do
                    for _,j in pairs(v.vsTeams) do
                        if myTeamId == j.teamId then
                            flag = true
                            myRankType = v.rankType
                            break
                        end
                    end
                end
                -- print("我的上榜类型",myRankType,self.data.zbsRank)
                local rankStr = self.data.zbsRank < 4 and language.xianlv25[self.data.zbsRank] or string.format(language.xianlv26,self.data.zbsRank)
                self.teamInfoArr[5].text = language.xianlv24[myRankType]..rankStr
            end
        end
    end
    self.date1.text = GToTimeString11(date)
    self.date2.text = GTotimeString10(raceTime[1]).." — "..GTotimeString10(raceTime[2])
end
--设置竞猜界面
function PkPanel:setGuessPanel()
    local zbsTime1 = conf.XianLvConf:getValue("zbs_race_time01")--争霸赛第一场时间
    local zbsTime2 = conf.XianLvConf:getValue("zbs_race_time02")--争霸赛第二场时间
    local zbsTime1Begin = zbsTime1[1]
    local zbsTime2Begin = zbsTime2[1]

    for k,v in pairs(self.vsInfoList) do
        local team1Btn = v.team1
        team1Btn.onClick:Add(self.seeTeamInfo,self)
        local team2Btn = v.team2
        team2Btn.onClick:Add(self.seeTeamInfo,self)
        local yaBtn = v.yaBtn
        yaBtn.onClick:Add(self.goYaZhu,self)
        local data = self.vsInfoData[v.group]
        local beginTime = 0
        if data.group then
            if v.group < 3 then--前两组
                team1Btn.title = data.vsTeams[1] and data.vsTeams[1].teamName or language.worldcup06
                team1Btn.data = data.vsTeams[1] and data.vsTeams[1].teamId or 0

                team2Btn.title = data.vsTeams[2] and data.vsTeams[2].teamName or language.worldcup06
                team2Btn.data = data.vsTeams[2] and data.vsTeams[2].teamId or 0
                beginTime = zbsTime1Begin
            elseif v.group == 3 then--冠军争夺组
                beginTime = zbsTime2Begin
                local winTeamName = ""
                local winTeamId = 0
                if not self.vsInfoData[1].vsTeams then
                    team1Btn.title = language.worldcup06
                    team1Btn.data =  0
                else
                    for k,v in pairs(self.vsInfoData[1].vsTeams) do
                        if self.vsInfoData[1].winTeamId == v.teamId then
                            team1Btn.title = v.teamName or language.worldcup06
                            team1Btn.data = v.teamId or 0
                            break
                        else
                            team1Btn.title = language.worldcup06
                            team1Btn.data = 0
                        end
                    end
                end
                if not self.vsInfoData[2].vsTeams then
                    team2Btn.title = language.worldcup06
                    team2Btn.data =  0
                else
                    for k,v in pairs(self.vsInfoData[2].vsTeams) do
                        if self.vsInfoData[2].winTeamId == v.teamId then
                            team2Btn.title = v.teamName or language.worldcup06
                            team2Btn.data = v.teamId or 0
                            break
                        else
                            team2Btn.title = language.worldcup06
                            team2Btn.data = 0
                        end
                    end

                end
                for k,v in pairs(data.vsTeams) do--对决列表
                    if v.teamId == data.winTeamId then
                        winTeamName = v.teamName
                        winTeamId = v.teamId
                    end
                end
                if data.winTeamId ~= 0 then
                    self.first.title = winTeamName
                    self.first.data = winTeamId
                    self.first.onClick:Add(self.seeTeamInfo,self)
                end
            elseif v.group == 4 then--季军争夺组
                beginTime = zbsTime2Begin
                local winTeamName = ""
                local winTeamId = 0
                if not self.vsInfoData[1].vsTeams then
                    team1Btn.title = language.worldcup06
                    team1Btn.data =  0
                else
                    for k,v in pairs(self.vsInfoData[1].vsTeams) do
                        if self.vsInfoData[1].winTeamId ~= v.teamId then
                            team1Btn.title = v.teamName or language.worldcup06
                            team1Btn.data = v.teamId or 0
                            break
                        else
                            team1Btn.title = language.worldcup06
                            team1Btn.data = 0
                        end
                    end
                end
                if not self.vsInfoData[2].vsTeams then
                    team2Btn.title = language.worldcup06
                    team2Btn.data =  0
                else
                    for k,v in pairs(self.vsInfoData[2].vsTeams) do
                        if self.vsInfoData[2].winTeamId ~= v.teamId then
                            team2Btn.title = v.teamName or language.worldcup06
                            team2Btn.data = v.teamId or 0
                            break
                        else
                            team2Btn.title = language.worldcup06
                            team2Btn.data = 0
                        end
                    end
                end
                for k,v in pairs(data.vsTeams) do
                    if v.teamId == data.winTeamId then
                        winTeamName = v.teamName
                        winTeamId = v.teamId
                    end
                end
                if data.winTeamId ~= 0 then
                    self.third.title = winTeamName
                    self.third.data = winTeamId
                    self.third.onClick:Add(self.seeTeamInfo,self)
                end
            end
            -- local isCanStake = false--是否可押注
            if not data.vsTeams[1] or not data.vsTeams[2] then
                yaBtn.visible = false
            else
                yaBtn.visible = true
                -- print("已经获胜队伍data.winTeamId",data.winTeamId)
                if data.winTeamId ~= 0 then
                    yaBtn.grayed = true
                    -- isCanStake = false
                else
                    yaBtn.grayed = false
                    -- isCanStake = true
                end
            end
            yaBtn.data = {rankType = data.rankType,group = data.group, beginTime = beginTime}
        else
            team1Btn.title = language.worldcup06
            team2Btn.title = language.worldcup06
            yaBtn.visible = false
            team1Btn.data = 0
            team2Btn.data = 0
        end
    end
end
--竞猜阶段，天地榜切换
--rankType: 1、天榜。2、地榜
function PkPanel:onGuessChange()
    self.vsInfoData = {}
  
    local  XlpkVsInfo= {}
    for k,v in pairs(self.vsInfoList) do
        local flag = false
        for _,j in pairs(self.data.vsInfo) do
            if j.rankType == self.guessC1.selectedIndex + 1 then
                if v.group == j.group then
                    table.insert(self.vsInfoData,j)
                    flag = true
                    break
                end
            end
        end
        if not flag then
            table.insert(self.vsInfoData,XlpkVsInfo)
        end
    end
    self.first.title = "冠军"
    self.third.title = "季军"
    -- printt("对决信息",self.vsInfoData)
    self:setGuessPanel()

end
--查看队伍信息
--data:
function PkPanel:seeTeamInfo(context)
    local data = context.sender.data
    if data == 0 then
        GComAlter("暂无队伍")
        return
    else
        -- print("队伍id",data)
        local msgId
        if self.data.msgId == 5540101 then
            msgId = 1540108
        elseif self.data.msgId == 5540201 then
            msgId = 1540208
        end
        mgr.ViewMgr:openView(ViewName.TeamInfoView,function ()
            proxy.XianLvProxy:sendMsg(msgId,{teamId = data})
        end)
    end
end

function PkPanel:goYaZhu(context)
    local data = context.sender.data
    local rankType = data.rankType
    local group = data.group
    local beginTime = data.beginTime
    local vsTeams = {}
    local vsInfo = cache.XianLvCache:getVsInfo()
    for k,v in pairs(vsInfo) do
        if v.rankType == rankType and v.group == group then
            vsTeams = v.vsTeams
            group = v.group
        end
    end
    mgr.ViewMgr:openView2(ViewName.XianLvPKTouZhuView,{vsTeams = vsTeams,group = group,beginTime = beginTime,nowTime = self.data.serverTime,curDay = self.data.curDay,msgId = self.data.msgId})
        
end


function PkPanel:onClickGoBtn(context)
    --data 1:前往结婚,2:报名参赛,3:已报名,4:参与匹配
    local data = context.sender.data
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    if data == 1 then
        self:goMarry()
    elseif data == 2 then
        mgr.ViewMgr:openView2(ViewName.JoinView,{msgId = self.data.msgId})
    elseif data == 3 then
        GComAlter(language.xianlv16_01)
    elseif data == 4 then
        -- if self.data.join == 0 then
        --     GComAlter(language.xianlv27_01)
        --     return
        -- end
        if self.data.matchStatu == 1 then
            GComAlter(language.xianlv28)--您的伴侣正在进行匹配，请耐心等待比赛开始
            return
        end
        local maxJoinCount = conf.XianLvConf:getValue("hxs_max_join_count")
        if mgr.FubenMgr:checkScene() then
            GComAlter(language.gonggong41)
        else
            if self.data.teamInfo.joinCount < maxJoinCount then
                local msgId
                if self.data.msgId == 5540101 then
                    msgId = 1540107
                elseif self.data.msgId == 5540201 then
                    msgId = 1540207
                end
                proxy.XianLvProxy:sendMsg(msgId,{reqType = 1})
            else
                GComAlter(language.xianlv20)
            end
        end
    end
end

function PkPanel:goMarry()
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    local mainTaskId = cache.TaskCache:getCurMainId()
    if mainTaskId <= 1014 and mainTaskId ~= 0 then
        GComAlter(language.task20)
        return
    end
    mgr.TaskMgr:setCurTaskId(9003)
    mgr.TaskMgr.mState = 2
    mgr.TaskMgr:resumeTask()
end

function PkPanel:onClickAward()
    mgr.ViewMgr:openView2(ViewName.XianLvPKRankAward,{msgId = self.data.msgId})
end

function PkPanel:onClickRank()
    local reqType = 0
    local page = 1
    if self.c1.selectedIndex == 0 then
        reqType = 0
        page = 1
    elseif self.c1.selectedIndex == 1 or self.c1.selectedIndex == 2 then
        reqType = self.guessC1.selectedIndex == 0 and 1 or 2--天地榜
        page = 0
    end
    local msgId
    if self.data.msgId == 5540101 then
        msgId = 1540103
    elseif self.data.msgId == 5540201 then
        msgId = 1540203
    end
    mgr.ViewMgr:openView(ViewName.XianLvRankView,function ()
        proxy.XianLvProxy:sendMsg(msgId,{reqType = reqType,page = page})
    end,{msgId = self.data.msgId})
end

return PkPanel