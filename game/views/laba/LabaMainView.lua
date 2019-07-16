--
-- Author: 
-- Date: 2018-01-10 10:27:32
--腊八活动

local ActiveDlhl = import(".ActiveDlhl") --登录豪礼
local ActiveHylb = import(".ActiveHylb") --活跃腊八
local ActiveGjsb = import(".ActiveGjsb") --挂机双倍
local ActiveFbsb = import(".ActiveFbsb") --副本双倍
local ActiveBoss = import(".ActiveBoss") --Boss有礼
local ActiveLbz = import(".ActiveLbz")  --腊八粥
local ActiveLbyl = import(".ActiveLbyl") --腊八有礼
local LabaMainView = class("LabaMainView", base.BaseView)

local PanelName = {
    [1180] = "ActiveDlhl",
    [1181] = "ActiveHylb",
    [1182] = "ActiveLbz",
    [1183] = "ActiveLbyl",
    [1184] = "ActiveGjsb",
    [1185] = "ActiveFbsb",
    [1186] = "ActiveBoss",
}
local PanelClass = {
    [1180] = ActiveDlhl,
    [1181] = ActiveHylb,
    [1182] = ActiveLbz,
    [1183] = ActiveLbyl,
    [1184] = ActiveGjsb,
    [1185] = ActiveFbsb,
    [1186] = ActiveBoss,
}

function LabaMainView:ctor()
    LabaMainView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

function LabaMainView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)
    self.container = self.view:GetChild("n3")
    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
end

function LabaMainView:initData(data)
    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:onBtnClose()
        return
    end
    local confData = conf.ActivityConf:getLabaActList()
    self.confData = {}
    local flag = false
    for i= 1060,1066 do --活动id
        if activeData.acts and activeData.acts[i] and activeData.acts[i] == 1 then
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
    else
        GComAlter(language.vip11)
        self:onBtnClose()
    end
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
end
function LabaMainView:initAct()
   for k = 1,self.listView.numItems do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local moduleId = change.module_id
            if self.moduleId == moduleId then
                cell.onClick:Call()
            end
        end
    end
end

function LabaMainView:cellData(index,obj)
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

function LabaMainView:onClickItem(context)
    local sender = context.data
    local data = sender.data
    self:createObj(data.module_id)
    self:refreshUI()
end

function LabaMainView:createObj(moduleId)
    if not self.showObj[moduleId] then 
        local name = PanelName[moduleId]
        self.showObj[moduleId] = UIPackage.CreateObject("laba",name)
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

function LabaMainView:getPanelObj(moduleId)
    return self.showObj[moduleId]
end

function LabaMainView:sendMsg()
    if self.moduleId == 1180 or self.moduleId == 1182 or self.moduleId == 1184 or self.moduleId == 1186 then  -- 登录豪礼、腊八粥、挂机双倍、boss有礼
        proxy.ActivityProxy:send(1030304,{reqType = 1})
    elseif self.moduleId == 1181 then -- 活跃腊八
        proxy.ActivityProxy:send(1030305,{reqType = 0})
    elseif self.moduleId == 1183 then --腊八有礼
        proxy.ActivityProxy:send(1030307,{reqType = 0})
    elseif self.moduleId == 1185 then 
        proxy.ActivityProxy:send(1030309) --副本双倍
    end
end
--服务器返回信息
function LabaMainView:addMsgCallBack(data)
    if data.msgId == 5030304 and self.moduleId == 1180 or self.moduleId ==1182 or self.moduleId == 1184 or self.moduleId == 1185 or self.moduleId == 1186 then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030305 and self.moduleId == 1181 then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030307 and self.moduleId == 1183  then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030309 and self.moduleId == 1185 then 
        self.classObj[self.moduleId]:setData(data)
    end
    if not self.timer then
        self:refreshUI()
        self.timer = self:addTimer(1, -1, handler(self,self.refreshUI))
    end
end

function LabaMainView:setData(data_)

end

function LabaMainView:refreshUI()

    local flag = false
    local serverTime =  mgr.NetMgr:getServerTime()
    local timeTab = os.date("*t",serverTime)
    if tonumber(timeTab.hour)== 0 and tonumber(timeTab.min) == 0 and tonumber(timeTab.sec) <=2 then  --打开界面零点刷新
        flag = true
    end
    -- print("时分秒",timeTab.hour,timeTab.min,timeTab.sec,flag)
    if flag then 
        proxy.ActivityProxy:send(1030304,{reqType = 1})
        flag = false
    end

end

function LabaMainView:onBtnClose()
    self:closeView()
end

return LabaMainView