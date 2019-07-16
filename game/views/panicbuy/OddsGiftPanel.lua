--
-- Author: 
-- Date: 2017-07-27 20:02:55
--

local OddsGiftPanel = class("OddsGiftPanel",import("game.base.Ref"))

function OddsGiftPanel:ctor(mParent,panel)
    self.mParent = mParent
    self.panelObj = panel
    self:initPanel()
end

function OddsGiftPanel:sendMsg(actId)
    self.actId = actId
    proxy.ActivityProxy:sendMsg(1030116, {reqType = 0,amount = 0,buyId = 0,typeId = actId})
end


function OddsGiftPanel:setData(data)
    self.data = data
    self.confdata = conf.ActivityConf:getDayGift(data.openDay)
    if not self.confdata then
        self.listView.numItems = 0
        return
    end

    self.listView.numItems = #self.confdata

    if data.items then
        GOpenAlert3(data.items)
    end
    -- if not self.timer then
    --     self:onTimer()
    --     self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    -- end
end

function OddsGiftPanel:clear()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function OddsGiftPanel:setVisible(visible)
    self.panelObj.visible = visible
    if not visible then
        self:clear()
    end
end

function OddsGiftPanel:initPanel()
    -- body
    self.listView = self.panelObj:GetChild("n15")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0


    local btnCZ = self.panelObj:GetChild("n5")
    btnCZ.onClick:Add(self.onChongzhi,self)
    btnCZ:GetChild("title").text = language.kaifu14

    self:initDec()
end

function OddsGiftPanel:initDec()
    -- body
    local dec1 = self.panelObj:GetChild("n7")
    dec1.text = language.kaifu15

    local dec1 = self.panelObj:GetChild("n8")
    dec1.text = language.kaifu26

    local dec1 = self.panelObj:GetChild("n14")
    dec1.text = mgr.TextMgr:getTextByTable(language.kaifu31)


     --时间
    self.time = self.panelObj:GetChild("n9")
    self.time.text = 0
     --
    --self.money = self.panelObj:GetChild("n10")
    --self.money.text = 0

    mgr.GuiMgr:registerMoneyPanel(self.panelObj,self.mParent:viewName())
end

function OddsGiftPanel:onTimer()
    -- body
    if not self.data then
        return 
    end
    if self.data.lastTime<=0 then
        if self.actId == 1026 then--开服前8天
            mgr.ViewMgr:closeAllView2()
            GComAlter(language.kaifu05)
        else
            self:sendMsg(self.actId)
        end
        return
    end

    self.time.text = GGetTimeData2(self.data.lastTime)
    self.data.lastTime = self.data.lastTime - 1
end

function OddsGiftPanel:setCurId(id)
    -- body
    self.id = id 
end

function OddsGiftPanel:celldata( index, obj )
    -- body
    local data = self.confdata[index+1]

    local c1 = obj:GetController("c1")
    c1.selectedIndex = data.zekou - 1

    local t = {mid = data.mid,amount = data.amount,bind = data.bind}
    local itemObj = obj:GetChild("n1")
    GSetItemData(itemObj,t,true)

    local dec1 = obj:GetChild("n2")
    dec1.text = language.kaifu27

    local dec1 = obj:GetChild("n3")
    dec1.text = language.kaifu28

    local dec1 = obj:GetChild("n4")
    dec1.text = language.kaifu29

    local dec1 = obj:GetChild("n9") 
    dec1.text = data.old_price

    local dec1 = obj:GetChild("n11") 
    dec1.text = data.price

    local dec1 = obj:GetChild("n5") 
    dec1.text = self.data.leftCountMap[data.id]

    local c2 = obj:GetController("c2")
    
    if self.data.leftCountMap[data.id] == 0 then
        c2.selectedIndex = 1
    else
        c2.selectedIndex = 0
    end

    local dec1 = obj:GetChild("n13")
    dec1.text = language.kaifu30


    local btn =  obj:GetChild("n12")
    btn.data = data
    btn.onClick:Add(self.onget,self)
end

function OddsGiftPanel:onget(context)
    local data = context.sender.data
    local var = self.data.leftCountMap[data.id]
    if  var == 0 then
        return
    end
    local param = {}
    param.shopData = {mid = data.mid}
    param.shopData.price = data.price
    param.shopData.callback = function(amount)
        -- body
        local sendParam = {
            reqType = 1,
            amount = amount,
            buyId = data.id,
            typeId = 1026,
        }
        proxy.ActivityProxy:sendMsg(1030116,sendParam)
    end
    param.itemData = {mid = data.mid ,amount = data.amount, bind = data.bind}

    mgr.ViewMgr:openView(ViewName.ShopBuyView,function(view)
        -- body
        view:setData(param,data.money_type)
        view:setBuyCount(var)
    end)

    
    -- 
end

function OddsGiftPanel:onChongzhi()
    -- body
    mgr.ViewMgr:closeAllView2()
    GGoVipTequan(0)
end

return OddsGiftPanel