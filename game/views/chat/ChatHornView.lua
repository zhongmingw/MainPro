--
-- Author: ohf
-- Date: 2017-01-12 20:08:53
--
--喇叭
local ChatHornView = class("ChatHornView", base.BaseView)

local hornId = 221011001

function ChatHornView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function ChatHornView:initData()
    self.data = cache.PackCache:getPackDataById(hornId)
    self.hornText.text = self.data.amount
    local chatId = 8
    self.oldTime = cache.ChatCache:getOldSeverTime(chatId)
    local confData = conf.ChatConf:getChatData(chatId)
    self.cdTime = confData and confData.cd_time or 0--cd时间
    self:onTimer()
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
end

function ChatHornView:initView()
    local closeBtn = self.view:GetChild("n1"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.ctrl = self.view:GetController("c1")
    self.inputText = self.view:GetChild("n14")
    self.inputText.text = ""
    self.inputText.onChanged:Add(self.onChangeInput,self)
    self.hornText = self.view:GetChild("n16")

    local phizBtn = self.view:GetChild("n11")
    phizBtn.onClick:Add(self.onClickPhiz,self)
    local sendBtn = self.view:GetChild("n12")
    sendBtn.onClick:Add(self.onClickSend,self)
    local buyBtn = self.view:GetChild("n5")
    buyBtn.onClick:Add(self.onClickBuy,self)
    local closePhizBtn = self.view:GetChild("n25")
    closePhizBtn.onClick:Add(self.onClickClosePhiz,self)
    self:initPhizPanel()
end

function ChatHornView:releaseTimer()
    if self.timer then
        self:removeTimer(self.cdTimer)
        self.timer = nil
    end
    self.cdTime = 0
    self.inputText.promptText = language.chatSend17
end

function ChatHornView:onTimer()
    if self.oldTime then
        local leftTime = mgr.NetMgr:getServerTime() - self.oldTime
        if leftTime >= self.cdTime then
            self:releaseTimer()
            return
        end
        local time = self.cdTime - leftTime
        self.inputText.promptText = string.format(language.chatSend18, time)
    else
        self:releaseTimer()
    end
end

function ChatHornView:onClickSend()
    if self.inputText.text == "" then
        GComAlter(language.chatSend2)
        return
    end
    local len = string.utf8len(self.inputText.text)
    if len >= language.chatNum then--输入限制
        GComAlter(string.format(language.chatSend6, language.chatNum))
        return
    end
    local params = {
        type = ChatType.horn,
        content = self.inputText.text,
        tarName = cache.PlayerCache:getRoleName()
    }
    proxy.ChatProxy:send(1060101,params)
    cache.ChatCache:setHornSend(true)
    self.inputText.text = ""
    -- self:closeView()
end

--输入监听
function ChatHornView:onChangeInput(context)
    self:setInputText(self.inputText.text)
end

function ChatHornView:setInputText(text,phizIndex)
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
end
--喇叭表情
function ChatHornView:initPhizPanel()
    local listView = self.view:GetChild("n23")--表情列表
    listView.itemRenderer = function(index,obj)
        self:cellPhizData(index, obj)
    end
    listView.numItems = ChatType.phizNum
    listView.onClickItem:Add(self.onPhizClickCall,self)
end

function ChatHornView:cellPhizData(index,cell)
    local phizId = index + 1
    if phizId < 10 then
        cell.data = "0"..phizId
    else
        cell.data = phizId
    end
    local imgObj = cell:GetChild("n0")
    imgObj.url = ResPath.phizRes(cell.data)
end

function ChatHornView:onPhizClickCall(context)
    local cell = context.data
    local index = cell.data
    self:setInputText(mgr.TextMgr:getPhiz(index),index)
    self.ctrl.selectedIndex = 0
end

function ChatHornView:successData()
    self.data = cache.PackCache:getPackDataById(hornId)
    self.hornText.text = self.data.amount
    self:closeView()
end

function ChatHornView:onClickBuy()
    if self.data then
        GGoBuyItem(self.data)
    end
end

function ChatHornView:onClickPhiz()
    self.ctrl.selectedIndex = 1
end

function ChatHornView:onClickClosePhiz()
    self.ctrl.selectedIndex = 0
end

return ChatHornView