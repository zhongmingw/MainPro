--
-- Author: 
-- Date: 2019-01-08 11:21:39
--

local Bx1007 = class("Bx1007",import("game.base.Ref"))

function Bx1007:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Bx1007:onTimer()
    -- body
    if not self.data then return end
end

-- 变量名：reqType 说明：0:显示 1:兑换
-- 变量名：canExchangeTimes    说明：可以兑换的次数
-- array<SimpleItemInfo>   变量名：items   说明：兑换的物品
-- 变量名：actStartTime    说明：开始时间
-- 变量名：actEndTime  说明：结束时间
-- 变量名：cid 说明：兑换id
function Bx1007:addMsgCallBack(data)
    -- body
    printt("惊喜兑换",data)
    self.data = data
    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)

    self.exchangeData = conf.BingXueConf:getExchangeData()
    self.listView.numItems = #self.exchangeData
end

function Bx1007:initView()

    self.timeTxt = self.view:GetChild("n3")
    self.decTxt = self.view:GetChild("n1")
    self.decTxt.text = language.bxJxdh01

    self.listView = self.view:GetChild("n4")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()

end

function Bx1007:celldata( index,obj )
    local data = self.exchangeData[index+1]
    if data then
        local itemObj = obj:GetChild("n6")
        local itemName = obj:GetChild("n7")
        local numTxt = obj:GetChild("n14")
        local getCount = obj:GetChild("n16")
        local getBtn = obj:GetChild("n11")
        local red = getBtn:GetChild("red")
        local c1 = getBtn:GetController("c1")
        local signIcon = obj:GetChild("n13")
        --221071851
        --print(data.items[1][1])
        GSetItemData(signIcon, {mid =221043924,amount =0,bind =1}, true)

        local name = conf.ItemConf:getName(data.items[1][1])
        itemName.text = name

        local itemInfo = {mid = data.items[1][1],amount = data.items[1][2],bind = data.items[1][3]}
        GSetItemData(itemObj, itemInfo, true)

        local needMid = data.cost[1][1]
        local needAmount = data.cost[1][2]
        local hasAmount = cache.PackCache:getPackDataById(needMid).amount
        numTxt.text = hasAmount .. "/" .. needAmount

        if self.data.gotTimes[data.id] then
            self.hasTimes = data.num - self.data.gotTimes[data.id]
        else
            self.hasTimes = data.num
        end
        
        getCount.text = self.hasTimes

        local flag = false--是否可兑换
        if hasAmount >= needAmount and self.hasTimes > 0 then
            red.visible=true
            flag = true
        end

        if flag then
            c1.selectedIndex = 0
        else
            red.visible=false
            c1.selectedIndex = 1
        end

        getBtn.data = {cid = data.id,flag = flag,num=data.num}
        getBtn.onClick:Add(self.onClickGet,self)

    end
end

function Bx1007:onClickGet( context )
    local data = context.sender.data
    if self.data.gotTimes[data.cid] then
        self.hasTimes = data.num - self.data.gotTimes[data.cid]
    else
        self.hasTimes = data.num
    end
    if data.flag then
        proxy.BingXueProxy:sendMsg(1030701,{reqType = 1,cid = data.cid})
    else
        if self.hasTimes > 0 then
            GComAlter(language.bxJxdh03)
        else
            GComAlter(language.bxJxdh02)
        end
    end
end

return Bx1007