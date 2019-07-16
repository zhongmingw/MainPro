--
-- Author: 
-- Date: 2018-08-27 21:37:13
--

local WuDiXinYunXing = class("WuDiXinYunXing", base.BaseView)

function WuDiXinYunXing:ctor()
    WuDiXinYunXing.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function WuDiXinYunXing:initView()
    local closeBtn = self.view:GetChild("n4"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    local ruleBtn = self.view:GetChild("n8")  
    ruleBtn.onClick:Add(self.onClickRule,self)
    self.jiandingResultText = self.view:GetChild("n22") --鉴定结果
    self.rewardItem = self.view:GetChild("n37")  
    self.rewardItemNum = self.view:GetChild("n38") 
    self.rewardButton = self.view:GetChild("n39") 
    self.rewardButton.onClick:Add(self.GetAward,self)
    self.c1 = self.view:GetController("c1")
    self.costYbText = self.view:GetChild("n43") 
    self.autoButton = self.view:GetChild("n46") 
    self.startButton = self.view:GetChild("n41") 
    self.startButton.onClick:Add(self.ChouJiang,self)
    self.lastTime = self.view:GetChild("n7")
    self.numtext1 =  self.view:GetChild("n13")
    self.numtext2 =  self.view:GetChild("n16")
    self.numtext3 =  self.view:GetChild("n19")
    self.titleIcon = self.view:GetChild("n5")
    self.logsList = self.view:GetChild("n51") --记录
    self.logsList.itemRenderer = function(index,obj)
        self:cellLogData(index, obj)
    end
    self.logsList.numItems = 0
    self.logsList:SetVirtual()
    self.RewardList = self.view:GetChild("n47"):GetChild("n51") --奖励展示
    self.RewardList.itemRenderer = function(index,obj)
        self:cellRewardData(index, obj)
    end
    self.RewardList.numItems = 0
    self.itemList = self.view:GetChild("n35") --物品列表
    self.itemList.itemRenderer = function(index,obj)
        self:ItemData(index, obj)
    end
    self.itemList.numItems = 0
    self.wdxyxRandomCost = conf.ActivityConf:getHolidayGlobal("wdxyx_random_cost")
    self.wdxyxChangeCost = conf.ActivityConf:getHolidayGlobal("wdxyx_change_cost")
    self.wdxyxAwardRate = conf.ActivityConf:getHolidayGlobal("wdxyx_award_rate")
    self.wdxyx_Num = conf.ActivityConf:getHolidayGlobal("wdxyx_num")
    self.wdxyxRandomCost1 = {}
    for k,v in pairs(self.wdxyxRandomCost) do
        self.wdxyxRandomCost1 [v[1]] = v[2]
    end
    self.wdxyxChangeCost1 = {}
    for k,v in pairs(self.wdxyxChangeCost) do
        self.wdxyxChangeCost1 [v[1]] = v[2]
    end
end

function WuDiXinYunXing:setData(data)
    printt(data)
    self.data = data
    if self.data.reqType == 3 then --返回领取奖励状态时设置已领取
        self.c1.selectedIndex = 1
        GOpenAlert3(data.items,true)
    elseif self.data.reqType == 0 then --返回打开信息时设置领取奖励状态为
        if self.data.isHadAward == 0 then
            self.c1.selectedIndex = 1
        else 
            self.c1.selectedIndex = 0  
        end 
    elseif self.data.reqType == 1 then --返回抽奖状态时设置可领取
        if self.data.args == 0 then
            self.c1.selectedIndex = 0
        elseif self.data.args == 1 then
            print("ggggggggggggggggggggggg")
            self.c1.selectedIndex = 1
            GOpenAlert3(data.items,true)
            if self.autoButton.selected then
                self.c1.selectedIndex = 0
            end
        end
    end
     --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "wudixinyunxing_001"
    self.titleIcon.url = UIPackage.GetItemURL("continue" , titleIconStr)
    self.Reward = conf.ActivityConf:getMulactiveshow(self.data.mulActId)
    self.rewardItemNum.text  = tostring("X"..self.data.rate)
    self.numtext1.text = tostring("X"..self.wdxyx_Num[1])
    self.numtext2.text = tostring("X"..self.wdxyx_Num[2])
    self.numtext3.text = tostring("X"..self.wdxyx_Num[3])
    if  #self.data.gridData == 0 then  --显示问号图标情况下(已领取或未抽奖)
        self.rewardItem:GetController("c1").selectedIndex  = 0
    else
        self.rewardItem:GetController("c1").selectedIndex  = 1
        local confItem = conf.ActivityConf:getWuDiXinYunXingitem(self.data.gridData[2])
        local t = {}
        t.mid = confItem.item[1]
        t.amount = confItem.item[2]
        t.bind = confItem.item[3]
        GSetItemData(self.rewardItem:GetChild("n28"),t,true)
    end
    self.mul_active = conf.ActivityConf:getMulActById(self.data.mulActId)
    self.costYbText.text = tostring(self.wdxyxRandomCost1[self.mul_active.award_pre]) 
    self.logsList.numItems = #data.records
    self.RewardList.numItems = #self.Reward.awards
    self.itemList.numItems = 3
    self:releaseTimer()
    self.time = self.data.lastTime
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function WuDiXinYunXing:onClickRule()
    GOpenRuleView(1134)
end

function WuDiXinYunXing:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
    end
    self.time = self.time - 1
end

function WuDiXinYunXing:GetAward()
    if  self.data.isHadAward <= 0 then
        GComAlter(language.wudixinyunxing02)
    else
        local param = {}
        param.reqType = 3
        param.args = 0
        proxy.ActivityProxy:sendMsg(1030243,param)
    end
end

function WuDiXinYunXing:ChouJiang()
    if (self.autoButton.selected ==  false) and (self.c1.selectedIndex == 0) then --先领取奖励
         GComAlter(language.wudixinyunxing03)
         return
    end
    if self.autoButton.selected then  --设置自动领取并抽奖
        local param = {}
        param.reqType = 1
        param.args = 1
        proxy.ActivityProxy:sendMsg(1030243,param)
        return
    end
    if  self.data.isHadAward == 0 then
        local param = {}   --直接抽奖
        param.reqType = 1
        param.args = 0
        proxy.ActivityProxy:sendMsg(1030243,param)
    end
    
end

function WuDiXinYunXing:cellLogData(index,obj)
    local data = self.data.records[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.wudixinyunxing01, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

function WuDiXinYunXing:cellRewardData(index,obj)
    local data = self.Reward.awards[index+1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3]
    GSetItemData(obj,t,true)
end

function WuDiXinYunXing:ItemData(index,obj)
    obj:GetController("c1").selectedIndex = 0
    obj:RemoveEventListeners()
    if self.data.isHadAward <= 0 then --格子数据为O时或领取完奖励时
        obj:GetChild("n28"):GetController("c1").selectedIndex = 1
        obj.data = {args = index + 1}
        obj.onClick:Add(self.NoHuanYiGe,self)
        obj:GetController("c1").selectedIndex = 1
        local data = self.data.gridData[index+1] --刚好index+1 =1,2,3与格子id相对应
        local itemData
        itemData = conf.ActivityConf:getWuDiXinYunXingitem(data) 
        obj.data = {args = index + 1}
        local t = {}
        t.mid = itemData.item[1]
        t.amount = itemData.item[2]
        t.bind = itemData.item[3]
        obj:GetChild("n28"):GetController("c1").selectedIndex = 1
        GSetItemData(obj:GetChild("n28"):GetChild("n28"),t,true)
        obj:GetChild("n30").text = tostring(self.wdxyxChangeCost1[self.mul_active.award_pre*100+index+1])
    elseif #self.data.gridData > 0  then
        local data = self.data.gridData[index+1] --刚好index+1 =1,2,3与格子id相对应
        local itemData
        itemData = conf.ActivityConf:getWuDiXinYunXingitem(data) 
        obj.data = {args = index + 1}
        obj.onClick:Add(self.HuanYiGe,self)
        local t = {}
        t.mid = itemData.item[1]
        t.amount = itemData.item[2]
        t.bind = itemData.item[3]
        obj:GetChild("n28"):GetController("c1").selectedIndex = 1
        GSetItemData(obj:GetChild("n28"):GetChild("n28"),t,true)
        obj:GetChild("n30").text = tostring(self.wdxyxChangeCost1[self.mul_active.award_pre*100+index+1])
    end

end

function WuDiXinYunXing:HuanYiGe(context)
    local data = context.sender.data
    local param = {}
    param.reqType = 2
    param.args = data.args
    proxy.ActivityProxy:sendMsg(1030243,param)
end

function WuDiXinYunXing:NoHuanYiGe(context)
     GComAlter(language.wudixinyunxing04)
end

function WuDiXinYunXing:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

return WuDiXinYunXing