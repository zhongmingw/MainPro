--
-- Author: 
-- Date: 2018-01-08 19:15:00
--
--周末狂欢
local WeekLoginAward = import("game.views.ydact.ActiveLoginAward")--登录豪礼
local FubenDouble = import(".FubenDouble")--副本双倍
local WeekGjsb = import(".WeekGjsb")--野外挂机
local WeekendView = class("WeekendView", base.BaseView)

local PanelName = {
    [1170] = "WeekLoginAward",
    [1171] = "FubenDouble",
    [1193] = "WeekGjsb",
}
local PanelClass = {
    [1170] = WeekLoginAward,
    [1171] = FubenDouble,
    [1193] = WeekGjsb,
}

function WeekendView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

function WeekendView:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n5")
    self:setCloseBtn(closeBtn)
    self.container = self.view:GetChild("n1")
    -- self.confData = conf.ActivityConf:getYdActList() --元旦活动
    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
end

function WeekendView:initData(data)
    --bxp
    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:onBtnClose()
        return
    end
    local confData = conf.ActivityConf:getWeekActList()
    self.confData = {}
    local flag = false

    for i=3035 ,3036 do
        if activeData.acts and activeData.acts[i] and activeData.acts[i] == 1 then
            flag = true
            break
        end
    end
    -- print("flag>>>>",flag)
    if flag then
        for k,v in pairs(confData) do
            if activeData.acts[v.id] and activeData.acts[v.id] == 1 then
                table.insert(self.confData,v)
            end
        end
        self.listView.numItems = #self.confData
        self.modelId = data.index or self.confData[1].module_id --bxp默认第一个id 原来1164
        self:initAct()
    else
        GComAlter(language.vip11)
        self:closeView()
    end
end


function WeekendView:initAct()
    local isFind = false
    for k = 1,self.listView.numItems do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local modelId = change.module_id
            if self.modelId == modelId then--选中boss
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

function WeekendView:addServerCallback(data)
    self:refreshRed(data)
    self.classObj[self.modelId]:setData(data)
end

function WeekendView:refreshRed(data)
    if data.msgId == 5030166 and data.reqType == 2 then
        local num = 0
        for k,v in pairs(data.itemGotDatas) do
            if v.gotStatus ~= 3 then
                num = num + 1
            end
        end
        if num >= #data.itemGotDatas then
            mgr.GuiMgr:redpointByVar(attConst.A20159,0)
        end
    end
end

function WeekendView:cellData(index, obj)
    local data = self.confData[index + 1]
    if data then
        obj.title = data.name or ""
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

function WeekendView:getChoosePanelObj(modelId)
    return self.showObj[modelId]
end

function WeekendView:onClickItem(context)
    local sender = context.data
    local data = sender.data
    self:createObj(data.module_id)
end

function WeekendView:createObj(modelId)
    if not self.showObj[modelId] then --用来缓存
        local var = PanelName[modelId]
        self.showObj[modelId] = UIPackage.CreateObject("weekend" ,var)
        self.container:AddChildAt(self.showObj[modelId],0)--添加新的
    end
    if not self.classObj[modelId] then
        self.classObj[modelId] = PanelClass[modelId].new(self,modelId)   
    end
    for k,v in pairs(self.showObj) do
        if k == modelId then
            v.visible = true
        else
            v.visible = false
        end
    end
    self.modelId = modelId
    self:sendMsg()
end

function WeekendView:sendMsg()
    if self.modelId == 1170 then--登录豪礼
        proxy.ActivityProxy:send(1030166,{reqType = 1,cid = 0})
    elseif self.modelId == 1171 then--副本双倍
        proxy.ActivityProxy:send(1030167,{reqType = 1,cid = 0})
    elseif self.modelId == 1193 then
        proxy.ActivityProxy:send(1030169,{reqType = 1,cid = 0})
    end
end

function WeekendView:refresh()
    self:sendMsg()
end

function WeekendView:doClearView(clear)
    -- if self.classObj[1166] then self.classObj[1166]:clear() end
end

return WeekendView