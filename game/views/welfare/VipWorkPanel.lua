--
-- Author: 
-- Date: 2017-07-27 20:05:13
--

local VipWorkPanel = class("VipWorkPanel",import("game.base.Ref"))

function VipWorkPanel:ctor(mParent,panel)
    self.mParent = mParent
    self.panelObj = panel
    self:initPanel()
end

function VipWorkPanel:initPanel()
    self.confData = conf.ActivityConf:getAllVipGift()
    self.listView = self.panelObj:GetChild("n2")
    self.listView.itemRenderer = function(index,obj)
        self:cellGiftData(index, obj)
    end
    self.buyBtn = self.panelObj:GetChild("n4")--一键购买
    self.buyBtn.onClick:Add(self.onClickYjBuy,self)
    self.price1 = self.panelObj:GetChild("n5")--
    self.moneyIcon = self.panelObj:GetChild("n6")
    self.moneyText = self.panelObj:GetChild("n7")--钱
    self.panelObj:GetChild("n8").text = language.welfare36
end

function VipWorkPanel:sendMsg()
    self.isFirst = true
    self.viplv = cache.PlayerCache:getVipLv()--自己的vip
    self.listView.numItems = 0
    proxy.ActivityProxy:send(1030107)
end

function VipWorkPanel:judgeVip()
    self.money = 0
    for k,v in pairs(self.confData) do
        if self.viplv >= v.vip_level and not self:isGotVipWeek(v.vip_level) then
            self.money = self.money + v.price
        end
    end
    local color = 7
    if self.money <= 0 then
        color = 14
        self.buyBtn.enabled = false
    else
        color = 7
        self.buyBtn.enabled = true
    end
    self.moneyText.text = mgr.TextMgr:getTextColorStr(self.money, color)
end
--礼包数据
function VipWorkPanel:cellGiftData(index,cell)
    local data = self.confData[index + 1]
    local vipLevel = data.vip_level

    local desc1 = cell:GetChild("n5")
    local desc2 = cell:GetChild("n14")
    
    local money1 = cell:GetChild("n7")--原价描述
    money1.text = language.gonggong31
    local money2 = cell:GetChild("n9")--特价描述
    money2.text = language.gonggong32
    local yMoney = cell:GetChild("n11")--原价
    yMoney.text = data.money_price
    local tMoney = cell:GetChild("n12")--特价
    tMoney.text = data.price
    local lineImg = cell:GetChild("n13")
    local icon1 = cell:GetChild("n8")
    local icon2 = cell:GetChild("n10")
    local goCzBtn = cell:GetChild("n16")--去充值
    goCzBtn.visible = false
    goCzBtn.onClick:Add(self.onClickCz,self)--去充值
    local arleayBuy = cell:GetChild("n6")--已购买字
    local buyBtn = cell:GetChild("n4")
    buyBtn.data = data
    buyBtn.onClick:Add(self.onClickBuyOrGet,self)--购买
    local buyIcon = buyBtn:GetChild("icon")
    buyIcon.url = UIPackage.GetItemURL(UICommonRes[6] , data.btn_font)
    local awards = data.week_awards
    local viplv = vipLevel - self.viplv
    desc1.text = string.format(language.welfare06, vipLevel)
    local isGot = self:isGotVipWeek(vipLevel)
    arleayBuy.visible = isGot
    buyBtn.visible = (not isGot)
    if viplv == 1 and vipLevel > 1 then
        local needCost = GGetVipNeedCost()
        if needCost > 0 then
            desc2.text = string.format(language.welfare15, needCost)
        else
            desc2.text = language.welfare35
        end
    else
        desc2.text = string.format(language.welfare12, vipLevel)
    end
    if self.viplv < vipLevel then
        desc2.visible = true
        goCzBtn.visible = true
        buyBtn.visible = false
        goCzBtn.y = buyBtn.y
    else
        desc2.visible = false
    end
    local awardsList = cell:GetChild("n2")
    awardsList.visible = true
    awardsList.itemRenderer = function(index,obj)
        local awardData = awards[index + 1]
        local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
        GSetItemData(obj, itemData, true)
    end
    awardsList.numItems = #awards
end

function VipWorkPanel:setData(data)
    self.vipWeekSigns = data.vipWeekSigns or {}
    self:judgeVip()
    self.listView.numItems = #self.confData
    if self.isFirst then
        self.listView:ScrollToView(0)
    end
    self.isFirst = false
end
--vip每周领取标识
function VipWorkPanel:isGotVipWeek(id)
    for k,v in pairs(self.vipWeekSigns) do
        if v and v == id then
            return true
        end
    end
end

function VipWorkPanel:setVisible(visible)
    self.panelObj.visible = visible
end

function VipWorkPanel:onClickBuyOrGet(context)
    local cell = context.sender
    local data = cell.data
    if self.viplv >= data.vip_level then
        proxy.ActivityProxy:send(1030108,{reqType = 2,vipId =   data.vip_level})
    else
        if g_ios_test then    --EVE 屏蔽处理，提示字符更改
            GComAlter(language.gonggong76)
        else
            GComAlter(language.gonggong27)
        end
    end
end

function VipWorkPanel:onClickCz()
    GOpenView({id = 1042})
end

function VipWorkPanel:onClickYjBuy()
    local text = string.format(language.welfare10, self.money)
    local param = {type = 9,richtext = mgr.TextMgr:getTextColorStr(text, 11),sure = function()
        proxy.ActivityProxy:send(1030108,{reqType = 4,vipId = 0})
    end}
    GComAlter(param)
end

function VipWorkPanel:clear()
  
end

function VipWorkPanel:onTimer()
    -- body 
end

return VipWorkPanel