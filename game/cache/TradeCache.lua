--
-- Author: 
-- Date: 2017-03-24 20:10:01
--
local TradeCache = class("TradeCache",base.BaseCache)
--[[

--]]
function TradeCache:init()
    self.requestTrade = 0
end

function TradeCache:removeTimer()
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil 
    end
    self.requestTrade = 0
end
--请求交易等待时间
function TradeCache:setrequestTrade(var)
    -- body
    self.requestTrade = var

    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil 
    end
    self.timer = mgr.TimerMgr:addTimer(1, -1, handler(self, self.update), "TradeCache")
end
function TradeCache:getrequestTrade()
    -- body
    return self.requestTrade
end

function TradeCache:update()
    -- body
    self.requestTrade = self.requestTrade - 1 
    if self.requestTrade <=0 then
        --主动取消交易
        GComAlter(language.trade07)
        --proxy.TaskProxy:send(1260205,{tradeType = 2})

        self:removeTimer()
    end
end

return TradeCache