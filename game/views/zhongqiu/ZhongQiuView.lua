--
-- Author: wx
-- Date: 2018-09-10 16:15:23
--
local ZhongQiuView = class("ZhongQiuView", base.BaseView)

local cls = {}
cls[1001] = import(".Zq1001") --节日boss
cls[1002] = import(".Zq1002") --降妖除魔
cls[1003] = import(".Zq1003") --拜月抽奖
cls[1004] = import(".Zq1004") --中秋豪礼
cls[1005] = import(".Zq1005") --登录领奖
cls[1006] = import(".Zq1006") --充值豪礼

local componentlist = {}
componentlist[1001] = "Component3"
componentlist[1002] = "Component5"
componentlist[1003] = "Component7"
componentlist[1004] = "Component8"
componentlist[1005] = "Component9"
componentlist[1006] = "Component9"

local redPoint = {}
redPoint[1005] = {30209}
redPoint[1006] = {30208}
redPoint[1004] = {30210}

function ZhongQiuView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.isBlack = true 
end

function ZhongQiuView:initData(data)
    self.classObj = {}
    if self.cacheComponent then
        for k ,v in pairs(self.cacheComponent) do
            v:Dispose()
        end 
    end
    self.cacheComponent = {}
    --初始化选择列表
    self.confdata = conf.ZhongQiuConf:getShowList()
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
        if v.id == 1005 and not (datainfo.acts and datainfo.acts[1149] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1006 and not (datainfo.acts and datainfo.acts[1148] == 1) then
            table.insert(keys,k)  
            remove_id[v.id] = 1 
        elseif v.id == 1003 and not (datainfo.acts and datainfo.acts[1151] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1 
        elseif v.id == 1004 and not (datainfo.acts and datainfo.acts[1150] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1 
        elseif v.id == 1002 and not (datainfo.acts and datainfo.acts[1152] == 1) then
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
                old.icon = "ui://zhongqiu/"..old.data.icon1
            end  
            new.icon = "ui://zhongqiu/" .. new.data.icon2
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
    self.param.showId =data and data.id or  1005
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

function ZhongQiuView:nextStep()
    -- body
    for k , v in pairs(self.confdata) do
        if v.id == self.param.showId  then
            self.listView:AddSelection(k-1,false)
            self.bindset.select = self.listView:GetChildAt(k-1)
            break
        end
    end
end
function ZhongQiuView:initView()
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

function ZhongQiuView:onTimer()
    -- body
    if not self.param.showId then
        return
    end

    if not self.classObj[self.param.showId] then
        return
    end

    self.classObj[self.param.showId]:onTimer()
end

function ZhongQiuView:cellBaseData(index, obj)
    local data =  self.confdata[index+1]
    obj.data = data
    obj.icon = "ui://zhongqiu/" .. data.icon1

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

function ZhongQiuView:onCallBack( context )
    -- body
    local btn = context.data 
    local data = btn.data 
    self.bindset.select = btn
end
function ZhongQiuView:setSelectCallBack(data)
    -- body
    if self.cacheComponent[data.id] then   
        self.bindset.component = self.cacheComponent[data.id]
    else
        local var = UIPackage.CreateObject("zhongqiu" , componentlist[data.id])
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
        proxy.ZhongqiuProxy:sendMsg(1030613)
    elseif 1003 == data.id then
        proxy.ZhongqiuProxy:sendMsg(1030611,{reqType = 0})
    elseif 1004 == data.id then
        proxy.ZhongqiuProxy:sendMsg(1030610,{reqType = 0})
    elseif 1005 == data.id then
        proxy.ZhongqiuProxy:sendMsg(1030609,{reqType = 0})
    elseif 1006 == data.id then
        proxy.ZhongqiuProxy:sendMsg(1030608,{reqType = 0})
    elseif 1002 == data.id then
        proxy.ZhongqiuProxy:sendMsg(1030612)    
    end
end

function ZhongQiuView:addMsgCallBack(data)
    -- body
    if not self.classObj or not self.param.showId or not self.classObj[self.param.showId] then
        return print("意外情况",debug.traceback(""))
    end
    self.classObj[self.param.showId]:addMsgCallBack(data)
end

return ZhongQiuView