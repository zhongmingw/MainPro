--
-- Author: Your Name
-- Date: 2017-12-07 20:58:18
--

local DailyTaskView = class("DailyTaskView", base.BaseView)

local DailyTaskPanel = import(".DailyTaskPanel") --修仙
function DailyTaskView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function DailyTaskView:initView()
    self.window2 = self.view:GetChild("n0")
    local closeBtn = self.window2:GetChild("btn_close")
    self:setCloseBtn(closeBtn)
    self.controllerC1 =  self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onbtnController,self)

    self.view:GetChild("n1"):GetChild("title").text = language.dailytask01
end

function DailyTaskView:initData()
    GSetMoneyPanel(self.window2,self:viewName())
    self:onbtnController()
end

function DailyTaskView:onbtnController()
    if self.controllerC1.selectedIndex == 0 then --属性
        if not self.DailyTaskPanel then 
            self.DailyTaskPanel = DailyTaskPanel.new(self)
        end
        proxy.ImmortalityProxy:sendMsg(1290101)
    end
end
--日常任务数据设置
function DailyTaskView:updateDailyTask(data)
    if self.DailyTaskPanel then
        self.DailyTaskPanel:setData(data)
    end
end
--领取活跃奖励刷新
function DailyTaskView:getAwardsRefresh(data)
    if self.DailyTaskPanel then
        self.DailyTaskPanel:getAwardsRefresh(data)
    end
end

function DailyTaskView:setData()

end

return DailyTaskView