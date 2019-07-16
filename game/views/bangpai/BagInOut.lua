--
-- Author: 
-- Date: 2017-03-03 16:54:06
--

local BagInOut = class("BagInOut", base.BaseView)

function BagInOut:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function BagInOut:initData(data)
    -- body
    self.data = data
    local index = self.data.index or 0
    local gangJob = cache.PlayerCache:getGangJob() or 0
    if (gangJob == 4 or gangJob == 3 or gangJob == 2) and mgr.ItemMgr:isGangWareItem(index) then
        self.c2.selectedIndex = 1
    else
        self.c2.selectedIndex = 0
    end
end

function BagInOut:initView()
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.itemObj = self.view:GetChild("n1")
    self.itemname = self.view:GetChild("n2")
    self.itemCount = self.view:GetChild("n14")
    self.itemdec = self.view:GetChild("n7")

    self.dec1 = self.view:GetChild("n8")
    self.labcount = self.view:GetChild("n9")
    self.dec2 = self.view:GetChild("n10") 
    self.labmoney = self.view:GetChild("n11") 

    local btnreduce = self.view:GetChild("n3")
    btnreduce.onClick:Add(self.onBtnReduce,self)
    local btnplus = self.view:GetChild("n4")
    btnplus.onClick:Add(self.onBtnPlus,self)

    local btnSure = self.view:GetChild("n5") 
    --btnSure:GetChild("title").visible = true
    btnSure.onClick:Add(self.onSure,self)

    self.xiaohuiBtn = self.view:GetChild("n19")
    self.xiaohuiBtn.onClick:Add(self.onXiaohui,self)
end

function BagInOut:setItemMsg()
    -- body
    local t = clone(self.data)
    if t.issetAmount then
        t.amount = 1
    end
    GSetItemData(self.itemObj,t,true)

    self.itemname.text = mgr.TextMgr:getColorNameByMid(self.data.mid)
    if self.c1.selectedIndex == 2 then
        self.itemCount.text = string.format(language.bangpai63,self.data.count)
    end
    self.itemdec.text =  conf.ItemConf:getDescribe(self.data.mid)
end
--取出
function BagInOut:setDataOut()
    self.c1.selectedIndex = 1
    self:setItemMsg(self.data.mid)

    self.dec1.text = language.bangpai76
    self.dec2.text = language.bangpai77

    local confData = conf.BangPaiConf:getStoreItem(self.data.mid)
    self.money =  confData and confData.take_gx or 0
    self.count = 1

    self:setMoney()
end

--存入
function BagInOut:setDataIn()
    self.c1.selectedIndex = 0
    self:setItemMsg(self.data.mid)

    self.dec1.text = language.bangpai78
    self.dec2.text = language.bangpai79

    local confData = conf.BangPaiConf:getStoreItem(self.data.mid)
    self.money =  confData.store_gx
    self.count = 1

    self:setMoney()
end

function BagInOut:setMoney()
    -- body
    self.labcount.text = self.count
    local money = self.count*self.money
    if self.c1.selectedIndex == 2 or self.c1.selectedIndex == 1 then
        if money > cache.PlayerCache:getTypeMoney(MoneyType.ckl) then
            self.isget = false
            self.labmoney.text = mgr.TextMgr:getTextColorStr(money, 14)
        else
            self.isget = true
            self.labmoney.text = mgr.TextMgr:getTextColorStr(money, 7)
        end
    else
        self.labmoney.text = mgr.TextMgr:getTextColorStr(money, 7)
    end
end
--商店对换换
function BagInOut:setDataBuy()
    -- body
    self.c1.selectedIndex = 2
    self:setItemMsg(self.data.mId)

    self.dec1.text = language.bangpai64
    self.dec2.text = language.bangpai65

    self.count = 1
    self.money = self.data.data.gx

    self:setMoney()
end
--交易放入
function BagInOut:setTradeIn()
    -- body
    self.c1.selectedIndex = 3
    self.dec1.text = language.trade04
    self:setItemMsg(self.data.mid)

    self.count = 1
    self.money = 1 
    self:setMoney()
end
--交取出
function BagInOut:setTradeOut()
    -- body
    self.c1.selectedIndex = 4
    self.dec1.text = language.trade04
    self:setItemMsg(self.data.mid)

    self.count = 1
    self.money = 1 
    self:setMoney()
end

function BagInOut:onBtnReduce()
    -- body
    if self.count == 1 then
        GComAlter(language.bangpai119)
        return
    end

    self.count = self.count - 1
    if self.count < 1 then
        self.count = 1
    end
    self:setMoney()
end

function BagInOut:onBtnPlus()
    -- body
    --if self.c1.selectedIndex == 3 or self.c1.selectedIndex == 4 then

    if self.c1.selectedIndex == 2 then
        if (self.count+1)*self.money > cache.PlayerCache:getTypeMoney(MoneyType.ckl) then
            GComAlter(language.bangpai120)
            return
        end
    elseif self.c1.selectedIndex == 1 then --取出
        if self.count + 1  > self.data.amount then --数量限制
            GComAlter(language.bangpai120)
            return
        end
        if (self.count+1)*self.money > cache.PlayerCache:getTypeMoney(MoneyType.ckl) then --贡献限制
            GComAlter(language.bangpai120)
            return
        end
    else
        if self.count + 1  > self.data.amount then --数量限制
            GComAlter(language.bangpai120)
            return
        end
    end
    self.count = self.count + 1 
    self:setMoney()
end


function BagInOut:onSure()
    -- body
    if self.count == 0 then
        return
    end

    if self.c1.selectedIndex == 2 then --兑换
        if self.isget  then
            local param = {}
            param.reqType = 2
            param.buyId = self.data.data.id
            param.buyLev = self.data.data.gang_lev
            param.buyNum = self.count
            proxy.BangPaiProxy:sendMsg(1250302,param)
            self:onBtnClose()
        else
            GComAlter(language.gonggong68)
        end
    elseif self.c1.selectedIndex == 1 then --取出
        if self.isget then
            local param = {}
            param.index = self.data.index
            param.amount = self.count
            param.reqType = 2
            proxy.BangPaiProxy:send1250305(param,self.data)
            --self:onBtnClose()
        else
            GComAlter(language.gonggong68)
        end
    elseif self.c1.selectedIndex == 3 or self.c1.selectedIndex == 4 then--交易放入 取出
        local param = {}
        if self.c1.selectedIndex == 3 then
            param.tradeType = 1 
        else
            param.tradeType = 2
        end
        param.index = self.data.index
        param.amount = self.count
        proxy.TradeProxy:send(1260203,param)

        self:onBtnClose()
    else --存入
        local param = {}
        param.index = self.data.index
        param.amount = self.count
        param.reqType = 1
        proxy.BangPaiProxy:send1250305(param,self.data)
        --self:onBtnClose()
    end
end

function BagInOut:add5250305(data)
    if data.reqType == 1 then
        GComAlter(string.format(language.bangpai147,self.count*self.money))
    elseif data.reqType == 2 then
        GComAlter(string.format(language.bangpai146,self.count*self.money)) 
    end
    self:onBtnClose()
end

function BagInOut:onXiaohui()
    local index = self.data and self.data.index
    if index then
        local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(language.bangpai150, 6),sure = function()
            proxy.BangPaiProxy:send1250305({index = index,amount = self.count,reqType = 3},self.data)
        end}
        GComAlter(param)
    end
end

function BagInOut:onBtnClose()
    -- body
    self:closeView()
end
return BagInOut