--
-- Author: 
-- Date: 2018-08-20 21:56:52
--

local TianMingBuGua = class("TianMingBuGua", base.BaseView)

function TianMingBuGua:ctor()
    TianMingBuGua.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function TianMingBuGua:initView()
    local closeBtn = self.view:GetChild("n7")
    self:setCloseBtn(closeBtn)

    local ruleBtn = self.view:GetChild("n11")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    local dec1 = self.view:GetChild("n12")
    dec1.text = language.tmbg01
    --记录list
    self.logsList = self.view:GetChild("n15")
    self.logsList.itemRenderer = function(index,obj)
        self:cellLogData(index, obj)
    end
    self.logsList:SetVirtual()

    self.lastTime = self.view:GetChild("n10")

    self.oneCostTxt = self.view:GetChild("n35")
    self.tenCostTxt = self.view:GetChild("n36")

    self.oneBtn = self.view:GetChild("n29")
    self.oneBtn.data = 1
    self.oneBtn.onClick:Add(self.onClickBuGua,self)

    self.tenBtn = self.view:GetChild("n30")
    self.tenBtn.data = 10
    self.tenBtn.onClick:Add(self.onClickBuGua,self)

    self.cancelBtn = self.view:GetChild("n37")
    --挂list
    self.guaList = self.view:GetChild("n27")
    self.guaList.itemRenderer = function(index,obj)
        self:cellGuaData(index, obj)
    end

    self.resetBtn = self.view:GetChild("n28")
    self.resetBtn.onClick:Add(self.onClickResetBtn,self)



end

function TianMingBuGua:initData()
    self:setBtnTouch(true)
    self.awardList = {}
    for i=1,22 do
        local item = self.view:GetChild("n39"):GetChild("n"..(i+38))
        item.data = 1000 + i
        table.insert(self.awardList,item)
    end
    self.guangXiaoCom = self.view:GetChild("n39"):GetChild("n62")
    self.guangXiaoCom.visible = false
    --光效icon
    self.guangXiaoIcon = self.guangXiaoCom:GetChild("n0")

    for k,v in pairs(self.awardList) do
        local confData = conf.ActivityConf:getTMBGAwardPoolById(v.data)
        local item = confData.item
        local itemObj = {mid = item[1],amount = item[2],bind = item[3],isquan = 0}
        GSetItemData(v, itemObj, true)
    end
end

function TianMingBuGua:setData(data)
    printt("卜卦",data)
    print("抽到奖励",data.awardId)
    self.data = data
    --总次数
    local allTimes = 0
    self.keyList = {}
    for k,v in pairs(data.gestTimesData) do
        allTimes = allTimes + v
        table.insert(self.keyList,k)
    end
    self.guaList.numItems = #self.keyList

    local costConfData = conf.ActivityConf:getTMBGCost()
    table.sort(costConfData,function (a,b)
        if a.id ~= b.id then
            return a.id > b.id
        end
    end)
    printt(costConfData)
    self.oneCost = 0
    for k,v in pairs(costConfData) do
        if allTimes >= v.amount[1]then
            self.oneCost = v.cost
            break
        end
    end
    self.oneCostTxt.text = self.oneCost
    self.tenCostTxt.text = self.oneCost*10
    if data.reqType == 1 then
        if data.args == 10 then
            self:setBtnTouch(true)
            GOpenAlert3(data.items)
        elseif data.args == 1 then
            if not self.cancelBtn.selected then
                self.guangXiaoCom.visible = true
                local getAwardId = data.awardId
                --目标位置
                local tarStep = getAwardId%1000
                self.curStep = 0
                print("~~~~",42+tarStep,0.1 * (42+tarStep))
                --计时器次数
                local time = 0
                self:addTimer(0.1,42+tarStep, function ()
                    time = time + 1
                    self.curStep = self.curStep + 1
                    self.curStep = self.curStep%22
                    self.curStep = self.curStep == 0 and 1 or self.curStep
                    self.guangXiaoIcon.x = self.awardList[self.curStep].x - 1
                    self.guangXiaoIcon.y = self.awardList[self.curStep].y - 3
                    if time == 42+tarStep then
                        self:addTimer(0.5, 1, function ()--延迟0.5秒打开窗口
                            self:setBtnTouch(true)
                            self.guangXiaoCom.visible = false
                            GOpenAlert3(data.items)
                        end)
                    end
                end)
            else
                self:setBtnTouch(true)
                GOpenAlert3(data.items)
            end

        end
    end
    self.time = data.lastTime
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.logsList.numItems = #data.records

end


function TianMingBuGua:cellLogData(index,obj)
    local data = self.data.records[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.houWang04, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

function TianMingBuGua:cellGuaData(index,obj)
    local cfgId = self.keyList[index+1]
    local confData = conf.ActivityConf:getTMBGAwardPoolById(cfgId)
    local item = obj:GetChild("n22")
    local times = obj:GetChild("n21")
    times.text = self.data.gestTimesData[cfgId]
    local itemObj = {mid = confData.item[1],amount = 1,bind = confData.item[3]}--策划需求，个数隐藏
    GSetItemData(item, itemObj)
    obj.data = {cfgId = cfgId,times = self.data.gestTimesData[cfgId]}
    obj.onClick:Add(self.onClickObj,self)
end

function TianMingBuGua:onClickObj(context)
    local data = context.sender.data
    local cfgId = data.cfgId
    --次数
    local times = data.times
    local confData = conf.ActivityConf:getTMBGAwardPoolById(cfgId)
    if times > #confData.gest_cost then
        GComAlter(language.tmbg04)
    else
        local flag = cache.ActivityCache:getTMBGAlertFlag()
        --不再提醒
        if flag then
            proxy.ActivityProxy:sendMsg(1030241,{reqType = 2,args = cfgId})
        else
            local mid = confData.item[1]
            local proName = conf.ItemConf:getName(mid)
            local param = {}
            local t = clone(language.tmbg02)
            t[2].text = string.format(t[2].text,confData.gest_cost[times])
            t[3].text = string.format(t[3].text,proName)
            param.richText = mgr.TextMgr:getTextByTable(t)
            param.sure = function ()
                proxy.ActivityProxy:sendMsg(1030241,{reqType = 2,args = cfgId})
            end
            param.isHint = true
            mgr.ViewMgr:openView2(ViewName.BuGuaAlert,param)
        end
    end
end


--卜卦
function TianMingBuGua:onClickBuGua(context)
    self:setBtnTouch(false)
    local data = context.sender.data
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    local ybAmount = ybData.amount
    if not self.oneCost or not data then return end
    if ybAmount < self.oneCost * data then
        GComAlter(language.gonggong18)
    else
        proxy.ActivityProxy:sendMsg(1030241,{reqType = 1,args = data})
    end
end

--重置
function TianMingBuGua:onClickResetBtn()
    local param = {}
    param.richText = language.tmbg03
    param.sure = function ()
        -- --能否重置
        -- local isCanReset = false
        -- for k,v in pairs(self.data.gestTimesData) do
        --     if v ~= 1 then
        --         isCanReset = true
        --         break
        --     end
        -- end
        -- if isCanReset then
            proxy.ActivityProxy:sendMsg(1030241,{reqType = 3,args = 0})
        -- else
            -- GComAlter(language.tmbg05)
        -- end
    end
    mgr.ViewMgr:openView2(ViewName.BuGuaAlert,param)
end

function TianMingBuGua:onTimer()
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

function TianMingBuGua:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function TianMingBuGua:setBtnTouch(flag)
    self.oneBtn.touchable = flag
    self.tenBtn.touchable = flag
    -- self.resetBtn.touchable = flag

end


function TianMingBuGua:onClickRule()
    GOpenRuleView(1131)
end


return TianMingBuGua