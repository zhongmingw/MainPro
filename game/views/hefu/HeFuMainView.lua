--合服活动入口
local Activity1076 = import(".Activity1076")--1076 1078 --合服累充活动
local Activity1077 = import(".Activity1077")--1077 1079 --合服单笔充值活动
local Activity1085 = import(".Activity1085")--1085  --合服投资计划
local Activity1086 = import(".Activity1086")--1086  --合服红包返还
local HeFuMainView = class("HeFuMainView", base.BaseView)

function HeFuMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.sharePackage = {"guide"}
end
--
function HeFuMainView:initData(data)
    -- body
    --有哪些是开服活动
    self.classObj = {}
    if self.showObj then
        for k ,v in pairs(self.showObj) do
            v:Dispose()
        end 
    end
    self.showObj = {}
    self.confData = conf.ActivityConf:getActiveByTimetype(1)


    self:addTimer(1,-1,handler(self,self.onTimer))
    self.listView.numItems = 0

    --当前玩家等级
    self.curPlayerLevel = cache.PlayerCache:getRoleLevel()
    --活动配置开启等级
    self.activeOpenLv = {
        [1041] = "",
        [1048] = "",
        [1049] = "",
        [1051] = "",
    }
    for k,_ in pairs(self.activeOpenLv) do
        self.activeOpenLv[k] = conf.ActivityConf:getActiveById(k).lv
    end

    -- self.confPlayerLevelOf1041 = conf.ActivityConf:getActiveById(1041).lv
    -- self.confPlayerLevelOf1048 = conf.ActivityConf:getActiveById(1048).lv
    -- self.confPlayerLevelOf8888 = conf.ActivityConf:getActiveById(8888).lv
end
--
function HeFuMainView:initView()
    self.listView = self.view:GetChild("n2")
    --self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onUIClickCall,self)

    self.container = self.view:GetChild("n13")

    local btnClose = self.view:GetChild("n10"):GetChild("n5")
    btnClose.onClick:Add(self.onBtnClose,self)

    
end

function HeFuMainView:onTimer()
    -- body
    if not self.param then
        return
    end

    if not self.param.id then
        return
    end

    if not self.classObj then
        return
    end

    if not self.classObj[self.param.id] then
        return
    end


    self.classObj[self.param.id]:onTimer()
    
end

--设置活动信息
function HeFuMainView:celldata(index,obj)
    -- body
    local data = self.data[index+1]
    local icon = obj:GetChild("icon")
    if data.iconup then
        icon.url = UIPackage.GetItemURL("hefu" ,data.iconup)
    end

    --plog("data.id",data.id)
    obj.data = data

    --注入控件 
    -- param.panel  红点底图
    -- param.text   显示文本
    -- param.ids    红点定义
    -- param.notnumber  --是否不显示数字 --默认显示
    if data.redid then
        local param = {}
        param.panel = obj:GetChild("n4")
        param.text = obj:GetChild("n5") 
        param.ids = {data.redid}
        param.notnumber = true
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    end
end
--选中
function HeFuMainView:initChoose(cell)
    -- body
    if self.oldCell then
        local icon = self.oldCell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("hefu" ,self.oldCell.data.iconup)
    end

    if cell then
        self.oldCell = cell
        local icon = cell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("hefu" ,cell.data.icondown)
    end
end

function HeFuMainView:onUIClickCall(context)
    -- body
    local cell = context.data
    local data = cell.data
    self:initChoose(cell)
    --按活动ID打开界面
    self.param = {id = data.id}
    self:openActive()
end

--当前有哪些活动
function HeFuMainView:setData(data_)
    self.data = {}
    self.openDay = data_.openDay
   
    for k ,v in pairs(self.confData) do
        if v.activity_pos and v.activity_pos == 14 and  data_ and data_.acts[v.id] == 1 then --这个活动开启了   
            -- plog("开启的活动：",v.id)
            table.insert(self.data,v)
        end
    end
    self.oldCell = nil 

    --plog("self.openDay",self.openDay)

    table.sort(self.data,function(a,b)
        -- body
        if a.sort == b.sort then
            return a.id < b.id
        else
            return a.sort < b.sort
        end
    end)

    self.listView.numItems = #self.data

    if self.listView.numItems == 0 then
        GComAlter(language.kaifu05)
        --self.container:RemoveChildren()
        self:onBtnClose()
    end
end
--当前跳转活动ID
function HeFuMainView:nextStep(param)
    if not self.data then
        return
    end
    if self.listView.numItems == 0 then
        return
    end
    -- print("活动id",param.id)
    local id = param.id 
    for k ,v in pairs(self.data) do
        if v.id == id then--找到了对应活动
            --选中效果
            self:initChoose(self.listView:GetChildAt(k-1))
            self.listView:AddSelection(k-1,false)
            self.param = {id = v.id}
            self:openActive()
            return
        end
    end
    if param.id then
        GComAlter(language.acthall02)
    end
    --没有找到对应活动
    self:initChoose(self.listView:GetChildAt(0))
    self.listView:AddSelection(0,false) 
    self.param = {id = self.data[1].id}
    self:openActive()
    
end

function HeFuMainView:openActive()
    -- body
    local id = self.param.id 
    local falg = false
    if id ~= 1019 then
        if not self.showObj[id] then --用来缓存
            local index = id 
            if index == 1078 then
                index = 1076
            end
            if index == 1079 then
                index = 1077
            end
            local var = "Activity"..index
            self.showObj[id] = UIPackage.CreateObject("hefu",var)
            falg = true
        end
        --移除旧的
        --self.container:RemoveChildren()
        --添加新的
        self.container:AddChild(self.showObj[id])
    end

    for k ,v in pairs(self.showObj) do
        v.visible = false
    end
    if self.showObj and self.showObj[id] then
        self.showObj[id].visible = true
    end
    if id == 1078 then
        if falg then
        -- plog("开服累充活动",id)
            self.classObj[id] = Activity1076.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030184, {reqType = 0,awardId = 0,actId = id})
    elseif id == 1079 then
        if falg then
        -- plog("开服单笔充值活动",id)
            self.classObj[id] = Activity1077.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030185, {reqType = 0,awardId = 0,actId = id})
    elseif id == 1085 then
        if falg then
            self.classObj[id] = Activity1085.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030187, {reqType = 0,awardId = 0})
    elseif id == 1086 then
        if falg then
            self.classObj[id] = Activity1086.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030403, {reqType = 0})
    end
end

function HeFuMainView:onBtnClose()
    self:closeView()
end

function HeFuMainView:dispose(clear)
    if clear then
        for k ,v in pairs(self.showObj) do
            v:Dispose()
        end
        self.showObj = {}
        -- self.classObj = {}
    end
    self.super.dispose(self, clear)
end

--24点刷新
function HeFuMainView:update24()
    -- body    
    if self.param then
        if self.param.id == 1078 then
            proxy.ActivityProxy:sendMsg(1030184, {reqType = 0,amount = 0,buyId = 0,typeId = self.param.id})
        elseif self.param.id == 1079 then
            proxy.ActivityProxy:sendMsg(1030185, {reqType = 0,amount = 0,buyId = 0,typeId = self.param.id}) 
        end
    end
end

function HeFuMainView:addMsgCallBack(data)
    -- printt(data)
    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    -- body
    if 5030184 == data.msgId and self.param.id == 1078 then 
        self.classObj[self.param.id]:add5030184(data)
    elseif 5030185 == data.msgId and self.param.id == 1079 then 
        self.classObj[self.param.id]:add5030185(data)
    elseif 5030187 == data.msgId and self.param.id == 1085 then
        self.classObj[self.param.id]:add5030187(data)
    elseif 5030403 == data.msgId and self.param.id == 1086 then
        self.classObj[self.param.id]:add5030403(data)
    end
end

return HeFuMainView