--
-- Author: Your Name
-- Date: 2018-09-18 14:38:56
--消费豪礼
local Gq1003 = class("Gq1003",import("game.base.Ref"))

function Gq1003:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Gq1003:onTimer()
    -- body
    if not self.data then return end
end

-- 变量名：reqType 说明：0：显示 1：领取 2：购买
-- 变量名：numSigns    说明：还可以领取购买的次数（上限）
-- 变量名：needConsumeNum  说明：还需消耗的元宝数
-- 变量名：leftReceiveTimes    说明：剩余可领取次数
-- array<SimpleItemInfo>   变量名：items   说明：奖励
-- 变量名：curDay  说明：当前第几天 从1开始
-- 变量名：actStartTime    说明：活动开始时间
-- 变量名：actEndTime  说明：活动结束时间
function Gq1003:addMsgCallBack(data)
    -- body
    printt("消费豪礼",data)
    self.data = data
    self.curDay = data.curDay
    local costId = 10000*self.curDay + 1
    local costWelfareData = conf.GuoQingConf:getCostGiftAwards(costId)
    if costWelfareData then
        self.costWelfareAwards = costWelfareData.items
        self.listView1.numItems = #self.costWelfareAwards
        local textData1 = clone(language.gq04)
        textData1[1].text = string.format(textData1[1].text,costWelfareData.quota)
        self.costTxt1.text = mgr.TextMgr:getTextByTable(textData1)
        local textData2 = clone(language.gq05)
        if data.needConsumeNum > 0 then
            textData2[2].text = string.format(textData2[2].text,data.leftReceiveTimes)
            textData2[4].text = string.format(textData2[4].text,data.needConsumeNum)
        else
            textData2 = clone(language.gq05_1)
            textData2[2].text = string.format(textData2[2].text,data.leftReceiveTimes)
        end
        self.costTxt2.text = mgr.TextMgr:getTextByTable(textData2)
        local textData3 = clone(language.gq06)
        local leftCount = costWelfareData.times - data.numSigns[costId]
        textData3[2].text = string.format(textData3[2].text,leftCount,costWelfareData.times)
        self.costTxt3.text = mgr.TextMgr:getTextByTable(textData3)

        local btn1State = self.getBtn1:GetController("c1")
        if data.numSigns[costId] > 0 then--可领取
            self.getBtn1.title = language.friend22
            if data.leftReceiveTimes > 0 then
                btn1State.selectedIndex = 0
            else
                btn1State.selectedIndex = 1
            end
        else--领取次数已满
            self.getBtn1.title = language.yqs08
            btn1State.selectedIndex = 2
        end
        self.getBtn1.data = {state = btn1State.selectedIndex,reqType = 1}
        self.getBtn1.onClick:Add(self.onClickGet,self)
    end
    local giftId = 10000*self.curDay + 2
    local giftData = conf.GuoQingConf:getCostGiftAwards(giftId)
    if giftData then
        self.giftAwards = giftData.items
        self.listView2.numItems = #self.giftAwards
        local textData1 = clone(language.gq07)
        self.giftTxt1.text = mgr.TextMgr:getTextByTable(textData1)

        self.giftTxt2.text = data.numSigns[giftId] .. language.welfare25[2]

        local btn2State = self.getBtn2:GetController("c1")
        if data.numSigns[giftId] > 0 then--可购买
            btn2State.selectedIndex = 0
        else--购买次数已满
            btn2State.selectedIndex = 1
        end
        self.getBtn2:GetChild("red").visible = false
        self.getBtn2.title = string.format(language.gq10,giftData.quota)
        self.getBtn2.data = {state = btn2State.selectedIndex,reqType = 2}  
        self.getBtn2.onClick:Add(self.onClickGet,self)
    end

    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)
    
    


end

function Gq1003:onClickGet(context)
    local data = context.sender.data
    local state = data.state
    local reqType = data.reqType
    if state == 1 then
        if reqType == 1 then
            GComAlter(string.format(language.gq08,self.data.needConsumeNum))
        else
            GComAlter(language.gq09)
        end
        return
    elseif state == 2 then
        return
    end
    if reqType == 2 then
        local giftId = 10000*self.curDay + 2
        local giftData = conf.GuoQingConf:getCostGiftAwards(giftId)
        local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        if giftData.quota > myYb then
            GComAlter(language.gonggong18)
            return
        end
    end
    proxy.GuoQingProxy:sendMsg(1030619,{reqType = reqType})
end

function Gq1003:initView()
    -- body
    local c1 = self.view:GetController("c1")
    c1.selectedIndex = 2
    self.panel = self.view:GetChild("n9")

    self.timeTxt = self.view:GetChild("n4")
    self.decTxt = self.view:GetChild("n5")
    self.decTxt.text = language.gq15

    --消费福利列表
    self.listView1 = self.panel:GetChild("n24")
    self.listView1.numItems = 0
    self.listView1.itemRenderer = function (index,obj)
        self:cell1data(index, obj)
    end
    self.listView1:SetVirtual()
    self.getBtn1 = self.panel:GetChild("n6")

    --节日礼包列表
    self.listView2 = self.panel:GetChild("n25")
    self.listView2.numItems = 0
    self.listView2.itemRenderer = function (index,obj)
        self:cell2data(index, obj)
    end
    self.listView2:SetVirtual()
    self.getBtn2 = self.panel:GetChild("n14")

    self.costTxt1 = self.panel:GetChild("n17")
    self.costTxt2 = self.panel:GetChild("n18")
    self.costTxt3 = self.panel:GetChild("n19")
    self.giftTxt1 = self.panel:GetChild("n21")
    self.giftTxt2 = self.panel:GetChild("n23")

end

function Gq1003:cell1data( index,obj )
    local data = self.costWelfareAwards[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,itemInfo,true)
    end
end

function Gq1003:cell2data( index,obj )
    local data = self.giftAwards[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,itemInfo,true)
    end
end

return Gq1003