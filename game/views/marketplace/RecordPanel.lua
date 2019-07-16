local RecordPanel = class("RecordPanel", import("game.base.Ref"))

function RecordPanel:ctor(parent)
    self.parent = parent
    self.index = 1
    self.firstIn = true
    self:initView()
    -- local param = {reqLabel = self.index}
    -- proxy.MarketProxy:sendMarketMsg(1260104,param,false)
end

function RecordPanel:refreshPanel()
    -- body
    local obj = self.titleList:GetChildAt(self.index-1)
    obj.selected = true
    local param = {reqLabel = self.index}
    proxy.MarketProxy:sendMarketMsg(1260104,param,false)
end

function RecordPanel:initView()
    -- body
    self.view = self.parent.view:GetChild("n25")
    self.titleList = self.view:GetChild("n10")
    self.listView = self.view:GetChild("n6")
    self:initTitleList()
    self:initListView()
end

function RecordPanel:initTitleList()
    -- body
    self.titleList.numItems = 0
    for i=0,2 do
        local url = UIPackage.GetItemURL("marketplace" , "PullList1")
        local obj = self.titleList:AddItemFromPool(url)
        self:celldata(i, obj)
    end
    if self.firstIn then
        self.firstIn = false
        local obj = self.titleList:GetChildAt(0)
        obj.selected = true
    end
end

function RecordPanel:setData(data)
    -- body
    self.data = data
    self.recordItems = data.recordItems
    local len = 0
    if self.recordItems then
        len = #self.recordItems
    end
    self.listView.numItems = len
    local decTxt = self.view:GetChild("n8")
    decTxt.visible = true
    if self.index == 1 then
        decTxt.text = language.sell07
    elseif self.index == 2 then
        decTxt.visible = false
    elseif self.index == 3 then
        decTxt.text = language.sell08
    end
end

function RecordPanel:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listView:SetVirtual()
end

function RecordPanel:itemData( index,obj )
    -- body
    local data = self.recordItems[index+1]
    local name = obj:GetChild("n2")
    local price = obj:GetChild("n4")
    local itemIcon = obj:GetChild("n1")
    local timeTxt = obj:GetChild("n5")
    
    price.text = data.price
    local btnGet = obj:GetChild("n6")
    btnGet.data = data
    btnGet.onClick:Add(self.onClickGet,self)
    btnGet.visible = true
    if self.index == 1 then
        btnGet.visible = false
    end
    if self.index == 3 then
        if data.canGot == 1 then
            btnGet.visible = true
        else
            btnGet.visible = false
        end
    end
    timeTxt.text = os.date("%Y-%m-%d",data.dealTme)
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

function RecordPanel:onClickGet( context )
    -- body
    local cell = context.sender
    local data = cell.data

    if self.index == 2 then
        local param = {index = data.index}
        proxy.MarketProxy:sendMarketMsg(1260103,param,false,2)
    elseif self.index == 3 then
        local param = {index = data.index,tradeId = data.tradeId}
        proxy.MarketProxy:sendMarketMsg(1260105,param)
    end
end

function RecordPanel:celldata( index,obj )
    -- body
    local titleTxt = obj:GetChild("title")
    if index == 0 then
        titleTxt.text = language.sell04
    elseif index == 1 then
        local redImg = obj:GetChild("n4")
        local param = {panel = redImg,ids = {10225}}
        mgr.GuiMgr:registerRedPonintPanel(param,"marketplace.MarketMainView.1")
        titleTxt.text = language.sell05
    elseif index == 2 then
        local redImg = obj:GetChild("n4")
        local param = {panel = redImg,ids = {10226}}
        mgr.GuiMgr:registerRedPonintPanel(param,"marketplace.MarketMainView.2")
        titleTxt.text = language.sell06
    end
    obj.data = index
    obj.onClick:Add(self.onClickShow,self)
end

function RecordPanel:onClickShow(context)
    -- body
    local cell = context.sender
    local idx = cell.data
    self.index = idx+1
    local param = {reqLabel = self.index}
    proxy.MarketProxy:sendMarketMsg(1260104,param,false)
end

return RecordPanel