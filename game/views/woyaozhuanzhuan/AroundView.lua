--
-- Author: 
-- Date: 2018-08-31 18:54:38
--

local AroundView = class("AroundView", base.BaseView)

local position = 
{
    {x = 343,y = 83,rotate = 315},
    {x = 342,y = 83,rotate = 0},
    {x = 342,y = 83,rotate = 45},
    {x = 341,y = 80,rotate = 90},
    {x = 341,y = 80,rotate = 135},
    {x = 341,y = 80,rotate = 180},
    {x = 343,y = 78,rotate = 225},
    {x = 343,y = 78,rotate = 270}
}

local dur = {0.75,1,1.25,1.5,1.75,2}

function AroundView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function AroundView:initView()
    --关闭按钮
    self.closeBtn = self.view:GetChild("n45")
    self:setCloseBtn(self.closeBtn )
    --self.closeBtn.onClick:Add(self.closeBtnClick,self)
    --抽一次按钮
    self.oneBtn = self.view:GetChild("n5")
    self.oneBtn.data = 1
    self.oneBtn.onClick:Add(self.btnClick,self)
    --抽十次按钮
    self.tenBtn = self.view:GetChild("n4")
    self.tenBtn.data = 2
    self.tenBtn.onClick:Add(self.btnClick,self)
    --领取按钮
    self.getAwardBtn = self.view:GetChild("n23")
    self.getAwardBtn.onClick:Add(self.btnClick,self)
    self.getAwardBtn.data = 3
    --取消动画
    self.actCancel = self.view:GetChild("n26")
    --抽奖动效
    self.t0 = self.view:GetTransition("t0")
    self.zhiZhen = self.view:GetChild("n30")
    self.tList = {}
    for i = 1,7 do
        table.insert(self.tList,self.view:GetTransition("t"..i))
    end
    self.bigAward = self.view:GetChild("n29")--金蛋
    self.bigAward1 = self.view:GetChild("n46")
    --抽一次消耗
    self.oneCostText = self.view:GetChild("n12") 
    --活动剩余时间
    self.leftTimeText = self.view:GetChild("n14")
    --奖池文本
    self.pondText = self.view:GetChild("n17")
    --抽奖提示文本(每抽...可获得)
    self.tipsText = self.view:GetChild("n20")
    --已抽奖次数
    self.drawCountText = self.view:GetChild("n22")
    --奖励展示
    self.award = {}
    for i = 31,38 do
        local item = self.view:GetChild("n"..i)
        table.insert(self.award,item)
    end
    --抽奖记录
    self.recordList = self.view:GetChild("n40")
    self.recordList.numItems = 0
    self.recordList.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
    self.recordList:SetVirtual()
    self.titleIcon = self.view:GetChild("n47")

end

function AroundView:initData()
    self.oneBtn.touchable = true
    self.tenBtn.touchable = true
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.oneCostConf = conf.ActivityConf:getValue("wyzz_one_cost")
    self.drawCountConf = conf.ActivityConf:getValue("wyzz_count")--抽x次可以领取
end

function AroundView:setData(data)
    self.data = data
    printt(data)
   
      --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "woyaozhuanzhuan_001"
    self.titleIcon.url = UIPackage.GetItemURL("woyaozhuanzhuan" , titleIconStr)
    -- self.Reward = conf.ActivityConf:getMulactiveshow(self.data.mulActId)

    self.request = nil
    self.isCanGet = nil
    self.leftTime = self.data.leftTime
    self:showAward()
    self.recordList.numItems = #self.data.logs
    self.drawCountText.text = self.data.lottryCount
    self.pondText.text = self.data.moneyPool
    self.oneCostText.text = self.oneCostConf[2]
    self.tipsText.text = string.format(language.woyaozhuanzhuan01,self.drawCountConf)
    if self.data.reqType == 1 then
        self:turn()
    else
        GOpenAlert3(self.data.items)
    end
    self.getAwardBtn.grayed = self.data.canGetTimes < 1
    --self.getAwardBtn.touchable = not self.getAwardBtn.grayed
    mgr.GuiMgr:redpointByVar(30178,self.data.canGetTimes,1)
end

function AroundView:showAward()
    local awardConf = conf.ActivityConf:getWyzzAward(self.mulConfData.award_pre)
    for k,v in pairs(awardConf) do
        if v.type == 1 then
            self.award[k].data = v.id
        end
        if v.awards then
            if v.type == 1 then
                local item = {}
                item.mid = v.awards[1][1]
                item.amount = v.awards[1][2]
                item.bind = v.awards[1][3]
                if v.quan ~= 1 then
                    item.isquan = true
                end
                GSetItemData(self.award[k]:GetChild("n0"),item,true) 
            else
                local bigAwardData = {}
                bigAwardData.mid = v.awards[1][1]
                bigAwardData.amount = v.awards[1][2]
                bigAwardData.bind = v.awards[1][3]
                if v.quan ~= 1 then
                    bigAwardData.isquan = true
                end
                GSetItemData(self.bigAward:GetChild("n0"),bigAwardData,true) 

                local bigAwardData1 = {}
                bigAwardData1.mid = v.awards[2][1]
                bigAwardData1.amount = v.awards[2][2]
                bigAwardData1.bind = v.awards[2][3]
                if v.quan ~= 1 then
                    bigAwardData1.isquan = true
                end
                GSetItemData(self.bigAward1:GetChild("n0"),bigAwardData1,true) 
            end
        else--奖池
            local ybIcon = self.award[k]:GetChild("n0"):GetChild("icon")
            self.award[k]:GetChild("n2").text = "奖池"..v.money_per.."%"
            ybIcon.scale = Vector2(0.8,0.8)
            ybIcon.pivotX = 0.5
            ybIcon.pivotY = 0.5
            local itemData = {mid = PackMid.gold,amount = 0 ,bind = 1,icon = UIItemRes.ingotType[1]}
            GSetItemData(self.award[k]:GetChild("n0"), itemData)
        end
    end 
end

function AroundView:cellData(index,obj)
    local data = self.data.logs[index+1]
    local text = obj:GetChild("n0")
    local content = string.split(data,"|")
    if content[1] == "2" then
        local userName = content[2]--玩家名
        local awardName = conf.ItemConf:getName(content[3])--奖励名称
        local awardCount = content[4]
        local str = mgr.TextMgr:getTextColorStr(userName,7)..mgr.TextMgr:getTextColorStr("幸运抽中了",6)..mgr.TextMgr:getTextColorStr(awardName,7)..mgr.TextMgr:getTextColorStr(awardCount,7)
        text.text = str
    else
        local userName = content[2]--玩家名
        local awardName = content[3]--奖励名称
        local str = mgr.TextMgr:getTextColorStr(userName,7)..mgr.TextMgr:getTextColorStr("幸运抽中了",6)..mgr.TextMgr:getTextColorStr(awardName,7)..mgr.TextMgr:getTextColorStr("绑元",7)
        text.text = str
    end
end
--抽奖动效
function AroundView:turn()
    if self.actCancel.selected then
        local pos = 0
        for k,v in pairs(self.award) do
            if v.data == self.data.cfgId then
                pos = k
                self.zhiZhen.position = Vector2(position[pos].x,position[pos].y)
                self.zhiZhen.rotation = position[pos].rotate
                GOpenAlert3(self.data.items)
            end
        end
    else
        local targetPos = 0
        for k,v in pairs(self.award) do
            if v.data == self.data.cfgId then
                targetPos = k
                self.t0:Play()
                self:setBtnStatus0()
                self:addTimer(2, 1, function ()
                    if targetPos == 2 then
                        self.t0:Play()                   
                        self:addTimer(2.25, 1, function ()
                            GOpenAlert3(self.data.items)
                            self:setBtnStatus1()
                        end)
                    elseif targetPos == 1 then
                        self.tList[7]:Play()
                        self:addTimer(2, 1, function ()
                            GOpenAlert3(self.data.items)
                            self:setBtnStatus1()
                        end)
                    else
                        self.tList[targetPos-2]:Play()
                        self:addTimer(dur[targetPos-2], 1, function ()
                            GOpenAlert3(self.data.items)
                            self:setBtnStatus1()
                        end)
                    end
                end)
            end
        end
    end
end

function AroundView:btnClick(context)
    if not self.data then
        return
    end
    local btn = context.sender
    local btnData = btn.data
    if cache.PlayerCache:getTypeMoney(MoneyType.gold) <= 0 then
        GOpenView({id = 1042})--前往充值
        return
    end
    if btn.name == "n23" then
        proxy.ActivityProxy:sendMsg(1030519,{reqType = btnData})
        if self.data.canGetTimes < 1 then
            return
        end
        GOpenAlert3(self.data.items)
    elseif btn.name == "n4" then
        proxy.ActivityProxy:sendMsg(1030519,{reqType = btnData})
        if not self.request then
            self.request = true
            self:addTimer(1, 1, function ()
                proxy.ActivityProxy:sendMsg(1030519,{reqType = 0})--刷新界面
            end)
        end
    elseif btn.name == "n5" then
        proxy.ActivityProxy:sendMsg(1030519,{reqType = btnData})
    end
end

function AroundView:onTimer()
    if not self.data then return end
    self.leftTime = math.max (self.leftTime - 1,0)

    if self.leftTime <= 0 then
        self:releaseTimer()
        self:closeView()
        return
    end
    if self.leftTime > 86400 then
        self.leftTimeText.text = GTotimeString7(self.leftTime)
    else
        self.leftTimeText.text = GTotimeString(self.leftTime)
    end
end

function AroundView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function AroundView:setBtnStatus0()
    self.oneBtn.touchable = false
    self.tenBtn.touchable = false
    self.getAwardBtn.touchable = false
end

function AroundView:setBtnStatus1()
    self.oneBtn.touchable = true
    self.tenBtn.touchable = true
    self.getAwardBtn.touchable = true
end

return AroundView