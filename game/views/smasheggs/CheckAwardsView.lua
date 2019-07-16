--
-- Author: Your Name
-- Date: 2017-09-21 15:19:32
--

local CheckAwardsView = class("CheckAwardsView", base.BaseView)

function CheckAwardsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function CheckAwardsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    self.accumulateList = self.view:GetChild("n5")
    self.accumulateList.numItems = 0
    self.accumulateList.itemRenderer = function (index,obj)
        self:celldata1(index, obj)
    end
    self.historyList = self.view:GetChild("n4")
    self.historyList.numItems = 0
    self.historyList.itemRenderer = function (index,obj)
        self:celldata2(index, obj)
    end
end

--累积奖励
function CheckAwardsView:celldata1( index, obj )
    local data = self.accumulateData[index+1]
    if data then--language.active31
        local decTxt = obj:GetChild("n1")
        local textData = {
                            {text = language.active31[1],color = 6},
                            {text = self.currCount,color = 7},
                            {text = string.format(language.active31[2],data.count),color = 6},
                        }
        decTxt.text = mgr.TextMgr:getTextByTable(textData)
        local list = obj:GetChild("n2")
        list.numItems = 0
        for k,v in pairs(data.rewards) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local Item = list:AddItemFromPool(url)
            local info = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(Item,info,true)
        end
        local getBtn = obj:GetChild("n3")
        local canGet = false
        local c1 = obj:GetController("c1")

        local flag = false
        for k,v in pairs(self.cumulateList) do
            if v == data.id then
                flag = true
                break
            end
        end
        if self.currCount >= data.count and not flag then
            canGet = true
            c1.selectedIndex = 0
        else
            if flag then
                c1.selectedIndex = 2
            else
                c1.selectedIndex = 1
            end
            canGet = false
        end
        getBtn.data = {tarId = data.id,canGet = canGet}
        getBtn.onClick:Add(self.onClickGet,self)
    end
end
--历史获得奖励
function CheckAwardsView:celldata2( index, obj )
    local data = self.history[index+1]
    if data then
        local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
        local info = {mid = data.mid,amount = data.amount,bind = data.bind}
        GSetItemData(obj,info,true)
    end
end

function CheckAwardsView:onController1()
    if self.c1.selectedIndex == 0 then
        self.accumulateList.numItems = #self.accumulateData
    else
        self.historyList.numItems = #self.history
    end
end

function CheckAwardsView:initData(data)
    self.history = data.history
    self.currCount = data.currCount --砸蛋次数
    self.cumulateList = data.cumulateList--累计奖励已领取列表
    self.accumulateData = conf.ActivityConf:getAccumulateData()
    self:sort()
    self.accumulateList.numItems = #self.accumulateData
    self.c1.selectedIndex = 0
end

function CheckAwardsView:sort()
    for k,v in pairs(self.accumulateData) do
        if self.cumulateList[v] then
            self.accumulateData[k].sortindex = 2
        else
            self.accumulateData[k].sortindex = 1
        end
    end
    table.sort(self.accumulateData,function(a,b)
        if a.sortindex ~= b.sortindex then
            return a.sortindex < b.sortindex
        else
            return a.id < b.id
        end
    end)
end

function CheckAwardsView:refreshView( data )
    self.cumulateList = data.cumulateList
    self:sort()
    self.accumulateList.numItems = #self.accumulateData
end

function CheckAwardsView:onClickGet(context)
    local data = context.sender.data
    if data.canGet then
        proxy.ActivityProxy:sendMsg(1030209,{reqType = 6,tarId = data.tarId})
    else
        GComAlter(language.active32)
    end
end

function CheckAwardsView:onClickClose()
    self:closeView()
end

return CheckAwardsView