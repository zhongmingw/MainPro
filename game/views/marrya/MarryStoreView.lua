--
-- Author: Your Name
-- Date: 2017-11-25 14:21:37
--

local MarryStoreView = class("MarryStoreView", base.BaseView)

function MarryStoreView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function MarryStoreView:initView()
    GSetMoneyPanel(self.view,self:viewName())
    local closeBtn = self.view:GetChild("n11")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    local chargeBtn = self.view:GetChild("n13")
    chargeBtn.onClick:Add(self.onClickCharge,self)
end

function MarryStoreView:onClickCharge()
    GOpenView({id = 1042})
end

function MarryStoreView:celldata( index,obj )
    local data = self.shopData[index + 1]
    if data then
        local item = obj:GetChild("n1")
        local itemData = {mid = data.mid,amount = data.amount,bind = data.bind or 0}
        GSetItemData(item,itemData,true)--设置道具信息
        local textName = obj:GetChild("n2")--名字
        local name = conf.ItemConf:getName(data.mid)
        textName.text = name
        local textPrice = obj:GetChild("n4")--当前价格
        textPrice.text = data.price
        local iconImg = obj:GetChild("n3")
        if data.money_type == 1 then --元宝
            local iconUrl = ResPath.iconRes("gonggongsucai_103")  --UIPackage.GetItemURL("_icons" , "gonggongsucai_103")
            iconImg.url = iconUrl
        elseif data.money_type == 2 then --绑元
            local iconUrl = ResPath.iconRes("gonggongsucai_108")  --UIPackage.GetItemURL("_icons" , "gonggongsucai_108")
            iconImg.url = iconUrl
        end
        --购买按钮
        data.type = 8--商店类型
        data.money_icon = data.money_type
        obj.data = {shopData = data,itemData = itemData}
        obj.onClick:Add(self.onClickBuy, self)
    end
end

function MarryStoreView:initData()
    self.shopData = conf.ShopConf:getWeddingShopData()
    self.listView.numItems = #self.shopData
end

function MarryStoreView:onClickBuy(context)
    local data = context.sender.data
    local vipLv = cache.PlayerCache:getVipLv()
    if data.shopData.vip then
        if data.shopData.vip <= vipLv then
            mgr.ViewMgr:openView(ViewName.ShopBuyView,function(view)
                view:setData(data,data.shopData.type)
                view:setBuyCount(-1)
            end)
        else
            GComAlter(language.store07) 
        end
    else
        mgr.ViewMgr:openView(ViewName.ShopBuyView,function(view)
            view:setData(data,data.shopData.type)
            view:setBuyCount(-1)
        end)
    end
end

return MarryStoreView