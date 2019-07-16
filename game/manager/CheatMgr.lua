--
-- Author: 王显
-- Date: 2017-10-09 11:47:09
-- 作弊器

local CheatMgr = class("CheatMgr")

function CheatMgr:ctor()
    self.task = {} --任务列表

    self.isCheat = false --是否开挂中
end

function CheatMgr:update()
    -- body
    if not self.isCheat then
        return
    end

    if #self.task == 0 then
        return
    end

    if self.isDoing then
        --有任务执行中
        return
    end

    for k,v in pairs(self.task) do
        if v then
            if self:CheckById(k) then--每秒只执行一项任务
                break
            end
        end
    end
end
--开始作弊
function CheatMgr:StartCheat()
    -- body
    self.isCheat = true

    --定时处理
    self:update()
    if not self.timer then
        self.timer = mgr.TimerMgr:addTimer(1, -1, function()
            self:update()
        end, "CheatMgr")
    end
end
--停止作弊
function CheatMgr:StopCheat()
    -- body
    --self.task = {}
    self.isCheat = false
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil 
    end
end
function CheatMgr:Dispose()
    -- body
    self.task = {}
    self:StopCheat()
end
--添加作弊任务
function CheatMgr:addTask(id,param)
    -- body
    self.task[id] = param or 1
end

--
function CheatMgr:removeTask(id)
    -- body
    self.task[id] = nil
end

function CheatMgr:CheckById(id)
    -- body
    self.isDoing = false
    if id == 1 then
        --地图中检测宝箱位置并且捡取
        self.isDoing = self:checkBoxPick()
    end

    return false
end

function CheatMgr:checkBoxPick()
    -- body
    local sId = cache.PlayerCache:getSId()
    local sConf = conf.SceneConf:getWoldRef(sId)

    if not sConf then
        print("该场景没有宝箱")
        return false
    end



end

function CheatMgr:addByDebugText(text)
    -- body
    if text == "jcsb" then


    end
end





return CheatMgr