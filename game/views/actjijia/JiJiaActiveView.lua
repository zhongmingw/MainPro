--
-- Author: Your Name
-- Date: 2018-07-23 15:43:55
--
--机甲来袭活动
local JiJiaActiveView = class("JiJiaActiveView", base.BaseView)

function JiJiaActiveView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function JiJiaActiveView:initView()
    local closeBtn = self.view:GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.jijiaList = {}
    for i = 1,10 do
        local icon = self.view:GetChild("icon"..i)
        table.insert(self.jijiaList,icon)
    end

    self.timerTxt = self.view:GetChild("n24")
    self.modelPanel = self.view:GetChild("n25")
    self.bgEffect = self.view:GetChild("n28")
    self.costYb = self.view:GetChild("n11")

    self.awardsList = self.view:GetChild("n27")
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.awardsList:SetVirtual()
end

function JiJiaActiveView:initData()
    self.costYb.text = conf.ActivityConf:getHolidayGlobal("jjjs_one_cost")
    self.maxNum = conf.ActivityConf:getHolidayGlobal("jjjs_sum_count")
    self.awardsData = conf.ActivityConf:getHolidayGlobal("jijs_awards_show")
    -- table.sort(self.awardsData,function(a,b)
    --     if a[4] ~= b[4] then
    --         return a[4] < b[4]
    --     end
    -- end)
    self.awardsList.numItems = #self.awardsData

    local modelId = conf.ActivityConf:getHolidayGlobal("jjjs_show_model")
    self.model = self:addModel(modelId[1], self.modelPanel)
    self.model:setSkins(nil,modelId[2],modelId[3])
    self.model:setRotationXYZ(0,150,0)
    self.model:setScale(100)
    self.model:setPosition(10, -183, 500)

    self.bgef = self:addEffect(4020162,self.bgEffect)
    self.leftData = {}--当前剩余机甲
    self.canClick = true
    self.lastTime = 0
end

function JiJiaActiveView:itemData(index,obj)
    local data = self.awardsData[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemInfo, true)
    end
end

-- 变量名：reqType 说明：0:信息 1:击破单个 2:全部击破
-- 变量名：lastTime    说明：剩余时间
-- 变量名：boxData 说明：机甲数据<索引id,type(1小机甲 2:大机甲)*100+statue(1:未击破 2:已击破)
-- array<SimpleItemInfo>   变量名：items   说明：奖励
-- 变量名：actId   说明：活动id
-- 变量名：hatredValue 说明：仇恨值
-- 变量名：index   说明：击破指定机甲id
function JiJiaActiveView:setData(data)
    -- printt("机甲活动>>>>>>>>>>>",self.boxData)
    self.data = data
    self.actId = data.actId
    self.boxData = data.boxData
    self.effect = {}

    self.lastTime = data.lastTime
    --倒计时
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.timerTxt.text = GGetTimeData2(self.lastTime)
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
    for k,v in pairs(self.effect) do
        if v then
            self:removeEffect(v)
            self.effect[k] = nil
        end
    end
    if data.index ~= 0 then--上一个为单个击破时
        local item = self.jijiaList[data.index]
        local effectPanel = item:GetChild("n1")
        item.visible = true
        self.effect[data.index] = self:addEffect(4020165, effectPanel)
        if not self:isAllRefresh() then
            self:addTimer(1, 1, function()
                self.canClick = true
                item.visible = false
            end)
        else
            self:addTimer(1, 1, function()
                self.canClick = true
                self:initJiJiaData()
            end)
        end
    elseif data.reqType == 2 then--上一次为全部击破时
        for k,v in pairs(self.leftData) do
            local boxStatue = v%100
            local item = self.jijiaList[k]
            local effectPanel = item:GetChild("n1")
            if boxStatue == 1 then
                self.effect[k] = self:addEffect(4020165, effectPanel)
            end
        end
        self:addTimer(1, 1, function()
            self.canClick = true
            self:initJiJiaData()
        end)
    else
        self:initJiJiaData()
    end
    
    --全部击破按钮
    local btnStrikeAll = self.view:GetChild("n8")
    btnStrikeAll.data = 0
    btnStrikeAll.onClick:Add(self.onClickStrike,self)
end

function JiJiaActiveView:onTimer()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.timerTxt.text = GGetTimeData2(self.lastTime)
    else
        self:closeView()
    end
end

function JiJiaActiveView:initJiJiaData()
    for k,v in pairs(self.jijiaList) do
        if k > #self.boxData then
            v.visible = false
            break
        end
        v.visible = true
        local boxType = math.floor(self.boxData[k]/100)
        local boxStatue = self.boxData[k]%100
        local effectPanel = v:GetChild("n1")
        if self.data.index ~= k or self:isAllRefresh() then
            if boxType == 1 then
                self.effect[k] = self:addEffect(4020164, effectPanel)
            else
                self.effect[k] = self:addEffect(4020163, effectPanel)
            end
            
            if boxStatue == 1 then
                v.visible = true
            else
                v.visible = false
            end
        end
        v.data = k
        v.onClick:Add(self.onClickStrike,self)
    end
end

--是否全部刷新
function JiJiaActiveView:isAllRefresh()
    local flag = true
    for k,v in pairs(self.boxData) do
        local boxStatue = v%100
        if boxStatue ~= 1 then
            flag = false
            break
        end
    end
    return flag
end

function JiJiaActiveView:onClickStrike(context)
    local data = context.sender.data
    local oneCost = conf.ActivityConf:getHolidayGlobal("jjjs_one_cost")
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if data == 0 then--全部击破
        local num = 0
        self.leftData = self.boxData
        for k,v in pairs(self.boxData) do
            if v%100 == 1 then
                num = num + 1
            end
        end
        if myYb >= oneCost*num then
            if self.canClick then
                self.canClick = false
                proxy.ActivityProxy:sendMsg(1030224,{reqType = 2,actId = self.actId})
            end
        else
            GComAlter(language.gonggong18)
        end
    else--单个击破
        if myYb >= oneCost then
            if self.canClick then
                self.canClick = false
                proxy.ActivityProxy:sendMsg(1030224,{reqType = 1,actId = self.actId,index = data})
            end
        else
            GComAlter(language.gonggong18)
        end
    end
end

return JiJiaActiveView