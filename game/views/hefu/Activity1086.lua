--
-- Author: Your Name
-- Date: 2018-06-20 21:08:22
--

local Activity1086 = class("Activity1086",import("game.base.Ref"))

function Activity1086:ctor(param)
    self.view = param
    self:initView()
end

function Activity1086:initView()
    self.guizeBtn = self.view:GetChild("n14")
    self.guizeBtn.onClick:Add(self.onClickGuize,self)
    self.listView1 = self.view:GetChild("n1")
    self.listView1.numItems = 0

    self.listView2 = self.view:GetChild("n8")
    self.listView2.numItems = 0

    self.awardsList = self.view:GetChild("n5")
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function (index,obj)
        self:awardsCell(index, obj)
    end
    self.redBagList1 = {}
    self.redBagList2 = {}

    self.timeTxt = self.view:GetChild("n11")
    self.numTxt = self.view:GetChild("n13")
    self.todayCost = self.view:GetChild("n4")
    self.dec = self.view:GetChild("n3")
    self.dec.text = language.redbag21
    self.c1 = self.view:GetController("c1")

    self.getBtn = self.view:GetChild("n6")
    self.getBtn.onClick:Add(self.onClickGet,self)
end

function Activity1086:initListView(listView,listData)
    listView.numItems = 0
    for i=1,#listData do
        local objItemUrl = UIPackage.GetItemURL("hefu" , "ItemRedBag1")
        if listData[i].day == self.data.curDay then--当前天
            objItemUrl = UIPackage.GetItemURL("hefu" , "ItemRedBag2")
        end
        local obj = listView:AddItemFromPool(objItemUrl)
        local dayTxt = obj:GetChild("n4")
        local ybNumTxt = obj:GetChild("n5")
        local decTxt = obj:GetChild("n6")
        dayTxt.text = listData[i].day
        ybNumTxt.text = listData[i].value
        if listData[i].day == self.data.curDay then
            decTxt.text = language.redbag16
        elseif listData[i].day < self.data.curDay then
            decTxt.text = language.redbag15
        else
            decTxt.text = language.redbag17
        end
    end
end

function Activity1086:awardsCell(index,obj)
    local data = self.awardsConf[index+1]
    if data then
        local mId = data[1]
        local amount = data[2]
        local bind = data[3]
        local itemInfo = {mid = mId,amount = amount,bind = bind}
        GSetItemData(obj, itemInfo, true)
    end
end

function Activity1086:onTimer()
    if not self.data then
        return
    end
    self.leftTime = self.leftTime - 1
    if self.leftTime > 0 then
        self.timeTxt.text = GGetTimeData2(self.leftTime)
    else
        self.timeTxt.text = language.acthall02
    end
end

function Activity1086:setCurId(id)
    -- body
    self.id = id
    
end

function Activity1086:setOpenDay( day )
    -- body
    
end

function Activity1086:onClickGuize()
    GOpenRuleView(1090)
end

function Activity1086:onClickGet()
    local needYb = conf.ActivityConf:getHolidayGlobal("red_bag_award_con")[self.data.curDay]
    if self.data.dayCostYb >= needYb then
        if self.data.awardGotSign > 0 then
            GComAlter(language.redbag20)
        else
            proxy.ActivityProxy:sendMsg(1030403, {reqType = 1})
        end
    else
        GComAlter(language.redbag19)
    end
end

-- int8
-- 变量名：reqType 说明：0:显示 1:领取目标奖励
-- map<int32,int32>
-- 变量名：redBags 说明：红包信息,key:第几天,value:存入金额
-- int32
-- 变量名：leftTime    说明：活动剩余时间
-- int32
-- 变量名：redBagSum   说明：红包总额
-- int32
-- 变量名：dayCostYb   说明：今日消费元宝
-- array<SimpleItemInfo>   变量名：items   说明：获得的奖励
-- int32
-- 变量名：awardGotSign    说明：奖励获取标识,>0已领取
-- int32
-- 变量名：curDay  说明：当前第几天
function Activity1086:add5030403(data)
    self.data = data
    printt("红包返还活动",data)
    self.leftTime = self.data.leftTime
    self.timeTxt.text = GGetTimeData2(self.leftTime)
    self.numTxt.text = self.data.redBagSum

    local t = clone(language.redbag18)
    local needYb = conf.ActivityConf:getHolidayGlobal("red_bag_award_con")[data.curDay]
    t[1].text = string.format(language.redbag18[1].text,data.dayCostYb)
    t[2].text = string.format(language.redbag18[2].text,needYb)
    if data.dayCostYb < needYb then
        t[1].color = 14
        self.c1.selectedIndex = 0
    else
        if data.awardGotSign <= 0 then
            self.c1.selectedIndex = 1
        else
            self.c1.selectedIndex = 2
        end
        t[1].color = 7
    end
    self.todayCost.text = mgr.TextMgr:getTextByTable(t)

    self.redBagList1 = {}
    self.redBagList2 = {}
    for k,v in pairs(data.redBags) do
        if k <= 3 then
            table.insert(self.redBagList1,{day = k,value = v})
        else
            table.insert(self.redBagList2,{day = k,value = v})
        end
    end
    table.sort(self.redBagList1,function(a,b)
        if a.day ~= b.day then
            return a.day < b.day
        end
    end)
    table.sort(self.redBagList2,function(a,b)
        if a.day ~= b.day then
            return a.day < b.day
        end
    end)

    self:initListView(self.listView1,self.redBagList1)
    self:initListView(self.listView2,self.redBagList2)

    --每日返还领取奖励
    local confData = conf.ActivityConf:getHolidayGlobal("red_bag_item")
    self.awardsConf = confData[data.curDay] or {}
    self.awardsList.numItems = #self.awardsConf
end



return Activity1086