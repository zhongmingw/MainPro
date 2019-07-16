--
-- Author: 
-- Date: 2018-07-17 14:10:53
--神器寻主

local ShenQiFindMaster = class("ShenQiFindMaster", base.BaseView)

function ShenQiFindMaster:ctor()
    ShenQiFindMaster.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ShenQiFindMaster:initView()
    local closeBtn = self.view:GetChild("n1"):GetChild("n41")
    closeBtn.onClick:Add(self.onBtnClose,self)
    local dec = self.view:GetChild("n21")
    dec.text =language.sqxz01
    self.leftTime = self.view:GetChild("n22")
    self.leftTime.text = ""
    --左按钮
    self.getBtnLeft = self.view:GetChild("n37")
    self.getBtnLeftC1 = self.getBtnLeft:GetController("c1")
    self.getBtnLeft.onClick:Add(self.onClickGetBtn,self)
    --右按钮
    self.getBtnRight = self.view:GetChild("n45")
    self.getBtnRightC1 = self.getBtnRight:GetController("c1")
    self.getBtnRight.onClick:Add(self.onClickGetBtn,self)

    self.leftAwardList = self.view:GetChild("n27")
    self.rightAwardList = self.view:GetChild("n28")

    self.leftYb = self.view:GetChild("n32")
    self.rightYb = self.view:GetChild("n35")

    self.leftEffectPanel = self.view:GetChild("n25")
    self.rightEffectPanel = self.view:GetChild("n26")


end

function ShenQiFindMaster:setData(data)
    self.data = data
    printt("神器寻主",data)
    local confData = conf.ActivityConf:getSQXZAward()
    local leftData = confData[1]
    local rightData = confData[2]
    --描述
    local leftTitleIcon = self.view:GetChild("n18")
    leftTitleIcon.url = UIPackage.GetItemURL("shenqifind",leftData.name_icon)
    local rightTitleIcon = self.view:GetChild("n19")
    rightTitleIcon.url = UIPackage.GetItemURL("shenqifind",rightData.name_icon)

    --单笔充值
    self.leftYb.text = leftData.quota
    self.rightYb.text = rightData.quota
    --神器特效
    self:setEffect(self.leftEffectPanel,leftData.effect_id)
    self:setEffect(self.rightEffectPanel,rightData.effect_id)
    --奖励
    GSetAwards(self.leftAwardList, leftData.awards)
    GSetAwards(self.rightAwardList, rightData.awards)
    --0=不可领取 1:可领取 2:已领取
    self.getBtnLeftC1.selectedIndex = data.itemStatus[leftData.id]
    self.getBtnRightC1.selectedIndex = data.itemStatus[rightData.id]

    self.getBtnLeft.data = {awardId = leftData.id,state = self.getBtnLeftC1.selectedIndex}
    self.getBtnRight.data = {awardId = rightData.id,state = self.getBtnRightC1.selectedIndex}


    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function ShenQiFindMaster:setEffect(panel,effectId)
    local shenqi = self:addEffect(effectId,panel)
    shenqi.Scale = Vector3.New(60,60,60)
    shenqi.LocalPosition = Vector3.New(0,-50,300)
end

function ShenQiFindMaster:onClickGetBtn(context)
    local data = context.sender.data
    local awardId = data.awardId
    local state = data.state--状态
    if state == 0 then--不可伶
        GGoVipTequan(0)
        self:onBtnClose()
        return
    elseif state == 1 then
        proxy.ActivityProxy:sendMsg(1030217,{reqType = 1,awardId = awardId})
    end
end

function ShenQiFindMaster:onTimer()
    if self.data.lastTime then
        if self.data.lastTime > 86400 then 
            self.leftTime.text = GTotimeString7(self.data.lastTime)
        else
            self.leftTime.text = GTotimeString2(self.data.lastTime)
        end
        if self.data.lastTime <= 0 then
            self:onBtnClose()
        end
        self.data.lastTime = self.data.lastTime-1
    end
end

function ShenQiFindMaster:releaseTimer()
   if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function ShenQiFindMaster:onBtnClose()
    self:releaseTimer()
    self:closeView()
end

return ShenQiFindMaster