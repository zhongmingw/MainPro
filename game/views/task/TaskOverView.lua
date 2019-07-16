--
-- Author: 
-- Date: 2017-03-18 10:55:37
--

local TaskOverView = class("TaskOverView", base.BaseView)

function TaskOverView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true
    
end

function TaskOverView:initData()
    -- body
    self.width = 0
    self.reward = {}
end

function TaskOverView:initView()
    self.c1 = self.view:GetController("c1")

    local btnClose = self.view:GetChild("n2"):GetChild("n7")
    btnClose.onClick:Add(self.onBtnClose,self)

    local dec = self.view:GetChild("n8")
    dec.text = language.mian08

    self.listView = self.view:GetChild("n7")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    local btnget = self.view:GetChild("n4")
    btnget.onClick:Add(self.onBtnget,self)

    
end

function TaskOverView:celldata(index,obj)
    -- body
    local data = self.confData1.awards[index+1]
    local t = {mid = data[1],amount = data[2],bind = data[3]}

    table.insert(self.reward,t)
    GSetItemData(obj,t,true)

    -- self.width = obj.actualWidth + self.width
    -- if index + 1 == self.listView.numItems then
    --     self.listView.viewWidth = self.width
    -- else
    --     self.width = self.width + self.listView.columnGap
    -- end
end

function TaskOverView:setData(data_)
    if not data_ then
        self:onBtnClose()
        return
    end

    self.width = 0
    self.data = data_
    if self.data.type == 4 then
        self.c1.selectedIndex = 0
        self.confData1 = conf.TaskConf:getTaskDailyexTaward(self.data.task_id)
    elseif self.data.type == 5 then
        self.c1.selectedIndex = 1
        self.confData1 = conf.TaskConf:getTaskGangexTaward(self.data.task_id)
    end
    self.listView.numItems = (self.confData1 and self.confData1.awards) and #self.confData1.awards or 0
end

function TaskOverView:onBtnget()
    -- body
    --GOpenAlert3(self.reward)
    self:onBtnClose()
end

function TaskOverView:onBtnClose()
    -- body
    mgr.HookMgr:cancelHook()
    self:closeView()
end

return TaskOverView