--
-- Author: 
-- Date: 2017-03-31 15:38:47
--

local AlertView12 = class("AlertView12", base.BaseView)

local time = 5

function AlertView12:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.dataList = {}
    self.timer = nil
end

function AlertView12:initData(data)
    self:setData(data)
end

function AlertView12:initView()

end

function AlertView12:onTimer()
    local data = table.remove(self.dataList,1)
    if not data then
        
        self.timer = false
        self:closeView()
        return
    end
    local hornPanel = self.view:GetChild("n0")
    local hornText = self.view:GetChild("n1")
    hornText.text = self:getSendText(data.textData)
    hornPanel.height = hornText.height + 21
    UTransition.TweenMove2(hornText, Vector2.New(hornText.x,hornText.y), data.speed, true, function()
        self:onTimer()
    end)
end

function AlertView12:setData(data)
    table.insert(self.dataList, data)
    if not self.timer then
        self:onTimer()
        self.timer = true
    end
end

function AlertView12:getSendText(data)
    local imgText = mgr.TextMgr:getImg(UIItemRes.chatType[data.type],40,20)
    local content = data.content
    local sex = GGetMsgByRoleIcon(data.sendRoleIcon).sex
    local title = mgr.TextMgr:getTextColorStr(language.chatSend10,4)
    local sendName = mgr.TextMgr:getTextColorStr(data.sendName.."("..language.gonggong28[sex].."):", 4)
    return title..sendName..mgr.ChatMgr:getSendText(content)
end

return AlertView12