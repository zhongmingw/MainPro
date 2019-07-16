--
-- Author: Your Name
-- Date: 2017-09-18 15:45:32
--
-- {record=},czCount=0,msgId=5030146,costScore=0,status=0,lastTime=248541,reqType=1,leftScore=0,itemInfos=},poolYb=0}
local MidasTouchView = class("MidasTouchView", base.BaseView)

function MidasTouchView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function MidasTouchView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n13")
    closeBtn.onClick:Add(self.onClickClose,self)
    --三个奖池
    self.awardsPoolPanel = {}
    for i=1,3 do
        local item = self.view:GetChild("n1"..i+1)
        table.insert(self.awardsPoolPanel,item)
    end
    --玩家当前充值和积分信息
    self.czInfoPanel = self.view:GetChild("n6")
    --记录列表
    self.recordList = self.view:GetChild("n37")
    self:initRecordList()
    --领取按钮
    self.getBtn = self.view:GetChild("n21")

    self.textDc = self.view:GetChild("n11")
    
    self.leftTimeTxt = self.view:GetChild("n9")
    self.bar = self.view:GetChild("n30")
    self.score1 = self.view:GetChild("n27")
    self.score2 = self.view:GetChild("n28")
    self.cost = self.view:GetChild("n29")
    self.award1 = self.view:GetChild("n25")
    self.award2 = self.view:GetChild("n26")
    self.guizeBtn = self.view:GetChild("n38")
    self.guizeBtn.onClick:Add(self.onClickGuize,self)
end

function MidasTouchView:onClickGuize()
    GOpenRuleView(1046)
end

function MidasTouchView:initData()
    if self.timers then
        self:removeTimer(self.timers)
        self.timers = nil 
    end

    local percent = conf.ActivityConf:getValue("dscj_daily_hy_score")
    local textData = {
                            {text = language.active25[1],color = 6},
                            {text = (percent/100) .."%",color = 7},
                            {text = language.active25[2],color = 6},
                        }
    self.textDc.text = mgr.TextMgr:getTextByTable(textData)
    self.leftTimeTxt.text = ""
    self.bar.value = 0
    local scoreAwards = conf.ActivityConf:getValue("dscj_score_consume_award")
    self.score1.text = scoreAwards[1][5]
    self.score2.text = scoreAwards[2][5]
    for i=1,2 do
        local awardInfo = {mid = scoreAwards[i][1], amount = scoreAwards[i][2], bind = scoreAwards[i][3]}
        GSetItemData(self.view:GetChild("n2"..i+4),awardInfo,true)
    end
    local param = clone(language.active26)
    param[2].text = string.format(param[2].text,0)
    self.cost.text = mgr.TextMgr:getTextByTable(param)
    --模型展示
    self:setModel()
    --活动计时
    self.timers = self:addTimer(1,-1,handler(self,self.onTiemr))
end

function MidasTouchView:onTiemr()
    if not self.data then
        self.leftTimeTxt.text = ""
        return
    end
    self.data.lastTime = self.data.lastTime - 1
    if self.data.lastTime < 0 then
        self.data.lastTime = 0
    end
    self.leftTimeTxt.text = GGetTimeData2(self.data.lastTime)
end

--设置奖池信息
function MidasTouchView:initAwardsPool()
    for id,item in pairs(self.awardsPoolPanel) do
        local itemData = conf.ActivityConf:getAwardsPoolById(id)
        local awardsList = item:GetChild("n9")
        awardsList.numItems = 0
        local minCzTxt = item:GetChild("n5")
        local costTxt = item:GetChild("n6") 
        local minCz = itemData.need_min_cz
        local cost = itemData.single_cost
        local textData1 = {
                            {text = language.active21[1],color = 6},
                            {text = minCz,color = 7},
                            {text = language.active21[2],color = 6},
                        }
        minCzTxt.text =  mgr.TextMgr:getTextByTable(textData1)
        local textData2 = {
                            {text = language.active22[1],color = 6},
                            {text = cost,color = 7},
                            {text = language.active22[2],color = 6},
                        }
        costTxt.text =  mgr.TextMgr:getTextByTable(textData2)

        --奖池显示
        local awardsPool = itemData.award_pool
        for k,awardT in pairs(awardsPool) do
            local objItemUrl = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local Obj = awardsList:AddItemFromPool(objItemUrl)
            local awardInfo = {mid = awardT[1], amount = awardT[2], bind = awardT[3]}
            GSetItemData(Obj,awardInfo,true)
        end
        --抽奖按钮
        local getBtn = item:GetChild("n7")
        local data = {reqType = 2,cfgId = id,itemData = itemData}
        getBtn.data = data
        getBtn.onClick:Add(self.onClickGet,self)
        if self.data.czCount >= itemData.need_min_cz and self.data.leftScore >= itemData.single_cost then
            getBtn:GetChild("red").visible = true
        else
            getBtn:GetChild("red").visible = false
        end
    end
end

--玩家当前充值信息
function MidasTouchView:setCzInfo(data)
    local leftScoreTxt = self.czInfoPanel:GetChild("n7")
    local czCountTxt = self.czInfoPanel:GetChild("n4")
    local poolYbTxt = self.czInfoPanel:GetChild("n9")
    leftScoreTxt.text = data.leftScore
    czCountTxt.text = data.czCount
    poolYbTxt.text = data.poolYb
end

--记录list
function MidasTouchView:initRecordList()
    self.recordList.numItems = 0
    self.recordList.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.recordList:SetVirtual()
end

function MidasTouchView:celldata( index,obj )
    local data = self.data.record[index+1]
    if data then
        local str = string.split(data,"#")
        local recordTxt = obj:GetChild("n0")
        recordTxt.text = str[1]..language.active28..str[2]
    end
end

--抽奖和领取
function MidasTouchView:onClickGet( context )
    local data = context.sender.data
    if data.reqType == 2 then
        local itemData = data.itemData
        if self.data.czCount >= itemData.need_min_cz and self.data.leftScore >= itemData.single_cost then
            proxy.ActivityProxy:sendMsg(1030146,{reqType = data.reqType,cfgId = data.cfgId})
        else
            if self.data.czCount < itemData.need_min_cz then--当日充值不足
                GComAlter(language.active23)
            elseif self.data.leftScore < itemData.single_cost then--当日消费积分不足
                GComAlter(language.active24)
            end
        end
    elseif data.reqType == 3 then
        if data.fashionMid then
            proxy.ActivityProxy:sendMsg(1030146,{reqType = data.reqType,fashionMid = data.fashionMid})
        else
            GComAlter(language.active27)
        end
    end
end

--设置展示模型
function MidasTouchView:setModel()

    self.model = self.view:GetChild("n19")
    local sex = cache.PlayerCache:getSex()
    local modelId = 4020210
    if sex ~= 1 then
        modelId = 4020211
    end
    local effect = self:addEffect(modelId,self.model)
    effect.Scale = Vector3.New(80,80,80)
    effect.LocalPosition = Vector3(0,-40,200)
    effect.LocalRotation = Vector3(350,0,0)
end

function MidasTouchView:setData(data)
    -- print("点石成金信息",data)
    -- printt(data.record)--{S2.邴俊伟#997,S2.邴俊伟#967},
    self.data = data
    --记录
    local records = data.record
    self.recordList.numItems = #records
    
    if #records > 0 then
        self.recordList:ScrollToView(#records-1)
    end
    local maxScore = conf.ActivityConf:getValue("dscj_daily_score_max")
    local scoreAwards = conf.ActivityConf:getValue("dscj_score_consume_award")
    --倒计时
    self.leftTimeTxt.text = GGetTimeData2(data.lastTime)

    local param = clone(language.active26)
    param[2].text = string.format(param[2].text,data.costScore)
    self.cost.text = mgr.TextMgr:getTextByTable(param)
    self.bar.value = data.costScore
    self.bar.max = scoreAwards[2][5]

    --领取{221071034,1,1,988,1000}
    self.awardFlagList = {[scoreAwards[1][1]] = 0,[scoreAwards[2][1]] = 0}--两个奖励领取情况
    for k,v in pairs(data.fashionGotList) do
        self.awardFlagList[v] = 1
    end
    local index = 0
    for i=1,2 do
        if data.costScore >= scoreAwards[i][5] then
            index = index + 1
        end
    end
    local fashionMid = nil
    if index >= 1 then
        for i=1,index do
            if self.awardFlagList[scoreAwards[i][1]] == 0 then
                fashionMid = scoreAwards[i][1]
                break
            end
        end
    end
    if fashionMid then
        self.getBtn:GetChild("n5").visible = true
        self.getBtn.grayed = false
    else
        self.getBtn:GetChild("n5").visible = false
        self.getBtn.grayed = true
    end
    for i=1,2 do
        local awardItem = self.view:GetChild("n2"..4+i)
        if self.awardFlagList[scoreAwards[i][1]] == 0 then
            awardItem:GetChild("n6").visible = false
        else
            awardItem:GetChild("n6").visible = true
        end
    end
    self.getBtn.data = {reqType = 3,fashionMid = fashionMid}
    self.getBtn.onClick:Add(self.onClickGet,self)
    --充值和积分信息
    self:setCzInfo(data)
    --奖池
    self:initAwardsPool()
end

function MidasTouchView:onClickClose()
    cache.PlayerCache:setAttribute(30123,self.data.costScore)
    GIsOpenWishPop(30123)
    self:closeView()
end

return MidasTouchView