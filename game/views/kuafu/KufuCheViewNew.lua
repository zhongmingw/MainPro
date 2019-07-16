--
-- Author: 
-- Date: 2018-01-04 19:58:29
--

local KufuCheViewNew = class("KufuCheViewNew", base.BaseView)
local _color = {5,10,1,15,3}
function KufuCheViewNew:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function KufuCheViewNew:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n5")
    btnClose.onClick:Add(self.onCloseView,self)

    self.c1 = self.view:GetController("c1")

    self.c2 = self.view:GetController("c2")
    
    local btnReSet = self.view:GetChild("n16")
    btnReSet.onClick:Add(self.onReset,self)

    local btnSetMax = self.view:GetChild("n17")
    btnSetMax.onClick:Add(self.onSetMax,self)

    local btnStart = self.view:GetChild("n18")
    btnStart.onClick:Add(self.onStart,self)

    local dec = self.view:GetChild("n21")
    dec.text = language.kuafu136
    self.costreset = self.view:GetChild("n22")
    self.costreset.text = ""

    local dec = self.view:GetChild("n23")
    dec.text = language.kuafu137
    self.costsetmax = self.view:GetChild("n24")
    self.costsetmax.text = ""

    local dec = self.view:GetChild("n25")
    dec.text = language.kuafu138
    self._count = self.view:GetChild("n26")
    self._count.text = ""


    self.chename = self.view:GetChild("n31")
    self.chename.text = ""

    self.moneytq = self.view:GetChild("n34")
    self.moneytq.text = ""

    self.moneyexp = self.view:GetChild("n35")
    self.moneyexp.text = ""

end

function KufuCheViewNew:initData()
    -- body
     --镖车系数
    self.level_coef = conf.KuaFuConf:getValue("level_coef")
    self.base_add = conf.KuaFuConf:getValue("base_add_value")

    self.data = cache.KuaFuCache:getTaskCache(2)
    self:setData()
end

function KufuCheViewNew:setData(data_)
    if self.data.cardId >= 5 then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
    end

    --设置刷新消耗
    self.cardId = math.max(self.data.cardId,1)
    --设置选中的车
    self.c2.selectedIndex = self.cardId - 1
    self.condata = conf.KuaFuConf:getSjzbCar(self.cardId)
    if self.condata.finish_item and self.condata.finish_item[1] then
        self.moneytq.text = self.condata.finish_item[1][2]
    else
        self.moneytq.text = 0
    end

   
    self.chename.text =self.condata.name-- mgr.TextMgr:getTextColorStr(self.condata.name, _color[self.cardId]) 

    local level = cache.PlayerCache:getRoleLevel()
    local expvalue = math.floor((level*self.level_coef+self.base_add)*self.condata.car_exp_coef/100)
    self.moneyexp.text = string.format("%.1f",expvalue/10000)..language.gonggong52

    local param = {}
    --刷新
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
    --元宝
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
    --次数
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

function KufuCheViewNew:onReset()
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

function KufuCheViewNew:onSetMax()
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

function KufuCheViewNew:onStart()
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

function KufuCheViewNew:onCloseView()
    -- body
    self:closeView()
end

function KufuCheViewNew:add5410104(data)
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



return KufuCheViewNew