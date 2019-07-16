--
-- Author: EVE
-- Date: 2017-12-18 19:52:53
--

local BuyCloudView = class("BuyCloudView", base.BaseView)

function BuyCloudView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.uiClear = UICacheType.cacheTime
    self.isBlack = true
end

function BuyCloudView:initView()
    --关闭
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onCloseView, self)

    --倒计时
    self.countDown = self.view:GetChild("n11")
    self.countDown.text = ""

    --开奖剩余份数
    self.countSurplus = self.view:GetChild("n12")
    self.countSurplus.text = ""

    --已购买份数
    self.countAlreadyBuy = self.view:GetChild("n18")
    self.countAlreadyBuy.text = ""

    --云购记录(列表展示)
    self.buyList = self.view:GetChild("n15")

    --云记录显示
    self:onBuyList() 

    --规则
    local ruleBtn = self.view:GetChild("n20")
    ruleBtn.onClick:Add(self.onRuleBtn, self)
   
    --中奖纪录面板入口
    local proRecordPanel = self.view:GetChild("n21")
    proRecordPanel.onClick:Add(self.onRecordPanel, self)

    --购买
    self.buyBtn = self.view:GetChild("n17")
    self.buyBtn.data = 1 --购买1次
    self.buyBtn.onClick:Add(self.onBuy, self)
    self.buyTenTimes = self.view:GetChild("n31")
    self.buyTenTimes.data = 3 --购买10次
    self.buyTenTimes.onClick:Add(self.onBuy, self)

    --奖励展示
    self.awardList = {}
    for i=2,8 do
        local temp = self.view:GetChild("n"..i)
        table.insert(self.awardList, temp)
    end
    self.mainItem = self.view:GetChild("n10") --大奖
    self.secondaryItem = self.view:GetChild("n9")  --小奖

    --花费和剩余次数配置
    self.sumAndCost = conf.ActivityConf:getSumAndCost()

    --花费
    self.buyBtn.title = self.sumAndCost[1][2]
    local zhekou = conf.ActivityConf:getValue("lucky_buy_ten_zk")
    self.buyTenTimes.title = self.sumAndCost[1][2] * (zhekou/100)*10
    
    --花费货币类型
    self.buyBtn:GetChild("n1").url = UIItemRes.moneyIcons[self.sumAndCost[1][1]]
    self.buyTenTimes:GetChild("n1").url = UIItemRes.moneyIcons[self.sumAndCost[1][1]]

    --标题美术字
    self.titleIcon = self.view:GetChild("n0"):GetChild("n5")
end

function BuyCloudView:initData(data)
    self.actId = data.actId

    -- print("actId>>>>>>>>>>>>>>>>",self.actId)
end

function BuyCloudView:onBuy(context)
    local data = context.sender.data
    --当前时间
    -- print("是否配置的18点：", self:setTimeCompare())

    -- if self:setTimeCompare() then --八点后，无次数显示
    --     proxy.ActivityProxy:sendMsg(1030301, {reqType = 1})

    -- else --没到八点，有次数限制
    --     local isCanBuy = self:setBuyCount() --判断购买次数是否足够
    --     if isCanBuy then 
    --         -- print("消息已发送~~~~~~~~~~~~~",GGetTimeData2(os.time()), GGetTimeData2(self.data.leftActTime))
    --         proxy.ActivityProxy:sendMsg(1030301, {reqType = 1})
    --     else
    --         GComAlter(language.buyCloud07)
    --     end
    -- end 
    print("购买类型>>>>>>>>>>>>",data)
    if self.actId == 3017 then
        proxy.ActivityProxy:sendMsg(1030301, {reqType = data})
    elseif self.actId == 3054 then
        proxy.ActivityProxy:sendMsg(1030401, {reqType = data})
    end
end

-- --设置时间比较
-- function BuyCloudView:setTimeCompare()
--     --当前时间
--     local timeTab = os.date("*t",mgr.NetMgr:getServerTime())
--     local hour = string.format("%02d", timeTab.hour)
--     local min = string.format("%02d", timeTab.min)
--     local sec = string.format("%02d", timeTab.sec) 

--     --配置的时间
--     local confTime = GTotimeString(self.sumAndCost[2])
--     local times = string.split(confTime, ":")

--     -- print("hour", hour, type(hour), "min", min, "sec", sec)
--     -- print("1111",times[1], type(times[1]), "2222", times[2], "3333", times[3])

--     --比较
--     if tonumber(hour) >= tonumber(times[1]) then 
--         if tonumber(min) >= tonumber(times[2]) then 
--             if tonumber(sec) >= tonumber(times[3]) then                
--                 return true
--             else
--                 return false
--             end 
--         else
--             return false
--         end 
--     else
--         return false
--     end 
-- end

function BuyCloudView:setData(data)

    printt("幸运云购",data)

    -- print("~~~~~~~~~~~~~~分隔线~~~~~~~~~~~~~~~~~",data.todayStage)

    self.data = data

    --多开id
    self.mulActId = data.mulActId
    local mulActConf = conf.ActivityConf:getMulActById(self.mulActId)
    if mulActConf and mulActConf.title_icon then
        self.titleIcon.url = UIPackage.GetItemURL("buycloud" , mulActConf.title_icon)
    end
    -- --购买按钮状态
    -- if self.data.todayStage == 3 then 
    --     self.buyBtn.touchable = false
    --     self.buyBtn.grayed = true
    -- elseif not self.buyBtn.touchable then 
    --     self.buyBtn.touchable = true
    --     self.buyBtn.grayed = false
    -- end 

    --购买成功飘字
    if self.data.reqType == 1 then
        local itemData = conf.ItemConf:getItem(self.data.items[1].mid)
        local name = itemData.name
        local color = itemData.color
        local amount = self.data.items[1].amount     
        GComAlter(string.format(language.buyCloud06, mgr.TextMgr:getQualityStr1(name, color), amount))
    elseif self.data.reqType == 3 then
        GOpenAlert3(data.items)
    end 

    --倒计时
    -- if not self.timeMark then
        self:onTimer() --活动倒计时
    --     self.timeMark = true
    -- end 

    --剩余份数
    self.countSurplus.text = string.format(language.buyCloud02, self.data.leftBuyCount) 

    --已购买份数
    self.countAlreadyBuy.text =string.format(language.buyCloud03, self.data.mineBuyCount) 

    --云记录长度
    self.buyList.numItems = #self.data.logs
  
    -- if self.stage ~= self.data.stage then  --*不应该每次消息返回都设置一次奖励Icon，所以这么写
    --     self.stage = self.data.stage

        --不可获取奖励的展示
        self:setAwardsShow(self.data.stage)

        --大奖的展示
        local mId = conf.ItemConf:getRealMid(self.data.bestItemInfo.mid) or self.data.bestItemInfo.mid
        local amount = self.data.bestItemInfo.amount
        local bind = self.data.bestItemInfo.bind
        local eStar = self.data.bestItemInfo.colorStarNum
        local info = {mid = mId, amount = amount, bind = bind, eStar = eStar}   
        GSetItemData(self.mainItem,info,true)

        --次要奖励的展示
        self:setAdditionalEquip()

        -- print("设置奖励",self.stage,mId)  
    -- end 
end

--额外装备的显示
function BuyCloudView:setAdditionalEquip()
    local tempData = conf.ActivityConf:getAdditionalEquip(self.actId,self.mulActId)
    local curLv = cache.PlayerCache:getRoleLevel()

    for k,v in pairs(tempData) do
        if v.level[1] <= curLv and curLv <= v.level[2] then
            local mId = v.item_fk[1]
            local amount = v.item_fk[2]
            local bind = v.item_fk[3]
            local info = {mid = mId, amount = amount, bind = bind}
            GSetItemData(self.secondaryItem,info,true)
        end 
    end
end

--剩余购买次数
function BuyCloudView:setBuyCount()
    if not self.data and not self.data.mineBuyCount then 
        print("消息没返回~！")
        return 
    end 

    --vip等级
    local curVipLv = cache.PlayerCache:getVipLv()
    --当前可购买次数
    local curCount = conf.VipChargeConf:getVipAwardsReset(curVipLv)  --vip等级是从0级开始的
    --计算剩余购买次数
    local needShowCount = curCount - self.data.mineBuyCount 
    -- print("剩余购买次数~~~~~~~~", needShowCount)
    --是否还能再购买
    if needShowCount <= 0 then       
        return false
    else      
        return true
    end 
end

--云记录列表
function BuyCloudView:onBuyList( ... )
    self.buyList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.buyList:SetVirtual()

    self.buyList.numItems = 0
end
function BuyCloudView:cellData(index, obj)
    local data = self.data.logs[index+1]

    local recordItem = obj:GetChild("n0") --记录文本
    recordItem.text = string.format(language.buyCloud01, mgr.TextMgr:getTextColorStr(data,7))
end

--设置奖励展示
function BuyCloudView:setAwardsShow(id)
    if id > 9 then id = 9 end
    --奖励配表
    local mulActConf = conf.ActivityConf:getMulActById(self.mulActId)
    local confData = conf.ActivityConf:getShowAward(id,self.actId)
    if mulActConf then
        local award_pre = mulActConf.award_pre
        local awardId = award_pre*1000 + id
        confData = conf.ActivityConf:getShowAward(awardId,self.actId)

    end
    -- printt(confData)
    local itemData = confData.items_u3d

    --奖励填入
    local listSize = #itemData
    for i=1,listSize do
        local mId = itemData[i][1]
        local amount = itemData[i][2]
        local bind = itemData[i][3]
        
        local info = {mid = mId,amount = amount,bind = bind}

        GSetItemData(self.awardList[i],info,true)
    end  
end

--倒计时
function BuyCloudView:onTimer()
    if not self.data or not self.data.leftActTime then 
        plog("@呼叫后端，服务器返回为空") 
        return 
    end

    if self.curTimer then
        self:removeTimer(self.curTimer)
        self.curTimer = nil
    end 

    self.curTimer = self:addTimer(1, -1, function()
        self.data.leftActTime = self.data.leftActTime-1
        if self.data.leftActTime > 0 then 
            if self.data.leftActTime > 86400 then 
                self.countDown.text = GTotimeString7(self.data.leftActTime)
                -- print("time~~~~~~~~~", GTotimeString7(self.data.leftActTime), self.data.leftActTime)
            else
                self.countDown.text = GTotimeString(self.data.leftActTime)
            end
        else
            self.countDown.text = language.kaifuchongji04
            self:closeView()
        end
    end)
end

--打开中奖面板
function BuyCloudView:onRecordPanel() 
    local view = mgr.ViewMgr:get(ViewName.ProRecordPanel)
    if not view then 
        -- print("巴黎圣母~~~~~~~~~~~~~~~~~~~~~~~")

        mgr.ViewMgr:openView(ViewName.ProRecordPanel,function()
            if self.actId == 3017 then
                proxy.ActivityProxy:sendMsg(1030301, {reqType = 2})
            elseif self.actId == 3054 then
                proxy.ActivityProxy:sendMsg(1030401, {reqType = 2})
            end
        end)
    end 
end

--规则面板
function BuyCloudView:onRuleBtn()
    GOpenRuleView(1072)
end

--关闭
function BuyCloudView:onCloseView()
    -- body
    self:closeView()
end

return BuyCloudView