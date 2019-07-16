--
-- Author: 
-- Date: 2018-10-22 15:09:46
--

local HalloweenRecharge = class("HalloweenRecharge", base.BaseView)

function HalloweenRecharge:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.openTween = ViewOpenTween.scale
end

function HalloweenRecharge:initView()
    local closeBtn = self.view:GetChild("n14")
    self:setCloseBtn(closeBtn)
    self.totalRechargeText = self.view:GetChild("n7")
    self.actCountDownText = self.view:GetChild("n9")
    self.awardList = self.view:GetChild("n10")
    self.awardList.itemRenderer = function (index,obj)
        self:setAwardData(index,obj)
    end
    self.awardList.numItems = 0
    self.awardList:SetVirtual()
    local actDec = self.view:GetChild("n3")
    actDec.text = language.wsjcz01

end

--[[
变量名：reqType     说明：0:显示 1:领取
变量名：cfgId       说明：配置id
变量名：gotSigns    说明：奖励领取标识
变量名：leftTime    说明：活动剩余时间
变量名：items       说明：奖励
变量名：rechargeSum 说明：累计充值的元宝数
--]]
function HalloweenRecharge:setData(data)
    self.data = data
    printt("万圣节累充>>>",data)
    self.actCountDown = data.leftTime 
    self.confData = conf.WSJConf:getHalloweenAward()
    self.totalRechargeText.text = data.rechargeSum

    local redNum = 0
    for k,v in pairs(self.confData) do
        if data.gotSigns and data.gotSigns[v.id] == 1 then -- 已领取
            self.confData[k].sign = 2
        else
            if data.rechargeSum >= v.quota then
                self.confData[k].sign = 0 -- 可领取
                redNum = redNum + 1
            else
                self.confData[k].sign = 1 -- 未达成条件
            end
        end
    end
    mgr.GuiMgr:redpointByVar(30222,redNum,1)

    table.sort(self.confData,function(a,b)
        if a.sign ~= b.sign then
            return a.sign < b.sign
        elseif a.quota ~= b.quota then 
            return a.quota < b.quota
        end
    end)
    self.awardList.numItems = #self.confData
    
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))      
    end

    local model = self.view:GetChild("n2")
    local modelId = conf.WSJConf:getValue("wsj_xianqi_model")[1]
    local model1 = self:addModel(modelId,model)
    model1:setPosition(81,-548,117)
    model1:setRotationXYZ(345,171,4.7)
    model1:setScale(180,180,180)
end

function HalloweenRecharge:setAwardData(index,obj)
    local listData = self.confData[index+1]
    local rechargeText = obj:GetChild("n0")
    local awardList = obj:GetChild("n1")
    local quotaText = obj:GetChild("n0")
    quotaText.text = string.format(language.wsjcz02,listData.quota)
    if listData then
        awardList.itemRenderer = function (_index,_obj)
            local itemData = listData.items[_index+1]
            local data = {mid = itemData[1],amount = itemData[2],bind = itemData[3]}
            GSetItemData(_obj, data, true)
        end
        awardList.numItems = #listData.items

        local getBtn = obj:GetChild("n2")
        getBtn.data = listData
        local redImg = getBtn:GetChild("red")
        local c1 = obj:GetController("c1")

        if listData.sign == 2 then -- 已领取
            c1.selectedIndex = 2 
        elseif listData.sign == 0 then -- 可领取
            getBtn.data.state = 1
            c1.selectedIndex = 1
            redImg.visible = true
        elseif listData.sign == 1 then -- 条件未达成
            c1.selectedIndex = 0
            getBtn.data.state = 2
            redImg.visible = false                   
        end
        getBtn.onClick:Add(self.btnOnClick,self)
    end
end

function HalloweenRecharge:btnOnClick(context)
    local btn = context.sender
    local btnData = btn.data
    if btnData.state == 2 then
        GComAlter("未达到领取条件")
    else
        proxy.ActivityProxy:sendMsg(1030639,{reqType = btnData.state,cfgId = btnData.id})
    end
end

function HalloweenRecharge:onTimer()
    if not self.data then return end
    self.actCountDown = math.max(self.actCountDown - 1,0)    
    if self.actCountDown <= 0 then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
        self:closeView()
        return
    end
    if self.actCountDown >= 86400 then
        self.actCountDownText.text = GGetTimeData3(self.actCountDown)
    else
        self.actCountDownText.text = GGetTimeData4(self.actCountDown)      
    end
end

return HalloweenRecharge