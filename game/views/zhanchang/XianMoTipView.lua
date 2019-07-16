--
-- Author: 
-- Date: 2017-08-30 14:40:08
--

local XianMoTipView = class("XianMoTipView", base.BaseView)

local EXPID = PackMid.exp

function XianMoTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianMoTipView:initView()
    self.c1 = self.view:GetController("c1")--主控制器
    self.c1.onChanged:Add(self.onChangedC1,self)--给控制器获取点击事件
    local closeBtn = self.view:GetChild("n6")
    closeBtn.onClick:Add(self.onClickClose,self)
    local btn1 = self.view:GetChild("n4")
    btn1:GetChild("title").text = language.xianmoWar04[1]
    local btn2 = self.view:GetChild("n5")
    btn2:GetChild("title").text = language.xianmoWar04[2]
    self:initAward()
    self:initRank()
end

function XianMoTipView:initAward()
    local panel = self.view:GetChild("n2")
    panel:GetChild("n5").text = language.xianmoWar01
    panel:GetChild("n6").text = language.xianmoWar02
    panel:GetChild("n7").text = language.xianmoWar03
    
    self.winAwardData = conf.XianMoConf:getXianmoAward(2)--胜利阵营奖励
    local winAwardView = panel:GetChild("n2")--胜利阵营奖励
    self.winAwardView = winAwardView
    winAwardView:SetVirtual()
    winAwardView.itemRenderer = function(index,obj)
        self:cellWinAwards(index, obj)
    end

    self.failAwardData = conf.XianMoConf:getXianmoAward(3)--失败阵营奖励
    local failAwardView = panel:GetChild("n3")--失败阵营奖励
    self.failAwardView = failAwardView
    failAwardView:SetVirtual()
    failAwardView.itemRenderer = function(index,obj)
        self:cellFailAwards(index, obj)
    end

    self.personalAwardDatas = conf.XianMoConf:getXianmoAward(1)--个人排名奖励
    table.sort(self.personalAwardDatas,function(a,b)
        return a.id < b.id
    end)
    local rankAwardView = panel:GetChild("n4")--个人排名奖励
    rankAwardView:SetVirtual()
    rankAwardView.itemRenderer = function(index,obj)
        self:cellRankAwards(index, obj)
    end
    rankAwardView.numItems = #self.personalAwardDatas
    self:setWinFailAwards()
end

function XianMoTipView:initRank()
    local panel = self.view:GetChild("n3")
    --仙排行榜
    self.xianRankList = panel:GetChild("n7")
    self.xianRankList:SetVirtual()
    self.xianRankList.itemRenderer = function(index,obj)
        self:cellXianRank(index, obj)
    end
    --魔排行榜
    self.moRankList = panel:GetChild("n11")
    self.moRankList:SetVirtual()
    self.moRankList.itemRenderer = function(index,obj)
        self:cellMoRank(index, obj)
    end
end

function XianMoTipView:onChangedC1()
    if self.c1.selectedIndex == 0 then--奖励
        self:setWinFailAwards()
    elseif self.c1.selectedIndex == 1 then--排行
        proxy.XianMoProxy:send(1420103)
    end
end
--设置胜利失败奖励
function XianMoTipView:setWinFailAwards()
    local expCoefs = conf.XianMoConf:getValue("exp_coef")
    local expXA,expXB = expCoefs[1],expCoefs[2]--经验系数A,B
    local top20AvgLev = cache.WenDingCache:getTop20AvgLev()--本服排名前20的平均等级
    local exp = expXA * top20AvgLev + expXB--公式

    local winCoef = self.winAwardData[1].coef or 0--胜利的经验
    local amount = math.floor(exp * (winCoef / 10000))
    local expData = {EXPID,amount,1}
    local awards = self.winAwardData[1].items or {}
    local winAwards = {}
    winAwards[1] = expData
    for k,v in pairs(awards) do
        table.insert(winAwards, v)
    end
    self.winAwards = winAwards
    self.winAwardView.numItems = #winAwards

    local failCoef = self.failAwardData[1].coef or 0--失败的经验
    local amount = math.floor(exp * (failCoef / 10000))
    local expData = {EXPID,amount,1}
    local awards = self.failAwardData[1].items or {}
    local failAwards = {}
    failAwards[1] = expData
    for k,v in pairs(awards) do
        table.insert(failAwards, v)
    end
    self.failAwards = failAwards
    self.failAwardView.numItems = #failAwards
end

function XianMoTipView:setData(data)
    self.xianTops = data.xianTops
    self.xianRankList.numItems = #self.xianTops
    self.moTops = data.moTops
    self.moRankList.numItems = #self.moTops
end
--胜利阵营奖励
function XianMoTipView:cellWinAwards(index,obj)
    local data = self.winAwards[index + 1]
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj, itemData, true)
end
--失败阵营奖励
function XianMoTipView:cellFailAwards(index,obj)
    local data = self.failAwards[index + 1]
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj, itemData, true)
end
--个人排名奖励
function XianMoTipView:cellRankAwards(index,obj)
    local rank = index + 1
    obj:GetChild("n1").text = rank
    local data = self.personalAwardDatas[rank]
    local expCoefs = conf.XianMoConf:getValue("exp_coef")
    local expXA,expXB = expCoefs[1],expCoefs[2]--经验系数A,B
    local top20AvgLev = cache.WenDingCache:getTop20AvgLev()--本服排名前20的平均等级
    local exp = expXA * top20AvgLev + expXB--公式

    local coef = data.coef or 0--排名的经验
    local amount = math.floor(exp * (coef / 10000))
    local expData = {EXPID,amount,1}
    local awards = data.items or {}
    local rankAwards = {}
    rankAwards[1] = expData
    for k,v in pairs(awards) do
        table.insert(rankAwards, v)
    end
    local listView = obj:GetChild("n0")
    listView.itemRenderer = function(i,obj)
        local award = rankAwards[i + 1]
        local itemData = {mid = award[1],amount = award[2],bind = award[3]}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #rankAwards
end

function XianMoTipView:cellXianRank(index,obj)
    local data = self.xianTops[index + 1]
    obj:GetChild("n0").text = data.rank
    obj:GetChild("n1").text = data.roleName
    obj:GetChild("n2").text = data.score
end

function XianMoTipView:cellMoRank(index,obj)
    local data = self.moTops[index + 1]
    obj:GetChild("n0").text = data.rank
    obj:GetChild("n1").text = data.roleName
    obj:GetChild("n2").text = data.score
end

function XianMoTipView:onClickClose()
    self.c1.selectedIndex = 0
    self:closeView()
end

return XianMoTipView