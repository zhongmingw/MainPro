--
-- Author: ohf
-- Date: 2017-03-28 15:10:13
--
--邀请入队
local TeamTipView = class("TeamTipView", base.BaseView)

local Time = 10
local normalType = Team.normalType
local capType = Team.capType

function TeamTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function TeamTipView:initView()
    local closeBtn = self.view:GetChild("n2")
    closeBtn.onClick:Add(self.onClickRefuse,self)
    self.text = self.view:GetChild("n3")
    local refuseBtn = self.view:GetChild("n5")
    refuseBtn.onClick:Add(self.onClickRefuse,self)
    local agreeBtn = self.view:GetChild("n6")
    agreeBtn.onClick:Add(self.onClickAgree,self)
    self.timeText = self.view:GetChild("n7")
    self.powerText = self.view:GetChild("n8")
end

function TeamTipView:setData(data,type)
    self.roleId = data.roleId
    self.type = type
    local str = str
    if self.type == normalType then--来自别人的申请
        str = mgr.TextMgr:getTextColorStr(data.roleName,7)..language.team15
    else--来自别人的邀请
        str = mgr.TextMgr:getTextColorStr(data.roleName,7)..language.team16
    end
    self.powerText.text = string.format(language.team31, data.power)
    self.text.text = str
    self.time = Time
    self:onTimer()
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
end
--拒绝
function TeamTipView:onClickRefuse()
    if self.type == normalType then--来自别人的申请
        self:send1300112(self.roleId,2)
    else--来自别人的邀请
        self:send1300106(self.roleId,2)
    end
    self:closeView()
end
--同意
function TeamTipView:onClickAgree()
    if self.type == normalType then--来自别人的申请
        self:send1300112(self.roleId,1)
    else--来自别人的邀请
        self:send1300106(self.roleId,1)
    end
    self:closeView()
end
--目标玩家id  1同意2拒绝
function TeamTipView:send1300106(tarRoleId,reqType)
    proxy.TeamProxy:send(1300106,{tarRoleId = tarRoleId,reqType = reqType})
end

function TeamTipView:send1300112(tarRoleId,reqType)
    proxy.TeamProxy:send(1300112,{tarRoleId = tarRoleId,reqType = reqType})
end

function TeamTipView:onTimer()
    if self.time <= 0 then
        cache.TeamCache:clearInvitation(0,true)
        self:onClickRefuse()
        return
    end
    self.timeText.text = string.format(language.team17, self.time)
    self.time = self.time - 1
end

return TeamTipView