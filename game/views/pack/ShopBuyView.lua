local ShopBuyView = class("ShopBuyView", base.BaseView)
--购买弹窗

function ShopBuyView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2           --窗口层级
    self.isBlack = true
    self.countNum = 1
    self.priceNum = 0
    self.openTween = ViewOpenTween.scale
end
--主界面
function ShopBuyView:initView()
    self.itemObj = self.view:GetChild("n4")
    self.nameText = self.view:GetChild("n5")--名字
    self.leftCount = self.view:GetChild("n6")--剩余购买次数
    self.leftCount.text = ""
    self.descText = self.view:GetChild("n7")--说明
    self.countText = self.view:GetChild("n17")--购买数量
    self.countText.text = self.countNum
    self.priceText = self.view:GetChild("n22")--对应价格
    self.priceText.text = self.priceNum
    self.icon = self.view:GetChild("n27")
    local addBtn = self.view:GetChild("n26")
    addBtn.data = 1
    addBtn.onClick:Add(self.onClickUpdateCount, self)
    local lessBtn = self.view:GetChild("n16")
    lessBtn.data = 2
    lessBtn.onClick:Add(self.onClickUpdateCount, self)
    local buyBtn = self.view:GetChild("n8")
    buyBtn.onClick:Add(self.onClickBuy, self)
    --最大购买
    local btnmax = self.view:GetChild("n33")
    btnmax.data = 3
    btnmax.onClick:Add(self.onClickUpdateCount,self)

	local closeBtn = self.view:GetChild("n25"):GetChild("n7")
    closeBtn.onClick:Add(self.onCloseView,self)
end

function ShopBuyView:initData()
    --交易密码
    self.passWord = nil

    self.timer = self:addTimer(0.1, -1, handler(self, self.timerClick))
end

function ShopBuyView:timerClick()
    -- body
    local num = checkint(self.countText.text) 
    --if not num or num == "" then num = 1 end
    if tonumber(num) ~= self.countNum then
        if tonumber(num)>0 then
            self.countNum = tonumber(num) > 9999 and 9999 or tonumber(num)
        end
        local price = self.shopData.price
        local buyType 
        if self.type == 1 or self.type == 111 then
            buyType =  MoneyType.gold
        elseif self.type == 2 then
            buyType =  MoneyType.bindGold
        elseif self.type == 3 then
            buyType =  MoneyType.ry
        elseif self.type == 4 then
            buyType =  MoneyType.pt
        elseif self.type == 6 then
            buyType =  MoneyType.sw
        elseif self.type == 7 then
            buyType =  MoneyType.wm
        elseif self.type == 9 then  --EVE 家园
            if self.shopData.money_type == 14 then 
                buyType =  12
            else
                buyType =  self.shopData.money_type
            end 
        else
            buyType = self.shopData.money_icon
            --self.icon.url = UIItemRes.moneyIcons[self.shopData.money_icon]
        end
        local money = cache.PlayerCache:getTypeMoney(buyType)
        local max = math.floor(money/price)
        local number = math.min(max,self.shopData.count)
        number = math.max(number,1) --至少保证一个
        
        if self.countNum == number then
            self.countNum = number
        end
        self:setBuyPrice()
    end
end

--Type有值时 为商城调入 
--Type=1 元宝商城 Type=2 绑元商城 Type=3 荣誉商城 Type=4 爬塔商城 Type=111 寄售行购买
--Type=8 婚礼商城 Type=9 家园商城 Type=10 vip限购
function ShopBuyView:setData(data,Type)
    self.type = Type
    self.shopData = data.shopData
    --printt(data)
    local petData = data.petData
    if petData and petData.petInfo and petData.petInfo.petId ~= 0 then--宠物
        local condata = conf.PetConf:getPetItem(petData.petInfo.petId)
        --local itemObj = obj
        self.nameText.text = petData.petInfo.name or condata.name
        self.descText.text = condata.describe
        color = condata.color
        local t = {isCase = true,color = condata.color,url = ResPath.iconRes(condata.src)}
        t.func = function()
            -- body
            -- mgr.ViewMgr:openView2(ViewName.PetMsgView, petData.petInfo)
            mgr.PetMgr:seeMarketInfo(petData)
        end
        GSetItemData(self.itemObj,t,true)
    else
        GSetItemData(self.itemObj, data.itemData, true)
        self.nameText.text = conf.ItemConf:getName(self.shopData.mid)
        self.descText.text = conf.ItemConf:getDescribe(self.shopData.mid)
    end
    if self.type == 1 or self.type == 10 or self.type == 111 then
        local iconUrl = ResPath.iconRes("gonggongsucai_103")-- UIPackage.GetItemURL("_icons" , "gonggongsucai_103")
        self.icon.url = iconUrl
    elseif self.type == 2 then
        local iconUrl =ResPath.iconRes("gonggongsucai_108")-- UIPackage.GetItemURL("_icons" , "gonggongsucai_108")
        self.icon.url = iconUrl
    elseif self.type == 3 then
        local iconUrl = UIItemRes.moneyIcons[MoneyType.ry]
        self.icon.url = iconUrl
    elseif self.type == 4 then
        local iconUrl = UIItemRes.moneyIcons[MoneyType.pt]
        self.icon.url = iconUrl
    elseif self.type == 5 then
        local iconUrl = UIItemRes.moneyIcons[MoneyType.gongxun]
        self.icon.url = iconUrl
    elseif self.type == 6 then
        local iconUrl = UIItemRes.moneyIcons[MoneyType.sw]
        self.icon.url = iconUrl
    elseif self.type == 7 then
        local iconUrl = UIItemRes.moneyIcons[MoneyType.wm]
        self.icon.url = iconUrl
    elseif self.type == 9 then  --EVE 家园商店货币logo
        local iconUrl 
        if self.shopData.money_type == 14 then 
            iconUrl = UIItemRes.moneyIcons[12]
        elseif self.shopData.money_type == 4 then   --消耗：元宝+绑元
            iconUrl = UIItemRes.moneyIcons[2]
        else
            iconUrl = UIItemRes.moneyIcons[self.shopData.money_type]
        end 
        self.icon.url = iconUrl
    else
        self.icon.url = UIItemRes.moneyIcons[self.shopData.money_icon]
    end
end

function ShopBuyView:setBuyPrice()
    self.countText.text = self.countNum
    self.priceText.text = self.countNum * self.shopData.price
end

function ShopBuyView:setBuyCount(leftCount)
    self.countNum = 1
    self.shopData.count = leftCount
    if leftCount < 0 then
        self.leftCount.text = ""
        self.shopData.count = 99999
    else
        self.leftCount.text = string.format(language.store01, leftCount)
    end
    self:setBuyPrice()
end
--改变购买数量
function ShopBuyView:onClickUpdateCount(context)
    local tag = context.sender.data
    if tag == 1 then--累加
        if self.shopData.count>self.countNum then
            self.countNum = self.countNum + 1
            if self.type == 111 then
                local needYb = self.countNum * self.shopData.price
                local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
                if needYb > moneyYb then
                    self.countNum = self.countNum - 1
                    GComAlter(language.sell23)
                end
            end
        else
            GComAlter(language.gonggong24)
        end
    elseif tag == 2 then
        self.countNum = self.countNum - 1
        if self.countNum <= 1 then
            if self.countNum < 1 then
                GComAlter(language.gonggong14)
            end
            self.countNum = 1
        end
    elseif tag == 3 then --最大数量
        local price = self.shopData.price
        local buyType 
        if self.type == 1 or self.type == 10 or  self.type == 111 then
            buyType =  MoneyType.gold
        elseif self.type == 2 then
            buyType =  MoneyType.bindGold
        elseif self.type == 3 then
            buyType =  MoneyType.ry
        elseif self.type == 4 then
            buyType =  MoneyType.pt
        elseif self.type == 5 then
            buyType =  MoneyType.gongxun
        elseif self.type == 6 then
            buyType =  MoneyType.sw
        elseif self.type == 7 then
            buyType =  MoneyType.wm
        elseif self.type == 9 then  --EVE 家园币
            if self.shopData.money_type == 14 then 
                buyType =  12
            elseif self.shopData.money_type == 4 then 

                buyType =  2
            else
                buyType =  self.shopData.money_type
            end 
        else
            buyType = self.shopData.money_icon
            --self.icon.url = UIItemRes.moneyIcons[self.shopData.money_icon]
        end
        local money = cache.PlayerCache:getTypeMoney(buyType)

        if self.type == 9 and self.shopData.money_type == 4 then  --EVE 自动最大购买数量时，元宝+绑元
            money = money + cache.PlayerCache:getTypeMoney(1)
        end 

        local max = math.floor(money/price)
        local number = math.min(max,self.shopData.count)
        number = math.max(number,1) --至少保证一个
        if self.countNum == number then
            GComAlter(language.arena16)
        else
            self.countNum = number
        end
    end
    self.priceNum = self.countNum * self.shopData.price

    self.countText.text = self.countNum
    self.priceText.text = self.priceNum
end

function ShopBuyView:onClickBuy()
    if tonumber(self.countNum) <= self.shopData.count then
        local Type = self.type
        if self.type == 8 then
            Type = self.shopData.money_icon
        end
        if Type then
            if Type == 1 or Type == 2 or Type == 3 
                or Type == 4 or Type == 5 or Type == 6 or Type == 7 or Type == 9 or Type == 10 then --EVE 添加类型 Type=9 家园 bxp Type = 10 VIp限购
                if Type == 1 or Type == 10 then
                    local needYb = self.countNum * self.shopData.price
                    local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
                    if needYb > moneyYb then
                        GComAlter(language.gonggong18)
                        self:closeView()
                        return 0
                    end
                elseif Type == 2 then
                    local needYb = self.countNum * self.shopData.price
                    local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
                    if needYb > moneyYb then
                        GComAlter(language.gonggong22)
                        self:closeView()
                        return 0
                    end
                elseif Type == 3 then
                    local needYb = self.countNum * self.shopData.price
                    local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.ry)
                    if needYb > moneyYb then
                        GComAlter(language.gonggong44)
                        self:closeView()
                        return 0
                    end
                elseif Type == 4 then
                    local needYb = self.countNum * self.shopData.price
                    local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.pt)
                    if needYb > moneyYb then
                        GComAlter(language.gonggong45)
                        self:closeView()
                        return 0
                    end
                elseif Type == 5 then
                    local needYb = self.countNum * self.shopData.price
                    local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.gongxun)
                    if needYb > moneyYb then
                        GComAlter(language.gonggong46)
                        self:closeView()
                        return 0
                    end
                elseif Type == 6 then
                    local needYb = self.countNum * self.shopData.price
                    local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.sw)
                    if needYb > moneyYb then
                        GComAlter(language.gonggong90)
                        self:closeView()
                        return 0
                    end
                elseif Type == 7 then
                    local needYb = self.countNum * self.shopData.price
                    local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.wm)
                    if needYb > moneyYb then
                        GComAlter(language.gonggong91)
                        self:closeView()
                        return 0
                    end
                elseif Type == 9 then  --EVE 家园
                    local needYb = self.countNum * self.shopData.price

                    local moneyYb
                    if self.shopData.money_type == 14 then 
                        moneyYb = cache.PlayerCache:getTypeMoney(12)
                    elseif self.shopData.money_type == 4 then 
                        local yb = cache.PlayerCache:getTypeMoney(1)
                        local by = cache.PlayerCache:getTypeMoney(2)
                        moneyYb = yb + by
                    else
                        moneyYb = cache.PlayerCache:getTypeMoney(self.shopData.money_type)  
                    end 
        
                    if needYb > moneyYb and self.shopData.money_type ~= 4 then
                        GComAlter(language.store15[self.shopData.money_type])
                        self:closeView()
                        return 0
                    elseif needYb > moneyYb and self.shopData.money_type == 4 then 
                        GComAlter(language.store15[2])
                        self:closeView()
                        return 0
                    end
                end
                if self.shopData.callback then
                    self.shopData.callback(tonumber(self.countNum))
                else
                    -- print("购买消息已发送",self.type)
                    proxy.ShopProxy:sendByItemsByStore( self.type,self.shopData.id,tonumber(self.countNum) )
                end
            elseif Type == 111 then
                local needYb = self.countNum * self.shopData.price
                local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
                if needYb > moneyYb then
                    GComAlter(language.gonggong18)
                    self:onCloseView()
                    return 0
                end
                if self.shopData.callback then
                    self.shopData.callback(tonumber(self.countNum))
                else
                    if self.shopData.passSet == 1 and not self.shopData.passWord then
                        local param = {index = self.shopData.index,amount = tonumber(self.countNum),srvId = self.shopData.srvId,passWord = self.shopData.passWord}
                        -- local callfunc = function()
                        --     proxy.MarketProxy:sendMarketMsg(1260106,param)
                        -- end
                        mgr.ViewMgr:openView2(ViewName.PasswordView,{Type = 2,param = param})
                    else
                        local param = {index = self.shopData.index,amount = tonumber(self.countNum),srvId = self.shopData.srvId,passWord = self.shopData.passWord}
                        proxy.MarketProxy:sendMarketMsg(1260106,param)
                    end
                end
                
            end
        else
            if self.shopData.callback then
                self.shopData.callback(tonumber(self.countNum))
            else
                proxy.ShopProxy:send(1090101,{type = 2, cfgId = self.shopData.id, amount = tonumber(self.countNum)})
            end
        end
    else
        GComAlter(language.store08)
    end
    self:closeView()
end

function ShopBuyView:onCloseView()
    -- body
    local view = mgr.ViewMgr:get(ViewName.MarketMainView)
    if view then
        view.MarketPanel:setPassword(nil)
    end
    self:closeView()
end

return ShopBuyView