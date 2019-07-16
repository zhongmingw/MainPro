--
-- Author: 
-- Date: 2018-06-25 16:43:50
--

local DailyActivityView = class("DailyActivityView", base.BaseView)

local ActiveReturn = import(".ActiveReturn") --超值返还
local ActiveChange = import(".ActiveChange") --超值兑换

local PanelName = {
    [1235] = "ActiveReturn",
    [1236] = "ActiveChange",
    [1243] = "ActiveReturn",--超值返还2
    [1244] = "ActiveChange",--超值兑换2
}
local PanelClass = {
    [1235] = ActiveReturn,
    [1236] = ActiveChange,
    [1243] = ActiveReturn,--超值返还2
    [1244] = ActiveChange,--超值兑换2
}

function DailyActivityView:ctor()
    DailyActivityView.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end


function DailyActivityView:initView()
    local closeBtn = self.view:GetChild("n1"):GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)
    self.container = self.view:GetChild("n4")
    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
end


function DailyActivityView:initData(data)
    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:onBtnClose()
        return
    end
    local confData = conf.ActivityConf:getDailyList()
    self.confData = {}
    local flag = false
    for i= 1101,1104 do --活动id
        if activeData.acts and activeData.acts[i] and activeData.acts[i] == 1 then
            flag = true
            break
        end
    end
    if flag then
        for k,v in pairs(confData) do
            -- print(v.id,activeData.acts[v.id])
            if activeData.acts[v.id] and activeData.acts[v.id] == 1 then
                table.insert(self.confData,v)
            end
        end
        
        self.listView.numItems = #self.confData
        self.moduleId = data.index or self.confData[1].module_id
        self:initAct()
        if self.timertick then 
            self:removeTimer(self.timertick)
            self.timertick = nil
        end
        if not self.timertick then 
            self:onTimer()
            self.timertick = self:addTimer(1, -1, handler(self, self.onTimer))
        end
    else
        GComAlter(language.vip11)
        self:onBtnClose()
    end
    -- self.oldCell = nil 

end
function DailyActivityView:onTimer()
    self.classObj[self.moduleId]:onTimer()
end

function DailyActivityView:cellData(index,obj)

    local data = self.confData[index+1]
    if data then
        local icon = obj:GetChild("icon")
        if data.iconup then 
            icon.url = UIPackage.GetItemURL("dailyactivitiy" ,data.iconup)
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

function DailyActivityView:initAct()
    local isFind = false
    for k = 1,self.listView.numItems do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local moduleId = change.module_id
            if self.moduleId == modelId then
                cell.onClick:Call()
                self:initChoose(cell)
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
                self:initChoose(cell)
            end
        end
    end
end

function DailyActivityView:onClickItem(context)
    local cell = context.data
    local data = cell.data
    self:createObj(data.module_id)
    self:initChoose(cell)
end
function DailyActivityView:initChoose(cell)
    if self.oldCell then
        local icon = self.oldCell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("dailyactivitiy" ,self.oldCell.data.iconup)
    end

    if cell then 
        self.oldCell = cell
        local icon = cell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("dailyactivitiy" ,cell.data.icondown)
    end
end
function DailyActivityView:createObj(moduleId)
    if not self.showObj[moduleId] then 
        local name = PanelName[moduleId]
        self.showObj[moduleId] = UIPackage.CreateObject("dailyactivitiy",name)
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

function DailyActivityView:getPanelObj(moduleId)
    return self.showObj[moduleId]
end

function DailyActivityView:sendMsg()
    if self.moduleId == 1235 then  --超值返还
        proxy.ActivityProxy:sendMsg(1030405,{reqType = 0,cfgId = 0})
    elseif self.moduleId == 1236 then -- 超值兑换
        proxy.ActivityProxy:sendMsg(1030406,{reqType = 0,cfgId = 0,num = 0})
    elseif self.moduleId == 1243 then  --超值返还2
        proxy.ActivityProxy:sendMsg(1030407,{reqType = 0,cfgId = 0})
    elseif self.moduleId == 1244 then -- 超值兑换2
        proxy.ActivityProxy:sendMsg(1030408,{reqType = 0,cfgId = 0,num = 0})
    end
end
--服务器返回信息
function DailyActivityView:addMsgCallBack(data)
    if data.msgId == 5030405 and self.moduleId == 1235 then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030406 and self.moduleId == 1236 then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030407 and self.moduleId == 1243 then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030408 and self.moduleId == 1244 then
        self.classObj[self.moduleId]:setData(data)
    end
end

function DailyActivityView:onBtnClose()
    if self.timertick then
        self:removeTimer(self.timertick)
        self.timertick = nil
    end
    self:closeView()
end
return DailyActivityView