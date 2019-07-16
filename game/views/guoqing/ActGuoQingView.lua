--
-- Author: Your Name
-- Date: 2018-09-17 20:23:46
--欢乐国庆
local ActGuoQingView = class("ActGuoQingView", base.BaseView)

local cls = {}
cls[1001] = import(".Gq1001") --登录有礼
cls[1002] = import(".Gq1002") --充值大礼
cls[1003] = import(".Gq1003") --消费豪礼
cls[1004] = import(".Gq1004") --激战BOSS
cls[1005] = import(".Gq1005") --欢乐兑换
cls[1006] = import(".Gq1006") --答题助兴
cls[1007] = import(".Gq1007") --疯弹作战

local componentlist = {}
componentlist[1001] = "Component1"
componentlist[1002] = "Component1"
componentlist[1003] = "Component1"
componentlist[1004] = "Component2"
componentlist[1005] = "Component3"
componentlist[1006] = "Component4"
componentlist[1007] = "Component5"

local redPoint = {}
redPoint[1001] = {30212}
redPoint[1002] = {30213}
redPoint[1003] = {30214}
redPoint[1005] = {30215}
-- redPoint[1006] = {20166}
-- redPoint[1007] = {50120}

function ActGuoQingView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.isBlack = true 
end

function ActGuoQingView:initData(data)
    self.classObj = {}
    if self.cacheComponent then
        for k ,v in pairs(self.cacheComponent) do
            v:Dispose()
        end 
    end
    self.cacheComponent = {}
    --初始化选择列表
    self.confdata = conf.GuoQingConf:getShowList()
    table.sort(self.confdata,function(a,b)
        -- body
        return a.sort < b.sort
    end)   
    --列表项开关
    local datainfo = cache.ActivityCache:get5030111()
    local keys = {}
    local remove_id = {}
    for k ,v in pairs(self.confdata) do
        --
        if v.id == 1001 and not (datainfo.acts and datainfo.acts[1157] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1002 and not (datainfo.acts and datainfo.acts[1158] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1003 and not (datainfo.acts and datainfo.acts[1159] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1005 and not (datainfo.acts and datainfo.acts[1160] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1004 and not (datainfo.acts and datainfo.acts[1161] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1006 and not (datainfo.acts and datainfo.acts[3051] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1007 and not (datainfo.acts and datainfo.acts[1058] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        end
    end

    table.sort(keys,function(a,b)
        -- body
        return a>b
    end)
    for k, v in pairs(keys) do
        table.remove(self.confdata,v)
    end
    --
    self.listView.numItems = #self.confdata --列表
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
            if old then
                old.icon = "ui://guoqing/"..old.data.icon1
            end  
            new.icon = "ui://guoqing/" .. new.data.icon2
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
            self.param.showId = new.data.id
        end
    end)

    --默认选择
    self.param = {}
    self.param.showId =data and data.id or  1001
    if remove_id[self.param.showId] == 1  then
        --挑一个没有关闭的
        for k ,v in pairs(self.confdata) do
            if not remove_id[v.id] then
                self.param.showId = v.id 
                break
            end
        end
    end

    self:nextStep()

    self:addTimer(1,-1,handler(self,self.onTimer))
end

function ActGuoQingView:nextStep()
    -- body
    for k , v in pairs(self.confdata) do
        if v.id == self.param.showId  then
            self.listView:AddSelection(k-1,false)
            self.bindset.select = self.listView:GetChildAt(k-1)
            break
        end
    end
end
function ActGuoQingView:initView()
    local btn = self.view:GetChild("n3")
    self:setCloseBtn(btn)

    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    --self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBack,self)

    


    self.component = self.view:GetChild("n2")
end

function ActGuoQingView:onTimer()
    -- body
    if not self.param.showId then
        return
    end

    if not self.classObj[self.param.showId] then
        return
    end

    self.classObj[self.param.showId]:onTimer()
end

function ActGuoQingView:cellBaseData(index, obj)
    local data =  self.confdata[index+1]
    obj.data = data
    obj.icon = "ui://guoqing/" .. data.icon1

    local redImg = obj:GetChild("red")
    if redPoint[data.id] then
        local param = {}
        param.panel = redImg
        --param.panel_add1 = obj:GetChild("n5")
        param.ids = redPoint[data.id]
        --param.text = obj:GetChild("n4")
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    end
    if data.id == 1006 then
        if cache.PlayerCache:getRedPointById(20166) > 0 then
            redImg.visible = true
        else
            redImg.visible = false
        end
    elseif data.id == 1007 then
        if cache.PlayerCache:getRedPointById(50120) > 0 then
            redImg.visible = true
        else
            redImg.visible = false
        end
    end
end

function ActGuoQingView:onCallBack( context )
    -- body
    local btn = context.data 
    local data = btn.data 
    self.bindset.select = btn
end
function ActGuoQingView:setSelectCallBack(data)
    -- body
    if self.cacheComponent[data.id] then   
        self.bindset.component = self.cacheComponent[data.id]
    else
        local var = UIPackage.CreateObject("guoqing" , componentlist[data.id])
        var.data = data
        self.component:AddChild(var)

        self.bindset.component = var
        self.cacheComponent[data.id] = var  
      --  if not self.classObj[data.id] and cls[data.id] then
        if not self.classObj[data.id] then
            self.classObj[data.id] = cls[data.id].new(self,data.id)
        end
    end

    print("选择页签>>>>>",data.id)
    if 1001 == data.id then
        proxy.GuoQingProxy:sendMsg(1030617,{reqType = 0})
    elseif 1002 == data.id then
        proxy.GuoQingProxy:sendMsg(1030618,{reqType = 0})
    elseif 1003 == data.id then
        proxy.GuoQingProxy:sendMsg(1030619,{reqType = 0})
    elseif 1004 == data.id then
        proxy.GuoQingProxy:sendMsg(1030621,{reqType = 0,cid = 0})
    elseif 1005 == data.id then
        proxy.GuoQingProxy:sendMsg(1030620,{reqType = 0,cid = 0})
    elseif 1006 == data.id then--答题
        proxy.ActivityWarProxy:send(1030179)
    elseif 1007 == data.id then--雪地入口信息
        proxy.ActivityWarProxy:send(1470101)
    end--
end

function ActGuoQingView:addMsgCallBack(data)
    -- body
    if not self.classObj or not self.param.showId or not self.classObj[self.param.showId] then
        print("id>>>>>>>>>>>>",self.param.showId)
        return print("意外情况",debug.traceback(""))
    end
    self.classObj[self.param.showId]:addMsgCallBack(data)
end

return ActGuoQingView