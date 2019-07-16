
local MarketMainView = class("MarketMainView", base.BaseView)
local MarketPanel = import(".MarketPanel")
local SellPanel = import(".SellPanel")
local RecordPanel = import(".RecordPanel")

function MarketMainView:ctor()
    self.super.ctor(self)
    self.uiClear = UICacheType.cacheTime
end

function MarketMainView:initData(data)
    local window2 = self.view:GetChild("n0")
    GSetMoneyPanel(window2,self:viewName())
    local closeBtn = window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)
    self:GoToPage(data.index)
    self:refreshRedPoint()

    self.super.initData()
end

function MarketMainView:refreshRedPoint()
    -- body
    local var1 = cache.PlayerCache:getRedPointById(attConst.A10225)
    local var2 = cache.PlayerCache:getRedPointById(attConst.A10226)
    if var1+var2>0 then
        self.btnRecord:GetChild("n4").visible = true
    else
        self.btnRecord:GetChild("n4").visible = false
    end
end

function MarketMainView:initView()

    --按钮：市场，出售，记录
    self.controllerC1 = self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onController1,self)
    self.btnMarket = self.view:GetChild("n20")
    self.btnMarket.data = 0
    self.btnMarket.onClick:Add(self.onBtnCall,self)
    self.btnMarket:GetChild("title").text = language.sell01

    self.btnSell = self.view:GetChild("n21")
    self.btnSell.data = 1
    self.btnSell.onClick:Add(self.onBtnCall,self)
    self.btnSell:GetChild("title").text = language.sell02

    self.btnRecord = self.view:GetChild("n22")
    self.btnRecord.data = 2
    self.btnRecord.onClick:Add(self.onBtnCall,self)
    self.btnRecord:GetChild("title").text = language.sell03

    --self:onController1()
end

function MarketMainView:onController1()
    -- body
    if 0 == self.controllerC1.selectedIndex then  --市场信息 
        if not self.MarketPanel then
            self.MarketPanel = MarketPanel.new(self)
        end
        self.MarketPanel:refreshPanel()
    elseif 1 == self.controllerC1.selectedIndex then --出售信息
        if not self.SellPanel then
            self.SellPanel = SellPanel.new(self)
        end
        self.SellPanel:refreshPanel()
    elseif 2 == self.controllerC1.selectedIndex then --记录信息
        if not self.RecordPanel then
            self.RecordPanel = RecordPanel.new(self)
        end
        self.RecordPanel:refreshPanel()
    end
end

function MarketMainView:onBtnCall(context)
    -- body
    self.controllerC1.selectedIndex = context.sender.data
end

function MarketMainView:GoToPage(page)
    -- body
    if page == self.controllerC1.selectedIndex then
        self:onController1()
    else
        self.controllerC1.selectedIndex = page or 0
    end

    
end

function MarketMainView:onClickClose()
    -- body
    self:closeView()
end

return MarketMainView