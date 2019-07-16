--
-- Author: ohf
-- Date: 2017-05-04 14:26:46
--
--排行信息（奖励，排行，战旗）
local WendingTipView = class("WendingTipView", base.BaseView)

local EXPID = PackMid.exp
local MaxFloor = 9

function WendingTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.floor = 1--记录第几层
end

function WendingTipView:initView()

    self.c1 = self.view:GetController("c1")--主控制器
    self.c1.onChanged:Add(self.onChangedC1,self)--给控制器获取点击事件
    local closeBtn = self.view:GetChild("n27")
    closeBtn.onClick:Add(self.onClickClose,self)
    local btn1 = self.view:GetChild("n28")
    btn1:GetChild("title").text = language.wending03[1]
    local btn2 = self.view:GetChild("n29")
    btn2:GetChild("title").text = language.wending03[2]
    local btn3 = self.view:GetChild("n30")
    self.btn3 = btn3
    btn3:GetChild("title").text = language.wending03[3]
    self:initAwards()
    self:initRanks()
    self:initWarFlag()
end
--奖励
function WendingTipView:initAwards()
    local panel = self.view:GetChild("n31")
    panel:GetChild("n1").text = language.wending07
    self.firstAwardList = panel:GetChild("n2")--首次登顶奖励
    self.firstAwardList:SetVirtual()
    self.firstAwardList.itemRenderer = function(index,obj)
        self:cellFirstAwards(index, obj)
    end
    self.awardsTitle = panel:GetChild("n10")
    self.floorAwardList = panel:GetChild("n4")--积分奖励
    self.floorAwardList.itemRenderer = function(index,obj)
        self:cellFloorAwards(index, obj)
    end
    self.msgsData = conf.WenDingConf:getWendMsgs()
    self.msgListView = panel:GetChild("n12")--积分描述
    self.msgListView.itemRenderer = function(index,obj)
        self:cellMsgData(index, obj)
    end
end

--排行
function WendingTipView:initRanks()
    local panel = self.view:GetChild("n32")
    self.rankList = panel:GetChild("n2")
    self.rankList:SetVirtual()
    self.rankList.itemRenderer = function(index,obj)
        self:cellRankData(index, obj)
    end
    panel:GetChild("n7").text = language.wending11
    panel:GetChild("n12").text = language.wending12
    self.myRankText = panel:GetChild("n8")--我的排名
    self.myNameText = panel:GetChild("n9")--我的名字
    self.myScoreText2 = panel:GetChild("n10")--我的积分
    self.scoreRankAwards = conf.WenDingConf:getRankAwards()
    self.scoreRanks = panel:GetChild("n13")--积分排行奖
    self.scoreRanks:SetVirtual()
    self.scoreRanks.itemRenderer = function(index,obj)
        self:cellScoreRanks(index, obj)
    end
end
--战旗
function WendingTipView:initWarFlag()
    local panel = self.view:GetChild("n33")
    panel:GetChild("n4").text = language.wending15
    self.holderText = panel:GetChild("n5")--持有者
    panel:GetChild("n6").text = language.wending16
    self.timeText = panel:GetChild("n7")--倒计时
    panel:GetChild("n8").text = language.wending17
    self.warFlagAwards = panel:GetChild("n2")--守旗奖励
    self.warFlagAwards:SetVirtual()
    self.warFlagAwards.itemRenderer = function(index,obj)
        self:cellWarFlagData(index, obj)
    end
    local score = conf.WenDingConf:getValue("got_flag_score")
    panel:GetChild("n11").text = string.format(language.wending18, score)
    local warBtn = panel:GetChild("n3")
    self.warBtn = warBtn
    warBtn.onClick:Add(self.onClickWarFlag,self)--前往抢夺
end

function WendingTipView:initData()
    if self.c1.selectedIndex == 0 then
        self:onChangedC1()
    else
        self.c1.selectedIndex = 0
    end
    local sId = cache.PlayerCache:getSId()
    local floor = tonumber(string.sub(sId,4,6))
    self.floor = floor
    if floor <= 8 then
        self.btn3.visible = false
    else
        self.btn3.visible = true
    end
end

function WendingTipView:setData(data)
    self.mData = data
    if self.mData.reqType == 1 then--奖励
        self:setAwards()
    elseif self.mData.reqType == 2 then--战旗
        self:setWarFlag()
    elseif self.mData.reqType == 3 then--排行
        self:setRanks()
    end
end
--奖励数据
function WendingTipView:setAwards()
    --升层奖励
    if self.floor >= MaxFloor then
        self.awardsTitle.text = language.wending17
    else
        self.awardsTitle.text = language.wending05[1]
    end
    self.floorAwards = conf.WenDingConf:getValue("first_max_floor_awards")
    self.firstAwardList.numItems = #self.floorAwards
    
    self.floorAwards2 = conf.WenDingConf:getFloorAwards(self.floor + 1) or {}
    if self.floor >= MaxFloor then
        self.floorAwards2 = conf.WenDingConf:getValue("flag_hold_awards")
    end
    self.floorAwardList.numItems = #self.floorAwards2
    self.msgListView.numItems = #self.msgsData
end

function WendingTipView:cellMsgData(index,obj)
    local key = index + 1
    local msgData = self.msgsData[key]
    local text = obj:GetChild("n0")
    if key == 1 then
        local score = conf.WenDingConf:getValue("kill_score")
        text.text = string.format(msgData.msg, score)
    elseif key == 2 then
        local confData = conf.WenDingConf:getFloorData(self.floor)
        local time = confData and confData.score_refresh_time or 0
        local score = confData and confData.score or 0
        text.text = string.format(msgData.msg, time, score)
    elseif key == 3 then
        local score = conf.WenDingConf:getValue("got_flag_score")
        text.text = string.format(msgData.msg, score)
    elseif key == 4 then
        local data = conf.WenDingConf:getValue("hold_flag_score")
        text.text = string.format(msgData.msg, data[1], data[2])
    end
end
--排行数据
function WendingTipView:setRanks()
    self.rankList.numItems = #self.mData.rankInfos
    self.rankList:ScrollToView(0)
    local myRank = self.mData.myRank
    self.myRankText.text = myRank.ranking
    self.myNameText.text = cache.PlayerCache:getRoleName()
    self.myScoreText2.text = myRank.score
    self.scoreRanks.numItems = #self.scoreRankAwards
end
--战旗数据
function WendingTipView:setWarFlag()
    local name = self.mData.flagGotName
    if not name or name == "" then
        name = language.juese04
    end
    self.holderText.text = name

    if name == cache.PlayerCache:getRoleName() then
        self.warBtn.enabled = false
    else
        self.warBtn.enabled = true
    end

    if not self.flagTimer then
        self:onTimer()
        self.flagTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.flagAwards = conf.WenDingConf:getValue("flag_hold_awards")
    self.warFlagAwards.numItems = #self.flagAwards
end

function WendingTipView:releaseTimer()
    if self.flagTimer then
        self:removeTimer(self.flagTimer)
        self.flagTimer = nil
    end
end

function WendingTipView:onTimer()
    if self.mData.flagGotTime <= 0 then
        self:releaseTimer()
        return
    end
    self.mData.flagGotTime = self.mData.flagGotTime - 1
    self.timeText.text = mgr.TextMgr:getTextColorStr(GTotimeString3(self.mData.flagGotTime), 7)..language.wending14
end
--首名登顶的奖励
function WendingTipView:cellFirstAwards(index,obj)
    local award = self.floorAwards[index + 1]
    local itemData = {mid = award[1],amount = award[2], bind = award[3],isGet = self.isGet}
    GSetItemData(obj, itemData, true)
end
--升层奖励
function WendingTipView:cellFloorAwards(index,obj)
    local isGotAwards = cache.WenDingCache:getIsGotAwards()
    local isGot = false
    if isGotAwards and isGotAwards == 1 and self.floor < MaxFloor then
        isGot = true
    end
    local award = self.floorAwards2[index + 1]
    local itemData = {mid = award[1],amount = award[2], bind = award[3], isGet = isGot}
    GSetItemData(obj, itemData, true)
end
--前十排行
function WendingTipView:cellRankData(index,cell)
    local rankData = self.mData.rankInfos[index + 1]
    cell:GetChild("n1").text = rankData.ranking
    cell:GetChild("n2").text = rankData.name
    cell:GetChild("n3").text = rankData.score
end
--积分排行奖
function WendingTipView:cellScoreRanks(index,cell)
    local data = self.scoreRankAwards[index + 1]
    cell:GetChild("n1").text = string.format(language.wending13, data.id)
    local listView = cell:GetChild("n2")
    local expCoefs = conf.WenDingConf:getValue("wending_exp_coef")
    local expXA,expXB = expCoefs[1],expCoefs[2]--经验系数A,B
    local top20AvgLev = cache.WenDingCache:getTop20AvgLev()--本服排名前20的平均等级
    local exp = expXA * top20AvgLev + expXB--公式
    local coef = data.coef or 0
    local amount = math.floor(exp * (coef / 10000))
    local expData = {EXPID,amount,1}
    local awards = data.awards or {}
    local scoreAwards = {}
    scoreAwards[1] = expData
    for k,v in pairs(awards) do
        table.insert(scoreAwards, v)
    end
    listView.itemRenderer = function(index,obj)
        local award = scoreAwards[index + 1]
        local itemData = {mid = award[1],amount = award[2], bind = award[3]}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #scoreAwards
end
--战旗奖励
function WendingTipView:cellWarFlagData(index,obj)
    local award = self.flagAwards[index + 1]
    local itemData = {mid = award[1],amount = award[2],bind = award[3]}
    GSetItemData(obj, itemData, true)
end

function WendingTipView:onChangedC1()
    if self.c1.selectedIndex ~= 2 then
        self:releaseTimer()
    end
    self:clear()
    local reqType = 1
    if self.c1.selectedIndex == 0 then
        reqType = 1
    elseif self.c1.selectedIndex == 1 then
        reqType = 3
    elseif self.c1.selectedIndex == 2 then
        reqType = 2
    end
    proxy.WenDingProxy:send(1350104,{reqType = reqType})
end
--前往抢夺战旗
function WendingTipView:onClickWarFlag()
    proxy.WenDingProxy:send(1350104,{reqType = 4})
    self:onClickClose()
end

function WendingTipView:onClickClose()
    self:clear()
    self:closeView()
end

function WendingTipView:clear()
    self.firstAwardList.numItems = 0
    self.floorAwardList.numItems = 0
    self.rankList.numItems = 0
    self.scoreRanks.numItems = 0
    self.warFlagAwards.numItems = 0
end

return WendingTipView