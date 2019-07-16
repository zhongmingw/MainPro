--
-- Author: 
-- Date: 2018-01-24 17:04:26
-- 情侣时装抽奖

local CoupleSuitsView = class("CoupleSuitsView", base.BaseView)

--特效位置
local AwardPos = {
    [10001] = 11,
    [10002] = 1,
    [10003] = 2,
    [10004] = 3,
    [10005] = 4,
    [10006] = 5,
    [10007] = 6,
    [10008] = 7,
    [10009] = 8,
    [10010] = 9,
    [10011] = 10,
    [10012] = 11
}
local TransitionDelay  = {0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5,2.75,3}

function CoupleSuitsView:ctor()
    CoupleSuitsView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale 
end

function CoupleSuitsView:initView()
    self.closeBtn = self.view:GetChild("n0"):GetChild("n3")
    self.closeBtn.onClick:Add(self.onBtnClose,self)
    self.awardItemList = {}
    for i=13,24 do
        local item = self.view:GetChild("n"..i)
        table.insert(self.awardItemList, item)
    end
    --抽奖一次
    self.oneBtn = self.view:GetChild("n2")
    self.oneBtn.data = {status = 1}
    self.oneBtn:GetChild("n1").url = UIPackage.GetItemURL("valentines" , "zhoumokuanghuan_009")
    self.oneBtn.onClick:Add(self.onClickBuy,self)
    --抽奖十次
    self.tenBtn = self.view:GetChild("n3")
    self.tenBtn.data = {status = 10}
    self.tenBtn:GetChild("n1").url = UIPackage.GetItemURL("valentines" , "zhoumokuanghuan_010")
    self.tenBtn.onClick:Add(self.onClickBuy,self)

    self.model = self.view:GetChild("n12")
    self.model2 = self.view:GetChild("n47")
    --个人积分
    self.singleScore = self.view:GetChild("n5")
    --情侣积分
    self.coupleScore = self.view:GetChild("n6")
    --规则
    self.ruleTxt = self.view:GetChild("n30")
    self.ruleTxt.text = language.valentine01
    --活动倒计时
    self.leftTimes = self.view:GetChild("n29")
    --领取条件文本
    self.getTxt = self.view:GetChild("n34")

    -- self.title = self.view:GetChild("n27")
    -- self.title.text = language.valentine06

    self.controller1 = self.view:GetController("c1")

    self.getAwardBtn = self.view:GetChild("n32")
    self.getAwardBtn.onClick:Add(self.getAward,self)

    self.t0 = self.view:GetTransition("t0")
    self.tList = {}
    for i=1,12 do
        local tTransition = self.view:GetTransition("t"..i)
        table.insert(self.tList,tTransition)
    end
    self.tEffect = self.view:GetChild("n42")

    self.listView = self.view:GetChild("n31")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function CoupleSuitsView:initData()
    self:setModel()
    
    --展示物品data
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    local confData = conf.ActivityConf:getRallfeAward()
    for k,v in pairs(confData) do
        local awardData = v.awards[1]
        if awardData then 
            local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3],isquan = 0}
            GSetItemData(self.awardItemList[v.sort], itemData, true)
        end
    end
    self.onceCost = conf.ActivityConf:getHolidayGlobal("valentine_raffle_cost")
    self.oneBtn.title = self.onceCost
    self.tenBtn.title = self.onceCost * 10

    --领取奖励data
    local sex = cache.PlayerCache:getSex()
    self.awards = conf.ActivityConf:getScoreAward(sex)

    self.awardData = self.awards[1].awards  --现在需求只有一个阶段的奖励

    self.listView.numItems = #self.awardData

    self.oneBtn.touchable = true
    self.tenBtn.touchable = true
    self.closeBtn.touchable = true
    self.tEffect.visible = false
end

function CoupleSuitsView:cellData(index,obj)
    local data = self.awardData[index+1]
    if data then 
        local awardData = data
        local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
        GSetItemData(obj, itemData, true)
    end
end

--抽奖
function CoupleSuitsView:onClickBuy(context)
    local data = context.sender.data
    
    cache.ActivityCache:setValentineRallfe(true) --设置一个情侣抽奖的flag

    self.times = data.status
    self.oneBtn.touchable = false
    self.tenBtn.touchable = false
    self.closeBtn.touchable = false
    local haveYb = cache.PackCache:getPackDataById(PackMid.gold).amount
    local needYb = self.onceCost * self.times
    if haveYb < needYb then 
        GComAlter(language.gonggong18)
        return 
    else
        proxy.ActivityProxy:sendMsg(1030313,{reqType = 1,arg1 = self.times})
    end
end

--服务器返回
function CoupleSuitsView:setData(data)
    self.data = data 
    -- print("抽到的奖励id",data.tarId)
    local maxScore = data.max
    self.singleScore.text = string.format(language.valentine02, data.personal)
    self.coupleScore.text = string.format(language.valentine03, data.couple)
    self.gots = {}
    for k,v in pairs(data.gots) do
        self.gots[v] = 1
    end
    for k,v in pairs(self.awards) do
        if maxScore >= v.integral then 
            if self.gots[v.id]  and self.gots[v.id] == 1 then
                self.controller1.selectedIndex = 1 --已经领取过了
                self.getTxt.text = string.format(language.valentine04,v.integral)
            else
                self.controller1.selectedIndex = 0 --可领取
                self.getTxt.text = string.format(language.valentine04,v.integral)
                break
            end 
        else
            self.controller1.selectedIndex = 2 --不可领
            self.getTxt.text = string.format(language.valentine04,v.integral)
            break
        end
    end
    local var = cache.PlayerCache:getRedPointById(attConst.A30136)
    if var > 0 then 
        self.getAwardBtn:GetChild("red").visible = true
    else
        self.getAwardBtn:GetChild("red").visible = false
    end


    if data.reqType == 1 then  --抽奖的
        if self.times == 1 then 
           self:playEffect()
        elseif self.times == 10 then 
            GOpenAlert3(self.data.items)
            self.oneBtn.touchable = true
            self.tenBtn.touchable = true
            self.closeBtn.touchable = true
        end
    end
    if not self.timer then
        self:timeTick()
        self.timer = self:addTimer(1, -1, handler(self,self.timeTick))
    end
end
--播放动效
function CoupleSuitsView:playEffect()
    
    self.tEffect.visible = true
    self.t0:Play()
    self:addTimer(4.15, 1, function()
        local tarId = self.data.tarId
        local pos = AwardPos[tarId]
        self.tList[pos]:Play()
        self:addTimer(TransitionDelay[pos], 1, function()
            self.oneBtn.touchable = true
            self.tenBtn.touchable = true
            self.closeBtn.touchable = true
            self:addTimer(0.8, 1, function ()
                self.tEffect.visible = false
                GOpenAlert3(self.data.items)
                cache.ActivityCache:setValentineRallfe(false)
            end)
        end)
    end)
end

function CoupleSuitsView:timeTick()
    self.data.leftTime = self.data.leftTime -1
    if self.data.leftTime > 86400 then 
        self.leftTimes.text = GTotimeString7(self.data.leftTime)
    elseif self.data.leftTime <=0 then 
        self.data.leftTime = 0
        self.leftTimes.text = GTotimeString2(self.data.leftTime)
    else
        self.leftTimes.text = GTotimeString2(self.data.leftTime)
    end
end

--领取奖励
function CoupleSuitsView:getAward(context)
    local maxScore = self.data.max
    for k,v in pairs(self.awards) do
        if not self.data.gots[k] or self.data.gots[k] ~= v.id then 
            -- if maxScore < v.integral then
            --     GComAlter(language.valentine05)
            --     return
            -- else
                proxy.ActivityProxy:send(1030313,{reqType = 2,arg1 = v.id})
                -- break
            -- end
        end
    end
end
function CoupleSuitsView:setModel()
    local sex = cache.PlayerCache:getSex()
    -- local modelId =3010405
    -- if sex == 1 then 
    --     modelId = 3010305
    -- end
    local manModelId = 3010307
    local womanModelId = 3010407
    
    local weaponId = 3020407 --男女通用

    local modelObj = self:addModel(womanModelId,self.model)--女的
    modelObj:setSkins(womanModelId, weaponId)--武器id
    modelObj:setScale(180)
    modelObj:setRotationXYZ(0,166,0)
    modelObj:setPosition(-60,-190,100)

    local obj = self:addModel(manModelId,self.model2)--男的
    obj:setSkins(manModelId, weaponId)
    obj:setScale(180)
    obj:setRotationXYZ(0,166,0)
    obj:setPosition(60,-162,100)
end

function CoupleSuitsView:onBtnClose()
    self:closeView()
end

return CoupleSuitsView