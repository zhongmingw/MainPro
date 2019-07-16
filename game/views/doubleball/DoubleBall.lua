--
-- Author: 
-- Date: 2018-10-23 10:06:16
--

local DoubleBall = class("DoubleBall", base.BaseView)

local prizeGrageIcon = {
    {"shuangsheqiu_036","shuangsheqiu_037"},
    {"shuangsheqiu_038","shuangsheqiu_039"},
    {"shuangsheqiu_040","shuangsheqiu_041"},
    {"shuangsheqiu_042","shuangsheqiu_043"},
}
local grageIcon = {
    "shuangsheqiu_038",
    "shuangsheqiu_039",
    "shuangsheqiu_040",
    "shuangsheqiu_041",
    "shuangsheqiu_042",
    "shuangsheqiu_043",
    "shuangsheqiu_036",
    "shuangsheqiu_037",
}

function DoubleBall:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end

function DoubleBall:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n15")
    self:setCloseBtn(closeBtn)
    self.leftPanel = self.view:GetChild("n1")
    self.rightPanel = self.view:GetChild("n2")

    self.lastLotteryList = self.leftPanel:GetChild("n20")
    self.lastLotteryList.itemRenderer = function (index,obj)
        self:setLastLotteryNum(index,obj)
    end

    self.nextLotteryTimeText =  self.leftPanel:GetChild("n15")
    local timeConf = conf.ActivityConf:getValue("ball_lottery_time")
    self.nextLotteryTimeText.text = timeConf..":00:00"
    self.curPond = self.leftPanel:GetChild("n18")
    self.lastAwardsList = self.leftPanel:GetChild("n16")
    self.lastAwardsList.itemRenderer = function (index,obj)
        self:setAwardData(index,obj)
    end
    self.lastAwardsList.numItems = 0
    self.lastAwardsList:SetVirtual()

    self.lotteryRuleList = self.rightPanel:GetChild("n5")
    self.lotteryRuleList.itemRenderer = function (index,obj)
        self:setlotteryRuleData(index,obj)
    end
    self.lotteryRuleList.numItems = 0
    self.lotteryRuleList:SetVirtual()

    self.betAwardList = self.rightPanel:GetChild("n9")
    self.betAwardList.itemRenderer = function (index,obj)
        self:setbetAwardData(index,obj)
    end
    self.betAwardList.numItems = 0
    self.betAwardList:SetVirtual()

    self.selectBallList = self.view:GetChild("n63")
    self.selectBallList.itemRenderer = function (index,obj)
        self:setSelectNum(index,obj)
    end

    self.bettedBtn = self.view:GetChild("n57")
    -- self.bettedBtn.onClick:Add(self.btnOnClick,self)
    self.randomBetBtn = self.view:GetChild("n59")
    self.cost1 = self.randomBetBtn:GetChild("title")
    self.randomBetBtn.onClick:Add(self.btnOnClick,self)
    self.randomBetTenBtn = self.view:GetChild("n60")
    self.cost2 = self.randomBetTenBtn:GetChild("title")
    self.randomBetTenBtn.onClick:Add(self.btnOnClick,self)
    self.betBySelfBtn = self.view:GetChild("n61")
    self.betBySelfBtn.onClick:Add(self.btnOnClick,self)
    self.cost3 = self.betBySelfBtn:GetChild("title")
end

--[[
请求
变量名：ballInfo    说明：自选或加注信息

变量名：reqType 说明：0：显示 1：随机一注 2：随机十注 3：自选
变量名：moneyPool    说明：奖池
变量名：awardInfo    说明：获奖情况
变量名：myBallInfo   说明：自身投注情况  (key:轮数 {num:注数}) {1={ballInfos={1={num=1,buleBall=4,redBall={10,12,25,26,28,30}}2={num=1,buleBall=7,redBall={2,7,15,18,20,33}}}}}
变量名：items        说明：奖励    
变量名：lastBallInfo 说明：上轮开奖号码
变量名：chooseBallInfo  说明：选着投注的号码
--]]

function DoubleBall:setData(data)
    self.data = data
    GOpenAlert3(data.items )
    -- printt("双色球>>>",data)
    -- printt("获奖情况>>>",data.awardInfo)
    -- printt("投注情况>>>",data.myBallInfo)
    -- printt("上轮开奖号码>>>",data.lastBallInfo)
    -- printt("投注的号码>>>",data.chooseBallInfo)
    self.curPond.text = data.moneyPool
    self.confData = conf.ActivityConf:getDoubleBallAward()
    self.oneCost = conf.ActivityConf:getValue("ball_lottery_cost")
    self.cost1.text = self.oneCost[2]
    self.cost2.text = self.oneCost[2]*10
    self.cost3.text = self.oneCost[2]

    -- 拆分data.myBallInfo
    self.bettedData = {}
    for k,v in pairs(data.myBallInfo) do
        for i,j in pairs(v) do
            table.insert(self.bettedData,j)
        end
    end

    -- 每一注的信息
    self.curBettedData = {}
    for k,v in pairs(self.bettedData) do
        for i,j in pairs(v) do
            table.insert(self.curBettedData,j)
        end
    end
    -- printt("获奖情况>>>",data.awardInfo)
    -- 用于获奖情况动态赋值
    self.table = {
        {data.awardInfo[7],data.awardInfo[8]},
        {data.awardInfo[1],data.awardInfo[2]},
        {data.awardInfo[3],data.awardInfo[4]},
        {data.awardInfo[5],data.awardInfo[6]},    
    }

    local prizeRuleData = conf.ActivityConf:getValue("ball_lottery_award")
    -- 用于规则item动态赋值
    self.prizeRule = {
        {language.doubleball01,prizeRuleData[1].."%"},
        {language.doubleball02,prizeRuleData[2].."%"},
        {language.doubleball03,prizeRuleData[3]},
        {language.doubleball04,prizeRuleData[4]},
        {language.doubleball05,prizeRuleData[5]},
        {language.doubleball06,prizeRuleData[6]},
        {language.doubleball07,prizeRuleData[7].."%"},
        {language.doubleball07,prizeRuleData[8].."%"},
    }

    local lastBlueNum = data.lastBallInfo.buleBall
    local lastRedNumData = data.lastBallInfo.redBall
    -- 用于上次开奖号码动态赋值
    self.lastLottery = {}
    if #lastRedNumData ~= 0 then
        self.lastLottery = {
        lastRedNumData[1],
        lastRedNumData[2],
        lastRedNumData[3],
        lastRedNumData[4],
        lastRedNumData[5],
        lastRedNumData[6],
        lastBlueNum,
    }
    end

    table.sort(data.chooseBallInfo.redBall)
    local selectBlueNum = data.chooseBallInfo.buleBall
    local selectRedNumData = data.chooseBallInfo.redBall
    -- 用于选号号码动态赋值
    self.selectNum = {}
    if #selectRedNumData ~= 0 then
        self.selectNum = {
        selectRedNumData[1],
        selectRedNumData[2],
        selectRedNumData[3],
        selectRedNumData[4],
        selectRedNumData[5],
        selectRedNumData[6],
        selectBlueNum,
    }
    end

    self.selectBallList.numItems  = 7
    self.lastLotteryList.numItems = 7
    self.lastAwardsList.numItems = #prizeGrageIcon
    self.betAwardList.numItems = #self.confData
    self.lotteryRuleList.numItems = #prizeRuleData 

    self.bettedBtn.data = {myBallInfo = self.bettedData}
    self.bettedBtn.onClick:Add(self.btnOnClick,self)
end

-- 选号
function DoubleBall:setSelectNum(index,obj)
    local data = self.selectNum[index+1]
    if #self.data.chooseBallInfo.redBall == 0 then
        obj:GetChild("title").text = "g"
    else
        obj:GetChild("title").text = data
    end
end

-- 上轮获奖
function DoubleBall:setAwardData(index,obj)
    local data = prizeGrageIcon[index + 1]
    local prizeCount = self.table[index + 1]
    local firstIcon = obj:GetChild("n0")
    local secondIcon = obj:GetChild("n2")
    local firstBetCount = obj:GetChild("n1")
    local secondBetCount = obj:GetChild("n3")
    firstIcon.url = UIPackage.GetItemURL("doubleball",data[1])
    secondIcon.url = UIPackage.GetItemURL("doubleball",data[2])
    if self.data.awardInfo then
        firstBetCount.text = prizeCount[1]
        secondBetCount.text = prizeCount[2]         
    end
end

-- 上轮开奖号码
function DoubleBall:setLastLotteryNum(index,obj)
    local data = self.lastLottery[index+1]
    if #self.data.lastBallInfo.redBall == 0 then
        obj:GetChild("title").text = "g"
    else
        obj:GetChild("title").text = data
    end
end

-- 奖励规则
function DoubleBall:setlotteryRuleData(index,obj)
    local ruleData = self.prizeRule[index + 1]
    local data = grageIcon[index + 1]
    local dec1 = obj:GetChild("n0")
    local dec2 = obj:GetChild("n1")
    local dec3 = obj:GetChild("n2")
    dec1.url = UIPackage.GetItemURL("doubleball",data)
    dec2.text = ruleData[1]
    dec3.text = ruleData[2]
end

-- 投注所获奖励
function DoubleBall:setbetAwardData(index,obj)
    local awardData = self.confData[index + 1].items
    if awardData then
        for k,v in pairs(awardData) do
            local itemData = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(obj, itemData, true)
        end
    end
end

function DoubleBall:btnOnClick(context)
    local btn = context.sender
    local btnData = btn.data
    local ingots = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if ingots <= 0 and btn.name ~= "n57" then
        self:gotoRecharge()
        return
    end
    if btn.name == "n57" then -- 已投列表
        mgr.ViewMgr:openView2(ViewName.BetedPanel,self.data)
    elseif btn.name == "n59" then -- 随机投注
        if ingots < self.oneCost[2] then
            self:gotoRecharge()
            return
        else
            proxy.ActivityProxy:send(1030645,{reqType = 1})
        end
    elseif btn.name == "n60" then -- 随机十注
        if ingots < self.oneCost[2]*10 then
            self:gotoRecharge()
            return
        else
            proxy.ActivityProxy:send(1030645,{reqType = 2})
        end               
    elseif btn.name == "n61" then -- 自选投注
        if ingots < self.oneCost[2] then
            self:gotoRecharge()
            return
        else
            mgr.ViewMgr:openView2(ViewName.BetPanel,self.data)
        end
    end
end

function DoubleBall:gotoRecharge()
    GOpenView({id = 1042})
    self:closeView()
end

return DoubleBall