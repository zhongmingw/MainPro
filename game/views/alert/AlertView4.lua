--
-- Author: 
-- Date: 2017-01-17 16:04:12
--

local AlertView4 = class("AlertView4", base.BaseView)

function AlertView4:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.dataList = {}
    self.timer = nil
end

function AlertView4:initData(data)
    self:setData(data)
end

function AlertView4:initView()
    local panel = self.view:GetChild("n1")
    self.centerX = panel.width / 2
    self.label = panel:GetChild("n1")
    self.oldX = self.label.x
end

function AlertView4:setData(data)
    table.insert(self.dataList, data)
    if not self.timer then
        self:onMove()
        self.timer = true
    end
end

function AlertView4:onMove()
    local data = table.remove(self.dataList,1)
    if not data then
        
        self.timer = false
        self:closeView()
        return
    end
    local width = self.label.width / 2
    self.label.x = self.oldX + width
    self.label.text = self:getSendText(data.textData)
    local time = HorseTime
    local iY = self.label.y
    UTransition.TweenMove2(self.label, Vector2.New(self.centerX, iY), time, true, function()
        self:addTimer(1, 1, function()
            UTransition.TweenMove2(self.label, Vector2.New(-width, iY), time, true, function()
                self:onMove()
            end)
        end)
    end)
end

function AlertView4:getSendText(data)
    local imgText = mgr.TextMgr:getImg(UIItemRes.chatType[data.type],40,20)
    -- local hert = "*"..data.sendRoleId.."*"..data.sendName.."*"..data.sendRoleIcon.."*"..data.sendRoleLev.."*"
    -- local str = ""
    local content = data.content
    -- local sex = GGetMsgByRoleIcon(data.sendRoleIcon).sex or 0
    -- local sendName = mgr.TextMgr:getTextColorStr(data.sendName.."("..language.gonggong28[sex].."):", 12)
    return content
end

return AlertView4