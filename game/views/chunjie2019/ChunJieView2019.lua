--
-- Author: Your Name
-- Date: 2018-09-17 20:23:46
--欢乐国庆
local ChunJieView2019 = class("ChunJieView2019", base.BaseView)

local cls = {}
cls[1001] = import(".Cj1001") --活动日程
-- 1阶段
cls[1002] = import(".Cj1002") --登录有礼
cls[1003] = import(".Cj1003") --节节高升
-- cls[1004] = import(".Cj1004") --年货采购
-- -- 2阶段
-- cls[1005] = import(".Cj1005") --登录有礼
-- cls[1006] = import(".Cj1006") --欢乐对联
-- cls[1007] = import(".Cj1007") --年年有余
-- cls[1008] = import(".Cj1008") --烟花大会
-- --3阶段
-- cls[1009] = import(".Cj1009") --登录有礼
-- cls[1010] = import(".Cj1010") --舞狮跳跃
-- cls[1011] = import(".Cj1011") --爆竹贺岁
-- cls[1012] = import(".Cj1012") --天降礼包
-- --4阶段
-- cls[1013] = import(".Cj1013") --登录翻牌
-- cls[1014] = import(".Cj1014") --迎拜财神
-- cls[1015] = import(".Cj1015") --开市优惠
-- cls[1016] = import(".Cj1016") --消费排行
-- cls[1017] = import(".Cj1017") --天降礼包


local componentlist = {}
componentlist[1001] = "Component1"
componentlist[1002] = "Component2"
componentlist[1003] = "Component3"
componentlist[1004] = "Component4"
componentlist[1005] = "Component5"
componentlist[1006] = "Component6"
componentlist[1007] = "Component7"
componentlist[1008] = "Component8"
-- componentlist[1009] = "Component9"
-- componentlist[1010] = "Component10"
-- componentlist[1011] = "Component11"
-- componentlist[1012] = "Component12"
-- componentlist[1013] = "Component13"
-- componentlist[1014] = "Component14"
-- componentlist[1015] = "Component15"
-- componentlist[1016] = "Component16"
-- componentlist[1017] = "Component17"



local redPoint = {}
-- redPoint[1002] = {30263} --小年降妖
-- redPoint[1003] = {30264} --小年兑换



function ChunJieView2019:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.isBlack = true 
end

function ChunJieView2019:initData(data)
    self.classObj = {}
    if self.cacheComponent then
        for k ,v in pairs(self.cacheComponent) do
            v:Dispose()
        end 
    end
    self.cacheComponent = {}
    --初始化选择列表
    if data.type then
        self.confdata = conf.ChunJieConf2019:getShowList(data.type)
    end
    print(data.type)
    printt(self.confData)
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
        if v.id == 1002 and not (datainfo.acts and datainfo.acts[1236] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1003 and not (datainfo.acts and datainfo.acts[1237] == 1) then
            table.insert(keys,k)
            remove_id[v.id] = 1
        elseif v.id == 1004 and not (datainfo.acts and datainfo.acts[1232] == 1) then
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
                old.icon = "ui://chunjie2019/"..old.data.icon1
            end  
            new.icon = "ui://chunjie2019/" .. new.data.icon2
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

function ChunJieView2019:nextStep()
    -- body
    for k , v in pairs(self.confdata) do
        if v.id == self.param.showId  then
            self.listView:AddSelection(k-1,false)
            self.bindset.select = self.listView:GetChildAt(k-1)
            break
        end
    end
end
function ChunJieView2019:initView()
    local btn = self.view:GetChild("n4")
    self:setCloseBtn(btn)

    self.listView = self.view:GetChild("n6")
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    --self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBack,self)


    self.component = self.view:GetChild("n2")
end

function ChunJieView2019:onTimer()
    -- body
    if not self.param.showId then
        return
    end

    if not self.classObj[self.param.showId] then
        return
    end

    self.classObj[self.param.showId]:onTimer()
end

function ChunJieView2019:cellBaseData(index, obj)
    local data =  self.confdata[index+1]
    obj.data = data
    obj.icon = "ui://chunjie2019/" .. data.icon1

    local redImg = obj:GetChild("red")
    if redPoint[data.id] then
        local param = {}
        param.panel = redImg
        --param.panel_add1 = obj:GetChild("n5")
        param.ids = redPoint[data.id]
        --param.text = obj:GetChild("n4")
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    end
    -- if data.id == 1006 then
    --     if cache.PlayerCache:getRedPointById(20166) > 0 then
    --         redImg.visible = true
    --     else
    --         redImg.visible = false
    --     end
    -- elseif data.id == 1007 then
    --     if cache.PlayerCache:getRedPointById(50120) > 0 then
    --         redImg.visible = true
    --     else
    --         redImg.visible = false
    --     end
    -- end
end

function ChunJieView2019:onCallBack( context )
    -- body
    local btn = context.data 
    local data = btn.data 
    self.bindset.select = btn
end
function ChunJieView2019:setSelectCallBack(data)
    -- body
    if self.cacheComponent[data.id] then   
        self.bindset.component = self.cacheComponent[data.id]
    else
        local var = UIPackage.CreateObject("chunjie2019" , componentlist[data.id])
        var.data = data
        self.component:AddChild(var)

        self.bindset.component = var
        self.cacheComponent[data.id] = var  
      --  if not self.classObj[data.id] and cls[data.id] then

        if not self.classObj[data.id] then
            --print("data ID:"..data.id)
            self.classObj[data.id] = cls[data.id].new(self,data.id)
        end
    end
    print("选择页签>>>>>",data.id)
    if 1001 == data.id then
        proxy.ChunJieProxy2019:sendMsg(1030709)
    elseif 1002 == data.id then
        proxy.ChunJieProxy2019:sendMsg(1030710,{reqType = 0})
    elseif 1003 == data.id then
        proxy.ChunJieProxy2019:sendMsg(1030711,{reqType = 0})
    end--
end

function ChunJieView2019:addMsgCallBack(data)
    -- body
    if not self.classObj or not self.param.showId or not self.classObj[self.param.showId] then
        print("id>>>>>>>>>>>>",self.param.showId)
        return print("意外情况",debug.traceback(""))
    end
    self.classObj[self.param.showId]:addMsgCallBack(data)
end



return ChunJieView2019