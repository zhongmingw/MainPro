--
-- Author: yr
-- Date: 2016-12-30 15:34:14
--

local TaskView = class("TaskView", base.BaseView)

function TaskView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
    self.isBlack = true
end

function TaskView:initData(data)
    -- body
    -- self.timerCount = 8
    -- self:onTimer()
    -- if self.innerTimer then
    --     self:removeTimer(self.innerTimer)
    --     self.innerTimer = nil 
    -- end
    -- self.innerTimer =  self:addTimer(1,-1,handler(self, self.onTimer))

    -- self.model.data = nil 
end

function TaskView:initView()
    self.view:GetChild("n23"):GetChild("n1").visible = false
    --self:setCloseBtn(self.view:GetChild("n23"):GetChild("n1"))
    --完成任务
    local completeBtn = self.view:GetChild("n2")
    completeBtn.onClick:Add(self.oncloseView,self)

    self.t0 = self.view:GetTransition("t0")
    self.t1 = self.view:GetTransition("t1")
    --几秒之后自动领取
    self.delayTxt = self.view:GetChild("title")
    
    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 0

    self.n9 = self.view:GetChild("n9")

    self.model = self.view:GetChild("n32")
    --self.timer = mgr.TimerMgr:addTimer(1, -1, handler(self, self.onTimer))
end

function TaskView:initModel(param)
    -- body
    local npcId = param.conditions[1][1]
    local _npc = conf.NpcConf:getNpcById(npcId)
    if not _npc then
        if self.model.data then
            self:removeModel(self.model.data)
            self.model.data = nil 
        end
        return
    end 
    if not self.model.data then
        self.model.data = self:addModel(_npc.body_id,self.model)
        self.model.data:setScale(190)
        self.model.data:setRotationXYZ(0,180,0)
        --local height = param.height * 190 / 80
        self.model.data:setPosition(self.model.actualWidth/2,-self.model.actualHeight-400,800)
    else
        self.model.data:setSkins(_npc.body_id)
    end
    --printt("size",self.model.data.goWrapper.width)
end

function TaskView:setData(taskId,flag)
    self.taskId = taskId
    local confData = conf.TaskConf:getTaskById(taskId)
    --local icon = self.view:GetChild("icon")
    --icon.url = 
    --
    self.timerCount = confData.continue or 8
    self:onTimer()
    if self.innerTimer then
        self:removeTimer(self.innerTimer)
        self.innerTimer = nil 
    end
    self.innerTimer =  self:addTimer(1,-1,handler(self, self.onTimer))

    self.model.data = nil 
    
    self:initModel(confData)


    --名字
    local name = self.view:GetChild("n7")
    name.text = confData.rewardname
    --完成描述
    self.view:GetChild("n8").text = confData.finishdec

    local exppanle = self.view:GetChild("n15")
    exppanle.visible = false
    --plog("taskId",taskId)
    local list = {}
    for  i = 10 , 13 do 
        --plog(i)
        local frame = self.view:GetChild("n"..i)
        frame.visible = false
        table.insert(list,frame)
    end
    if confData.finish_items then
        self.n9.visible = true
        local index = 1
        for k ,v in pairs(confData.finish_items) do
            if list[index] then
                list[index].visible = true
                local itemData = {}
                itemData.mid = v[1]
                itemData.amount = v[2]
                itemData.bind = v[3]
                GSetItemData(list[index],itemData,false)

                index = index + 1
            end
        end
    else
        self.n9.visible = false
    end
    --是否是新手应道
    if flag then
        self.c1.selectedIndex = 1
    end

    if self.c1.selectedIndex == 0 then
        self.t0:Play()
    else
        self.t1:Play()
    end
end

function TaskView:completeTask()
    -- body
    --plog("发 = "..self.taskId)
    local index = tonumber(string.sub(tostring(self.taskId),1,1))
    if index == 1 then
        proxy.TaskProxy:send(1050103,{taskId = self.taskId})  
    elseif index == 4 then
        local data = conf.TaskConf:getTaskById(self.taskId)
        mgr.ViewMgr:openView2(ViewName.TaskOneView,clone(data))
        -- param = {}
        -- param.taskId = self.taskId
        -- param.reqType = 1
        -- --printt("param 1050201",param)
        -- proxy.TaskProxy:send(1050201, param)
    end
end

function TaskView:oncloseView()
    self:completeTask()
    self:closeView()
end

function TaskView:onTimer()
    self.timerCount = self.timerCount - 1
    self.delayTxt.text = string.format(language.task05,self.timerCount)
    if self.timerCount == 0 then
        self:oncloseView()
    end
end

return TaskView