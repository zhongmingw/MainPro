--
-- Author: Your Name
-- Date: 2018-01-16 15:57:19
--

local PwsTeamTipView = class("PwsTeamTipView", base.BaseView)

function PwsTeamTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function PwsTeamTipView:initView()
    local closeBtn = self.view:GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.nameTxt = self.view:GetChild("n3")
    self.powerTxt = self.view:GetChild("n8")
    self.timeTxt = self.view:GetChild("n7")
    self.agreeBtn = self.view:GetChild("n6")
    self.agreeBtn.onClick:Add(self.onClickAgree,self)
    self.refuseBtn = self.view:GetChild("n5")
    self.refuseBtn.onClick:Add(self.onClickRefuse,self)
end

function PwsTeamTipView:initData(data)
    self.data = data
    if data.type == 1 then--申请
        self.nameTxt.text = data.roleName .. language.qualifier18
        self.powerTxt.text = string.format(language.team31,data.rolePower)
    else
        self.nameTxt.text = data.roleName .. language.qualifier18_1
    end

    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
    self.time = 10
    self.timeTxt.text = string.format(language.team17,self.time) 
    self.timer = self:addTimer(1, -1, handler(self,self.onTimer))
end

function PwsTeamTipView:onTimer()
    if self.time > 0 then
        self.time = self.time - 1
        self.timeTxt.text = string.format(language.team17,self.time)
    else
        self:onClickRefuse()
    end
end

--同意
function PwsTeamTipView:onClickAgree()
    local reqType = 8
    if self.data.type == 1 then
        reqType = 8
    else
        reqType = 6
    end
    local param = {roleId = self.data.roleId,reqType = reqType,teamId = self.data.teamId}
    proxy.QualifierProxy:sendMsg(1480204,param)
    self:closeView()
end
--拒绝
function PwsTeamTipView:onClickRefuse()
    local reqType = 11
    if self.data.type == 1 then
        reqType = 11
        local param = {roleId = self.data.roleId,reqType = reqType,teamId = self.data.teamId}
        proxy.QualifierProxy:sendMsg(1480204,param)
    end
    self:closeView()
end

return PwsTeamTipView