--
-- Author: Your Name
-- Date: 2018-08-08 10:40:45
--百发百中
local ActShootingView = class("ActShootingView", base.BaseView)

function ActShootingView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ActShootingView:initView()
    local closeBtn = self.view:GetChild("n1")
    self:setCloseBtn(closeBtn)
    local guizeBtn = self.view:GetChild("n30")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.panel = self.view:GetChild("n28")
    self.boxList1 = {}
    self.boxList2 = {}
    for i=1,10 do
        local item1 = self.panel:GetChild("n0"):GetChild("n"..i)
        table.insert(self.boxList1,item1)
        local item2 = self.panel:GetChild("n1"):GetChild("n"..i)
        table.insert(self.boxList2,item2)
    end
    self.t0 = self.panel:GetTransition("t0")
    self.t1 = self.panel:GetTransition("t1")
    self.awardsList = self.view:GetChild("n12")
    self.awardsList.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.awardsList:SetVirtual()
    self.awardData = {}
    self.oneCostTxt = self.view:GetChild("n18")
    self.AllCostTxt = self.view:GetChild("n19")
    self.modelPanel = self.view:GetChild("n21")
    self.lastTimeTxt = self.view:GetChild("n15")
    self.gunEffect = self.view:GetChild("n29")
end

function ActShootingView:initData()
    self.t0:Play()
    self.t1:Stop()
    self.canClick = true--是否可点击按钮
    self.isEffectRef = true--特效是否刷新
    self.clickCooling = 9--可点击按钮冷却时间
    self.awardData = conf.ActivityConf:getHolidayGlobal("bfbz_show_awards")
    self.awardsList.numItems = #self.awardData
    --射击一次消耗元宝
    self.oneCost = conf.ActivityConf:getHolidayGlobal("bfbz_cost_once")
    self.oneCostTxt.text = self.oneCost
    --射击按钮
    self.shootOneBtn = self.view:GetChild("n9")
    self.shootOneBtn.data = 1--单次
    self.shootOneBtn.onClick:Add(self.onClickShoot,self)
    self.shootAllBtn = self.view:GetChild("n10")
    self.shootAllBtn.data = 2--剩余全部
    self.shootAllBtn.onClick:Add(self.onClickShoot,self)
    local modelIdData = conf.ActivityConf:getHolidayGlobal("bfbz_show_model")
    local sex = cache.PlayerCache:getSex()
    local modelId = modelIdData[sex]
    local wuqiId = modelIdData[3]
    local modelObj = self:addModel(modelId,self.modelPanel)
    modelObj:setSkins(nil, wuqiId, nil)
    modelObj:setPosition(0,-230,500)
    modelObj:setRotation(160)
    modelObj:setScale(180)

end

function ActShootingView:celldata(index,obj)
    local data = self.awardData[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemInfo, true)
    end
end

-- 变量名：reqType 说明：0:信息 1:射一次 2:全射
-- 变量名：index   说明：一次索引
-- 变量名：lastTime    说明：剩余时间
-- 变量名：boxData 说明：数据<索引id,type(1低级箱子 2:高级箱子) 射击过的没有数据
-- array<SimpleItemInfo>   变量名：items   说明：奖励
-- 变量名：itemType    说明：类型
function ActShootingView:setData(data)--221021001
    -- printt("百发百中>>>>>>>>>>>>>>",data)
    self.lastBoxNum = 0--剩余箱子数量
    for k,v in pairs(data.boxData) do
        self.lastBoxNum = self.lastBoxNum + 1
    end
    self.AllCostTxt.text = self.oneCost*self.lastBoxNum

    for i=1,10 do
        local item1 = self.boxList1[i]
        local t1 = item1:GetTransition("t0")
        local icon1 = item1:GetChild("n0")
        local item2 = self.boxList2[i]
        local t2 = item2:GetTransition("t0")
        local icon2 = item2:GetChild("n0")
        if data.boxData[i] or (data.index ~= 0 and data.index == i) then
            icon1.visible = true
            icon2.visible = true
            local iconUrl = {
                [1] = "baifbaizhong_013",
                [2] = "baifbaizhong_014",
            }
            if data.boxData[i] then
                icon1.url = UIPackage.GetItemURL("actshooting" , iconUrl[data.boxData[i]])
                icon2.url = UIPackage.GetItemURL("actshooting" , iconUrl[data.boxData[i]])
            else
                icon1.url = UIPackage.GetItemURL("actshooting" , iconUrl[data.itemType])
                icon2.url = UIPackage.GetItemURL("actshooting" , iconUrl[data.itemType])
            end
        else
            icon1.visible = false
            icon2.visible = false
        end
    end

    local effect = self:addEffect(4020168, self.gunEffect)
    effect.LocalPosition = Vector3.New(0,40,200)
    if data.reqType == 1 then--单次射击时播放动效
        self:playEffByIndex(data.index)
        self.isEffectRef = false
        local effect = self:addEffect(4020167, self.gunEffect)
        effect.LocalPosition = Vector3.New(0,40,200)
        self:addTimer(2, 1, function()
            self.isEffectRef = true
            effect = self:addEffect(4020168, self.gunEffect)
            effect.LocalPosition = Vector3.New(0,40,200)
        end)
    elseif data.reqType == 2 then--全部射击时播放动效
        for k,v in pairs(self.data.boxData) do
            self:playEffByIndex(k)
        end
        local effect = self:addEffect(4020167, self.gunEffect)
        effect.LocalPosition = Vector3.New(0,40,200)
        self:addTimer(2, 1, function()
            self.isEffectRef = true
            effect = self:addEffect(4020168, self.gunEffect)
            effect.LocalPosition = Vector3.New(0,40,200)
        end)
        self:addTimer(0.4, 1, function()
            self.t0:Stop()
            self.t1:Play()
        end)
        if data.items and #data.items > 0 then
            GOpenAlert3(data.items)
        end
    end

    self.data = data

    --活动倒计时
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.lasttime = data.lastTime
    self.lastTimeTxt.text = GGetTimeData2(self.lasttime)
    self.timer = self:addTimer(1, -1, handler(self,self.onTimer))
end

--播放指定位置的动效
function ActShootingView:playEffByIndex(index)
    local item1 = self.boxList1[index]
    local icon1 = item1:GetChild("n0") 
    local t1 = item1:GetTransition("t0")
    local effectPanel1 = item1:GetChild("n2")
    local panel1 = self.panel:GetChild("n0")
    if item1.x + panel1.x > -10 and item1.x + panel1.x < 550 then
        local boomEffect = self:addEffect(4020166, effectPanel1)
    end
    t1:Play()
    local item2 = self.boxList2[index]
    local icon2 = item2:GetChild("n0")
    local t2 = item2:GetTransition("t0")
    local effectPanel2 = item2:GetChild("n2")
    local panel2 = self.panel:GetChild("n1")
    if item2.x + panel2.x > -10 and item2.x + panel2.x < 550 then
        local boomEffect = self:addEffect(4020166, effectPanel2)
    end
    t2:Play()
    
    if self.lastBoxNum == 10 then
        icon1.visible = true
        icon2.visible = true
        self.t0:Stop()
        self.t1:Play()
        self.canClick = false
        self:addTimer(self.clickCooling, 1, function()
            self.canClick = true
        end)
    else
        self:addTimer(0.4, 1, function()
            icon1.visible = false
            icon2.visible = false
        end)
    end
end

function ActShootingView:onTimer()
    if self.lasttime > 0 then
        self.lasttime = self.lasttime - 1
        self.lastTimeTxt.text = GGetTimeData2(self.lasttime)
    else
        GComAlter(language.vip11)
        self:closeView()
    end
end

function ActShootingView:onClickShoot(context)
    local data = context.sender.data
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if self.canClick then
        if self.isEffectRef then
            if data == 1 then
                if myYb >= self.oneCost then
                    proxy.ActivityProxy:sendMsg(1030234,{reqType = 1})
                else
                    GComAlter(language.gonggong18)
                end
            elseif data == 2 then
                if myYb >= self.oneCost*self.lastBoxNum then
                    proxy.ActivityProxy:sendMsg(1030234,{reqType = 2})
                else
                    GComAlter(language.gonggong18)
                end
            end
        end
    else
        GComAlter(language.active65)
    end
end

function ActShootingView:onClickGuize()
    GOpenRuleView(1123)
end

return ActShootingView