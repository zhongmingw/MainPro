--
-- Author: 
-- Date: 2017-03-25 16:02:52
-- ---
-- local Active1001 = import(".Active1001")--1001-1008--开服进阶排行
-- local Active1009 = import(".Active1009")--1009-1016--开服进阶日
local Active1023 = import(".Active1023")--3001-3008 --坐骑进阶排行
local Active1017 = import(".Active1017")--1017-1023--开服7天任务
-- local Active1024 = import(".Active1024")--1024 --连续充值
local Active1025 = import(".Active1025")--1025 --首充团购
local Active1026 = import(".Active1026")--1026 --特惠礼包
local Active1028 = import(".Active1028")--1028 --每日累充
local Active1020 = import(".Active1020")--1020 --EVE 仙盟排行
local Active1041 = import(".Active1041")--1041 --EVE 等级排行
local Active1043 = import(".Active1043")--1043 --开服等级冲锋
local Active1048 = import(".Active1048")--1048 --EVE 战力排行&跨服战力排行
-- local Active1049 = import(".Active1049")--1048 --EVE 跨服战力排行
local Active1052 = import(".Active1052")--1052 --boss神装
local Active1053 = import(".Active1053")--1053 --集字活动
local Active1076 = import(".Active1076")--1076 1078 --开服累充活动
local Active1077 = import(".Active1077")--1077 1079 --开服单笔充值活动
local Active1087 = import(".Active1087")--1087  --开服红包返还
local Active1091 = import(".Active1091")--1091 --神器战力排行bxp

local KaiFuMainView = class("KaiFuMainView", base.BaseView)

function KaiFuMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.sharePackage = {"guide"}
end
--单独抽到主界面入口
local RemoveActid = {    
    [1023] = true,--坐骑进阶大比拼
    [1001] = true,--仙羽进阶大比拼
    [1002] = true,--神兵进阶大比拼
    [1003] = true,--仙器进阶大比拼
    [1004] = true,--法宝进阶大比拼
    [1005] = true,--伙伴仙羽进阶大比拼
    [1006] = true,--伙伴神兵进阶大比拼
    [1007] = true,--伙伴仙器进阶大比拼
    [1008] = true,--伙伴法宝进阶大比拼
    [1091] = true,--神器排行
    [1041] = true,--等级排行
    [1075] = true,--宠物排行
    [1051] = true,--装备排行
}
--
function KaiFuMainView:initData(data)
    -- body
    --有哪些是开服活动
    self.classObj = {}
    if self.showObj then
        for k ,v in pairs(self.showObj) do
            v:Dispose()
        end 
    end
    self.showObj = {}
    self.confData = {}
    local mData = conf.ActivityConf:getActiveByTimetype(1)
    for k,v in pairs(mData) do
        if not RemoveActid[v.id] then
            table.insert(self.confData,v)
        end
    end
    local confDataOfSevenDay = conf.ActivityConf:getActiveByTimetype(7)  
    for k,v in pairs(confDataOfSevenDay) do
        if v.id == 1049 then 
            table.insert(self.confData,v)
        end 
    end
   
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
function KaiFuMainView:initView()
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

function KaiFuMainView:onTimer()
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
function KaiFuMainView:celldata(index,obj)
    -- body
    local data = self.data[index+1]
    local icon = obj:GetChild("icon")
    if data.iconup then
        icon.url = UIPackage.GetItemURL("kaifu" ,data.iconup)
    end
    --开服任务
    --plog("data.id",data.id)
    if data.id == 1017 then
        if self.openDay < 8 then
            local name = "kaifurenwu_".. string.format("%03d",self.openDay+9)
            --plog("name",name)
            icon.url = UIPackage.GetItemURL("kaifu" ,name)
        else
            local name = "kaifurenwu_018"
            if self.openDay == 9 then
                name = "kaifurenwu_020"
            end
            --plog("name",name)
            icon.url = UIPackage.GetItemURL("kaifu" ,name)
        end
    end

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
function KaiFuMainView:initChoose(cell)
    -- body
    if self.oldCell then
        local icon = self.oldCell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("kaifu" ,self.oldCell.data.iconup)

        --开服任务
        if self.oldCell.data.id == 1017 then
            if self.openDay < 8 then
                local name = "kaifurenwu_".. string.format("%03d",self.openDay+9)
                --plog("name",name)
                icon.url = UIPackage.GetItemURL("kaifu" ,name)
            else
                local name = "kaifurenwu_018"
                if self.openDay == 9 then
                    name = "kaifurenwu_020"
                end
                --plog("name",name)
                icon.url = UIPackage.GetItemURL("kaifu" ,name)
            end
        end

    end

    if cell then
        self.oldCell = cell
        local icon = cell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("kaifu" ,cell.data.icondown)

        --开服任务
        if cell.data.id == 1017 then
            if self.openDay < 8 then
                local name = "kaifurenwu_"..string.format("%03d",self.openDay+2)
                icon.url = UIPackage.GetItemURL("kaifu" ,name)
            else
                local name = "kaifurenwu_017"
                if self.openDay == 9 then
                    name = "kaifurenwu_019"
                end
                --plog("name",name)
                icon.url = UIPackage.GetItemURL("kaifu" ,name)
            end
        end
    end
end

function KaiFuMainView:onUIClickCall(context)
    -- body
    local cell = context.data
    local data = cell.data
    self:initChoose(cell)
    --按活动ID打开界面
    self.param = {id = data.id}
    self:openActive()
end

--当前有哪些活动
function KaiFuMainView:setData(data_)
    -- for k,v in pairs(data_.acts) do
    --     print(k,v)
    -- end
    -- plog(data_.acts[1049],"fuck u")

    self.data = {}
    self.openDay = data_.openDay
   
    for k ,v in pairs(self.confData) do
        if v.activity_pos and v.activity_pos == 1 and  data_ and data_.acts[v.id] == 1 then --这个活动开启了   
            -- plog("开启的活动：",v.id)      
            -- if v.id == 1041 then 
            --     if (self.curPlayerLevel >= self.confPlayerLevelOf1041) then
            --         table.insert(self.data,1,v)
            --     end 
            -- elseif v.id == 1048 then 
            --     if (self.curPlayerLevel >= self.confPlayerLevelOf1048) then 
            --         table.insert(self.data, v)
            --     end 

            if v.id == 1041 or v.id == 1048 or v.id == 1049 or v.id == 1051 then 
                if self.curPlayerLevel >= self.activeOpenLv[v.id] then 
                    if v.id == 1041 then 
                        table.insert(self.data,1,v)
                    else
                        table.insert(self.data,v)
                    end
                end 
            else
                table.insert(self.data,v)
            end
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
    -- printt(self.data)
    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
end
--当前跳转活动ID
function KaiFuMainView:nextStep(param)
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

function KaiFuMainView:openActive()
    -- body
    local id = self.param.id 
    local falg = false
    if id ~= 1019 then
        if not self.showObj[id] then --用来缓存
            local index = id 
            if id <= 1008 or id == 1023 then --都是一个组件
                index = 1023
            end 
            if index == 1048 or index == 1049 or index == 1051 or index == 1075 then
                index = 1048
            end
            if index == 1076 or index == 1078 then
                index = 1076
            end
            if index == 1077 or index == 1079 then
                index = 1077
            end
            if index == 1091 then 
                index = 1091
            end
            local var = "Active"..index
            self.showObj[id] = UIPackage.CreateObject("kaifu",var)
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
    if id <= 1008 or id == 1023 then-- 请求开服进阶大比拼排行榜信息

        if falg then
            self.classObj[id] = Active1023.new(self.showObj[id])
        end
        --plog(self.classObj[id],"self.classObj[id]")
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030109, {actId = id})
    -- elseif id <= 1016 then --开服进阶目标
    --     if falg then
    --         self.classObj[id] = Active1009.new(self.showObj[id])
    --     end
    --     self.classObj[id]:setCurId(id)
    --     proxy.ActivityProxy:sendMsg(1030110, {actId = id,reqType=0,awardId=0})
    elseif id == 1017 then --开服7天任务
        if falg then
            self.classObj[id] = Active1017.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        --self.classObj[id]:setOpenDay(self.openDay)
        proxy.ActivityProxy:sendMsg(1030117, {taskId = 0,reqType=0})
    -- elseif id == 1024 then --连续充值
    --     if falg then
    --         self.classObj[id] = Active1024.new(self.showObj[id])
    --     end
    --     self.classObj[id]:setCurId(id)
    --     proxy.ActivityProxy:sendMsg(1030112, {reqType = 0,awardId = 0})
    elseif id == 1025 then--首充团购
        if falg then
            self.classObj[id] = Active1025.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030114, {reqType = 0,awardId = 0})
    elseif id == 1026 then
        if falg then
            self.classObj[id] = Active1026.new(self.showObj[id])
        end
        --plog("send 1030116")
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030116, {reqType = 0,amount = 0,buyId = 0,typeId = 1026})
    elseif id == 1028 then
        if falg then
            self.classObj[id] = Active1028.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030120, {reqType = 0,awardId = 0,activityId = 1028})
    elseif id == 1019 then
        mgr.ViewMgr:openView2(ViewName.MarryKaiFuRank)
        self:onBtnClose()
    elseif id == 1020 then   
        if falg then
            self.classObj[id] = Active1020.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030126)
    elseif id == 1041 then
        if falg then 
            self.classObj[id] = Active1041.new(self.showObj[id])
        end 
        -- plog("输出活动ID：", id )
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030207,{actId = 1041})
    elseif id == 1043 then
        if falg then 
            self.classObj[id] = Active1043.new(self.showObj[id])
        end 
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030208,{actId = 1043,reqType = 1,itemId = 0})
    elseif id == 1048 or id == 1049 or id == 1051 or id == 1075 then
        if falg then 
            self.classObj[id] = Active1048.new(self.showObj[id])
        end 
        -- plog("输出活动ID：", id )
        self.classObj[id]:setCurId(id)
        if id == 1048 then 
            proxy.ActivityProxy:sendMsg(1030148,{actId = 1048})
        elseif id == 1049 then
            proxy.ActivityProxy:sendMsg(1030149,{actId = 1049})
        elseif id == 1051 then
            proxy.ActivityProxy:sendMsg(1030150,{actId = 1051})
        elseif id == 1075 then--宠物战力排行
            proxy.ActivityProxy:sendMsg(1030183,{actId = 1075})
        end
    elseif id == 1052 then
        if falg then 
            self.classObj[id] = Active1052.new(self.showObj[id],self)
        end
        proxy.ActivityProxy:sendMsg(1030210,{reqType = 0})
    elseif id == 1053 then
        if falg then 
            self.classObj[id] = Active1053.new(self.showObj[id])
        end
        proxy.ActivityProxy:sendMsg(1030151,{reqType = 1})
    -- elseif id == 1049 then  --1049为跨服战力id
    --     if falg then 
    --         self.classObj[id] = Active1049.new(self.showObj[id])
    --     end 
    --     -- plog("输出活动ID：", id )
    --     self.classObj[id]:setCurId(id)
    --     proxy.ActivityProxy:sendMsg(1030149,{actId = 1049})
    elseif id == 1076 or id == 1078 then
        if falg then
        -- plog("开服累充活动",id)
            self.classObj[id] = Active1076.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030184, {reqType = 0,awardId = 0,actId = id})
    elseif id == 1077 or id == 1079 then
        if falg then
        -- plog("开服累充活动",id)
            self.classObj[id] = Active1077.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030185, {reqType = 0,awardId = 0,actId = id})
    elseif id == 1087 then
        if falg then
            self.classObj[id] = Active1087.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030404, {reqType = 0})
    elseif id == 1091 then 
        if falg then
            self.classObj[id] = Active1091.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030409)--开服神奇排行
    end
end

function KaiFuMainView:onBtnClose()
    self:closeView()
end

function KaiFuMainView:dispose(clear)
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
function KaiFuMainView:update24()
    -- body
    
    --plog("24点请求")
    local view = mgr.ViewMgr:get(ViewName.KaiFuRank)
    if view then
        view:closeView()
    end
    
    if self.param then
        if self.param.id == 1026 then --24点时候刷新一次
            proxy.ActivityProxy:sendMsg(1030116, {reqType = 0,amount = 0,buyId = 0,typeId = 1026}) 
        elseif self.param.id == 1076 or self.param.id == 1078 then
            proxy.ActivityProxy:sendMsg(1030184, {reqType = 0,amount = 0,buyId = 0,typeId = self.param.id})
        elseif self.param.id == 1077 or self.param.id == 1079 then
            proxy.ActivityProxy:sendMsg(1030185, {reqType = 0,amount = 0,buyId = 0,typeId = self.param.id}) 
        end
    end
end

function KaiFuMainView:addMsgCallBack(data)
    -- printt(data)
    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    -- body
    if 5030109 == data.msgId and (self.param.id <= 1008 or self.param.id == 1023) then --什么鬼消息
        self.classObj[self.param.id]:add5030109(data)
    -- elseif 5030110 == data.msgId and self.param.id <= 1016 then
    --     self.classObj[self.param.id]:add5030110(data)
    -- if 5030112 == data.msgId and self.param.id == 1024 then
    --     self.classObj[self.param.id]:add5030112(data)
    elseif 5030114 == data.msgId and self.param.id == 1025 then
        self.classObj[self.param.id]:setOpenDay(self.openDay)
        self.classObj[self.param.id]:add5030114(data)
    elseif 5030116 == data.msgId and self.param.id == 1026 then
       --plog("5030116",5030116
        self.classObj[self.param.id]:add5030116(data)
    elseif 5030117 == data.msgId and self.param.id == 1017 then
        --plog("5030117",5030117)
        self.classObj[self.param.id]:setOpenDay(self.openDay)
        self.classObj[self.param.id]:add5030117(data)
    elseif 5030120 == data.msgId and self.param.id == 1028 then
        self.classObj[self.param.id]:setOpenDay(self.openDay)
        self.classObj[self.param.id]:add5030120(data)
    elseif 5030126 == data.msgId and self.param.id == 1020 then
        self.classObj[self.param.id]:setOpenDay(self.openDay)
        self.classObj[self.param.id]:add5030126(data)
    elseif 5030207 == data.msgId and self.param.id == 1041 then 
        self.classObj[self.param.id]:setOpenDay(self.openDay)
        self.classObj[self.param.id]:add5030207(data)
    elseif 5030208 == data.msgId and self.param.id == 1043 then 
        self.classObj[self.param.id]:setOpenDay(self.openDay)
        self.classObj[self.param.id]:add5030208(data)
    elseif 5030148 == data.msgId and self.param.id == 1048 then 
        self.classObj[self.param.id]:setOpenDay(self.openDay)
        self.classObj[self.param.id]:add5030148(data)
    elseif 5030149 == data.msgId and self.param.id == 1049 then 
        self.classObj[self.param.id]:setOpenDay(self.openDay)
        self.classObj[self.param.id]:add5030148(data)
    elseif 5030150 == data.msgId and self.param.id == 1051 then 
        self.classObj[self.param.id]:setOpenDay(self.openDay)
        self.classObj[self.param.id]:add5030148(data)
    elseif 5030210 == data.msgId and self.param.id == 1052 then 
        self.classObj[self.param.id]:add5030210(data)
    elseif 5030151 == data.msgId and self.param.id == 1053 then 
        self.classObj[self.param.id]:add5030151(data)
    elseif 5030183 == data.msgId and self.param.id == 1075 then 
        self.classObj[self.param.id]:add5030148(data)
    elseif 5030184 == data.msgId and (self.param.id == 1076 or self.param.id == 1078)then 
        self.classObj[self.param.id]:add5030184(data)
    elseif 5030185 == data.msgId and (self.param.id == 1077 or self.param.id == 1079)then 
        self.classObj[self.param.id]:add5030185(data)
    elseif 5030404 == data.msgId and self.param.id == 1087 then
        self.classObj[self.param.id]:add5030404(data)
    elseif 5030409 == data.msgId and self.param.id == 1091 then
        self.classObj[self.param.id]:add5030409(data)
    end
end

return KaiFuMainView