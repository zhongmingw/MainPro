--
-- Author: 
-- Date: 2017-01-12 16:31:33
--

local ChatProxy = class("ChatProxy",base.BaseProxy)

function ChatProxy:init()
    self:add(5060101,self.add5060101)
    self:add(5060103,self.add5060103)--请求私聊玩家列表（仅登录时请求）
    self:add(5060104,self.add5060104)--请求玩家聊天记录（只请求登录留言没请求过的）
    self:add(5080101,self.add5080101)--返回邮件列表
    self:add(5080102,self.add5080102)--返回标记&领取邮件
    self:add(8030104,self.add8030104)--聊天信息
end

function ChatProxy:add5060101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JiYiHuaDengView)
        if view then
            view:refreshSendCD()
        end
    elseif data.status == 2203034 then
        local confData = conf.ChatConf:getAgentChatById(g_var.channelId)
        print("聊天维护>>>>>>>>>>>>>>>>>>",g_var.channelId,confData)
        if confData then
            GComAlter(confData.dec)
        else
            GComErrorMsg(data.status)
        end
    else
        GComErrorMsg(data.status)
    end 
end
--请求私聊玩家列表（仅登录时请求）
function ChatProxy:add5060103(data)
    if data.status == 0 then
        local readRoles = {}--未读玩家
        for k,v in pairs(data.chatUserList) do
            local roleData = {roleIcon = v.RoleIcon,roleId = v.roleId,roleName = v.roleName,level = v.RoleLev,relation = v.relation,readFlag = v.readFlag}
            if v.readFlag == 1 and #readRoles >= 2 then
                table.insert(readRoles, roleData)
            end
            cache.ChatCache:setPrivateRole(roleData)
        end
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            for k,v in pairs(readRoles) do
                view:setPrivateChat(v)
            end
        end
    else
        GComErrorMsg(data.status)
    end 
end
--请求玩家聊天记录（只请求登录留言没请求过的）
function ChatProxy:add5060104(data)
    if data.status == 0 then
        --printt(data.chatInfoList,"@@@@@@@@")
        --cache.ChatCache:setPrivateData(data.chatInfoList)--聊天记录 array
        local roleData = cache.ChatCache:getPrivateRoleData()
        local view = mgr.ViewMgr:get(ViewName.ChatView)
        if view then
            view:setTarName(roleData)
        end
        cache.ChatCache:setSendPrivateRole(roleData.roleId)
    else
        GComErrorMsg(data.status)
    end 
end
--聊天信息
function ChatProxy:add8030104(data)
    if data.status == 0 then
      
        if data.type == ChatType.horseLamp then--跑马灯的不显示在系统里面
            local params = {textData = data, type = 3}
            GComAlter(params)
        else
            if data.type == ChatType.horn then--喇叭
                local params = {textData = data, type = 12,speed = 5}
                GComAlter(params)
                local view = mgr.ViewMgr:get(ViewName.ChatHornView)
                if view then
                    view:successData()
                end
                if cache.ChatCache:getHornSend() then
                    cache.ChatCache:setOldSeverTime(8)
                end
                cache.ChatCache:setHornSend(false)
            end
            if data.type == ChatType.private then
                local roleData = {roleId = data.sendRoleId, roleIcon = data.sendRoleIcon,roleName = data.sendName,level = data.sendRoleLev,relation = data.relation}
                local view = mgr.ViewMgr:get(ViewName.MainView)
                if view then
                    view:setPrivateChat(roleData) --主界面的私聊
                end
                if roleData.roleId ~= cache.PlayerCache:getRoleId() then--有人发消息
                    cache.ChatCache:setPrivateRole(roleData)--设置私聊列表
                end
            end
             --记忆饺宴（活动）
            if data.type == ChatType.jiyiDanMu then
                local view = mgr.ViewMgr:get(ViewName.JiYiHuaDengView)
                if view  then
                    local str = mgr.ChatMgr:getSendText(data.content,data.sendRoleId)
                    local info = {text= str}
                    local isOpen = cache.ActivityCache:getDanMuOpen()
                    if isOpen then
                        mgr.TipsMgr:addDanMuTip(info)
                    end
                end
                return
            end
            if data.sendRoleId == cache.PlayerCache:getRoleId() then
                cache.ChatCache:setSendChat(data.type,data)--缓存刚刚发出去的消息
            end
            cache.ChatCache:setData(data)
            
            local iChannel = mgr.ChatMgr:getChooseChannel(data.type)--最新要刷新的频道
            if not cache.ChatCache:getNewMsg() then--没有在刷新的时候
                cache.ChatCache:setNewMsg(iChannel)
            end
            --仙盟有新消息时 主界面仙盟聊天按钮刷新红点
            if data.type == ChatType.gang then
                local chatview = mgr.ViewMgr:get(ViewName.JiYJiaoYanView)
                local view = mgr.ViewMgr:get(ViewName.JiYJiaoYanView)
                if view and not chatview then
                    view:setGangChatBtnRed(true)
                end
                if chatview then
                    chatview:setGangChatBtnRed()
                end
            end
           
        end
    else
        GComErrorMsg(data.status)
    end 
end

--返回邮件列表
function ChatProxy:add5080101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ChatView)
        if view then 
            view:refreshMail(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end
--返回标记&领取邮件1:领取,2一键领取附件邮件,3删除单个,4一键删除已读
function ChatProxy:add5080102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ChatView)
        if view then 
            view:receiveMail(data)
        end
        local reqType = data.reqType
        if reqType == 1 then
            if cache.ChatCache:getLinquFujian() then
                GComAlter(language.mail06)
            end
        elseif reqType == 2 then
            GComAlter(language.mail07)
        elseif reqType == 3 then
            GComAlter(language.mail08)
        elseif reqType == 4 then
            GComAlter(language.mail09)
        end
        cache.ChatCache:setLinquFujian(nil)
    else
        GComErrorMsg(data.status)
    end 
end

return ChatProxy