--
-- Author: 
-- Date: 2018-01-25 10:51:16
--
local ValentineDlhl = import("game.views.laba.ActiveDlhl") --情人节登录豪礼
local ValentineHyqrj = import("game.views.laba.ActiveHylb") --活跃情人节

local ValentinesMainView = class("ValentinesMainView", base.BaseView)

local PanelName = {
    [1205] = "ValentineDlhl",
    [1206] = "ValentineHyqrj"
}
local PanelClass = {
    [1205] = ValentineDlhl,
    [1206] = ValentineHyqrj
}   
    
function ValentinesMainView:ctor()
    ValentinesMainView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

function ValentinesMainView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)
    self.container = self.view:GetChild("n1")
    self.listView = self.view:GetChild("n2")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)

end

function ValentinesMainView:initData(data)
    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:onBtnClose()
        return
    end
    local confData = conf.ActivityConf:getValentineActList()
    self.confData = {}
    local flag = false
    if  (activeData.acts[3046] and activeData.acts[3046] == 1) or (activeData.acts[1070] and activeData.acts[1070] == 1 )then 
        flag = true
    end
    if flag then 
        for k,v in pairs(confData) do
            if activeData.acts[v.id] and activeData.acts[v.id] == 1 then 
                table.insert(self.confData, v)
            end
        end
        self.listView.numItems = #self.confData
        self.moduleId = data.index or self.confData[1].module_id
        self:initAct()
    else
        GComAlter(language.vip11)
        self:onBtnClose()
    end
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
end

function ValentinesMainView:initAct()
    local isFind = false
    for i=1,self.listView.numItems do
        local cell = self.listView:GetChildAt(i-1)
        if cell then 
            local change = cell.data
            local moduleId = change.module_id
            if self.moduleId == moduleId then 
                cell.onClick:Call()
                isFind = true
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

function ValentinesMainView:cellData(index,obj)
    local data = self.confData[index+1]
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

function ValentinesMainView:onClickItem(context)
    local sender = context.data
    local data = sender.data
    self:createObj(data.module_id)
    self:refreshUI()
end

function ValentinesMainView:createObj(moduleId)
    if not self.showObj[moduleId] then 
        local name = PanelName[moduleId]
        self.showObj[moduleId] = UIPackage.CreateObject("valentines",name)
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

function ValentinesMainView:getPanelObj(moduleId)
    return self.showObj[moduleId]
end

function ValentinesMainView:sendMsg()
    if self.moduleId == 1205 then  -- 登录豪礼
        proxy.ActivityProxy:send(1030175,{actId = 3046,reqType = 1})
    elseif self.moduleId == 1206 then -- 活跃情人节
        proxy.ActivityProxy:send(1030314,{reqType = 0})
    end
end

--服务器返回信息
function ValentinesMainView:addMsgCallBack(data)
    if data.msgId == 5030175 and self.moduleId == 1205 then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030314 and self.moduleId == 1206 then
        self.classObj[self.moduleId]:setData(data)
    end
    if not self.timer then
        self:refreshUI()
        self.timer = self:addTimer(1, -1, handler(self,self.refreshUI))
    end
end
--打开界面零点刷新
function ValentinesMainView:refreshUI()
    local flag = false
    local serverTime =  mgr.NetMgr:getServerTime()
    local timeTab = os.date("*t",serverTime)
    if tonumber(timeTab.hour)== 0 and tonumber(timeTab.min) == 0 and tonumber(timeTab.sec) <=2 then  
        flag = true
    end
    -- print("时分秒",timeTab.hour,timeTab.min,timeTab.sec,flag)
    if flag then 
        proxy.ActivityProxy:send(1030175,{actId = 3046,reqType = 1})
        flag = false
    end
end
function ValentinesMainView:onBtnClose()
    self:closeView()
end

return ValentinesMainView