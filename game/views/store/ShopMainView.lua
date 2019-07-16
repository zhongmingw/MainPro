local ShopMainView = class("ShopMainView", base.BaseView)

--EVE 商店模块对应language.store14里的key值
local module_id = {  
    [1159] = 9
}

function ShopMainView:ctor()
    self.super.ctor(self)
    self.type = 1
    -- proxy.ShopProxy:sendStore(self.type)
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function ShopMainView:initData(data)
    -- body
    local window2 = self.view:GetChild("n0")
    GSetMoneyPanel(window2,self:viewName())
    self.windowC1 = window2:GetController("c1")
    local closeBtn = window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.data = {} --各个商店商品信息
    self.leftTimesData = {}
    self.openShop = clone(language.store14)  --商店名列表

    self.needIndex = data.index or 0  
    self.falg = 1 

    self:checkOpenShop()  --检测商店开启

    
    --EVE 新
    self:GoToPage(data.index) 
    self:onController()
    
    --EVE END
end

function ShopMainView:initView()
    self.storePanel = self.view:GetChild("n11")

    self.listView = self.storePanel:GetChild("n2")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()

    if g_is_banshu then
        self.view:GetChild("n7"):SetScale(0,0)
        self.view:GetChild("n8"):SetScale(0,0)
        self.view:GetChild("n12"):SetScale(0,0)
        self.view:GetChild("n13"):SetScale(0,0)
        self.storePanel:GetChild("n7"):SetScale(0,0)
    end
    --self:setTabList() 
    self.tabList = self.view:GetChild("n16") --EVE 页签改成列表模式 
    self.tabList.itemRenderer = function (index,obj)
        self:cellDataTab(index, obj)
    end
    self.tabList:SetVirtual()
    self.tabList.numItems = 0
    self.tabList.onClickItem:Add(self.onTabListItem,self) 

    self.title = self.view:GetChild("n17") --库存标题
    self.title.text = language.store17
    self.title.visible = false
end

--EVE 检测开启的商店
function ShopMainView:checkOpenShop()
    for k,v in pairs(module_id) do
        if mgr.ModuleMgr:CheckSeeView(k) then
            if not self.openShop[v] then 
                table.insert(self.openShop, v, language.store14[v])
            end 
        else
            self.openShop[v] = nil
        end
    end
    if g_ios_test then  --EVE 版属屏蔽只保留元宝和绑元(新的屏蔽方式)
        table.remove(self.openShop,1)
        self.tabList.numItems = 2
    else
        self.tabList.numItems = #self.openShop
    end
end

function ShopMainView:cellDataTab(index, obj) --EVE
    -- body
    local data = self.openShop[index+1]

    obj.title = data

    local tempData = {index = index}
    if g_ios_test then
        tempData = {index = index + 1}
    end
    obj.data = tempData

    if self.needIndex ~= 0 then  --从各种入口跳转到主商店时
        if index == self.needIndex then
            obj.selected = true
        else
            obj.selected = false
        end
    else     --从主入口打开商店
        if index == 0 and self.falg == 1 then 
            obj.selected = true
            self.falg = 2
        else   
            obj.selected = false
        end
    end
end

function ShopMainView:onTabListItem(context) --EVE
    -- body
    local cell = context.data
    local data = cell.data

    self.index = data.index
    self:onController()
end

function ShopMainView:getStoreType()
    -- body
    return self.type
end

function ShopMainView:setData( data )
    -- printt("data.b",data.buyLeftTimes)
    -- self:addTimer(2, 1, function 
    --     ()
    --     GComAlter("消息返回")
    -- end)
    self.leftTimesData = data.buyLeftTimes
    if g_ios_test then
        local data = {}
        for k,v in pairs(self.data) do
            local leftNums = self.leftTimesData[v.id] or 0
            if leftNums < 0 then
                table.insert(data, v)
            end
        end
        self.data = data
    end
    self.listView.numItems = #self.data
end

function ShopMainView:onController()
    if 1 == self.index then --元宝商城 --0
        self.type = 1
        self.windowC1.selectedIndex = 0
        self.data = conf.ShopConf:getYbShopData()
        self.title.visible = false
    elseif 2 == self.index then --绑元商城--1
        self.type = 2
        self.windowC1.selectedIndex = 0
        self.data = conf.ShopConf:getBindYbShopData()
        self.title.visible = false
    elseif 3 == self.index then --荣誉商城--2
        self.data = conf.ShopConf:getHonorShopData()
        self.type = 3
        self.windowC1.selectedIndex = 1
        self.title.visible = false
    elseif 4 == self.index then --爬塔商城--3
        self.data = conf.ShopConf:getPataShopData()
        self.type = 4
        self.windowC1.selectedIndex = 3
        self.title.visible = false
    elseif 5 == self.index then --功勋商城--4
        self.data = conf.ShopConf:getGongXunShopData()
        self.type = 5
        self.windowC1.selectedIndex = 2
        self.title.visible = false
    elseif 6 == self.index then --声望商城--5
        self.type = 6
        self.data = conf.ShopConf:getSwShopData()
        self.windowC1.selectedIndex = 4
        self.title.visible = false
    elseif 7 == self.index then --威名商城--6
        self.type = 7
        self.data = conf.ShopConf:getWmShopData()
        self.windowC1.selectedIndex = 5
        self.title.visible = false
    elseif 8 == self.index then --EVE 家园商店
        self.type = 9
        self.data = conf.ShopConf:getJiaYuanShopData()
        self.windowC1.selectedIndex = 6
        -- print("哈利路亚~~~~~~~~~~~~")
        self.title.visible = false
    elseif 0 == self.index then --bxpVIP限购--7
        self.type = 10
        self.data = conf.ShopConf:getWeekLimitShopData()
        self.windowC1.selectedIndex = 0
        self.title.visible = true
        --GComAlter("#######self.type = 10")
    end
    --GComAlter("发送的self.type"..self.type)
    proxy.ShopProxy:sendStore(self.type)
    -- self.listView.numItems = #self.data
    -- self.listView:RefreshVirtualList()
end

--跳转用
function ShopMainView:GoToPage(page)
    -- body
    self.index = page or 0
    if g_ios_test then self.index = 1 end
end

function ShopMainView:initShopList()
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function ShopMainView:celldata( index,cellObj )
    local itemInfo = self.data[index+1]
    local itemObj = cellObj:GetChild("n19")
    local mid = itemInfo.mid
    local leftTimes = cellObj:GetChild("n6")
    local leftNums = self.leftTimesData[itemInfo.id] or 0
    local itemData = {mid = mid,amount = itemInfo.amount,bind = itemInfo.bind or 0}
    GSetItemData(itemObj,itemData,true)--设置道具信息
    local btnBuy = cellObj:GetChild("n17")--购买按钮
    btnBuy.data = {shopData = itemInfo,itemData = itemData}
    btnBuy.onClick:Add(self.onClickBuy, self)
    if leftNums < 0 then
        leftTimes.text = ""
        cellObj:GetChild("n1").visible = false
        cellObj:GetChild("n20").visible = false
        btnBuy.visible = true  
    else
        cellObj:GetChild("n1").visible = true
        leftTimes.text = string.format(language.store02,leftNums)
        if leftNums == 0 then
            cellObj:GetChild("n20").visible = true
            btnBuy.visible = false
        else
            cellObj:GetChild("n20").visible = false
            btnBuy.visible = true            
        end
    end
    local textName = cellObj:GetChild("n4")--名字
    local name = conf.ItemConf:getName(mid)
    textName.text = name

    local slash = cellObj:GetChild("n15") --斜线
    local costPrice = cellObj:GetChild("n12")--原价
    costPrice.text = itemInfo.old_price
    local textPrice = cellObj:GetChild("n13")--当前价格
    textPrice.text = itemInfo.price
    if itemInfo.old_price then
        slash.visible = true
        textPrice.position = {y=96,x=177,z=0}
    else
        slash.visible = false
        textPrice.position = costPrice.position
    end
    local iconImg = cellObj:GetChild("n11")
    if self.type == 1 then --元宝
        local iconUrl = ResPath.iconRes("gonggongsucai_103")  --UIPackage.GetItemURL("_icons" , "gonggongsucai_103")
        iconImg.url = iconUrl
    elseif self.type == 2 then --绑元
        local iconUrl = ResPath.iconRes("gonggongsucai_108")  --UIPackage.GetItemURL("_icons" , "gonggongsucai_108")
        iconImg.url = iconUrl
    elseif self.type == 3 then --荣誉
        local iconUrl =ResPath.iconRes("gonggongsucai_120")--  UIPackage.GetItemURL("_icons" , "gonggongsucai_120")
        iconImg.url = iconUrl
    elseif self.type == 4 then --爬塔
        local iconUrl =ResPath.iconRes("gonggongsucai_121")  --UIPackage.GetItemURL("_icons" , "gonggongsucai_121")
        iconImg.url = iconUrl
    elseif self.type == 5 then --功勋
        local iconUrl = ResPath.iconRes("gonggongsucai_122") --- UIPackage.GetItemURL("_icons" , "gonggongsucai_122")
        iconImg.url = iconUrl
    elseif self.type == 6 then --声望
        local iconUrl = UIItemRes.moneyIcons[MoneyType.sw] --- UIPackage.GetItemURL("_icons" , "gonggongsucai_122")
        iconImg.url = iconUrl
    elseif self.type == 7 then --威名
        local iconUrl = UIItemRes.moneyIcons[MoneyType.wm] --- UIPackage.GetItemURL("_icons" , "gonggongsucai_122")
        iconImg.url = iconUrl
    elseif self.type == 9 then --EVE 家园
        local iconUrl 
        if itemInfo.money_type == 14 then
            iconUrl = UIItemRes.moneyIcons[12] 
        elseif itemInfo.money_type == 4 then     --消耗：元宝+绑元
            iconUrl = UIItemRes.moneyIcons[2] 
        else
            iconUrl = UIItemRes.moneyIcons[itemInfo.money_type] 
        end 
        iconImg.url = iconUrl   
    elseif self.type == 10 then --VIP限购 元宝
        local iconUrl = ResPath.iconRes("gonggongsucai_103")
        iconImg.url = iconUrl
    end
    local discount = cellObj:GetChild("n5") --折扣
    local disImg = cellObj:GetChild("n2")  --折扣图标
    if itemInfo.discount then
        discount.visible = true
        disImg.visible = true
        discount.text = itemInfo.discount
    else
        discount.visible = false
        disImg.visible = false
    end
    if itemInfo.isPrivilege == 1 then--仙尊卡购买跳转
        local skipId = language.store16[itemInfo.id]
        if skipId then
            leftTimes.text = ""
            -- print("仙尊卡",cache.PlayerCache:VipIsActivate(skipId),skipId)
            if cache.PlayerCache:VipIsActivate(skipId) then
                cellObj:GetChild("n20").visible = true
                btnBuy.visible = false
            else
                cellObj:GetChild("n20").visible = false
                btnBuy.visible = true
            end
        end
        if not GXianzunDiscount() and itemInfo.isPrivilege == 1 then
            -- print("仙尊卡不打折",itemInfo.id)
            discount.visible = false
            disImg.visible = false
            slash.visible = false
            costPrice.text = ""
            textPrice.text = itemInfo.old_price
            textPrice.position = costPrice.position
        end
    end
    
    local vipTxt = cellObj:GetChild("n7")
    if itemInfo.vip then
        local vipLv = cache.PlayerCache:getVipLv()
        if itemInfo.vip > vipLv then
            vipTxt.text = string.format(language.store06,itemInfo.vip)
            vipTxt.visible = true
            cellObj:GetChild("n3").visible = true
        else
            vipTxt.visible = false
            cellObj:GetChild("n3").visible = false
        end
    else
        vipTxt.visible = false
        cellObj:GetChild("n3").visible = false
    end
end

--刷新剩余数量
function ShopMainView:refreshLeftNums( index,num )
    self.leftTimesData[index] = self.leftTimesData[index]-num >= 0 and 
                                self.leftTimesData[index]-num or -1
    self.listView.numItems = #self.data
    self.listView:RefreshVirtualList()
end

function ShopMainView:onClickBuy( context )
    local data = context.sender.data
    local vipLv = cache.PlayerCache:getVipLv()

    -- print("当前物品的ID为：",data.shopData.mId,data.shopData.isPrivilege)
    if data.shopData.isPrivilege and data.shopData.isPrivilege == 1 then
        GOpenView({id = 1050})
    elseif data.shopData.vip then
        if data.shopData.vip <= vipLv then
            mgr.ViewMgr:openView(ViewName.ShopBuyView,function(view)
                view:setData(data,self.type)
                view:setBuyCount(self.leftTimesData[data.shopData.id])
            end)
        else
            if g_ios_test then     --EVE 屏蔽处理，提示修改
                GComAlter(language.gonggong76)
            else
                GComAlter(language.store07)
            end 
        end
    else
        mgr.ViewMgr:openView(ViewName.ShopBuyView,function(view)
            view:setData(data,self.type)
            view:setBuyCount(self.leftTimesData[data.shopData.id])
        end)
    end
end

function ShopMainView:onClickClose()
    -- body
    self.needIndex = 0 --EVE

    self:closeView()

    mgr.ModuleMgr:backView()
end

return ShopMainView