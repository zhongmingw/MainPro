--
-- Author: 
-- Date: 2018-09-18 17:23:27
--

local QuanMingView = class("QuanMingView", base.BaseView)

local cls = {}
cls[1154] = import(".qmbz1154") --全民折扣礼包
cls[1155] = import(".qmbz1155") --全民消费返还
cls[1156] = import(".qmbz1156") --全民全服秒杀

local componentlist = {}
componentlist[1154] = "Component5"
componentlist[1155] = "Component8"
componentlist[1156] = "Component7"

local redPoint = {}
redPoint[1155] = {30211}

local sortlist = {}
sortlist[1154] = 1
sortlist[1155] = 2
sortlist[1156] = 3

--默认消息参数
local msglist = {}
msglist[1154] = {msgId = 1030614 , param = {reqType = 0,cid=0}}
msglist[1155] = {msgId = 1030615 , param = {reqType = 0,cid=0}}
msglist[1156] = {msgId = 1030616 , param = {reqType = 0,cid=0}}


function QuanMingView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.isBlack = true 
end

function QuanMingView:initData(data)
    -- body
    self.classObj = {}
    if self.cacheComponent then
        for k ,v in pairs(self.cacheComponent) do
            v:Dispose()
        end 
    end
    self.cacheComponent = {}

    --初始化选择列表
    self.keys = table.keys(sortlist)
    table.sort(self.keys,function(a,b)
        -- body
        return sortlist[a] < sortlist[b]
    end)   

     --列表项开关
    local datainfo = cache.ActivityCache:get5030111()
    local keys = {}
    local remove_id = {}
    for k ,v in pairs(self.keys) do
        if  not (datainfo.acts and datainfo.acts[v] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        end
    end
    table.sort(keys,function(a,b)
        -- body
        return a>b
    end)
    for k, v in pairs(keys) do
        table.remove(self.keys,v)
    end

    self.listView.numItems = #self.keys --列表

    if 0 == self.listView.numItems then
        self:closeView()
        return 
    end
    if self.bindset then
        self.bindset:delete()
        self.bindset = nil 
    end

    self.bindset = CreateBindingSet()
    self.bindset:bind("select",function(new,old)
        -- body
        if new ~= old then
            self:setSelectCallBack(new.data)
        end
    end)
    self.bindset:just_set("select",nil) 
    self.bindset:bind("component",function(new,old)
        -- body
        if new ~= old then
            if old then
                old.visible = false
            end
            new.visible = true
            self.param.showId = new.data
        end
    end)

    --默认选择
    self.param = {}
    self.param.showId =data and data.id or  1154
    if remove_id[self.param.showId] == 1  then
        --挑一个没有关闭的
        for k ,v in pairs(self.keys) do
            if not remove_id[v] then
                self.param.showId = v 
                break
            end
        end
    end

    self:nextStep()

    self:addTimer(1,-1,handler(self,self.onTimer))

end

function QuanMingView:nextStep()
    -- body
    for k , v in pairs(self.keys) do
        if v == self.param.showId  then
            self.listView:AddSelection(k-1,false)
            self.bindset.select = self.listView:GetChildAt(k-1)
            break
        end
    end
end

function QuanMingView:initView()
    local btn = self.view:GetChild("n0"):GetChild("n6")
    self:setCloseBtn(btn)

    self.listView = self.view:GetChild("n22")
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    self.listView.onClickItem:Add(self.onCallBack,self)

    self.component = self.view:GetChild("n10")

    self.labttimer = self.view:GetChild("n21")

end

function QuanMingView:cellBaseData(index, obj)
    -- body
    local key = self.keys[index+1]
    obj.data = key

    obj.title = language.qmbz01[key]

    if redPoint[key] then
        local redImg = obj:GetChild("red")
        local param = {}
        param.panel = redImg
        --param.panel_add1 = obj:GetChild("n5")
        param.ids = redPoint[key]
        --param.text = obj:GetChild("n4")
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    end
end

function QuanMingView:onCallBack( context )
    -- body
    local btn = context.data 
    local data = btn.data 
    self.bindset.select = btn
end
function QuanMingView:setSelectCallBack(data)
    -- body
    --print("data",data)
    if self.cacheComponent[data] then   
        self.bindset.component = self.cacheComponent[data]
    else
        local var = UIPackage.CreateObject("rechargeback" , componentlist[data])
        var.data = data
        self.component:AddChild(var)

        self.bindset.component = var
        self.cacheComponent[data] = var  
      --  if not self.classObj[data.id] and cls[data.id] then
        if not self.classObj[data] then
            self.classObj[data] = cls[data].new(self,data)
        end
    end
    if msglist[data] then
        proxy.ActivityProxy:sendMsg(msglist[data].msgId, msglist[data].param )
    end
end

function QuanMingView:onTimer()
    -- body
    if not self.param.showId then
        return
    end

    if not self.classObj[self.param.showId] then
        return
    end

    self.classObj[self.param.showId]:onTimer()
end

function QuanMingView:setTimeLab(var)
    -- body
    if var <= 0 then
        self:closeView()
        return
    end
    self.labttimer.text = language.ydact01 .. mgr.TextMgr:getTextColorStr(GGetTimeData2(var), 7)
end

function QuanMingView:addMsgCallBack(data)
    -- body
    if not self.classObj or not self.param.showId or not self.classObj[self.param.showId] then
        return print("意外情况",debug.traceback(""))
    end
    self.classObj[self.param.showId]:addMsgCallBack(data)
end
return QuanMingView