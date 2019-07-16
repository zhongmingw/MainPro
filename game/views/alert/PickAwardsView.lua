--
-- Author: 
-- Date: 2017-04-26 14:57:39
--
--拾取界面
local PickAwardsView = class("PickAwardsView", base.BaseView)

local useTime = PickUseTime --进度条完成时间
function PickAwardsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
end

function PickAwardsView:initData(data)
    self.progressBar.value = 0
    self.progressBar.max = 100
    if self.pickTimer then
        self:removeTimer(self.pickTimer)
    end
    self.pickTimer = nil
    useTime = data.pickUseTime or PickUseTime
    self:setData(data)
end

function PickAwardsView:initView()
    self.progressBar = self.view:GetChild("n14")
end

function PickAwardsView:setData(data)
    self.monsterData = data.monsterData
    if not self.monsterData then --没有采集物信息 强制走完进度条
        self.force = true
    end
    self.func = data.func
    self.startTime = Time.getTime()
    if not self.pickTimer then
        self:onTimer()
        self.pickTimer = self:addTimer(0.2,-1,handler(self, self.onTimer))
    end
end

function PickAwardsView:clear()
    mgr.HookMgr:setPickRoleId("0") 
    mgr.HookMgr:finishPick(true)
    self:closeView()
end

function PickAwardsView:dispose(clear)
    self.func = nil
    self.startTime = Time.getTime()
    if self.pickTimer then
        self:removeTimer(self.pickTimer)
        self.pickTimer = nil
    end
    if gRole and not gRole:isDeadState() then gRole:idleBehaviour() end
    self.super.dispose(self,clear)
end

function PickAwardsView:onTimer()
    local currTime = Time.getTime()
    local var = currTime - self.startTime
    --使用操作杆
    if UJoystick.IsJoystick then
        mgr.InputMgr:IsJoystick()
        return
    end
    if not self.force then
        local obj = mgr.ThingMgr:getObj(ThingType.monster, self.monsterData.roleId)
        if not obj then
            self:clear()
            return
        end
    end
    self.progressBar.value =  var/useTime * self.progressBar.max
    if useTime <= var then
        if self.func then
            self.func()
            self:clear()
        end
    end
end


return PickAwardsView