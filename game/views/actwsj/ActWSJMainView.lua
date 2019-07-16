--
-- Author: 
-- Date: 2018-10-22 11:50:20
--
local WSJ1001 = import(".WSJ1001") --登录豪礼
local WSJ1002 = import(".WSJ1002") --捣蛋BOSS
local WSJ1003 = import(".WSJ1003") --惊喜兑换
local WSJ1004 = import(".WSJ1004") --降妖除魔
local ActWSJMainView = class("ActWSJMainView", base.BaseView)

local PanelName = {
    [1369] = "WSJ1001",
    [1370] = "WSJ1002",
    [1371] = "WSJ1003",
    [1372] = "WSJ1004",
}
local PanelClass = {
    [1369] = WSJ1001,
    [1370] = WSJ1002,
    [1371] = WSJ1003,
    [1372] = WSJ1004,
}
local ActId = {1172,1173,1174,3096}

function ActWSJMainView:ctor()
    ActWSJMainView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

function ActWSJMainView:initView()
    self:setCloseBtn(self.view:GetChild("n2"))
    self.container = self.view:GetChild("n4")
    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
end

function ActWSJMainView:initData(data)

    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:closeView()
        return
    end
    local confData = conf.ActivityConf:getWSJActList()
    self.confData = {}
    local flag = false
    for k,v in pairs(ActId) do
        if activeData.acts and activeData.acts[v] and activeData.acts[v] == 1 then
            flag = true
            break
        end
    end
    if flag then
        for k,v in pairs(confData) do
            if activeData.acts[v.id] and activeData.acts[v.id] == 1 then
                table.insert(self.confData,v)
            end
        end
        
        self.listView.numItems = #self.confData
        self.moduleId = data.index or self.confData[1].module_id
        self:initAct()
        if self.timer then
            self:removeTimer(self.timer)
            self.timer = nil
        end
        self.timer = self:addTimer(1, -1, handler(self,self.onTimer))
    else
        GComAlter(language.vip11)
        self:closeView()
    end
end

function ActWSJMainView:onTimer()
    -- if self.moduleId == 1370 or self.moduleId == 1372 then
        self.classObj[self.moduleId]:onTimer()
    -- end
end

function ActWSJMainView:initAct()
    local isFind = false
    for k = 1,self.listView.numItems do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local moduleId = change.module_id
            if self.moduleId == moduleId then
                cell.onClick:Call()
                isFind =true
                break
            end
        end
    end
    if not isFind then
        if self.listView.numItems > 0 then
            local cell = self.listView:GetChildAt(0)
            if cell then
                cell.onClick:Call()
            end
        end
    end
end

function ActWSJMainView:cellData(index,obj)
    local data = self.confData[index+1]
    if data then
        -- obj.icon = data.name or ""
        local icon = obj:GetChild("icon")
        if data.iconup then
            icon.url = UIPackage.GetItemURL("actwsj" ,data.iconup)
        end
        obj.data = data
        if data.redid then
            local param = {}
            param.panel = obj:GetChild("red")
            param.ids = {data.redid}
            param.notnumber = true
            mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
        end
        if data.id == 3096 then--降妖除魔
            local endTime =cache.PlayerCache:getRedPointById(20208)
            -- print("endTime",endTime)
            --持续时间
            local duringTime = conf.WSJConf:getValue("wsj_act_time")
            --活动进入时间，超过时间后无法再进
            local lastTime = conf.WSJConf:getValue("wsj_limit_in_time")

            local openTime = endTime - duringTime
            local severTime = mgr.NetMgr:getServerTime()
            -- print("severTime",severTime)

            if severTime >= openTime  and severTime <= (openTime+lastTime) then
                 obj:GetChild("red").visible = true
            else
                 obj:GetChild("red").visible = false
            end
        end
    end
end

function ActWSJMainView:onClickItem(context)
    local cell = context.data
    local data = cell.data
    self:createObj(data.module_id)
    self:initChoose(cell)
    -- self:refreshUI()
end

--选中
function ActWSJMainView:initChoose(cell)
    if self.oldCell then
        local icon = self.oldCell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("actwsj" ,self.oldCell.data.iconup)
    end
    if cell then
        self.oldCell = cell
        local icon = cell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("actwsj" ,cell.data.icondown)
    end
end

function ActWSJMainView:createObj(moduleId)
    if not self.showObj[moduleId] then 
        local name = PanelName[moduleId]
        self.showObj[moduleId] = UIPackage.CreateObject("actwsj",name)
        self.container:AddChildAt(self.showObj[moduleId],0)
    end
    if not self.classObj[moduleId] then
        self.classObj[moduleId] = PanelClass[moduleId].new(self,moduleId)   
    end
    for k,v in pairs(self.showObj) do
        if k == moduleId then
            v.visible = true
        else
            v.visible = false
        end
    end
    self.moduleId = moduleId
    self:sendMsg()
end
function ActWSJMainView:getPanelObj(moduleId)
    return self.showObj[moduleId]
end


function ActWSJMainView:sendMsg()
    if self.moduleId == 1369 then  -- 登录
        proxy.WSJProxy:send(1030642,{reqType = 0})
    elseif self.moduleId == 1370 then -- boss
        proxy.WSJProxy:send(1030643,{reqType = 0})
    elseif self.moduleId == 1371 then --兑换
        proxy.WSJProxy:send(1030644,{reqType = 0,cid = 0})
    elseif self.moduleId == 1372 then --降妖除魔
        proxy.WSJProxy:send(1030641) 
    end
end

function ActWSJMainView:addMsgCallBack(data)
    if data.msgId == 5030642 and self.moduleId == 1369 then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030643 and self.moduleId == 1370 then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030644 and self.moduleId == 1371  then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030641 and self.moduleId == 1372 then 
        self.classObj[self.moduleId]:setData(data)
    end
end



return ActWSJMainView