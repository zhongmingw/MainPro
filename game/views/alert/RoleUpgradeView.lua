--
-- Author: Your Name
-- Date: 2017-08-02 19:15:50
--

local RoleUpgradeView = class("RoleUpgradeView", base.BaseView)

function RoleUpgradeView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function RoleUpgradeView:initView()
    self.view2 = self.view:GetChild("n3")
    self.t0 = self.view2:GetTransition("t0")
    self.Lvtext = self.view2:GetChild("n2")
end

function RoleUpgradeView:initData(data)
    self.Lvtext.text = data.lv
    self.time = 0
    self.t0:Play()
    self,timer = self:addTimer(0.5, -1, handler(self, self.onTimer))
end

function RoleUpgradeView:onTimer()
    self.time = self.time + 0.5
    if self.time > 1.5 then
        if self.timer then
            self:removeTimer(self.timer)
            self.timer = nil 
        end
        self:closeView()
    end
end

return RoleUpgradeView