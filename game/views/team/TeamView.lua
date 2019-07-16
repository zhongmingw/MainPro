--
-- Author: ohf
-- Date: 2017-03-28 15:09:17
--
--组队系统
local TeamView = class("TeamView", base.BaseView)

local NearbyPanel = import(".NearbyPanel")--附近队伍

local TeamRolePanel = import(".TeamRolePanel")--队伍角色信息

function TeamView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.minLvl = 0
    self.maxLvl = 0
    self.openTween = ViewOpenTween.scale
    self.hhTime = 0--喊话cd
end

function TeamView:initData(data)
    self.fightCdTime = 0
    self.siteData = {}--组队设定数据
    self.targetSceneId = data.targetSceneId or cache.PlayerCache:getSId()--目标场景
    self.jinlaiSceneId = data.targetSceneId
    self:clearRole()
    mgr.TaskMgr:stopTask()
    self:nextStep(data.index)
end

function TeamView:initView()
    local window = self.view:GetChild("n16")
    local closeBtn = window:GetChild("n2")
    closeBtn.onClick:Add(self.onClickClose,self)
    --我的队伍，附近队伍
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    self:initMyTeam()
    self.nearbyPanel = NearbyPanel.new(self)
end

function TeamView:initMyTeam()
    local panel = self.view:GetChild("n41")
    self.teamC1 = panel:GetController("c1")
    self.checkBtn = panel:GetChild("n6")--我是队长时，自动接受其他人发出的申请
    self.checkBtn.onChanged:Add(self.selelctCheck,self)
    
    local expBtn = panel:GetChild("n29")--Tips 加成显示
    expBtn.onClick:Add(self.onClickExpAndMoney,self)

    local createBtn = panel:GetChild("n3")
    self.createBtn = createBtn
    createBtn.onClick:Add(self.onClickCreate,self)

    self.teamCapText = panel:GetChild("n13")
    self.teamCapText.text = language.team06

    local fubenBtn = panel:GetChild("n2")
    self.fubenBtn = fubenBtn
    fubenBtn.onClick:Add(self.onFightCall,self)

    self.textSendGg = panel:GetChild("n16")
    self.textSendGg.text = mgr.TextMgr:getTextColorStr(language.team37, 7, "")
    self.textSendGg.onClick:Add(self.onClickSendGg,self)

    self.roleList = {}
    local index = 0
    for i=7,9 do
        index = index + 1
        local item = panel:GetChild("n"..i)
        local itemPanel = TeamRolePanel.new(self,item,index)
        table.insert(self.roleList, itemPanel)
    end
    panel:GetChild("n18").text = language.team42
    self.teamMbText = panel:GetChild("n20")--队伍目标
    local mbBtn = panel:GetChild("n21")
    mbBtn.onClick:Add(self.onClickTeamSite,self)
    panel:GetChild("n22").text = language.team43
    self.teamLvText = panel:GetChild("n24")--队伍等级
    local lvBtn = panel:GetChild("n25")
    lvBtn.onClick:Add(self.onClickTeamSite,self)

    --EVE 加成显示
    self.teamC2 = panel:GetController("c2")
end

function TeamView:teamSizeChange()
    local teamSize = cache.TeamCache:getTeamMemberNum() --获取队伍人数
    self.teamC2.selectedIndex = teamSize
end

function TeamView:nextStep(id)
    local index = 0
    if id then
        index = id - 1
    end
    self.c1.selectedIndex = index
    self:onController1()
end

function TeamView:setData(data)
    local selectedIndex = self.c1.selectedIndex
    if selectedIndex == 0 and data.msgId == 5300102 then--我的队伍
        self:updateMyData(data)
        self.minLvl = data.minLvl
        self.maxLvl = data.maxLvl
    elseif selectedIndex == 1 and data.msgId == 5300101 then--附近队伍
        self.nearbyPanel:setData(data)
    end

    self:teamSizeChange()
end

function TeamView:onController1()
    local selectedIndex = self.c1.selectedIndex
    if selectedIndex == 0 then--我的队伍
        proxy.TeamProxy:send(1300102)
    else--附近队伍
        local targetId = 1
        if self.siteData.targetId then
            targetId = self.siteData.targetId
        else
            local sceneData = conf.SceneConf:getSceneById(self.targetSceneId)
            targetId = sceneData and sceneData.team_target or 1
        end
        proxy.TeamProxy:send(1300101,{targetId = targetId})
    end
end

function TeamView:updateMyData(data)
    if self.jinlaiSceneId and cache.TeamCache:getIsCaptain(cache.PlayerCache:getRoleId()) then--有目标场景的
        local sceneData = conf.SceneConf:getSceneById(self.jinlaiSceneId)
        local team_target = sceneData and sceneData.team_target or 0
        self.jinlaiSceneId = nil
        if data.targetId > 0 and team_target ~= data.targetId then
            local confData = conf.TeamConf:getTeamConfig(team_target)
            local lvlSection = confData and confData.lv_section
            proxy.TeamProxy:send(1300114,{targetId = team_target,minLvl = lvlSection[1],maxLvl = lvlSection[2]})
            return
        else
            self:setTeamSite(data)
        end
    else
        self:setTeamSite(data)
    end
    self.autoAgreeApply = data and data.autoAgreeApply or 0
    self:setState()
    local teamMembers = cache.TeamCache:getTeamMembers()
    -- printt(teamMembers)
    for k,v in pairs(teamMembers) do
        self.roleList[k]:setRoleData(v)
    end
    if cache.TeamCache:getIsNotTeam() then
        self.createBtn.data = 1
        self.createBtn.icon = UIItemRes.team01
    else
        self.createBtn.data = 2
        self.createBtn.icon = UIItemRes.team02
    end
end
--我是队长时，自动接受其他人发出的申请
function TeamView:selelctCheck()
    proxy.TeamProxy:send(1300110,{reqType = 2})
end
--返回设置状态
function TeamView:updateState(data)
    self.autoAgreeApply = data.autoAgreeApply
    self:setState()
end

function TeamView:setState()
    if self.autoAgreeApply == 1 then
        self.checkBtn.selected = true
    else
        self.checkBtn.selected = false
    end
end
--创建队伍
function TeamView:onClickCreate(context)
    local lv = conf.SysConf:getValue("team_limit_lvl") or 0
    if cache.PlayerCache:getRoleLevel() < lv then
        GComAlter(string.format(language.team26, lv))
        return 
    end
    local cell = context.sender
    local index = cell.data
    if index == 1 then
        if GGetisOperationTeam() == Team.fubenType1 then
            GComAlter(language.team64)
        else
            if self.siteData.targetId then--创建队伍
                local level = cache.PlayerCache:getRoleLevel()
                if level < self.siteData.minLvl or level > self.siteData.maxLvl then
                    GComAlter(string.format(language.team55, self.siteData.minLvl.."-"..self.siteData.maxLvl))
                else
                    proxy.TeamProxy:send(1300104,self.siteData)
                end
            end
        end
    else--退出队伍
        if GGetisOperationTeam() == Team.fubenType2 then
            GComAlter(language.team63)
        else
            proxy.TeamProxy:send(1300107)
        end
    end
end
-- {sceneId = sceneId,self.minLv,maxLvl}  isSite是否设定
function TeamView:setTeamSite(siteData,isSite)
    local confData
    if cache.TeamCache:getTeamId() > 0 or isSite then
        self.siteData = siteData
        if siteData.targetId == 0 then
            siteData.targetId = 1
        end
        confData = conf.TeamConf:getTeamConfig(siteData.targetId)
        self.targetSceneId = confData.sceneid
        if confData.name then
            self.teamMbText.text = confData.name
            self.teamLvText.text = self.siteData.minLvl.."-"..self.siteData.maxLvl
        else
            self.teamMbText.text = "无"
            self.teamLvText.text = "无"
        end
        self.fightCdTime = 0
    else
        local sceneData = conf.SceneConf:getSceneById(self.targetSceneId)
        local targetId = sceneData and sceneData.team_target or 2
        confData = conf.TeamConf:getTeamConfig(targetId)
        self.siteData = {targetId = confData.id,minLvl = confData.lv_section[1],maxLvl = confData.lv_section[2]}
        self.teamMbText.text = confData.name
        self.teamLvText.text = self.siteData.minLvl.."-"..self.siteData.maxLvl
    end
    local isFuben = confData and confData.is_fuben or 0
    if isFuben == 1 and cache.TeamCache:getTeamId() > 0 then--可打副本的
        self.teamC1.selectedIndex = 1
        if cache.TeamCache:getIsCaptain(cache.PlayerCache:getRoleId()) then--队长才有操作权利
            self.fubenBtn.visible = true
            self.textSendGg.visible = true
        else
            self.fubenBtn.visible = false
            self.textSendGg.visible = false
        end
    else
        self.teamC1.selectedIndex = 0
    end
end

function TeamView:onClickSendGg()
    local time = conf.SysConf:getValue("team_hh_cd_time") or 0
    local cdTime = Time.getTime() - self.hhTime
    if cdTime < time then
        GComAlter(string.format(language.team69, math.floor(time - cdTime)))
        return
    end
    local confData = conf.ChatConf:getSysNotice(8005)
    if confData then
        local str = confData.content
        local sendMsg = cache.TeamCache:getTeamId().."="
        local teamConf = conf.TeamConf:getTeamConfig(self.siteData.targetId)
        local name = teamConf and teamConf.name or ""
        local minLvl,maxLvl = cache.TeamCache:getTeamLv()
        sendMsg = sendMsg..string.format(str, cache.PlayerCache:getRoleName(),name,minLvl.."-"..maxLvl)
        local params = {
            type = ChatType.fubenTeam,
            content = sendMsg,
            isVoice = 0,
            voiceStr = "",
            tarName = ""
        }
        proxy.ChatProxy:send(1060101,params)
        GComAlter(language.kuafu102)
        self.hhTime = Time.getTime()
    end
end
--开启战斗
function TeamView:onFightCall()
    local confData = conf.TeamConf:getTeamConfig(self.siteData.targetId)
    if not confData then return end
    local sceneId = confData.sceneid or 0
    if sceneId == 0 then return end
    local cdTime = confData.cd_time or 0--冷却时间
    if Time.getTime() - self.fightCdTime < cdTime then
        GComAlter(language.team66)
        return
    end
    local sceneConfig = conf.SceneConf:getSceneById(sceneId)
    local lvl = sceneConfig and sceneConfig.lvl or 1
    local playLv = cache.PlayerCache:getRoleLevel()
    if playLv < lvl then
        GComAlter(string.format(language.gonggong07, lvl))
        return
    end
    if self.siteData.targetId == conf.SysConf:getValue("dujie_team_tartget") then--渡劫
        sceneId = GGetDujieSceneId()
        if sceneId == 0 then
            GComAlter(language.xiuxian25)
            return
        else
            local fbConf = conf.FubenConf:getPassDatabyId(sceneId*1000+1)
            local roleLv = cache.PlayerCache:getRoleLevel()
            if fbConf.open_lv > roleLv then
                local str = language.xiuxian28[1]..fbConf.open_lv..language.xiuxian28[2]
                GComAlter(str)
                return
            end
        end
    end
    local num = cache.TeamCache:getTeamMemberNum()
    
    if self.siteData.targetId == conf.SysConf:getValue("marry_team_tartget") then--情緣
        if num == 2 then
            for k,v in pairs(cache.TeamCache:getTeamMembers()) do
                if v.captain ~= 1 then
                    if cache.PlayerCache:getCoupleName() ~= v.roleName then
                        GComAlter(language.team57)
                    else
                        proxy.MarryProxy:sendMsg(1027102)
                    end
                    return
                end
            end
        else
            GComAlter(language.team58)
            return
        end
    end
    if num < cache.TeamCache.maxTeamNum then
        local param = {}
        param.richText = language.team36
        param.okText = language.gonggong101
        param.cancelText = language.gonggong102
        param.sure = function()
            proxy.FubenProxy:send(1027305,{sceneId = sceneId,reqType = 1})
        end
        mgr.ViewMgr:openView2(ViewName.TeamWarTipView, param)
    else
        proxy.FubenProxy:send(1027305,{sceneId = sceneId,reqType = 1})
    end
    self.fightCdTime = Time.getTime()
end
--点击经验或者点击金钱
function TeamView:onClickExpAndMoney() --EVE 添加跳转Tips
    local view = mgr.ViewMgr:get(ViewName.TeamTipsView)
    if not view then 
        mgr.ViewMgr:openView2(ViewName.TeamTipsView, {})
    end 
end
--打开组队设定
function TeamView:onClickTeamSite()
    local lv = conf.SysConf:getValue("team_limit_lvl") or 0
    if cache.PlayerCache:getRoleLevel() < lv then
        GComAlter(string.format(language.gonggong07, lv))
        return 
    end
    if cache.TeamCache:getIsCaptain(cache.PlayerCache:getRoleId()) or cache.TeamCache:getTeamId() <= 0 then
        mgr.ViewMgr:openView2(ViewName.TeamSiteView, {targetId = self.siteData.targetId or 1})
    else
        GComAlter(language.team60)
    end
end

function TeamView:refOnlineState()
    for i=1,3 do
        local teamMembers = cache.TeamCache:getTeamMembers()
        self.roleList[i]:refOnlineState(teamMembers[i])
    end
end
--先清理所有模型
function TeamView:clearRole()
    for i=1,3 do
        self.roleList[i]:clear()
    end
end
--关闭时候所要清理的数据
function TeamView:clearEvent()
    self:clearRole()
end

function TeamView:onClickClose()
    self:closeView()
end

return TeamView