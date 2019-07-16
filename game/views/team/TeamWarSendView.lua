--
-- Author:
-- Date: 2017-11-02 21:58:05
--

local TeamWarSendView = class("TeamWarSendView", base.BaseView)

function TeamWarSendView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
end

function TeamWarSendView:initView()
    self.roleItems = {}
    for i=6,8 do
        local role = self.view:GetChild("n"..i)
        table.insert(self.roleItems, role)
    end
    self.view:GetChild("n10").text = language.team49
    self.progressBar = self.view:GetChild("n11")--倒计时进度条
    self.proBarText = self.progressBar:GetChild("n2")
    self.refuseBtn = self.view:GetChild("n12")--拒绝
    self.refuseBtn.onClick:Add(self.onClickRefuse,self)
    self.agreeBtn = self.view:GetChild("n13")--同意
    self.agreeBtn.onClick:Add(self.onClickAgree,self)
    self.desc = self.view:GetChild("n14")
end

function TeamWarSendView:initData(data)
    self:resetTeamMebers()
    mgr.TaskMgr:stopTask()
    self.maxTime = conf.SysConf:getValue("team_ready_time")
    self.time = self.maxTime
    self:onTimer()
    self:addTimer(0.2, -1, handler(self, self.onTimer))
    self:setData(data)
    local sceneData = conf.SceneConf:getSceneById(data.sceneId)
    local name = sceneData and sceneData.name or ""
    self.desc.text = string.format(language.team59, name)
end

function TeamWarSendView:setData(data)
    self.sceneId = data.sceneId
    local teamMembers = cache.TeamCache:getTeamMembers()
    local zbNum = 0--记录准备人数
    for k,v in pairs(self.roleItems) do
        local icon = v:GetChild("n9"):GetChild("n0")
        local name = v:GetChild("n3")
        local captain = v:GetChild("n6")
        local zbIcon = v:GetChild("n7")
        local powerText = v:GetChild("n10")
        local teamData = teamMembers[k]
        if teamData.roleId then
            icon.url = GGetMsgByRoleIcon(teamData.roleIcon,teamData.roleId,function(t)
                if icon then icon.url = t.headUrl end
            end).headUrl
            name.text = teamData.roleName
            if teamData.captain == 1 then--队长
                captain.visible = true
            else
                captain.visible = false
            end
            if data.roleId == teamData.roleId then
                teamData.reqType = data.reqType
            end
            if teamData.reqType and teamData.reqType <= 2 then--已经准备了
                zbIcon.url = UIItemRes.team03
                zbNum = zbNum + 1
            else
                if teamData.captain == 1 then--如果是队长
                    zbIcon.url = UIItemRes.team03
                    zbNum = zbNum + 1
                else
                    zbIcon.url = UIItemRes.team04
                end
            end
            powerText.text = string.format(language.team67, GTransFormNum(teamData.power))
        else
            zbIcon.url = UIItemRes.team04
            captain.visible = false
            icon.url = ""
            name.text = ""
            powerText.text = ""
        end
    end
    local isCaptain = cache.TeamCache:getIsCaptain(cache.PlayerCache:getRoleId())
    if isCaptain then--队长等于直接同意了
        self.refuseBtn.enabled = false
        self.agreeBtn.enabled = false
    end

    if data.reqType == 3 then--有人拒绝了
        GComAlter(string.format(language.team56, data.roleName))
        self:closeView()
        return
    end
    -- plog(zbNum,cache.TeamCache:getTeamMemberNum(),isCaptain)
    if zbNum >= cache.TeamCache:getTeamMemberNum() and isCaptain then--全员准备好了队长拉入战斗
        self.isZb = true--全员准备好了
        self:addTimer(0.7, 1, function()
            -- plog("全员准备好了进入副本",self.sceneId)
            mgr.FubenMgr:gotoFubenWar(self.sceneId)
        end)
    else
        self.isZb = false
    end
end
--重置队伍
function TeamWarSendView:resetTeamMebers()
    local teamMembers = cache.TeamCache:getTeamMembers()
    for k,v in pairs(teamMembers) do
        teamMembers[k].reqType = 3
    end
end

function TeamWarSendView:onTimer()
    self.progressBar.value = self.time
    self.progressBar.max = self.maxTime
    self.proBarText.text = GTotimeString3(math.ceil(self.time))
    if self.time <= 0 then
        if self.isZb then--如果刚刚好遇到全员准备好了
            -- plog("进入副本2",self.sceneId)
            mgr.FubenMgr:gotoFubenWar(self.sceneId)
        elseif cache.TeamCache:getTeamMemberNum() == 3 then
            mgr.FubenMgr:gotoFubenWar(self.sceneId)
        end
        self:closeView()
        return
    end
    self.time = self.time - 0.2
end
--拒绝
function TeamWarSendView:onClickRefuse()
    if not self.sceneId then return end
    proxy.FubenProxy:send(1027305,{sceneId = self.sceneId,reqType = 3})
    self:closeView()
end
--同意
function TeamWarSendView:onClickAgree()
    if not self.sceneId then return end
    proxy.FubenProxy:send(1027305,{sceneId = self.sceneId,reqType = 2})
end

function TeamWarSendView:closeView()
    self.refuseBtn.enabled = true
    self.agreeBtn.enabled = true
    self.super.closeView(self)
end

return TeamWarSendView