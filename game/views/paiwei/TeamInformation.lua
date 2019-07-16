--
-- Author: Your Name
-- Date: 2018-01-29 20:45:41
--跨服排位队伍信息界面

local TeamInformation = class("TeamInformation", base.BaseView)

function TeamInformation:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function TeamInformation:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    local guizeBtn = self.view:GetChild("n12")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    self.teamNameTxt = self.view:GetChild("n10")
    self.pwLevTxt = self.view:GetChild("n11")
    --申请列表
    self.applyBtn = self.view:GetChild("n13")
    self.applyBtn.onClick:Add(self.onClickApply,self)
    --解散按钮
    self.disBtn = self.view:GetChild("n14")
    self.disBtn.onClick:Add(self.onClickDis,self)
    --踢出队伍按钮
    self.kickBtn = self.view:GetChild("n15")
    self.kickBtn.onClick:Add(self.onClickKick,self)
    --转移队长按钮
    self.transferBtn = self.view:GetChild("n16")
    --转移
    self.transferBtn.onClick:Add(self.onClickTransfer,self)
    --邀请成员
    self.inviteBtn = self.view:GetChild("n17")
    self.inviteBtn.onClick:Add(self.onClickInvite,self)
    --退出队伍
    self.quitBtn = self.view:GetChild("n18")
    self.quitBtn.onClick:Add(self.onClickQuit,self)
end

function TeamInformation:onController()
    
end

function TeamInformation:initData(data)
    self:showMembers()
    local teamInfo = cache.PwsCache:getTeamInfo()
    local roleId = cache.PlayerCache:getRoleId()
    if roleId == teamInfo.captainRoleId then
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
    end
end

--队伍成员排序
function TeamInformation:membersSort(teamMembers)
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
function TeamInformation:showMembers()
    local teamInfo = cache.PwsCache:getTeamInfo()
    local members = self:membersSort(cache.PwsCache:getTeamList())
    local roleId = cache.PlayerCache:getRoleId()
    if roleId == teamInfo.captainRoleId then
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
    end
    local rolePanelList = {}
    for i=7,9 do
        table.insert(rolePanelList,self.view:GetChild("n"..i))
    end
    local teamIcon = self.view:GetChild("n3")
    if teamInfo.icon > 0 then
        local imgData = conf.QualifierConf:getTeamIconById(teamInfo.icon)
        teamIcon.url = UIPackage.GetItemURL("paiwei",imgData.icon)
    end
    local pwData = conf.QualifierConf:getPwsTeamDataByLv(teamInfo.pwLev)
    local levelTxt = self.view:GetChild("n11")
    levelTxt.text = language.qualifier31 .. pwData.name .. pwData.stars .. language.gonggong118
    -- teamInfo
    -- captainRoleId   说明：队长角色id
    -- captainName 说明：队长名字
    -- teamName    说明：队伍名字
    -- icon    说明：图标
    -- pwLev   说明：排位等级
    -- teamId  说明：队伍id
    if teamInfo.teamId > 0 then--有队伍
        -- members
        -- roleId  说明：角色id
        -- roleName    说明：角色名字
        -- level   说明：等级
        -- power   说明：战力
        -- roleIcon    说明：头像
        -- skinMap 说明：外观
        -- printt("成员信息",members)
        self.view:GetChild("n10").text = teamInfo.teamName
        for i=1,#rolePanelList do
            local heroModel = rolePanelList[i]:GetChild("n1")
            if members[i] then
                rolePanelList[i].visible = true
                local roleName = rolePanelList[i]:GetChild("n3")
                local levTxt = rolePanelList[i]:GetChild("n6")
                local powerTxt = rolePanelList[i]:GetChild("n7")
                roleName.text = members[i].roleName
                levTxt.text = members[i].level
                powerTxt.text = members[i].power
                for index =1,8 do
                    rolePanelList[i]:GetChild("n"..(index-1)).visible = true
                end
                if members[i].roleId == teamInfo.captainRoleId then
                    rolePanelList[i]:GetChild("n2").visible = true
                else
                    rolePanelList[i]:GetChild("n2").visible = false
                end
                local skinMap = members[i].skinMap
                local sex = members[i].sex
                local modelObj = self:addModel(skinMap[1],heroModel)
                modelObj:setSkins(nil,skinMap[2],skinMap[3])
                modelObj:setPosition(50,-200,200)
                modelObj:setRotation(RoleSexModel[sex].angle)
                modelObj:setScale(120)
            else
                -- rolePanelList[i].visible = false
                for index =1,8 do
                    if index-1 ~= 1 then
                        rolePanelList[i]:GetChild("n"..(index-1)).visible = false
                    else
                        rolePanelList[i]:GetChild("n"..(index-1)).visible = true
                    end
                end
                
                local modelObj = self:addModel(GuDingmodel[1],heroModel)
                modelObj:setPosition(50,-200,200)
                modelObj:setRotation(RoleSexModel[1].angle)
                modelObj:setScale(120)
            end
        end
    end
end
--申请列表
function TeamInformation:onClickApply()
    if self:whetherCanOperate() then
        mgr.ViewMgr:openView2(ViewName.PwsTeamApplyView, {})
    else
        GComAlter(language.qualifier50)
    end
end
--解散
function TeamInformation:onClickDis()
    local teamInfo = cache.PwsCache:getTeamInfo()
    -- print("队伍信息",teamInfo.memberCount)
    if self:whetherCanOperate() then
        if teamInfo.memberCount and teamInfo.memberCount == 1 then
            mgr.ViewMgr:openView2(ViewName.DismissTipsView, {type = 1})
        else
            GComAlter(language.qualifier38)
        end
    else
        GComAlter(language.qualifier50)
    end
end
--踢出
function TeamInformation:onClickKick()
    if self:whetherCanOperate() then
        mgr.ViewMgr:openView2(ViewName.PwsMembersList, {type = 1})
    else
        GComAlter(language.qualifier50)
    end
end
--转移
function TeamInformation:onClickTransfer()
    if self:whetherCanOperate() then
        mgr.ViewMgr:openView2(ViewName.PwsMembersList, {type = 2})    
    else
        GComAlter(language.qualifier50)
    end
end
--邀请
function TeamInformation:onClickInvite()
    if self:whetherCanOperate() then
        mgr.ViewMgr:openView2(ViewName.PwsTeamInviteList, {})
    else
        GComAlter(language.qualifier50)
    end
end
--退出
function TeamInformation:onClickQuit()
    if self:whetherCanOperate() then
        mgr.ViewMgr:openView2(ViewName.DismissTipsView, {type = 2})
    else
        GComAlter(language.qualifier50)
    end
end

--是否可以进行战队操作
function TeamInformation:whetherCanOperate()
    local flag = true
    local netTime = mgr.NetMgr:getServerTime()
    local day = GGetWeekDayByTimestamp(netTime)
    local teamStartDay = conf.QualifierConf:getValue("zd_week_day")
    local delayTime = conf.QualifierConf:getValue("act_sec") + conf.QualifierConf:getValue("start_diff")
    if day == teamStartDay[1] then
        local TimeTab = os.date("*t",netTime)
        local openTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0) + delayTime
        if netTime >= openTime then
            flag = false
        end
    elseif day == 0 then--周末
        local TimeTab = os.date("*t",netTime)
        local overTime = GToTimestampByDayTime(TimeTab.day,TimeTab.month,TimeTab.year,0,0) + delayTime
        if netTime < overTime then
            flag = false
        end
    end
    return flag
end

function TeamInformation:onClickGuize()
    GOpenRuleView(1075)
end

function TeamInformation:dispose(clear)
    self.super.dispose(self,clear)
end

return TeamInformation