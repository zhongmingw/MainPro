--
-- Author: Your Name
-- Date: 2018-01-10 14:22:24
--

local RankProceedView = class("RankProceedView", base.BaseView)

function RankProceedView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function RankProceedView:initView()
    self.timeTxtDec = self.view:GetChild("n2")
    self.time1 = self.view:GetChild("n3")
    self.time2 = self.view:GetChild("n4")
    self.c1 = self.view:GetController("c1")
    -- self.c1.onChanged:Add(self.onControlChange,self)
    self.teamListView = self.view:GetChild("n6"):GetChild("n0")
    self.teamListView.numItems = 0
    self.teamListView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.teamListView:SetVirtual()
    self.enemyList = self.view:GetChild("n8")
    self.enemyList.numItems = 0
    self.enemyList.itemRenderer = function (index,obj)
        self:enemyCell(index,obj)
    end
    self.enemyList:SetVirtual()
end
--one_fight_sec
function RankProceedView:initData(data)
    self.timeTxtDec.text = language.qualifier33
    self:setRound(data)
    self.type = data.type
    if data.teamId then--有队伍信息
        print("有队伍信息")
        self.c1.selectedIndex = 1
        self:refreshHpInfo(data)
    else--单人排位
        self.c1.selectedIndex = 0
    end
    
end

--当前第几回合
function RankProceedView:setRound(data)
    if data.bo then--当前第几回合
        local things = mgr.ThingMgr:objsByType(ThingType.player)
        if data.bo == 0 then
            for k,v in pairs(things) do
                -- print("设置不可选中")
                v:setCanSelect(false)
            end
            self.timeTxtDec.text = language.qualifier33
        else
            for k,v in pairs(things) do
                -- print("设置可选中")
                v:setCanSelect(true)
            end
            self.timeTxtDec.text = string.format(language.qualifier34,data.bo)
        end
    end
    local startTime = data.startTime or data.boStartTime
    local proceedTime = 0
    if data.type == 1 then--单人排位
        proceedTime = conf.QualifierConf:getValue("one_fight_sec")
    elseif data.type == 2 then--组队排位
        proceedTime = conf.QualifierConf:getValue("zd_fight_sec")
    elseif data.type == 3 then--季后赛有准备时间
        self.timeTxtDec.text = language.qualifier53
        local delayTime = conf.QualifierConf:getValue("jhs_ready_sec")
        startTime = startTime + delayTime
    else--季后赛每回合时间
        proceedTime = conf.QualifierConf:getValue("jhs_bo_sec")
    end
    self.startTime = startTime
    print("结束时间  当前时间",data.type,startTime,mgr.NetMgr:getServerTime())
    self.endTime = startTime + proceedTime
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
    local nowTime = mgr.NetMgr:getServerTime()
    local curTime = self.endTime - nowTime
    if nowTime - self.startTime < 0 then--准备时间
        curTime = self.startTime - nowTime
    end
    local timeData = GGetTimeData(curTime)
    self.time1.text = timeData.min
    self.time2.text = string.format("%02d",timeData.sec)
    self.timer = self:addTimer(1, -1,handler(self,self.timerClick))
end

function RankProceedView:refreshHpInfo(data)
    self.hpInfos = data.hpInfos
    local myTeamId = data.teamId
    self.myTeamHpInfo = {}
    self.enemyHpInfo = {}
    for k,v in pairs(self.hpInfos) do
        if myTeamId == v.teamId then
            -- print("己方队伍")
            table.insert(self.myTeamHpInfo,v)
        else
            -- print("敌方队伍")
            table.insert(self.enemyHpInfo,v)
        end
    end
    self.teamListView.numItems = #self.myTeamHpInfo
    self.enemyList.numItems = #self.enemyHpInfo
end

-- 变量名：roleId  说明：角色id
-- 变量名：hp  说明：当前血量
-- 变量名：hpMax   说明：最大血
-- 变量名：roleIcon    说明：头像
-- 变量名：roleName    说明：名字
-- 变量名：teamId  说明：队伍id
function RankProceedView:celldata(index,obj)
    local data = self.myTeamHpInfo[index+1]
    if data then
        local icon = obj:GetChild("n2")
        local nameTxt = obj:GetChild("n7")
        local captainIcon = obj:GetChild("n4")
        local hpBar = obj:GetChild("n5")
        local lvTxt = obj:GetChild("n6")
        local teamInfo = cache.PwsCache:getTeamInfo()
        if teamInfo.captainRoleId == data.roleId then
            captainIcon.visible = true
        else
            captainIcon.visible = false
        end
        nameTxt.text = data.roleName
        hpBar.value = data.hp
        hpBar.max = data.hpMax
        lvTxt.text = data.lev or 1
        icon.url = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(t)
            if icon then icon.url = t.headUrl end
        end).headUrl
    end
end
function RankProceedView:enemyCell(index,obj)
    local data = self.enemyHpInfo[index+1]
    if data then
        local icon = obj:GetChild("n1"):GetChild("n0")
        local hpBar = obj:GetChild("n2")
        hpBar.value = data.hp
        hpBar.max = data.hpMax
        icon.url = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(t)
            if icon then icon.url = t.headUrl end
        end).headUrl
    end
end

function RankProceedView:timerClick()
    local nowTime = mgr.NetMgr:getServerTime()
    local curTime = self.endTime - nowTime
    if nowTime - self.startTime < 0 then
        curTime = self.startTime - nowTime
    end
    if curTime >= 0 then
        local timeData = GGetTimeData(curTime)
        self.time1.text = timeData.min
        self.time2.text = string.format("%02d",timeData.sec)
    else
        print("关闭排位赛对战界面")
        -- self:closeView()
    end
end

return RankProceedView