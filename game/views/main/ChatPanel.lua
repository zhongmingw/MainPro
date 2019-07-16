--
-- Author: 
-- Date: 2017-09-15 20:48:00
--

local ChatPanel = class("ChatPanel",import("game.base.Ref"))

function ChatPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end
-- 
function ChatPanel:initPanel()
    self.textList = {}
    self.openChat = true
    self.view = self.mParent.view
    self.chatListView1 = self.view:GetChild("n218")
    -- self.chatListView1.touchable = false
    self.chatListView1:SetVirtual()
    self.chatListView1.itemRenderer = function(index,obj)
        self:cellChatData(index, obj)
    end
    self.chatListView1.numItems = 6 

    self.chatListView2 = self.view:GetChild("n219")
    -- self.chatListView2.touchable = false
    self.chatListView2:SetVirtual()
    self.chatListView2.itemRenderer = function(index,obj)
        self:cellChatData(index, obj)
    end
    self.chatListView2.numItems = 6

    self.chatBtn = self.view:GetChild("n223")
    self.chatBtnX = clone(self.chatBtn.x)
    self.chatBtnY = clone(self.chatBtn.y)

    self.chatTouch = self.view:GetChild("n360")
    self.chatTouch.data = 1 
    self.chatTouch.onClick:Add(self.onClickChatCount,self)
    
    self.chatC5 = self.view:GetController("c5")
    self:initChatPanel()
    self.chatSite = self.view:GetChild("n361")
    self.chatSite.onClick:Add(self.onClickChatSite,self)
end

--实时改变主界面聊天
function ChatPanel:updateChat()
    local chatType = cache.ChatCache:getNewMsg()
    if chatType then
        local view = mgr.ViewMgr:get(ViewName.ChatView)
        if view then
            view:setData(chatType)
        end
        self:setChatData()
        self:setNearChat()
        cache.ChatCache:setNewMsg(false)
    end
end

function ChatPanel:onClickItemChat()
    if self.openChat then
        local param = {id = 1011}
        GOpenView(param)
    end
    self.openChat = true
end

function ChatPanel:onClickChatSite()
    mgr.ViewMgr:openView(ViewName.SiteView,function(view)
        view:nextStep(2)
    end)
end

--点击聊天框箭头
function ChatPanel:onClickChatCount(context)
    local index = context.sender.data
    if index == 1 then
        self.chatC5.selectedIndex = 1
        context.sender.data = 2
        self.chatBtn.rotation = 180
    else
        self:initChatPanel()
        context.sender.data = 1
    end
    self.mParent.bubblePanel:setBtnPos()
    self:setChatData()
end

function ChatPanel:initChatPanel()
    self.chatC5.selectedIndex = 0
    self.chatBtn.rotation = 0
end

function ChatPanel:cellChatData(index,obj)
    local data = self.textList[index + 1]
    if data and data.type then
        local msgText = obj:GetChild("n0")
        local imgText = mgr.TextMgr:getImg(UIItemRes.chatType[data.type],36,18)
        local hert = "*"..data.sendRoleId.."*"..data.sendName.."*"..data.sendRoleIcon.."*"..data.sendRoleLev.."*"
        local str = ""
        local content = data.content
        local sendName = ""
        if data.sendName ~= "" then
            local sex = GGetMsgByRoleSex(data.sendRoleIcon)
            if (data.type >= ChatType.gang and data.type <= ChatType.ganghelp) or data.type == ChatType.gangWarehouse then--帮派聊天
                sendName = mgr.TextMgr:getTextColorStr(data.sendName.."("..language.gonggong28[sex]..")", 12)..mgr.TextMgr:getTextColorStr(language.chatSend9[data.gangJob], 14)..":"
            else
                sendName = mgr.TextMgr:getTextColorStr(data.sendName.."("..language.gonggong28[sex].."):", 12)
            end
        end
        if data.type == ChatType.boss then
            str = content..mgr.TextMgr:getHerfStr(language.chatSend8,7,1048)
        elseif data.type == ChatType.kuafueTeam then
            local i = string.find(content,"=")
            local msg = data.content
            local splitStr = string.split(msg,"=")
            local teamId = splitStr[1] or ""
            local hert = ChatHerts.KUAFUTEAM..teamId..ChatHerts.KUAFUTEAM
            local s = splitStr[2] or ""
            str = s..mgr.TextMgr:getTextColorStr(language.chatSend26, 7, hert)
        elseif data.type == ChatType.kuafuBoss then
            str = content..mgr.TextMgr:getHerfStr(language.chatSend8,7,1048)
        elseif data.type == ChatType.sjzbSepc then
            local splitStr = string.split(data.content,"=")
            local str1 = splitStr[1] or ""
            local xy = string.split(str1,",")
            local hert = ""
            if #xy == 2 then
                hert = ChatHerts.KUASEPC..xy[1]..ChatHerts.KUASEPC..xy[2]..ChatHerts.KUASEPC
            end
            str = splitStr[2] or ""
        elseif data.type == ChatType.gangRecruit then--帮派招聘喊话
            local i = string.find(content,"=")
            local id = string.sub(content,0,i - 1)
            local hert = ChatHerts.GANGHERT..id..ChatHerts.GANGHERT
            str = mgr.ChatMgr:getSendText(string.sub(content,i + 1),data.sendRoleId)..mgr.TextMgr:getTextColorStr(language.chatSend5, 10, hert)
        elseif data.type == ChatType.ganghelp then--帮派求助
            local k = 0
            local lt = {}
            for i=1,2 do
                k = string.find(content, "=",k+1)
                if k == nil then break end
                table.insert(lt, k)
            end
            local roleId  = string.sub(content,1,lt[1] - 1)
            local boxIndex = string.sub(content,lt[1] + 1,lt[2] - 1)
            local hert = ChatHerts.GANGHELPHERT..roleId ..ChatHerts.GANGHELPHERT..boxIndex..ChatHerts.GANGHELPHERT
            str = mgr.ChatMgr:getSendText(string.sub(content,lt[2] + 1),data.sendRoleId)..mgr.TextMgr:getTextColorStr(language.chatSend8, 10, hert)
        elseif data.type == ChatType.fubenTeam then--副本组队公告
            local splitStr = string.split(data.content,"=")
            if #splitStr == 2 then
                hert = ChatHerts.SYSTEMTEAM..splitStr[1]..ChatHerts.SYSTEMTEAM
            end
            local str2 = splitStr[2] or ""
            str = str2..mgr.TextMgr:getTextColorStr(language.chatSend26, 7, hert)
        elseif data.type == ChatType.worldBossSystem then--世界boss仙盟招募
            local splitStr = string.split(data.content,"=")
            local hert = ""
            if #splitStr == 2 then
                local strPex = splitStr[1]
                local strTab = string.split(strPex,",")
                if #strTab == 2 then
                    hert = ChatHerts.SYSTEWORLDBOSS..strTab[1]..ChatHerts.SYSTEWORLDBOSS..strTab[2]..ChatHerts.SYSTEWORLDBOSS
                end
            end
            local str2 = splitStr[2] or ""
            str = str2..mgr.TextMgr:getTextColorStr(language.chatSend29, 7, hert)
        else
            str = mgr.ChatMgr:getSendText(content,data.sendRoleId)
        end
        if data.type == ChatType.system or data.type == ChatType.horseLamp or data.type == ChatType.sjzbBossDead or data.type == ChatType.kuafuSystem then--bxp 增加跨服系统
            msgText.text = imgText..string.trim(content)
        elseif data.type == ChatType.gangHd then
            msgText.text = imgText..string.trim(content)
        elseif data.type == ChatType.xmshDice then--仙盟圣火的骰子数
            msgText.text = imgText .. mgr.ChatMgr:getXmshDice(content)
        elseif data.type == ChatType.xmFlame then--仙盟圣火添柴
            msgText.text = imgText .. content
        elseif data.type == ChatType.fubenTeam then
            msgText.text = imgText..str
        else
            msgText.text = imgText..sendName..string.trim(str)
        end
        msgText.onClickLink:Add(self.onClickLink,self)--部分超链接系统广播
        msgText.onClick:Add(self.onClickItemChat,self)
    end
    local touch = obj:GetChild("n1")
    touch.onClick:Add(self.onClickItemChat,self)
end

function ChatPanel:onClickLink(context)
    self.openChat = false
    local str = string.sub(context.data, 1,1)
    local petstr = string.split(context.data,"=")
    if petstr and #petstr >=2 and petstr[1] == ChatHerts.PETHERTCHAT then
        mgr.ChatMgr:onClickTextSee(context.data)
    else
        if str == ChatHerts.PROINFOHERT then--道具查看
            mgr.ChatMgr:onClickLink(context.data)--先屏蔽
        elseif str == ChatHerts.GANGHERT then--帮主喊话超链接
            mgr.ChatMgr:onClickLink3(context.data)
        elseif str == ChatHerts.GANGHELPHERT then--帮派求助
            mgr.ChatMgr:onClickLink4(context.data)
        elseif str == ChatHerts.POSHERT then
            mgr.ChatMgr:onClickLink5(context.data)
        elseif str == ChatHerts.KUAFUTEAM then
            mgr.ChatMgr:onClickLink6(context.data)
        elseif str == ChatHerts.KUASEPC then
            mgr.ChatMgr:onClickLink7(context.data)
        elseif str == ChatHerts.SYSTEMPRO then--系统道具
            mgr.ChatMgr:onLinkSystemPros(context.data)
        elseif str == ChatHerts.SYSTEMTEAM then--副本喊话公告
            mgr.ChatMgr:onLinkSystemTeam(context.data)
        elseif str == ChatHerts.SYSTEWORLDBOSS then--boss招募
            mgr.ChatMgr:onLinkBossZmSystem(context.data)
        -- elseif str == "1" then --宠物
        --     mgr.ChatMgr:onClickTextSee(context.data)
        else
            mgr.ChatMgr:onClickLinkGo(context.data)
        end
    end
end

function ChatPanel:setChatData()
    local data = cache.ChatCache:getChatData()
    local len = #data
    local textList = {}
    textList[6] = data[len] or {}
    textList[5] = data[len - 1] or {}
    textList[4] = data[len - 2] or {}
    textList[3] = data[len - 3] or {}
    textList[2] = data[len - 4] or {}
    textList[1] = data[len - 5] or {}
    self.textList = textList
    local len = #textList
    if self.chatC5.selectedIndex == 0 then
        self.chatListView1.numItems = len
        self.chatListView1:ScrollToView(len - 1,false,true)
    elseif self.chatC5.selectedIndex == 1 then
        self.chatListView2.numItems = len
        self.chatListView2:ScrollToView(len - 1,false,true)
    end
end
--附近聊天
function ChatPanel:setNearChat()
    local chatData = cache.ChatCache:getChatData()
    local data = chatData[#chatData]
    if data and data.type == ChatType.near then--判断最新一条是不是附近聊天
        local roleId = data.sendRoleId 
        if roleId == gRole:getID() then
            gRole:setChatData(mgr.ChatMgr:getSendText(data.content,roleId))
        else
            local player = mgr.ThingMgr:getObj(ThingType.player, roleId)
            if player then
                player:setChatData(mgr.ChatMgr:getSendText(data.content,roleId))
            end
        end
    end
end

return ChatPanel