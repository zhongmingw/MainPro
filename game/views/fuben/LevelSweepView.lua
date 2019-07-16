--
-- Author: 
-- Date: 2017-09-12 14:21:59
--

local LevelSweepView = class("LevelSweepView", base.BaseView)

function LevelSweepView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function LevelSweepView:initView()
    self.sweepCost = 0--记录要消耗的元宝
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.timeText = self.view:GetChild("n5")
    self.view:GetChild("n6").text = language.fuben108

    self.itemList = {}
    for i=2,4 do
        local item = self.view:GetChild("n"..i)
        table.insert(self.itemList, item)
    end

    local btn = self.view:GetChild("n7")
    btn.onClick:Add(self.onClickSweep,self)

    self.constText = self.view:GetChild("n9")--消耗的元宝
end

function LevelSweepView:initData(data)
    self.textNums = {}
    self.counts = {0,0,0}--记录默认使用经验符数量
    self.maxCounts = {}--记录最大使用数量
    self.timeTexts = {}--三个buff的剩余时间显示
    self.times = {0,0,0}
    self.leftTime = data.leftTime or 0--剩余时间
    self.timeText.text = language.fuben111..mgr.TextMgr:getTextColorStr(GTotimeString2(self.leftTime), 7)
    self.sweepCost = data.cost or 0
    self.constText.text = self.sweepCost
    local items = conf.FubenConf:getValue("exp_lianjigu_itemid")
    for k,mid in pairs(items) do
       self:setItemData(k,mid)
    end
    self:onTimer()
    self.buffTimer = self:addTimer(1, -1, handler(self, self.onTimer))
end
--设置三种经验符的信息
function LevelSweepView:setItemData(key,mid)
    local item = self.itemList[key]
    if item then
        local itemObj = item:GetChild("n1")
        local itemData = {mid = mid, amount = 1}
        GSetItemData(itemObj,itemData,true)

        local buyBtn = item:GetChild("n2")
        buyBtn.data = itemData
        buyBtn:RemoveEventListeners()
        buyBtn.onClick:Add(self.onClickBuy,self)
        local leftBtn = item:GetChild("n4")
        leftBtn.data = {key = key,mid = mid}
        leftBtn:RemoveEventListeners()
        leftBtn.onClick:Add(self.onClickLess,self)
        local rightBtn = item:GetChild("n5")
        rightBtn.data = {key = key,mid = mid}
        rightBtn:RemoveEventListeners()
        rightBtn.onClick:Add(self.onClickAdd,self)
        self.textNums[key] = item:GetChild("n6")
        -- 
        local buffId = conf.ItemConf:getArgsType2(mid)--获取buffId
        local buffData = mgr.BuffMgr:getBuffByModelId(buffId)
        local endTime = buffData and buffData.endTime or 0
        local buffTime = math.max(0, endTime - mgr.NetMgr:getServerTime())
        self.times[key] = buffTime
        local confData = conf.BuffConf:getBuffConf(buffId)
        local confTime = confData and confData.effect_time or 0--配置时间毫秒
        local time = math.max(0, self.leftTime - buffTime)
        local count = math.ceil(time / (confTime / 1000))--默认显示多少个
        local packData = cache.PackCache:getPackDataById(mid)
        if count > packData.amount then
            count = packData.amount
        end
        self.textNums[key].text = count
        self.counts[key] = count
        self.maxCounts[key] = count
        self.timeTexts[key] = item:GetChild("n7")
    end
end

function LevelSweepView:onTimer()
    local items = conf.FubenConf:getValue("exp_lianjigu_itemid")
    for key,mid in pairs(items) do
        if self.times[key] <= 0 then
            self.times[key] = 0
            self.timeTexts[key].text = ""
        else
            self.timeTexts[key].text = language.fuben109..mgr.TextMgr:getTextColorStr(GTotimeString4(self.times[key]), 7)
        end
        self.times[key] = self.times[key] - 1
        local buffId = conf.ItemConf:getArgsType2(mid)--获取buffId
        local confData = conf.BuffConf:getBuffConf(buffId)
        local confTime = confData and confData.effect_time or 0--配置时间毫秒
        local time = math.max(0, self.leftTime - self.times[key])
        local count = math.ceil(time / (confTime / 1000))--默认显示多少个
        if count <= self.maxCounts[key] then
            self.maxCounts[key] = count
        end
        if self.counts[key] >= count then--根据时间的减少，最大使用数量会发生变化
            self.counts[key] = count
            self.textNums[key].text = count
        end
    end
end
--经验符购买
function LevelSweepView:onClickBuy(context)
    local data = context.sender.data
    if data then
        GGoBuyItem(data)
    end
end

function LevelSweepView:onClickLess(context)
    local data = context.sender.data
    local key = data.key
    local mid = data.mid
    self.counts[key] = self.counts[key] - 1
    if self.counts[key] <= 0 then
        self.counts[key] = 0
    end
    self.textNums[key].text = self.counts[key]
end

function LevelSweepView:onClickAdd(context)
    local data = context.sender.data
    local key = data.key
    local mid = data.mid
    self.counts[key] = self.counts[key] + 1
    local count = self.counts[key]
    local maxCount = self.maxCounts[key]
    if maxCount <= 0 then
        self.counts[key] = maxCount
        local buffId = conf.ItemConf:getArgsType2(mid)--获取buffId
        local confData = conf.BuffConf:getBuffConf(buffId)
        local confTime = confData and confData.effect_time or 0--配置时间毫秒
        local time = math.max(0, self.leftTime - self.times[key])
        local num = math.ceil(time / (confTime / 1000))--默认显示多少个
        local packData = cache.PackCache:getPackDataById(mid)
        if packData.amount <= 0 and num > 0 then--背包里面为0并且可以使用1个以上的经验符的时候
            GGoBuyItem({mid = mid, amount = 1})
        else
            GComAlter(language.fuben112)
        end
        return
    end
    if count >= maxCount  then
        if count > maxCount then
            GComAlter(language.fuben112)
        end
        self.counts[key] = maxCount
    end
    self.textNums[key].text = self.counts[key]
end

function LevelSweepView:onClickSweep()
    local sendFunc = function()
        plog(self.counts)
        proxy.FubenProxy:send(1025105,{expNumList = self.counts})
        self:closeView()
    end
    local count = 0
    for k,num in pairs(self.counts) do
        if num == 0 then
            count = count + 1
        end
    end
    local timeCount = 0
    for k,v in pairs(self.times) do
        if v <= 0 then
            timeCount = timeCount + 1
        end
    end
    local notExp = false
    if timeCount >= #self.times then--没有使用经验符的情况
        if count >= #self.counts then--都没有添加道具的情况
            notExp = true
        else
            notExp = false
        end
    end
    if notExp then
        local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(language.fuben110,9),sure = function()
            sendFunc()
        end}
        GComAlter(param)
    else
        local strTab = clone(language.fuben106)
        strTab[2].text = string.format(strTab[2].text, self.sweepCost)
        local param = {type = 2,richtext = mgr.TextMgr:getTextByTable(strTab),sure = function()
            sendFunc()
        end}
        GComAlter(param)
    end
end

return LevelSweepView