--
-- Author: Your Name
-- Date: 2018-09-13 19:27:40
--万神殿精力续费提示
local WsdBuyJingLiTip = class("WsdBuyJingLiTip", base.BaseView)

function WsdBuyJingLiTip:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function WsdBuyJingLiTip:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.sureBtn = self.view:GetChild("n5")
    self.sureBtn.onClick:Add(self.onClickSure,self)
    self.decTxt1 = self.view:GetChild("n1")
    self.decTxt2 = self.view:GetChild("n2")
    self.decTxt3 = self.view:GetChild("n4")
    self.itemIcon = self.view:GetChild("n3")
    self.numTxt = self.view:GetChild("n7")
end

function WsdBuyJingLiTip:initData(data)
    local maxJl = conf.WanShenDianConf:getValue("init_max_jl")
    local sId = cache.PlayerCache:getSId()
    local costItem = conf.WanShenDianConf:getCostItem(sId)
    local itemName = conf.ItemConf:getName(costItem[1])
    local textData1 = clone(language.wanshendian06)
    local textData2 = clone(language.wanshendian07)
    local textData3 = clone(language.wanshendian08)
    textData1[2].text = string.format(textData1[2].text,maxJl)
    textData2[2].text = string.format(textData2[2].text,itemName)
    
    self.decTxt1.text = mgr.TextMgr:getTextByTable(textData1)
    self.decTxt2.text = mgr.TextMgr:getTextByTable(textData2)
    
    local itemInfo = {mid = costItem[1],amount = costItem[2],bind = 1}
    GSetItemData(self.itemIcon, itemInfo, true)

    local leftCount = cache.WanShenDianCache:getLeftCount()
    local proId = 221043201
    local itemCount = cache.PackCache:getPackDataById(proId).amount --入场券数量
    local ybNum = conf.WanShenDianConf:getValue("ticket_cost")[2]
    local vip = cache.PlayerCache:getVipLv()
    local confData = conf.VipChargeConf:getVipAwardById(vip)
    local count = confData and confData.vip_tequan[9][2] or 0
    local keyConf = conf.WanShenDianConf:getCostNum(sId)
    local index = (keyConf and (count - leftCount + 1) > #keyConf) and #keyConf or (count - leftCount + 1)
    local needCount = keyConf and keyConf[index] or 1--需要的入场券数量
    local data = {}
    data.itemInfo = {mid = proId,amount = itemCount,bind = 1}
    if itemCount >= needCount then
        self.numTxt.text = mgr.TextMgr:getTextColorStr(itemCount .. "/" .. needCount, 4)
        self.decTxt3.text = language.fuben174
    else
        local str = mgr.TextMgr:getTextColorStr(itemCount, 14)
        self.numTxt.text = str .. mgr.TextMgr:getTextColorStr("/"..needCount, 4)
        local needYb = ybNum*(needCount - itemCount)
        textData3[2].text = string.format(textData3[2].text,needYb)
        self.decTxt3.text = mgr.TextMgr:getTextByTable(textData3)
    end
end

function WsdBuyJingLiTip:onClickSure()
    local sId = cache.PlayerCache:getSId()
    local costItem = conf.WanShenDianConf:getCostItem(sId)
    local hasCount = cache.PackCache:getPackDataById(costItem[1]).amount
    local needCount = costItem[2]
    local costYb = conf.WanShenDianConf:getValue("ticket_cost")[2]
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local myByb = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
    if hasCount < needCount then
        if myYb + myByb >= costYb then
            proxy.WanShenDianProxy:send(1331303)
        else
            GComAlter(language.gonggong18)
        end
    else
        proxy.WanShenDianProxy:send(1331303)
    end
    self:closeView()
end

return WsdBuyJingLiTip