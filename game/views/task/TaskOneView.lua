--
-- Author: 
-- Date: 2017-03-17 21:58:05
--

local TaskOneView = class("TaskOneView", base.BaseView)

function TaskOneView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true  
end

function TaskOneView:initData(data)
    -- body
    if not data then
        plog("传递参数错误@wx")
        self:closeView()
        return
    end
    --self.data = data
    if not self.data then
        self.data = data
    else
        if self.data.task_id == data.task_id then
            return
        else
            self.data = data
        end
    end

    self.width = 0
    self.timer = 10 
    self.dec2.text = string.format(language.mian07,self.timer)
    self:setData()

    if self.dd then
        self:removeTimer(self.dd)
        self.dd = nil 
    end
    self.dd = self:addTimer(1,-1, handler(self,self.onTimer))


end

function TaskOneView:initView()
    local btnClose = self.view:GetChild("n2"):GetChild("n7")
    btnClose.onClick:Add(self.onBtnget,self)

    local btn15 = self.view:GetChild("n3")
    btn15.onClick:Add(self.onBtn15get,self)

    local btnget = self.view:GetChild("n4")
    btnget.onClick:Add(self.onBtnget,self)

    self.dec1 = self.view:GetChild("n8")
    self.dec2 = self.view:GetChild("n9")
    self.money = self.view:GetChild("n10")
    -- self.money2 = self.view:GetChild("n18")

    

    self.listView = self.view:GetChild("n7")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
end

function TaskOneView:initDec()
    -- body
    self.dec1.text = ""
    self.dec2.text = ""
    self.money.text = ""
    -- self.money2.text = ""
end

function TaskOneView:celldata(index,obj)
    -- body

    local data = self.confData1.awards[index+1]
    local t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj,t,true)

    self.width = obj.actualWidth + self.width
    if index + 1 == self.listView.numItems then
        self.listView.viewWidth = self.width
    else
        self.width = self.width + self.listView.columnGap
    end
end

function TaskOneView:setData(data_)
    --self.width = 0
    --self.data = data_
    self.dec1.text = language.mian06
    local cur 
    local max 
    --plog("self.data.task_id",self.data.task_id)
    if self.data.type == 4 then
        self.use = conf.TaskConf:getValue("daily_mul_award_cost")
        self.confData1 = conf.TaskConf:getTaskDailyAward(cache.PlayerCache:getRoleLevel())

        cur = cache.TaskCache:getdailyFinishCount()
        max = conf.TaskConf:getValue("daily_finish_max") 
    elseif self.data.type == 5 then
        self.use = conf.TaskConf:getValue("gang_mul_award_cost")
        self.confData1 = conf.TaskConf:getTaskGangAward(self.data.task_id)

        cur = cache.TaskCache:getgangFinishCount()
        max = conf.TaskConf:getValue("gang_finish_max") 
    end

    if cur + 1 >= max then--完成所有
        self.all = true
    else
        self.all = false
    end


    if self.use <= cache.PlayerCache:getTypeMoney(MoneyType.gold) then
        self.isget = true
        self.money.text = mgr.TextMgr:getTextColorStr(self.use, 7)
    else
        self.isget = false
        self.money.text = mgr.TextMgr:getTextColorStr(self.use, 14)
    end
    -- self.money2.text = self.use

    self.listView.numItems = (self.confData1 and self.confData1.awards) and #self.confData1.awards  or 0
end

function TaskOneView:onTimer()
    -- body

    self.timer = self.timer - 1 
    if self.timer <= 0 then
        self:onBtnget()
    else
        self.dec2.text = string.format(language.mian07,self.timer)
    end

end

function TaskOneView:onBtnget()
    -- body
    if self.data.type == 4 then
        param = {}
        param.taskId = self.data.task_id
        param.reqType = 1
        --printt("param 1050201",param)
        proxy.TaskProxy:send(1050201, param)
    elseif self.data.type == 5 then
        param = {}
        param.taskId = self.data.task_id
        param.reqType = 1
        --printt("param 1050301",param)
        proxy.TaskProxy:send(1050301, param)
    end
    self:onBtnClose()
end

function TaskOneView:onBtn15get()
    -- body
    if not self.isget then
        GComAlter(language.gonggong18)
        return
    end
    if self.data.type == 4 then
        param = {}
        param.taskId = self.data.task_id
        param.reqType = 2
        proxy.TaskProxy:send(1050201, param)
        self:onBtnClose()
    elseif self.data.type == 5 then
        param = {}
        param.taskId = self.data.task_id
        param.reqType = 2
        proxy.TaskProxy:send(1050301, param)
        self:onBtnClose()
    end
end

function TaskOneView:onBtnClose()
    -- body
     
    if self.all then
        mgr.ViewMgr:openView(ViewName.TaskOverView, function(view)
            -- body
            view:setData(clone(self.data))
        end)
    end
    self.data = nil
    self:closeView() 
end

return TaskOneView