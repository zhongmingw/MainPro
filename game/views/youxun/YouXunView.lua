--
-- Author: wx
-- Date: 2018-08-31 19:19:19
--

local YouXunView = class("YouXunView", base.BaseView)
local cls = {}
cls[1001] = import(".Yx1001") --悠钻
cls[1002] = import(".Yx1002") --每日vip
cls[1003] = import(".Yx1003") --任务等级
cls[1004] = import(".Yx1004") --充值  
cls[1005] = import(".Yx1005") --消费
cls[1006] = import(".Yx1006") --手机
cls[1007] = import(".Yx1007") --年费

local componentlist = {}
local redPoint = {}
local showList = conf.YouXunConf:getShowList()
for k,v in pairs(showList) do
    print("k v",k,v)
    componentlist[v.id] = v.com
    redPoint[v.id] = v.redid
end

function YouXunView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.isBlack = true 
end

function YouXunView:initData(data)
    -- body
    self.classObj = {}
    if self.cacheComponent then
        for k ,v in pairs(self.cacheComponent) do
            v:Dispose()
        end 
    end
    self.cacheComponent = {}

    --背景图
    local bgImg = self.view:GetChild("n0")
    local confData = conf.YouXunConf:getPrivilegeConf(g_var.packId)
    if g_var.yx_game_param and g_var.yx_game_param ~= "" then
        if confData then
            bgImg.url = UIPackage.GetItemURL("youxun" ,confData.bg_img)
        else
            bgImg.url = UIPackage.GetItemURL("youxun" ,"yxtequan_035")
        end
    end
    local keys = {}
    for k ,v in pairs(self.confdata) do
        --手机奖励领取之后消失
        if v.id == 1006 and cache.PlayerCache:getRedPointById(30206) == 999 then
            table.insert(keys,k)
        elseif v.id == 1003 and cache.PlayerCache:getRedPointById(30203) == 999 then
            table.insert(keys,k)
        end
    end
    table.sort(keys,function(a,b)
        -- body
        return a>b
    end)
    for k, v in pairs(keys) do
        table.remove(self.confdata,v)
    end


    self.listView.numItems = #self.confdata
    self.bindset = CreateBindingSet()
    self.bindset:bind("select",function(new,old)
        -- body
        if new ~= old then
            if old then
                --old.selected = false
                -- old.icon = "ui://youxun/"..old.data.icon1
            end  
            -- new.icon = "ui://youxun/" .. new.data.icon2
            self:setSelectCallBack(new.data)
        end
    end)
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
    self.param.showId = 1001

    self:nextStep()

    self:addTimer(1,-1,handler(self,self.onTimer))
end

function YouXunView:nextStep()
    -- body
    for k , v in pairs(self.confdata) do
        if v.id == self.param.showId  then
            self.listView:AddSelection(k-1,false)
            self.bindset.select = self.listView:GetChildAt(k-1)
            break
        end
    end
end

function YouXunView:initView()
    

    local btn = self.view:GetChild("n4")
    self:setCloseBtn(btn)

    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    --self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBack,self)

    --初始化选择列表
    self.confdata = conf.YouXunConf:getShowList()
    table.sort(self.confdata,function(a,b)
        -- body
        return a.sort < b.sort
    end)   
    

    self.component = self.view:GetChild("n8")
end

function YouXunView:onTimer()
    -- body
    if not self.param.showId then
        return
    end

    if not self.classObj[self.param.showId] then
        return
    end

    self.classObj[self.param.showId]:onTimer()
end

function YouXunView:cellBaseData(index, obj)
    local data =  self.confdata[index+1]
    obj.data = data
    -- obj.icon = "ui://youxun/" .. data.icon1
    local confData = conf.YouXunConf:getPrivilegeConf(g_var.packId)
    if confData then
        for k,v in pairs(confData.title_name) do
            if tostring(data.id) == v[1] then
                obj:GetChild("n6").text = v[2]
                break
            end
        end
    else
        obj:GetChild("n6").text = data.name
    end
    local redImg = obj:GetChild("red")
    local param = {}
    param.panel = redImg
    param.panel_add1 = obj:GetChild("n5")
    param.ids = redPoint[data.id]
    param.text = obj:GetChild("n4")
    mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
end

function YouXunView:onCallBack( context )
    -- body
    local btn = context.data 
    local data = btn.data 
    self.bindset.select = btn
end

function YouXunView:setSelectCallBack(data)
    -- body
    if self.cacheComponent[data.id] then
        self.bindset.component = self.cacheComponent[data.id]
    else
        local var = UIPackage.CreateObject("youxun" , componentlist[data.id])
        var.data = data
        self.component:AddChild(var)

        self.bindset.component = var
        self.cacheComponent[data.id] = var
        if not self.classObj[data.id] then
            --print("data.id",data.id)
            self.classObj[data.id] = cls[data.id].new(self,data.id)
        end
    end

    if 1001 == data.id then
        proxy.YouXunProxy:sendMsg(1030601,{reqType = 0,cfgId = 0})
    elseif 1002 == data.id then
        proxy.YouXunProxy:sendMsg(1030602,{reqType = 0,cfgId = 0})
    elseif 1003 == data.id then
        proxy.YouXunProxy:sendMsg(1030603,{reqType = 0,cfgId = 0})
    elseif 1004 == data.id then
        proxy.YouXunProxy:sendMsg(1030604,{reqType = 0,cfgId = 0})
    elseif 1005 == data.id then
        proxy.YouXunProxy:sendMsg(1030605,{reqType = 0,cfgId = 0})
    elseif 1006 == data.id then
        proxy.YouXunProxy:sendMsg(1030606,{reqType = 0})
    elseif 1007 == data.id then
        proxy.YouXunProxy:sendMsg(1030638,{reqType = 0,cfgId = 0})
    end
end

function YouXunView:addMsgCallBack(data)
    -- body
    if not self.classObj or not self.param.showId or not self.classObj[self.param.showId] then
        return print("意外情况",debug.traceback(""))
    end
    self.classObj[self.param.showId]:addMsgCallBack(data)
end

function YouXunView:onOpenVip()
    -- body
    mgr.SDKMgr:yxsdk(1003)
end

function YouXunView:onOpenPhone()
    -- body
    mgr.SDKMgr:yxsdk(1001)
end

return YouXunView