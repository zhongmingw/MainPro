--
-- Author: 
-- Date: 2018-06-30 19:31:34
--

local HeFuBagView = class("HeFuBagView", base.BaseView)

function HeFuBagView:ctor()
    HeFuBagView.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function HeFuBagView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n6")
    closeBtn.onClick:Add(self.onBtnClose,self)

    self.leftTime = self.view:GetChild("n7")
    local title = self.view:GetChild("n4")
    title.text = language.hefubag01

    self.listView = self.view:GetChild("n8")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
end
function HeFuBagView:initData()
    
end

function HeFuBagView:cellData(index,obj)
    local data = self.confData[index+1]
    if data then
        local name = obj:GetChild("n1")
        name.text = conf.ItemConf:getName(data.item[1][1])
        
        local item = obj:GetChild("n10")
        local param = {mid = data.item[1][1],amount = data.item[1][2],bind = data.item[1][3]}
        GSetItemData(item,param,true)
        
        local oldPrice = obj:GetChild("n4")
        oldPrice.text = data.old_price
        
        local newprice = obj:GetChild("n7")
        newprice.text = data.cost_money[2] 
        local img = obj:GetChild("n9")
        local buyBtn = obj:GetChild("n8")
        buyBtn.data = data
        buyBtn.onClick:Add(self.buyBag,self)
        if self.data.buys[data.id] >= data.max_count then
            buyBtn.touchable = false
            buyBtn.grayed = true
            img.grayed = true
        else
            buyBtn.touchable = true
            buyBtn.grayed = false
            img.grayed = false

        end
    end
end
function HeFuBagView:buyBag( context )
    local data = context.sender.data

    local needYb = data.cost_money[2] 
    local goldData = cache.PackCache:getPackDataById(PackMid.gold)
    if goldData.amount < needYb then 
        GComAlter(language.gonggong18)
        GGoVipTequan(0)
        self:onBtnClose(0)
    else
        proxy.ActivityProxy:sendMsg(1030411,{reqType = 1,cfgId = data.id})
    end
end

function HeFuBagView:setData(data)
    printt(data)
    self.data = data
    self.time = data.todayLeftTime
    self.confData = conf.ActivityConf:getConfDataByOpenDay(data.curDay)
    self.listView.numItems = #self.confData
    if self.timertick then
        self:removeTimer(self.timertick)
        self.timertick = nil
    end
    if not self.timertick then 
        self:onTimer()
        self.timertick = self:addTimer(1, -1, handler(self, self.onTimer))
    end
  
    
end

function HeFuBagView:onTimer()
    if self.time then 
        self.leftTime.text = GTotimeString(self.time)
        if self.time <= 0 then
            self:closeView()
            return
        end
        self.time = self.time - 1
    end
end

function HeFuBagView:onBtnClose()
    if self.timertick then
        self:removeTimer(self.timertick)
        self.timertick = nil
    end
    self:closeView()
end

return HeFuBagView