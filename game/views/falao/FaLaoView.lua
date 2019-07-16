--
-- Author: 
-- Date: 2018-07-19 14:47:50
--

local FaLaoView = class("FaLaoView", base.BaseView)

local FloorImg = {
    [1] = "falaomibao_007", --顶层
    [2] = "falaomibao_008", --五层
    [3] = "falaomibao_009", --四层
    [4] = "falaomibao_010", --三层
    [5] = "falaomibao_011", --二层
    [6] = "falaomibao_012", --首层
}

function FaLaoView:ctor()
    FaLaoView.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function FaLaoView:initView()
    self.closeBtn = self.view:GetChild("n0"):GetChild("n6")
    self.closeBtn.onClick:Add(self.onBtnClose,self)
    self.titleIcon = self.view:GetChild("n0"):GetChild("n7")
    
    local ruleBtn = self.view:GetChild("n8")  
    ruleBtn.onClick:Add(self.onClickRule,self)
    
    local dec1 = self.view:GetChild("n6")
    dec1.text = language.falao01
    local dec2 = self.view:GetChild("n14")
    dec2.text = language.falao03
    
    self.ybNum = self.view:GetChild("n11")
    self.ybNum.text = ""
    
    self.lastTime = self.view:GetChild("n7")
    self.lastTime.text = ""

    self.logsList = self.view:GetChild("n5")
    self.logsList.itemRenderer = function(index,obj)
        self:cellLogData(index, obj)
    end
    self.logsList:SetVirtual()

    self.showList = self.view:GetChild("n1")
    self.showList.itemRenderer = function(index,obj)
        self:cellShowData(index, obj)
    end
    -- self.showList:SetVirtual()


end

function FaLaoView:initData()
    self.cost = conf.ActivityConf:getHolidayGlobal("pyramid_count_cost")
    self.oneBtn = self.view:GetChild("n13")
    self.oneBtn.data = 1
    self.oneBtn.title = tonumber(self.cost[1][2])
    self.oneBtn.onClick:Add(self.goBuy,self)
    self.tenBtn = self.view:GetChild("n12")
    self.tenBtn.data = 10
    self.tenBtn.title = tonumber(self.cost[2][2])
    self.tenBtn.onClick:Add(self.goBuy,self)
    self:setBtnTouch(true)


end

function FaLaoView:addMsgCallBack(data)
    self.data = data
    printt("法老密宝",data)
    -- print("抽中奖励",data.curIndex)
    -- print("当前层",data.floor)
    print("多开id",data.mulActId)

    self.time = data.lastTime
     --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "falaomibao_001"
    self.titleIcon.url = UIPackage.GetItemURL("falao" , titleIconStr)

    self.logsList.numItems = #data.records

    self.maxfloor = conf.ActivityConf:getHolidayGlobal("pyramid_max_floor")--总层数
    if not self.movieComList then
        self.movieComList = {}
    end
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    self.ybNum.text = ybData.amount

    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    if data.times == 0 then
        self.showList.numItems = self.maxfloor
    elseif data.times == 10 then
        GOpenAlert3(data.items)
        self:setBtnTouch(true)
        self.showList.numItems = self.maxfloor
    elseif data.times == 1 then
        self:playTransition()
    end
end

function FaLaoView:cellLogData(index, obj)
    local data = self.data.records[index+1]
    local strTab = string.split(data,ChatHerts.SYSTEMPRO)
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n1")
    recordItem.text = string.format(language.falao02, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

function FaLaoView:setLocationImg(locationImg,currFloor,index)
    if currFloor == self.maxfloor - index then
        locationImg.visible = true
    else
        locationImg.visible = false
    end
end

function FaLaoView:cellShowData(index,obj)
    local floorImg = obj:GetChild("n15")
    floorImg.url = UIPackage.GetItemURL("falao",FloorImg[index+1])
    local locationImg = obj:GetChild("n17")--所在层标记

    local movieCom = obj:GetChild("n22")
    table.insert(self.movieComList,movieCom)
    if self.data.floor == self.maxfloor - index then
        locationImg.visible = true
    else
        locationImg.visible = false
    end

    local firstAwardImg = obj:GetChild("n18")--最高层奖励展示img
    local jianTouCom = obj:GetChild("n20")--箭头
    if index == 0 then
        firstAwardImg.visible = false--隐藏图片展示
        jianTouCom.visible = false
    else
        firstAwardImg.visible = false
        jianTouCom.visible = true
    end
    local awardList = obj:GetChild("n16")
   
    --前缀
    local pre = self.mulConfData.award_pre
    self.awardConfData = conf.ActivityConf:getFLMBDataByFloor(pre,self.maxfloor - index)
    jianTouCom.y = -25
    jianTouCom.x = 280 + ((#self.awardConfData -2) * 35)
    awardList.itemRenderer = function (index, obj)
        self:cellAwardData(index, obj)
    end
    awardList.numItems = #self.awardConfData
    -- self:setAwards(awardConfData)
end

function FaLaoView:cellAwardData(index,obj)
    local data = self.awardConfData[index+1]
    local c1 = obj:GetController("c1")
    if data then
        local item = obj:GetChild("n0")
        local awardData = data.item 
        local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3],isquan = 0}
        GSetItemData(item, itemData, true)
        if data.mb then
            c1.selectedIndex = 1
        else
            c1.selectedIndex = 0
        end
    end
end
--
local InitPos = {0,37,75,111,149}-- 一层~五层光标初始位置
local EndPos = {368,332,296,259,223}-- 一层~五层光标初始位置
--播放动画
function FaLaoView:playTransition()
    -- self.data.floor = 1
    local tempIndex = string.sub(tostring(self.data.curIndex),5,8)
    local awardFloor = math.floor(tonumber(tempIndex)/1000)--奖励层
    if awardFloor >= 6 then--最高6层
        GOpenAlert3(self.data.items)
        self:setBtnTouch(true)
        self.showList.numItems = self.maxfloor
        return
    end
    for k,v in pairs(self.movieComList) do
        if awardFloor == self.maxfloor - k + 1 then
            v.visible = true--组件打开
            self.movieImg = v:GetChild("n0")
            self.movieImg.visible = true--抽到奖励的所在层的动画亮起
            v:GetChild("n0").x = InitPos[awardFloor]
        end
    end
    local getRightLimt = false
    local timerTimes = self:getTimerLoopTimes(self.data.curIndex)
    --通过修改循环次数，来决定停留在那个奖励上
    self:addTimer(0.15, timerTimes, function ()
        if self.movieImg.visible then
            if math.abs(self.movieImg.x - EndPos[awardFloor]) < 10 then--这个比较的self.movieImg.x其实是上一秒的位置，
                getRightLimt = true
            end
            -- print(">>>>>>",self.movieImg.x,EndPos[self.data.floor])
            -- print(">>>>>>",getRightLimt)
            if not getRightLimt then
                self.movieImg.x = self.movieImg.x + 74 --距离差
                -- print("现在",self.movieImg.x)
            else
                -- print("###",self.movieImg.x,InitPos[self.data.floor])
                if math.abs(self.movieImg.x - InitPos[awardFloor]) <= 80 then--80(只要比距离差74大的任何数都可以)
                    getRightLimt = false  
                end
                self.movieImg.x = self.movieImg.x - 74
            end
            
        end
    end)

    self:addTimer(0.15*timerTimes+1, 1,function ()
        -- print("延时",0.15*timerTimes+0.2)
        GOpenAlert3(self.data.items)
        self.movieImg.visible = false
        self:setBtnTouch(true)
        self.showList.numItems = self.maxfloor

    end)
end

--设置定时器循环次数
function FaLaoView:getTimerLoopTimes(curIndex) 
    local floor = string.sub(tostring(curIndex),5,5)
    --每层动画循环波播一遍需要的定时器循环次数
    local eachNum = (self.maxfloor - tonumber(floor)) * 2
    --目标位置
    local temp = string.sub(tostring(curIndex),5,8)
    local traIndex = (tonumber(temp)%1000) - 1
    --*3 是动画先循环播三遍
    local timerLoopTimes = eachNum * floor + traIndex
    -- print(curFloor,curIndex,eachNum,traIndex,timerLoopTimes)
    return timerLoopTimes
end


function FaLaoView:goBuy( context )
    self:setBtnTouch(false)
    local data = context.sender.data
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    local haveYb = ybData.amount
    if data == 1 then
        if haveYb < self.cost[1][2] then
            GComAlter(language.gonggong18)
            GGoVipTequan(0)
            self:onBtnClose()
            self:setBtnTouch(true)
            return
        end
    elseif data == 10 then
        if haveYb < self.cost[2][2] then
            GComAlter(language.gonggong18)
            GGoVipTequan(0)
            self:setBtnTouch(true)
            return
        end
    end
    proxy.ActivityProxy:sendMsg(1030218,{reqType = 1,times = data})
end

function FaLaoView:setBtnTouch(flag)
    self.oneBtn.touchable = flag
    self.tenBtn.touchable = flag
    -- self.closeBtn.touchable = flag

end

function FaLaoView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:onBtnClose()
    end

    self.time = self.time - 1
end


function FaLaoView:onClickRule()
    GOpenRuleView(1105)
end

function FaLaoView:releaseTimer()
   if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function FaLaoView:onBtnClose()
    if self.movieImg then
        self.movieImg.visible = false
    end
    self.showList.numItems = self.maxfloor
    self:releaseTimer()
    self:closeView()
end

return FaLaoView