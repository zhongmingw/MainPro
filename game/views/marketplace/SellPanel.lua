local SellPanel = class("SellPanel", import("game.base.Ref"))

function SellPanel:ctor(parent)
    self.parent = parent
    self:initView()
end

function SellPanel:refreshPanel()
    -- body
    local param = {reqLabel = 4}
    proxy.MarketProxy:sendMarketMsg(1260104,param,true)
    if GCheckView(1188) then--宠物系统是否开启
        self.btnPutPet.visible = true
    else
        self.btnPutPet.visible = false
    end
end

function SellPanel:initView()
    -- body
    self.view = self.parent.view:GetChild("n24")
    self.listView = self.view:GetChild("n11")
    self.btnPutAway = self.view:GetChild("n13")
    self.btnPutAway.onClick:Add(self.onClickPutAway,self)
    self.btnPutPet = self.view:GetChild("n14")
    self.btnPutPet.onClick:Add(self.onClickPutPet,self)
    self:initListView()
    local timeHint = self.view:GetChild("n12")
    local timeData = GGetTimeData(conf.SysConf:getValue("mark_sell_time"))
    timeHint.text = string.format(language.sell18,timeData.hour)
    local param = {reqLabel = 4}
    proxy.MarketProxy:sendMarketMsg(1260104,param,true)
end

function SellPanel:setData(data)
    -- body
    self.data = data
    self.recordItems = data.recordItems
    local len = 0
    if self.recordItems then
        len = #self.recordItems
    end
    self.listView.numItems = len
end

function SellPanel:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listView:SetVirtual()
end

function SellPanel:itemData( index,obj )
    -- body
    local data = self.recordItems[index+1]
    local name = obj:GetChild("n2")
    local num = obj:GetChild("n3")
    local price = obj:GetChild("n4")
    local sumPrice = obj:GetChild("n5")
    local itemIcon = obj:GetChild("n1")
    local btnPutOut = obj:GetChild("n9")
    btnPutOut.data = data
    btnPutOut.onClick:Add(self.onClickPutOut,self)
    
    num.text = data.amount
    price.text = data.price
    sumPrice.text = data.price*data.amount

    local color
    local itemName
    if data.petInfo and data.petInfo.petId ~= 0 then--宠物
        local condata = conf.PetConf:getPetItem(data.petInfo.petId)
        --local itemObj = obj
        itemName = data.petInfo.name or condata.name
        color = condata.color
        local t = {isCase = true,color = condata.color,url = ResPath.iconRes(condata.src)}
        t.func = function()
            -- body
            -- mgr.ViewMgr:openView2(ViewName.PetMsgView, data.petInfo)
            mgr.PetMgr:seeMarketInfo(data)
        end
        GSetItemData(itemIcon,t,true)
    else--背包道具
        color = conf.ItemConf:getQuality(data.mid)
        itemName = conf.ItemConf:getName(data.mid)
        local info = {mid = data.mid,amount = data.amount,colorAttris = data.colorAttris,level = data.level or 0}
        info.isArrow = true
        GSetItemData(itemIcon,info,true)
    end
    name.text = mgr.TextMgr:getQualityStr1(itemName,color)
end

--上架
function SellPanel:onClickPutAway(  )
    local data = {}
    local packData = cache.PackCache:getPackData()
    for k,v in pairs(packData) do
        local trade = conf.ItemConf:getItemTrade(v.mid)
        local color = conf.ItemConf:getQuality(v.mid)
        local packData = cache.PackCache:getPackDataByIndex(v.index)
        packData.amount = packData.amount or 1
        if trade == 1 and v.bind == 0 and color < 7 then--粉装不能上架
            v.amount = packData.amount
            table.insert(data,v)
        end
    end
    --圣裝处理
    local shengzhuangpackData = cache.PackCache:getShengZhuangPackData()
    for k,v in pairs(shengzhuangpackData) do
        local trade = conf.ItemConf:getItemTrade(v.mid)
        local packData = cache.PackCache:getShengZhuangPackDataByIndex(v.index)
        packData.amount = packData.amount or 1
        if trade == 1 and v.bind == 0 then
            v.amount = packData.amount
            table.insert(data,v)
        end
    end
    -- printt("zhuangbei",data)
    local view = mgr.ViewMgr:get(ViewName.PutAwayPanel)
    if view then
        view:setPetListVisible(false)
        view:setData(data)
    else
        mgr.ViewMgr:openView(ViewName.PutAwayPanel,function(view)
            view:setPetListVisible(false)
            view:setData(data)
        end)
    end
end
--上架宠物
function SellPanel:onClickPutPet()
    proxy.PetProxy:sendMsg(1490101)
end

--下架
function SellPanel:onClickPutOut( context )
    -- body
    local cell = context.sender
    local info = cell.data

    local data = {}
    data.type = 2 
    data.richtext = language.sell19
    data.sure = function()
        -- body
        local param = {index = info.index}
        proxy.MarketProxy:sendMarketMsg(1260103,param,true,1)
    end

    data.cancel = function ()
        -- body
    end
    GComAlter(data)
end

return SellPanel