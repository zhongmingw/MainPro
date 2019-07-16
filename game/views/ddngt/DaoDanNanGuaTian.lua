--
-- Author: 
-- Date: 2018-10-22 17:16:51
--

local DaoDanNanGuaTian = class("DaoDanNanGuaTian", base.BaseView)

function DaoDanNanGuaTian:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end

function DaoDanNanGuaTian:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n6")
    self:setCloseBtn(closeBtn)
    self.actCountDownText = self.view:GetChild("n7")

    self.awardList = self.view:GetChild("n9")
    self.awardList.itemRenderer = function (index,obj)
        self:setAwardData(index,obj)
    end
    self.awardList.numItems = 0
    self.awardList:SetVirtual()

    self.recordList = self.view:GetChild("n12")
    self.recordList.itemRenderer = function (index,obj)
        self:setRecordData(index,obj)
    end
    self.recordList.numItems = 0
    self.recordList:SetVirtual()

    self.pumpkinList = {}
    for i = 39,47 do
        local pumpkin = self.view:GetChild("n"..i)
        pumpkin.data = i - 38
        table.insert(self.pumpkinList,pumpkin)
        pumpkin.onClick:Add(self.pumpkinClick,self)
    end

    for k,v in pairs(self.pumpkinList) do
        self.pumpkinList[k]:GetTransition("t1"):Play()
    end

    self.driveCostText = self.view:GetChild("n15")
    self.driveAllBtn = self.view:GetChild("n1") -- 一键驱除
    self.driveAllBtn.onClick:Add(self.btnOnClick,self)

    self.effectImg = self.view:GetChild("n60") -- 掉糖果特效

    self.effectList = {} -- 砸南瓜特效
    for i = 51,59 do
        local effect = self.view:GetChild("n"..i)
        table.insert(self.effectList,effect)
    end
end

--[[
变量名：reqType  说明：0：显示 1：抽一次 2：抽完
变量名：site     说明：位置（1-9）
变量名：items    说明：获得的奖励
变量名：leftTime 说明：活动剩余时间
变量名：gotSite  说明：已经抽取的位置
变量名：logs     说明：日志记录
变量名：dataIds  说明：获得的奖励id
--]]
function DaoDanNanGuaTian:setData(data)
    self.data = data    
    -- printt("捣蛋南瓜田>>>",data)
    if data.reqType == 2 then
        GOpenAlert3(data.items)
    end
    self.actCountDown = data.leftTime
    self.confData = conf.WSJConf:getNanGuaAward()
    self.confData1 = conf.WSJConf:getNanGua()
    self.constData = conf.WSJConf:getValue("halloween_lottery_cost")
    self.allCost = conf.WSJConf:getValue("halloween_lottery_num")
    self.oneCost = self.constData[2]
    self.awardList.numItems = #self.confData
    self.recordList.numItems = #data.logs

    self.leftPumpkinCount = 0 -- 剩余的南瓜数量
    self.leftPumpkinCount = self.allCost - #data.gotSite
    self.driveCostText.text = self.oneCost

    local flag 
    if #data.dataIds ~= 0 then
        -- print("获得的奖励id>>>",data.dataIds[1])
        flag = self:setFlag(data.dataIds[1])
    end
    -- print(flag)
    for k,v in pairs(data.gotSite) do
        for i,j in pairs(self.pumpkinList) do
            self.pumpkinList[v].touchable = false
            self.pumpkinList[v]:GetChild("icon").url = UIPackage.GetItemURL("ddngt" , "daodannangua_012")
        end
    end

    local curPumpkin = self.pumpkinList[data.site]
    if data.site ~= 0 then
        self.effect = self:addEffect(4020213, self.effectList[data.site])
        if flag then -- 低级奖励
            self:addTimer(0.5, 1, function ()
                GOpenAlert3(data.items) 
            end)
            curPumpkin:GetChild("icon").url = UIPackage.GetItemURL("ddngt" , "daodannangua_012")
        else
            self:addTimer(1.5, 1, function ()
                GOpenAlert3(data.items) 
            end)
            self.effect = self:addEffect(4020214, self.effectImg)
            self.effect.LocalPosition = Vector3.New(241,-120,0)
            curPumpkin.visible = false
        end
        self.pumpkinList[data.site].touchable = false
    end
    if #data.gotSite == 0 and data.reqType ~= 0 then
        for k,v in pairs(self.pumpkinList) do
            v.visible = true
            v:GetChild("icon").url = UIPackage.GetItemURL("ddngt" , "daodannangua_011")
            v:GetTransition("t1"):Play()
            v.touchable = true
        end
    end

    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function DaoDanNanGuaTian:setFlag(dataId)
    local flag = false
    for k,v in pairs(self.confData1) do
        if v.id == dataId and v.type == 1 then
            -- print("低级奖励>>>",v.type)
            flag = true
        elseif v.id == dataId and v.type == 2 then
            -- print("高级奖励>>>",v.type)
            flag = false
        end
    end
    return flag
end

function DaoDanNanGuaTian:setAwardData(index,obj)
    local awardData = self.confData[index+1]
    local data = {}
    if awardData then
        data = {mid = awardData.items[1],amount = awardData.items[2],bind = awardData.items[2]}
        GSetItemData(obj, data, true)
    end
end

function DaoDanNanGuaTian:setRecordData(index,obj)
    if not self.data then return end
    local recordIndex = index + 1
    if self.data.logs then
        local recordData = self.data.logs[recordIndex]
        local splitData = string.split(recordData,ChatHerts.SYSTEMPRO)
        local itemName = conf.ItemConf:getName(splitData[2])
        local table = {
                {text = splitData[1],color = 25},
                {text = language.ddng01,color = 0},                
                {text = itemName,color = 26},
                {text = splitData[3],color = 26},
            }
        local recordText = mgr.TextMgr:getTextByTable(table)
        local recordItem = obj:GetChild("n1")
        recordItem.text = recordText
    end
end

function DaoDanNanGuaTian:pumpkinClick(context)
    local btn = context.sender
    local btnData = btn.data
    local ingots = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if ingots >= self.oneCost then
        -- print("已驱赶的南瓜>>>",btnData)
        proxy.ActivityProxy:sendMsg(1030640,{reqType = 1,site = btnData})
    else
        GOpenView({id = 1042})
        self:closeView()
        return
    end
end

function DaoDanNanGuaTian:btnOnClick()
    local ingots = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if ingots >= (self.oneCost*self.leftPumpkinCount) then
        proxy.ActivityProxy:sendMsg(1030640,{reqType = 2}) 
    else
        GOpenView({id = 1042})
        self:closeView()
        return
    end
end

function DaoDanNanGuaTian:onTimer()
    if not self.data then return end
    self.actCountDown = math.max(self.actCountDown - 1,0)
    if self.actCountDown <= 0 then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
        self:closeView()
        return
    end
    if self.actCountDown >= 86400 then
        self.actCountDownText.text = GGetTimeData3(self.actCountDown)
    else
        self.actCountDownText.text = GGetTimeData4(self.actCountDown)        
    end
end

return DaoDanNanGuaTian