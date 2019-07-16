--
-- Author: 
-- Date: 2018-10-15 21:41:11
-- 累计消费

local Cumulative = class("Cumulative", base.BaseView)

function Cumulative:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end

function Cumulative:initView()
    local window = self.view:GetChild("n5")
    local closeBtn = window:GetChild("n9")
    self:setCloseBtn(closeBtn)
    self.costText = self.view:GetChild("n17")
    self.costText.text = " "
    self.actCountDownText = self.view:GetChild("n19")
    self.actCountDownText.text = " "
    self.awardList = self.view:GetChild("n6")
    self.awardList.itemRenderer = function ( index,obj )
        self:setAwardData(index,obj)
    end
    self.awardList.numItems = 0
    self.awardList:SetVirtual()

    local dec1 = self.view:GetChild("n16")
    dec1.text = language.ljxf1
    local dec2 = self.view:GetChild("n18")
    dec2.text = language.ljxf2
end

function Cumulative:initData()

end

--[[
变量名：reqType  说明：0:显示 1:领取
变量名：gotSigns 说明：奖励领取标识
变量名：leftTime 说明：活动剩余时间
变量名：items    说明：奖励
变量名：costSum  说明：累计消费的元宝数
变量名：cfgId    说明：配置id
变量名：mulActiveId 说明：多开活动id
--]]
function Cumulative:setData(data)
    self.data = data
    -- printt("累计消费>>>",data)
    GOpenAlert3(data.items)
    self.actCountDown = data.leftTime
    self.confData = conf.ActivityConf:getLJXFAward(data.mulActiveId)
    self.costText.text = data.costSum

    local redNum = 0
    for k,v in pairs(self.confData) do
        if data.gotSigns and data.gotSigns[v.quota] == 1 then
            self.confData[k].sign = 2 -- 已领取
        else
            if data.costSum >= v.quota then
                self.confData[k].sign = 0 -- 可领取
                redNum = redNum + 1
            else
                self.confData[k].sign = 1 -- 未达到消费额度
            end
        end
    end
    table.sort(self.confData,function(a,b)
        if a.sign ~= b.sign then
            return a.sign < b.sign
        elseif a.quota ~= b.quota then 
            return a.quota < b.quota
        end
    end)
    self.awardList.numItems = #self.confData
    mgr.GuiMgr:redpointByVar(30220,redNum,1)

    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

end

function Cumulative:setAwardData(index,obj)
    local awardData = self.confData[index+1]
    if awardData then
        local dec1 = obj:GetChild("n2")
        dec1.text = language.ljxf3
        local dec2 = obj:GetChild("n3")
        dec2.text = language.ljxf4
        local consume = obj:GetChild("n4")
        consume.text = awardData.quota
        local itemList = obj:GetChild("n5")
        itemList.itemRenderer = function ( _index,_obj )
            local itemData = awardData.items[_index+1]
            local data = {mid = itemData[1],amount = itemData[2],bind = itemData[3]}
            GSetItemData(_obj, data, true)
        end
        itemList.numItems = #awardData.items
        local c1 = obj:GetController("c1")
        local getBtn = obj:GetChild("n6")
        getBtn.data = awardData
        local redImg = getBtn:GetChild("n3") 
        if awardData.sign == 2 then -- 已领取
            c1.selectedIndex = 2 
        elseif awardData.sign == 0 then -- 可领取
            c1.selectedIndex = 1           
            getBtn.data.state = 1
            redImg.visible = true 
        elseif awardData.sign == 1 then -- 未达到消费额度
            c1.selectedIndex = 0
            getBtn.data.state = 2
            redImg.visible = false 
        end
        getBtn.onClick:Add(self.getBtnClick,self)
    end
end

function Cumulative:getBtnClick(context)
    local btn = context.sender
    local btnData = btn.data
    if btnData.state == 2 then
        GComAlter(language.ljxf5)
    else
        print(btnData.id)
        proxy.ActivityProxy:sendMsg(1030636,{reqType = btnData.state,cfgId = btnData.id})
    end
end

function Cumulative:onTimer()
    if not self.data then return end
    self.actCountDown = math.max(self.actCountDown - 1,0)
    if self.actCountDown <= 0 then
        print("活动结束")
        self:removeTimer(self.actTimer)
        self.actTimer = nil
        self:closeView()
        return
    end
    if self.actCountDown >= 86400 then
        self.actCountDownText.text = mgr.TextMgr:getTextColorStr(GGetTimeData3(self.actCountDown),7)
    else
        self.actCountDownText.text = mgr.TextMgr:getTextColorStr(GGetTimeData4(self.actCountDown),7)
    end
end

return Cumulative