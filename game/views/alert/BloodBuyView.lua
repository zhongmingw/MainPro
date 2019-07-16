--
-- Author: Your Name
-- Date: 2017-07-19 21:01:33
--
local BloodBuyView = class("BloodBuyView", base.BaseView)

function BloodBuyView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
    self.isBlack = true
end

function BloodBuyView:initView()
    local closeBtn = self.view:GetChild("n5")
    closeBtn.onClick:Add(self.onCloseView,self)
end

function BloodBuyView:initData()
    local roleLv = cache.PlayerCache:getRoleLevel()
    local bloodTab = {
                        [1] = 221011005,--初级血包
                        [2] = 221011033,--中级血包
                        [3] = 221011034,--高级血包
                    }
    local selected = 1
    for i=1,3 do
        local lvl = conf.ItemConf:getLvl(bloodTab[i]) or 0
        selected = i
        if lvl > roleLv then
            selected = i - 1
            break
        end
    end
    local item = self.view:GetChild("n3")
    local mId = bloodTab[selected]
    local info = {mid=mId,amount=1}
    GSetItemData(item,info,false)
    local confData = conf.ShopConf:getPersonalShop()
    local price = 0
    local data = {}
    for k,v in pairs(confData) do
        if v.mid == mId then
            data = v
            break
        end
    end
    self.view:GetChild("n8").text = data.price
    local btnBuy = self.view:GetChild("n6")
    btnBuy.data = data
    btnBuy.onClick:Add(self.onBuyClick,self)
end

function BloodBuyView:onBuyClick( context )
    local data = context.sender.data
    proxy.ShopProxy:send(1090101,{type = 2, cfgId = data.id, amount = 1})
    -- self:onCloseView()
end

function BloodBuyView:onCloseView()
    self:closeView()
end

return BloodBuyView