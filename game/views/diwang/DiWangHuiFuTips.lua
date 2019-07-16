--
-- Author: Your Name
-- Date: 2018-07-26 14:24:14
--

local DiWangHuiFuTips = class("DiWangHuiFuTips", base.BaseView)

function DiWangHuiFuTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function DiWangHuiFuTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.costIcon = self.view:GetChild("n3")
    --取消
    self.cancelBtn = self.view:GetChild("n1")
    self:setCloseBtn(self.cancelBtn)
    --确认
    self.sureBtn = self.view:GetChild("n2")
    self.sureBtn.onClick:Add(self.onClickSure,self)
    self.costTxt = self.view:GetChild("n5")
end

function DiWangHuiFuTips:initData(data)
    local leftColdTime = data.leftColdTime
    self.costData = conf.DiWangConf:getDiWangValue("clear_min_cost")
    self.costIcon.url = UIItemRes.moneyIcons[BuyMoneyType[self.costData[1]][1]]
    self.costTxt.text = self.costData[2]*(math.ceil(leftColdTime/60))
end

function DiWangHuiFuTips:onClickSure()
    local myCurrency = cache.PlayerCache:getTypeMoney(BuyMoneyType[self.costData[1]][1])
    if self.costData[2] <= myCurrency then
        proxy.DiWangProxy:sendMsg(1550104)
    else
        GComAlter(language.gonggong18)
    end
end

return DiWangHuiFuTips