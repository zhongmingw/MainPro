--
-- Author: 
-- Date: 2017-01-10 21:26:32
--

local CollectBarView = class("CollectBarView", base.BaseView)

local useTime = CollectTime --进度条完成时间
function CollectBarView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1 
end

function CollectBarView:initData()
    -- body

    self.bar.value = 0
    self.bar.max = useTime

    self.startTime = Time.getTime()--os.clock()
    if self.st then
        self:removeTimer(self.st)
        self.st = nil 
    end
    self.st =  self:addTimer(0.1,-1,handler(self, self.onTimer))
end

function CollectBarView:initView()
    self.bar = self.view:GetChild("n14")
end

function CollectBarView:setData(id,t)
    self.taskId = id 
    self.confData = t
end

function CollectBarView:clear()
    -- body
    self:closeView()
end

function CollectBarView:add5050104()
    -- body
    --plog("dddd",cache.TaskCache:getextMap(self.taskId,self.confData.targetId))
    self.bar.value = 0
    if self.confData[2] > cache.TaskCache:getextMap(self.taskId,self.confData[1]) then
        self:clear()
        mgr.TaskMgr:openTaskProess() --继续下一条收集任务 
    else
        self:clear()
    end
end

function CollectBarView:onTimer()
    -- body

    local currTime = Time.getTime()
    local var = currTime - self.startTime
    self.bar.value =  var--/useTime * self.bar.max
    if useTime <= var then
        self.startTime = currTime
        proxy.TaskProxy:send(1050104,{taskId = self.taskId,targetId = self.confData.targetId })

        if self.st then
            self:removeTimer(self.st)
            self.st = nil 
        end
    end
  
end

return CollectBarView