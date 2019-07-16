--
-- Author: 
-- Date: 2017-04-07 18:48:57
--
local ChatConf = class("ChatConf",base.BaseConf)

function ChatConf:init()
    self:addConf("chat_config")--聊天冷却
    self:addConf("chat_bubble")--聊天个性冒泡
    self:addConf("gang_hd_speak")--仙盟互动
    self:addConf("sys_notice")--系统广播
    self:addConf("agent_chat_limit")--平台聊天维护
end

function ChatConf:getSysNotice(id)
    return self.sys_notice[tostring(id)]
end
--聊天开启等级和cd时间
function ChatConf:getChatData(id)
    return self.chat_config[tostring(id)]
end

function ChatConf:getChatBubble()
    local data = {}
    for k,v in pairs(self.chat_bubble) do
        table.insert(data, v)
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end
--个性
function ChatConf:getChatBubbleData(id)
    return self.chat_bubble[tostring(id)]
end

function ChatConf:getGangHDSpeak(id)
    return self.gang_hd_speak[tostring(id)]
end

function ChatConf:getAgentChatById(id)
    local data = nil
    for k,v in pairs(self.agent_chat_limit) do
        if v.id == id then
            data = v
        end
    end
    return data
end

return ChatConf