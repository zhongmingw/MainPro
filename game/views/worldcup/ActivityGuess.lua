--
-- Author: 
-- Date: 2018-06-30 14:57:56
--

local ActivityGuess = class("ActivityGuess",import("game.base.Ref"))

function ActivityGuess:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end


function ActivityGuess:initPanel()
    self.view = self.mParent.view:GetChild("n16")
    local rule1 = self.view:GetChild("n34")
    local rule2 = self.view:GetChild("n35")
    rule1.text = language.worldcup08
    rule2.text = language.worldcup09
    self.first = self.view:GetChild("first")--冠军
    self.third = self.view:GetChild("third")--季军
    self.teamInfo = {}

   
    local t = {}--1场
    t.team1 = self.view:GetChild("n0")
    t.team2 = self.view:GetChild("n1")
    t.yaBtn1 = self.view:GetChild("n0"):GetChild("n1")
    t.yaBtn2 = self.view:GetChild("n1"):GetChild("n1")
    t.time = self.view:GetChild("n37")
    table.insert(self.teamInfo,t)
    local t = {}--2场
    t.team1 = self.view:GetChild("n2")
    t.team2 = self.view:GetChild("n3")
    t.yaBtn1 = self.view:GetChild("n2"):GetChild("n1")
    t.yaBtn2 = self.view:GetChild("n3"):GetChild("n1")
    t.time = self.view:GetChild("n38")
    table.insert(self.teamInfo,t)
    local t = {}--3场
    t.team1 = self.view:GetChild("n8")
    t.team2 = self.view:GetChild("n9")
    t.yaBtn1 = self.view:GetChild("n8"):GetChild("n1")
    t.yaBtn2 = self.view:GetChild("n9"):GetChild("n1")
    t.time = self.view:GetChild("n39")
    table.insert(self.teamInfo,t)
    local t = {}--4场
    t.team1 = self.view:GetChild("n10")
    t.team2 = self.view:GetChild("n11")
    t.yaBtn1 = self.view:GetChild("n10"):GetChild("n1")
    t.yaBtn2 = self.view:GetChild("n11"):GetChild("n1")
    t.time = self.view:GetChild("n40")
    table.insert(self.teamInfo,t)
    local t = {}--5场
    t.team1 = self.view:GetChild("n4")
    t.team2 = self.view:GetChild("n5")
    t.yaBtn1 = self.view:GetChild("n4"):GetChild("n1")
    t.yaBtn2 = self.view:GetChild("n5"):GetChild("n1")
    t.time = self.view:GetChild("n42")
    table.insert(self.teamInfo,t)
    local t = {}--6场
    t.team1 = self.view:GetChild("n12")
    t.team2 = self.view:GetChild("n13")
    t.yaBtn1 = self.view:GetChild("n12"):GetChild("n1")
    t.yaBtn2 = self.view:GetChild("n13"):GetChild("n1")
    t.time = self.view:GetChild("n43")
    table.insert(self.teamInfo,t)
    local t = {}--7场--季军赛
    t.team1 = self.view:GetChild("n7")
    t.team2 = self.view:GetChild("n15")
    t.yaBtn1 = self.view:GetChild("n7"):GetChild("n1")
    t.yaBtn2 = self.view:GetChild("n15"):GetChild("n1")
    t.time = self.view:GetChild("n45")
    table.insert(self.teamInfo,t)
    local t = {}--8场--冠军赛
    t.team1 = self.view:GetChild("n6")
    t.team2 = self.view:GetChild("n14")
    t.yaBtn1 = self.view:GetChild("n6"):GetChild("n1")
    t.yaBtn2 = self.view:GetChild("n14"):GetChild("n1")
    t.time = self.view:GetChild("n44")
    table.insert(self.teamInfo,t)

end
--设置信息
function ActivityGuess:setInfo()
    local nowTime = mgr.NetMgr:getServerTime()
    local fieldArr = {}
    for k,v in pairs(self.data.infos) do
        table.insert(fieldArr,v.field)--后端返还场次信息
    end
    local temp = {}
    for k,v in pairs(fieldArr) do
        if v then
            temp[v] = 1
        end
    end
    local t = {1,2,3,4,5,6,7,8}
    for k,v in pairs(t) do
        if not temp[k] then
            table.insert(fieldArr,v)--将8场比赛补充完整
        end
    end
    -- printt(fieldArr)

    for k,v in pairs(self.teamInfo) do
         --team1是UI中上面或左边的队伍，将UI场次按钮和后端数据场次对应
        local team1Btn = self.teamInfo[fieldArr[k]].team1:GetChild("n0")
        local team2Btn = self.teamInfo[fieldArr[k]].team2:GetChild("n0")
        team1Btn.onClick:Add(self.onTeamBtn,self)
        team2Btn.onClick:Add(self.onTeamBtn,self)
        local time = v.time:GetChild("n1")
        local title = v.time:GetChild("n0")

        local data = self.data.infos[k]
        -- printt(data)
        if data then 
            local gameInfo = conf.WorldCupConf:getGameInfo(data.field)
            local teamIdTable = {}
            for k,v in pairs(data.teanInfo) do
                table.insert(teamIdTable,k)
            end
            local team1Id = teamIdTable[1] and teamIdTable[1] --gameInfo.team and gameInfo.team[1]
            local team2Id = teamIdTable[2] and teamIdTable[2] --gameInfo.team and gameInfo.team[2]
            
            if data.field == 5 then--第五场
                team1Id = self.data.infos[1].winTeamId
                team2Id = self.data.infos[2].winTeamId
            elseif data.field == 6 then
                team1Id = self.data.infos[3].winTeamId
                team2Id = self.data.infos[4].winTeamId
            elseif data.field == 7 then
                -- printt(data.teanInfo)
                for k,v in pairs(self.data.infos[5].teanInfo) do
                    if self.data.infos[5].winTeamId == 0 then --没有赢的队伍
                        team1Id = 0
                    elseif self.data.infos[5].winTeamId ~= k then
                        team1Id = k
                        -- print("team1Id",k)
                        break
                    end
                end
                for k,v in pairs(self.data.infos[6].teanInfo) do
                    if self.data.infos[6].winTeamId == 0 then 
                        team2Id = 0
                    elseif self.data.infos[6].winTeamId ~= k then
                        team2Id = k
                        break
                    end
                end
            elseif data.field == 8 then
                team1Id = self.data.infos[5].winTeamId
                team2Id = self.data.infos[6].winTeamId
            end
            local stakeInfo = {}
            for k,v in pairs(self.data.stakeInfos) do
                if v.field == data.field then 
                    table.insert(stakeInfo,v)--获得指定场次的压住信息
                end
            end
            v.yaBtn1.data = {teamId = team1Id,field = data.field,stakeInfo = stakeInfo,endTime = data.endTime}
            v.yaBtn2.data = {teamId = team2Id,field = data.field,stakeInfo = stakeInfo,endTime = data.endTime}
            team1Btn.data = {teamId = team1Id,field = data.field,stakeInfo = stakeInfo,endTime = data.endTime}
            team2Btn.data = {teamId = team2Id,field = data.field,stakeInfo = stakeInfo,endTime = data.endTime}

            v.yaBtn1.onClick:Add(self.goYaZhu,self)
            v.yaBtn2.onClick:Add(self.goYaZhu,self)
            if data.field == 8 then --冠军赛
                if data.winTeamId ~= 0 then--有队伍获胜
                    local teamName = conf.WorldCupConf:getTeamName(data.winTeamId).name
                    self.first.title = teamName
                end
            end
            if data.field == 7 then--季军赛
                if data.winTeamId  ~= 0 then--有队伍获胜
                    local teamName = conf.WorldCupConf:getTeamName(data.winTeamId).name
                    self.third.title = teamName

                end
            end

            if team1Id ~= 0 then 
                v.yaBtn1.visible = true
                team1Btn.title = data.teanInfo[team1Id]
            else
                v.yaBtn1.visible = false
                team1Btn.title = language.worldcup06
                team1Btn.data = 2--虚位以待
            end
            if team2Id ~= 0 then 
                v.yaBtn2.visible = true
                team2Btn.title = data.teanInfo[team2Id]
            else
                v.yaBtn2.visible = false
                team2Btn.title = language.worldcup06
                team2Btn.data = 2--比赛没开始
            end
            if team1Id  ~= 0 and team2Id ~= 0 then --两个队伍都存在
                title.text = language.worldcup07
                time.text = GToTimeString9(data.endTime)
                if data.winTeamId ~= 0 then--有队伍获胜
                    time.text = ""
                    title.text = ""
                end
            else
                time.text = ""
                title.text = ""
            end
            if nowTime > data.endTime then --已经过了押注时间
                -- v.yaBtn1.touchable = false
                -- v.yaBtn2.touchable = false
                
                v.yaBtn1.grayed = true
                v.yaBtn2.grayed = true
               
                -- team1Btn.data = 1
                -- team2Btn.data = 1

                team1Btn.grayed = true
                team2Btn.grayed = true

                team1Btn.touchable = false
                team2Btn.touchable = false
            else
                -- team1Btn.data = 2
                -- team2Btn.data = 2
            --     v.yaBtn1.touchable = true
            --     v.yaBtn2.touchable = true
                v.yaBtn1.grayed = false
                v.yaBtn2.grayed = false
            end
            if #teamIdTable < 2 then --还有一个队伍没有踢完
                v.yaBtn1.visible = false
                v.yaBtn2.visible = false
                team1Btn.data = 2--虚位以待
                team2Btn.data = 2--虚位以待
            end
        else
            team1Btn.title = language.worldcup06
            team2Btn.title = language.worldcup06
            time.text = ""
            title.text = ""

            v.yaBtn1.visible = false
            v.yaBtn2.visible = false
            team1Btn.data = 2
            team2Btn.data = 2
        end

    end
end

function ActivityGuess:onTeamBtn(context)
    local data = context.sender.data
    if type(data) == "number" then
        if data == 1 then --请关注下一场精彩比赛
            GComAlter(language.worldcup10)
            return
        elseif data == 2 then --比赛还没开始
            GComAlter(language.worldcup12)
            return
        end
    else
        local nowTime = mgr.NetMgr:getServerTime()
        mgr.ViewMgr:openView2(ViewName.YaZhuView,data)
    end



end

function ActivityGuess:goYaZhu(context)
    local data = context.sender.data
    -- local data = {teamId = teamId}
    local nowTime = mgr.NetMgr:getServerTime()
    -- if nowTime > data.endTime then --已经开始比赛
        -- GComAlter(language.worldcup10)
        -- return
    -- end
    mgr.ViewMgr:openView2(ViewName.YaZhuView,data)

end


function ActivityGuess:setData(data)
    self.data = data
    printt("后端返回",self.data)
    self:setInfo()
end

function ActivityGuess:onTimer()
    if self.time then 
        if tonumber(self.time) > 86400 then 
            self.lastTime.text = GTotimeString7(self.time)
        else
            self.lastTime.text = GTotimeString(self.time)
        end
        if self.time <= 0 then
           self.mParent:onBtnClose()
        end
        self.time = self.time - 1
    end
end


return ActivityGuess