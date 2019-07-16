--
-- Author: Your Name
-- Date: 2018-07-03 19:11:34
--

local RechargeRebate = class("RechargeRebate", base.BaseView)

function RechargeRebate:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function RechargeRebate:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.listView = self.view:GetChild("n7")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function( index,obj )
        -- body
        self:celldata(index,obj)
    end
    self.listView.numItems = 0

    self.timeTxt = self.view:GetChild("n6")
end

-- 变量名：lastTime    说明：剩余时间
-- 变量名：czTimesData 说明：已充值领取元宝对应次数
-- 变量名：actId   说明：活动id
function RechargeRebate:setData(data)
    self.data = data
    self.confData = conf.ActivityConf:getRechargeRebate()
    self.listView.numItems = #self.confData
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.lastTime = data.lastTime
    self.timer = self:addTimer(1, -1, handler(self,self.timerClick))
    if self.lastTime > 86400 then
        self.timeTxt.text = GGetTimeData3(self.lastTime)
    else
        self.timeTxt.text = GTotimeString2(self.lastTime)
    end
end

function RechargeRebate:timerClick()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        if self.lastTime > 86400 then
            self.timeTxt.text = GGetTimeData3(self.lastTime)
        else
            self.timeTxt.text = GTotimeString2(self.lastTime)
        end
    else
        self.timeTxt.text = language.vip11
    end
end

function RechargeRebate:celldata(index,obj)
    local data = self.confData[index+1]
    if data then
        -- local ybTxt = obj:GetChild("n1")
        local rmbTxt = obj:GetChild("n6")
        local item1 = obj:GetChild("n7")
        local item2 = obj:GetChild("n10")
        local chargeBtn = obj:GetChild("n8")
        local getImg = obj:GetChild("n9")
        if self.data.czTimesData[data.quota] then--已领取
            getImg.visible = true
            chargeBtn.visible = false
        else
            getImg.visible = false
            chargeBtn.visible = true
        end
        chargeBtn.data = {price=data.rmb}
        chargeBtn.onClick:Add(self.GoToCharge,self)
        local mid = data.awards[1][1]
        local amount1 = data.quota
        local amount2 = data.awards[1][2]
        local bind = data.awards[1][3]
        local info1 = {mid = 221051001,amount = amount1,bind = 0}
        local info2 = {mid = mid,amount = amount2,bind = bind}
        GSetItemData(item1, info1, true)
        GSetItemData(item2, info2, true)
        -- ybTxt.text = data.quota*2
        rmbTxt.text = data.rmb
    end
end

function RechargeRebate:GoToCharge(context)
    local data = context.sender.data
    mgr.SDKMgr:pay(data)
end

return RechargeRebate