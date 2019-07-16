--
-- Author: Your Name
-- Date: 2018-09-18 14:38:56
--欢乐兑换
local Gq1005 = class("Gq1005",import("game.base.Ref"))

function Gq1005:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Gq1005:onTimer()
    -- body
    if not self.data then return end
end

-- 变量名：reqType 说明：0:显示 1:兑换
-- 变量名：canExchangeTimes    说明：可以兑换的次数
-- array<SimpleItemInfo>   变量名：items   说明：兑换的物品
-- 变量名：actStartTime    说明：开始时间
-- 变量名：actEndTime  说明：结束时间
-- 变量名：cid 说明：兑换id
function Gq1005:addMsgCallBack(data)
    -- body
    printt("欢乐兑换",data)
    self.data = data
    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)

    self.exchangeData = conf.GuoQingConf:getExchangeData()
    self.listView.numItems = #self.exchangeData
end

function Gq1005:initView()

    self.timeTxt = self.view:GetChild("n4")
    self.decTxt = self.view:GetChild("n5")
    self.decTxt.text = language.gq16

    self.listView = self.view:GetChild("n6")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()

end

function Gq1005:celldata( index,obj )
    local data = self.exchangeData[index+1]
    if data then
        local itemObj = obj:GetChild("n1")
        local itemName = obj:GetChild("n2")
        local numTxt = obj:GetChild("n5")
        local getCount = obj:GetChild("n8")
        local getBtn = obj:GetChild("n6")
        local c1 = getBtn:GetController("c1")


        local name = conf.ItemConf:getName(data.items[1][1])
        itemName.text = name

        local itemInfo = {mid = data.items[1][1],amount = data.items[1][2],bind = data.items[1][3]}
        GSetItemData(itemObj, itemInfo, true)

        local needMid = data.cost[1][1]
        local needAmount = data.cost[1][2]
        local hasAmount = cache.PackCache:getPackDataById(needMid).amount
        numTxt.text = hasAmount .. "/" .. needAmount

        local hasTimes = self.data.canExchangeTimes[data.id]
        getCount.text = hasTimes

        local flag = false--是否可兑换
        if hasAmount >= needAmount and hasTimes > 0 then
            flag = true
        end

        if flag then
            c1.selectedIndex = 0
        else
            c1.selectedIndex = 1
        end

        getBtn.data = {cid = data.id,flag = flag}
        getBtn.onClick:Add(self.onClickGet,self)

    end
end

function Gq1005:onClickGet( context )
    local data = context.sender.data
    if data.flag then
        proxy.GuoQingProxy:sendMsg(1030620,{reqType = 1,cid = data.cid})
    else
        if self.data.canExchangeTimes[data.cid] > 0 then
            GComAlter(language.gq12)
        else
            GComAlter(language.dailyactive07)
        end
    end
end

return Gq1005