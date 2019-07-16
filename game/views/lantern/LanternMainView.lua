--
-- Author: 
-- Date: 2018-01-30 15:26:14
--
--元宵灯会
--周末狂欢
local LanternLoginAward = import("game.views.ydact.ActiveLoginAward")--登录豪礼
local ActiveHddh = import(".ActiveHddh")--花灯兑奖
local ActiveWchd = import(".ActiveWchd")--五彩灯会
local ActiveCdmh = import(".ActiveCdmh")--猜灯谜会
local BriskLantern = import("game.views.laba.ActiveHylb") --活跃情人节

local LanternMainView = class("LanternMainView", base.BaseView)

local PanelName = {
    [1208] = "LanternLoginAward",
    [1209] = "ActiveHddh",
    [1210] = "ActiveWchd",
    [1211] = "ActiveCdmh",
    [1212] = "BriskLantern",
}
local PanelClass = {
    [1208] = LanternLoginAward,
    [1209] = ActiveHddh,
    [1210] = ActiveWchd,
    [1211] = ActiveCdmh,
    [1212] = BriskLantern,
}

function LanternMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
    self.actId = 0
end

function LanternMainView:initView()
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

function LanternMainView:initData(data)
    self.selectId = 0
    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:onBtnClose()
        return
    end
    local confData = conf.ActivityConf:getLanternActList()
    self.confData = {}
    local flag = false
    local t = {3048,1072,3051,3052,1073}
    for i=1 ,#t do
        local id = t[i]
        if activeData.acts and activeData.acts[id] and activeData.acts[id] == 1 then
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
        self:addTimer(1, -1, handler(self, self.onTimer))
    else
        GComAlter(language.vip11)
        self:closeView()
    end
end

function LanternMainView:onTimer()
    if self.modelId == 1211 then
        self.classObj[self.modelId]:onTimer()
    end
end

function LanternMainView:initAct()
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

function LanternMainView:addServerCallback(data)
    self:refreshRed(data)
    self.classObj[self.modelId]:setData(data)
end

function LanternMainView:refreshRed(data)
    if data.msgId == 5030175 and data.reqType == 2 then
        local num = 0
        for k,v in pairs(data.itemGotDatas) do
            if v.gotStatus ~= 3 then
                num = num + 1
            end
        end
        if num >= #data.itemGotDatas then
            mgr.GuiMgr:redpointByVar(attConst.A20163,0)
        end
    end
end

function LanternMainView:cellData(index, obj)
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

function LanternMainView:getChoosePanelObj(modelId)
    return self.showObj[modelId]
end

function LanternMainView:onClickItem(context)
    local sender = context.data
    local data = sender.data
    self.actId = data.id
    if self.selectId ~= data.module_id then
        self.selectId = data.module_id
        self:createObj(data.module_id)
    end
end

function LanternMainView:createObj(modelId)
    if not self.showObj[modelId] then --用来缓存
        local var = PanelName[modelId]
        self.showObj[modelId] = UIPackage.CreateObject("lantern" ,var)
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

function LanternMainView:sendMsg()
    if self.modelId == 1208 then--登录豪礼
        proxy.ActivityProxy:send(1030175,{actId = self.actId,reqType = 1,cid = 0})
    elseif self.modelId == 1209 then--花灯兑奖
        proxy.ActivityProxy:send(1030316,{reqType = 0,cid = 0})
    elseif self.modelId == 1210 then--五彩灯会
        proxy.ActivityProxy:send(1030175,{actId = self.actId,reqType = 1,cid = 0})
    elseif self.modelId == 1211 then--猜灯谜
        proxy.ActivityWarProxy:send(1030179,{reqType = 1,cid = 0})
    elseif self.modelId == 1212 then--活跃元宵
        proxy.ActivityProxy:send(1030317,{reqType = 0,cid = 0})
    end
end

function LanternMainView:refresh()
    self:sendMsg()
end

function LanternMainView:doClearView(clear)
    -- if self.classObj[1166] then self.classObj[1166]:clear() end
end

return LanternMainView