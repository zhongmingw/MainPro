--
-- Author: EVE 
-- Date: 2018-01-24 16:27:32
-- 小年活动

local ActiveDL = import(".ActiveDL") --登录豪礼
local ActiveXD = import(".ActiveXD") --雪地作战
local ActiveJZ = import(".ActiveJZ") --饺子团圆
local ActiveYL = import(".ActiveYL") --BOSS有礼

local LunarYearMainView = class("LunarYearMainView", base.BaseView)

local PanelName = {
    [3045] = "ActiveDL",
    [1058] = "ActiveXD",
    [1068] = "ActiveJZ",
    [3053] = "ActiveYL",
}
local PanelClass = { 
    [3045] = ActiveDL,   --登录
    [1058] = ActiveXD,   --雪地
    [1068] = ActiveJZ,   --饺子
    [3053] = ActiveYL,   --有礼
}

function LunarYearMainView:ctor()
    LunarYearMainView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

function LunarYearMainView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)

    self.container = self.view:GetChild("n3")
    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
end

function LunarYearMainView:initData(data)

    local activeData = cache.ActivityCache:get5030111()

    -- if activeData.acts[3053] and activeData.acts[3053] == 1 then
    --     print("BOSS有礼已开启：",3053)
    -- else
    --     print("BOSS有礼未开启：",3053,activeData.acts[3053])
    -- end

    if not activeData then
        self:onBtnClose()
        return
    end

    local confData = conf.ActivityConf:getLunarYearActList()
    self.confData = {}
    local flag = false
    for k, _ in pairs(PanelName) do
        if activeData.acts and activeData.acts[k] and activeData.acts[k] == 1 then
            flag = true
            break
        end
    end

    if flag then
        for k,v in pairs(confData) do
            if activeData.acts[v.id] and activeData.acts[v.id] == 1 then
                -- print("当前开启的活动有：",v.id)
                table.insert(self.confData,v)
            end
        end
        
        self.listView.numItems = #self.confData
        self.moduleId = data.index or self.confData[1].module_id
        self:initAct()
        self:addTimer(1, -1, handler(self, self.onTimer))
    else
        GComAlter(language.vip11)
        self:onBtnClose()
    end
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end

    self:simulateInitData()
end

function LunarYearMainView:initAct()
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

function LunarYearMainView:onTimer()
    if self.moduleId == 1058 then
        self.classObj[self.moduleId]:onTimer()
    end
end

function LunarYearMainView:cellData(index,obj)
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

function LunarYearMainView:onClickItem(context)
    local sender = context.data
    local data = sender.data
    self:createObj(data.id)
    self:refreshUI()
    self:simulateInitData() --模拟initData()
end

--模拟initData函数
function LunarYearMainView:simulateInitData()
    if self.moduleId == 1068 then 
        self.classObj[self.moduleId]:initData()
    end 
end

function LunarYearMainView:createObj(moduleId)
    if not self.showObj[moduleId] then 
        local name = PanelName[moduleId]
        -- print(moduleId,"~~",name)
        self.showObj[moduleId] = UIPackage.CreateObject("lunaryear",name)
        self.container:AddChildAt(self.showObj[moduleId],0)
    end
    if not self.classObj[moduleId] then
        self.classObj[moduleId] = PanelClass[moduleId].new(self,self.showObj[moduleId])   
        -- print("这里有东西不存在")
    end
    for k,v in pairs(self.showObj) do
        if k == moduleId then
            v.visible = true
        else
            v.visible = false
        end
    end
    self.moduleId = moduleId
    
    if self.moduleId ~= 1068 then
        self:sendMsg()
    end
end

function LunarYearMainView:getPanelObj(moduleId)
    return self.showObj[moduleId]
end

function LunarYearMainView:sendMsg()
    if self.moduleId == 3045  then                                       --登录
        proxy.ActivityProxy:send(1030175,{reqType = 1, actId = 3045,})
    elseif self.moduleId == 1058 then                                    --雪地
        proxy.ActivityProxy:send(1470101,{})
    -- elseif self.moduleId == 1183 then                                 --饺子
    --     proxy.ActivityProxy:send(1030307,{reqType = 0})
    end
end

--服务器返回信息
function LunarYearMainView:addMsgCallBack(data)
    self.data = data

    if data.msgId == 5030175 then --登录
        self.classObj[self.moduleId]:setData(data)       
    elseif data.msgId == 5470101 then
        self.classObj[self.moduleId]:setData(data)

--     elseif data.msgId == 5030309 and self.moduleId == 1185 then 
--         self.classObj[self.moduleId]:setData(data)
    end

    if not self.timer then
        self:refreshUI()
        self.timer = self:addTimer(1, -1, handler(self,self.refreshUI))
    end
end

function LunarYearMainView:refreshUI()

    local flag = false
    local serverTime =  mgr.NetMgr:getServerTime()
    local timeTab = os.date("*t",serverTime)
    if tonumber(timeTab.hour)== 0 and tonumber(timeTab.min) == 0 and tonumber(timeTab.sec) <=2 then  --打开界面零点刷新
        flag = true
    end
    -- print("时分秒",timeTab.hour,timeTab.min,timeTab.sec,flag)
    if flag then 
        proxy.ActivityProxy:send(1030175,{reqType = 1})
        flag = false
    end

end

function LunarYearMainView:doClearView(clear)
    if self.classObj[1058] then self.classObj[1058]:clear() end
end

function LunarYearMainView:onBtnClose()
    self:closeView()
end

return LunarYearMainView