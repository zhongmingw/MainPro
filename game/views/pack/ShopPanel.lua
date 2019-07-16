--商店区域
local ShopPanel = class("ShopPanel",import("game.base.Ref"))

function ShopPanel:ctor(mParent)
	self.mParent = mParent
	self:initPanel()
end

function ShopPanel:initPanel()
	local panelObj = self.mParent.view:GetChild("panel_shop")
	self.listView = panelObj:GetChild("n14")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.personalShop = {}
    local data = conf.ShopConf:getPersonalShop()
    local curLvl = cache.PlayerCache:getRoleLevel()
    for k,v in pairs(data) do
        local lvl = v.lvl or 1
        if curLvl >= lvl then
            table.insert(self.personalShop, v)
        end
    end
end

function ShopPanel:setData()
    self.listView.numItems = #self.personalShop
end

function ShopPanel:cellData(index, cellObj)
    local shopData = self.personalShop[index + 1]
    local itemObj = cellObj:GetChild("n21")
    local mid = shopData.mid
    local itemData = {mid = mid,amount = shopData.amount,bind = shopData.bind}
    GSetItemData(itemObj,itemData,true)--设置道具信息
    local textName = cellObj:GetChild("n17")--名字
    local name = conf.ItemConf:getName(mid)
    textName.text = name
    local textPrice = cellObj:GetChild("n19")--价格
    textPrice.text = shopData.price
    local icon = cellObj:GetChild("n23")
    icon.url = UIItemRes.moneyIcons[shopData.money_icon]
    local btnBuy = cellObj:GetChild("n20")--购买按钮
    btnBuy.data = {shopData = shopData,itemData = itemData}
    btnBuy.onClick:Add(self.onClickBuy, self)
end
--购买
function ShopPanel:onClickBuy(context)
    local data = context.sender.data
    proxy.ShopProxy:send(1090101,{type = 1, cfgId = data.shopData.id, amount = 0})
	mgr.ViewMgr:openView(ViewName.ShopBuyView,function(view)
        view:setData(data)
        view:setBuyPrice()
    end)
end

return ShopPanel