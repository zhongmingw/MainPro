--
-- Author: wx
-- Date: 2017-02-13 14:17:24
--
local ZuoqiProPanel1 = import(".ZuoqiProPanel1") --坐骑界面的属性
local ZuoQiPanel = import(".ZuoQiPanel") --坐骑技能和装备
local ZuoqiJie =import(".ZuoqiJie") --坐骑进阶
local ZuoqiProPanel2 = import(".ZuoqiProPanel2")
local QiBingPanel = import(".QiBingPanel")


local ZuoQiMain = class("ZuoQiMain", base.BaseView)
local redpoint = {10216,10207,10210,10208,10209,10262,20216}
local opent1 = {
    [5120101] = 1001,
    [5140101] = 1002, --仙羽
    [5160101] = 1003, --神兵
    [5180101] = 1004, --仙器
    [5170101] = 1005, --法宝
    [5560101] = 1287, --麒麟臂
    [5650106] = 1438, --奇兵
}
local opent2 = {
    [5120102] = 1001,
    [5140102] = 1002, --仙羽
    [5160102] = 1003, --神兵
    [5180102] = 1004, --仙器
    [5170102] = 1005, --法宝
    [5560102] = 1287,  --麒麟臂
    [5650106] = 1438, --奇兵
}
local opent3 = {
    [5120102] = 221041040, --坐骑
    [5140102] = 221041041, --仙羽
    [5160102] = 221041042, --神兵
    [5180102] = 221041043, --仙器
    [5170102] = 221041044, --法宝
}
local opent4 = {
    1001, --坐骑
    1002, --仙羽
    1003, --神兵
    1004, --仙器
    1005, --法宝
    1287,--麒麟臂
    1438, -- 奇兵
}
local opent5 = {
    1001,1003,1005,1002,1004,1287, 1438
}
function ZuoQiMain:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    -- self.drawcall = false
    self.openTween = ViewOpenTween.scale
    self.uiClear = UICacheType.cacheForever
end

function ZuoQiMain:initData(data)
    -- body
    self.goontask = false
    self.isDoneUp = false
    self.refreshModel = true
    self.is10 = true --+10
    self.index =  data.index or 0 --默认选中哪个
    self.childIndex = data.childIndex
    self.moduleId = data.grandson
    self.suitId = data.suitId--时装升星的时装配置id
    self:addTimer(1,-1,handler(self,self.onTimer))
    --货币窗口
    GSetMoneyPanel(self.window2,self:viewName())
    --注册红点
    for k ,v in pairs(self.list) do
        if redpoint[k] and redpoint[k] ~= 0 then
            local redImg = v:GetChild("n4")
            local param = {panel = redImg,ids = {redpoint[k]}}
            mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
        end
    end
    --按开启等级设置位置 和 是否课件
    self:setVisible()
    --默认全部不可见
    self:visibleInit()


    if self.ZuoQiPanel then
        self.ZuoQiPanel.model.data = nil
    end
    if self.zuoqiJie then
        self.zuoqiJie.leftModel.data = nil
        self.zuoqiJie.rightModel.data = nil
        self.zuoqiJie.isAuto = false
    end
    if self.index == self.c1.selectedIndex then
        self:onController1()
    else
        self.c1.selectedIndex = self.index
    end

    self.super.initData()
end

function ZuoQiMain:initView()
    --单选控制
    self.window2 = self.view:GetChild("n0")

    local closeBtn = self.window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    --形象
    self.zuoqipanel = self.view:GetChild("n9")
    --坐骑属性
    self.panel1 = self.view:GetChild("n13")
    --其他属性
    self.panel2 = self.view:GetChild("n16")
    --进阶界面
    self.jijiepanel = self.view:GetChild("n15")

    -- 奇兵面板
    self.qiBingPanel = self.view:GetChild("n33")

    --5个按钮
    local index = 0
    self.list = {}
    self.btnpos = {}
    self.signList = {}
    for i = 1, 7 do
        index = index + 1
        local btn =  self.view:GetChild("n10"..i)
        btn.data = i - 1
        btn.onClick:Add(self.onbtnCall,self)
        btn:GetChild("title").text = language.zuoqi01[index]
        table.insert(self.btnpos,btn.y)
        table.insert(self.list,btn)
        local signIcon = self.view:GetChild("n2"..i)
        table.insert(self.signList,signIcon)
    end

    self.btnClose = self.view:GetChild("n17")
    self.btnClose.onClick:Add(self.onBtnBack,self)

    if g_is_banshu then
        for k ,v in pairs(self.signList) do
            v:SetScale(0,0)
        end
    end
end

function ZuoQiMain:onbtnCall(context)
    -- body
    local sender = context.sender
    local i = sender.data

    self.c1.selectedIndex = i
end

function ZuoQiMain:onTimer()
    -- body
    -- print("1111111")
    if self.ZuoqiProPanel2 then
        self.ZuoqiProPanel2:onTimer()
    end
    if self.Panel1 then
        self.Panel1:onTimer()
    end
    if self.zuoqiJie then
        self.zuoqiJie:onTimer()
    end
    if self.ZuoQiPanel then
        self.ZuoQiPanel:onTimer()
    end
end

--按开启等级设置位置 和 是否课件
function ZuoQiMain:setVisible()
    -- body

    local index = 1
    for k , v in pairs(opent4) do
        local selectedIndex = 0
        local sortindex = 1
        if v == 1001 then
            selectedIndex = 0
            sortindex = 1
        elseif v == 1003 then
            selectedIndex = 1
            sortindex = 2
        elseif v == 1005 then
            selectedIndex = 2
            sortindex = 3
        elseif v == 1002 then
            selectedIndex = 3
            sortindex = 4
        elseif v == 1004 then
            selectedIndex = 4
            sortindex = 5
        elseif v == 1287 then
            selectedIndex = 5
            sortindex = 6
        elseif v == 1438 then
            selectedIndex = 6
            sortindex = 7
        end

        local btn = self.list[sortindex]
        local sign = self.signList[sortindex]
        sign.visible = false
        btn.visible = mgr.ModuleMgr:CheckSeeView(v)
        if btn.visible then
            btn.sortingOrder = index
            sign.sortingOrder = index + 1
            btn.y = self.btnpos[index]
            local confData = conf.VipChargeConf:getDataById(selectedIndex)
            if selectedIndex == 0 then
                -- print("当前开服天数",GGetDayChargeDayTimes())
                if GGetDayChargeDayTimes() == 1 and GGetDayChargeState(confData.charge_grade) then
                    -- print("坐骑",confData.charge_grade)
                    sign.visible = true
                else
                    sign.visible = false
                end
            else
                if SkipType[GGetDayChargeDayTimes()%7] == selectedIndex and GGetDayChargeState(confData.charge_grade) then
                    sign.visible = true
                else
                    sign.visible = false
                end
                local openDay = cache.ActivityCache:get5030111().openDay
                if openDay > 7 then
                    sign.visible = false
                end
            end

            if not sign.visible then
                sign.visible = self:checkBuy(selectedIndex)
            end
            index = index + 1
        end
    end
end

function ZuoQiMain:checkTehui(index)
    -- body
    if true then
        --屏蔽特惠抢购 20180301
        return false
    end
    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end
    local condata = conf.SysConf:getHwbSBItem("zuoqi"..index)
    if not condata then
        return false
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return false
    end
    local _in
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

    if not condata.open_day then
        _in = {condata.buy_id[curday] or condata.buy_id[9]}
    end
    --检测是否购买了要求物品
    local key = g_var.accountId.."1026buy"
    local _localbuy = UPlayerPrefs.GetString(key)
    --plog("今天已将购买",_localbuy)
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

function ZuoQiMain:checkBaiBei(index)
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
    local condata = conf.SysConf:getHwbSBItem("zuoqi"..index)
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

function ZuoQiMain:checkBuy(index)
    -- body


    return false--self:checkTehui(index) or self:checkBaiBei(index)
end

--默认全部不可见
function ZuoQiMain:visibleInit()
    -- body
    self.zuoqipanel.visible = false
    self.panel1.visible = false
    self.jijiepanel.visible = false
    self.panel2.visible = false
    self.btnClose.visible = false
end
--请求界面信息
function ZuoQiMain:onController1()
    -- body
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
    --形象
    if not self.ZuoQiPanel then
        self.ZuoQiPanel = ZuoQiPanel.new(self)
    end
    --进阶
    if not self.zuoqiJie then
        self.zuoqiJie = ZuoqiJie.new(self)

    end
    self.zuoqiJie:setIsAuto(false)

    if 0 == self.c1.selectedIndex then --坐骑
        if not self.Panel1 then
            self.Panel1 = ZuoqiProPanel1.new(self)
        end
        self.Panel1.c1.selectedIndex = 0
        self.Panel1:setistimer() --切换界面
        proxy.ZuoQiProxy:send(1120101)
    else
        if not self.ZuoqiProPanel2 then
            self.ZuoqiProPanel2 = ZuoqiProPanel2.new(self)
        end
        self.ZuoqiProPanel2:setistimer() --切换界面
        self.ZuoqiProPanel2:updateSelect(0)

        if nil == self.QiBingPanel then
            self.QiBingPanel = QiBingPanel.new(self)
        end

        if 1 == self.c1.selectedIndex then --神兵
            proxy.ZuoQiProxy:send(1160101)
        elseif 2 == self.c1.selectedIndex then --法宝
            proxy.ZuoQiProxy:send(1170101)
        elseif 3 == self.c1.selectedIndex then --仙羽
            proxy.ZuoQiProxy:send(1140101)
        elseif 4 == self.c1.selectedIndex then --仙器
            proxy.ZuoQiProxy:send(1180101)
        elseif 5 == self.c1.selectedIndex then --麒麟臂
            proxy.ZuoQiProxy:send(1560101)
        elseif 6 == self.c1.selectedIndex then --奇兵
            proxy.QiBingProxy:sendGetInfo()
        end
    end

    self:setPanelState(self.c1.selectedIndex)
end
--属性界面的激活 或者 进阶界面按钮返回
function ZuoQiMain:onbtnCallBack()
    if not self.data then return end
    if self.data.lev == 0 then
        --意外灭有激活的时候
        if self.c1.selectedIndex == 3 then
            proxy.ZuoQiProxy:send(1140102,{reqType = 0})
        elseif self.c1.selectedIndex == 1 then
            proxy.ZuoQiProxy:send(1160102,{reqType = 0})
        elseif self.c1.selectedIndex == 2 then
            proxy.ZuoQiProxy:send(1170102,{reqType = 0})
        elseif self.c1.selectedIndex == 4 then
            proxy.ZuoQiProxy:send(1180102,{reqType = 0})
        elseif self.c1.selectedIndex == 0 then
            proxy.ZuoQiProxy:send(1120102,{auto = 0})
        elseif self.c1.selectedIndex == 5 then
            --print("sendmsg 1560102")
            proxy.ZuoQiProxy:send(1560102,{reqType = 0})
        end
        return
    end
    --是否还有下级
    local confData = conf.ZuoQiConf:getDataByLv(self.data.lev + 1,self.c1.selectedIndex)
    local maxTo = conf.ZuoQiConf:getValue("endmaxjie",self.c1.selectedIndex) or 10
    --print("confData",confData,self.data.lev,confData.jie,maxTo)
    if not confData or confData.jie > maxTo then
        return
    end
    --跳转到进阶界面
    self.is10 = true
    self:visibleInit()
    self.jijiepanel.visible = true
    self.btnClose.visible = true
    self.zuoqiJie:setData(self.data,true)
end

function ZuoQiMain:setData(data_)
    self:onController1()
end
--技能点击
function ZuoQiMain:callLeftItem( param )
    -- body
    local data = param
    mgr.ViewMgr:openView(ViewName.ZuoQiSkillUp, function(view)
        -- body
        view:setData(self.c1.selectedIndex)
    end, data)
end
--装备点击
function ZuoQiMain:callRightItem( param )
    -- body
    local data = param
    mgr.ViewMgr:openView(ViewName.ZuoQiEquipUp, function(view)
    -- body
        view:setData(self.c1.selectedIndex)
    end, data)
end

function ZuoQiMain:refreshZuoqi(isSx,id)
    self:updateZuoqi(self.data,isSx)
    if self.Panel1 and self.panel1.visible then
        self.Panel1:initPro2(id)
    end
    if self.ZuoqiProPanel2 and self.panel2.visible then
        self.ZuoqiProPanel2:initPro2(id)
    end
end
--设置数据 --flag 升级红点扣除
function ZuoQiMain:updateZuoqi(data,isSx)
    -- body
    --左边形象
    if self.ZuoQiPanel and self.zuoqipanel.visible then
        self.ZuoQiPanel:setData(data)
    end
    --坐骑属性
    if self.Panel1 and self.panel1.visible then
        self.Panel1:setData(data,isSx)
        self.isDoneUp = false
    end
    --神兵属性，1，，,,，1
    if self.ZuoqiProPanel2 and self.panel2.visible then
        self.ZuoqiProPanel2:setData(data,self.isDoneUp)
        self.isDoneUp = false
    end
    --进阶界面
    if self.zuoqiJie and self.jijiepanel.visible then
        self.zuoqiJie:setData(data,self.refreshModel)
    end

    --刷新红点信息
    self:refreshRed()
end
--特殊皮肤选择
function ZuoQiMain:onSkincallBack(id)
    -- body
    if self.ZuoQiPanel and self.zuoqipanel.visible then
        self.ZuoQiPanel:initModel(id,true)
    end

    if self.Panel1 and self.panel1.visible then
        self.Panel1:initPro2(id)

    end
    if self.ZuoqiProPanel2 and self.panel2.visible then
        self.ZuoqiProPanel2:initPro2(id)

    end
end
--特殊皮肤选择 返回按钮
function ZuoQiMain:onSkinBack()
    -- body
    if self.Panel1 and self.panel1.visible then
        self.Panel1:updateSelect(0)
        self.Panel1:setData(self.data)
    end

    if self.ZuoqiProPanel2 and self.panel2.visible then
        self.ZuoqiProPanel2:updateSelect(0)
        self.ZuoqiProPanel2:setData(self.data)
    end
end

function ZuoQiMain:onBtnBack()
    -- body
    if self.zuoqiJie then
        self.zuoqiJie:setIsAuto(false)
    end
    if self.jijiepanel.visible  then
        self.zuoqipanel.visible = true
        self.jijiepanel.visible = false
        if self.c1.selectedIndex == 0 then
            self.panel1.visible = true
            self.panel2.visible = false
        else
            self.panel1.visible = false
            self.panel2.visible = true
        end
        self:updateZuoqi(self.data)
        if self.ZuoQiPanel then
            self.ZuoQiPanel:selectCur(nil,true)
        end

        self.btnClose.visible = false
    end
    self:refreshRed()
end

function ZuoQiMain:onClickClose(flag)
    -- body
    --停止自动升级
    if self.zuoqiJie then
        self.zuoqiJie:setIsAuto(false)
    end

    if self.goontask then
        GgoToMainTask()
    end
    --以下判定是 如果有祝福值的情况下给个 额外的view提示
    if cache.ZuoQiCache:getIsZhuFu(self.c1.selectedIndex+1) then
        self:closeView()
        return
    end

    if not self.ZuoqiProPanel2 then
        self:closeView()
        return
    end

    if self.ZuoqiProPanel2 and not self.ZuoqiProPanel2:isOverTime() and self.c1.selectedIndex ~= 0 then
        self:closeView()
        return
    end
    if self.Panel1 and not self.Panel1:isOverTime() and self.c1.selectedIndex == 0 then
        self:closeView()
        return
    end

    local text = {
        language.zuoqi53_1,
        language.zuoqi53,
        language.zuoqi54,
        language.zuoqi55,
        language.zuoqi56,
    }

    local param = {}
    param.type = 7
    param.index = self.c1.selectedIndex
    param.data = self.data
    param.radio = cache.ZuoQiCache:getIsZhuFu(param.index+1)
    local nextconf = conf.ZuoQiConf:getDataByLv(self.data.lev,self.c1.selectedIndex)
    param.need_exp = nextconf.need_exp

    param.text = text[self.c1.selectedIndex+1]
    param.sure = function(flag)
        -- body
        local t = {1001,1003,1005,1002,1004}
        local data = {}
        data.index = param.index
        cache.ZuoQiCache:setIsZhuFu(data.index+1,flag)
        data.id = t[data.index+1]
        GOpenView(data)
    end
    param.cancel = function( flag )
        -- body
        cache.ZuoQiCache:setIsZhuFu(param.index+1,flag)
    end
    GComAlter(param)

    self.ZuoQiPanel:setSelfmodle_id()
    self:dispose()
    self:closeView()
end

function ZuoQiMain:checkIsHave(id)
    -- body
    if not self.data then
        return false
    end
    --皮肤是否拥有
    for k ,v in pairs(self.data.skins) do
        if v.skinId == id then
            return true
        end
    end

    return false
end

function ZuoQiMain:addMsgCallBack(data)
    -- body
    if 5120101 == data.msgId
        or 5140101 == data.msgId
        or 5160101 == data.msgId
        or 5170101 ==  data.msgId
        or 5180101 == data.msgId
        or 5560101 ==  data.msgId then

        if not self.jijiepanel.visible then
            --不是二层升级进阶页面
            self.zuoqipanel.visible = true
            if 5120101 == data.msgId then
                self.panel1.visible = true --坐骑
            else
                self.panel2.visible = true --其他
            end
        end
        self.data = data

        self.is10 = true
        self.refreshModel = true
        self:updateZuoqi(data)
        --第一次进入选中当前
        if self.ZuoQiPanel then
            self.ZuoQiPanel:selectCur(nil,nil)
            if self.moduleId then
                --按模型跳转指定阶
                local info = conf.ZuoQiConf:getSkinsByModle(self.moduleId,self.c1.selectedIndex)
                if info and not info.grow_cons then
                    self:onSkincallBack(info.id)
                end
                self.moduleId = nil
            end
        end
        --打开进阶界面
        if self.childIndex then
            self.childIndex = nil
            if self.data.lev > 0 then
                self:onbtnCallBack()
            end
        end
        --bxp打开时装升星
        if self.suitId then
            self:onSkincallBack(self.suitId)
            self.suitId = nil
        end

        local confData = conf.ZuoQiConf:getDataByLv(self.data.lev,self.c1.selectedIndex)
        local jie = confData and confData.jie or 1
        cache.ZuoQiCache:setCurPass(jie,self.c1.selectedIndex,false)
        cache.PlayerCache:setDataJie(opent1[data.msgId],jie) --记录当前阶数
    elseif 5120102 == data.msgId or 5140102 == data.msgId or 5160102 == data.msgId or 5170102 ==  data.msgId
        or 5180102 == data.msgId or data.msgId==5560102 then
        if self.c1.selectedIndex == 0 and data.msgId~=5120102 then
            return
        elseif self.c1.selectedIndex == 1 and data.msgId~=5160102 then
            return
        elseif self.c1.selectedIndex == 2 and data.msgId~=5170102 then
            return
        elseif self.c1.selectedIndex == 3 and data.msgId~=5140102 then
            return
        elseif self.c1.selectedIndex == 4 and data.msgId~=5180102 then
            return
        elseif self.c1.selectedIndex == 5 and data.msgId~=5560102 then
        end
        self.is10 = false
        local confData = conf.ZuoQiConf:getDataByLv(self.data.lev,self.c1.selectedIndex)
        local newconfData = conf.ZuoQiConf:getDataByLv(data.lev,self.c1.selectedIndex)
        local falg = false --是否发送佩戴协议
        -- if 5120102 == data.msgId then -- 升级成功加个票子
        --     -- if self.zuoqiJie  then
        --     --     self.zuoqiJie:actionTip()
        --     -- end
        --     cache.PlayerCache:setAttribute(attConst.A10240,data.levExp)
        --     cache.PlayerCache:setAttribute(attConst.A10241,data.lev)
        --     cache.PlayerCache:setAttribute(attConst.A10242,data.secs)
        -- end

        self.data.lev = data.lev
        self.data.levExp = data.levExp
        self.data.secs = data.secs
        self.data.blessTime = data.blessTime
        -- print("临时属性",data.tempAttris)
        -- self.data.tempAttris = data.tempAttris
        self.data.power = data.power
        self.data.isCrit = data.isCrit

        self.refreshModel = false

        if self.c1.selectedIndex == 5  and data.lev == 1 then
            --麒麟臂有激活的
            local info = conf.ZuoQiConf:getSkinsByJie(1,self.c1.selectedIndex)
            local param = {}
            param.skinId = info.id
            proxy.ZuoQiProxy:send(1560105,param)
        end

        if confData.jie~=newconfData.jie and newconfData.jie~=1  then --升级了
            self.refreshModel = true
            mgr.ViewMgr:openView(ViewName.ZuoQiUpView,function( view )
                -- body
                view:setData(self.data,confData,data.items,self.playPower,self.c1.selectedIndex)
            end)
            --停止自动升级
            if self.zuoqiJie then
                self.zuoqiJie:setIsAuto(false)
            end
            if self.ZuoqiProPanel2 then
                self.ZuoqiProPanel2:setistimer() --切换界面
            end
            if self.Panel1 then
                self.Panel1:setistimer()
            end
            --升级成功 自动穿戴
            local _useData = conf.ZuoQiConf:getSkinsByJie(newconfData.jie,self.c1.selectedIndex)
            if 0 == self.c1.selectedIndex then
                local param = {}
                param.skinId = _useData.id
                param.reqType = 1
                proxy.ZuoQiProxy:send(1120105,param)
            else
                local param = {}
                param.skinId = _useData.id
                if 3 == self.c1.selectedIndex then
                    proxy.ZuoQiProxy:send(1140105,param)
                elseif 1 == self.c1.selectedIndex then
                    proxy.ZuoQiProxy:send(1160105,param)
                elseif 2 == self.c1.selectedIndex then
                    proxy.ZuoQiProxy:send(1170105,param)
                elseif 4 == self.c1.selectedIndex then
                    proxy.ZuoQiProxy:send(1180105,param)
                elseif 5 == self.c1.selectedIndex then
                    proxy.ZuoQiProxy:send(1560105,param)
                end
            end
        end

        if self.zuoqiJie then
            self.zuoqiJie:playEff()
        end
        self.isDoneUp = true
        --检测是否有下级
        self.maxTo = conf.ZuoQiConf:getValue("endmaxjie",self.c1.selectedIndex) or 10
        local confData_Check = conf.ZuoQiConf:getDataByLv(data.lev+1,self.c1.selectedIndex)
        if not confData_Check or newconfData.jie >= self.maxTo then
            self:onBtnBack() --没有下一级 返回1层界面
        else
            --刷新数据
            self:updateZuoqi(self.data)
        end
        --背包物品快速使用
        local jie = newconfData and newconfData.jie or 1
        cache.PlayerCache:setDataJie(opent2[data.msgId],jie)
        local prosId = opent3[data.msgId]
        if prosId then
            local prosData = cache.PackCache:getPackDataById(prosId)
            if prosData.amount > 0 and jie >= RiseProTipJie then
                mgr.ItemMgr:openQuickUse(prosData)
            end
        end
    elseif 5120103 == data.msgId or 5140103 == data.msgId or 5160103 == data.msgId
        or 5170103 == data.msgId or 5180103 == data.msgId
        or 5560103 == data.msgId then --装备升级
        if data.lev == 1 then
            GComAlter(language.zuoqi64)
        else
            GComAlter(language.zuoqi63)
        end
        self.data.power = data.power
        self.data.equips[data.equipId] = data.lev
        self:updateZuoqi(self.data)
    elseif 5120104 == data.msgId or 5140104 == data.msgId or 5160104 == data.msgId
        or 5170104 == data.msgId or 5180104 == data.msgId or 5560104 == data.msgId  then --技能升级
        --用于市场标记是否需要的技能书
        if 5120104 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1001,data.skillId,data.lev)
        elseif 5140104 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1002,data.skillId,data.lev)
        elseif 5160104 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1003,data.skillId,data.lev)
        elseif 5170104 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1005,data.skillId,data.lev)
        elseif 5180104 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1004,data.skillId,data.lev)
        elseif 5560104 == data.msgId then
            cache.PlayerCache:updateSkillLevel(1287,data.skillId,data.lev)
        end

        if data.lev == 1 then
            GComAlter(language.zuoqi64)
        else
            GComAlter(language.zuoqi63)
        end
        self.data.power = data.power
        self.data.skills[data.skillId] = data.lev
        self:updateZuoqi(self.data)

    elseif 5120105 == data.msgId or 5140105 == data.msgId or 5160105 == data.msgId
        or 5170105 == data.msgId or 5180105 == data.msgId or 5560105 == data.msgId  then
        --self:updateZuoqi(self.data)
        --第一次进入选中当前
        if self.ZuoQiPanel then
            self.ZuoQiPanel:setbtnTitle()
        end
    elseif 5650101 == data.msgId
        or 5650102 == data.msgId
        or 5650103 == data.msgId
        or 5650104 == data.msgId
        or 5650105 == data.msgId
        or 5650106 == data.msgId
        or 8240302 == data.msgId
        or 8240303 == data.msgId then

        self:flushQiBing(data)
        self:refreshRed()
    end

end
--红点检测
function ZuoQiMain:redPointCheck()
    -- body
    --使用成功 检测装备是否还能升级
end

--------
function ZuoQiMain:add5090102()
    -- body
    if self.zuoqiJie then
        self.zuoqiJie:setData(self.data,self.refreshModel)
    end
    if self.Panel1 and self.panel1.visible then
        self.Panel1:setData(self.data)
    end
    if self.ZuoqiProPanel2 and self.panel2.visible then
        self.ZuoqiProPanel2:setData(self.data)
    end
end

function ZuoQiMain:setAuto(flag)
    -- body
    if self.zuoqiJie then
        self.zuoqiJie:setIsAuto(false)
    end
end

---为了引导打开的界面返回主界面继续任务
function ZuoQiMain:setGoonGuide()
    -- body
    self.goontask = true
end

--计算红点信息
function ZuoQiMain:refreshRed()
    -- body
    if not self.data or not self.ZuoQiPanel  then
        return
    end

    --技能 装备 资质丹 潜力丹
    local number = self.ZuoQiPanel:refreshRed()
    if self.c1.selectedIndex == 6 then -- 奇兵
        local isOpen = mgr.ModuleMgr:CheckView({id = opent5[self.c1.selectedIndex + 1], falg = true})
        if isOpen then
            local isHadRedPoint = cache.QiBingCache:calcAllRedPoint()
            number = isHadRedPoint and number + 1 or number
        end
    else
        local maxTo = conf.ZuoQiConf:getValue("endmaxjie",self.c1.selectedIndex) or 10
        local confData = conf.ZuoQiConf:getDataByLv(self.data.lev,self.c1.selectedIndex)
        local confdatanext = conf.ZuoQiConf:getDataByLv(self.data.lev+1,self.c1.selectedIndex)
        if not confdatanext or (confdatanext and confdatanext.jie>=maxTo)  then
        else
            if self.c1.selectedIndex == 0 then
                local var = conf.ZuoQiConf:getValue("bless_clear_jie",self.c1.selectedIndex)
                if confData.jie and confData.jie < var then
                    if confData.cost_items then --消耗道具
                        local var = cache.PackCache:getLinkCost(confData.cost_items[1])
                        if var >= confData.cost_items[2] then --足够
                            number = number + 1
                        end
                    else
                        number = number + 1
                    end
                end
            elseif self.c1.selectedIndex == 5 then
                --红点计算
                if confData.jie and confData.cost_items  then
                   local var = cache.PackCache:getLinkCost(confData.cost_items[1])
                    if var >= confData.cost_items[2] then --足够
                        number = number + 1
                    end
                end
            else
                local var = conf.ZuoQiConf:getValue("bless_clear_jie",self.c1.selectedIndex)
                if confData.jie and confData.jie < var then
                    if confData.cost_items then --消耗道具
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
    end

    if number <= 0 then
        local var = redpoint[self.c1.selectedIndex+1]
        mgr.GuiMgr:redpointByID(var,cache.PlayerCache:getRedPointById(var))

        local t = {
            [1]=1001, --坐骑
            [4]=1002, --仙羽
            [2]=1003, --神兵
            [5]=1004, --仙器
            [3]=1005, --法宝
            [6]=1287,
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

function ZuoQiMain:setPanelState(index)
    local value = index == 6
    self.zuoqipanel.visible = not value
    -- --坐骑属性
    -- self.panel1.visible = not value
    -- --其他属性
    -- self.panel2.visible = not value
    if value then
        --进阶界面
        self.jijiepanel.visible = false
    end
    self.qiBingPanel.visible = value
end

function ZuoQiMain:flushQiBing(data)
    if nil == self.QiBingPanel then
        return
    end
    self.QiBingPanel:flush(data)
end

function ZuoQiMain:doClearView(clear)
    if nil == self.QiBingPanel then
        return
    end
    self.QiBingPanel:closeView()
end

return ZuoQiMain