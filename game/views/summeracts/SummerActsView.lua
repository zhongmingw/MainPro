--夏日活动
-- Author: Your Name
-- Date: 2017-08-09 21:08:12
--
local SummerActsView = class("SummerActsView", base.BaseView)

function SummerActsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function SummerActsView:initView()
    local closeBtn = self.view:GetChild("n4"):GetChild("n9")
    closeBtn.onClick:Add(self.onBtnClose,self)
    self.panel = self.view:GetChild("n9")
    self.signImg = self.panel:GetChild("n25")
    self.itemCost = self.panel:GetChild("n28")
    self.ybCost = self.panel:GetChild("n31")
    self.pos = 1
    self.time = 0
    local sex = cache.PlayerCache:getSex()
    for i=1,12 do
        local awardsConf = conf.ActivityConf:getSummerAwardsById(i)
        local awardsData = awardsConf[1]
        if sex == 2 and (i == 1 or i == 3) then
            awardsData = awardsConf[2]
        end
        if awardsData then
            local obj = self.panel:GetChild("n"..i)
            local mId = awardsData[1]
            local amount = awardsData[2]
            local bind = awardsData[3]
            local info = {mid = mId,amount = amount,bind = bind}
            
            GSetItemData(obj,info,true)
        end
    end
    local guizeBtn = self.panel:GetChild("n40")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.model = self.panel:GetChild("n36")
    self.model2 = self.panel:GetChild("n47")

    self.labtimer = self.panel:GetChild("n49")
    self.labtimer.text = ""
end

function SummerActsView:initData()
    --模型显示
    local sex = cache.PlayerCache:getSex()
    local shizhuangConf = conf.ActivityConf:getSummerAwardsById(1)
    local wuqiConf = conf.ActivityConf:getSummerAwardsById(3)
    local shizhuangMid = shizhuangConf[1][1]
    local wuqiMid = wuqiConf[1][1]
    if sex == 2 then
        shizhuangMid = shizhuangConf[2][1]
        wuqiMid = wuqiConf[2][1]
    end
    local skinId1 = conf.ItemConf:getItemExt(shizhuangMid)
    local skinId2 = conf.ItemConf:getItemExt(wuqiMid)
    local confData1 = conf.RoleConf:getFashData(skinId1)
    local confData2 = conf.RoleConf:getFashData(skinId2)

    self.model.visible = true
    -- print("模型id",confData1.model)
    if confData1.model then
        local obj = self:addModel(confData1.model,self.model,nil,"mount2_idle")
        obj:setSkins(nil,confData2.model)
        obj:setPosition(0,-427.8,200)
        obj:setRotation(168.5)
        obj:setScale(150)

        local obj = self:addModel(3040302,self.model2)
        obj:setPosition(0,-258.7,180)
        obj:setRotation(152)
        obj:setScale(80)
    end

    if self.timers then
        self:removeTimer(self.timers)
        self.timers = nil 
    end

    self.timers = self:addTimer(1,-1,handler(self,self.onTiemr))
end

function SummerActsView:onTiemr()
    -- body
    if not self.data then
        self.labtimer.text = ""
        return
    end

    self.data.leftTime = self.data.leftTime - 1
    if self.data.leftTime < 0 then
        self.data.leftTime = 0
    end

    local param = clone(language.active19)
    param[2].text = string.format(param[2].text,GGetTimeData2(self.data.leftTime))

    self.labtimer.text = mgr.TextMgr:getTextByTable(param)
end

function SummerActsView:onClickGuize()
    GOpenRuleView(1041)
end

function SummerActsView:onClickDraw(context)
    local data = context.sender.data
    local ybCost = conf.ActivityConf:getValue("summer_flame_cost_yb")
    local itemCost = conf.ActivityConf:getValue("summer_flame_cost")
    local step = #data.gotItems + 1
    local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local proportion = conf.ActivityConf:getValue("summer_flame_proportion")--道具元宝比例
    if step <= 12 then
        if data.costItemCount < itemCost[step] then
            local param = {}
            local extraCost = ybCost[step] - itemCost[step]*proportion 
            local extraYb = (itemCost[step] - data.costItemCount)*proportion+extraCost
            param.type = 2
            param.sure = function()
                --print("元宝数量",extraYb)
                if moneyYb < extraYb then
                    GComAlter(language.gonggong18)
                else
                    proxy.ActivityProxy:sendMsg(1030205, {reqType = 2,buyType = 2,stage = step})
                end
            end
            param.closefun = function( )
                
            end
            if extraYb == 0 then
                local textData = {
                                    {text = language.active02,color = 6},
                                    {text = language.active02_1,color = 6},
                                }
                param.richtext = mgr.TextMgr:getTextByTable(textData)
            else
                local textData = {
                                    {text = language.active02,color = 6},
                                    {text = extraYb,color = 7},
                                    {text = language.active02_1,color = 6},
                                }
                param.richtext = mgr.TextMgr:getTextByTable(textData)
            end
            GComAlter(param)
        else
            proxy.ActivityProxy:sendMsg(1030205, {reqType = 2,buyType = 1,stage = step})
        end
    else
        GComAlter(language.active03)
    end
end

function SummerActsView:addMsgCallBack(data)
    self.data = data
    -- print("抽奖活动",data.itemId,data.reqType)
    if data.reqType == 2 then--抽奖返回
        local num = data.itemId % 10000
        local drawBtn = self.panel:GetChild("n24")
        drawBtn.onClick:Clear()
        self:signMove(num)
    else
        self:setData(data)
    end
end

function SummerActsView:setData(data)
    local drawBtn = self.panel:GetChild("n24")
    drawBtn.data = data
    drawBtn.onClick:Add(self.onClickDraw,self)
    local actNum = conf.ActivityConf:getValue("summer_flame_items")
    local ybCost = conf.ActivityConf:getValue("summer_flame_cost_yb")
    local itemCost = conf.ActivityConf:getValue("summer_flame_cost")
    local step = #data.gotItems + 1
    if step <= 12 then
        local textData = {
                    {text = data.costItemCount,color = 7},
                    {text = "/"..itemCost[step] ,color = 7},  
                }
        if data.costItemCount < itemCost[step] then
            textData = {
                    {text = data.costItemCount,color = 14},
                    {text = "/"..itemCost[step],color = 7},
                }
        end
        for i=26,31 do
            self.panel:GetChild("n"..i).visible = true
        end
        self.itemCost.text = mgr.TextMgr:getTextByTable(textData)
        local var = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        local _tt = {}
        if var > ybCost[step] then
            _tt[1] = {text = ybCost[step].." ",color = 7}     
        else
            _tt[1] = {text = ybCost[step].." ",color = 14}     
        end
        _tt[2] = {text = language.active07,color = 11}

        self.ybCost.text = mgr.TextMgr:getTextByTable(_tt)
    else
        for i=26,31 do
            self.panel:GetChild("n"..i).visible = false
        end
    end
    --已领取的奖励
    for k,v in pairs(data.gotItems) do
        local index = tonumber(v)%10000
        self.panel:GetChild("n"..index):GetChild("n6").visible = true
    end
    --领取活跃奖励道具
    local stage = 0
    for i=1,#actNum do
        if not data.gotCostItems[i] then
            stage = i
            break
        end
    end
    local getActBtn = self.panel:GetChild("n37")
    local ActText = self.panel:GetChild("n38")
    getActBtn.data = stage
    getActBtn.onClick:Add(self.onClickGetAct,self)
    local drawItem = self.panel:GetChild("n44")
    local itemNums = drawItem:GetChild("n2")
    -- print("领取情况",stage)
    -- printt(data.gotCostItems)
    if stage ~= 0 then
        ActText.text = string.format(language.active04,actNum[stage][1])
        drawItem.visible = true
        self.panel:GetChild("n46").visible = false
        itemNums.text = actNum[stage][2]
        if actNum[stage][1] <= self.data.activeCount then
            getActBtn.grayed = false
        else
            getActBtn.grayed = true
        end
    else
        self.panel:GetChild("n46").visible = true
        drawItem.visible = true
        ActText.text = language.active05
        getActBtn.grayed = true
    end
end

--领取消耗道具
function SummerActsView:onClickGetAct( context )
    local stage = context.sender.data
    local gotCostItems = self.data.gotCostItems

    local activeCount = self.data.activeCount
    local actNum = conf.ActivityConf:getValue("summer_flame_items")
    if stage ~= 0 then
        if actNum[stage][1] <= activeCount then
            --print("领取",stage)
            proxy.ActivityProxy:sendMsg(1030205, {reqType = 3,buyType = 0,stage = stage})
        else
            GComAlter(language.active06)
        end
    else
        GComAlter(language.active05)
    end
end

--移动格子
function SummerActsView:signMove(num)
    self.times = num + 12*2 + 12*3 --3圈快速 2圈中速 然后慢速
    self.pos = 1
    local award = self.panel:GetChild("n"..self.pos)
    self.signImg.x = award.x - 2
    self.signImg.y = award.y - 2
    self.timer = mgr.TimerMgr:addTimer(0.05, -1, function()
        local flag = false
        if self.times >= num+12*2 then--快速
            flag = true
            self.times = self.times - 1
        elseif self.times >= num then
            self.times = self.times - 0.5
            if self.times%1 == 0 then--中速
                flag = true
            end
        elseif self.times >= 1 then--慢速
            self.times = self.times - 0.25
            if self.times%1 == 0 then
                flag = true
            end
        else--停止移动
            flag = false
            self.pos = 1
            self.times = 0
            self:setData(self.data)
            local index = self.data.itemId%10000
            local awardsConf = conf.ActivityConf:getSummerAwardsById(index)
            local awardsData = awardsConf[1]
            if sex == 2 and i <= 2 then
                awardsData = awardsConf[2]
            end
            if awardsData then
                local items = {{mid = awardsData[1],amount = awardsData[2],bind = awardsData[3]}}
                GOpenAlert3(items)
            end
            mgr.TimerMgr:removeTimer(self.timer)
        end
        if flag then--flag为true时移动格子
            self.pos = self.pos + 1
            if self.pos == 13 then
                self.pos = 1
            end
            local award = self.panel:GetChild("n"..self.pos)
            self.signImg.x = award.x - 2
            self.signImg.y = award.y - 2
        end
    end)
end

function SummerActsView:onBtnClose()
    cache.PlayerCache:setAttribute(30120,#self.data.gotItems)
    GIsOpenWishPop(30120)
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
    end
    self:closeView()
end

return SummerActsView