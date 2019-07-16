--
-- Author: 
-- Date: 2017-08-24 14:24:26
--

local KufuCheView = class("KufuCheView", base.BaseView)

function KufuCheView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function KufuCheView:initView()
    local btnClose = self.view:GetChild("n2"):GetChild("n5")
    btnClose.onClick:Add(self.onCloseView,self)


    self.c1 = self.view:GetController("c1")
    self.listbtn = {}
    --镖车系数
    self.level_coef = conf.KuaFuConf:getValue("level_coef")
    self.base_add = conf.KuaFuConf:getValue("base_add_value")
    for i = 7 , 11 do
        local btn = self.view:GetChild("n"..i)
        self:setInfo(btn,i-6)
        table.insert(self.listbtn,btn)
    end

    local btnReSet = self.view:GetChild("n3")
    btnReSet.onClick:Add(self.onReset,self)

    local btnSetMax = self.view:GetChild("n4")
    btnSetMax.onClick:Add(self.onSetMax,self)

    local btnStart = self.view:GetChild("n5")
    btnStart.onClick:Add(self.onStart,self)

    local dec = self.view:GetChild("n12")
    dec.text = language.kuafu136
    self.costreset = self.view:GetChild("n15")
    self.costreset.text = ""

    local dec = self.view:GetChild("n18")
    dec.text = language.kuafu137
    self.costsetmax = self.view:GetChild("n20")
    self.costsetmax.text = ""

    local dec = self.view:GetChild("n21")
    dec.text = language.kuafu138
    self._count = self.view:GetChild("n23")
    self._count.text = ""
end

function KufuCheView:setInfo(btn,i)
    -- body
    local condata = conf.KuaFuConf:getSjzbCar(i)
    if not condata then
        btn.visible = false
        plog("配置丢失",i)
        return
    end
    btn.visible = true

    local _color = {5,10,1,15,3}
    
    local _name = btn:GetChild("n5")
    _name.text = mgr.TextMgr:getTextColorStr(condata.name, _color[i]) 

    btn:GetController("c1").selectedIndex = i - 1

    local _gongxun = btn:GetChild("n8") 
    local _icon1 = btn:GetChild("n6")

    local _iconjs = btn:GetChild("n11")
    local _js = btn:GetChild("n12")
    if condata.finish_item and condata.finish_item[1] then
        _gongxun.text = condata.finish_item[1][2]
        _icon1.visible = true
    else
        _gongxun.text = ""
        _icon1.visible = false
    end

    if condata.finish_item and condata.finish_item[2] then 
        _js.text = condata.finish_item[2][2]
        _iconjs.visible = true
    else
        _js.text = ""
        _iconjs.visible = false
    end 

    local _exp = btn:GetChild("n9") 
    local _icon2 = btn:GetChild("n7")
    
    _icon2.visible = true
    local level = cache.PlayerCache:getRoleLevel()
    local expvalue = math.floor((level*self.level_coef+self.base_add)*condata.car_exp_coef/100)
    _exp.text = string.format("%.1f",expvalue/10000)..language.gonggong52

    

    -- if condata.finish_item and condata.finish_item[2] then
    --     _exp.text = condata.finish_item[2][2]
    --     _icon2.visible = true
    -- else
    --     _exp.text = ""
    --     _icon2.visible = false
    -- end
end

function KufuCheView:initData()
    -- body
    self.data = cache.KuaFuCache:getTaskCache(2)
    self:setData()
end

function KufuCheView:setData(data_)
    --设置当前选中
    self.canreset = false
    self.canMax = false
    self.canhs = false

    if self.data.cardId >= 5 then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
    end
    
    --设置刷新消耗
    self.cardId = math.max(self.data.cardId,1)
    self.condata = conf.KuaFuConf:getSjzbCar(self.cardId)
    --设置选中
    for k ,v in pairs(self.listbtn) do
        local c1 = v:GetController("c2")
        if k == self.cardId then
            c1.selectedIndex = 1
        else
            c1.selectedIndex = 0
        end
    end

    --ref_cost
    local param = {}
    if self.condata.ref_cost then
        local _pack = cache.PackCache:getPackDataById(self.condata.ref_cost[1])
        
        if _pack.amount >= self.condata.ref_cost[2] then
            self.canreset = true
            table.insert(param,{text = _pack.amount,color = 7})
        else
            table.insert(param,{text = _pack.amount,color = 14})
        end
        table.insert(param,{text ="/"..self.condata.ref_cost[2],color = 7})

        self.costreset.text = mgr.TextMgr:getTextByTable(param)
    else
        self.costreset.text = ""
    end


    local _money = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local maxmoner = conf.KuaFuConf:getValue("orange_car_cost") 
    param = {}
    if _money >= maxmoner[1] then
        self.canMax = true
        table.insert(param,{text = _money,color = 7})
    else
        table.insert(param,{text = _money,color = 14})
    end
    table.insert(param,{text ="/"..maxmoner[1],color = 7})

    self.costsetmax.text = mgr.TextMgr:getTextByTable(param)

    local _t = conf.KuaFuConf:getSjzbTask(2)
    local var = _t and _t.limit_count or 1
    param = {}
    if self.data.curCount < var then
        self.canhs = true
        table.insert(param,{text = self.data.curCount,color = 7})
    else
        table.insert(param,{text = self.data.curCount,color = 14})
    end
    table.insert(param,{text = "/"..var,color = 7})
    self._count.text = mgr.TextMgr:getTextByTable(param)
end

function KufuCheView:onReset()
    -- body
    --刷新车
    if not self.data then
        return
    end

    if self.data.cardId >= 5 then
        GComAlter(language.kuafu139)
        return
    end

    if self.canreset then
        proxy.KuaFuProxy:sendMsg(1410104,{type = 1})
    else
        GComAlter(language.gonggong11)
    end
end

function KufuCheView:onSetMax()
    -- body
    if not self.data then
        return
    end

    if self.data.cardId >= 5 then
        GComAlter(language.kuafu139)
        return
    end

    if self.canMax then
        proxy.KuaFuProxy:sendMsg(1410104,{type = 2})
    else
        GComAlter(language.gonggong18)
    end
end

function KufuCheView:onStart()
    -- body
    if not self.data then
        return
    end
    if self.canhs then
        proxy.KuaFuProxy:sendMsg(1410202,{type=1})
    else
        GComAlter(language.kuafu124)
    end

    self:onCloseView()
end

function KufuCheView:onCloseView()
    -- body
    self:closeView()
end

function KufuCheView:add5410104(data)
    -- body
    --请求三界争霸刷新镖车
    --三界争霸，镖车刷新成功、失败（升至、降至XX），需要飘字提示
    local condata = conf.KuaFuConf:getSjzbCar(data.cardId)
    if self.data.cardId > data.cardId then
        --降至XX
        GComAlter(string.format(language.kuafu158,condata.name))
    elseif self.data.cardId == data.cardId then
        GComAlter(language.kuafu160)
    else
        --升至xx
        GComAlter(string.format(language.kuafu158,condata.name))
    end

    self.data.cardId = data.cardId
    self:setData()
end

return KufuCheView