--
-- Author: 
-- Date: 2017-09-19 19:46:40
--

local AwakenBuyFag = class("AwakenBuyFag", base.BaseView)

function AwakenBuyFag:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function AwakenBuyFag:initView()
    self.maxTired = conf.AwakenConf:getJsdValue("day_buy_tired_max")
    self.tiredPrices = conf.AwakenConf:getJsdValue("tired_price")
    local closeBtn = self.view:GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.fagText = self.view:GetChild("n3")--剩余疲劳值
    self.fagText.text = language.awaken14
    self.view:GetChild("n17").text = language.awaken15

    self.timeText = self.view:GetChild("n4")

    self.view:GetChild("n5").text = language.awaken17
    self.view:GetChild("n6").text = language.arena14
    self.view:GetChild("n11").text = language.arena15
    self.view:GetChild("n14").text = language.awaken18
    self.priceText = self.view:GetChild("n20")--购买总价
    self.priceBText = self.view:GetChild("n22")--返还绑元

    self.countText = self.view:GetChild("n8")--购买次数
    self.countText.text = 1

    local leftBtn = self.view:GetChild("n10")
    leftBtn.onClick:Add(self.onClickLess,self)
    local rightBtn = self.view:GetChild("n9")
    rightBtn.onClick:Add(self.onClickAdd,self)

    local useBtn = self.view:GetChild("n12")--使用疲劳
    useBtn.onClick:Add(self.onClickUse,self)
    local buyBtn = self.view:GetChild("n13")--购买疲劳
    buyBtn.onClick:Add(self.onClickBuy,self)

    self.leftBuyTiredText = self.view:GetChild("n14")
end

function AwakenBuyFag:initData(data)
    self.count = 1
    self:setData(data)
end

function AwakenBuyFag:setData(data)
    self.warData = data or cache.AwakenCache:getAwakenWarData()
    local leftBuyTiredCount = self.warData and self.warData.leftBuyTiredCount or 0
    self.leftBuyTiredText.text = language.awaken18..mgr.TextMgr:getTextColorStr(leftBuyTiredCount, 7)
    local tired = self.warData and self.warData.tired or 0
    self.fagText.text = language.awaken14..mgr.TextMgr:getTextColorStr(tired, 7)
    local leftPlayTime = self.warData and self.warData.leftPlayTime or 0
    self.timeText.text = language.awaken16..mgr.TextMgr:getTextColorStr(GTotimeString(leftPlayTime), 7)
    self:setCountPrice()
end

function AwakenBuyFag:setCountPrice()
    local leftBuyTiredCount = self.warData and self.warData.leftBuyTiredCount or 0
    if self.count < 1 then
        self.count = 1
    end
    if self.count > leftBuyTiredCount then
        self.count = leftBuyTiredCount
        GComAlter(language.awaken28)
    end
    local count = self.maxTired - leftBuyTiredCount + 1--从第几次开始买
    local max = count + self.count - 1
    local price = 0
    for i=count,max do
        local tiredPrice = 0
        if i >= #self.tiredPrices then
            tiredPrice = self.tiredPrices[#self.tiredPrices]
        else
            tiredPrice = self.tiredPrices[i]
        end
        price = price + tiredPrice
    end
    self.countText.text = self.count
    self.priceText.text = price
    self.priceBText.text = price
end

function AwakenBuyFag:onClickLess()
    self.count = self.count - 1
    self:setCountPrice()
end

function AwakenBuyFag:onClickAdd()
    self.count = self.count + 1
    self:setCountPrice()
end
--使用疲劳
function AwakenBuyFag:onClickUse()
    proxy.AwakenProxy:send(1430104,{count = 1})
    self:closeView()
end
--购买疲劳
function AwakenBuyFag:onClickBuy()
    proxy.AwakenProxy:send(1430105,{count = self.count})
    self:closeView()
end

return AwakenBuyFag