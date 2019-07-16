--
-- Author: 
-- Date: 2017-01-16 10:59:44
--

local FriendTips = class("FriendTips", base.BaseView)

--EVE 注释原因：将玩家信息移动到头像下以后，背景框需要加长。因此原背景框尺寸不适用
-- local y1 = {377,394}--两个框的高度大小1
-- local y2 = {465,483}--两个框的高度大小3
local y1 = {474,491}--两个框的高度大小1
local y2 = {564,583}--两个框的高度大小3

local teamType1 = 1--邀请入队
local teamType2 = 2--申请入队
local teamType3 = 3--退出队伍

function FriendTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.uiClear = UICacheType.cacheTime
end

function FriendTips:initView()
    self.groupObj = self.view:GetChild("n15")
    self.panel1 = self.view:GetChild("n2")--底框
    self.panel1.height = y1[2]
    self.panel2 = self.view:GetChild("n5")--白底框
    self.panel2.height = y1[1]
    self.imgRoleIcon = self.view:GetChild("n6")

    self.roleName = self.view:GetChild("n7")
    self.roleName.text = ""
    --公会
    self.roleGname = self.view:GetChild("n9")
    self.roleGname.text = ""
    --
    self.btnlist = {}
    --查看信息
    local btnSee = self.view:GetChild("n10")
    if not g_ios_test then  --EVE 屏蔽查看玩家信息
        btnSee:GetChild("title").text = language.friend13
        btnSee.onClick:Add(self.onBtnSee,self)
        table.insert(self.btnlist,btnSee)
    else 
        btnSee:SetScale(0,0)
    end
    --聊天
    local btnChat = self.view:GetChild("n11")
    btnChat:GetChild("title").text = language.friend14
    btnChat.onClick:Add(self.onBtnChat,self)
    table.insert(self.btnlist,btnChat)
    --送花
    local btnSongHua = self.view:GetChild("n19")
    btnSongHua:GetChild("title").text = language.friend41
    btnSongHua.onClick:Add(self.onBtnSonghua,self)
    table.insert(self.btnlist,btnSongHua)
    --邀请入盟
    local btnXianmeng = self.view:GetChild("n20")
    btnXianmeng:GetChild("title").text = language.friend43
    btnXianmeng.onClick:Add(self.onBtnRumeng,self)
    table.insert(self.btnlist,btnXianmeng)
    --邀请加入队伍
    self.teamBtn1 = self.view:GetChild("n12")--邀请入队按钮
    self.teamText1 = self.teamBtn1:GetChild("title")
    self.teamText1.text = language.friend15
    self.teamBtn1.onClick:Add(self.onClickTeam1,self)
    table.insert(self.btnlist,self.teamBtn1)
    --删除好友
    local btntDeleteFriend = self.view:GetChild("n13")
    btntDeleteFriend:GetChild("title").text = language.friend16
    btntDeleteFriend.onClick:Add(self.onBtnDelete,self)
    self.btntDeleteFriend = btntDeleteFriend
    table.insert(self.btnlist,btntDeleteFriend)
    --黑名单
    local btnHeiMingDan = self.view:GetChild("n14")
    btnHeiMingDan:GetChild("title").text = language.friend17
    btnHeiMingDan.onClick:Add(self.onBtnHeiMingDan,self)
    table.insert(self.btnlist,btnHeiMingDan)
    --交易
    local btnTrade = self.view:GetChild("n16")
    btnTrade:GetChild("title").text = language.trade02 
    btnTrade.onClick:Add(self.onTrade,self)
    self.btnTrade = btnTrade
    table.insert(self.btnlist,btnTrade)

    local btnClose = self.view:GetChild("n3")
    btnClose.onClick:Add(self.onCloseView,self)
    --转移队长
    self.teamBtn2 = self.view:GetChild("n17")--转移队长按钮
    self.teamText2 = self.teamBtn2:GetChild("title")
    self.teamText2.text = language.friend34
    table.insert(self.btnlist,self.teamBtn2)
    self.teamBtn2.onClick:Add(self.onClickTeam2,self)
    --提出队伍
    self.teamBtn3 = self.view:GetChild("n18")--踢出队伍按钮
    self.teamText3 = self.teamBtn3:GetChild("title")
    self.teamText3.text = language.friend36
    table.insert(self.btnlist,self.teamBtn3)
    self.teamBtn3.onClick:Add(self.onClickTeam3,self)
end

function FriendTips:isOnlySee()
    -- body
    -- local str = cache.PlayerCache:getRoleName()
    -- local s1 = string.split(str,".")
    -- local s2 = string.split(self.data.roleName,".")
    --plog("主服id",self.data.mainSvrId, cache.PlayerCache:getServerId())
    
    
    if not self.data.mainSvrId or self.data.mainSvrId == 0 then--避免一些没有传的情况 默认为本服
        return false
    elseif self.data.mainSvrId ~= cache.PlayerCache:getServerId() then
        return true  
    end
    -- if #s1 == 2 and #s2 == 2 then
    --     if s1[1] == s2[1] then
    --         return false
    --     else
    --         return true
    --     end
    -- end
    return false
end

function FriendTips:setData(data_)
    self.data = data_ 
    if not self.data.mainSvrId then
        self.data.mainSvrId = data_.svrId or 0
    end
    self.roleName.text = data_.roleName or ""

    local t = { level = data_.level , roleIcon = data_.roleIcon,roleId = data_.roleId }
    GBtnGongGongSuCai_050(self.imgRoleIcon,t)

    self.groupObj.x = 304
    self.groupObj.y = 20
    if self.data.pos then
        local iX = self.groupObj.x
        local iY = self.groupObj.y
        self.groupObj:SetXY(iX + self.data.pos.x, iY + self.data.pos.y)
    end
    self.btnTrade.visible = false
    if self.data.heiming or self.data.chouren or self.data.friend then
        self.btntDeleteFriend:GetChild("title").text = language.friend30
    end
    -- if self.data.trade then
    --     self.btnTrade.visible = self.data.trade
    -- end

    self.teamBtn1.data = {data = self.data,index = 0}
    self.teamBtn2.data = self.data
    self.teamBtn3.data = self.data
    self:judgeTeam()

    if self:isOnlySee() then
        for k ,v in pairs(self.btnlist) do
            if k > 1 then
                v.visible = false
            end
        end
    else
        proxy.PlayerProxy:send(1020206,{tarRoleId = self.data.roleId})
        for k ,v in pairs(self.btnlist) do
            if k < #self.btnlist - 1 and v.name ~= "n16" then
                v.visible = true
            end
        end
        --self.btnTrade.visible = false
    end
end

--EVE 显示玩家仙盟归属
function FriendTips:gangItem(data)
    -- printt(data)
    local gangName = data.userInfo.gangName
    -- plog(gangName .. "~~~~~~~~~~~~~~~~~~~~~~~~~~~", type(gangName))

    if not gangName or gangName == "" then
        self.roleGname.text = language.friend38
        -- plog(language.friend38)
    else    
        self.roleGname.text = gangName
    end
end

--判断组队情况
function FriendTips:judgeTeam()
    local teamId = self.data.teamId
    local teamCaptain = self.data.teamCaptain
    local captain = self.data.captain
    self.teamBtn2.visible = false
    self.teamBtn3.visible = false
    self.panel1.height = y1[2]
    self.panel2.height = y1[1]
    if teamId and teamId > 0 then
        if teamCaptain then
            if cache.TeamCache:getTeamId() <= 0 then
                self.teamBtn1.enabled = true
                self.teamBtn1.data.index = teamType2
                self.teamText1.text = language.friend33
            else
                self.teamBtn1.enabled = false
                self.teamText1.text = language.friend15
            end
        end
        if captain then--组队界面点击的时候
            if captain == 1 then--点击队伍队长
                self.teamBtn1.enabled = false
                self.teamText1.text = language.friend15
            else
                local roleId = cache.PlayerCache:getRoleId()
                local isCaptain = cache.TeamCache:getIsCaptain(roleId)
                if isCaptain then--如果我是队长
                    self.teamBtn1.enabled = false
                    self.teamText1.text = language.friend15
                    self.teamBtn2.visible = true
                    self.teamBtn3.visible = true
                    self.panel1.height = y2[2]
                    self.groupObj.y = 20
                    self.panel2.height = y2[1]
                else
                    self.teamBtn1.enabled = false
                    self.teamText1.text = language.friend15
                end
            end
        end
    else
        self.teamBtn1.enabled = true
        self.teamBtn1.data.index = teamType1
        self.teamText1.text = language.friend15
    end
end

function FriendTips:onBtnSee(context)
    -- body
    local param = {}
    param.roleId = self.data.roleId
    param.svrId = self.data.mainSvrId or 0
    --printt(param)
    GSeePlayerInfo(param)
end



function FriendTips:onBtnChat()
    if self.data.roleId == cache.PlayerCache:getRoleId() then
        GComAlter(language.chatSend4)
        return
    end
    local confData = conf.ChatConf:getChatData(7)
    local openlv = confData and confData.open_lv or 1
    local level = self.data and self.data.level or 1
    local chatName = confData and confData.name or ""
    local chatVipLv = conf.SysConf:getValue("vip_not_limit_chat")
    -- if G_AgentChatLimit() then
    --     local LimitData = conf.ChatConf:getAgentChatById(g_var.channelId)
    --     local limitLv = 0
    --     for k,v in pairs(LimitData.open_lev) do
    --         if confData.type == v[1] then
    --             limitLv = v[2]
    --             break
    --         end
    --     end
    --     if cache.PlayerCache:getRoleLevel() < limitLv and cache.PlayerCache:getVipLv() < chatVipLv then
    --         GComAlter(string.format(language.chatSend16, chatName,limitLv))
    --         return
    --     end
    -- elseif (cache.PlayerCache:getRoleLevel() < openlv) and cache.PlayerCache:getVipLv() < chatVipLv then
    --     GComAlter(string.format(language.chatSend16, chatName,openlv))
    --     return
    -- end
    local data  = {roleIcon = self.data.roleIcon,roleId = self.data.roleId,roleName = self.data.roleName,level = self.data.level,relation = self.data.relation}
    local param = {id = 1011,roleData = data}
    GOpenView(param)
    self:onCloseView()
    local view = mgr.ViewMgr:get(ViewName.FriendView)
    if view then
        view:closeView()
    end
end
--删除好友
function FriendTips:onBtnDelete()
    if self.data.heiming then
        GComAlter(language.friend31)
        return
    end
    local t 
    if self.data.chouren or self.data.friend then
        t = clone(language.friend32)
    else
        t = clone(language.friend18)
    end
    t[2].text = string.format(t[2].text,self.data.roleName or "")

    local data = {}
    data.type = 2 
    data.richtext = mgr.TextMgr:getTextByTable(t)
    data.sure = function()
        -- body
        local param = {}
        param.reqType = (self.data.chouren or self.data.friend) and 1 or 2 
        param.roleIds = {}
        table.insert(param.roleIds,self.data.roleId)

        --printt("1070103",param)

        proxy.FriendProxy:sendMsg(1070103,param)
    end

    data.cancel = function ()
        -- body
    end
    GComAlter(data) 
end
--黑名单
function FriendTips:onBtnHeiMingDan()
    -- body
     local t = clone(language.friend19)
    t[2].text = string.format(t[2].text,self.data.roleName or "")

    local data = {}
    data.type = 2 
    data.richtext = mgr.TextMgr:getTextByTable(t)
    data.sure = function(  )
        -- body
        local param = {}
        param.reqType = 1 
        param.roleId =  self.data.roleId
        proxy.FriendProxy:send(1070202,param)
    end

    data.cancel = function ()
        -- body
    end
    GComAlter(data)  
end
--交易
function FriendTips:onTrade()
    -- body
    local var = conf.SysConf:getValue("player_trade_lev")
    if cache.PlayerCache:getRoleLevel()< var then --自己等级不足
        GComAlter(string.format(language.trade15,var)) 
        return
    elseif self.data.level < var then --对方等级不足
        GComAlter(string.format(language.trade16,var))
        return
    elseif cache.TradeCache:getrequestTrade()> 0 then --在等待别人回复
        GComAlter(language.trade17)
        return
    end

    local param = {}
    param.inviteRoleId = self.data.roleId
    proxy.TradeProxy:send(1260201,param)
    ---发送交易请求
    -- mgr.ViewMgr:openView(ViewName.TradeMainView,function(view)
    --     -- body
    --     view:setData()
    -- end)
    self:onCloseView()
end

function FriendTips:onClickTeam1(context)
    if GGetisOperationTeam() == Team.fubenType1 then
        GComAlter(language.team64)
        return
    end
    local lv = conf.SysConf:getValue("team_limit_lvl") or 0
    if cache.PlayerCache:getRoleLevel() < lv then
        GComAlter(string.format(language.gonggong07, lv))
        return 
    end
    local cell = context.sender
    local data = cell.data.data
    local index = cell.data.index
    if index == teamType1 then--邀请入队
        local minLv,maxLv = cache.TeamCache:getTeamLv()
        if cache.TeamCache:getTeamId() > 0 and (data.level < minLv or data.level > maxLv) then
            GComAlter(language.team53)
        else
            proxy.TeamProxy:send(1300105,{tarRoleId = data.roleId})
        end
    elseif index == teamType2 then--申请入队
        proxy.TeamProxy:send(1300111,{teamId = data.teamId})
    elseif index == teamType3 then--退出队伍
        proxy.TeamProxy:send(1300107)
    end
    self:onCloseView()
end
--转移队长
function FriendTips:onClickTeam2(context)
    local cell = context.sender
    local data = cell.data
    proxy.TeamProxy:send(1300109,{tarRoleId = data.roleId})
    self:onCloseView()
end
--踢出队伍
function FriendTips:onClickTeam3(context)
    local cell = context.sender
    local data = cell.data
    proxy.TeamProxy:send(1300108,{tarRoleId = data.roleId})
    self:onCloseView()
end

function FriendTips:onCloseView()
    -- body
    self:closeView()
end

function FriendTips:onBtnSonghua()
    -- body
    if not self.data then
        return
    elseif not self.data.relation then
        return
    end

    if self.data.relation == 0 then
        GComAlter(language.friend42)
    else
        local data = {roleId = self.data.roleId,roleName = self.data.roleName}
        mgr.ViewMgr:openView2(ViewName.MarrySongHuaView,data)
    end
end

function FriendTips:onBtnRumeng()
    -- body
    if not self.data or not self.data.gangName then
        return
    end
    if self.data.gangName ~= "" then
        GComAlter(language.friend44)
        return
    end
    if cache.PlayerCache:getGangId() == "0" then
        GComAlter(language.friend45)
        return
    end
    local job = cache.PlayerCache:getGangJob()
    if job < 2 then
        GComAlter(language.friend46)
        return
    end

    --发送邀请
    proxy.BangPaiProxy:sendMsg(1250406,{tarRoleId = self.data.roleId})
    self:closeView()
end

function FriendTips:add5020206( data )
    -- body
    self.data.gangName = data.userInfo.gangName
    self.data.level = data.userInfo.level
    self.data.roleIcon = data.userInfo.roleIcon
    self.data.teamId = data.userInfo.teamId
    self.data.teamCaptain = data.userInfo.teamCaptain
    self.data.relation = data.userInfo.relation
    self.data.isJy = data.userInfo.isJy
    self.data.mainSvrId = data.userInfo.mainSvrId

    --BUG #6405 跨服精英boss:跨服里点击其他玩家信息，只显示【查看信息】这个项，其他选项隐藏
    if self:isOnlySee() then
        for k ,v in pairs(self.btnlist) do
            if k > 1 then
                v.visible = false
            end
        end
    else
        for k ,v in pairs(self.btnlist) do
            if k < #self.btnlist - 1 and v.name ~="n16" then
                v.visible = true
            end
        end
        local t = { level = self.data.level , roleIcon = self.data.roleIcon, roleId = self.data.roleId }
        GBtnGongGongSuCai_050(self.imgRoleIcon,t)
    end
    if data.userInfo.relation == 1 then
        self.data.friend = false
        self.btntDeleteFriend:GetChild("title").text = language.friend16
    else
        self.data.friend = true
        self.btntDeleteFriend:GetChild("title").text = language.friend30
    end
    
    if self.data.isJy == 1 then
        self.btnlist[2].enabled = false
    else
        self.btnlist[2].enabled = true
    end
    --printt(data.userInfo)
    if self.data.gangName ~= "" then
        self.btnlist[4].enabled = false
    else
        self.btnlist[4].enabled = true
    end
    self.teamBtn1.data = {data = self.data,index = 0}
    self.teamBtn2.data = self.data
    self.teamBtn3.data = self.data
    self:judgeTeam()
end

return FriendTips