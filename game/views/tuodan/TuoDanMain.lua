--
-- Author: 
-- Date: 2018-10-29 15:53:19
--

local TuoDanMain = class("TuoDanMain", base.BaseView)

function TuoDanMain:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end

function TuoDanMain:initView()
    local window = self.view:GetChild("n83")
    local closeBtn = window:GetChild("n5")
    self:setCloseBtn(closeBtn)
    self.actCountDownText = self.view:GetChild("n63")
    local ruleBtn = self.view:GetChild("n74")
    ruleBtn.onClick:Add(self.ruleOnClick,self)
    local actDec = self.view:GetChild("n64")
    self.toggle1 = self.view:GetChild("n66")
    self.toggle1.touchable = false
    self.rechargeQuota = self.view:GetChild("n68")
    self.toggle2 = self.view:GetChild("n69")
    self.toggle2.touchable = false
    self.tiQinCount = self.view:GetChild("n71")
    self.getBtn = self.view:GetChild("n73")
    self.getBtn.onClick:Add(self.btnOnClick,self)
    self.c1 = self.view:GetController("c1")

    self.rechargeYbText = self.view:GetChild("n67") -- 充值元宝
    self.marryTimesText = self.view:GetChild("n70") -- 提亲成功次数
end

--[[
变量名：reqType 说明：0=信息 1=领取
变量名：quota   说明：充值元宝
变量名：mTimes  说明：提亲次数
变量名：lastTime    说明：剩余活动时间
变量名：items   说明：奖励
变量名：awardGot    说明：1=奖励已领取
--]]
function TuoDanMain:setData(data)
    self.data = data
    -- printt("脱单进行时>>>",data)
    GOpenAlert3(data.items)
    self.actCountDown = data.lastTime
    self.rechargeYb = conf.ActivityConf:getHolidayGlobal("qlch_quota") -- 情侣称号充值元宝
    self.marryTimes = conf.ActivityConf:getHolidayGlobal("qlch_marry_times") -- 情侣称号结婚次数

    -- print(data.awardGot)
    if data.reqType == 1 and data.awardGot == 1 then
        self.c1.selectedIndex = 3
        self.getBtn.touchable = false
        self.getBtn:GetChild("red").visible = false
    end

    local redNum = 0
    if data.awardGot == 1 then
        self.c1.selectedIndex = 3
        self.getBtn.touchable = false
        self.getBtn:GetChild("red").visible = false
        self.toggle1.selected = true
        self.toggle2.selected = true        
    else
        if data.quota < self.rechargeYb then -- 前往充值
            self.c1.selectedIndex = 0
        else
            self.toggle1.selected = true
        end
        if data.mTimes < self.marryTimes then -- 前往提亲
            self.c1.selectedIndex = 1
        else
            self.toggle2.selected = true
        end
        if data.quota < self.rechargeYb and data.mTimes < self.marryTimes then
            self.c1.selectedIndex = 0
        elseif data.quota >= self.rechargeYb and data.mTimes >= self.marryTimes then
            self.c1.selectedIndex = 2
            redNum = redNum + 1
            self.getBtn:GetChild("red").visible = true
        end
    end

    mgr.GuiMgr:redpointByVar(20209,redNum,1)

    self.rechargeQuota.text = string.format(language.tuodan01,data.quota)..self.rechargeYb
    self.tiQinCount.text = string.format(language.tuodan01,data.mTimes)..self.marryTimes
    self.rechargeYbText.text = string.format(language.tuodan02,self.rechargeYb)
    self.marryTimesText.text = string.format(language.tuodan03,self.marryTimes)

    if self.actTimer then
        self:releaseTimer()
    end
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function TuoDanMain:btnOnClick(context)
    local btn = context.sender
    local data = btn.data
    if self.c1.selectedIndex == 0 then
        GOpenView({id = 1042})
        self:closeView()
        return
    elseif self.c1.selectedIndex == 1 then -- 前往提亲
        mgr.ViewMgr:openView2(ViewName.MarryApplyView)
        self:closeView()
        return
    elseif self.c1.selectedIndex == 2 then -- 领取
        proxy.ActivityProxy:sendMsg(1030254,{reqType = 1})
    end
end

function TuoDanMain:ruleOnClick()
    GOpenRuleView(1155)
end

function TuoDanMain:onTimer()
    if not self.data then return end
    self.actCountDown = math.max(self.actCountDown - 1,0)
    if self.actCountDown <= 0 then
        self:releaseTimer()
        self:closeView()
        return
    end
    if self.actCountDown >= 86400 then
        self.actCountDownText.text = mgr.TextMgr:getTextColorStr(GGetTimeData3(self.actCountDown),7)
    else
        self.actCountDownText.text = mgr.TextMgr:getTextColorStr(GGetTimeData4(self.actCountDown),7)
    end
end

function TuoDanMain:releaseTimer()
    self:removeTimer(self.actTimer)
    self.actTimer = nil
end

return TuoDanMain