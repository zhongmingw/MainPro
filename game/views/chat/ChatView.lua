--
-- Author: ohf
-- Date: 2017-01-12 15:56:49
--
--聊天界面
local ChatView = class("ChatView", base.BaseView)

local ChatPhizPanel = import(".ChatPhizPanel") --表情区域

local ChatProsPanel = import(".ChatProsPanel")--道具区域

local ChatHistoryPanel = import(".ChatHistoryPanel")--输入历史

local ChatPetPanel = import(".ChatPetPanel")--宠物 

local MailPanel = import(".MailPanel")--邮件列表

function ChatView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.index = 0--记录是第几个聊天
    self.uiClear = UICacheType.cacheForever
end

function ChatView:initData(data)
    self.evtY = 0--语音按钮触摸移动位置
    self.tarName = nil--私聊玩家的目标名字缓存
    self.mType = nil--聊天频道情况（如：是否加入帮派）
    self.sendRoleId = 0--发送者的id（仅用于密聊）
    self.oldTime = 0
    self:releaseVoiceTimer()
    self:releaseTimer()
    self:initRedMail()--邮件红点
    self.isVoice = false
    self.playVoiceTime = os.time()--语音播放世界纪录
    self:setEmoticonVisible(1)
    self.musicEnble = mgr.SoundMgr:getMusicEnable()--音乐开关
    self.soundEnble = clone(mgr.SoundMgr:getSoundEnable())--音效开关
    if data.roleData then--外部調用私聊
        self:setTarName(data.roleData)
    else
        self:nextStep(data.index)
    end
end

function ChatView:initView()
    self.closeViewEffect = self.view:GetTransition("t1")--EVE 使用动效关闭聊天窗口
    self.mailRedPoint = self.view:GetChild("n62")--邮件红点
    self.chatController = self.view:GetController("c1")--主控制器
    self.chatController.onChanged:Add(self.selelctChat,self)--给控制器获取点击事件
    self.controller3 = self.view:GetController("c3")--条件控制器
    self.chatListView = self.view:GetChild("n90")--聊天列表
    self.chatListView:SetVirtual()
    self.chatListView.itemRenderer = function(index,obj)
        self:cellChatData(index, obj)
    end
    self.chatListView.scrollPane.onScroll:Add(self.doSpecialEffect, self)

    self.worldListView = self.view:GetChild("n96")--世界聊天
    self.worldListView:SetVirtual()
    self.worldListView.itemRenderer = function(index,obj)
        self:cellChatData(index, obj)
    end
    self.worldListView.scrollPane.onScroll:Add(self.doSpecialEffect, self)

    self.gangListView = self.view:GetChild("n97")--仙盟聊天列表
    self.gangListView:SetVirtual()
    self.gangListView.itemRenderer = function(index,obj)
        self:cellGangData(index, obj)
    end
    self.gangListView.scrollPane.onScroll:Add(self.doSpecialEffect, self)

    self.systemListView = self.view:GetChild("n91")--系统信息
    self.systemListView:SetVirtual()
    self.systemListView.itemRenderer = function(index,obj)
        self:cellSystemData(index, obj)
    end
    --密聊列表
    self.roleListView = self.view:GetChild("n87")
    self.roleListView:SetVirtual()
    self.roleListView.itemRenderer = function(index,obj)
        self:cellRoleData(index, obj)
    end
    self.roleListView.onClickItem:Add(self.onClickRole,self)
    --私聊
    self.privateBtn = self.view:GetChild("n88")
    self.privateName = self.privateBtn:GetChild("title")

    self:initEmoticon()

    self.sendText = ""--要发送的文本不含道具
    self.sendPro = ""--要发送的道具
    self.sendMsg = ""--最终发送的消息
    self.inputText = self.view:GetChild("n17")--输入框
    self.inputText.onChanged:Add(self.onChangeInput,self)
    self.inputFrame = self.view:GetChild("n16")
    self.inputText.promptText = language.chatSend17

    self:initButton()

    self.newTipFrame = self.view:GetChild("n25")
    --新消息提示
    self.newTipText = self.view:GetChild("n26")
    local str1 = mgr.TextMgr:getTextColorStr(language.newMsg[1],12)
    local str2 = mgr.TextMgr:getTextColorStr(language.newMsg[2],10)
    self.newTipText.text = str1..str2
    self.newTipText.onClick:Add(self.onClickNewMsg,self)

    local warnText = self.view:GetChild("n50")
    warnText.text = language.chatWarn
    
    self:setNewMsg(false)

    self.downDesc1 = self.view:GetChild("n79")--不能发消息提示
    self.downFrame = self.view:GetChild("n76")
    for i=53,59 do
        local btn = self.view:GetChild("n"..i)
        if g_ios_test and (i == 56 or i == 57) then   --EVE 屏蔽仙盟和队伍聊天栏
            btn.visible = false
        end 
        btn.title = language.chatSend20[i]
        btn.selectedTitle = language.chatSend20[i]
    end
    self.voiceTips = self.view:GetChild("n93")--语音按住提示图1
    self.voiceTips.visible = false
    self.voiceTips2 = self.view:GetChild("n94")--语音按住提示图2
    self.voiceTips2.visible = false
    self.voiceEffect = self.view:GetChild("n95")--语音播放动画
    self.voiceEffect.visible = false
    --聊天装饰按钮
    self.decorateBtn = self.view:GetChild("n101")
    self.decorateBtn.onClick:Add(self.onClickDecorate,self)
end

--仙盟按钮红点显隐
function ChatView:setGangChatBtnRed()
    local btn = self.view:GetChild("n56")
    if self.chatController.selectedIndex == 3 then
        btn:GetChild("red").visible = false
    else
        btn:GetChild("red").visible = true
    end
end

function ChatView:initEmoticon()
    self.emoticonPanel = self.view:GetChild("n44")--表情栏区域
    self.emoticonController = self.view:GetController("c2")--表情道具历史等控制器
    self.emoticonController.onChanged:Add(self.selelctEmoticon,self)
    self.phizPanel = ChatPhizPanel.new(self)--表情
    self.prosPanel = ChatProsPanel.new(self)--道具
    self.historyPanel = ChatHistoryPanel.new(self)--输入历史
    self.mailPanel = MailPanel.new(self)--聊天列表

    self.petPanel =  ChatPetPanel.new(self)--宠物
end

function ChatView:initButton()
    local closeBtn = self.view:GetChild("n61")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.blackView.onClick:Add(self.onClickClose,self)
    local closePhizBtn = self.view:GetChild("n38")--关闭表情栏
    closePhizBtn.data = 1
    closePhizBtn.onClick:Add(self.onClickPhiz,self)
    self:initVoiceButton()
    self.phizBtn = self.view:GetChild("n19")
    self.phizBtn.data = 2
    self.phizBtn.onClick:Add(self.onClickPhiz,self)

    self.hornBtn = self.view:GetChild("n20")
    self.hornBtn.onClick:Add(self.onClickHorn,self)

    local sendBtn = self.view:GetChild("n21")--发送按钮
    sendBtn.onClick:Add(self.onClickSend,self)
    self.sendCdImg = sendBtn:GetChild("n6").asImage
    self.guidBtn = self.view:GetChild("n80")
    self.guidBtn.onClick:Add(self.onClickGuid,self)

    self.deleteReadBtn = self.view:GetChild("n82")--一键删除已读
    self.deleteReadBtn.onClick:Add(self.onClickDeleteRead,self)
    self.receiveReadBtn = self.view:GetChild("n83")--一键领取已读
    self.receiveReadBtn.onClick:Add(self.onClickReceiveRead,self)
end
--注册语音按钮
function ChatView:initVoiceButton()
    self.voiceLabelBtn = self.view:GetChild("n18")--语音文字切换按钮
    self.voiceLabelBtn.onClick:Add(self.onClickVoice,self)
    self.voiceLabelBtn.visible = false --屏蔽语音按钮2018/06/26bxp
    self.voiceBtn = self.view:GetChild("n100")--语音按钮
    self.voiceBtn:RemoveEventListeners()
    self.voiceBtn.onTouchBegin:Add(self.onVoiceBegin,self)
    self.voiceBtn.onTouchEnd:Add(self.onVoiceTouchEnd,self)
end
--语音切换
function ChatView:onClickVoice()
    if self.isVoice then
        self.isVoice = false
        self:setDownVisible(1)
    else
        self.isVoice = true
        self:setDownVisible(8)
    end
end
--开始按下
function ChatView:onVoiceBegin(context)
    local evt = context.data
    self.evtY = evt.y
    if self:isNotSendLv() then return end--等级不足
    if self.oldTime then
        local leftTime = mgr.NetMgr:getServerTime() - self.oldTime
        if leftTime < self.cdTime then
            GComAlter(language.chatSend19)
            return
        end
    end
    self:playVocieEff(true)
    self.beginTime = 1
    self.touchTimer = self:addTimer(1, -1, function( ... )
        if self.beginTime >= 8 then
            self.beginTime = 8
            self:setTipVisible()
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
    Stage.inst.onTouchMove:Add(self.onTouchMove,self)
end

function ChatView:setTipVisible()
    self:playVocieEff(false)
    self.voiceTips2.visible = false
    self:clearEvent()
end

function ChatView:clearEvent()
    Stage.inst.onTouchMove:Remove(self.onTouchMove,self)
end

function ChatView:onTouchMove(context)
    local evt = context.data
    local y = math.abs(self.evtY - evt.y)
    if y >= 30 then
        self:playVocieEff(false)
        self.voiceTips2.visible = true
    else
        self:playVocieEff(true)
        self.voiceTips2.visible = false
    end
end

function ChatView:playVocieEff(visible)
    self.voiceTips.visible = visible
    self.voiceEffect.visible = visible
    if visible then
        self.voiceEffect.url = UIPackage.GetItemURL("_movie","MovieChat")
    else
        self.voiceEffect.url = ""
    end
end
--按下结束发送语音
function ChatView:onVoiceTouchEnd(context)
    if self:isNotSendLv() then return end--等级不足
    if self.oldTime then
        local leftTime = mgr.NetMgr:getServerTime() - self.oldTime
        if leftTime < self.cdTime then return end
    end
    if self.touchTimer then
        self:removeTimer(self.touchTimer)
        self.touchTimer = nil
    end
    local evt = context.data
    local y = math.abs(self.evtY - evt.y)
    -- plog(y,self.evtY,evt.y)
    if y <= 30 then
        if self.beginTime <= 1 then
            self:setTipVisible()
            GComAlter(language.chatSend23)
            return
        end
        local function func(data)
            self:sendVoice(data)
        end 
        mgr.SDKMgr:recordAudio(2,func)
        if self.beginTime and self.beginTime >= 8 then self.beginTime = 8 end

        if not self.voiceTimer then
            self.time = 0
            self.voiceTimer = self:addTimer(1, -1, function()
                self.time = self.time + 1
                if self.time >= 2 then
                    self:releaseVoiceTimer()
                    if not self.isVoiceSend then GComAlter(language.chatSend24) end
                end
            end)
        end
    else
        mgr.SDKMgr:recordAudio(3)
    end
    self:setTipVisible()
end

function ChatView:releaseVoiceTimer()
    if self.voiceTimer then
        self:removeTimer(self.voiceTimer)
        self.voiceTimer = nil
    end
end

--播放语音
function ChatView:onPlayAudio(context)
    local btn = context.sender
    local cell = btn.data
    self:playAudio(cell)
end
--停掉上一个播放者的动画
function ChatView:stopLastAct()
    self:releaseAudioTimer()
    if self.playCell then--停掉原来的语音动画
        -- plog("停掉原来的语音动画")
        local data = self.playCell.data
        local chatData = data.chatData
        local voiceBtn1 = self.playCell:GetChild("n26")--
        local voiceBtn2 = self.playCell:GetChild("n27")--
        local voiceEffect = self.playCell:GetChild("n28")
        voiceEffect.visible = false
        voiceEffect.url = ""
        if tonumber(chatData.isVoice) > 0 then--停掉语音的动画，显示为原来的图片
            if chatData.sendRoleId == cache.PlayerCache:getRoleId() then
                voiceBtn1.visible = false
                voiceBtn2.visible = true
            else
                voiceBtn1.visible = true
                voiceBtn2.visible = false
            end
        end
    end
    self.playCell = nil
end
--播放当前播放者的动画
function ChatView:playThisAct(cell)
    local data = cell.data.chatData
    cell:GetChild("n26").visible = false
    cell:GetChild("n27").visible = false
    local voiceEffect = cell:GetChild("n28")
    voiceEffect.visible = true
    if data.sendRoleId == cache.PlayerCache:getRoleId() then
        voiceEffect.url = UIPackage.GetItemURL("chat","MovieClip1")
    else
        voiceEffect.url = UIPackage.GetItemURL("chat","MovieClip2")
    end
end

function ChatView:releaseAudioTimer()
    if self.musicEnble then
        UnitySound:BGMSetVolume(mgr.SoundMgr:getMusicVolume())
    end
    if self.soundEnble then self.soundMute = false end--静音
    if self.playTimer then
        self:removeTimer(self.playTimer)
        self.playTimer = nil
    end
end

function ChatView:playAudio(cell)
    local data = cell.data.chatData
    local index = cell.data.index
    cache.ChatCache:setPlayAudioIndex(data,index)
    self:stopLastAct()
    self:playThisAct(cell)
    if not self.playCell then self.playCell = cell end
    local audioSec = tonumber(data.isVoice)
    if audioSec > 0 then
        mgr.SDKMgr:playAudio(data.voiceStr)--播放语音
        self.playVoiceTime = Time.getTime()
        if not self.playTimer then
            self.playTimer = self:addTimer(0.2, -1, function()
                if Time.getTime() - self.playVoiceTime > audioSec then
                    self:stopLastAct()
                    self.soundVolume = nil
                else
                    if self.musicEnble then
                        UnitySound:BGMSetVolume(0)
                    end
                    if self.soundEnble then self.soundMute = true end--静音      
                end
            end)
        end
    end
end

function ChatView:sendVoice(data)
    printt("语音返回",data)
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
            tarName = self.tarName or ""
        }
        proxy.ChatProxy:send(1060101,params)
        self.isSend = true
        self.isVoiceSend = true
    end
end

function ChatView:initRedMail()
    local redPoint = self.view:GetChild("n84")
    local redText = self.view:GetChild("n85")
    local param = {panel = redPoint,text = redText, ids = {attConst.A10201},notnumber = true}
    mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
end

function ChatView:setData(iChannel)
    if iChannel then self.isRef = true end--是否外部刷新
    local isRefList = false
    if self.isSend then--是否是自己发送
        local chatId = self.chatController.selectedIndex + 1
        cache.ChatCache:setOldSeverTime(chatId)
        isRefList = true
    end
    self.isSend = nil
    if self.isRef then
        if self.chatController.selectedIndex == iChannel then--新消息刷新了当前频道
            isRefList = true
        end
    else
        isRefList = true
    end
    if isRefList then self:selelctChat() end--刷新列表
end
--外部跳转调用  聊天类型 id 1-7
function ChatView:nextStep(gotoIndex)
    local index = 0
    if gotoIndex then
        index = gotoIndex - 1
    else
        index = cache.ChatCache:getSelectedIndex()
        if index == 6 then index = 7 end--如果上一次是私聊频道则索引到密聊列表
        if index == 8 then index = 1 end--如果是邮件则打开世界
    end
    if index == self.chatController.selectedIndex then
        self:selelctChat()
    else
        self.chatController.selectedIndex = index
    end
    -- 
end
--聊天信息
function ChatView:setChatData()
    self:setMsgSorts()
    local len = #self.chatData

    local sendName = self.chatData[len] and self.chatData[len].sendName or ""
    --数据列表
    if self.chatType == ChatType.system or self.chatType == ChatType.kuafuSystem then--bxp加跨服系统
        self.systemListView.numItems = len
        self.systemListView:ScrollToView(len - 1)
        self:setNewMsg(false)
    else
        if self.chatController.selectedIndex == 1 then--世界聊天
            self.worldListView.numItems = len
        elseif self.chatController.selectedIndex == 3 then--仙盟聊天
            self.gangListView.numItems = len
        else
            self.chatListView.numItems = len
        end
        if (not self.isRef and len > 0) or (not self.isSpecial and len > 0) or sendName == cache.PlayerCache:getRoleName() then
            self:actionChatList()
        else
            if self.index < len - 1 then
                self:setNewMsg(true)
            end
        end
        local chatId = self.chatController.selectedIndex + 1
        self.oldTime = cache.ChatCache:getOldSeverTime(chatId)
        local confData = conf.ChatConf:getChatData(chatId)
        self.cdTime = confData and confData.cd_time or 0--cd时间
        if not self.cdTimer then
            if self.oldTime then
                self.cdActionTime = self.cdTime - (mgr.NetMgr:getServerTime() - self.oldTime)
            end
            self:onTimer()
            self.cdTimer = self:addTimer(0.2, -1, handler(self,self.onTimer))
        end
        self.isRef = nil
    end
end

function ChatView:releaseTimer()
    if self.cdTimer then
        self:removeTimer(self.cdTimer)
        self.cdTimer = nil
    end
    self.cdTime = 0
    self.inputText.promptText = language.chatSend17
    self.voiceBtn.title = language.chatSend21
    self.sendCdImg.fillAmount = 0
end
--发送倒计时
function ChatView:onTimer()
    if self.oldTime then
        local leftTime = mgr.NetMgr:getServerTime() - self.oldTime
        if leftTime >= self.cdTime then
            self:releaseTimer()
            return
        end
        self:setTipVisible()
        local time = math.ceil(self.cdTime - leftTime)
        self.inputText.promptText = string.format(language.chatSend18, time)
        self.voiceBtn.title = string.format(language.chatSend18, time)
        if self.cdActionTime then
            self.cdActionTime = self.cdActionTime - 0.2
            self.sendCdImg.fillAmount = self.cdActionTime / self.cdTime
        end
    else
        self:releaseTimer()
    end
end
--密聊列表
function ChatView:setPrivateRole()
    self.roleList = cache.ChatCache:getPrivateRole()
    self.roleListView.numItems = #self.roleList
    self.roleListView:ScrollToView(0,false,true)
end
--清空消息
function ChatView:cleanMsg()
    self.inputText.text = ""
    self.sendText = ""--要发送的文本不含道具
    self.sendPro = ""--要发送的道具    
    if self.sendMsg ~= "" then--把发送成功的文本存入输入历史
        cache.ChatCache:setHistoryData(self.sendMsg)
        self.sendMsg = ""--最终发送的消息
    end
end
--信息分类
function ChatView:setMsgSorts()
    self.chatData = {}--根据类型解析返回的文本
    if self.chatType == ChatType.world then--世界（包含了帮主喊话）
        local chatData = cache.ChatCache:getWorldData()
        for k,v in pairs(chatData) do
            if v.type == self.chatType or v.type == ChatType.gangRecruit or v.type == ChatType.horn then
                table.insert(self.chatData, v)
            end
        end
    elseif self.chatType == ChatType.near then--附近
        local chatData = cache.ChatCache:getWorldData()
        for k,v in pairs(chatData) do
            if v.type == self.chatType then
                table.insert(self.chatData, v)
            end
        end
    elseif self.chatType == ChatType.gang or self.chatType == ChatType.gangWarehouse then--仙盟（包括接收仙盟求助,仙盟互动,世界boss仙盟招募）
        local chatData = cache.ChatCache:getGangData()
        for k,v in pairs(chatData) do
            table.insert(self.chatData, v)
        end
    elseif self.chatType == ChatType.system or self.chatType == ChatType.kuafuSystem then--系统（包括跑马灯）--bxp添加跨服系统
        local chatData = cache.ChatCache:getChatSystemData()
        for k,v in pairs(chatData) do
            table.insert(self.chatData, v)
        end
    elseif self.chatType == ChatType.private then--私聊
        local name = cache.PlayerCache:getRoleName()
        local roleId = cache.PlayerCache:getRoleId()
        local chatData = cache.ChatCache:getPrivateData()
        for k,v in pairs(chatData) do
            if v.type == self.chatType and ((self.tarName == v.tarName) or (v.tarName == name and v.sendName == self.tarName)) then
                table.insert(self.chatData, v)
            end
        end
    elseif self.chatType == ChatType.team then--队伍
        local chatData = cache.ChatCache:geTeamData()
        for k,v in pairs(chatData) do
            table.insert(self.chatData, v)
        end
    elseif self.chatType == ChatType.friend then--好友
        local chatData = cache.ChatCache:geFriendData()
        for k,v in pairs(chatData) do
            table.insert(self.chatData, v)
        end
    end
end
--仙盟聊天
function ChatView:cellGangData(index,cell)
    local data = self.chatData[index + 1]
    if not data then
        cell.visible = false
    else
        cell.visible = true
    end
    local speakItem = cell:GetChild("n0")--仙盟聊天item
    local hdItem = cell:GetChild("n1")--仙盟互动item
    local systemItem = cell:GetChild("n2")--仙盟圣火添柴系统提示
    -- print("仙盟",data.type)
    if data.type == ChatType.gangHd then
        hdItem.visible = true
        speakItem.visible = false
        systemItem.visible = false
        hdItem:GetChild("n0").text = data.content
        hdItem:GetChild("n1").url = UIItemRes.chatType[data.type]
        local btn1 = hdItem:GetChild("n2")--问好
        local btn2 = hdItem:GetChild("n3")--欢迎
        local btn3 = hdItem:GetChild("n4")--调戏
        local callback = function()
            btn1.enabled = false
            btn2.enabled = false
            btn3.enabled = false
        end

        local sendhdback = function(texts)
            if #texts > 0 then
                math.randomseed(tostring(os.time()):reverse():sub(1, 6))
                local random = math.random(1,#texts)
                self:sendChat(texts[random])
                cache.ChatCache:setGangHd(index + 1)
                callback()
            else
                plog("@策划互动配置有问题")
            end
        end

        if data.hd then--是否互动过
            callback()
        else
            btn1.enabled = true
            btn2.enabled = true
            btn3.enabled = true
        end

        local confData = conf.ChatConf:getGangHDSpeak(1)
        btn1.title = confData and confData.name or "问好"
        local texts = confData and confData.text or {}
        btn1:RemoveEventListeners()
        btn1.onClick:Add(function()
            sendhdback(texts)
        end,self)
        
        local confData = conf.ChatConf:getGangHDSpeak(2)
        btn2.title = confData and confData.name or "欢迎"
        local texts = confData and confData.text or {}
        btn2:RemoveEventListeners()
        btn2.onClick:Add(function()
            sendhdback(texts)
        end,self)
        
        local confData = conf.ChatConf:getGangHDSpeak(3)
        btn3.title = confData and confData.name or "调戏"
        local texts = confData and confData.text or {}
        btn3:RemoveEventListeners()
        btn3.onClick:Add(function()
            sendhdback(texts)
        end,self)
    elseif data.type == ChatType.xmFlame then
        systemItem.visible = true
        speakItem.visible = false
        hdItem.visible = false
        self:cellSystemData(index,systemItem)
    else
        speakItem.visible = true
        hdItem.visible = false
        systemItem.visible = false
        self:cellChatData(index,speakItem)
    end
end
--聊天数据
function ChatView:cellChatData(index,cell)
    local data = self.chatData[index + 1]
    if data then
        cell.visible = true
        cell.data = {chatData = data,index = index + 1}
        local roleId = data.sendRoleId
        local type = data.type
        local imgIcon = cell:GetChild("n6"):GetChild("n3")
        imgIcon.data = data
        local playerData = GGetMsgByRoleIcon(data.sendRoleIcon,data.sendRoleId,function(t,roleId)
            if imgIcon then
                local mRoleId = imgIcon.data and imgIcon.data.sendRoleId or 0
                if mRoleId == roleId then
                    imgIcon.url = t.headUrl
                end
            end
        end)
        imgIcon.url = playerData.headUrl
        imgIcon.onClick:Add(self.onClickPlayer,self)
        local vipText = cell:GetChild("n7")
        local vipImg = cell:GetChild("n8")
        local name = mgr.TextMgr:getTextColorStr(data.sendName,globalConst.ChatView01)
        local nameText1 = cell:GetChild("n13")
        local nameText2 = cell:GetChild("n15")
        local lvText = cell:GetChild("n14")
        lvText.text = string.format(language.gonggong51, data.sendRoleLev) 
        --聊天人物信息
        local privilegeStr = mgr.TextMgr:getImg(UIItemRes.chatPrivilege[playerData.privilege],29,30)
        local sexStr = mgr.TextMgr:getImg(UIItemRes.chatSex[playerData.sex])
        local gangStr = mgr.TextMgr:getImg(UIItemRes.chatGang[data.gangJob],53,30)
        local rankStr = mgr.TextMgr:getImg(UIItemRes.chatRank[data.powerRank],96,30)
        if type >= ChatType.gang and type <= ChatType.ganghelp then--帮派聊天
            nameText1.text = privilegeStr..sexStr..name..gangStr
            nameText2.text = gangStr..name..sexStr..privilegeStr
        else
            nameText1.text = privilegeStr..sexStr..name..rankStr
            nameText2.text = rankStr..name..sexStr..privilegeStr
        end
        if playerData.viplv <= 1 then--人物vip显示
            vipImg.visible = false
            vipText.visible = false
        else
            vipImg.visible = true
            vipText.visible = true
            vipText.text = playerData.viplv
        end
        self:setChatText(cell,data,playerData)
        if self.index < index then
            self.index = index
            self:setNewMsg(false)
        end
    else
        cell.visible = false
    end
end
--显示聊天文本
function ChatView:setChatText(cell,data,playerData)
    local roleId = data.sendRoleId
    local isVoice = data.isVoice--语音时长
    local sendName = data.sendName
    local ctrl = cell:GetController("c1")
    local bubble1 = cell:GetChild("n1")--气泡1
    local bubble2 = cell:GetChild("n2")--气泡2
    local kuangImg = cell:GetChild("n5")--框
    local bubbleData = conf.ChatConf:getChatBubbleData(playerData.pid)
    local image1 = "liaotian_082"
    local image2 = "liaotian_082"
    local num = 30
    --气泡
    if data.paopaoId > 0 then
        num = 45
        local bgImage = conf.RoleConf:getBubbleIconById(data.paopaoId)
        bubble1.url = UIPackage.GetItemURL("_others" , bgImage)
        bubble2.url = UIPackage.GetItemURL("_others" , bgImage)
    else
        bubble1.url = UIPackage.GetItemURL("chat" , image1)
        bubble2.url = UIPackage.GetItemURL("chat" , image2)
    end
    bubble1:RemoveEventListeners()
    bubble2:RemoveEventListeners()
    local roleIcon = data.sendRoleIcon
    --头像边框icon
    local frameId = math.floor((roleIcon%10000)/100)
    local frameIcon = conf.RoleConf:getFrameIconById(frameId)
    if frameIcon then
        kuangImg.url = UIPackage.GetItemURL("_others" , frameIcon)
    else
        local iconImg = bubbleData and bubbleData.icon_img or "liaotian_084"
        kuangImg.url = UIPackage.GetItemURL("chat" , iconImg)
    end

    local str = ""
    local content = data.content
    local type = data.type
    -- print("服务器返回信息",content,type)
    if type == ChatType.gangRecruit then--帮派招聘喊话
        local i = string.find(content,"=")
        local guidId = string.sub(content,0,i - 1)
        local hert = ChatHerts.GANGHERT..guidId..ChatHerts.GANGHERT
        str = mgr.ChatMgr:getSendText(string.sub(content,i + 1),data.sendRoleId)..mgr.TextMgr:getTextColorStr(language.chatSend5, 10, hert)
    elseif type == ChatType.ganghelp then--帮派求助
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
    elseif type == ChatType.xmshDice then--仙盟圣火的骰子数
        str = mgr.ChatMgr:getXmshDice(content)
    elseif data.type == ChatType.worldBossSystem then--世界boss仙盟招募
        local splitStr = string.split(content,"=")
        local hert = ""
        if #splitStr == 2 then
            if #splitStr == 2 then
                local strPex = splitStr[1]
                local strTab = string.split(strPex,",")
                if #strTab == 2 then
                    hert = ChatHerts.SYSTEWORLDBOSS..strTab[1]..ChatHerts.SYSTEWORLDBOSS..strTab[2]..ChatHerts.SYSTEWORLDBOSS
                end
            end
        end
        local str2 = splitStr[2] or ""
        str = str2..mgr.TextMgr:getTextColorStr(language.chatSend29, 7, hert)
    else
        str = mgr.ChatMgr:getSendText(content,data.sendRoleId)
    end

    local msgText1 = cell:GetChild("n11")--换行文本
    local msgText2 = cell:GetChild("n12")--不换行文本
    
    if type == ChatType.system or type == ChatType.horseLamp then
        msgText1.text = mgr.ChatMgr:getSendText(content,data.sendRoleId)
        msgText2.text = mgr.ChatMgr:getSendText(content,data.sendRoleId)
    else
        msgText1.text = string.trim(str)
        msgText2.text = string.trim(str)
    end
    
    if roleId ~= cache.PlayerCache:getRoleId() then--别人
        ctrl.selectedIndex = 0
        msgText1.visible = true
        msgText2.visible = false
        if msgText2.width >= msgText1.width then--换行的时候
            bubble1.width = msgText1.width + num
        else
            bubble1.width = msgText2.width + num
        end
    else--自己
        ctrl.selectedIndex = 1
        if msgText2.width >= msgText1.width then--换行的时候
            msgText1.visible = true
            msgText2.visible = false
            bubble2.width = msgText1.width + num
        else
            msgText1.visible = false
            msgText2.visible = true
            bubble2.width = msgText2.width + num
        end
    end
    msgText1.onClickLink:Add(self.onClickLinkText,self)
    msgText2.onClickLink:Add(self.onClickLinkText,self)
    local voiceText = cell:GetChild("n16")--语音翻译文本
    local voiceBtn1 = cell:GetChild("n26")--语音播放按钮--别人
    local voiceBtn2 = cell:GetChild("n27")--语音播放按钮--自己
    voiceBtn1:RemoveEventListeners()
    voiceBtn2:RemoveEventListeners()
    local effect = cell:GetChild("n28")
    effect.visible = false
    if isVoice > 0 then--当前是语音消息
        msgText1.visible = false
        self:setVoiceMsg(cell,voiceBtn1,voiceBtn2,voiceText,msgText2,bubble1,bubble2,effect)
    else
        voiceText.visible = false
        voiceBtn1.visible = false
        voiceBtn2.visible = false
        local height = msgText1.height + 16
        if height <= 40 then height = 40 end
        bubble1.height = height--设置气泡的高度
        bubble2.height = height
        cell.height = height + 34
    end
end
--语音消息
function ChatView:setVoiceMsg(cell,voiceBtn1,voiceBtn2,voiceText,msgText2,bubble1,bubble2,effect)
    local data = cell.data.chatData
    voiceText.visible = true
    voiceBtn1.title = '"'..data.isVoice
    voiceBtn2.title = '"'..data.isVoice
    voiceBtn1.data = cell
    voiceBtn1.onClick:Add(self.onPlayAudio,self)
    voiceBtn2.data = cell
    voiceBtn2.onClick:Add(self.onPlayAudio,self)
    bubble1.data = cell
    bubble1.onClick:Add(self.onPlayAudio,self)
    bubble2.data = cell
    bubble2.onClick:Add(self.onPlayAudio,self)
    local num = 70
    local isVoiceText = cache.ChatCache:getVoiceChannel(ChatType.voice)
    if isVoiceText == 1 then
        num = 30
        msgText2.text = ""
        voiceText.text = ""
    else--语音转文字
        voiceText.text = mgr.ChatMgr:getSendText(data.content) 
    end
    local type = data.type
    local autoPlay = cache.ChatCache:getVoiceChannel(self.chatType)
    if self.isRef then
        local isPlay = false
        if self.chatType == ChatType.world then--世界语音0就是关闭自动播放
            if autoPlay == 1 then isPlay = true end
        else
            if autoPlay == 0 then isPlay = true end
        end
        if isPlay and not data.isPlayedAudio then self:playAudio(cell) end
    end
    if data.sendRoleId ~= cache.PlayerCache:getRoleId() then--别人
        msgText2.visible = false
        local width = msgText2.width
        if msgText2.width >= voiceText.width then--换行的时候
            bubble1.width = voiceText.width + num
            width = voiceText.width
        else
            bubble1.width = msgText2.width + num
        end
        if isVoiceText == 1 then
            bubble1.width = voiceBtn1.width + num + 15
        end
        voiceBtn1.visible = true
        voiceBtn1.x = bubble1.x + width + 30
        effect.x = voiceBtn1.x
    else--自己
        local width = msgText2.width
        if msgText2.width >= voiceText.width then--换行的时候
            voiceText.visible = true
            msgText2.visible = false
            bubble2.width = voiceText.width + num
            width = voiceText.width 
        else
            voiceText.visible = false
            msgText2.visible = true
            bubble2.width = msgText2.width + num
        end
        if isVoiceText == 1 then
            bubble2.width = voiceBtn2.width + num + 15
        end
        voiceBtn2.visible = true
        voiceBtn2.x = bubble2.x - width - 50
        effect.x = voiceBtn2.x
    end
    local height = voiceText.height + 16
    if height <= 40 then height = 40 end
    bubble1.height = height--设置气泡的高度
    bubble2.height = height
    cell.height = height + 34
end
--系统信息（包括跑马灯）
function ChatView:cellSystemData(index, cell)
    local data = self.chatData[index + 1]
    if not data then
        cell.visible = false
    else
        cell.visible = true
    end
    local icon = cell:GetChild("n25")
    icon.url = UIItemRes.chatType[data.type]
    local msgText = cell:GetChild("n11")
    if data.type == ChatType.boss then--boss公告
        msgText.text = data.content..mgr.TextMgr:getHerfStr(language.chatSend8,7,1048)
    elseif data.type == ChatType.kuafueTeam then--跨服组队副本公告
        local msg = data.content
        local splitStr = string.split(msg,"=")
        local teamId = splitStr[1] or ""
        local hert = ChatHerts.KUAFUTEAM..teamId..ChatHerts.KUAFUTEAM
        local str = splitStr[2] or ""
        msgText.text = str..mgr.TextMgr:getTextColorStr(language.chatSend26, 7, hert)
    elseif data.type == ChatType.kuafuBoss then
        msgText.text = data.content..mgr.TextMgr:getHerfStr(language.chatSend8,7,1048)
    elseif data.type == ChatType.sjzbSepc then--三界争霸公告
        local splitStr = string.split(data.content,"=")
        local str1 = splitStr[1] or ""
        local xy = string.split(str1,",")
        local hert = ""
        if #xy == 2 then
            hert = ChatHerts.KUASEPC..xy[1]..ChatHerts.KUASEPC..xy[2]..ChatHerts.KUASEPC
        end
        local str2 = splitStr[2] or ""
        -- msgText.text = str2..mgr.TextMgr:getTextColorStr(language.chatSend27, 7, hert)
        msgText.text = str2
    elseif data.type == ChatType.fubenTeam then--副本组队公告
        local splitStr = string.split(data.content,"=")
        if #splitStr == 2 then
            hert = ChatHerts.SYSTEMTEAM..splitStr[1]..ChatHerts.SYSTEMTEAM
        end
        local str2 = splitStr[2] or ""
        msgText.text = str2..mgr.TextMgr:getTextColorStr(language.chatSend26, 7, hert)
    else
        msgText.text = data.content
    end
    cell.data = data
    msgText.onClickLink:Add(self.onClickLinkText,self)--部分超链接系统广播
end
--密聊列表
function ChatView:cellRoleData(index, cell)
    local data = self.roleList[index + 1]
    cell.data = data
    cell.visible = cache.ChatCache:isShieldMsg(ChatType.private)
    local nameText = cell:GetChild("n4")
    nameText.text = data.roleName
    local lvText = cell:GetChild("n2")
    lvText.text = string.format(language.gonggong51,data.level)
    local bgKuang = cell:GetChild("n3")
    local icon = cell:GetChild("n6"):GetChild("n3")
    local playerData = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(t)
        if icon then
            icon.url = t.headUrl
        end
    end)
    icon.url = playerData.headUrl
    local desc = cell:GetChild("n5")
    local bubbleData = conf.ChatConf:getChatBubbleData(playerData.pid)
    bgKuang.url = UIPackage.GetItemURL("chat" , bubbleData.icon_img)
    if data.relation == 0 then--陌生人
        desc.text = mgr.TextMgr:getTextColorStr(language.chatSend12[2], 14)
    else--好友
        desc.text = mgr.TextMgr:getTextColorStr(language.chatSend12[1], 10)
    end
end
--点击密聊对象
function ChatView:onClickRole(context)
    local cell = context.data
    local data = cell.data
    self.sendRoleId = data.roleId
    local role = cache.ChatCache:getSendPrivateRole(self.sendRoleId)
    if not role then--还没请求过的留言玩家
        cache.ChatCache:setPrivateRoleData(data)
        proxy.ChatProxy:send(1060104,{roleId = self.sendRoleId,roleName = data.roleName})
    else
        self:setTarName(data)
    end
end
--点击查看新的聊天信息
function ChatView:onClickNewMsg()
    self:actionChatList()
end
--玩家信息
function ChatView:onClickPlayer(context)
    local cell = context.sender
    local data = cell.data
    local roleId = data.sendRoleId
    local roleName = data.sendName
    local roleIcon = data.sendRoleIcon
    local sendRoleLev = data.sendRoleLev
    if roleId ~= " " then
        if roleId ~= cache.PlayerCache:getRoleId() then
            local params = {roleId = roleId,roleName = roleName,level = sendRoleLev,pos = {x = 150,y = 0},roleIcon = roleIcon,chouren = true,trade = true,mainSvrId = data.sendMainSrvId}
            mgr.ViewMgr:openView(ViewName.FriendTips,function(view)
                view:setData(params)
            end)
        end
    end
end
--超链接消息
function ChatView:onClickLinkText(context)

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
            self:onClickClose()
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
--滚动监听
function ChatView:doSpecialEffect(context)
    self.isSpecial = true
end

function ChatView:actionChatList()
    self.index = #self.chatData - 1
    if self.chatController.selectedIndex == 1 then--世界聊天
        if self.isRef then
            self.worldListView:ScrollToView(self.index,true,true)
        else
            self.worldListView:ScrollToView(self.index)
        end
    elseif self.chatController.selectedIndex == 3 then--仙盟聊天
        if self.isRef then
            self.gangListView:ScrollToView(self.index,true,true)
        else
            self.gangListView:ScrollToView(self.index)
        end
    else
        if self.isRef then
            self.chatListView:ScrollToView(self.index,true,true)
        else
            self.chatListView:ScrollToView(self.index)
        end
    end
    self:setNewMsg(false)
end

function ChatView:selelctChat()
    local selectedIndex = self.chatController.selectedIndex
    cache.ChatCache:setSelectedIndex(selectedIndex)
    self.chatType = 0--聊天发送类型==服务端对应世界2,喇叭3,附近4,私人5
    if self.isVoice then
        self:setDownVisible(8)
    else
        self:setDownVisible(1)
    end
    -- self:setEmoticonVisible(1)
    if selectedIndex == 8 then--邮件
        self:setDownVisible(5) 
        proxy.ChatProxy:send(1080101,{page = 1})
        return 
    end
    if not self.tarName then
        self.privateBtn.visible = false
    else
        self.privateBtn.visible = true
    end
    if selectedIndex == 0 then--系统
        self.chatType = ChatType.system
        self:setDownVisible(2)
    elseif selectedIndex == 1 then--世界
        self.chatType = ChatType.world
    elseif selectedIndex == 2 then--附近
        self.chatType = ChatType.near
    elseif selectedIndex == 3 then--帮派
        self.chatType = ChatType.gang
        local gangId = tonumber(cache.PlayerCache:getGangId())
        if gangId <= 0 then
            self:setDownVisible(3)
        end
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:setGangChatBtnRed(false)
        end
    elseif selectedIndex == 4 then--队伍
        self.chatType = ChatType.team
        if cache.TeamCache:getTeamId() <= 0 
            and not mgr.FubenMgr:isKuaFuTeamFuben(cache.PlayerCache:getSId()) then
            self:setDownVisible(4)
        end
    elseif selectedIndex == 5 then--好友
        self.chatType = ChatType.friend
        if not cache.PlayerCache:getIsFriend() then
            self:setDownVisible(7)
        end
    elseif selectedIndex == 7 then--密聊列表
        self:setPrivateRole()
        self:setDownVisible(6)
        return
    elseif selectedIndex == 6 then--私聊玩家
        self.chatType = ChatType.private
        if self.isRef then--如果发送刷新则设置已经私聊的玩家进密聊列表
            if self.roleData then
                local roleData = clone(self.roleData)
                cache.ChatCache:setPrivateRole(roleData)
                self.roleData = nil
            end
        end
    end
    local mainview = mgr.ViewMgr:get(ViewName.MainView)
    local btn = self.view:GetChild("n56")
    btn:GetChild("red").visible = mainview:getGangChatBtnRed()
    self:setChatData()
end
--刷新邮件
function ChatView:refreshMail(data)
    self.mailPanel:setData(data)
end
--操作邮件
function ChatView:receiveMail(data)
    self.mailPanel:receiveMail(data)
end

function ChatView:selelctEmoticon()
    local selectedIndex = self.emoticonController.selectedIndex
    if selectedIndex == 0 then--表情
        self.phizPanel:setData()
    elseif selectedIndex == 1 then--道具
        self.prosPanel:setData()
    elseif selectedIndex == 2 then--输入历史
        self.historyPanel:setData()
    elseif selectedIndex == 3 then--当前坐标
        self:setSendPos()
    elseif selectedIndex == 4 then--扔骰子
        self:setSendDice()
    elseif selectedIndex == 5 then--设置
        mgr.ViewMgr:openView(ViewName.SiteView,function(view)
            view:nextStep(2)
        end)
        self:onClickClose()
    elseif selectedIndex == 6 then--宠物
        self.petPanel:sendData()
    end
end
--喇叭
function ChatView:onClickHorn()
    GOpenView({id = 1026})
end
--发送消息按钮
function ChatView:onClickSend()
    self:setEmoticonVisible(1)
    self:sendChat()
end
--发送等级不够
function ChatView:isNotSendLv()
    local chatId = self.chatController.selectedIndex 
    local confData = conf.ChatConf:getChatData(chatId + 1)
    local openlv = confData and confData.open_lv or 1
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
    --         GComAlter(string.format(language.chatSend15, chatName,limitLv))
    --         return true
    --     end
    -- elseif cache.PlayerCache:getRoleLevel() < openlv and cache.PlayerCache:getVipLv() < chatVipLv then
    --     GComAlter(string.format(language.chatSend15, chatName,openlv))
    --     return true
    -- end
end
--发送消息
function ChatView:sendChat(str)
    local testMl = "@@#"
    if string.trim(self.inputText.text) == testMl then
        local view = mgr.ViewMgr:get(ViewName.DebugView)
        if view then
            view:closeView()
        else
            mgr.ViewMgr:openView(ViewName.DebugView)    
        end
        self:cleanMsg()
        return
    end
    if self.chatType == 0 then
        GComAlter(language.chatSend1)
        return
    end
    local sendText = ""
    local proNum1 = string.find(self.sendText, "<")
    local proNum2 = string.find(self.sendText, ">")
    if proNum1 and proNum2 and self.sendPro ~= "" then--判断是不是有道具文本
        local text = string.sub(self.sendText,proNum1, proNum2)
        sendText = string.gsub(self.sendText,text,"")
    else
        sendText = self.sendText
        if cache.PlayerCache:getRoleLevel() < ChatType.degreeLv then
            local chatData = cache.ChatCache:getSendChat(self.chatType)--获取前一条消息
            -- printt(chatData)
            if chatData then
                local degree = mgr.ChatMgr:editDistance(chatData.content,sendText)
                if degree >= ChatType.degree then
                    local tab = clone(chatData)
                    tab.content = sendText
                    cache.ChatCache:setData(tab)
                    local iChannel = mgr.ChatMgr:getChooseChannel(self.chatType)--最新要刷新的频道
                    cache.ChatCache:setNewMsg(iChannel)
                    self:cleanMsg()
                    return
                end
            end
        end
    end
    self.sendMsg = self.sendPro..sendText
    if self:isNotSendLv() then
        self:cleanMsg()
        return
    end
    if str then
        self.sendMsg = str
    else
        if self.sendMsg == "" or string.trim(self.sendMsg) == "" or string.trim(self.inputText.text) == "" then--输入了空消息
            GComAlter(language.chatSend2)
            self:cleanMsg()
            return
        end
    end

    if self.chatType == ChatType.private then--私聊
        if not self.tarName then
            self:cleanMsg()
            GComAlter(language.chatSend3)
            return
        end
    end
    if self.inputText.promptText == language.chatSend17 then--发送聊天
        local params = {
            type = self.chatType,
            content = self.sendMsg,
            isVoice = 0,
            voiceStr = "",
            tarName = self.tarName or ""
        }
        local sId = cache.PlayerCache:getSId()
        local sConf = conf.SceneConf:getSceneById(sId)
        -- print(">>>>>>>>>>>",sConf.cross,self.chatType)
        if sConf.cross and sConf.cross > 0 and (self.chatType == ChatType.team or self.chatType == ChatType.near) then
            GComAlter(language.chatSend30)
        else
            proxy.ChatProxy:send(1060101,params)
            self.isSend = true
        end
        self:cleanMsg()
        if self.chatType == ChatType.private then--私聊
            local role = cache.ChatCache:getSendPrivateRole(self.sendRoleId)
            if not role then--还没请求过的留言玩家
                if self.roleData then
                    local roleData = clone(self.roleData)
                    self:addTimer(0.3, 1, function()
                        local roleId = roleData and roleData.roleId or 0
                        local roleName = roleData and roleData.roleName or 0
                        cache.ChatCache:setPrivateRoleData(roleData)
                        proxy.ChatProxy:send(1060104,{roleId = roleId,roleName = roleName})
                    end)
                end
            end
        end
    else--还在cd中
        GComAlter(language.chatSend19)
    end
end

function ChatView:setTarName(data)
    self.tarName = data.roleName
    self.roleData = data
    local strList = string.split(self.tarName,".")--分离服务器名字
    if strList then
        self.privateName.text = strList[#strList]
    else
        self.privateName.text = data.roleName
    end
    self.chatController.selectedIndex = 6
    self:selelctChat()
end

function ChatView:onClickPhiz(context)
    self:setEmoticonVisible(context.sender.data)
end
--邮件一键删除已读
function ChatView:onClickDeleteRead()
    local mailNum = self.mailPanel:getMailNum()
    if self.mailPanel:getReadNum() <= 0 then
        GComAlter(language.mail03)
        return
    end
    if mailNum <= 0 or mailNum == self.mailPanel:getUnreadNum() then
        GComAlter(language.mail03)
        return
    end
    proxy.ChatProxy:send(1080102,{reqType = 4,mailId = 0})
end
--邮件一键领取已读
function ChatView:onClickReceiveRead()
    local mailNum = self.mailPanel:getMailNum()
    local unread = self.mailPanel:getUnreadNum()
    if mailNum <= 0 or mailNum == mailNum - unread then
        GComAlter(language.mail04)
        return
    end
    proxy.ChatProxy:send(1080102,{reqType = 2,mailId = 0})
end
--表情栏panel
function ChatView:setEmoticonVisible(type)
    self.emoticonController.selectedIndex = 0
    if type == 1 then
        self.emoticonPanel.visible = false
    else
        if self.emoticonPanel.visible == true then
            self.emoticonPanel.visible = false
        else
            self.emoticonPanel.visible = true
            self:selelctEmoticon()
        end
    end
end
--输入监听
function ChatView:onChangeInput(context)
    self:setInputText(self.inputText.text)
end
--添加聊天信息
function ChatView:setInputText(text,phizIndex)
    local len = string.utf8len(self.inputText.text)
    if len >= language.chatNum then--输入限制
        GComAlter(string.format(language.chatSend6, language.chatNum))
        return
    end
    if phizIndex then
        self.inputText.text = self.inputText.text.."#"..phizIndex
    else
        self.inputText.text = text
    end
    self:setInputText2("")
    self.sendText = self.inputText.text
    local i = string.find(self.sendText, ">")
    if i then
        self.sendText = string.sub(self.sendText, i + 1)
    end
end
--针对是否有道具设置input
function ChatView:setInputText2( proText )
    if self.sendPro ~= "" then
        local i = string.find(self.inputText.text, ">")
        if i then
            local text = string.sub(self.inputText.text, i + 1)
            if proText then
                if proText == "" then
                    self.inputText.text = string.sub(self.inputText.text, 1,i)..text
                else
                    self.inputText.text = proText..text
                end
            end
        else
            self.inputText.text = proText or ""
        end
    else
        local text = proText or ""
        self.inputText.text = text..self.inputText.text
    end
end
--添加道具
function ChatView:setInputPros(data)
    local colorAttris = data.colorAttris or {}
    local colorStr = ""
    for k,v in pairs(colorAttris) do
        if k ~= #colorAttris then
            colorStr = colorStr..v.type..","..v.value..","
        else
            colorStr = colorStr..v.type..","..v.value
        end
    end
    if colorStr == "" then
        colorStr = "0,0"
    end
    local proSymbol = ChatHerts.PROINFOHERT

    local confdata = conf.ItemConf:getItem(data.mid)
    local index = data.index

    if confdata.type == Pack.wuxing then
        index = 0
    elseif confdata.type == Pack.xianzhuang then
        index = 0
    end

    str = proSymbol..data.mid..proSymbol..index..proSymbol..data.amount..proSymbol..cache.PlayerCache:getServerId()..proSymbol..colorStr..proSymbol..(data.level or 0)..proSymbol
    local proText = "<"..conf.ItemConf:getName(data.mid)..">"
    self:setInputText2(proText)
    self.sendPro = str
    self:setEmoticonVisible(1)
end
--添加宠物信息
function ChatView:setInputPet(data)
    -- body
    --添加到聊天文字
    local condata = conf.PetConf:getPetItem(data.petId)
    local proText = "<"..(data.name or "")..">"
    self:setInputText2(proText)
    --拼接发送key
    local proSymbol = ChatHerts.PETHERT
    -- self.sendPro = proSymbol.."1="
    self.sendPro = proSymbol..ChatHerts.PETHERTCHAT.."=" --bxp
    ..data.petId
    ..","..cache.PlayerCache:getRoleId()
    ..","..data.petRoleId
    ..","..cache.PlayerCache:getServerId()
    ..","..data.name
    ..proSymbol
    -- print("self.sendPro",self.sendPro)
    self:setEmoticonVisible(1)
end

--输入历史
function ChatView:setHistory(text)
    self:sendChat(text)
    self:setEmoticonVisible(1)
end
--发送坐标
function ChatView:setSendPos()
    local t = gRole:getPosition()
    local text = "@@"..cache.PlayerCache:getRoleId().."@@"..cache.PlayerCache:getSId().."@@"..math.floor(t.x).."@@"..math.floor(t.z).."@@"
    self:setEmoticonVisible(1)
    self.emoticonController.selectedIndex = 0
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.chatSend22)
        return
    end
    self:sendChat(text)
end
--扔骰子
function ChatView:setSendDice()
    math.randomseed(os.time())
    local num = math.random(0,99)
    local text = "|"..num.."|"
    self:sendChat(text)
    -- mgr.ChatMgr:sendxianMenDice({1,2,3})
    self:setEmoticonVisible(1)
    self.emoticonController.selectedIndex = 0
end
--设置是否有新消息
function ChatView:setNewMsg(isNew)
    if isNew then
        self.newTipText.visible = true
        self.newTipFrame.visible = true
    else
        self.isSpecial = false
        self.newTipText.visible = false
        self.newTipFrame.visible = false
    end
end
--设置是否可聊天 1可文字聊天,2不能发消息,3未加帮派,4没有队伍,5邮件列表,6密聊,7没有好友,8可语音聊天语音
function ChatView:setDownVisible(type)
    local icon = mgr.TextMgr:getImg(UIItemRes.warning01)
    local iType = type or 1
    self.controller3.selectedIndex = iType - 1
    self.mType = iType 
    if iType == 1 then--文字聊天
        self.voiceLabelBtn.icon = UIItemRes.chatVoice[1]
    elseif iType == 8 then--语音聊天
        self.voiceLabelBtn.icon = UIItemRes.chatVoice[2]
    else--各种不允许聊天情况
        if iType == 2 then
            self.downDesc1.text = icon..language.notMsg
        elseif iType == 3 then
            self.downDesc1.text = icon..language.chatGuild
        elseif iType == 4 then
            self.downDesc1.text = icon..language.chatTeam
        elseif iType == 5 then
        elseif iType == 6 then
            self.downDesc1.text = icon..language.chatSend14
        elseif iType == 7 then
            self.downDesc1.text = icon..language.chatFriend
        end
    end
end
--跳转到帮派
function ChatView:onClickGuid()
    GOpenView({id = 1013,index = 0})
    self:onClickClose()
end

function ChatView:onClickClose()
    self:releaseAudioTimer()
    self:setEmoticonVisible(1)
    --EVE 使用动效关闭聊天窗
    self.closeViewEffect:Play()
    self:removeBlackbg()   --EVE 移除灰色背景
    self:addTimer(0.38, 1, function()
        self.playCell = nil
        self:closeView()     
    end)
end

function ChatView:addMsgCallBack(data)
    -- body
    --print("1")
    if data.msgId == 5490101 then
        if self.emoticonPanel.visible then
            --print("#",self.emoticonController.selectedIndex)
            if self.emoticonController.selectedIndex == 6 then
                --print("self.petPanel",self.petPanel)
                if self.petPanel then
                    self.petPanel:setData()
                end
            end
        end
    end
end

function ChatView:onClickDecorate()
    GOpenView({id = 1320})
end

return ChatView