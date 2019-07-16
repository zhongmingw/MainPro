--
-- Author: 
-- Date: 2018-09-25 16:58:10
--圣印抽奖返还

local ShengYinReturn = class("ShengYinReturn", base.BaseView)

function ShengYinReturn:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ShengYinReturn:initView()
    self.closeBtn = self.view:GetChild("n1")
    self:setCloseBtn(self.closeBtn)
    self.actCountDownText = self.view:GetChild("n4")
    self.listView = self.view:GetChild("n5")
    self.listView.itemRenderer = function (index,obj)
        self:setAwardData(index,obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function ShengYinReturn:initData()
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

--[[
变量名：reqType      说明：0:显示 1:领取
变量名：leftTime     说明：活动剩余时间
变量名：times        说明：寻宝次数
变量名：itemGotSigns 说明：已经领取的奖励   
变量名：items        说明：奖励
变量名：cid          说明：领取id
--]]
    
function ShengYinReturn:setData(data)
        -- print(cache.PlayerCache:getRedPointById(20213),"$$$$$$$$$$$$$$")
    self.data = data
    self.actCountTime = data.leftTime 
    if data.msgId == 5030625 then
        self.awardConf = conf.ActivityConf:getSYReturn()
    elseif data.msgId == 5030417 then -- 合服
        self.awardConf = conf.ActivityConf:getXunBaoAwardbyactID(1189)
    end

    local num = 0
    --判断领取状态
    self.isGot = {}
    for k,v in pairs(data.itemGotSigns) do
        self.isGot[v] = 1
    end
    for k,v in pairs(self.awardConf) do
        if self.isGot[v.id] and self.isGot[v.id] == 1 then
            self.awardConf[k].sign = 2 -- 已领取
        else
            if data.times >= v.times then -- 可领取
                self.awardConf[k].sign = 0
                num = num + 1
            else
                self.awardConf[k].sign = 1 -- 条件未达成
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
    self.listView.numItems = #self.awardConf
    mgr.GuiMgr:redpointByVar(30217,num,1)
end

function ShengYinReturn:setAwardData(index,obj)
    if not self.data then return end
    local awardData = self.awardConf[index+1]
    local awardList = obj:GetChild("n1")
    GSetAwards(awardList,awardData.awards)
    local dec = obj:GetChild("n2")
    dec.text = string.format(language.syfh1,awardData.times)
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
    if awardData.sign == 2 then
        c1.selectedIndex = 2 -- 已领取
    elseif awardData.sign == 0 then
        c1.selectedIndex = 1
        getAwardBtn.data.state = 1 -- 可领取
        getAwardBtn:GetChild("red").visible = true
    else
        c1.selectedIndex = 0
        getAwardBtn.data.state = 0 -- 条件未达成
        getAwardBtn:GetChild("red").visible = false
    end
    getAwardBtn.onClick:Add(self.getAwards,self)
end

function ShengYinReturn:getAwards(context)
    local btnData = context.sender.data
    if btnData.state == 0 then
        GComAlter("条件未达成")
        return
    else
   
        if self.data.msgId == 5030625 then
            proxy.ActivityProxy:sendMsg(1030625,{reqType = btnData.state,cid = btnData.id})
        elseif  self.data.msgId == 5030417  then
            proxy.ActivityProxy:sendMsg(1030417,{reqType = btnData.state,cid = btnData.id})
        end
        
    end
end

function ShengYinReturn:onTimer()
    if not self.data then return end
    if self.actCountTime <= 0 then
        self:closeView()
        return
    end
    if self.actCountTime >= 86400 then
        self.actCountDownText.text = GGetTimeData3(self.actCountTime)
    else
        self.actCountDownText.text = GGetTimeData4(self.actCountTime)
    end
    self.actCountTime = self.actCountTime - 1
end

function ShengYinReturn:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end
 
return ShengYinReturn