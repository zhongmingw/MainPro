--
-- Author: 
-- Date: 2018-08-04 17:24:30
--充值抽抽乐

local ChargePumpView = class("ChargePumpView", base.BaseView)

function ChargePumpView:ctor()
    ChargePumpView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ChargePumpView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    local ruleBtn = self.view:GetChild("n9")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    local dec1 = self.view:GetChild("n12")
    dec1.text = language.czccl01

    local dec2 = self.view:GetChild("n15")
    dec2.text = language.czccl02

    local dec3 = self.view:GetChild("n27")
    dec3.text = language.czccl03

    local dec4 = self.view:GetChild("n1")

    self.titleIcon = self.view:GetChild("n0"):GetChild("icon")


    local oneCount = conf.ActivityConf:getHolidayGlobal("czccl_one_count_yb")
    local t = clone(language.czccl04)
    t[2].text = oneCount
    dec4.text = mgr.TextMgr:getTextByTable(t)

    local oneBtn = self.view:GetChild("n17")
    oneBtn.data = 1
    oneBtn.onClick:Add(self.onClickPumpBtn,self)
    
    local tenBtn = self.view:GetChild("n18")
    tenBtn.data = 10
    tenBtn.onClick:Add(self.onClickPumpBtn,self)
    
    self.lastTime = self.view:GetChild("n8")
    --充值金额
    self.chargeNum = self.view:GetChild("n14")
    --抽取次数
    self.pumpTime = self.view:GetChild("n16")
    --全服次数
    self.allCount = self.view:GetChild("n28")

    self.boxlist = {}
    for i = 21 , 26 do
        local btn = self.view:GetChild("n"..i)
        btn.onClick:Add(self.onBoxCall,self)
        table.insert(self.boxlist,btn)
    end

    self.logsList = self.view:GetChild("n4")
    self.logsList.itemRenderer = function(index,obj)
        self:cellLogData(index, obj)
    end
    self.logsList:SetVirtual()

    self.showAwardList = self.view:GetChild("n11")
    self.showAwardList.itemRenderer = function(index,obj)
        self:cellShowData(index, obj)
    end
    self.showAwardList:SetVirtual()

    self.bar = self.view:GetChild("n20") 

end

function ChargePumpView:setData(data)
    self.data = data
    -- printt("充值抽抽乐>>>",data)
    --剩余抽取次数
    self.pumpTime.text = data.leftTimes
    --当前充值元宝
    self.chargeNum.text = data.czYb

    self.isGot = {}
    table.sort(self.data.gotData)
    for k,v in pairs(self.data.gotData) do
        self.isGot[v] = 1
    end

    self.time = data.lastTime
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    local mulStr = "czccl_award_show_"..tostring(self.data.mulActId)
    self.confData = conf.ActivityConf:getHolidayGlobal(mulStr)
    self.showAwardList.numItems = #self.confData
    self.logsList.numItems = #data.record

    self:setBoxList()
end
--设置宝箱
function ChargePumpView:setBoxList()
    --多开活动
    -- print(self.data.mulActId)
    self.mulActBoxData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIcon = self.mulActBoxData.title_icon or "chongzhichouchoule_001"
    self.titleIcon.url = UIPackage.GetItemURL("continue" , titleIcon)

    self.boxData = conf.ActivityConf:getCzcclBoxAwards(self.data.mulActId)
    self.max = 0
    self.valuelist = {}
    for k ,v in pairs(self.boxData) do
        -- if v.count > self.max then
        --     self.max = v.count
        -- end
        self.max = self.max + v.count
        table.insert(self.valuelist,v.count)
        local btn = self.boxlist[k]
        btn.data = v 
        btn:GetController("c1").selectedIndex = 0
        btn:GetChild("n4").text = v.count
        btn:GetChild("n3").text = string.format(language.czccl06,v.vip_level)
    end
    self.bar.max = self.max
    --全服次数
    self.allCount.text = self.data.sumTimes.."次"
    self.bar.value = self.data.sumTimes
    --设置箱子位置
    table.sort(self.valuelist)
    -- for k,v in pairs(self.boxlist) do
        -- v.x = self.bar.x +(self.valuelist[k]/self.max*self.bar.width)
    -- end
    -- local number = 0
    for k , v in pairs(self.boxlist) do
        v:GetChild("n6").visible = false
        if not self.isGot[v.data.count] then
            if v.data.vip_level <= cache.PlayerCache:getVipLv() and v.data.count <= self.data.sumTimes then
                v:GetController("c1").selectedIndex = 1--可以领
                -- number = 1
                v:GetChild("n6").visible = true
            else
                v:GetController("c1").selectedIndex = 0--不可领
            end
        else
            v:GetController("c1").selectedIndex = 2--已领取
        end
    end
    --设置进度条
    self.bar.value = self.max 
    for k ,v in pairs(self.valuelist) do
        if v >= self.data.sumTimes then
            local dis = v -  (self.valuelist[k-1] or 0)
            local last = self.data.sumTimes - (self.valuelist[k-1] or 0)
            self.bar.value = 1/6*self.max*(k-1) +  1/6*self.max * last/dis
            break
        end
    end

    --刷新红点
    -- mgr.GuiMgr:redpointByVar(20198,number,1)

end

function ChargePumpView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
    end

    self.time = self.time - 1
end


function ChargePumpView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function ChargePumpView:cellShowData(index,obj)
    local data = self.confData[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemData, true)
    end
end

function ChargePumpView:cellLogData(index, obj)
    local data = self.data.record[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.houWang04, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

--抽奖
function ChargePumpView:onClickPumpBtn(context)
    local data = context.sender.data
    if not data or not self.data then return end
    if self.data.leftTimes < data  then
        GComAlter(language.czccl05)
        return
    end
    proxy.ActivityProxy:sendMsg(1030233,{reqType = 1,args = data})

end
--点击宝箱
function ChargePumpView:onBoxCall(context)
    local data = context.sender.data
    -- printt(data)
    if not data or not self.data then return end
    if self.isGot[data.count] then
        GComAlter(language.czccl07)
        return
    end
    if self.data.sumTimes < data.count or cache.PlayerCache:getVipLv()< data.vip_level then
        mgr.ViewMgr:openView2(ViewName.RewardView,data.awards)
        -- GComAlter(language.czccl08)
        return
    end
    proxy.ActivityProxy:sendMsg(1030233,{reqType = 2,args = data.id})

end


function ChargePumpView:onClickRule()
    GOpenRuleView(1120)
end

return ChargePumpView