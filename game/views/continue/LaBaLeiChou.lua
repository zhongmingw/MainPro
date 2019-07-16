--
-- Author: 
-- Date: 2019-01-03 09:22:55
--

local LaBaLeiChou = class("LaBaLeiChou", base.BaseView)

function LaBaLeiChou:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function LaBaLeiChou:initView()
    local closeBtn = self.view:GetChild("n6")
    self:setCloseBtn(closeBtn)

    self.dec1 = self.view:GetChild("n32")
    self.dec2 = self.view:GetChild("n33")
    self.dec3 = self.view:GetChild("n34")
    self.dec4 = self.view:GetChild("n35")


    
    
    --记录list
    self.logsList = self.view:GetChild("n14")
    self.logsList.itemRenderer = function(index,obj)
        self:cellLogData(index, obj)
    end
    self.logsList:SetVirtual()

    self.lastTime = self.view:GetChild("n9")


    self.oneBtn = self.view:GetChild("n20")
    self.oneBtn.data = 1
    self.oneBtn.onClick:Add(self.onClickLaBa,self)
    self.tenBtn = self.view:GetChild("n40")
    self.tenBtn.data = 10
    self.tenBtn.onClick:Add(self.onClickLaBa,self)
    self.getBtn = self.view:GetChild("n21")
    self.getBtn.onClick:Add(self.onClickGetBtn,self)
    self.costData1 = conf.LaBaConf2019:getValue("lb_lottery_cost")
    self.costData2 = conf.LaBaConf2019:getValue("lb_lottery_con")
    self.costData3 = conf.LaBaConf2019:getValue("lb_lottery")
    local oneCostTxt = self.view:GetChild("n38")
    oneCostTxt.text = "*"..self.costData1[1][2]
    local tenCostTxt = self.view:GetChild("n27")
    tenCostTxt.text = "*"..self.costData1[2][2]

    local text1 =  self.view:GetChild("n38")
    text1.text = "*"..  self.costData1[1][2]
    local text2 =  self.view:GetChild("n27")
    text2.text = "*"..  self.costData1[2][2]

    GSetItemData( self.view:GetChild("n31"), {mid = self.costData3[1],amount = 1,bind = 0}, true)
end

function LaBaLeiChou:setData(data)
    printt("累充",data)
    self.data = data
 

    self:refreshText()
    self:choujiangredPoint()

    if self:calCanGet() then
        self.getBtn.grayed = false
        self.getBtn:GetChild("n3").visible = true
    else
        self.getBtn.grayed = true
        self.getBtn:GetChild("n3").visible = false
    end
    if data.reqType == 1 then

        self.guangXiaoCom.visible = true
        local getAwardId = data.cid
        --目标位置
        local tarStep = getAwardId%1000
        self.curStep = 0
        print("~~~~",31+tarStep,0.1 * (42+tarStep),getAwardId)
        --计时器次数
        local time = 0
        self:addTimer(0.1,30+tarStep, function ()
            time = time + 1
            self.curStep = self.curStep + 1
            self.curStep = self.curStep%16
            self.curStep = self.curStep == 0 and 1 or self.curStep
            self.guangXiaoIcon.x = self.awardList[self.curStep].x 
            self.guangXiaoIcon.y = self.awardList[self.curStep].y 
            if time == 30+tarStep then
                self:addTimer(0.5, 1, function ()--延迟0.5秒打开窗口
                    self:setBtnTouch(true)
                    self.guangXiaoCom.visible = false
                    GOpenAlert3(data.items)
                end)
            end
        end)
    elseif data.reqType == 2 then
        GOpenAlert3(data.items)
    end

    self.time = data.leftTime
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.logsList.numItems = #self.data.record
end

function LaBaLeiChou:initData()
    self:setBtnTouch(true)
    self.awardList = {}
    for i=1,16 do
        local item = self.view:GetChild("n43"):GetChild("n"..(i+42))
        item.data = 1000 + i
        table.insert(self.awardList,item)
    end
    self.guangXiaoCom = self.view:GetChild("n43"):GetChild("n59")
    self.guangXiaoCom.visible = false
    --光效icon
    self.guangXiaoIcon = self.guangXiaoCom:GetChild("n59")
    for k,v in pairs(self.awardList) do
        local confData = conf.ActivityConf:getLBLCAwardPoolById(v.data)
        if confData then
            local item = confData.items
            local itemObj = {mid = item[1][1],amount = item[1][2],bind = item[1][3],isquan = true}
            GSetItemData(v, itemObj, true)
        end
    end
end

function LaBaLeiChou:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
    end
    self.time = self.time - 1
end

function LaBaLeiChou:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function LaBaLeiChou:setBtnTouch(flag)
    self.oneBtn.touchable = flag
    self.tenBtn.touchable = flag
end

function LaBaLeiChou:refreshText()
    self.dec1.text = string.format(language.labaDlhl2019_07,self.data.costSum or 0)
    self.dec2.text =  string.format(language.labaDlhl2019_08,self.data.rechargeSum or 0)
    local amount  =  cache.PackCache:getPackDataById( self.costData3[1]).amount or 0
    self.dec3.text = string.format(language.labaDlhl2019_06,amount )
    self.dec4.text = string.format(language.labaDlhl2019_05,self.costData2[2],self.costData2[1] )
end

function LaBaLeiChou:cellLogData(index,obj)
    local data = self.data.record[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.labaDlhl2019_11, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

function LaBaLeiChou:onClickGetBtn(context)
    local data = context.sender.data
    if not self:calCanGet() then --抽奖卷不足
        GComAlter(language.labaDlhl2019_12)
        return
    else
        proxy.ActivityProxy:send(1030692,{reqType = 3})
    end
end

function LaBaLeiChou:calCanGet()
   local cost1 =  math.floor((self.data.rechargeSum or 0)/ self.costData2[1]) --充值
   local cost2 =  math.floor((self.data.costSum or 0 )/ self.costData2[2]) --消费
   local  cost 
   if cost1 > cost2 then
        cost = cost2 
   else
        cost = cost1
   end
   print(cost,cost1,cost2, self.data.gotCount )
   if self.data.gotCount then
        cost = cost - self.data.gotCount 
   end
   if cost > 0 then
       return true
   else
       return false
   end
end

function LaBaLeiChou:onClickLaBa(context)
    local data = context.sender.data

    if data == 1 then
        if self.oneBtn:GetChild("red").visible then
            proxy.ActivityProxy:send(1030692,{reqType = 1})
        else
            GComAlter(language.labaDlhl2019_13)
        end
    elseif data == 10 then
        if self.tenBtn:GetChild("red").visible then
            proxy.ActivityProxy:send(1030692,{reqType = 2})
        else
            GComAlter(language.labaDlhl2019_13)
        end

    end
end

function LaBaLeiChou:choujiangredPoint()
    local num = cache.PackCache:getPackDataById( self.costData3[1]).amount or 0
    if num >= self.costData1[1][2] then 
        self.oneBtn:GetChild("red").visible = true
        if num >= self.costData1[2][2] then
            self.tenBtn:GetChild("red").visible = true
        else
            self.tenBtn:GetChild("red").visible = false
        end
    else
        self.oneBtn:GetChild("red").visible = false
        self.tenBtn:GetChild("red").visible = false

    end

end


return LaBaLeiChou