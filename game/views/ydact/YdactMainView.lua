--
-- Author: 
-- Date: 2017-12-26 11:06:47
--
local ActiveDhnh = import(".ActiveDhnh")--兑换年货
local ActiveLoginAward = import(".ActiveLoginAward")--登录豪礼
local ActiveSjtf = import(".ActiveSjtf")--收集桃符
local ActiveXdzz = import(".ActiveXdzz")--雪地作战
local YdactMainView = class("YdactMainView", base.BaseView)

local PanelName = {
    [1164] = "ActiveLoginAward",
    [1165] = "ActiveDhnh",
    [1166] = "ActiveXdzz",
    [1167] = "ActiveSjtf",
}
local PanelClass = {
    [1164] = ActiveLoginAward,
    [1165] = ActiveDhnh,
    [1166] = ActiveXdzz,
    [1167] = ActiveSjtf,
}

function YdactMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

function YdactMainView:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)
    self.container = self.view:GetChild("n1")
    -- self.confData = conf.ActivityConf:getYdActList() --元旦活动
    self.listView = self.view:GetChild("n5")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
end

function YdactMainView:initData(data)
    self.selectId = data.module_id
    --bxp
    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:onBtnClose()
        return
    end
    local confData = conf.ActivityConf:getYdActList()
    self.confData = {}
    local flag = false
    for i=1056 ,1059 do
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
        self:addTimer(1, -1, handler(self, self.onTimer))
    else
        GComAlter(language.vip11)
        self:onBtnClose()
    end
end

function YdactMainView:onTimer()
    if self.modelId == 1166 then
        self.classObj[self.modelId]:onTimer()
    end
end

function YdactMainView:initAct()
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

function YdactMainView:addServerCallback(data)
    if self.modelId == 1166 and data.msgId == 5470101 then
        self.classObj[self.modelId]:setData(data)
    elseif self.modelId == 1165 and data.msgId == 5030303 then --EVE 兑换年货
        self.classObj[self.modelId]:setData(data)
    elseif data.msgId == 5030302 and self.modelId == 1164 or self.modelId == 1167 then --bxp 登录豪礼&收集桃符
        self.classObj[self.modelId]:setData(data)
    end
end

function YdactMainView:cellData(index, obj)
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

function YdactMainView:getChoosePanelObj(modelId)
    return self.showObj[modelId]
end

function YdactMainView:onClickItem(context)
    local sender = context.data
    local data = sender.data
    if self.selectId ~= data.module_id then
        self:createObj(data.module_id)
        self.selectId = data.module_id
    end
end

function YdactMainView:createObj(modelId)
    if not self.showObj[modelId] then --用来缓存
        local var = PanelName[modelId]
        self.showObj[modelId] = UIPackage.CreateObject("ydact" ,var)
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

function YdactMainView:sendMsg()
    if self.modelId == 1166 then
        proxy.ActivityProxy:send(1470101)
    elseif self.modelId == 1165 then --EVE 
        -- print("兑换年货消息已发送~~~~~~~~~~~~~")
        proxy.ActivityProxy:send(1030303,{reqType = 0})
    elseif self.modelId == 1164 then--bxp登录豪礼
        proxy.ActivityProxy:send(1030302,{reqType = 1})
    elseif self.modelId == 1167 then--bxp收集桃符
        proxy.ActivityProxy:send(1030302,{reqType = 1})
    end
end

function YdactMainView:doClearView(clear)
    if self.classObj[1166] then self.classObj[1166]:clear() end
end
function YdactMainView:onBtnClose()
    self:closeView()
end

return YdactMainView