--
-- Author: 
-- Date: 2017-06-23 10:26:44
--

local ChatVoice = class("ChatVoice",import("game.base.Ref"))

local world = 2
local gang = 4

function ChatVoice:ctor(mParent)
    self.mParent = mParent
    self.chatType = ChatType.world
    self:initPanel()
end
-- 
function ChatVoice:initPanel()
    self.evtY = 0
    self.view = self.mParent.view
    self.worldBtn = self.view:GetChild("n221")--世界语音按钮
    self.worldBtn:RemoveEventListeners()
    self.worldBtn.onTouchBegin:Add(self.onWorldBegin,self)
    self.worldBtn.onTouchEnd:Add(self.onWorldEnd,self)
    -- self.gangBtn = self.view:GetChild("n222")--仙盟语音按钮
    -- self.gangBtn:RemoveEventListeners()
    -- self.gangBtn.onTouchBegin:Add(self.onGangBegin,self)
    -- self.gangBtn.onTouchEnd:Add(self.onGangEnd,self)
end

function ChatVoice:createVoiceTip()
    if not self.tipVoice then
        self.tipVoice = UIPackage.CreateObject("main" , "VoicePanel")
        self.view:AddChildAt(self.tipVoice,self.view.numChildren)
        self.tipVoice:Center()
    end
end
--世界频道按下
function ChatVoice:onWorldBegin(context)
    local evt = context.data
    self.evtY = evt.y
    self.chatType = ChatType.world
    self:onVoiceBegin()
    Stage.inst.onTouchMove:Add(self.onTouchMove,self)
end

function ChatVoice:onWorldEnd(context)
    local evt = context.data
    self:onVoiceEnd(evt.y)
end
--仙盟频道按下
function ChatVoice:onGangBegin(context)
    local evt = context.data
    self.evtY = evt.y
    self.chatType = ChatType.gang
    self:onVoiceBegin()
    Stage.inst.onTouchMove:Add(self.onTouchMove,self)
end

function ChatVoice:onGangEnd(context)
    local evt = context.data
    self:onVoiceEnd(evt.y)
end
--开始按下
function ChatVoice:onVoiceBegin()
    local gangId = tonumber(cache.PlayerCache:getGangId())
    if self.chatType == ChatType.gang and gangId <= 0 then
        GComAlter(language.redbag12)
        return
    end
    if self:isNotSendLv() then--等级不足
        return
    end
    self:createVoiceTip()
    if self.tipVoice then
        self.effect = self.tipVoice:GetChild("n2")
        self.effect.url = UIPackage.GetItemURL("_movie","MovieChat")
    end
    self.beginTime = 1
    self.touchTimer = self.mParent:addTimer(1, -1, function( ... )
        if self.beginTime >= 8 then
            self.beginTime = 8
            self:removeVoice()
        else
            self.beginTime = self.beginTime + 1
        end
    end)
    self:releaseVoiceTimer()
    self.isVoiceSend = nil
    local function func(data)
        self:sendVoice(data)
    end 
    mgr.SDKMgr:recordAudio(1,func)
end

function ChatVoice:onTouchMove(context)
    local evt = context.data
    local y = math.abs(self.evtY - evt.y)
    if not self.tipVoice then return end
    local tip1 = self.tipVoice:GetChild("n0")
    local tip2 = self.tipVoice:GetChild("n1")
    if y >= 30 then
        tip1.visible = false
        self.effect.visible = false
        tip2.visible = true
    else
        tip1.visible = true
        self.effect.visible = true
        tip2.visible = false
    end
end
--销毁语音
function ChatVoice:removeVoice()
    if self.tipVoice then 
        self.tipVoice:Dispose()
        self.tipVoice = nil
    end
    self:clearEvent()
end

function ChatVoice:clearEvent()
    Stage.inst.onTouchMove:Remove(self.onTouchMove,self)
end
--按下结束发送语音
function ChatVoice:onVoiceEnd(evtY)
    local gangId = tonumber(cache.PlayerCache:getGangId())
    if self.chatType == ChatType.gang and gangId <= 0 then
        GComAlter(language.redbag12)
        return
    end
    if self:isNotSendLv() then--等级不足
        return
    end
    if self.oldTime then
        local leftTime = mgr.NetMgr:getServerTime() - self.oldTime
        if leftTime < self.cdTime then
            return
        end
    end
    if self.touchTimer then
        self.mParent:removeTimer(self.touchTimer)
        self.touchTimer = nil
    end
    local y = math.abs(self.evtY - evtY)
    -- plog(y,self.evtY,evt.y)
    if y <= 30 then
        if self.beginTime <= 1 then
            self:removeVoice()
            GComAlter(language.chatSend23)
            return
        end
        local function func(data)
            self:sendVoice(data)
        end 
        mgr.SDKMgr:recordAudio(2,func)
        if not self.voiceTimer then
            self.time = 0
            self.voiceTimer = self.mParent:addTimer(1, -1, function()
                self.time = self.time + 1
                if self.time >= 2 then
                    self:releaseVoiceTimer()
                    if not self.isVoiceSend then
                        GComAlter(language.chatSend24)
                    end
                end
            end)
        end
    else
        mgr.SDKMgr:recordAudio(3)
    end
    self:removeVoice()
end

function ChatVoice:releaseVoiceTimer()
    if self.voiceTimer then
        self.mParent:removeTimer(self.voiceTimer)
        self.voiceTimer = nil
    end
end
--语音回调
function ChatVoice:sendVoice(data)
    if data["errorCode"] == 0 then  -- 0表示成功
        if self.beginTime and self.beginTime >= 8 then
            self.beginTime = 8
        end
        local audioData = data.audioData  --语音数据base64字符串
        local audioTxt = data.audioTxt    --语音翻译的文字
        local params = {
            type = self.chatType,
            isVoice = self.beginTime,
            voiceStr = audioData,
            content = audioTxt,
            tarName = ""
        }
        proxy.ChatProxy:send(1060101,params)
        self.isVoiceSend = true
    end
end
--发送等级不够
function ChatVoice:isNotSendLv()
    local chatId = world
    if self.chatType == ChatType.gang then
        chatId = gang
    end
    local confData = conf.ChatConf:getChatData(chatId)
    local openlv = confData and confData.open_lv or 1
    local chatName = confData and confData.name or ""
    -- if G_AgentChatLimit() then
    --     local LimitData = conf.ChatConf:getAgentChatById(g_var.channelId)
    --     local limitLv = 0
    --     for k,v in pairs(LimitData.open_lev) do
    --         if confData.type == v[1] then
    --             limitLv = v[2]
    --             break
    --         end
    --     end
    --     if cache.PlayerCache:getRoleLevel() < limitLv then
    --         GComAlter(string.format(language.chatSend15, chatName,limitLv))
    --         return true
    --     end
    -- elseif cache.PlayerCache:getRoleLevel() < openlv then
    --     GComAlter(string.format(language.chatSend15, chatName,openlv))
    --     return true
    -- end
end

return ChatVoice