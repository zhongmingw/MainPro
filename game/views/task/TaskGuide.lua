--
-- Author: 
-- Date: 2017-11-18 00:08:16
--
local ListHeight = {
    [1] = 40,
    [2] = 82,
    [3] = 123,
}
local TaskGuide = class("TaskGuide", base.BaseView)

function TaskGuide:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function TaskGuide:initData()
    -- body
    self:setData()
    self:addGuiide()
end

function TaskGuide:initView()
    local btnclose = self.view:GetChild("n0"):GetChild("n2")
    btnclose.onClick:Add(self.onCloseView,self)

    self.listView = self.view:GetChild("n15")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBack,self)
end

function TaskGuide:cellData(index, obj)
    -- body
    local data = self.data[index+1]
    local type = data.type or 1
    obj.title = language.task17[type]
    obj.data = data
end

function TaskGuide:onCallBack(context)
    -- body
    local data = context.data.data
    if not data then
        return
    end
    if data.type == 1 then
        --做日常
        GgoToDialyTask()
    elseif data.type == 2 then
        --秘境
        GOpenView({id = 1132})
    elseif data.type == 3 then
        --挂机
        local confData = conf.TaskConf:getTaskHook(lvl)
        if confData then
            local sceneId = confData.sceneId
            local pos = confData.pos
            -- printt(confData)
            mgr.TaskMgr:goTaskBy(sceneId,{x = pos[1],z = pos[2]},function()
                -- plog("挂机挂机")
                mgr.HookMgr:startHook()
            end)
        end
    end

    self:onCloseView()
end

function TaskGuide:setData(data_)
    --日常任务
    self.data = {}
    local daydata = cache.TaskCache:getdailyTasks()
    if daydata and #daydata ~= 0 then
        local t = {type = 1}--日常任务
        table.insert(self.data, t)
    end
    --秘境
    local redNum = cache.PlayerCache:getRedPointById(attConst.A50113)
    if mgr.ModuleMgr:CheckView(1132) and redNum > 0 then
        table.insert(self.data, {type = 2})
    end
    --挂机
    table.insert(self.data, {type = 3})

    self.listView.numItems = #self.data
    self.listView.height = ListHeight[self.listView.numItems]
end

function TaskGuide:onCloseView()
    -- body
    self:closeView()
end

function TaskGuide:addGuiide()
    -- body
    local daydata = cache.TaskCache:getdailyTasks()
    if daydata and #daydata ~= 0 then
        --self.listView.scrollPane:ScrollTop()
        local cell = self.listView:GetChildAt(0)
        if cell then
            local param = {}
            param.richang = cell 
            mgr.ViewMgr:openView2(ViewName.GuideLayer,param)
        end

    end
end

return TaskGuide