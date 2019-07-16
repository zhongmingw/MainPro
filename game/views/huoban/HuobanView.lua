--
-- Author: 
-- Date: 2017-02-25 10:54:05
--
local HuobanPanel = import(".HuobanPanel") --伙伴技能和装备
local HuobanPro = import(".HuobanPro") --伙伴属性
local HuoBanOtherPro = import(".HuoBanOtherPro") --伙伴其他物品属性
local HuoBanJie = import(".HuoBanJie")--升级进阶

local HuobanView = class("HuobanView", base.BaseView)
local redpoint = {10211,10213,10212,10215,10214}
local _max_ = {12,10,10,10,10}
local opent1 = {
    [5200101] = 1006,
    [5210101] = 1007,
    [5220102] = 1008,
    [5230101] = 1010,
    [5240101] = 1009,
}
local opent2 = {
    [5200201] = 1006,
    [5210102] = 1007,
    [5220103] = 1008,
    [5230102] = 1010,
    [5240102] = 1009,
}
local opent3 = {
    [5210102] = 221041046,
    [5220103] = 221041047,
    [5230102] = 221041049,
    [5240102] = 221041048,
}

local opent5 = {
    1006,1007,1008,1010,1009
}
function HuobanView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.drawcall = false
    self.openTween = ViewOpenTween.scale
    self.uiClear = UICacheType.cacheForever
end

function HuobanView:initData(data)
    -- body
    self.is10 = true
    self.refreshModel = true
    --解决报错
    if self.HuoBanJie then
        self.HuoBanJie.leftModel.data = nil 
        self.HuoBanJie.rightModel.data = nil 
    end
    if self.huoBan then
        self.huoBan.model.data = nil 
    end
    --货币窗口
    GSetMoneyPanel(self.window2,self:viewName())

    --注册红点
    for i = 8 , 12 do
        local btn =  self.view:GetChild("n"..i)
        local redImg = btn:GetChild("n4")
        --plog("i ",redpoint[i-7],cache.PlayerCache:getRedPointById(redpoint[i-7]) )
        local param = {panel = redImg,ids = {redpoint[i-7]}}
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    end


    self:visibleInit()
    self:setVisible()
    self.index =  data.index or 0 --默认选中哪个
    self.childIndex = data.childIndex
    self.moduleId = data.grandson

    self.suitId = data.suitId--时装升星的时装配置id
    if self.c1.selectedIndex == self.index then
        self:onController1()
    else
        self.c1.selectedIndex = self.index
    end


    --计算器
    if self.dd then
        self:removeTimer(self.dd)
        self.dd = nil 
    end
    self:addTimer(1,-1,handler(self,self.onTimer))
    

    self.super.initData()
end

function HuobanView:checkTehui(index)
    -- body
    if true then
        --屏蔽特惠抢购 20180301
        return false
    end

    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end
    local condata = conf.SysConf:getHwbSBItem("lingdong"..index)
    if not condata then
        return false
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return false
    end
    local _in
	--plog("data.openDay",data.openDay)
    if data.openDay > 9 then
        --没有购买要求
        if not condata.buy_id_new then
            return false
        end
        _in = clone(condata.buy_id_new)
    else
        --没有购买要求
        if not condata.buy_id then
            return false
        end
        _in = clone(condata.buy_id)
    end
    --
    --local _in = clone(condata.buy_id)
    if not condata.open_day then
        _in = {condata.buy_id[curday] or condata.buy_id[9]}
    end
    --检测是否购买了要求物品
    local key = g_var.accountId.."1026buy"
    local _localbuy = UPlayerPrefs.GetString(key)
    --plog("今天已将购买",_localbuy)
	--plog("要求购买",json.encode(_in) )
    if _localbuy~="" then
        local _t = json.decode(_localbuy)
        local pairs = pairs
        local falg = false 
        for k,v in pairs(_in) do
            local innnerbuy = false--当前物品是否买过
            for i , j in pairs(_t) do
                if tonumber(j) == tonumber(v) then
                    innnerbuy = true 
                    break
                end
            end
            if not innnerbuy then --有个需求物品没有买
                falg = true
                break
            end
        end
        return falg
    else
        return true
    end
end

function HuobanView:checkBaiBei(index)
    -- body
    if true then
        --屏蔽特惠抢购 20180301
        return false
    end
    if cache.PlayerCache:getRedPointById(attConst.A30111)<=0 then
        return false
    end
    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end
    local condata = conf.SysConf:getHwbSBItem("lingdong"..index)
    if not condata then
        return false
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return false
    end
    --没有购买要求
    if not condata.buy_danci then
        return false
    end
    local _in = clone(condata.buy_danci)
    if not condata.open_day then
        _in = {condata.buy_danci[curday] or condata.buy_danci[9]}
    end

    --检测是否购买了要求物品
    local key = g_var.accountId.."3010buy"
    local _localbuy = UPlayerPrefs.GetString(key)
    if _localbuy~="" then
        local _t = json.decode(_localbuy)
        local pairs = pairs

        local falg = false 
        for k,v in pairs(condata.buy_danci) do
            local innnerbuy = false--当前物品是否买过
            for i , j in pairs(_t) do
                if tonumber(j) == tonumber(v) then
                    innnerbuy = true 
                    break
                end
            end
            if not innnerbuy then --有个需求物品没有买
                falg = true
                break
            end
        end
        return falg
    else
        return true
    end
end

function HuobanView:checkBuy(index)
    -- body
    return self:checkTehui(index) or self:checkBaiBei(index)
end

function HuobanView:initView()
    self.window2 = self.view:GetChild("n0")
    --关闭
    local closeBtn = self.window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)
    --
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    --伙伴形象组件
    self.huobanPanel = self.view:GetChild("n18")
    self.pro1Panel = self.view:GetChild("n20")
    self.pro2Panel = self.view:GetChild("n21")
    self.huobanJie = self.view:GetChild("n22")
    --单选按钮按钮按下
    local index = 0 
    self.list = {}
    self.btnpos = {}
    self.signList = {}
    for i = 8 , 12 do
        index = index + 1
        local t = {}
        t.btn =  self.view:GetChild("n"..i)
        t.btn:GetChild("title").text = ""
        --按钮上的字
        t.lab = self.view:GetChild("n"..(i+5))
        t.lab.text = language.huoban01[index]

        table.insert(self.list,t)
        table.insert(self.btnpos,t.btn.y)
        local signIcon = self.view:GetChild("n2"..(i-4))
        table.insert(self.signList,signIcon)

        
    end
    
    self.btnClose = self.view:GetChild("n23")
    self.btnClose.onClick:Add(self.onbtnClose,self)

    
end
--按开启等级设置位置 和 是否课件
function HuobanView:setVisible()
    -- body
    local t = {
        1006, --灵童
        1007, --灵羽
        1008, --灵兵
        1009, --灵器
        1010, --灵宝
        
    }
    local index = 1
    for k , v in pairs(t) do
        local selectedIndex = 1
        local sortindex = 1
        if v == 1006 then
            selectedIndex = 1
            sortindex = 1
        elseif v == 1007 then
            selectedIndex = 2
            sortindex = 2
        elseif v == 1008 then
            selectedIndex = 3
            sortindex = 3
        elseif v == 1010 then
            selectedIndex = 4
            sortindex = 4
        elseif v == 1009 then
            selectedIndex = 5
            sortindex = 5
        end 
        --plog(k,v,sortindex)

        local t = self.list[sortindex]
        local sign = self.signList[sortindex]
        sign.visible = false
        t.btn.visible = mgr.ModuleMgr:CheckSeeView(v)
        t.lab.visible = t.btn.visible 
        if t.btn.visible then
            t.btn.sortingOrder = index
            t.lab.sortingOrder = index + 1
            sign.sortingOrder = index + 2
            t.btn.y = self.btnpos[index]

            index = index + 1

            local confData = conf.VipChargeConf:getDataById(selectedIndex+9)
            if selectedIndex+9 == 10 then
                -- if GFirstChargeIsOpen() and not GGetFirstChargeState(confData.charge_grade) then 
                --     sign.visible = true
                -- else
                --     sign.visible = false
                -- end
                sign.visible = false
            else
                local i = GGetDayChargeDayTimes()%7
                if GGetDayChargeDayTimes()%7 == 0 then i = 7 end
                if type(SkipType[i]) == "table" then
                    if (SkipType[i][1] == selectedIndex+9 or SkipType[i][2] == selectedIndex+9) and GGetDayChargeState(confData.charge_grade) then
                        sign.visible = true
                    else
                        sign.visible = false
                    end
                else
                    sign.visible = false
                end
            end
            local openDay = cache.ActivityCache:get5030111().openDay
            if openDay > 7 then
                sign.visible = false
            end
            -- print("每日首充",GGetDayChargeState(confData.charge_grade),SkipType[GGetDayChargeDayTimes()],selectedIndex+9)
            if not sign.visible then
                --print("活动开放",self:checkBuy(selectedIndex))
                sign.visible = self:checkBuy(selectedIndex-1) 
            end
        end
        -- signIndex = signIndex + 1
    end
end
--时间
function HuobanView:onTimer()
    -- body
    --属性
    if self.HuobanPro then
        self.HuobanPro:onTimer()
    end
    -- --进阶
    if self.HuoBanJie then
        self.HuoBanJie:onTimer()
    end
    --特殊皮肤
    if self.HuoBanOtherPro then
        self.HuoBanOtherPro:onTimer()
    end
end

function HuobanView:visibleInit()
    -- body
    self.huobanPanel.visible = false
    self.pro1Panel.visible = false
    self.pro2Panel.visible = false
    self.huobanJie.visible = false
    self.btnClose.visible = false
end

--选择那个页面
function HuobanView:onController1()
    if not mgr.ModuleMgr:CheckView({id = opent5[self.c1.selectedIndex+1],falg = true} ) then
        if self.oldselect then
            self.c1.selectedIndex = self.oldselect
        else
            self.c1.selectedIndex = 0
        end
        return
    end
    self.oldselect = self.c1.selectedIndex

    self:visibleInit()
    if not self.huoBan then
        self.huoBan = HuobanPanel.new(self)
    end
    if not self.HuoBanJie then
        self.HuoBanJie = HuoBanJie.new(self)
    end
    self.HuoBanJie:setIsAuto(false)

    if 0 == self.c1.selectedIndex then --伙伴
        if not self.HuobanPro then
            self.HuobanPro = HuobanPro.new(self)
        end
        proxy.HuobanProxy:send(1200101)
    else
        if not self.HuoBanOtherPro then
            self.HuoBanOtherPro = HuoBanOtherPro.new(self)
        end
        self.HuoBanOtherPro:setistimer()
        self.HuoBanOtherPro:updateSelect(0)
        if 1 == self.c1.selectedIndex then --仙羽
            proxy.HuobanProxy:send(1210101)
        elseif 2 == self.c1.selectedIndex then --神兵
            proxy.HuobanProxy:send(1220102)
        elseif 3 == self.c1.selectedIndex then --法宝
            proxy.HuobanProxy:send(1230101)
        elseif 4 == self.c1.selectedIndex then --仙器
            proxy.HuobanProxy:send(1240101)
        end   
    end
end

function HuobanView:setData(data_)
    self:onController1()
end

--设置数据
function HuobanView:updateZuoqi(id)
    -- body    
    if self.huoBan and self.huobanPanel.visible then
        self.huoBan:setData(self.data)
    end

    if self.HuobanPro and self.pro1Panel.visible then
        self.HuobanPro:update(self.data)
        if id then
            self.HuobanPro:initPro2(id)
        end
    end

    if self.HuoBanOtherPro and self.pro2Panel.visible then
        self.HuoBanOtherPro:setData(self.data)
        if id then
            self.HuoBanOtherPro:initPro2(id)
        end
    end

    if self.HuoBanJie and self.huobanJie.visible then
        self.HuoBanJie:setData(self.data,self.huobanparam,self.refreshModel)
    end
    --刷新红点信息
    self:refreshRed() 
end
--特殊皮肤选择
function HuobanView:onSkincallBack(id)

    if self.HuoBanOtherPro and self.pro2Panel.visible then
        self.HuoBanOtherPro:initPro2(id)
    end

    if self.HuobanPro and self.pro1Panel.visible then
        self.HuobanPro:initPro2(id)
    end

    if self.huoBan and self.huobanPanel.visible then
        self.huoBan:initModel(id,true)
    end
end
--特殊皮肤选择 返回按钮
function HuobanView:onSkinBack()
    -- body
    --其他属性 回复
    if self.HuoBanOtherPro and self.pro2Panel.visible then
        self.HuoBanOtherPro:updateSelect()
    end
    --伙伴属性
    if self.HuobanPro and self.pro1Panel.visible then
        self.HuobanPro:updateSelect()
    end

    self:updateZuoqi()
    if self.huoBan and self.huobanPanel.visible then
        self.huoBan:backModel()
        --self.huoBan:selectCur(true)
    end
end
function HuobanView:callpetItem( param )
    -- body
    self.huobanparam = param

    if self.huoBan and self.huobanPanel.visible then
        self.huoBan:initModel(param.id,true)
    end

    if self.HuobanPro then
        self.HuobanPro:setData(param,self.data)
    end
end

--技能点击 或者小伙伴点击
function HuobanView:callLeftItem( param )
    -- body
    --技能点击
    local data = param
    mgr.ViewMgr:openView(ViewName.HuobanSkillUp, function(view)
        -- body
        view:setData(self.c1.selectedIndex)
    end, data)   
end
--装备点击
function HuobanView:callRightItem( param )
    -- body
    local data = param
    mgr.ViewMgr:openView(ViewName.HuobanEquipUp, function(view)
        -- body
        view:setData(self.c1.selectedIndex)
    end, data)   
end
--进阶按钮
function HuobanView:onbtnCallBack()
    -- body
    printt("伙伴升级>>>>>>>>>>>",self.data)
    if not self.data then
        return
    end

    if self.data.lev == 0 then
        --意外没有激活的情况
        if self.c1.selectedIndex == 0 then
            proxy.HuobanProxy:send(1200201,{reqType = 1})
        elseif self.c1.selectedIndex == 1 then
            proxy.HuobanProxy:send(1210102,{reqType = 0})
        elseif self.c1.selectedIndex == 2 then
            proxy.HuobanProxy:send(1220103,{reqType = 0})
        elseif self.c1.selectedIndex == 3 then
            proxy.HuobanProxy:send(1230102,{reqType = 0})
        elseif self.c1.selectedIndex == 4 then
            proxy.HuobanProxy:send(1240102,{reqType = 0})
        end
        return 
    end

    local confData = conf.HuobanConf:getDataByLv(self.data.lev+1,self.c1.selectedIndex)
    local maxTo = conf.HuobanConf:getValue("endmaxjie",self.c1.selectedIndex) or _max_[self.c1.selectedIndex+1]
    if not confData or confData.jie>maxTo then
        return 
    end

    -- if self.c1.selectedIndex == 0 then
    --     return
    -- end

    
    self.is10 = true
    self:visibleInit()
    self.huobanJie.visible = true
    self.btnClose.visible = true
    if self.HuoBanJie then
        self.HuoBanJie:setData(self.data,self.huobanparam,true)
    end
end

function HuobanView:onbtnClose()
    -- body
    self.huobanPanel.visible = true
    self.huobanJie.visible = false
    self.btnClose.visible = false
    if self.c1.selectedIndex == 0 then
        self.pro1Panel.visible = true
        --伙伴属性
        self:updateZuoqi()
        if self.HuobanPro then
            self.HuobanPro:updateSelect()
        end
        if self.huoBan then
            self.huoBan:resetChengHao()
        end
    else
        self.pro2Panel.visible = true
        if self.HuoBanOtherPro then
            self.HuoBanOtherPro:updateSelect()
        end
        self:updateZuoqi()
        if self.huoBan then
            self.huoBan:selectCur(nil,true)
        end
    end
end

function HuobanView:onClickClose()
    if self.huoBan then 
        self.huoBan:setSelfmodle_id()--从精彩活动的跳转至此的时候，设置为nil bxp
    end
    --停止自动升级
    if self.HuoBanJie then
        self.HuoBanJie:setIsAuto(false)
    end

    if self.c1.selectedIndex == 0 then
        self:closeView()
        return 
    end

    if cache.HuobanCache:getIsZhuFu(self.c1.selectedIndex) then
        self:closeView()
        return 
    end

    if not self.HuoBanOtherPro then
        self:closeView()
        return
    end

    if not self.HuoBanOtherPro:isOverTime() then
        self:closeView()
        return
    end

    local param = {}
    param.type = 7
    param.index = self.c1.selectedIndex
    param.data = self.data
    param.radio = cache.HuobanCache:getIsZhuFu()
    param.text = language.huoban18[self.c1.selectedIndex]
    local nextconf = conf.HuobanConf:getDataByLv(self.data.lev,self.c1.selectedIndex)
    param.need_exp = nextconf.need_exp

    param.sure = function(flag)
        -- body
        local data = {}
        data.index = param.index
        cache.HuobanCache:setIsZhuFu(data.index,flag)
        
        local t = {1007,1008,1010,1009}
        data.id = t[param.index]

        GOpenView(data)
    end
    param.cancel = function( flag )
        -- body
        cache.HuobanCache:setIsZhuFu(param.index,flag)
    end
    GComAlter(param)


    self:closeView()
    
end


-------------------------------处理消息
function HuobanView:addMsgCallBack( data )
    -- body
    --plog("data.msgId = ",data.msgId)
    if  5200101 == data.msgId or 5210101 == data.msgId or 5220102 == data.msgId
            or data.msgId == 5230101 or 5240101 ==data.msgId then  
        --返回的界面设置不同的属性
        if not self.huobanJie.visible then
            self.huobanPanel.visible = true
            if 5200101 == data.msgId then
                --属性1
                self.pro1Panel.visible = true
            else
                --属性2
                self.pro2Panel.visible = true
            end
        end
        self.data = data
        self.is10 = true
        self.refreshModel = true
        self:updateZuoqi()
        --第一次进入选中当前
        local view = mgr.ViewMgr:get(ViewName.HuobanItemUse)
        if self.huoBan and not view then
            self.huoBan:selectCur(nil,nil)
            if self.moduleId and self.moduleId ~= 1 then
                -- print("当前展示模型id",self.moduleId)
                local info = conf.HuobanConf:getSkinsByModel(self.moduleId,self.c1.selectedIndex)
                -- print("self.moduleId>>>>>>>>>>>",self.moduleId,self.c1.selectedIndex)
                if not info then
                    info = conf.HuobanConf:getSkinsByIndex(self.moduleId,self.c1.selectedIndex)
                end
                if self.c1.selectedIndex == 0 then
                    if info and info.istshu == 2 then
                        self:onSkincallBack(info.id)
                    else
                        self:callpetItem(info)
                    end
                else
                    if info and not info.grow_cons then
                        self:onSkincallBack(info.id)
                    end
                end
            end
            self.huoBan:ScrollToRed()
            self.moduleId= nil 
        end
        if self.HuoBanOtherPro and self.pro2Panel.visible then
            self.HuoBanOtherPro:updateSelect()
        end

        if self.childIndex then
            self.childIndex = nil 
            self:onbtnCallBack()
        end

         --bxp打开时装升星
        if self.suitId then 
            self:onSkincallBack(self.suitId)
            self.suitId = nil
        end
        local confData = conf.HuobanConf:getDataByLv(self.data.lev,self.c1.selectedIndex)
        cache.HuobanCache:setCurPass(confData.jie or 1,self.c1.selectedIndex,false)
        local jie = confData and confData.jie or 1
        cache.PlayerCache:setDataJie(opent1[data.msgId],jie)
    elseif 5200201 == data.msgId or 5210102 == data.msgId or 5220103 == data.msgId
            or 5230102 == data.msgId or 5240102 ==data.msgId then --伙伴升阶
        -- print("伙伴升级",data.lev)
        -- printt(data)
        if self.c1.selectedIndex == 0 and data.msgId~=5200201 then
            return
        elseif self.c1.selectedIndex == 1 and data.msgId~=5210102 then
            return
        elseif self.c1.selectedIndex == 2 and data.msgId~=5220103 then
            return
        elseif self.c1.selectedIndex == 3 and data.msgId~=5230102 then
            return
        elseif self.c1.selectedIndex == 4 and data.msgId~=5240102 then
            return
        end
        self.is10 = false
        local confData = conf.HuobanConf:getDataByLv(self.data.lev,self.c1.selectedIndex)
        local newconfData = conf.HuobanConf:getDataByLv(data.lev,self.c1.selectedIndex)

        self.data.lev = data.lev
        self.data.levExp = data.levExp
        self.data.secs = data.secs
        self.data.blessTime = data.blessTime
        self.data.tempAttris = data.tempAttris
        self.data.exp = data.exp
        self.data.lastUpTime = data.lastUpTime
        self.data.power = data.power
        self.data.onlineSecs = data.onlineSecs

        self.refreshModel = false
        --改变伙伴称号
        if 5200201 == data.msgId then
            if confData.jie~=newconfData.jie then
                self.refreshModel = true
            end
            cache.PlayerCache:setPartnerLevel(data.lev)
            --刷一下称号
            local pet = mgr.ThingMgr:getObj(ThingType.pet,cache.PlayerCache:getRoleId())
            if pet then
                pet:setChenghao(data.lev)
            end
        end

        local confData_Check = conf.HuobanConf:getDataByLv(data.lev+1,self.c1.selectedIndex)
        
        if 5200201~= data.msgId and confData.jie~=newconfData.jie and newconfData.jie~=1 then --升级了
            self.refreshModel = true
            mgr.ViewMgr:openView(ViewName.HuobanUpView,function( view )
                -- body
                view:setData(self.data,confData,data.items,self.playPower,self.c1.selectedIndex)
            end)
            --停止自动升级
            self:setAuto(false)
            if self.HuoBanOtherPro then
                self.HuoBanOtherPro:setistimer()
            end
            --发送穿戴协议
            local _useData = conf.HuobanConf:getSkinsByJie(newconfData.jie,self.c1.selectedIndex)
            if 1 == self.c1.selectedIndex then
                proxy.HuobanProxy:send(1210105,{skinId = _useData.id})
            elseif 2 == self.c1.selectedIndex then
                proxy.HuobanProxy:send(1220106,{skinId = _useData.id})
            elseif 3 == self.c1.selectedIndex then
                proxy.HuobanProxy:send(1230105,{skinId = _useData.id})
            elseif 4 == self.c1.selectedIndex then
                proxy.HuobanProxy:send(1240105,{skinId = _useData.id})
            end

        end

        if self.HuoBanJie then
            self.HuoBanJie:playEff()
        end
        local confData_Check = conf.HuobanConf:getDataByLv(data.lev+1,self.c1.selectedIndex)
        self.maxTo = conf.HuobanConf:getValue("endmaxjie",self.c1.selectedIndex) or _max_[self.c1.selectedIndex+1]
        if not confData_Check or newconfData.jie>= self.maxTo then
            self:onbtnClose() 
            return  
        else
            self:updateZuoqi()
        end
        local jie = newconfData and newconfData.jie or 1
        cache.PlayerCache:setDataJie(opent2[data.msgId],jie)
        local prosId = opent3[data.msgId]
        if prosId then
            local prosData = cache.PackCache:getPackDataById(prosId)
            if prosData.amount > 0 and jie >= RiseProTipJie then
                mgr.ItemMgr:openQuickUse(prosData)
            end
        end
    elseif 5200103 == data.msgId or 5210103 == data.msgId or 5220104 == data.msgId
            or data.msgId == 5230103 or 5240103 ==data.msgId then --装备升级
        self.data.power = data.power
        self.data.equips[data.equipId] = data.lev
        self:updateZuoqi()

        
    elseif 5200104 == data.msgId or 5210104 == data.msgId or 5220105 == data.msgId
            or data.msgId == 5230104 or 5240104 ==data.msgId then --技能升级

        if 5200104 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1006,data.skillId,data.lev)
        elseif 5210104 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1007,data.skillId,data.lev)
        elseif 5220105 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1008,data.skillId,data.lev)
        elseif 5230104 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1010,data.skillId,data.lev)
        elseif 5240104 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1009,data.skillId,data.lev)
        end

        self.data.skills[data.skillId] = data.lev 
        self:updateZuoqi()
    elseif 5200105 == data.msgId or 5210105 == data.msgId or 5220106 == data.msgId
            or 5230105 == data.msgId or 5240105 ==data.msgId then --皮肤改变
            --plog("data.msgId",data.msgId)
            if self.huoBan and self.huobanPanel.visible then
                self.huoBan:setbtnTitle(data)
            end
    elseif 5200106 == data.msgId then --小伙伴改名
        if 0 ~= self.c1.selectedIndex then
            return 
        end
        for k , v in pairs(self.data.skins) do
            if v.skinId == data.skinId then
                self.data.skins[k].name = data.name
                self.data.skins[k].changeNameCount = data.changeNameCount
                if self.huoBan and self.huobanPanel.visible then
                    self.huoBan:initModel(v.skinId,true)
                end
                break
            end
        end 
    elseif data.msgId == 5200107 then
        if 0 ~= self.c1.selectedIndex then
            return 
        end

        local condata = conf.HuobanConf:getSkinsByIndex(data.skinId,0)
        GComAlter(string.format(language.huoban45,condata.name))

        for k , v in pairs(self.data.skins) do
            if v.skinId == data.skinId then
                self.data.skins[k].sign = 2
                if self.huoBan and self.huobanPanel.visible then
                    self.huoBan:initModel(v.skinId,true)
                end
                break
            end
        end 
        self:updateZuoqi()
    elseif data.msgId == 5200201 then
        
    end
end

function HuobanView:add5090102()
    -- body
    if self.HuoBanOtherPro then
        self.HuoBanOtherPro:setData(self.data)
    end

    if self.HuoBanJie then
        self.HuoBanJie:setData(self.data,self.huobanparam,self.refreshModel)
    end
end

function HuobanView:setAuto(flag)
    -- body
    if self.HuoBanJie then
        self.HuoBanJie:setIsAuto(flag)
    end
end

function HuobanView:checkVip(confData)
    -- body
    local id 
    if confData.jie < 4 then
        id = 1
    elseif confData.jie < 7 then
        id = 2
    else
        id = 3
    end

    return cache.PlayerCache:VipIsActivate(id)
end

--计算红点信息
function HuobanView:refreshRed()
    -- body
    if not self.data or not self.huoBan then
        return
    end
    --技能 装备 资质丹 潜力丹
    local number = self.huoBan:refreshRed()
    --plog(".number.",number)
    local maxTo = conf.HuobanConf:getValue("endmaxjie",self.c1.selectedIndex) or 10
    local confData = conf.HuobanConf:getDataByLv(self.data.lev,self.c1.selectedIndex)
    local confdatanext = conf.HuobanConf:getDataByLv(self.data.lev+1,self.c1.selectedIndex)
    if not confdatanext or confdatanext.jie>=maxTo  then
    else
        if self.c1.selectedIndex == 0 then
            for k ,v in pairs(self.data.skins) do
                if v.sign == 1 then
                    number = number + 1
                    break
                end
            end

            if GCheckTunShiEquip() then
                number = number + 1
            end
            
            local var = cache.PlayerCache:getRedPointById(10211)
            if var == 1 then
                number = number + 1
            end

            -- if confData.xing == 10 then
            --     if self:checkVip(confData) then
            --         number = number + 1
            --     elseif confData.jie_cost_sec and self.data.lastUpTime and self.data.onlineSecs then
            --         local var = confData.jie_cost_sec - (mgr.NetMgr:getServerTime() - self.data.lastUpTime+ self.data.onlineSecs)
            --         if var <= 0 then
            --             number = number + 1
            --         end
            --     end
            -- else--灵童吞噬装备红点删除
            --     if GCheckTunShiEquip() then
            --         number = number + 1
            --     end
            -- end
        else
            local var = conf.HuobanConf:getValue("bless_clear_jie",self.c1.selectedIndex)
            if confData.jie and confData.jie < var then
                if confData.cost_items then
                    --local var = cache.PackCache:getPackDataById(confData.cost_items[1]).amount
                    local var = cache.PackCache:getLinkCost(confData.cost_items[1])
                    if var >= confData.cost_items[2] then --足够
                        number = number + 1
                    end
                else
                    number = number + 1
                end
            end  
        end
    end
    -- if self.c1.selectedIndex == 0 then
    --     if self.HuobanPro.redimg.visible then
    --         number = number + 1
    --     end
    -- else
    --     if self.HuoBanOtherPro.redimg.visible then
    --         number = number + 1
    --     end
    -- end
    -- --plog("number",number,self.c1.selectedIndex)
    if number <= 0 then
        local var = redpoint[self.c1.selectedIndex+1]
        mgr.GuiMgr:redpointByID(var,cache.PlayerCache:getRedPointById(var))

         local t = {
            [1]=1006, --灵童
            [2]=1007, --灵羽
            [3]=1008, --灵兵
            [5]=1009, --灵器
            [4]=1010, --灵宝
        }
        GCloseAdvTip(t[self.c1.selectedIndex+1])
    else
        local var = redpoint[self.c1.selectedIndex+1]
        cache.PlayerCache:setRedpoint(var, 1)
        mgr.GuiMgr:updateRedPointPanels(var)
        mgr.GuiMgr:refreshRedTop()
        mgr.GuiMgr:refreshRedBottom()
    end
end

return HuobanView