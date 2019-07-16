--
-- Author: 
-- Date: 2017-11-28 19:32:01
--
local XmzbPanel = import(".XmzbPanel")

local DecideFanePanel = import(".DecideFanePanel")

local PanelFlame = import(".PanelFlame")

local ShenshouPanel = import(".ShenshouPanel")

local PanelActivity = class("PanelActivity", import("game.base.Ref"))

local PanelClass = {
    [1127] = PanelFlame,
    [1139] = XmzbPanel,
    [1140] = DecideFanePanel,
    [1353] = ShenshouPanel
}

local PanelName = {
    [1127] = "PanelFlame",
    [1139] = "XmzbPanel",
    [1140] = "DecideFanePanel",
    [1353] = "ShenshouPanel",
}

local RedPoint = {
    [1127] = {10251,20150},
    [1139] = {attConst.A20133},
    [1140] = {attConst.A20154},
}


function PanelActivity:ctor(mParent)
    self.mParent = mParent
    self.showObj = {}
    self.classObj = {}
    self.index = 0
    self:initPanel()
end

function PanelActivity:initPanel()
    self.gangActives = conf.BangPaiConf:getGangActives()
    local panelObj = self.mParent.view:GetChild("n34")
    self.listView = panelObj:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    self.container = panelObj:GetChild("n2")--活动区域
end

function PanelActivity:setData(data)
    self.listView.numItems = #self.gangActives
    self:nextStep(data.index)
end

function PanelActivity:onTimer()
    if self.classObj[self.moduleId] then
        self.classObj[self.moduleId]:onTimer()
    end

    for i=1,self.listView.numItems do
        local obj = self.listView:GetChildAt(i - 1)
        local data = obj.data
        if data.id == 1353 then
            obj:GetChild("n4").visible = cache.PlayerCache:getRedPointById(attConst.A50133) > 0
        end        
    end
end

--跳转模块
function PanelActivity:nextStep(sort)
    local iSort = sort or self.index
    local index = 0
    for k,v in pairs(self.gangActives) do
        if v.sort == iSort then
            index = k - 1
            break
        end
    end
    -- self.listView:AddSelection(index,false)
    self.listView:ScrollToView(index)
    self.index = sort
    local cell = self.listView:GetChildAt(index)
    cell.onClick:Call()
end

function PanelActivity:cellData(index, obj)
    local data = self.gangActives[index + 1]
    obj.title = data.name
    obj.selectedTitle = data.name
    obj.data = data
end

function PanelActivity:onClickItem(context)
    local data = context.data.data
    self.moduleId = data.id
    self:createPanel()
end

function PanelActivity:createPanel()
    local falg = false
    local moduleId = self.moduleId

    if not self.showObj[moduleId] then --用来缓存
        local var = PanelName[moduleId]
        self.showObj[moduleId] = UIPackage.CreateObject("bangpai" ,var)
        self.container:AddChild(self.showObj[moduleId])
        falg = true
    end

    for k,v in pairs(PanelName) do
        if k == moduleId then
            if falg then
                self.classObj[moduleId] = PanelClass[moduleId].new(self.showObj[moduleId],self.mParent)  
            end
            self:setPanelVisible(k, true)
            self:sendMsg()
        else
            self:setPanelVisible(k, false)
        end
    end
end

function PanelActivity:setPanelVisible(moduleId,visible)
    if self.showObj[moduleId] then
        self.showObj[moduleId].visible = visible
        if not visible then
            self.classObj[moduleId]:clear()
        end
    end
end

function PanelActivity:sendMsg()
    if self.moduleId == 1127 then
        proxy.BangPaiProxy:send(1250502,{reqType=1})
    elseif self.moduleId == 1139 then--仙盟争霸
        proxy.XmhdProxy:send(1360201)
    elseif self.moduleId == 1140 then--主宰神殿
        proxy.XmhdProxy:send(1360202,{reqType = 1})
    elseif self.moduleId == 1353 then--神兽圣域
        --proxy
    end
end
--服务器返回
function PanelActivity:addMsgCallBack(data)
    if self.moduleId == 1127 and data.msgId == 5250502 then --请求仙盟BOSS信息返回
        self.classObj[self.moduleId]:setData(data)
    elseif self.moduleId == 1139 and data.msgId == 5360201 then--仙盟争霸
        self.classObj[self.moduleId]:setData(data)
    elseif self.moduleId == 1140 then--主宰神殿
        if data.msgId == 5360202 then
            self.classObj[self.moduleId]:setData(data)
        elseif data.msgId == 5360204 then--分配
            self.classObj[self.moduleId]:addMsgFpCallBack(data)
        end
    elseif self.moduleId == 1353 then--神兽圣域
        --self.classObj[self.moduleId]:setData(data)
    end
    self:refreshRedPoint()
end

--刷新红点
function PanelActivity:refreshRedPoint()
    for i=1,self.listView.numItems do
        local obj = self.listView:GetChildAt(i - 1)
        local data = obj.data
        local redNum = 0
        if RedPoint[data.id] then
            for k,v in pairs(RedPoint[data.id]) do
                redNum = cache.PlayerCache:getRedPointById(v)
            end
        end
        local visible = redNum > 0
        obj:GetChild("n4").visible = visible
    end
end

function PanelActivity:clear()
    for k,v in pairs(self.classObj) do
        v:clear()
    end
    self.index = 0
end

return PanelActivity