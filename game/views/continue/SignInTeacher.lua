--
-- Author: 
-- Date: 2018-08-25 10:34:28
--

local SignInTeacher = class("SignInTeacher", base.BaseView)

math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

local PeopleIcon = {
    [1] = "laoshiqingdianming_007",
    [2] = "laoshiqingdianming_008",
    [3] = "laoshiqingdianming_009",
}

function SignInTeacher:ctor()
    SignInTeacher.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function SignInTeacher:initView()
    local closeBtn = self.view:GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.titleIcon = self.view:GetChild("titleIcon")

    local ruleBtn = self.view:GetChild("n21")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    self.showAwardList = self.view:GetChild("n17")
    self.showAwardList.itemRenderer = function(index,obj)
        self:cellShowData(index, obj)
    end
    self.showAwardList:SetVirtual()

    self.cardList = self.view:GetChild("n35")
    self.cardList.itemRenderer = function(index,obj)
        self:cellCardData(index, obj)
    end

    self.lastTime = self.view:GetChild("n20")

    local resetBtn = self.view:GetChild("n22")
    resetBtn.data = {reqType = 2,times =  0}
    resetBtn.onClick:Add(self.onClickBtn,self)
    
    local tenBtn = self.view:GetChild("n23")
    self.tenCost = self.view:GetChild("n27")
    tenBtn.data =  {reqType = 1,times =  10}
    tenBtn.onClick:Add(self.onClickBtn,self)
    
    local fiftyBtn = self.view:GetChild("n24")
    self.fiftyCost = self.view:GetChild("n30")
    fiftyBtn.data = {reqType = 1,times =  50}
    fiftyBtn.onClick:Add(self.onClickBtn,self)

    self.oneCost = self.view:GetChild("n33")
    local oneTitle = self.view:GetChild("n34")
    oneTitle.text = language.teacher01
    for i=1,3 do
        self.view:GetChild("n"..(11+i)).text = language.teacher02[i]
    end

end
local Index = {
    [1] = {1,1,1,2,2,2,3,3,3},
    [2] = {1,1,1,2,2,2,3,3,3},
    [3] = {1,1,1,2,2,2,3,3,3},
}

function SignInTeacher:initData()
    self.isPlaying = false

    for i=1,3 do
        self:randomList(Index[i])--3种档位的3种卡背随机出现
    end
end

function SignInTeacher:randomList( arr )
    for i=1,#arr do
        local index = math.random(1,#arr)
        arr[i],arr[index] = arr[index],arr[i]
    end
end

function SignInTeacher:cellShowData(index,obj)
    local data = self.showAwardData[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,itemData,true)
    end
end

function SignInTeacher:onController1()
    -- self:setCost()
    proxy.ActivityProxy:sendMsg(1030242,{reqType = 0,times = 0,index = 0,level = self.c1.selectedIndex+1})
end

function SignInTeacher:setCost()
    self.costConfData = conf.ActivityConf:getTeacherCostByType(self.pre,self.c1.selectedIndex+1)
    self.oneCost.text = self.costConfData[1].cost 
    self.tenCost.text = self.costConfData[2].cost  
    self.fiftyCost.text = self.costConfData[3].cost  
end

function SignInTeacher:setData(data)
    self.data = data
    printt("老师》》》",self.data)
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "laoshiqingdianming_003"
    self.titleIcon.url = UIPackage.GetItemURL("continue" , titleIconStr)
    --前缀
    self.pre = self.mulConfData.award_pre
    --奖励显示
    local mulStr = "teacher_show_award_"..tostring(self.data.mulActId)
    self.showAwardData = conf.ActivityConf:getHolidayGlobal(mulStr)
    self.showAwardList.numItems = #self.showAwardData
    
    self.c1.selectedIndex = data.level-1

    self:setCost()

    self.isGot = 0
    for k,v in pairs(data.cardData) do
        self.isGot = self.isGot + 1
    end
    if self.isGot == 9 then
        self:addTimer(0.35, 1, function ()--0.35秒是反转动画的时间
            proxy.ActivityProxy:sendMsg(1030242,{reqType = 0,times = 0,index = 0,level = self.c1.selectedIndex+1})
        end)
    end
    -- print(self.isGot)
    self.cardList.numItems = 9

    self.time = data.lastTime

    if data.reqType == 1 then
        if data.times == 10 or data.times == 50 then
            GOpenAlert3(data.items)
        end
    end

    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function SignInTeacher:cellCardData(index,obj)
    local peopleIcon = obj:GetChild("n3")
    peopleIcon.url = UIPackage.GetItemURL("continue",PeopleIcon[Index[self.c1.selectedIndex+1][index+1]])

    local t0 = obj:GetTransition("t0")--翻转动画
    local open = obj:GetTransition("open")--已翻开
    local backGround = obj:GetTransition("backGround")--未翻开
    
    local itemObj = obj:GetChild("n0"):GetChild("n1")
    local proNameTxt = obj:GetChild("n0"):GetChild("n2")
    
    local c1 = obj:GetController("c1")--这个控制器只起到标志作用，UI中不起任何作用
    if self.data and self.data.cardData and self.data.cardData[index+1] then
        c1.selectedIndex = 1 --已翻
        local itemConf = conf.ActivityConf:getTeacherItemById(self.data.cardData[index+1])
        local mid = itemConf.item[1]
        local amount = itemConf.item[2]
        local color = conf.ItemConf:getQuality(mid)
        local proName = conf.ItemConf:getName(mid)
        local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
        proNameTxt.text = awardsStr--.."X"..amount
        local itemData = {mid = mid,amount = amount ,bind = itemConf.item[3]}
        GSetItemData(itemObj, itemData,true)
    else
        c1.selectedIndex = 0 
    end
    if c1.selectedIndex == 1 then--已翻开
        open:Play()
    else
        backGround:Play()
    end
    obj.data = {index = index+1}
    obj.onClick:Add(self.onClickCard,self)
end

function SignInTeacher:onClickCard(context)
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    local ybAmount = ybData.amount
    local data = context.sender
    local index = data.data.index
    local t0 = data:GetTransition("t0")
    local c1 = data:GetController("c1")
    local backGround = data:GetTransition("backGround")--未翻开

    if c1.selectedIndex == 0 and not self.isPlaying then
        if ybAmount >= self.costConfData[1].cost then
            -- proxy.ActivityProxy:sendMsg(1030242,{reqType = 1,times = 1,index = index,level = self.c1.selectedIndex+1})
            self.isPlaying = true
            t0:Play()
             t0:SetHook("send", function ()
                --卡牌翻转到send的时候发送协议 
                proxy.ActivityProxy:sendMsg(1030242,{reqType = 1,times = 1,index = index,level = self.c1.selectedIndex+1})
            end);
            t0:SetHook("finish", function ()
                self.isPlaying = false
                GOpenAlert3(self.data.items)
            end);
            t0:SetHook("open", function ()
                c1.selectedIndex = 1
            end);
        else
            GComAlter(language.gonggong18)
            GGoVipTequan(0)
            self:closeView()
        end
    else
        -- GComAlter("已经翻开了")
    end
end

function SignInTeacher:onClickBtn(context)
    local data = context.sender.data
    local reqType = data.reqType
    local times = data.times
    local cost = 0
    if times == 10 then
       cost = self.costConfData[2].cost  
    elseif times == 50 then
       cost = self.costConfData[3].cost  
    end
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    local ybAmount = ybData.amount
    if reqType == 1 then--点名
        if ybAmount >= cost then
            proxy.ActivityProxy:sendMsg(1030242,{reqType = reqType,times = times,index = 0,level = self.c1.selectedIndex+1})
        else
            GComAlter(language.gonggong18)
            GGoVipTequan(0)
            self:closeView()
        end
    elseif reqType == 2 then
        if self.isGot == 0 then
            GComAlter(language.tmbg05)
        else
            proxy.ActivityProxy:sendMsg(1030242,{reqType = reqType,times = times,index = 0,level = self.c1.selectedIndex+1})
        end
    end
end


function SignInTeacher:onTimer()
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

function SignInTeacher:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end


function SignInTeacher:onClickRule()
    GOpenRuleView(1132)
end

return SignInTeacher