--
-- Author: 
-- Date: 2018-10-08 16:10:57
--剑神装备寻宝返还

local JianShenEquipReturn = class("JianShenEquipReturn", import("game.base.Ref"))

function JianShenEquipReturn:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function JianShenEquipReturn:initPanel()
    self.view = self.mParent.view:GetChild("n18")
    self.actCountDownText = self.view:GetChild("n5")

    self.awardList = self.view:GetChild("n3")
    self.awardList.itemRenderer = function (index,obj)
        self:setAwardData(index,obj)
    end
    self.awardList:SetVirtual()
    self.awardList.numItems = 0
end

--[[
变量名：reqType       说明：0:显示 1:领取
变量名：leftTime      说明：活动剩余时间
变量名：times         说明：寻宝次数
变量名：itemGotSigns  说明：已经领取的奖励 
变量名：items         说明：奖励
变量名：cid           说明：领取id    
--]]

function JianShenEquipReturn:setData(data)
    self.data = data
    -- printt("剑神装备寻宝返还>>>",data)
    self.actCountDown = data.leftTime
    self.awardConf = conf.ActivityConf:getJSEquipAward()
    self.isGot = {}
    for k,v in pairs(data.itemGotSigns) do
         self.isGot[v] = 1
    end
    local redNum = 0

    for k,v in pairs(self.awardConf) do
        if self.isGot[v.id] and self.isGot[v.id] == 1 then
            self.awardConf[k].sign = 2 -- 已领取
        else
            if data.times >= v.times then
                self.awardConf[k].sign = 0 -- 可领取
                redNum = redNum + 1
            else
                self.awardConf[k].sign = 1 -- 不符合条件                
            end
        end
    end
    table.sort(self.awardConf,function(a,b)
        if a.sign ~= b.sign then
            return a.sign < b.sign
        elseif a.id ~= b.id then 
            return a.id < b.id
        end
    end)
    self.awardList.numItems = #self.awardConf
    mgr.GuiMgr:redpointByVar(30219,redNum,1)
end

function JianShenEquipReturn:setAwardData(index,obj)
    if not self.data then return end
    local awardData = self.awardConf[index + 1]
    if awardData then
        local awardList = obj:GetChild("n1")
        GSetAwards(awardList,awardData.awards)
        local dec = obj:GetChild("n2")
        dec.text = string.format(language.jianshen1,awardData.times)
        local constText = obj:GetChild("n3")
        --设置字体
        local color
        if self.data.times < awardData.times then
            color = 14
        else
            color = 7        
        end
        local textData = {
                {text = tostring(self.data.times),color = color},
                {text = "/",color = 11},
                {text = tostring(awardData.times),color = 14}
            }
        constText.text = "("..mgr.TextMgr:getTextByTable(textData)..")"

        local getAwardBtn = obj:GetChild("n4")
        getAwardBtn.data = awardData
        local c1 = obj:GetController("c1")
        if awardData.sign == 2 then -- 已领取
            c1.selectedIndex = 2
        elseif awardData.sign == 0 then -- 可领取
            c1.selectedIndex = 1
            getAwardBtn.data.state = 1
            getAwardBtn:GetChild("red").visible = true
        elseif awardData.sign == 1 then -- 不符合条件
            c1.selectedIndex = 0 
            getAwardBtn.data.state = 2
            getAwardBtn:GetChild("red").visible = false
        end
        getAwardBtn.onClick:Add(self.getAwards,self)
    end
end

function JianShenEquipReturn:getAwards(context)
    local btn = context.sender
    local data = btn.data
    if data.state == 2 then
        GComAlter("条件未达成")
    else
        proxy.ActivityProxy:sendMsg(1030633,{reqType = data.state,cid = data.id})
    end
end

function JianShenEquipReturn:onTimer()
    if not self.data then return end
    if self.actCountDown <= 0 then
        self.mParent:onBtnClose()
        return
    end
    if self.actCountDown >= 86400 then
        self.actCountDownText.text = GGetTimeData3(self.actCountDown)
    else
        self.actCountDownText.text = GGetTimeData4(self.actCountDown)        
    end
    self.actCountDown = math.max(self.actCountDown - 1 , 0)
end

return JianShenEquipReturn