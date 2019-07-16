--
-- Author: EVE
-- Date: 2017-05-12 14:45:39
-- Desc: 战斗力变化飘字提示
--

local PowerChangeView = class("PowerChangeView", base.BaseView)

function PowerChangeView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3   --UI层级
end

function PowerChangeView:initData(data) --每次打开窗口都会调用
    self:setData(data)
end

function PowerChangeView:initView() --第一次打开窗口时调用
    self.view2 = self.view:GetChild("n16")
    --总战力
    self.textTotalPower = self.view2:GetChild("n2")
    self.textTotalPower.text = " "
    --战力+
    self.textPowerPlus = self.view2:GetChild("n3")
    --帧动画
    self.animFrame = self.view2:GetChild("n13")
    self.animFrame.onPlayEnd:Add(self.onPlayEnd,self)
    --战力差值动效
    self.animEffect = self.view2:GetTransition("t0")
    --战斗力提升LOGO
    self.logo = self.view2:GetChild("n15")
    self.logo.visible = false
end

function PowerChangeView:setData(newPower)
    self.time = 0
    self.flag = false

    self.textPowerPlus.text = ""

    self.oldPower = cache.PlayerCache:getOldPower() -- 旧战力
    self.newPower = newPower                        -- 新战力
    self.textTotalPower.text = self.oldPower        -- 显示旧战力
    self.power = self.newPower - self.oldPower

    self.temp = math.floor(self.power / 7)

    self:onTimer()
    self:addTimer(0.05, -1, handler(self, self.onTimer))
end

function PowerChangeView:onTimer()
    --2)*特效计时 
    if self.time == 0.2 then 
        self.animFrame.visible = true
        self.animFrame:SetPlaySettings(0,-1,1,-1)
    end
    --3)战力跳数
    if self.time >= 0.5 then  
        local tempStr = self.textTotalPower.text     
        if tonumber(tempStr) < self.newPower then
            self.textTotalPower.text = tempStr + self.temp
        else
            self.textTotalPower.text = self.newPower
        end
    end
    --4)显示上浮变化值   
    if self.time >= 1 then        
        if not self.flag and self.power > 0 then
            self.textPowerPlus.text = "+" .. self.power 
            self.animEffect:Play()
            self.flag = true
        end
    end
    --5)整个状态停留X秒
    if self.time > 2.2  then 
        self:closeSelf()
        return
    end
    self.time = self.time + 0.05
end

function PowerChangeView:onPlayEnd() 
    self.animFrame.visible = false
end

function PowerChangeView:closeSelf()
    -- body
    self.logo.visible = false
    self:closeView()
end

return PowerChangeView