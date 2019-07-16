--
-- Author: 
-- Date: 2018-12-17 22:24:21
--

local YuanDanQiFuView = class("YuanDanQiFuView", base.BaseView)

local table = table
function YuanDanQiFuView:ctor()
    YuanDanQiFuView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function YuanDanQiFuView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    local dec1 = self.view:GetChild("n4")
    dec1.text = language.ydqf01

    local dec2 = self.view:GetChild("n12")
    dec2.text = language.ydqf02

    self.logsList = self.view:GetChild("n9")
    self.logsList.itemRenderer = function(index,obj)
        self:cellLogData(index, obj)
    end
    self.logsList:SetVirtual()

    self.lastTime = self.view:GetChild("n3")

    local ruleBtn = self.view:GetChild("n43")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    self.bar = self.view:GetChild("n5") 
    self.bar.value = 0
    --赠送
    self.giveList = {}
    --进度
    self.rateList = {}
    for i=1,6 do
        local rate = self.view:GetChild("n"..(i+18))
        rate.data = i
        table.insert(self.rateList,rate) 
        local com = self.view:GetChild("n"..(i+24))
        com.data = i
        table.insert(self.giveList,com) 
    end

    local oneCost = conf.YuanDanConf:getValue("ny_blessing_one_cost")
    local tenCost = conf.YuanDanConf:getValue("ny_blessing_ten_cost")

    local btn1 = self.view:GetChild("n40")
    btn1.title = oneCost[2]
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn2 = self.view:GetChild("n41")
    btn2.title = tenCost[2]
    btn2.onClick:Add(self.onBtnCallBack,self)

    self.showList = self.view:GetChild("n15")
    self.showList.itemRenderer = function(index,obj)
        self:cellShowData(index, obj)
    end
    self.showList:SetVirtual()

    --兑换列表 
    self.changeList = self.view:GetChild("n52")
    self.changeList.itemRenderer = function(index,obj)
        self:cellChangeData(index, obj)
    end
    self.changeList:SetVirtual()

    self.myShuiJing =  self.view:GetChild("n56")

    self.ybTxt =  self.view:GetChild("n45")

    self.view:GetChild("n57").text = language.ydqf04

end


function YuanDanQiFuView:initData()
    local barData = conf.YuanDanConf:getValue("ny_blessing")
    for k,v in pairs(barData) do
        local rate = self.rateList[k]
        rate.text = rate and v[1] or ""
        local give = self.giveList[k]
        give:GetChild("n27").text = give and v[2] or ""
    end


    self.showAwardConfData = conf.YuanDanConf:getValue("ydqf_show_award")
    self.showList.numItems = #self.showAwardConfData

    self.bar.max = conf.YuanDanConf:getValue("ny_blessing_clear")

    local value = conf.YuanDanConf:getValue("ydqf_blessing_value")
    self.view:GetChild("n37").text = value[1]
    self.view:GetChild("n38").text = value[2]

   


end

function YuanDanQiFuView:addMsgCallBack(data)
    -- printt("元旦祈福",data)
    self.data = data
    self.time = data.leftTime
    --元宝
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    self.ybTxt.text = ybData.amount
    --水晶
    self.myShuiJing .text = data.crystals
    self.bar.value = data.blessValue


    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

    self.logsList.numItems = #data.logs

     local conf = conf.YuanDanConf:getQiFuDataByType(2)
    self.confData ={}
    for i=1,math.ceil(#conf / 4) do--4个一组
        self.confData[i] = {}
    end
    for k,v in pairs(self.confData) do
        for i,j in pairs(conf) do
            if math.ceil(i/4) == k then
                table.insert(self.confData[k],j)
            end
        end
    end

    self.changeList.numItems = #self.confData
end


function YuanDanQiFuView:cellChangeData(index,obj)
    local comList  = {}
    for i=1,4 do
        local com = obj:GetChild("n"..i)
        table.insert(comList,com)
    end
    local data = self.confData[index+1]
    if data then
        for k,com in pairs(comList) do--com:组件
            local mData = data[k]
            if mData then
                com.visible = true
                local itemData = {mid = mData.items[1][1],amount = mData.items[1][2],bind = mData.items[1][3]}
                GSetItemData(com:GetChild("n0"), itemData, true)
                local changeTimes = self.data 
                    and self.data.exchangeMap and  
                    self.data.exchangeMap[mData.id] and 
                    tonumber(mData.limit_times)-tonumber(self.data.exchangeMap[mData.id]) or mData.limit_times
                com:GetChild("n1").text = "限兑"..changeTimes.."/"..mData.limit_times
                com:GetChild("n3").text = mData.cost
                local changeBtn = com:GetChild("n4")
                changeBtn.grayed = self.data.crystals < mData.cost
                if changeTimes <= 0 then
                    changeBtn.grayed  = true
                end
                if not changeBtn.grayed then
                    changeBtn:GetChild("red").visible = true
                else
                    changeBtn:GetChild("red").visible = false
                end
                changeBtn.data = {limtTimes =changeTimes,mData = mData}
                changeBtn.onClick:Add(self.onClickChangebtn,self)
            else
                com.visible = false
            end
        end
    end
 
end
function YuanDanQiFuView:onClickChangebtn(context)
    local btn = context.sender
    local data = btn.data
    local mData = data.mData
    if data.limtTimes <= 0 then
        GComAlter(language.ydqf03)
    else
        if self.data.crystals < mData.cost then
            GComAlter(language.ydqf05)
        else
            proxy.YuanDanProxy:sendMsg(1030680,{reqType = 3,cid = mData.id})
        end
    end

end
function YuanDanQiFuView:cellShowData(index,obj)
    local data = self.showAwardConfData[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemData, true)
    end
end
function YuanDanQiFuView:cellLogData(index, obj)
    local data = self.data.logs[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.houWang04, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

function YuanDanQiFuView:onBtnCallBack(context)
    if not self.data then return end
    local btn = context.sender
    local reqType = 0
    if "n40" == btn.name then
        reqType = 1
    elseif "n41" == btn.name then
        reqType = 2
    end 
    proxy.YuanDanProxy:sendMsg(1030680,{reqType = reqType,cid = 0})
end


function YuanDanQiFuView:onClickRule()
    GOpenRuleView(1167)
end


function YuanDanQiFuView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GGetTimeData2(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
    end
    self.time = self.time - 1
end

function YuanDanQiFuView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

return YuanDanQiFuView