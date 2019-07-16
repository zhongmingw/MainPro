--
-- Author: Your Name
-- Date: 2018-09-18 14:38:56
--充值大礼
local Gq1002 = class("Gq1002",import("game.base.Ref"))

function Gq1002:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Gq1002:onTimer()
    -- body
    if not self.data then return end
end

-- 变量名：reqType 说明：0：显示 1：领取首充 2：领取累充
-- 变量名：firstRechargeSign   说明：每日首充领取标识
-- 变量名：accumulateRecharge  说明：每日累充领取标识
-- 变量名：czSums  说明：每日充值的元宝数
-- array<SimpleItemInfo>   变量名：items   说明：奖励
-- 变量名：curDay  说明：当前第几天 从1开始
-- 变量名：actStartTime    说明：活动开始时间
-- 变量名：actEndTime  说明：活动结束时间
function Gq1002:addMsgCallBack(data)
    -- body
    printt("充值大礼",data)
    self.curDay = data.curDay
    self.sumCzNum.text = data.czSums
    local firstId = 10000+self.curDay
    local firstRechargeData = conf.GuoQingConf:getRechargeAwards(firstId)
    if firstRechargeData then
        self.firstRechargeAwards = firstRechargeData.items
        self.listView1.numItems = #self.firstRechargeAwards
    end
    local sumId = 20000+self.curDay
    local sumRechargeData = conf.GuoQingConf:getRechargeAwards(sumId)
    if sumRechargeData then
        self.sumRechargeAwards = sumRechargeData.items
        self.listView2.numItems = #self.sumRechargeAwards
        self.quotaTxt.text = sumRechargeData.quota
    end
    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)

    local btn1State = self.getBtn1:GetController("c1")
    local btn2State = self.getBtn2:GetController("c1")
    if data.firstRechargeSign == 0 then--可领取
        self.getBtn1.title = language.friend22
        if data.czSums > 0 then
            btn1State.selectedIndex = 0
        else
            btn1State.selectedIndex = 1
        end
    else--已领取
        self.getBtn1.title = language.yqs08
        btn1State.selectedIndex = 2
    end

    if data.accumulateRecharge == 0 then--未领取
        self.getBtn2.title = language.friend22
        if sumRechargeData.quota > data.czSums then--不可领取
            btn2State.selectedIndex = 1
        else--可领取
            btn2State.selectedIndex = 0
        end
    else--已领取
        self.getBtn2.title = language.yqs08
        btn2State.selectedIndex = 2
    end

    self.getBtn1.data = {state = btn1State.selectedIndex,reqType = 1}
    self.getBtn2.data = {state = btn2State.selectedIndex,reqType = 2}
    self.getBtn1.onClick:Add(self.onClickGet,self)
    self.getBtn2.onClick:Add(self.onClickGet,self)
end

function Gq1002:onClickGet(context)
    local data = context.sender.data
    local state = data.state
    local reqType = data.reqType
    if state == 1 then
        if reqType == 1 then
            GComAlter(language.gq02)
        else
            GComAlter(string.format(language.gq03,self.quotaTxt.text))
        end
        return
    elseif state == 2 then
        GComAlter(language.czccl07)
    end
    proxy.GuoQingProxy:sendMsg(1030618,{reqType = reqType})
end

function Gq1002:initView()
    -- body
    local c1 = self.view:GetController("c1")
    c1.selectedIndex = 1
    self.panel = self.view:GetChild("n8")

    self.timeTxt = self.view:GetChild("n4")
    self.decTxt = self.view:GetChild("n5")
    self.decTxt.text = language.gq14

    --累充领取额度限制
    self.quotaTxt = self.panel:GetChild("n20")
    self.sumCzNum = self.panel:GetChild("n23")

    --首充奖励列表
    self.listView1 = self.panel:GetChild("n5")
    self.listView1.numItems = 0
    self.listView1.itemRenderer = function (index,obj)
        self:cell1data(index, obj)
    end
    self.listView1:SetVirtual()
    self.getBtn1 = self.panel:GetChild("n6")

    --累充奖励列表
    self.listView2 = self.panel:GetChild("n13")
    self.listView2.numItems = 0
    self.listView2.itemRenderer = function (index,obj)
        self:cell2data(index, obj)
    end
    self.listView2:SetVirtual()
    self.getBtn2 = self.panel:GetChild("n14")
end

function Gq1002:cell1data( index,obj )
    local data = self.firstRechargeAwards[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,itemInfo,true)
    end
end

function Gq1002:cell2data( index,obj )
    local data = self.sumRechargeAwards[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,itemInfo,true)
    end
end

return Gq1002