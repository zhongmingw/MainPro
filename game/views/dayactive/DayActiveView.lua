--
-- Author: Your Name
-- Date: 2017-06-15 14:26:39
--
-- local Active1032 = import(".Active1032")--1032 --特惠礼包
-- local Active1033 = import(".Active1033")--1033 --每日累充
local Active1001 = import(".Active1001")--1001-1008--开服进阶排行
local Active1023 = import(".Active1023")--3001-3008 --坐骑进阶排行
local Active1009 = import(".Active1009")--1009-1016--开服进阶日
local Active3001 = import(".Active3001")--3001-3008 --进阶日活动
local DayActiveView = class("DayActiveView", base.BaseView)

function DayActiveView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function DayActiveView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n5")
    btnClose.onClick:Add(self.onBtnClose,self)
    self.listView = self.view:GetChild("n2")
    self.listView.onClickItem:Add(self.onUIClickCall,self)
    self.panel = self.view:GetChild("n3")
    self:initListView()
end

function DayActiveView:initListView()
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function DayActiveView:celldata( index,obj )
    local data = self.confData[index+1]
    if data then
        local icon = obj:GetChild("icon")
        if data.iconup then
            icon.url = UIPackage.GetItemURL("dayactive" ,data.iconup)
        end
        obj.data = data
        if data.redid then
            local param = {}
            param.panel = obj:GetChild("n4")
            param.text = obj:GetChild("n5") 
            param.ids = {data.redid}
            param.notnumber = true
            mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
        end
    end
end

function DayActiveView:initData(data)
    self.classObj = {}
    if self.showObj then
        for k ,v in pairs(self.showObj) do
            v:Dispose()
        end 
    end
    self.showObj = {}
    self.childIndex = data.childIndex
    self:addTimer(1,-1,handler(self,self.onTimer))
end

function DayActiveView:onTimer()
    -- body
    if not self.param then
        return
    end

    if not self.param.id then
        return
    end

    if not self.classObj then
        return
    end

    if not self.classObj[self.param.id] then
        return
    end


    self.classObj[self.param.id]:onTimer()
    
end

--24点刷新
function DayActiveView:update24()
    -- body
    if self.param then
        -- print("刷新",self.param.id)
        if self.param.id == 1032 then --24点时候刷新一次
            proxy.ActivityProxy:sendMsg(1030116, {reqType = 0,amount = 0,buyId = 0,typeId = 1032}) 
        elseif self.param.id == 1033 then
            proxy.ActivityProxy:sendMsg(1030120, {reqType = 0,awardId = 0,activityId = 1033})
        end
    end
end

function DayActiveView:nextStep(id)
    if id then
        for k,v in pairs(self.confData) do
            local cell = self.listView:GetChildAt(k - 1)
            local cellData = cell and cell.data or nil
            if cellData and cellData.id == id then
                self:initChoose(cell)
                self.listView:AddSelection(k-1,false)
                self.listView:ScrollToView(cellData.index)
                self.param = {id = id}
                self:openActive()
                break
            end
        end
    else
        self:initChoose(self.listView:GetChildAt(0))
        local cell = self.listView:GetChildAt(0)
        self.listView:AddSelection(0,false)
        self.param = {id = cell.data.id}
        self:openActive()
    end
end

--选中
function DayActiveView:onUIClickCall(context)
    -- body
    local cell = context.data
    local data = cell.data
    self:initChoose(cell)
    --按活动ID打开界面
    self.param = {id = data.id}
    self:openActive()
end

function DayActiveView:initChoose(cell)
    if self.oldCell then
        local icon = self.oldCell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("dayactive" ,self.oldCell.data.iconup)
    end

    if cell then
        self.oldCell = cell
        local icon = cell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("dayactive" ,cell.data.icondown)
    end
end

function DayActiveView:openActive()
    local id = self.param.id
    local falg = false
    if not self.showObj[id] then --用来缓存
        local index = id 
        if id <= 1008 or id == 1023 then --都是一个组件
            index = 1023
        elseif id <= 1016 or id == 1040 then
            index = 1009
        -- elseif id == 1023 then--坐骑进阶排行
        --     index = 1023
        end 
        if id >= 3001 and id <= 3008 then
            index = 3001
        end
        local var = "Active"..index
        -- print("活动界面",index)
        self.showObj[id] = UIPackage.CreateObject("dayactive",var)
        falg = true
    end
    --移除旧的
    self.panel:RemoveChildren()
    --添加新的
    self.panel:AddChild(self.showObj[id])
    -- if id == 1032 then --每日特惠礼包
    --     if falg then
    --         self.classObj[id] = Active1032.new(self.showObj[id])
    --     end
    --     --plog("send 1030116")
    --     self.classObj[id]:setCurId(id)
    --     proxy.ActivityProxy:sendMsg(1030116, {reqType = 0,amount = 0,buyId = 0,typeId = 1032})
    -- elseif id == 1033 then --每日累充
    --     if falg then
    --         self.classObj[id] = Active1033.new(self.showObj[id])
    --     end
    --     self.classObj[id]:setCurId(id)
    --     proxy.ActivityProxy:sendMsg(1030120, {reqType = 0,awardId = 0,activityId = 1033})
    if id <= 1008 or id == 1023 then-- 请求开服进阶大比拼排行榜信息
        if falg then
            self.classObj[id] = Active1023.new(self.showObj[id])
        end
        --plog(self.classObj[id],"self.classObj[id]")
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030109, {actId = id})
    elseif id <= 1016 or id == 1040 then --开服进阶目标
        if falg then
            self.classObj[id] = Active1009.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        -- print("活动id",id)
        proxy.ActivityProxy:sendMsg(1030110, {actId = id,reqType=0,awardId=0})
    elseif id >= 3001 and id <= 3008 then
        if falg then
            self.classObj[id] = Active3001.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030110, {actId = id,reqType=0,awardId=0})
    -- elseif id == 1023 then--坐骑进阶排行
    --     if falg then
    --         self.classObj[id] = Active1023.new(self.showObj[id])
    --     end
    --     self.classObj[id]:setCurId(id)
    --     proxy.ActivityProxy:sendMsg(1030109, {actId = id})
    end
end

function DayActiveView:setData(data)
    -- print("开服天数",data.openDay)
    self.openDay = data.openDay
    -- self.acts = data.acts
    local confData = conf.ActivityConf:getActiveList() --日常活动
    self.confData = {} --日常活动列表里的活动
    for k,v in pairs(confData) do
        if data.acts[v.id] and data.acts[v.id] == 1 then
            table.insert(self.confData,v)
            -- print("活动",v.id)
        end
    end
    self.listView.numItems = #self.confData
    self:nextStep(self.childIndex)
end

function DayActiveView:onBtnClose()
    for k ,v in pairs(self.showObj) do
        v:Dispose()
    end 
    self.showObj = {}
    self.classObj = {}
    self:closeView()
end

--活动请求消息返回
function DayActiveView:addMsgCallBack(data)
    -- if 5030116 == data.msgId and self.param.id == 1032 then
    --    -- plog("5030116",5030116)
    --     self.classObj[self.param.id]:add5030116(data)
    -- elseif 5030120 == data.msgId and self.param.id == 1033 then
    --     self.classObj[self.param.id]:setOpenDay(self.openDay)
    --     self.classObj[self.param.id]:add5030120(data)
    if 5030109 == data.msgId and (self.param.id <= 1008 or self.param.id == 1023) then --什么鬼消息
        self.classObj[self.param.id]:add5030109(data)
    elseif 5030110 == data.msgId and (self.param.id <= 1016 or self.param.id == 1040) then
        self.classObj[self.param.id]:add5030110(data)
    -- elseif 5030110 == data.msgId and self.param.id >= 3001 and self.param.id <= 3008 then
    --     self.classObj[self.param.id]:add5030110(data)
    end
end

return DayActiveView