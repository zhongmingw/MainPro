--
-- Author: 
-- Date: 2018-10-22 14:50:40
--

local WSJ1003 = class("WSJ1003",import("game.base.Ref"))

function WSJ1003:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function WSJ1003:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)
    self.timeTxt = panelObj:GetChild("n4")
    self.timeTxt.text = ""
    
    local decTxt = panelObj:GetChild("n5")
    decTxt.text = language.wsj03

    self.listView = panelObj:GetChild("n6")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

    self.leftTimeTxt = panelObj:GetChild("n7")


end

function WSJ1003:setData(data)
    -- printt("兑换",data)
    self.data = data
    self.confData = conf.WSJConf:getExchageAward()
    self.listView.numItems = #self.confData
    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)

    local severTime = mgr.NetMgr:getServerTime()
    self.leftTime = data.actEndTime - severTime
    self.leftTimeTxt.text = language.kaifu15 .. GGetTimeData2(self.leftTime)

end

function WSJ1003:onTimer()
    if not self.data then return end
    if self.leftTime then
        self.leftTime = self.leftTime - 1
        self.leftTimeTxt.text = language.kaifu15 .. GGetTimeData2(self.leftTime)
        if self.leftTime <= 0 then
            self.mParent:closeView()
        end
    end
end


function WSJ1003:cellData(index,obj )
    local data = self.confData[index+1]
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
        local color = hasAmount >= needAmount and 10 or 14
        local textData = {
            {text = hasAmount,color = color},
            {text = "/"..needAmount,color = 10},
        }
        numTxt.text = mgr.TextMgr:getTextByTable(textData)
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

function WSJ1003:onClickGet( context )
    local data = context.sender.data
    if data.flag then
        proxy.WSJProxy:sendMsg(1030644,{reqType = 1,cid = data.cid})
    else
        if self.data.canExchangeTimes[data.cid] > 0 then
            GComAlter(language.wsj07)
        else
            GComAlter(language.dailyactive07)
        end
    end
end






return WSJ1003