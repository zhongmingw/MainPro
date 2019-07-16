--
-- Author: Your Name
-- Date: 2017-09-20 15:48:56
--
local SmashEggsView = class("SmashEggsView", base.BaseView)

function SmashEggsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function SmashEggsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n13")
    closeBtn.onClick:Add(self.onClickClose,self)
    local guizeBtn = self.view:GetChild("n40")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.awardsList = self.view:GetChild("n8")
    self.eggList = self.view:GetChild("n24")
    self:initAwardsList()
    self:initEggsList()
    self.refreshBtn = self.view:GetChild("n25")--刷新按钮
    self.openAllBtn = self.view:GetChild("n26")--全部砸开按钮
    self.oneCost = self.view:GetChild("n28")--单个砸蛋消耗
    self.allCost = self.view:GetChild("n31")--全部砸蛋消耗
    self.freeCount = self.view:GetChild("n35")--免费次数
    self.refreshFree = self.view:GetChild("n37")--免费刷新次数
    self.getBtn = self.view:GetChild("n13")--领取时装按钮
    self.bar = self.view:GetChild("n16")--当前砸蛋次数进度条
    self.checkAwardBtn = self.view:GetChild("n41")--查看奖励按钮
    self.checkAwardRed = self.view:GetChild("n39")--查看奖励按钮红点
    self.checkAwardRed.visible = false
    self.labtimer = self.view:GetChild("n7")
    self.labtimer.text = ""
    self.model = self.view:GetChild("n22")
    self.nowCount = self.view:GetChild("n38")--当前次数
    self.nowCount.visible = false
end

function SmashEggsView:onClickGuize()
    GOpenRuleView(1082)
end

--展示模型
function SmashEggsView:setModel()
    local fashions = conf.ActivityConf:getValue("smash_egg_fashion")
    local lingtong = conf.ItemConf:getItemExt(fashions[1][1])--灵童
    -- local lingqi = conf.ItemConf:getItemExt(fashions[2][1])--以前是两个奖励 现在改为一个
    local lingtongData = conf.HuobanConf:getSkinsByIndex(lingtong, 0)
    -- local lingqiData = conf.HuobanConf:getSkinsByIndex(lingqi, 4)

    self.model.visible = true
    -- print("仙器模型",lingtongData.modle_id,lingtong)
    if lingtongData.modle_id then
        -- local obj = self:addModel(3050302,self.model)

        -- obj:setScale(150)
        -- obj:setRotationXYZ(0,166,0)
        -- obj:setPosition(0,-150,300)
        -- obj:addWeaponEct(lingbingData.modle_id.."_ui")
        local obj = self:addModel(lingtongData.modle_id, self.model)
        obj:setScale(160)
        obj:setRotationXYZ(0,180,0)
        obj:setPosition(0,-350,850)
        -- effect.LocalRotation = Vector3.New(0,157,0)
        -- effect.LocalPosition = Vector3.New(0,-150,500)
        -- effect.Scale = Vector3.New(100,100,100)
    end
end

function SmashEggsView:initData()
    self:setAwards()
    self:setModel()
    local getCond = conf.ActivityConf:getValue("smash_egg_fashion_cond")
    local fashions = conf.ActivityConf:getValue("smash_egg_fashion")
    for i=12,20 do
        self.view:GetChild("n"..i).visible = false
    end
    -- for i=1,#fashions do
    --     local awardInfo = {mid = fashions[i][1], amount = fashions[i][2], bind = fashions[i][3]}
    --     self.view:GetChild("n"..(5-#fashions+i)).visible = true
    --     self.view:GetChild("n"..(19-#fashions+i)).text = getCond[i]
    --     self.view:GetChild("n"..(19-#fashions+i)).visible = true
    --     GSetItemData(self.view:GetChild("n1"..(5-#fashions+i)),awardInfo,true)
    -- end

    self.refreshBtn.onClick:Add(self.onClickRefresh,self)
    self.view:GetChild("n29").visible = false--删除免费次数
    -- local freeCount = conf.ActivityConf:getValue("smash_egg_free_count")
    -- self.view:GetChild("n29").text = string.format(language.active33,freeCount[1],freeCount[2])
    if self.timers then
        self:removeTimer(self.timers)
        self.timers = nil 
    end
    self.nowCount.text = ""
    self.timers = self:addTimer(1,-1,handler(self,self.onTiemr))
end

function SmashEggsView:onTiemr()
    if not self.data then
        self.labtimer.text = ""
        return
    end

    self.data.leftTime = self.data.leftTime - 1
    if self.data.leftTime < 0 then
        self.data.leftTime = 0
    end

    local param = clone(language.active19)
    param[2].text = string.format(param[2].text,GGetTimeData2(self.data.leftTime))
    param[1].color = 6
    param[2].color = 7
    self.labtimer.text = mgr.TextMgr:getTextByTable(param)
end

--奖励列表初始化
function SmashEggsView:initAwardsList()
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.awardsList:SetVirtual()
end
--砸蛋列表初始化
function SmashEggsView:initEggsList()
    self.eggList.numItems = 0
    self.eggList.itemRenderer = function (index,obj)
        self:eggsCelldata(index, obj)
    end
end
--加载奖励列表
function SmashEggsView:setAwards()
    self.awardsData = conf.ActivityConf:getEggAwardsData()
    self.awardsList.numItems = #self.awardsData
end
function SmashEggsView:celldata( index,obj )
    local data = self.awardsData[index+1]
    if data then
        local info = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,info,true)
    end
end

function SmashEggsView:eggsCelldata( index,obj )
    local id = self.data.currEggs[index+1]
    if id then
        local icon = obj:GetChild("n0")
        if id == 10001 then--普通蛋
            icon.url = UIPackage.GetItemURL("smasheggs" , "fengkuangzadan_007")
        elseif id == 20001 then--极品蛋
            icon.url = UIPackage.GetItemURL("smasheggs" , "fengkuangzadan_008")
        elseif id == -1 then--已经砸过的极品蛋
            icon.url = UIPackage.GetItemURL("smasheggs" , "fengkuangzadan_009")
        elseif id == 0 then--已经砸过的普通蛋
            icon.url = UIPackage.GetItemURL("smasheggs" , "fengkuangzadan_010")
        end
        obj.data = index+1
        obj.onClick:Add(self.onClickSmash,self)
    end
end

--点击砸蛋
function SmashEggsView:onClickSmash( context )
    local id = context.sender.data
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local cost = conf.ActivityConf:getValue("smash_egg_cost")
    local maxCount = conf.ActivityConf:getValue("smash_egg_limit_count")
    if self.notTips then 
        if myYb >= cost or self.data.leftCounts > 0 then
            if self.data.currCount < maxCount then
                proxy.ActivityProxy:sendMsg(1030209,{reqType = 3,tarId = id})
            else
                GComAlter(language.active35)
            end
        else
            GComAlter(language.gonggong18)
        end
        return 
    end
    if self.data.leftCounts > 0 then
        proxy.ActivityProxy:sendMsg(1030209,{reqType = 3,tarId = id})
    else
        local param = {}
        param.type = 8
        param.sure = function(flag)
            if myYb >= cost then
                if self.data.currCount < maxCount then
                    proxy.ActivityProxy:sendMsg(1030209,{reqType = 3,tarId = id})
                else
                    GComAlter(language.active35)
                end
            else
                GComAlter(language.gonggong18)
            end
            self.notTips = flag
        end
        local textData = {
                            {text = language.active34[1],color = 6},
                            {text = string.format(language.active34[2],cost),color = 7},
                            {text = language.active34[3],color = 6},
                        }
        param.richtext = mgr.TextMgr:getTextByTable(textData)
        param.richtext1 = language.zuoqi51
        param.sureIcon = UIItemRes.imagefons01
        GComAlter(param)
    end
end

--刷新砸蛋列表
function SmashEggsView:onClickRefresh()
    local cost = conf.ActivityConf:getValue("smash_egg_refresh_cost")
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if self.data.leftRefreshCounts > 0 then
        proxy.ActivityProxy:sendMsg(1030209,{reqType = 5})

        return
    end
    local param = {}
    param.type = 2
    param.sure = function()
        if myYb >= cost then
            proxy.ActivityProxy:sendMsg(1030209,{reqType = 5})
        else
            GComAlter(language.gonggong18)
        end
    end
    local textData = {
                        {text = language.active34[1],color = 6},
                        {text = string.format(language.active34[2],cost),color = 7},
                        {text = language.active34[4],color = 6},
                    }
    param.richtext = mgr.TextMgr:getTextByTable(textData)
    GComAlter(param)
    
end

function SmashEggsView:setData(data)
    -- print("疯狂砸蛋")
    -- printt(data)
    self.data = data
    --砸蛋列表设置
    self.eggList.numItems = #data.currEggs

    --砸蛋消耗
    local smashCost = conf.ActivityConf:getValue("smash_egg_cost")
    self.oneCost.text = smashCost
    if data.leftCounts > 0 then
        self.view:GetChild("n32").visible = false
        self.oneCost.visible = false
        self.freeCount.visible = true
        self.freeCount.text = string.format(language.active29,data.leftCounts)
    else
        self.view:GetChild("n32").visible = true
        self.oneCost.visible = true
        self.freeCount.visible = false
    end
    --全部砸开消耗计算
    local allCost = 0
    local counts = 0
    for k,v in pairs(data.currEggs) do
        if v > 0 then
            allCost = allCost + smashCost
            counts = counts + 1
        end
    end
    allCost = allCost - data.leftCounts * smashCost
    self.allCost.text = allCost
    self.openAllBtn.data = {allCost = allCost,counts = counts}
    self.openAllBtn.onClick:Add(self.onClickOpenAll,self)
    --刷新设置
    local refreshCost = conf.ActivityConf:getValue("smash_egg_refresh_cost")
    self.view:GetChild("n30").text = refreshCost
    if data.leftRefreshCounts > 0 then
        self.view:GetChild("n30").visible = false
        self.view:GetChild("n34").visible = false
        self.refreshFree.visible = true
    else
        self.view:GetChild("n30").visible = true
        self.view:GetChild("n34").visible = true
        self.refreshFree.visible = false
    end
    --当前时装领取设置
    local getCond = conf.ActivityConf:getValue("smash_egg_fashion_cond")
    local fashions = conf.ActivityConf:getValue("smash_egg_fashion")
    self.bar.max = getCond[#getCond]
    self.bar.value = data.currCount
    self.nowCount.text = data.currCount
    self.awardFlagList = {[fashions[1][1]] = 0}--领取状态 奖励改为只有一个 之前的,[fashions[2][1]] = 0删掉了
    for k,v in pairs(data.gotFashion) do
        self.awardFlagList[v] = 1
    end
    local index = 0
    for i=1,#getCond do
        if data.currCount >= getCond[i] then
            index = index + 1
        end
    end
    -- print("当前砸蛋次数",index,data.currCount,getCond[i],self.awardFlagList[fashions[i][1]])
    -- printt(data.gotFashion)
    local tarId = nil
    if index >= 1 then
        for i=1,index do
            if self.awardFlagList[fashions[i][1]] == 0 then
                tarId = i
                break
            end
        end
    end
    if tarId then
        self.getBtn:GetChild("n5").visible = true
        self.getBtn.grayed = false
    else
        self.getBtn:GetChild("n5").visible = false
        self.getBtn.grayed = true
    end
    self.getBtn.data = {reqType = 2,tarId = tarId}
    self.getBtn.onClick:Add(self.onClickGet,self)
    --奖励icon
    for i=1,#fashions do
        local awardItem = self.view:GetChild("n1"..(5-#fashions)+i)
        if self.awardFlagList[fashions[i][1]] == 0 then
            awardItem:GetChild("n6").visible = false
        else
            awardItem:GetChild("n6").visible = true
        end
    end
    -- --查看奖励按钮
    self.checkAwardBtn.data = {history = data.history,currCount = data.currCount,cumulateList = data.cumulateList}
    self.checkAwardBtn.onClick:Add(self.onClickCheckAwards,self)
    -- self:setRedPoint()--屏蔽查看奖励
end
--查看奖励红点
function SmashEggsView:setRedPoint()
    local cumulateList = self.data.cumulateList
    local accumulateData = conf.ActivityConf:getAccumulateData()
    local flag = false

    for k,v in pairs(accumulateData) do
        if self.data.currCount >= v.count then
            local canGet = true
            for _,id in pairs(cumulateList) do
                if id == v.id then
                    canGet = false
                    break
                end
            end
            if canGet then
                flag = true
                break
            end
        end
    end
    if flag then
        self.checkAwardRed.visible = true
    else
        self.checkAwardRed.visible = false
    end
end

function SmashEggsView:onClickCheckAwards( context )
    local data = context.sender.data
    mgr.ViewMgr:openView2(ViewName.CheckAwardsView,data)
end

function SmashEggsView:onClickGet( context )
    local data = context.sender.data
    if data.tarId then
        proxy.ActivityProxy:sendMsg(1030209,{reqType = data.reqType,tarId = data.tarId})
    else
        GComAlter(language.active27)
    end
end

function SmashEggsView:onClickOpenAll(context)
    local maxCount = conf.ActivityConf:getValue("smash_egg_limit_count")
    local cost = context.sender.data.allCost
    local counts = context.sender.data.counts
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local param = {}
    param.type = 2
    param.sure = function()
        if (maxCount - self.data.currCount) >= counts then
            if myYb >= cost then
                proxy.ActivityProxy:sendMsg(1030209,{reqType = 4})
            else
                GComAlter(language.gonggong18)
            end
        else
            GComAlter(string.format(language.active30,maxCount - self.data.currCount))
        end
    end
    local textData = {
                        {text = language.active34[1],color = 6},
                        {text = string.format(language.active34[2],cost),color = 7},
                        {text = language.active34[3],color = 6},
                    }
    param.richtext = mgr.TextMgr:getTextByTable(textData)
    GComAlter(param)
end

function SmashEggsView:onClickClose()
    cache.PlayerCache:setAttribute(30121,self.data.currCount)
    -- GIsOpenWishPop(30121)
    if self.timers then
        self:removeTimer(self.timers)
        self.timers = nil 
    end
    self:closeView()
end

return SmashEggsView