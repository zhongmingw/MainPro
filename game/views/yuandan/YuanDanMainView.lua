--
-- Author: 
-- Date: 2018-12-18 14:07:20
--

local YuanDanMainView = class("YuanDanMainView", base.BaseView)

local YuanDan1001 = import(".YuanDan1001") --登录豪礼
local YuanDan1002 = import(".YuanDan1002") --元旦投资
local YuanDan1003 = import(".YuanDan1003") --boss惊喜
local YuanDan1004 = import(".YuanDan1004") --秘境探索
local YuanDan1005 = import(".YuanDan1005") --记忆花灯

local PanelName = {
    [1431] = "YuanDan1001",
    [1432] = "YuanDan1002",
    [1433] = "YuanDan1003",
    [1434] = "YuanDan1004",
    [1436] = "YuanDan1005",
}
local PanelClass = {
    [1431] = YuanDan1001,
    [1432] = YuanDan1002,
    [1433] = YuanDan1003,
    [1434] = YuanDan1004,
    [1436] = YuanDan1005,
}
local ActId = {1209,1210,1211,1214}

function YuanDanMainView:ctor()
    YuanDanMainView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

function YuanDanMainView:initView()
    self:setCloseBtn(self.view:GetChild("n3"))
    self.container = self.view:GetChild("n2")
    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)

end

function YuanDanMainView:initData(data)

    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:closeView()
        return
    end
    local confData = conf.ActivityConf:getYuanDanActList()
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

function YuanDanMainView:onTimer()
    self.classObj[self.moduleId]:onTimer()
end

function YuanDanMainView:refeshList()
    if self.confData then
        self.listView.numItems = #self.confData
    end
end

function YuanDanMainView:refresh20215()
    if self.classObj[1436] then
        self.classObj[1436]:refeshNextStartTime()
    end
end

function YuanDanMainView:initAct()
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


function YuanDanMainView:cellData(index,obj)
    local data = self.confData[index+1]
    if data then
        local icon = obj:GetChild("icon")
        if data.iconup then
            icon.url = UIPackage.GetItemURL("yuandan" ,data.iconup)
        end
        obj.data = data
        if data.redid then
            local param = {}
            param.panel = obj:GetChild("red")
            param.ids = {data.redid}
            param.notnumber = true
            if data.redid == 20214  then
                local number = cache.PlayerCache:getRedPointById(20214)--记忆花灯开启时间红点
                obj:GetChild("red").visible = number > 0
                -- print("20214###",number,obj:GetChild("red").visible)
            else
                mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
            end
        end
    end
end


function YuanDanMainView:onClickItem(context)
    local cell = context.data
    local data = cell.data
    self:createObj(data.module_id)
    self:initChoose(cell)
    -- self:refreshUI()
end

--选中
function YuanDanMainView:initChoose(cell)
    if self.oldCell then
        local icon = self.oldCell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("yuandan" ,self.oldCell.data.iconup)
    end
    if cell then
        self.oldCell = cell
        local icon = cell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("yuandan" ,cell.data.icondown)
    end
end

function YuanDanMainView:createObj(moduleId)
    if not self.showObj[moduleId] then 
        local name = PanelName[moduleId]
        self.showObj[moduleId] = UIPackage.CreateObject("yuandan",name)
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
function YuanDanMainView:getPanelObj(moduleId)
    return self.showObj[moduleId]
end


function YuanDanMainView:sendMsg()
    if self.moduleId == 1431 then  -- 登录
        proxy.YuanDanProxy:sendMsg(1030677,{reqType = 0})
    elseif self.moduleId == 1432 then -- 投资
        proxy.YuanDanProxy:sendMsg(1030678,{reqType = 0,cid = 0})
    elseif self.moduleId == 1433 then --boss
        proxy.YuanDanProxy:sendMsg(1030679)
    elseif self.moduleId == 1434 then --探索
        proxy.YuanDanProxy:sendMsg(1030682,{reqType = 0,cid = 0})
    elseif self.moduleId == 1436 then --记忆
        self.classObj[1436]:setData()
    end
end

function YuanDanMainView:addMsgCallBack(data)
    self.classObj[self.moduleId]:setData(data)
end

return YuanDanMainView