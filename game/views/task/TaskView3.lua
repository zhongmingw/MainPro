--
-- Author: EVE
-- Date: 2018-04-08 15:34:14
--

local TaskView3 = class("TaskView3", base.BaseView)

function TaskView3:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
    self.isBlack = true
end

function TaskView3:initData(data)
    self.timerCount = 8   --confData.continue or 

    self.data = data

    self:setData()
end

function TaskView3:initView()
    self.view:GetChild("n23"):GetChild("n1").visible = false
    --完成任务
    local completeBtn = self.view:GetChild("n2")
    completeBtn.onClick:Add(self.oncloseView,self)
    --几秒之后自动领取
    self.delayTxt = self.view:GetChild("title")
    --NPC角色模型
    self.model = self.view:GetChild("n32")
    --奖励Logo
    self.n9 = self.view:GetChild("n9")
    self.n9.visible = false
    --箭头
    self.Arrow = self.view:GetChild("n25")
    --箭头动效
    self.t0 = self.view:GetTransition("t0")
    --奖励物品列表
    self.list = self.view:GetChild("n34")
    self.list.visible = false
    --任务描述
    self.taskDesc = self.view:GetChild("n8")
end

function TaskView3:setData()
    local taskId = self.data.data.task_id
    local confData = conf.TaskConf:getTaskById(taskId)
    -- print("taskid:",taskId)
    -- printt(confData)
    --接任务倒计时
    self:onTimer()
    if self.innerTimer then
        self:removeTimer(self.innerTimer)
        self.innerTimer = nil 
    end
    self.innerTimer =  self:addTimer(1,-1,handler(self, self.onTimer))
    --添加npc模型
    self:initModel()
 
    --对话NPC名字
    local name = self.view:GetChild("n7")
    name.text = confData.name
    --经验
    local exppanle = self.view:GetChild("n15")
    exppanle.visible = false
    --任务描述
    self.taskDesc.text = confData.dec
    --播动效
    self.t0:Play()
end

function TaskView3:initModel()
    -- body
    local npcId = self.data.npcId
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
        self.model.data:setPosition(self.model.actualWidth/2,-self.model.actualHeight-400,800)
    else
        self.model.data:setSkins(_npc.body_id)
    end
    --printt("size",self.model.data.goWrapper.width)
end

--完成任务时调一下
function TaskView3:completeTask()

    mgr.FubenMgr:gotoFubenWar(self.data.data.conditions[1][1])
end

function TaskView3:onTimer()
    self.timerCount = self.timerCount - 1
    self.delayTxt.text = string.format(language.task05,self.timerCount)
    if self.timerCount == 0 then
        self:oncloseView()
    end
end

--关闭窗口
function TaskView3:oncloseView()
    self:removeModel(self.model.data)
    self:completeTask()
    self:closeView()
end

return TaskView3