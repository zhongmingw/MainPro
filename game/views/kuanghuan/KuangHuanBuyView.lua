--
-- Author: 
-- Date: 2018-08-01 21:14:35
--

local KuangHuanBuyView = class("KuangHuanBuyView", base.BaseView)

function KuangHuanBuyView:ctor()
    KuangHuanBuyView.super.ctor(self)
    self.uiLevel = UILevel.level2 
end

function KuangHuanBuyView:initView()
    local closeBtn = self.view:GetChild("n1")
    self:setCloseBtn(closeBtn)
end
--data.index 0：可以买，1：到上限，2：未解锁
function KuangHuanBuyView:initData(data)
    -- printt("道具",data)
    self.lockCzConf = conf.ActivityConf:getValue("happy_buy_unlock_cz")
    --上一层
    local lastFloor = data.curFloor - 1
    if lastFloor == 0 then
        lastFloor = 1
    end 
    --上一层的充值额度
    local lastFloorCzQuota = self.lockCzConf[lastFloor]
    -- print("当前层",data.curFloor,"上一层",lastFloor,"上一层的充值额度",lastFloorCzQuota[2],"已充值",data.czSum)
    local awardData = data.awardData
    local buyTimes = data.buyTimes
    
    local itemObj = self.view:GetChild("n2")
    local c1 = itemObj:GetController("c1")
    c1.selectedIndex = data.index

    local unlock_cz = self.view:GetChild("n6")
    local str = ""
    if c1.selectedIndex == 2 then--未解锁
        if data.czSum >= lastFloorCzQuota[2] then
            str = awardData.unlock_cz 
        else
            str = language.khdlg03--秘密
        end
    else
        str = awardData.unlock_cz 
    end
    unlock_cz.text = str


    local buyBtn = self.view:GetChild("n12")
    buyBtn.data = awardData.id
    buyBtn.onClick:Add(self.onClickBuyBtn,self)
    
    if data.index == 0 then
        buyBtn.touchable = true
        buyBtn.grayed = false
    else
        buyBtn.touchable = false
        buyBtn.grayed = true
    end
   
    local item = itemObj:GetChild("n0")
    local temp = awardData.item[1]
    local isquan = awardData.isquan
    if not isquan then
        if c1.selectedIndex == 2 or c1.selectedIndex == 1 then
            isquan = 0
        else
            isquan = nil
        end
    end
    local itemData = {mid = temp[1],amount = temp[2],bind = temp[3],isquan = isquan}
    GSetItemData(item, itemData, true)

    local mid = temp[1]
    local name = self.view:GetChild("n3")
    local color = conf.ItemConf:getQuality(mid)
    local proName = conf.ItemConf:getName(mid)
    name.text = mgr.TextMgr:getQualityStr1(proName, color)

    --个人限购
    local limtNum = self.view:GetChild("n7")
    limtNum.text = tostring(buyTimes).."/"..tostring(awardData.buy_limit)
    
    local oldMoney = self.view:GetChild("n9")
    oldMoney.text = awardData.old_price

    local newMoney = self.view:GetChild("n11")
    newMoney.text = awardData.price[2]

    local dec1 = self.view:GetChild("n4")
    dec1.text = language.khdlg04
    local dec2 = self.view:GetChild("n5")
    dec2.text = language.khdlg05

end

function KuangHuanBuyView:onClickBuyBtn(context)
    local id = context.sender.data
    proxy.ActivityProxy:sendMsg(1030510,{reqType = 1,cfgId = id})
    self:closeView()
end

return KuangHuanBuyView