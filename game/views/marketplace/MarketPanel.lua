local MarketPanel = class("MarketPanel", import("game.base.Ref"))

function MarketPanel:ctor(parent)
    self.parent = parent
    self.type = 100 --当前请求类型
    self.page = 1 --当前页数
    self.totalSum=1 --总页数
    self.sortType = 5 --当前排序类型
    self.sortMode = 1 --当前排序方式
    self.jie = 0 --筛选阶
    self.color = 0 --筛选品质
    --排序情况 1为升序 2为降序
    self.sortNum = 1
    self.sortPrice = 1
    self.sortSumPrice = 1
    -- local param = {reqLabel = self.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page,jie = self.jie,color = self.color}
    -- proxy.MarketProxy:sendMarketMsg(1260101,param)
end

function MarketPanel:refreshPanel()
    -- body
    self.passWord = nil
    self:initView()
    local param = {reqLabel = self.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page,jie = self.jie,color = self.color}
    proxy.MarketProxy:sendMarketMsg(1260101,param)
end

function MarketPanel:initView()
    -- body
    self.view = self.parent.view:GetChild("n23")
    self.titleList = self.view:GetChild("n16")
    self.listView = self.view:GetChild("n11")
    --切换页码的4个按钮
    local btnCutLeft1 =self.view:GetChild("n23")
    btnCutLeft1.onClick:Add(self.onClickCutLeft1,self)
    local btnCutRight1 =self.view:GetChild("n24")
    btnCutRight1.onClick:Add(self.onClickCutRight1,self)
    local btnCutLeft2 =self.view:GetChild("n26")
    btnCutLeft2.onClick:Add(self.onClickCutLeft2,self)
    local btnCutRight2 =self.view:GetChild("n25")
    btnCutRight2.onClick:Add(self.onClickCutRight2,self)
    local data = conf.MarketConf:getMarketTitleData()
    --排序按钮
    local btnNum = self.view:GetChild("n7")
    btnNum.onClick:Add(self.onClickSortByNum,self)
    local btnPrice = self.view:GetChild("n8")
    btnPrice.onClick:Add(self.onClickSortByPrice,self)
    local btnSumPrice = self.view:GetChild("n9")
    btnSumPrice.onClick:Add(self.onClickSortBySumPrice,self)
    --筛选按钮
    local levelBtn = self.view:GetChild("n36")--等阶筛选按钮
    levelBtn.onClick:Add(self.onClickLevCal,self)
    local colorBtn = self.view:GetChild("n37")--等阶筛选按钮
    colorBtn.onClick:Add(self.onClickColorCal,self)
    --筛选组件
    self.Panel = self.view:GetChild("n35")--等阶筛选
    self.Panel.visible = false
    self.listPanel = self.view:GetChild("n34")
    self.listPanel:SetVirtual()
    self.listPanel.itemRenderer = function(index,obj)
        self:cellPanelData(index, obj)
    end
    self.listPanel.numItems = 0
    self.listPanel.onClickItem:Add(self.onlistPanel,self)
    --刷新按钮
    local btnRefresh = self.view:GetChild("n10")
    btnRefresh.onClick:Add(self.onClickRefresh,self)
    self.titleData = {}
    self.smallData = {}
    for k,v in pairs(data) do
        if v.type > 9999 then
            local typeNum = math.floor(v.type/100)
            if typeNum == 104 or typeNum == 105 or typeNum == 106 then--宠物系统判断开启
                if GCheckView(1188) then
                    table.insert(self.smallData,v)
                end
            else
                table.insert(self.smallData,v)
            end
        else
            v.open = 0
            if v.type == 104 or v.type == 105 or v.type == 106 then--宠物系统判断开启
                if GCheckView(1188) then
                    table.insert(self.titleData,v)
                end
            else
                table.insert(self.titleData,v)
            end
        end
    end
    table.sort(self.titleData,function(a,b)
        if a.type ~= b.type then
            return a.type < b.type
        end
    end)
    table.sort(self.smallData,function(a,b)
        if a.type ~= b.type then
            return a.type < b.type
        end
    end)
    --搜索
    self.seetText = self.view:GetChild("n31")
    self.BtnSeet = self.view:GetChild("n28")
    self.BtnSeet.onClick:Add(self.onClickSeet,self)
    self.isSeet = false
    --交易密码
    self.passWord = nil
    self:initTitleList()
    self:initListView()
end

--设置购买
function MarketPanel:setPassword(passWord)
    self.passWord = passWord
end

--等阶筛选
function MarketPanel:onClickLevCal(context)
    local btn = context.sender 
    if self.call and self.call == 1 and self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.call = 1
    self:callset(btn)
end
--品质筛选
function MarketPanel:onClickColorCal(context)
    local btn = context.sender 
    if self.call and self.call == 2 and self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.call = 2
    self:callset(btn)
end

function MarketPanel:callset(btn)
    self.Panel.x = btn.x + (btn.width - self.Panel.width)/2
    self.Panel.y = btn.y + btn.height + 2
    self.Panel.visible = true

    self.listPanel.numItems = #language.sell24[self.call]
    if self.call == 1 then
        self.listPanel:AddSelection(self.jie,false)
    else
        if self.color == 0 then
            self.listPanel:AddSelection(self.color,false)
        else
            self.listPanel:AddSelection(self.color-3,false)
        end
    end
end
--
function MarketPanel:cellPanelData(index,obj)
    obj.data = index + 1
    obj.title = language.sell24[self.call][index+1]
end
--
function MarketPanel:onlistPanel(context)
    local data = context.data.data
    if self.call == 1 then
        self.jie = data - 1
        -- self.color = 0
    elseif self.call == 2 then
        -- self.jie = 0
        if data ~= 1 then
            self.color = data + 2
        else
            self.color = data - 1
        end
    end
    -- print("筛选",self.color,self.jie)
    local param = {reqLabel = self.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page,jie = self.jie,color = self.color}
    proxy.MarketProxy:sendMarketMsg(1260101,param)
    self.Panel.visible = false
end

--搜索
function MarketPanel:onClickSeet()
    local name = self.seetText.text or ""
    local testMl = "@@#"
    if string.trim(name) == testMl then
        local view = mgr.ViewMgr:get(ViewName.DebugView)
        if view then
            view:closeView()
        else
            mgr.ViewMgr:openView(ViewName.DebugView)    
        end
        return
    end
    self.page = 1
    proxy.MarketProxy:sendMarketMsg(1260108,{name = name,sortType = self.sortType,sortMode = self.sortMode,page = self.page})
end
--当前查询状态
function MarketPanel:setSeetState(flag)
    self.isSeet = flag
end

function MarketPanel:onClickRefresh( context )
    -- body
    self:refreshPanel()
end
--切换页码按钮  4个
function MarketPanel:onClickCutLeft1( context )
    -- body
    self.page = self.page - 10
    if self.page <= 0 then
        self.page = 1
        GComAlter(language.sell22)
    end
    if not self.isSeet then
        local param = {reqLabel = self.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page,jie = self.jie,color = self.color}
        proxy.MarketProxy:sendMarketMsg(1260101,param)
    else
        self:onClickSeet()
    end
end
function MarketPanel:onClickCutRight1( context )
    -- body
    self.page = self.page + 10
    if self.page > self.totalSum then
        self.page = self.totalSum
        GComAlter(language.sell21)
    end
    if not self.isSeet then
        local param = {reqLabel = self.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page,jie = self.jie,color = self.color}
        proxy.MarketProxy:sendMarketMsg(1260101,param)
    else
        self:onClickSeet()
    end
end
function MarketPanel:onClickCutLeft2( context )
    -- body
    self.page = self.page - 1
    if self.page <= 0 then
        self.page = 1
        GComAlter(language.sell22)
    end
    if not self.isSeet then
        local param = {reqLabel = self.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page,jie = self.jie,color = self.color}
        proxy.MarketProxy:sendMarketMsg(1260101,param)
    else
        self:onClickSeet()
    end
end
function MarketPanel:onClickCutRight2( context )
    -- body
    self.page = self.page + 1
    if self.page > self.totalSum then
        self.page = self.totalSum
        GComAlter(language.sell21)
    end
    if not self.isSeet then
        local param = {reqLabel = self.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page,jie = self.jie,color = self.color}
        proxy.MarketProxy:sendMarketMsg(1260101,param)
    else
        self:onClickSeet()
    end
end

--排序按钮 3个
function MarketPanel:onClickSortByNum( context )
    -- body
    if math.floor(self.type/100) == 100 or self.type == 100 then
        self.sortType = 4
    else
        self.sortType = 1
    end
    self.page = 1
    self.sortMode = self.sortNum
    if not self.isSeet then
        local param = {reqLabel = self.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page,jie = self.jie,color = self.color}
        proxy.MarketProxy:sendMarketMsg(1260101,param)
    else
        self:onClickSeet()
    end
    if self.sortNum == 1 then
        self.sortNum = 2
    else
        self.sortNum = 1
    end
end
function MarketPanel:onClickSortByPrice( context )
    -- body
    self.sortType = 2
    self.page = 1
    self.sortMode = self.sortPrice
    if not self.isSeet then
        local param = {reqLabel = self.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page,jie = self.jie,color = self.color}
        proxy.MarketProxy:sendMarketMsg(1260101,param)
    else
        self:onClickSeet()
    end
    if self.sortPrice == 1 then
        self.sortPrice = 2
    else
        self.sortPrice = 1
    end
end
function MarketPanel:onClickSortBySumPrice( context )
    -- body
    self.sortType = 3
    self.page = 1
    self.sortMode = self.sortSumPrice
    if not self.isSeet then
        local param = {reqLabel = self.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page,jie = self.jie,color = self.color}
        proxy.MarketProxy:sendMarketMsg(1260101,param)
    else
        self:onClickSeet()
    end
    if self.sortSumPrice == 1 then
        self.sortSumPrice = 2
    else
        self.sortSumPrice = 1
    end
end

function MarketPanel:setData( data )
    -- body
    self.data = data
    self.totalSum = data.totalSum
    if self.totalSum == 0 then
        self.totalSum = 1
    end
    self.markInfos = data.markInfos
    self.listView.numItems = #self.markInfos
    self.listView:ScrollToView(0,false,true)
    local dec = self.view:GetChild("n27")
    dec.visible = false
    if #self.markInfos == 0 then
        dec.visible = true
        dec.text = language.sell10
    end
    local pageTxt = self.view:GetChild("n22")
    pageTxt.text = data.page.."/"..self.totalSum
    --

    if math.floor(self.type/100) == 100 or self.type == 100 then
        self.view:GetChild("n7"):GetChild("title").text = language.sell37
    else
        self.view:GetChild("n7"):GetChild("title").text = language.sell38
    end
    if self.sortNum == 1 then
        self.view:GetChild("n13"):SetScale(1,1)
    else
        self.view:GetChild("n13"):SetScale(1,-1)
    end
    if self.sortPrice == 1 then
        self.view:GetChild("n15"):SetScale(1,1)
    else
        self.view:GetChild("n15"):SetScale(1,-1)
    end
    if self.sortSumPrice == 1 then
        self.view:GetChild("n14"):SetScale(1,1)
    else
        self.view:GetChild("n14"):SetScale(1,-1)
    end
end

function MarketPanel:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listView:SetVirtual()
end

function MarketPanel:itemData( index,obj )
    -- body
    local data = self.markInfos[index+1]
    local name = obj:GetChild("n2")
    local num = obj:GetChild("n3")
    local price = obj:GetChild("n4")
    local sumPrice = obj:GetChild("n5")
    local itemIcon = obj:GetChild("n1")
    local passWordImg = obj:GetChild("n10")
    if data.passSet == 1 then
        passWordImg.visible = true
    else
        passWordImg.visible = false
    end
    
    local itemType = conf.ItemConf:getType(data.mid)
    local power = conf.ItemConf:getPower(data.mid)
    local propMap = {}
    if itemType == Pack.equipType then--装备显示战力
        local score = mgr.ItemMgr:getCompreScore(data)
        num.text = math.ceil(score) -- power
        propMap = {[501] = power}
    else
        num.text = data.amount
    end
    price.text = data.price
    sumPrice.text = data.price*data.amount
    local info = {mid=data.mid,amount = data.amount,colorAttris = data.colorAttris,propMap = propMap,level = data.level or 0}
    info.isdone = cache.PlayerCache:getIsNeed(info.mid)
    if info.isdone == 2 or info.isdone == 3 then  
        --需要 和 未学排除背包
        if cache.PackCache:getPackDataById(info.mid).amount > 0 then 
            info.isdone = nil
        end
    else
        --多余不显示
        info.isdone = nil
    end
    info.isArrow = true
    --
    local color
    local itemName
    if data.petInfo and data.petInfo.petId ~= 0 then--宠物
        num.text = data.amount
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
        GSetItemData(itemIcon,info,true)
    end
    name.text = mgr.TextMgr:getQualityStr1(itemName,color)
    local btnBuy = obj:GetChild("n6")
    local itemInfo = {
        price = data.price,
        index = data.index,
        count = data.amount,
        mid = data.mid,
        roleId = data.roleId,
        srvId = data.srvId,
        passWord = self.passWord,
        passSet = data.passSet,
    }
    btnBuy.data = {shopData = itemInfo,itemData = info,petData = data}
    btnBuy.onClick:Add(self.onClickBuy,self)
end

function MarketPanel:onClickBuy( context )
    -- body
    local cell = context.sender
    local data = cell.data
    local roleId = cache.PlayerCache:getRoleId()
    if roleId == data.shopData.roleId then
        GComAlter(language.sell16)
    else
        -- if data.shopData.passSet == 1 and not self.passWord then
        --     local callfunc = function()
        --         mgr.ViewMgr:openView(ViewName.ShopBuyView,function(view)
        --             view:setData(data,10)
        --             view:setBuyCount(data.shopData.count)
        --         end)
        --     end
        --     mgr.ViewMgr:openView2(ViewName.PasswordView,{Type = 2,callback = callfunc})
        -- else
            mgr.ViewMgr:openView(ViewName.ShopBuyView,function(view)
                view:setData(data,111)
                view:setBuyCount(data.shopData.count)
            end)
        -- end
    end
end

function MarketPanel:initTitleList()
    -- body
    self.num = 0
    self.titleList.numItems = 0
    for _,data in pairs(self.titleData) do
        local url = UIPackage.GetItemURL("marketplace" , "PullList")
        local obj = self.titleList:AddItemFromPool(url)
        local titleType = tonumber(data.type)
        obj.data = data
        self:celldata(data, obj)
        self.num = self.num + 1
        if data.open == 1 then
            for _,v in pairs(self.smallData) do
                local id = tonumber(v.type)
                if titleType == math.floor(id/100) then
                    local url = UIPackage.GetItemURL("marketplace" , "BtnTitle")
                    local obj = self.titleList:AddItemFromPool(url)
                    obj.data = v
                    self:smallCelldata(v, obj)
                    self.num = self.num + 1
                end
            end
        end
    end
    for i=1,self.num do
        local obj = self.titleList:GetChildAt(i-1)
        local img = obj:GetChild("icon")
        if (obj.data.type == self.type or obj.data.type == math.floor(self.type/100)) and obj.data.type < 1000 then
            local url = UIPackage.GetItemURL("_panels" , "denlufuwuqi_004")
            img.url = url
        elseif obj.data.type < 1000 then
            local url = UIPackage.GetItemURL("_panels" , "denlufuwuqi_003")
            img.url = url
        end
    end
end

function MarketPanel:celldata(data, obj)
    -- body
    local titleTxt = obj:GetChild("title")
    titleTxt.text = data.name
    obj.data = data
    obj.onClick:Add(self.onClickSuitItem,self)
end

function MarketPanel:smallCelldata(data, obj)
    -- body
    local titleTxt = obj:GetChild("title")
    titleTxt.text = data.name
    obj.data = data
    obj.onClick:Add(self.onClickSmallSearch,self)
end

function MarketPanel:onClickSuitItem( context )
    local cell = context.sender
    local data = cell.data
    local imgBg = cell:GetChild("icon")
    for k,v in pairs(self.titleData) do
        if data.id == v.id then
            if v.open == 0 then--关
                self.titleData[k].open = 1
            else
                self.titleData[k].open = 0
            end
        else
            self.titleData[k].open = 0
        end
    end
    self.type = data.type
    self.page = 1
    if self.type == 100 then
        self.sortType = 5
    end
    self.jie = 0
    self.color = 0
    local param = {reqLabel = data.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page}
    proxy.MarketProxy:sendMarketMsg(1260101,param)
    self:initTitleList()
end

function MarketPanel:onClickSmallSearch( context )
    -- body
    local cell = context.sender
    local data = cell.data
    self.type = data.type
    -- print("当前选择类型",data.type)
    self.page = 1
    if math.floor(self.type/100) == 100 then
        self.sortType = 5
    end
    self.jie = 0
    self.color = 0
    local param = {reqLabel = data.type,sortType = self.sortType,sortMode = self.sortMode,page = self.page}
    proxy.MarketProxy:sendMarketMsg(1260101,param)
end

return MarketPanel