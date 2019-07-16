--
-- Author: 
-- Date: 2017-09-24 17:01:03
-- 

local TopLockView = class("TopLockView", base.BaseView)

function TopLockView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level5 
end

function TopLockView:initView()
        self.n2Btn =  self.view:GetChild("n2")
        self.n2Btn.changeOnClick = false
-- self:closeView()
        self.n2Btn.onGripTouchEnd:Add(function()
            if self.n2Btn.value>=93 then
                self.n2Btn.value = 0
                self:closeView()
            else
                self.n2Btn.value = 0
            end

        end,self)
end

function TopLockView:initData()
    self.n2Btn.value = 0
end

function TopLockView:setData(data_)
    
end

function TopLockView:dispose(clear)
    UnityEngine.Application.targetFrameRate = 30
    self.super.dispose(self, clear)
end

return TopLockView