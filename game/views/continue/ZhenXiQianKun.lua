--
-- Author: 
-- Date: 2018-09-26 11:32:36
--

local ZhenXiQianKun = class("ZhenXiQianKun", base.BaseView)

function ZhenXiQianKun:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ZhenXiQianKun:initView()
    self.closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(self.closeBtn)
    self.awardListView = self.view:GetChild("n9")

    self.awardListView.itemRenderer = function (index,obj)
        self:setAward(index,obj)
    end
    self.awardListView:SetVirtual()
    self.awardListView.numItems = 0
    self.lotteryList = {}
    for i = 11,20 do 
        local item = self.view:GetChild("n"..i)
        table.insert(self.lotteryList, item)
    end

    self.actCountTimeText = self.view:GetChild("n36")
    self.getBtn = self.view:GetChild("n23")
    self.getBtn.onClick:Add(self.btnOnClick,self)
    self.getAllBtn = self.view:GetChild("n25")
    self.getAllBtn.onClick:Add(self.btnOnClick,self)
    self.refreshBtn = self.view:GetChild("n38")
    self.refreshBtn.onClick:Add(self.btnOnClick,self)
    self.ruleBtn = self.view:GetChild("n42")
    self.ruleBtn.onClick:Add(self.btnOnClick,self)

    self.cancelAct = self.view:GetChild("n40")
    self.guangXiao = self.view:GetChild("n48")

    self.oneCostText = self.view:GetChild("n29")
    self.allCostText = self.view:GetChild("n33")
    self.refreshCostText = self.view:GetChild("n37")
end

function ZhenXiQianKun:initData()
    self:setBtnClickState(true)
    self.guangXiao.visible = false
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

    -- print("重开界面,下一次抽奖的起始位置id>>>",self.startPos)
end

--[[
变量名：reqType     说明：0：显示 1：抽一次 2：抽完 3：刷新
变量名：leftTime    说明：活动剩余时间
变量名：curItems    说明：当前轮的道具id
变量名：leftItems   说明：剩余的道具id
变量名：items       说明：获得的道具
变量名：cfgId       说明：当前的格子id（配置id）
--]]
function ZhenXiQianKun:setData(data)
    
    if data.reqType == 0 and not self.startPos then
        self.startPos = data.cfgId -- 下一次抽奖的起始位置
    end

    self.data = data
    -- printt("珍稀乾坤>>>",data)
    self.actCountTime = data.leftTime
    self.lotteryAwardConf = conf.ActivityConf:getZxqk()
    self.awardConf = conf.ActivityConf:getValue("zxqk_award_show")
    local oneCost = conf.ActivityConf:getValue("zxqk_one_cost")
    self.oneCostText.text = oneCost[2]
    self.allCostText.text = oneCost[2] * #data.leftItems
    local refreshCost = conf.ActivityConf:getValue("zxqk_refresh_cost")
    self.refreshCostText.text = string.format(language.zxqk4,refreshCost[2])
    self:setLotteryAward()

    self.awardListView.numItems = #self.awardConf
    if data.reqType == 0 then
        self:setState()
    elseif data.reqType == 1 then
        if data.cfgId == 0 then
            self.startPos = data.cfgId
            self:addTimer(0.2, 1, function ()
                GOpenAlert3(self.data.items)          
            end)
            self:addTimer(0.5, 1, function ()
                self:setState()
                self.guangXiao.xy = self.lotteryList[1].xy
            end)
        else
            self:turn()
        end
    elseif data.reqType == 2 then
        GOpenAlert3(data.items)
        self:setState()
        self.guangXiao.xy = self.lotteryList[1].xy  
    elseif data.reqType == 3 then
        self:setState() 
    end
    self.leftItems = data.leftItems
end

function ZhenXiQianKun:btnOnClick(context)
    local btn = context.sender
    if cache.PlayerCache:getTypeMoney(MoneyType.gold) <= 0 then
        GOpenView({id = 1042})--前往充值
        return
    end
    if btn.name == "n23" then -- 立即抽奖
        proxy.ActivityProxy:sendMsg(1030626,{reqType = 1})
    elseif btn.name == "n25" then -- 抽完
        proxy.ActivityProxy:sendMsg(1030626,{reqType = 2})
    elseif btn.name == "n38" then -- 刷新
        proxy.ActivityProxy:sendMsg(1030626,{reqType = 3})
    elseif btn.name == "n42" then -- 查看帮助
        GOpenRuleView(1147)
    end
end

function ZhenXiQianKun:setAward(index,obj)
    local awardData = self.awardConf[index+1]
    local itemObj = obj:GetChild("n3")
    local itemName= obj:GetChild("n2")
    local data = {}
    data.mid = awardData[1]
    data.amount = awardData[2]
    data.bind = awardData[3]
    if awardData[5] and awardData[5] == 1 then
        data.isquan = false
    else
        data.isquan = true
    end
    GSetItemData(itemObj, data, true)
    local name = conf.ItemConf:getName(awardData[1])
    local itemColor = conf.ItemConf:getQuality(awardData[1])
    itemName.text = mgr.TextMgr:getQualityStr1(name,itemColor)
end

function ZhenXiQianKun:setLotteryAward()
    local randomAwardConf = self:getRandomAward()
    for k,v in pairs(randomAwardConf) do
        self.lotteryList[k].data = v.id
        local awardItem = self.lotteryList[k]
        local itemObj = awardItem:GetChild("n3")
        local itemName= awardItem:GetChild("n2")
        local data = {}
        data.mid = v.items[1]
        data.amount = v.items[2]
        data.bind = v.items[3]
        if v.zq and v.zq == 1 then
            data.isquan = false
        else
            data.isquan = true
        end
        GSetItemData(itemObj, data, true)
        local name = conf.ItemConf:getName(v.items[1])
        local itemColor = conf.ItemConf:getQuality(v.items[1])
        itemName.text = mgr.TextMgr:getQualityStr1(name,itemColor)
    end
end

--设置格子状态
function ZhenXiQianKun:setState()
    for k,v in pairs(self.lotteryList) do
        if self:isGet(v.data) then
            v:GetController("c1").selectedIndex = 2
        else
            v:GetController("c1").selectedIndex = 0
        end
    end
end

--当前id是否被抽过
function ZhenXiQianKun:isGet(cfgId)
    local flag = true
    for k,v in pairs(self.data.leftItems) do
        if v == cfgId then
            flag = false
        end
    end
    return flag
end

function ZhenXiQianKun:getRandomAward()
    local data = {}
    for i,j in pairs(self.data.curItems) do
        for k,v in pairs(self.lotteryAwardConf) do
            if v.id == j then 
                table.insert(data,v)
                break
            end
        end
        table.sort(data,function (a,b)
            return a.id < b.id 
        end)
    end
    return data
end

function ZhenXiQianKun:turn()
    if self.cancelAct.selected then  
        GOpenAlert3(self.data.items)
        self:setState()     
        self.startPos = self.data.cfgId
    else
        self.guangXiao.visible = true
        local toIndex = 0
        local startPosition = 0
        for k , v in pairs(self.lotteryList) do
            if v.data == self.data.cfgId then
                toIndex = k
            end
            if v.data == self.startPos then
                startPosition = k + 1
                -- print("上一次停止位置>>>",k,self.startPos)
                if k ~= 10 then
                    self.guangXiao.xy = self.lotteryList[startPosition].xy
                else
                    self.guangXiao.xy = self.lotteryList[1].xy
                end
            end
        end

        self.startPos = self.data.cfgId

        local number = #self.lotteryList
        local _wai = 10
        local delay = 0.1 --间隔时间

        local list = {}
        for i = startPosition , number do
            table.insert(list,i)
        end
        for i = 1 , _wai do
            table.insert(list,i)
        end
        for i = 1 , toIndex do
            table.insert(list,i)
        end
        local max = #list
        for k ,v in pairs(list) do
            self:addTimer(delay*(k-1), 1,function( )
                self.guangXiao.x = self.lotteryList[v].x
                self.guangXiao.y = self.lotteryList[v].y
                self:setBtnClickState(false)
                if k == max then
                    self:addTimer(0.5,1,function ( )
                        self.guangXiao.visible = false
                        GOpenAlert3(self.data.items)
                        self:setState()     
                        self:setBtnClickState(true)      
                    end)
                end
            end)
        end
    end
end

function ZhenXiQianKun:setBtnClickState(flag)
    self.getBtn.touchable = flag
    self.getAllBtn.touchable = flag
    self.refreshBtn.touchable = flag
end

function ZhenXiQianKun:onTimer()
    if not self.data then return end
    if self.actCountTime <= 0 then
        self:closeView()
        return
    end
    if self.actCountTime >= 86400 then
        self.actCountTimeText.text = GGetTimeData3(self.actCountTime)
    else
        self.actCountTimeText.text = GGetTimeData4(self.actCountTime)
    end
    self.actCountTime = self.actCountTime - 1 
end

function ZhenXiQianKun:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

return ZhenXiQianKun