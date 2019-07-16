--
-- Author: 
-- Date: 2018-12-11 15:16:14
--

local ShengDanCharge = class("ShengDanCharge", base.BaseView)

function ShengDanCharge:ctor()
    ShengDanCharge.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ShengDanCharge:initView()
    self:setCloseBtn(self.view:GetChild("n11"))
    --充值按钮
    self.rechargeBtn = self.view:GetChild("n15")
    self.rechargeBtn.data = 0
    self.rechargeBtn.onClick:Add(self.onClickChargeBtn,self)
    --活动剩余时间
    self.lastTime = self.view:GetChild("n12")
    --当前充值元宝数
    self.rechargeAmount = self.view:GetChild("n16"):GetChild("n18")
    --充值，领取控制器
    self.c1 = self.view:GetController("c1")
    --充值奖励列表
    self.awardList = self.view:GetChild("n14")
    self.awardList.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
    self.awardList.numItems = 0
    --元宝数量列表
    self.YBList = self.view:GetChild("n19")
    self.YBList.itemRenderer = function (index,obj)
        self:cellYBData(index,obj)
    end
    self.YBList.numItems = 0
    self.YBList.onClickItem:Add(self.onClickYBList,self)

    local dec1 = self.view:GetChild("n13")
    dec1.text = language.zhongqiuhaoli01
    local dec2 = self.view:GetChild("n16")
    dec2.text = language.zhongqiuhaoli02

end
function ShengDanCharge:addMsgCallBack(data)
    -- printt("圣诞累充",data)
  
    if data.reqType == 1 then
        GOpenAlert3(data.items)
    end

    self.data = data
    self.condata = conf.ShengDanConf:getZqhlAward()
    
    self.rechargeAmount.text = self.data.czSum
    self.actLeftTime = self.data.leftTime
    
    self.YBList.numItems = #self.condata
    local index = 0
    for k,v in pairs(self.condata) do
        if not self.data.gotSigns[v.id] then  
            index = k
            break      
        end
    end
    if index == 0 then
        self.YBList:AddSelection(self.YBList.numItems-1,false)
        self.YBList:ScrollToView(self.YBList.numItems-1)
        self:setInfo(self.condata[self.YBList.numItems])
    else
        self.YBList:AddSelection(index-1,false)
        self.YBList:ScrollToView(index-1)
        self:setInfo(self.condata[index])
    end
    self:releaseTimer()
    if not actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end
function ShengDanCharge:setInfo(data)
    if not self.data then return end
    self.confcur = data
    --local id = self.confcur.id % 1000--标志位
    self.awardList.numItems = #self.confcur.item
    --设置按钮状态
    if self.data.gotSigns[self.confcur.id] and self.data.gotSigns[self.confcur.id] == 1 then
        self.rechargeBtn.data = 2 --已领取
        self.c1.selectedIndex = 1
    elseif self.data.czSum >= self.confcur.quota then
        self.rechargeBtn.data = 1 --可领取
        self.c1.selectedIndex = 0
        self.rechargeBtn.title = "可领取"
        self.rechargeBtn:GetChild("red").visible = true
        --self.YBList:GetChildAt(id-1):GetChild("red").visible = true
    else 
        self.rechargeBtn.data = 0 --前往充值
        self.c1.selectedIndex = 0
        self.rechargeBtn.title = "前往充值"
        self.rechargeBtn:GetChild("red").visible = false
    end
end

function ShengDanCharge:cellData(index,obj)
    local awardObj = self.confcur.item[index + 1]
    local itemData = {}
    itemData.mid = awardObj[1]
    itemData.amount = awardObj[2]
    itemData.bind = awardObj[3]
    GSetItemData(obj, itemData, true) 
end

function ShengDanCharge:cellYBData(index,obj)
    local data = self.condata[index + 1]
    obj.data = data
    local YBAmount = obj:GetChild("n5")
    YBAmount.text = data.quota
    local YBText = obj:GetChild("n6")
    YBText.text = language.zhongqiuhaoli04
    local dec3 = obj:GetChild("n4")
    dec3.text = language.zhongqiuhaoli03

    obj:GetChild("red").visible = (not self.data.gotSigns[data.id]) and data.quota <= self.data.czSum
end

function ShengDanCharge:onClickYBList(context)
    local btnData = context.data
    local data = btnData.data
    self:setInfo(data)
end

function ShengDanCharge:onClickChargeBtn(context)
    if not self.data then
        return
    end
    local data = context.sender.data
    if data == 1 then
        proxy.ShengDanProxy:sendMsg(1030668,{reqType = 1,cfgId = self.confcur.id})
    elseif data == 0 then
        GOpenView({id = 1042})
    elseif data == 2 then
        GComAlter("已领取")
    end
end


function ShengDanCharge:onTimer()
    if not self.data or not self.actLeftTime then return end
    self.lastTime.text = GGetTimeData2(self.actLeftTime)
    if self.actLeftTime <= 0 then
        self:releaseTimer()
        self:closeView()
    end
    self.actLeftTime = self.actLeftTime - 1
end

function ShengDanCharge:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

return ShengDanCharge