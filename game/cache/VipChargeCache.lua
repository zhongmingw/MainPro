local VipChargeCache = class("VipChargeCache",base.BaseCache)

function VipChargeCache:init(  )
    -- body
    self.recharge = {} --充值信息
    self.privilege = {} --特权信息
    self.onLineTime = 0 --在线时间
    self.xianzunTime = 0
    self.xianzunTyTime = nil --白银仙尊体验卡结束时间
    self.upGradePoint = 0 --vip升级红点
end

--获取服务器返回的充值信息并缓存
function VipChargeCache:keepRechargeList( data )
    -- body
    self.recharge = data
end
--获取服务器返回的特权信息并缓存
function VipChargeCache:keepPrivilegeList( data )
    -- body
    -- for i=1,3 do    
    --     local vipStage = 10301+i
    --     cache.PlayerCache:setAttribute(vipStage,data[i])
    -- end
    self.privilege = data
end

--充值列表
function VipChargeCache:getRechargeList()
    -- body
    return self.recharge
end
--特权信息
function VipChargeCache:getPrivilegeList()
    -- body
    return self.privilege
end

--缓存登陆的时间点(用于获取当前在线时间)
function VipChargeCache:setOnlineTime( time )
    -- body
    self.onLineTime = time
end
--返回登陆时间点
function VipChargeCache:getOnlineTime()
    return self.onLineTime
end

--缓存仙尊卡活动时间
function VipChargeCache:setXianzunTime( time )
    -- body
    self.xianzunTime = time or 0
end
--获取仙尊卡活动时间
function VipChargeCache:getXianzunTime()
    return self.xianzunTime
end
--缓存白银仙尊体验卡结束时间
function VipChargeCache:setXianzunTyTime( time )
    -- body
    self.xianzunTyTime = time
end
function VipChargeCache:getXianzunTyTime()
    -- body
    return self.xianzunTyTime
end

--vip升级红点设置
function VipChargeCache:setVipGradeUpRedPoint( num )
    self.upGradePoint = num
end
function VipChargeCache:getVipGradeUpRedPoint()
    return self.upGradePoint
end

return VipChargeCache