--
-- Author: yr
-- Date: 2017-11-29 15:48:06
-- 测试工具

local DebugMgr = class("DebugMgr")

function DebugMgr:ctor()
    self.isMarkTime = false  --特别耗时的地方记录：定时器，消息
    self.isProfile = false  --全局方法耗时记录
end

-- 获取全局变量变化异常打印
function DebugMgr:globalVarInfo()
    if not self.gCount then
        self.gList = {}
        self.gCount = table.nums(_G)
        for k, v in pairs(_G) do
            self.gList[k] = 1
        end
    else
        local tempc = table.nums(_G)
        if self.gCount ~= tempc then
            print("全局变量数目：", tempc, "新增：", tempc - self.gCount)
            self.gCount = tempc
            for k, v in pairs(_G) do
                if self.gList[k] == nil then
                    print("新增全局变量名：", k)
                end
                self.gList[k] = 1
            end
        end
    end
end

--------------------------------------------------------------------------------

function DebugMgr:start(mode)
    if self.isProfile == false then return end

    self.reports         = {}
    self.reportsByTitle  = {}
    -- 记录开始时间
    self.startime = os.clock()
    -- 开始hook，注册handler，记录call和return事件
    debug.sethook(function(t)
        local funcinfo = debug.getinfo(2, 'nS')
        --local localInfo = debug.getlocal(2, 1)
        self:profilingHandler(t, funcinfo, localInfo)
    end, "cr", 0)
end

function DebugMgr:stop(mode)
    self.stoptime = os.clock()
    debug.sethook()
    local totaltime = self.stoptime - self.startime
    -- 排序报告
    table.sort(self.reports, function(a, b)
        return a.totaltime > b.totaltime
    end)

    printt(self.reports)
    -- 格式化报告输出
    for _, report in ipairs(self.reports) do

        local percent = (report.totaltime / totaltime) * 100
        if percent < 1 then
            break
        end

        --print("%6.3f, %6.2f%%, %7d, %s", report.totaltime, percent, report.callcount, report.title)
    end
end

function DebugMgr:profilingCall(funcinfo)
    local report = self:report(funcinfo)
    assert(report)
    report.calltime    = os.clock()
    report.callcount   = report.callcount + 1
end

function DebugMgr:profilingReturn(funcinfo, localInfo)
    local stoptime = os.clock()
    local report = self:report(funcinfo)
    assert(report)
    if report.calltime and report.calltime > 0 then
        local costTime = stoptime - report.calltime
        if costTime > 0.08 then
            print("函数执行耗时："..string.format("%.2fs", costTime)..", 类名：", funcinfo.source,"===>方法：",funcinfo.name or funcinfo.linedefined)
        end

        -- report.totaltime = report.totaltime + (stoptime - report.calltime)
        report.calltime = 0
    end
end

function DebugMgr:profilingHandler(hooktype, funcinfo, localInfo)
    --local funcinfo = debug.getinfo(2, 'nS') 
    if hooktype == "call" then
        self:profilingCall(funcinfo)
    elseif hooktype == "return" then
        self:profilingReturn(funcinfo, localInfo)
    end

end

function DebugMgr:title(funcinfo)
    assert(funcinfo)
    local name = funcinfo.name or 'anonymous'
    local line = string.format("%d", funcinfo.linedefined or 0)
    local source = funcinfo.short_src or 'C_FUNC'
    -- if os.isfile(source) then
    --     source = path.relative(source, xmake._PROGRAM_DIR)
    -- end
    --print("################", funcinfo.short_src)
    return string.format("%-30s: %s: %s", name, source, line)
end

function DebugMgr:report(funcinfo)
    local title = self:title(funcinfo)
    local report = self.reportsByTitle[title]
    if not report then
        report = 
        {
            title       = title
        ,   callcount   = 0
        ,   totaltime   = 0
        }

        self.reportsByTitle[title] = report
        table.insert(self.reports, report)
    end

    return report
end

--------------------------------------------------------------------------------
function DebugMgr:startMarkTime()
    if not self.isMarkTime then return end
    self.lastTime = Time.getTime()
end

function DebugMgr:endMarkTime(info)
    if not self.isMarkTime then return end

    local costTime = Time.getTime() - self.lastTime
    if costTime > 0.05 then
        print("耗时记录：", costTime, "信息：", info)
    end
end

return DebugMgr