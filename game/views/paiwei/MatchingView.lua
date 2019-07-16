--
-- Author: Your Name
-- Date: 2018-01-08 17:58:02
--

local MatchingView = class("MatchingView", base.BaseView)

function MatchingView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function MatchingView:initView()
    self.text = self.view:GetChild("n0")
    local cancelBtn = self.view:GetChild("n3")
    cancelBtn.onClick:Add(self.onClickCancel,self)
end

function MatchingView:onClickCancel()
    print("取消类型",self.type)
    if self.type == 1 then
        proxy.QualifierProxy:sendMsg(1480106,{reqType = 2})
    elseif self.type == 2 then
        local roleId = cache.PlayerCache:getRoleId()
        local teamInfo = cache.PwsCache:getTeamInfo()
        if teamInfo.captainRoleId == roleId then
            proxy.QualifierProxy:sendMsg(1480205,{reqType = 2})
        else
            GComAlter(language.qualifier21)
        end
    end
end

function MatchingView:onTiemr()
    self.num = self.num + 1
    self.text.text = self.num
    if self.num > 60 then
        if self.timer then
            mgr.TimerMgr:removeTimer(self.timer)
            self.timer = nil
        end
        if self.type == 1 then
            proxy.QualifierProxy:sendMsg(1480106,{reqType = 2})
        elseif self.type == 2 then
            proxy.QualifierProxy:sendMsg(1480205,{reqType = 2})
        end
        self:closeView()
    end
end

function MatchingView:initData(data)
    self.type = data.type
    self.num = 0
    self.text.text = self.num
    self.timer = self:addTimer(1,-1,handler(self,self.onTiemr))
end

return MatchingView