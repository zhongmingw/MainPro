--
-- Author: Your Name
-- Date: 2017-11-29 16:17:10
--

local WeddingView = class("WeddingView", base.BaseView)

function WeddingView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function WeddingView:initView()
    local quitBtn = self.view:GetChild("n14")
    quitBtn.onClick:Add(self.onClickQuit,self)
    self.c1 = self.view:GetController("c1")
    self.t0 = self.view:GetTransition("t0")
    self.t1 = self.view:GetTransition("t1")
    local arrowBtn = self.view:GetChild("n5")
    arrowBtn.onClick:Add(self.onClickArrow,self)
    self.trackItem = self.view:GetChild("n0")
    self.time1 = self.view:GetChild("n6")
    self.time2 = self.view:GetChild("n8")

    self.processBar = self.view:GetChild("n9")
    self.processBar.value = 0
    --两个节点的img
    self.img1 = self.processBar:GetChild("n7")
    self.img2 = self.processBar:GetChild("n8")
    self.barImg = self.processBar:GetChild("bar")

    self.marryBtn = self.view:GetChild("n10")--拜堂按钮
    self.marryBtn.onClick:Add(self.onClickMarry,self)
    self.wishBtn = self.view:GetChild("n11") --祝福按钮
    self.wishBtn.onClick:Add(self.onClickWish,self)
    self.storeBtn = self.view:GetChild("n12")--商城按钮
    self.storeBtn.onClick:Add(self.onClickShop,self)
    self.manageBtn = self.view:GetChild("n13")     --管理按钮
    self.manageBtn.onClick:Add(self.onClickManage,self)
end

-- status=0,joyfulRefresh=1,expPool=0,
-- leftTime=1511918100,hotProgress=20,
-- msgId=5390309,banquetCount=0
function WeddingView:initData(data)
    -- print("场景信息",data)
    -- printt(data)
    self.data = data
    local nuptialHot = conf.MarryConf:getValue("nuptial_hot_progress")
    local img1Num = nuptialHot[1][1]
    local img2Num = nuptialHot[2][1]
    self.img1.x = self.barImg.x +(img1Num/3344* (self.processBar.width))-5--这个5个像素是根据实际情况定的
    self.img2.x = self.barImg.x +(img2Num/3344* (self.processBar.width))-5


    local banquetTxt = self.trackItem:GetChild("n10")
    local expPoolTxt = self.trackItem:GetChild("n11")
    local joyousTxt = self.trackItem:GetChild("n12")
    local decTxt = self.trackItem:GetChild("n13")
    local sumNum = conf.MarryConf:getValue("wedding_banquet_count")
    banquetTxt.text = string.format(language.marryiage37,data.banquetCount,sumNum)
    expPoolTxt.text = language.marryiage38 .. GTransFormNum(data.expPool)
    local maxNum = conf.MarryConf:getValue("joyful_count")
    joyousTxt.text = data.joyfulCount .. "/" ..maxNum
    -- local textData = {
    --         {text = language.marryiage41[1],color = 5},
    --         {text = language.marryiage41[2],color = 4},
    --         {text = language.marryiage41[3],color = 5},
    --         {text = language.marryiage41[4],color = 4},
    --         {text = language.marryiage41[5],color = 5},
    -- }
    local textData = {
            {text = language.marryiage41_01[1],color = 5},
    }
    decTxt.text = mgr.TextMgr:getTextByTable(textData)
    self.numHot = self.trackItem:GetChild("n19")
    self.numHot.text = data.hotProgress
    self.processBar.value = data.hotProgress %3344
    self.processBar.max = 3344

    self.timeCount = 0--经验请求

    local curTime = data.leftTime - mgr.NetMgr:getServerTime()
    local timeData = GGetTimeData(curTime)
    self.time1.text = timeData.min
    self.time2.text = string.format("%02d",timeData.sec)
    self.timer = self:addTimer(1, -1,handler(self,self.timerClick))

    self:setFireworks()

end

--烟花道具
function WeddingView:setFireworks()
    --{{221042047},{221042048}},
    --cache.PackCache:getPackDataById(id,isCount,isBind)
    local fireworks = conf.MarryConf:getValue("fireworks")
    local mId1 = fireworks[1][1]
    local mId2 = fireworks[2][1]
    local itemInfo1 = cache.PackCache:getPackDataById(mId1,true)
    local itemInfo2 = cache.PackCache:getPackDataById(mId2,true)
    local item1 = self.trackItem:GetChild("n14"):GetChild("n0")
    local item2 = self.trackItem:GetChild("n14"):GetChild("n1")
    local useBtn1 = self.trackItem:GetChild("n14"):GetChild("n2")
    local useBtn2 = self.trackItem:GetChild("n14"):GetChild("n4")
    local buyBtn1 = self.trackItem:GetChild("n14"):GetChild("n3")
    local buyBtn2 = self.trackItem:GetChild("n14"):GetChild("n5")
    useBtn1.data = itemInfo1
    useBtn2.data = itemInfo2
    useBtn1.onClick:Add(self.onClickUse,self)
    useBtn2.onClick:Add(self.onClickUse,self)
    buyBtn1.data = itemInfo1
    buyBtn2.data = itemInfo2
    buyBtn1.onClick:Add(self.onClickBuy,self)
    buyBtn2.onClick:Add(self.onClickBuy,self)
    if itemInfo1.amount > 0 then
        buyBtn1.visible = false
        useBtn1.visible = true
    else
        buyBtn1.visible = true
        useBtn1.visible = false
    end
    if itemInfo2.amount > 0 then
        buyBtn2.visible = false
        useBtn2.visible = true
    else
        buyBtn2.visible = true
        useBtn2.visible = false
    end
    GSetItemData(item1, itemInfo1, true)
    GSetItemData(item2, itemInfo2, true)
end

--热度刷新
function WeddingView:refreshHot(data)
    local leftValue = self.processBar.value
    self.numHot.text = data.hotProgress
    self.processBar.value = data.hotProgress%3344
    local fireworks = conf.MarryConf:getValue("fireworks")
    local nuptialHot = conf.MarryConf:getValue("nuptial_hot_progress")
    local isHot = false
    for k,v in pairs(nuptialHot) do
        if leftValue  < v[1] and data.hotProgress >= v[1] then
            isHot = true
            break
        elseif leftValue > 1314 and data.hotProgress < 512 then
            isHot = true
            break
        end
    end
    if isHot then--喜糖
        
    elseif data.itemId == fireworks[1][1] then
        mgr.ViewMgr:openView2(ViewName.Alert15,4020148)
    elseif data.itemId == fireworks[2][1] then
        mgr.ViewMgr:openView2(ViewName.Alert15,4020147)
    end

end
--经验刷新
function WeddingView:refreshExp(data)
    local expPoolTxt = self.trackItem:GetChild("n11")
    expPoolTxt.text = language.marryiage38 .. GTransFormNum(data.exp)
end
--酒席使用数量刷新joyful_count
function WeddingView:refreshBanquetCount(data)
    local banquetTxt = self.trackItem:GetChild("n10")
    local sumNum = conf.MarryConf:getValue("wedding_banquet_count")
    banquetTxt.text = string.format(language.marryiage37,data.banquetCount,sumNum)
end
--采集物刷新
function WeddingView:refreshJoyful(data)
    local joyousTxt = self.trackItem:GetChild("n12")
    local maxNum = conf.MarryConf:getValue("joyful_count")
    joyousTxt.text = data.joyfulCount .. "/" ..maxNum
    -- print("采集物刷新",data.joyfulCount)
end

function WeddingView:onClickUse( context )
    local data = context.sender.data
    local param = {}
    param.index = data.index
    param.amount = 1
    -- print("使用道具index",data.index)
    proxy.PackProxy:sendUsePro(param)
end

function WeddingView:onClickBuy( context )
    local data = context.sender.data
    local shopData = conf.ShopConf:getWeddingItemByMid(data.mid)
    proxy.ShopProxy:sendByItemsByStore( 8,shopData.id,1)
end

function WeddingView:timerClick()
    local curTime = self.data.leftTime - mgr.NetMgr:getServerTime()
    if curTime > 0 then
        local timeData = GGetTimeData(curTime)
        self.time1.text = timeData.min
        self.time2.text = string.format("%02d",timeData.sec)
    else
        self:onClickQuit()
        self:closeView()
    end
    if self.timeCount < 4 then
        self.timeCount = self.timeCount + 1
    else
        self.timeCount = 0
        proxy.MarryProxy:sendMsg(1390308)
    end
end

function WeddingView:onClickMarry()
    proxy.MarryProxy:sendMsg(1390307,{reqType = 1})
end

function WeddingView:onClickWish()
    -- print("祝福按钮")
    -- mgr.ViewMgr:openView2(ViewName.MarryWishView,{})
    proxy.MarryProxy:sendMsg(1390304,{reqType = 0})
end

function WeddingView:onClickShop()
    mgr.ViewMgr:openView2(ViewName.MarryStoreView)
end

function WeddingView:onClickManage()
    if self.data.isOwer == 1 then
        proxy.MarryProxy:sendMsg(1390303,{reqType = 1})
    else
        GComAlter(language.marryiage56)
    end
end

function WeddingView:onClickQuit()
    self:closeView()
    mgr.FubenMgr:quitFuben()
end

function WeddingView:hidePanel()
    self.ctrl1.selectedIndex = 1
    self.t0:Play()
end

function WeddingView:appearPanel()
    self.ctrl1.selectedIndex = 0
    self.t1:Play()
end

function WeddingView:onClickArrow()
    if self.c1.selectedIndex == 0 then
        self:hidePanel()
    else
        self:appearPanel()
    end
end

return WeddingView