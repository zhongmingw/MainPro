--[[--
  伤害数据
]]

local HurtInfo = class("HurtInfo")

function HurtInfo:ctor()
    self.attackId = 0
    self.thingId = 123456    --受击目标id
    self.thingType = 7       --目标类型| 主角？ 玩家？ 怪物？
end

function HurtInfo:addHurt(hurt)
    self.hurts = hurt
end

return HurtInfo