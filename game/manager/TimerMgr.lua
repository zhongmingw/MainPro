--[[--
时间管理
]]

local TimerMgr = class("TimerMgr")

function TimerMgr:ctor()
    self:init()
    self.timerCount = 1
end

function TimerMgr:init()
    --定时对象
    self.timerObj = {}
end

--定时器跑起来
function TimerMgr:onTimer()
    local nowTime = Time.getTime()
    for key, value in pairs(self.timerObj) do
        if value.delete == 1 or value.loop == 0 then
            self.timerObj[key] = nil
        else
            if (nowTime - value.lastTime) >= value.delay then
                mgr.DebugMgr:startMarkTime()
                local ok,errorInfo = pcall(value.callBack)
                if not ok then  --有报错
                    if g_var.gameState == g_state.formal or g_var.gameState == g_state.ttFormal then  --外网环境打印log
                        print(errorInfo)
                    else --内网直接抛出异常
                        error(errorInfo)
                    end
                end
                --value.callBack()
                if value.loop > 0 then
                    value.loop = value.loop - 1
                end
                value.lastTime = nowTime
                mgr.DebugMgr:endMarkTime(value.tag)
            end
        end
    end
end
--添加延迟一帧执行
function TimerMgr:addDelay(func)
    self:addTimer(0.1, 1, func)
end
--添加定时对象
function TimerMgr:addTimer(delay, loop, func, tag)
    local id = "timer"..self.timerCount
    local params = {timerId=id, loop=loop,delay=delay,callBack=func,tag=tag}
    self:checkTimer(params)
    self.timerCount = self.timerCount + 1
    return id
end

--{timerId="timer", loop=0[-1无限次，1..n对应次数], delay=1,callBack=function}
function TimerMgr:checkTimer(timer)
    if timer.delay < 0.02 then
        plog("定时器不支持0.02秒以下")
        return
    end
    if not self.timerObj[timer.timerId] then
        timer.lastTime = Time.getTime()
        timer.delete = 0
        self.timerObj[timer.timerId] = timer
    else
        plog("[ERROR]->添加重复定时器")
    end
end

--移除定时器
function TimerMgr:removeTimer(timerId)
    if self.timerObj[timerId] then
        self.timerObj[timerId].delete = 1
    end
end

--清理所有的timer
function TimerMgr:dispose()
    self:init()
    self.timerCount = 1
end

return TimerMgr