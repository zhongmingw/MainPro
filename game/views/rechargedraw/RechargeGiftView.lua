--
-- Author: Your Name
-- Date: 2018-07-23 15:01:01
--
--充值豪礼活动
local RechargeGiftView = class("RechargeGiftView", base.BaseView)

function RechargeGiftView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function RechargeGiftView:initView()
    local closeBtn = self.view:GetChild("n9")
    self:setCloseBtn(closeBtn)
    local guizeBtn = self.view:GetChild("n17")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.lastTime = 0
    self.needYb = conf.ActivityConf:getValue("czhl_gift_czyb")
    -- self.awardData = conf.ActivityConf:getValue("czhl_gift_awards_show")
    -- self.modelId = conf.ActivityConf:getValue("czhl_gift_showmodel")
    --模型参数
    -- self.modelParam = conf.ActivityConf:getValue("czhl_gift_showmodel_scale_pos_rot")

    self.timeTxt = self.view:GetChild("n21")
    self.sumYbTxt = self.view:GetChild("n24")
    self.bar = self.view:GetChild("n32")
    self.dec1 = self.view:GetChild("n22")
    self.dec2 = self.view:GetChild("n25")
    self.dec3 = self.view:GetChild("n26")
    self.dec4 = self.view:GetChild("n27")
    self.dec5 = self.view:GetChild("n28")
    self.dec6 = self.view:GetChild("n29")
    self.awardItem = self.view:GetChild("n30")
    self.modelPanel = self.view:GetChild("n31")

    local goToVipBtn = self.view:GetChild("n19")
    goToVipBtn.onClick:Add(self.onClickCharge,self)
    self.titleIcon = self.view:GetChild("icon")

end

function RechargeGiftView:initData()
    self.dec1.text = language.active53
    self.dec2.text = language.active54
    local textData = clone(language.active55)
    textData[2].text = string.format(textData[2].text,self.needYb)
    self.dec3.text = mgr.TextMgr:getTextByTable(textData)
    self.dec4.text = language.active56


end

function RechargeGiftView:initModel()
    -- printt("标记",self.modelId)
    if self.modelId[2] and self.modelId[2] == 2 then--展示是特效
        local effect = nil
        local _scale = self.modelParam[1][1]
        -- print("id",self.modelId[1])
        effect = self:addEffect(self.modelId[1], self.modelPanel)
        -- effect.Scale = Vector3.New(_scale,_scale,_scale)
        effect.LocalPosition = Vector3.New(self.modelParam[2][1],self.modelParam[2][2],self.modelParam[2][3])
    else
        local obj = nil
        if self.modelId[2] and self.modelId[2] == 1 then--模型是翅膀
            obj = self:addModel(GuDingmodel[1],self.modelPanel)
            obj:setSkins(nil,nil,self.modelId[1])
        else
            obj = self:addModel(self.modelId[1], self.modelPanel)
        end
        obj:setScale(self.modelParam[1][1])
        obj:setPosition(self.modelParam[2][1],self.modelParam[2][2],self.modelParam[2][3])
        obj:setRotationXYZ(self.modelParam[3][1],self.modelParam[3][2],self.modelParam[3][3])
    end
end

-- 变量名：reqType 说明：0:信息 1:领取
-- 变量名：lastTime    说明：剩余时间
-- 变量名：sumCzYb 说明：当前总充值
-- 变量名：gotSumTimes 说明：已领取总次数
-- array<SimpleItemInfo>   变量名：items   说明：奖励
function RechargeGiftView:setData(data)
    -- printt("充值豪礼信息>>>>>",data)
    self.data = data
    -- print("多开id",self.data.mulActId)
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "chongzhihaoli_001"
    self.titleIcon.url = UIPackage.GetItemURL("rechargedraw",titleIconStr)
    local awardData = conf.ActivityConf:getMulactiveshow(self.data.mulActId)
    local itemInfo = {mid = awardData.awards[1][1],amount = awardData.awards[1][2],bind = awardData.awards[1][3]}
    GSetItemData(self.awardItem, itemInfo, true)
    if self.mulConfData  and self.mulConfData.model_id and self.mulConfData.model_scale_pos_rot then
        --模型参数
        self.modelId = self.mulConfData.model_id[1]
        self.modelParam = self.mulConfData.model_scale_pos_rot[1]
        self:initModel()
    end
    
    self.sumYbTxt.text = data.sumCzYb
    local value = data.sumCzYb - data.gotSumTimes * self.needYb
    self.bar.value = value
    self.bar.max = self.needYb
    local textData = {
        {text = value,color = 7},
        {text = "/"..self.needYb,color = 7},
    }
    if value < self.needYb then
        textData[1].color = 14
    end
    self.dec5.text = mgr.TextMgr:getTextByTable(textData)

    --当前可领取礼包个数
    local textData2 = clone(language.active57)
    textData2[2].text = string.format(textData2[2].text,math.floor(data.sumCzYb/self.needYb)-data.gotSumTimes)
    self.dec6.text = mgr.TextMgr:getTextByTable(textData2)
    
    self.lastTime = data.lastTime
    if self.lastTime > 86400 then
        self.timeTxt.text = GGetTimeData3(self.lastTime)
    else
        self.timeTxt.text = GTotimeString(self.lastTime)
    end
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.timer = self:addTimer(1, -1, handler(self,self.timerClick))

    local getBtn = self.view:GetChild("n18")
    getBtn.onClick:Add(self.onClickGet,self)
end

function RechargeGiftView:timerClick()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        if self.lastTime > 86400 then
            self.timeTxt.text = GGetTimeData3(self.lastTime)
        else
            self.timeTxt.text = GTotimeString(self.lastTime)
        end
    else
        self:closeView()
    end
end

function RechargeGiftView:onClickGet()
    local getTimes = math.floor(self.data.sumCzYb/self.needYb)-self.data.gotSumTimes
    if getTimes > 0 then
        proxy.ActivityProxy:sendMsg(1030222,{reqType = 1})
    else
        GComAlter(language.active58)
    end
end

function RechargeGiftView:onClickCharge()
    GOpenView({id = 1042})
end

function RechargeGiftView:onClickGuize()
    GOpenRuleView(1106)
end

return RechargeGiftView