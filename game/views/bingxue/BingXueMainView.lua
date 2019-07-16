--
-- Author: Your Name
-- Date: 2018-09-17 20:23:46
--冰雪
local BingXueMainView = class("BingXueMainView", base.BaseView)

local cls = {}
cls[1003] = import(".Bx1003") --登陆有礼
cls[1004] = import(".Bx1004") --欢登雪山
cls[1005] = import(".Bx1005") --欢乐雪仗
cls[1006] = import(".Bx1006") --激战boss
cls[1007] = import(".Bx1007") --惊喜兑换

local componentlist = {}
componentlist[1003] = "Component3"
componentlist[1004] = "Component4"
componentlist[1005] = "Component5"
componentlist[1006] = "Component6"
componentlist[1007] = "Component7"

local redPoint = {}
redPoint[1003] = {30258}
redPoint[1004] = {30259}
redPoint[1007] = {30260}

function BingXueMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.isBlack = true 
end

function BingXueMainView:initData(data)
    self.classObj = {}
    if self.cacheComponent then
        for k ,v in pairs(self.cacheComponent) do
            v:Dispose()
        end 
    end
    self.cacheComponent = {}
    --初始化选择列表
    self.confdata = conf.BingXueConf:getShowList()
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
        if v.id == 1003 and not (datainfo.acts and datainfo.acts[1224] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1004 and not (datainfo.acts and datainfo.acts[1225] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1005 and not (datainfo.acts and datainfo.acts[1226] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1006 and not (datainfo.acts and datainfo.acts[1227] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1007 and not (datainfo.acts and datainfo.acts[1228] == 1) then
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
                old.icon = "ui://bingxue/"..old.data.icon1
            end  
            new.icon = "ui://bingxue/" .. new.data.icon2
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
    self.param.showId =data and data.id or  1003
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

function BingXueMainView:nextStep()
    -- body
    for k , v in pairs(self.confdata) do
        if v.id == self.param.showId  then
            self.listView:AddSelection(k-1,false)
            self.bindset.select = self.listView:GetChildAt(k-1)
            break
        end
    end
end
function BingXueMainView:initView()
    local btn = self.view:GetChild("n17")
    self:setCloseBtn(btn)

    self.listView = self.view:GetChild("n14")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    --self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBack,self)



    self.component = self.view:GetChild("n16")
end

function BingXueMainView:refreshList()
    self.listView:RefreshVirtualList()
end

function BingXueMainView:onTimer()
    -- body
    if not self.param.showId then
        return
    end

    if not self.classObj[self.param.showId] then
        return
    end

    self.classObj[self.param.showId]:onTimer()
end

function BingXueMainView:cellBaseData(index, obj)
    local data =  self.confdata[index+1]
    obj.data = data
    obj.icon = "ui://bingxue/" .. data.icon1

    local redImg = obj:GetChild("red")
    if redPoint[data.id] then
        local param = {}
        param.panel = redImg
        --param.panel_add1 = obj:GetChild("n5")
        param.ids = redPoint[data.id]
        --param.text = obj:GetChild("n4")
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    end
    if data.id == 1003 then
        if cache.PlayerCache:getRedPointById(30258) > 0 then
            redImg.visible = true
        else
            redImg.visible = false
        end
    elseif data.id == 1004 then
        if cache.PlayerCache:getRedPointById(30259) > 0 then
            redImg.visible = true
        else
            redImg.visible = false
        end
    elseif data.id == 1007 then
        if cache.PlayerCache:getRedPointById(30260) > 0 then
            redImg.visible = true
        else
            redImg.visible = false
        end
    elseif data.id == 1005 then
        if cache.PlayerCache:getRedPointById(50120) > 0 then
            redImg.visible = true
        else
            redImg.visible = false
        end
    end
end

function BingXueMainView:onCallBack( context )
    -- body
    local btn = context.data 
    local data = btn.data 
    self.bindset.select = btn
end
function BingXueMainView:setSelectCallBack(data)
    -- body
    if self.cacheComponent[data.id] then   
        self.bindset.component = self.cacheComponent[data.id]
    else
        local var = UIPackage.CreateObject("bingxue" , componentlist[data.id])
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
    if 1003 == data.id then
        proxy.BingXueProxy:sendMsg(1030698)
    elseif 1004 == data.id then
        proxy.BingXueProxy:sendMsg(1030699,{reqType = 0})
    elseif 1005 == data.id then
        proxy.ActivityWarProxy:send(1470101)
    elseif 1006 == data.id then
        proxy.BingXueProxy:sendMsg(1030700)
    elseif 1007 == data.id then
        proxy.BingXueProxy:sendMsg(1030701,{reqType = 0,cid = 0})
    end--
end

function BingXueMainView:addMsgCallBack(data)
    -- body
    if not self.classObj or not self.param.showId or not self.classObj[self.param.showId] then
        print("id>>>>>>>>>>>>",self.param.showId)
        return print("意外情况",debug.traceback(""))
    end
    self.classObj[self.param.showId]:addMsgCallBack(data)
end

return BingXueMainView