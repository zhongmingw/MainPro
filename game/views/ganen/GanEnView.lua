--
-- Author: wx
-- Date: 2018-09-10 16:15:23
--
local GanEnView = class("GanEnView", base.BaseView)

local cls = {}
cls[1001] = import(".Ge1001") --登录惊喜
cls[1002] = import(".Ge1002") --囍结良缘
cls[1003] = import(".Ge1003") --甜蜜豪礼


local componentlist = {}
componentlist[1001] = "Component1"
componentlist[1002] = "Component1"
componentlist[1003] = "Component2"


local redPoint = {}
redPoint[1001] = {30228}
redPoint[1002] = {30229}
redPoint[1003] = {30230}

function GanEnView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.isBlack = true 
end

function GanEnView:initData(data)
    self.classObj = {}
    if self.cacheComponent then
        for k ,v in pairs(self.cacheComponent) do
            v:Dispose()
        end 
    end
    self.cacheComponent = {}
    --初始化选择列表
    self.confdata = conf.GanEnConf:getShowList()
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
        if v.id == 1001 and not (datainfo.acts and datainfo.acts[1181] == 1) then -- 登录惊喜
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1002 and not (datainfo.acts and datainfo.acts[1182] == 1) then -- 囍结良缘
            table.insert(keys,k)  
            remove_id[v.id] = 1 
        elseif v.id == 1003 and not (datainfo.acts and datainfo.acts[1183] == 1) then --甜蜜豪礼
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
                old.icon = "ui://ganen/"..old.data.icon1
            end  
            new.icon = "ui://ganen/" .. new.data.icon2
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

function GanEnView:nextStep()
    -- body
    for k , v in pairs(self.confdata) do
        if v.id == self.param.showId  then
            self.listView:AddSelection(k-1,false)
            self.bindset.select = self.listView:GetChildAt(k-1)
            break
        end
    end
end
function GanEnView:initView()
    local btn = self.view:GetChild("n4")
    self:setCloseBtn(btn)

    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    --self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBack,self)

    


    self.component = self.view:GetChild("n2")
end

function GanEnView:onTimer()
    -- body
    if not self.param.showId then
        return
    end

    if not self.classObj[self.param.showId] then
        return
    end

    self.classObj[self.param.showId]:onTimer()
end

function GanEnView:cellBaseData(index, obj)
    local data =  self.confdata[index+1]
    obj.data = data
    obj.icon = "ui://ganen/" .. data.icon1

    if redPoint[data.id] then
        local redImg = obj:GetChild("red")
        local param = {}
        param.panel = redImg
        --param.panel_add1 = obj:GetChild("n5")
        param.ids = redPoint[data.id]
        --param.text = obj:GetChild("n4")
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    end
end

function GanEnView:onCallBack( context )
    -- body
    local btn = context.data 
    local data = btn.data 
    self.bindset.select = btn
end
function GanEnView:setSelectCallBack(data)
    -- body
    if self.cacheComponent[data.id] then   
        self.bindset.component = self.cacheComponent[data.id]
    else
        local var = UIPackage.CreateObject("ganen" , componentlist[data.id])
        var.data = data
        self.component:AddChild(var)

        self.bindset.component = var
        self.cacheComponent[data.id] = var  
      --  if not self.classObj[data.id] and cls[data.id] then
        if not self.classObj[data.id] then
            self.classObj[data.id] = cls[data.id].new(self,data.id)
        end
    end

    if 1001 == data.id then
        proxy.GanEnProxy:sendMsg(1030652,{reqType = 0})
    elseif 1002 == data.id then
        proxy.GanEnProxy:sendMsg(1030653,{reqType = 0})
    elseif 1003 == data.id then
        proxy.GanEnProxy:sendMsg(1030654,{reqType = 0,cid = 0})
    end
end

function GanEnView:addMsgCallBack(data)
    -- body
    if not self.classObj or not self.param.showId or not self.classObj[self.param.showId] then
        return print("意外情况",debug.traceback(""))
    end
    self.classObj[self.param.showId]:addMsgCallBack(data)
end

return GanEnView