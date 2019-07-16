--
-- Author: ohf
-- Date: 2017-01-12 16:41:24
--
local ChatCache = class("ChatCache",base.BaseCache)
--[[

--]]
function ChatCache:init()
    self.chatData = {
        [1] = {},--普通；聊天
        [2] = {},--输入历史
    }
    self.systemData = {}--系统
    self.worldData = {}--世界
    self.hornData = {}--喇叭
    self.gangData = {}--仙盟
    self.privateData = {}--私聊
    self.teamData = {}--队伍
    self.friendData = {}--好友

    self.privateRoles = {}--私聊列表
    self.severOldTime = {}--服务器旧时间
    self.privateRoleData = {}--待请求的玩家
    self.sendPrivateRoles = {}--缓存已经请求的留言玩家
    self.privateCount = 0--记录私聊的次数
    self.sendChat = {}--缓存自己刚刚发的消息
end

function ChatCache:setData(data)
    data.content = mgr.TextMgr:splitStr(data.content,"")
    if string.trim(data.content) == "" then
        return
    end
    local len = #self.chatData[1]
    local chatData = data
    if len > ChatType.chatNum then 
        table.remove(self.chatData[1],1)
        table.insert(self.chatData[1], chatData)
    else
        table.insert(self.chatData[1], chatData)
    end
    if chatData.type == ChatType.system or chatData.type == ChatType.horseLamp or chatData.type == ChatType.boss or chatData.type == ChatType.kuafueTeam or chatData.type == ChatType.kuafuBoss or chatData.type == ChatType.sjzbSepc or chatData.type == ChatType.sjzbBoss or chatData.type == ChatType.sjzbCar or 
        chatData.type == ChatType.sjzbBossDead or chatData.type == ChatType.fubenTeam or chatData.type == ChatType.kuafuSystem  then--系统的
        local len = #self.systemData
        if len > ChatType.systemChannelNum then 
            table.remove(self.systemData,1)
            table.insert(self.systemData, chatData)
        else
            table.insert(self.systemData, chatData)
        end
    elseif chatData.type == ChatType.world or chatData.type == ChatType.gangRecruit or chatData.type == ChatType.near or chatData.type == ChatType.horn then--世界的（喇叭，仙盟招人）
        local len = #self.worldData
        if len > ChatType.worldChannelNum then 
            table.remove(self.worldData,1)
            table.insert(self.worldData, chatData)
        else
            table.insert(self.worldData, chatData)
        end
    elseif chatData.type == ChatType.private then--私聊的
        local len = #self.privateData
        if len > ChatType.priveteChannelNum then 
            table.remove(self.privateData,1)
            table.insert(self.privateData, chatData)
        else
            table.insert(self.privateData, chatData)
        end
    elseif chatData.type == ChatType.friend then--好友的
        local len = #self.friendData
        if len > ChatType.friendChannelNum then 
            table.remove(self.friendData,1)
            table.insert(self.friendData, chatData)
        else
            table.insert(self.friendData, chatData)
        end
    elseif chatData.type == ChatType.team then--队伍的
        local len = #self.teamData
        if len > ChatType.teamChannelNum then 
            table.remove(self.teamData,1)
            table.insert(self.teamData, chatData)
        else
            table.insert(self.teamData, chatData)
        end
    elseif chatData.type == ChatType.gang or chatData.type == ChatType.ganghelp or chatData.type == ChatType.gangHd or chatData.type == ChatType.gangWarehouse
        or chatData.type == ChatType.worldBossSystem or chatData.type == ChatType.xmshDice or chatData.type == ChatType.xmFlame then
        local len = #self.gangData
        if len > ChatType.gangChannelNum then 
            table.remove(self.gangData,1)
            table.insert(self.gangData, chatData)
        else
            table.insert(self.gangData, chatData)
        end
    end
end

function ChatCache:getEditDistance(lists,chatData)
    local len = #lists
    if len <= 0 then return 0 end
    local lastData = lists[len]
    if lastData.type == chatData.type and chatData.sendRoleId ~= cache.PlayerCache:getRoleId() then--同一个频道不是自己的玩家
        if chatData.sendRoleId == lastData.sendRoleId then--玩家roleid相同的
            return self:editDistance(lastData.content,chatData.content)
        end
    end
    return 0
end

function ChatCache:setHistoryData(str)
    local k = 0
    local lt = {}
    for i=1,2 do
        k = string.find(str, "|",k+1)
        if k == nil then break end
        table.insert(lt, k)
    end
    if #lt == 2 and lt[1] == 1 and lt[2] - lt[1] > 1 then--检测是否是骰子数
        local text = tonumber(string.sub(str,2,lt[2] - 1))
        if text and text <= 99 then
            return
        end
    end
    for k,v in pairs(self.chatData[2]) do
        if v == str then
            self.chatData[2][k] = str
            return
        end
    end
    local len = #self.chatData[2]
    if len >= ChatType.history then
        self.chatData[2][1] = nil
        table.insert(self.chatData[2], str)
    else
        table.insert(self.chatData[2], str)
    end
end
--主界面
function ChatCache:getChatData()
    return self:getLists(self.chatData[1])
end
--世界
function ChatCache:getWorldData()
    return self:getLists(self.worldData)
end
--设置仙盟互动
function ChatCache:setGangHd(index)
    if self.gangData[index] then
        self.gangData[index].hd = true
    end
end
--仙盟
function ChatCache:getGangData()
    return self:getLists(self.gangData)
end
--私聊
function ChatCache:getPrivateData()
    return self:getLists(self.privateData)
end
--重新设置私聊
function ChatCache:setPrivateData(chatUserList)
    local num = 0
    local privates = {}
    local tarPrivates = {}
    for k,v in pairs(self.privateData) do
        if self.privateRoleData.roleId == v.sendRoleId or self.privateRoleData.roleName == v.tarName then
            self.privateData[k] = nil
            table.insert(tarPrivates, v)
        else
            table.insert(privates, v)
        end
    end
    local lists = 1
    if #tarPrivates > #chatUserList then
        lists = tarPrivates
    else
        lists = chatUserList
    end
    self.privateData = privates
    for k,v in pairs(lists) do
        table.insert(self.privateData, v)
    end
end
--要私聊的那个人的id和名字
function ChatCache:setPrivateRoleData(data)
    self.privateRoleData = data
end

function ChatCache:getPrivateRoleData()
    return self.privateRoleData
end
--设置已经请求的留言玩家
function ChatCache:setSendPrivateRole(roleId)
    self.sendPrivateRoles[roleId] = 1
end

function ChatCache:getSendPrivateRole(roleId)
    return self.sendPrivateRoles[roleId]
end
--队伍
function ChatCache:geTeamData()
    return self:getLists(self.teamData)
end
--好友
function ChatCache:geFriendData()
    return self:getLists(self.friendData)
end
--自己刚刚发的消息
function ChatCache:setSendChat(type,chatData)
    self.sendChat[type] = chatData
end

function ChatCache:getSendChat(type)
    return self.sendChat[type]
end

function ChatCache:getLists(lists)
    local chatData = {}
    for k,v in pairs(lists) do
        if self:isShieldMsg(v.type) then
            if v.isVoice == 0 then
                table.insert(chatData, v)
            else
                if self:isShieldVoice(v.type) then
                    table.insert(chatData, v)
                end
            end
        end
    end
    return chatData
end

function ChatCache:getChatSystemData()
    return self.systemData
end
--文字
function ChatCache:isShieldMsg(type)
    local iType = clone(type)
    if iType == ChatType.ganghelp then
        iType = ChatType.gang
    elseif iType == ChatType.gangRecruit then
        iType = ChatType.world
    end
    local open = self:getChannel(iType)
    if open == 0 then
        return true
    end
end
--語音
function ChatCache:isShieldVoice(type)
    local iType = clone(type)
    if iType == ChatType.ganghelp then
        iType = ChatType.gang
    elseif iType == ChatType.gangRecruit then
        iType = ChatType.world
    end
    return true
end

function ChatCache:getHistoryData()
    return self.chatData[2]
end
--记录是否有新消息到来
function ChatCache:setNewMsg(chatType)
    self.refChatType = chatType
end

function ChatCache:getNewMsg()
    return self.refChatType
end
--聊天屏蔽
function ChatCache:setChannel(type,open)
    UPlayerPrefs.SetInt(type.."",open)
end
--0接收  1屏蔽
function ChatCache:getChannel(type)
    return UPlayerPrefs.GetInt(type.."")-- body
end
--聊天语音自动播放
function ChatCache:setVoiceChannel(type,open)
    UPlayerPrefs.SetInt(type.."P",open)
end
--0接收  1屏蔽
function ChatCache:getVoiceChannel(type)
    return UPlayerPrefs.GetInt(type.."P")-- body
end
--设置私聊列表
function ChatCache:setPrivateRole(roleData)
    self:addPrivateCount()
    local isNotFind = true
    for k,v in pairs(self.privateRoles) do
        if v and v.roleId == roleData.roleId then
            self.privateRoles[k] = roleData--找到了刚刚私聊的玩家
            self.privateRoles[k].count = self:getPrivateCount()
            isNotFind = false
            break
        end
    end
    if isNotFind then--没有找到
        roleData.count = self:getPrivateCount()
        table.insert(self.privateRoles, roleData)
    end
end
function ChatCache:getPrivateRole()
    table.sort(self.privateRoles,function(a,b)
        return a.count > b.count
    end)
    return self.privateRoles
end
--私聊计数器
function ChatCache:addPrivateCount()
    self.privateCount = self.privateCount + 1
end

function ChatCache:getPrivateCount()
    return self.privateCount or 1
end

function ChatCache:setOldSeverTime(chatId)
    self.severOldTime[chatId] = clone(mgr.NetMgr:getServerTime())
end

function ChatCache:getOldSeverTime(chatId)
    return self.severOldTime[chatId]
end
--喇叭发送标记
function ChatCache:setHornSend(isSend)
    self.isHornSend = isSend
end

function ChatCache:getHornSend(isSend)
   return self.isHornSend
end
--是不是领取附件
function ChatCache:setLinquFujian(isLinquFujian)
    self.isLinquFujian = isLinquFujian
end

function ChatCache:getLinquFujian()
    return self.isLinquFujian
end
--缓存点击的index
function ChatCache:setSelectedIndex(index)
    self.selectedIndex = index
end

function ChatCache:getSelectedIndex()
    return self.selectedIndex or 1
end
--记录播放过的语音
function ChatCache:setPlayAudioIndex(chatData,index)
    local chatList
    if chatData.type == ChatType.world or chatData.type == ChatType.near then--世界和附近的
        chatList = self.worldData
    elseif chatData.type == ChatType.private then--私聊的
        chatList = self.privateData
    elseif chatData.type == ChatType.friend then--好友的
        chatList = self.friendData
    elseif chatData.type == ChatType.team then--队伍的
        chatList = self.teamData
    elseif chatData.type == ChatType.gang then--仙盟的
        chatList = self.gangData
    end
    if chatList then
        for k,v in pairs(chatList) do
            if k == index and v.isVoice > 0 then
                chatList[k].isPlayedAudio = 1
            end
        end
    end
end

return ChatCache