--
-- Author:bxp 
-- Date: 2018-12-10 14:29:30
--2018圣诞

local ShengDanMainView = class("ShengDanMainView", base.BaseView)
local ShengDan1001 = import(".ShengDan1001") --登录豪礼
local ShengDan1002 = import(".ShengDan1002") --圣诞宝树
local ShengDan1003 = import(".ShengDan1003") --双倍副本
local ShengDan1004 = import(".ShengDan1004") --激战boss
local ShengDan1005 = import(".ShengDan1005") --圣诞兑换

local PanelName = {
    [1413] = "ShengDan1001",
    [1414] = "ShengDan1002",
    [1415] = "ShengDan1003",
    [1416] = "ShengDan1004",
    [1417] = "ShengDan1005",
}
local PanelClass = {
    [1413] = ShengDan1001,
    [1414] = ShengDan1002,
    [1415] = ShengDan1003,
    [1416] = ShengDan1004,
    [1417] = ShengDan1005,
}
local ActId = {1202,1203,1204,1205,1206}

function ShengDanMainView:ctor()
    ShengDanMainView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

function ShengDanMainView:initView()
    self:setCloseBtn(self.view:GetChild("n9"))
    self.container = self.view:GetChild("n10")
    self.listView = self.view:GetChild("n8")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)

end

function ShengDanMainView:initData(data)

    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:closeView()
        return
    end
    local confData = conf.ActivityConf:getShengDanActList()
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

function ShengDanMainView:onTimer()
    self.classObj[self.moduleId]:onTimer()
end

function ShengDanMainView:initAct()
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


function ShengDanMainView:cellData(index,obj)
    local data = self.confData[index+1]
    if data then
        local icon = obj:GetChild("icon")
        if data.iconup then
            icon.url = UIPackage.GetItemURL("shengdan" ,data.iconup)
        end
        obj.data = data
        if data.redid then
            local param = {}
            param.panel = obj:GetChild("red")
            param.ids = {data.redid}
            param.notnumber = true
            mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
        end
    end
end


function ShengDanMainView:onClickItem(context)
    local cell = context.data
    local data = cell.data
    self:createObj(data.module_id)
    self:initChoose(cell)
    -- self:refreshUI()
end

--选中
function ShengDanMainView:initChoose(cell)
    if self.oldCell then
        local icon = self.oldCell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("shengdan" ,self.oldCell.data.iconup)
    end
    if cell then
        self.oldCell = cell
        local icon = cell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("shengdan" ,cell.data.icondown)
    end
end

function ShengDanMainView:createObj(moduleId)
    if not self.showObj[moduleId] then 
        local name = PanelName[moduleId]
        self.showObj[moduleId] = UIPackage.CreateObject("shengdan",name)
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
function ShengDanMainView:getPanelObj(moduleId)
    return self.showObj[moduleId]
end


function ShengDanMainView:sendMsg()
    if self.moduleId == 1413 then  -- 登录
        proxy.ShengDanProxy:sendMsg(1030670,{reqType = 0})
    elseif self.moduleId == 1414 then -- 宝树
        proxy.ShengDanProxy:sendMsg(1030671,{reqType = 0,cid = 0})
    elseif self.moduleId == 1415 then --双倍副本
        proxy.ShengDanProxy:sendMsg(1030674)
    elseif self.moduleId == 1416 then --boss
        proxy.ShengDanProxy:sendMsg(1030672) 
    elseif self.moduleId == 1417 then --兑换
        proxy.ShengDanProxy:sendMsg(1030673,{reqType = 0,cid = 0}) 
    end
end

function ShengDanMainView:addMsgCallBack(data)
    self.classObj[self.moduleId]:setData(data)
end

return ShengDanMainView