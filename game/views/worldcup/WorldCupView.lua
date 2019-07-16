--
-- Author: 
-- Date: 2018-06-30 14:20:46
--
local WorldCupView = class("WorldCupView", base.BaseView)

local AwardShow = import(".AwardShow")--奖励展示
local ActivityGuess = import(".ActivityGuess")--活动竞猜
local TreasureChange = import(".TreasureChange")--珍品兑换


function WorldCupView:ctor()
    WorldCupView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function WorldCupView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n9")
    closeBtn.onClick:Add(self.onBtnClose,self)

    self.awardShow = AwardShow.new(self)--奖励展示
    self.activityGuess = ActivityGuess.new(self) --活动竞猜
    self.treasureChange = TreasureChange.new(self) --珍品兑换

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    self.leftTimeTxt = self.view:GetChild("n18")

    local ruleBtn = self.view:GetChild("n15")  
    ruleBtn.onClick:Add(self.onClickRule,self)
end

function WorldCupView:initData(data)
    self.c1.selectedIndex = data and data.index and data.index or 0

    if self.timertick then
        self:removeTimer(self.timertick)
        self.timertick = nil
    end
    if not self.timertick then 
        self:onTimer()
        self.timertick = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    self:refreshRedPoint()
    if self.c1.selectedIndex == 0 and self.awardShow then -- 奖励展示
        self.awardShow:initData()
    elseif self.c1.selectedIndex == 1 and self.activityGuess   then -- 活动竞猜
        self.activityGuess:initData()
    elseif self.c1.selectedIndex == 2 and self.treasureChange   then --珍品兑换
        self.treasureChange:initData()
    end
    local data = cache.ActivityCache:get5030111()
    if  data.acts[3059] and data.acts[3059] == 1 then 
        self.view:GetChild("n12").visible = true
    else
        self.view:GetChild("n12").visible = false
    end
end
function WorldCupView:refreshRedPoint()
    local var =  cache.PlayerCache:getRedPointById(attConst.A20178)--珍品兑换
    self.view:GetChild("n12"):GetChild("red").visible = var > 0 and true or false
end

function WorldCupView:onController1()
    if self.c1.selectedIndex == 0  then -- 奖励展示

    elseif self.c1.selectedIndex == 1  then -- 活动竞猜
        -- proxy.ActivityProxy:sendMsg(1030501,{reqType = 0,field = 0,teamId = 0,confId = 0})
    elseif self.c1.selectedIndex == 2  then --珍品兑换
        -- local
        local activeData = cache.ActivityCache:get5030111()
        proxy.ActivityProxy:sendMsg(1030502,{reqType = 0,cid = 0})
    end
end

--服务器返回信息
function WorldCupView:addMsgCallBack(data)
    if data.lastTime then 
        self.lastTime = data.lastTime
        -- print("self.lastTime",self.lastTime)
        -- self.leftTimeTxt.text = GTotimeString7(self.lastTime)
    end
    self:refreshRedPoint()
    if data.msgId == 5030501 then
        self.activityGuess:setData(data)
    elseif data.msgId == 5030502 then
        self.treasureChange:setData(data)
    end
end

--选择竞猜
function WorldCupView:goYaZhu()
    self.c1.selectedIndex = 1
end


function WorldCupView:onTimer()
    -- if self.c1.selectedIndex == 1  then -- 活动竞猜
    --     self.activityGuess:onTimer()
    -- elseif self.c1.selectedIndex == 2  then --珍品兑换
    --     self.treasureChange:onTimer()
    -- end
    if self.lastTime then 
        

        if tonumber(self.lastTime) > 86400 then 
            self.leftTimeTxt.text = GTotimeString7(self.lastTime)
        else
            self.leftTimeTxt.text = GTotimeString(self.lastTime)
        end
        if self.lastTime <= 0 then
           self:onBtnClose()
        end
        self.lastTime = self.lastTime - 1


    end
end

function WorldCupView:onClickRule()
    GOpenRuleView(1095)
end

function WorldCupView:onBtnClose()
    if self.timertick then
        self:removeTimer(self.timertick)
        self.timertick = nil
    end
    self:closeView()
end

return WorldCupView