--
-- Author: 
-- Date: 2018-03-12 22:13:40
--
--修改后
local XunBaoSingle = class("XunBaoSingle",import("game.base.Ref"))

function XunBaoSingle:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId
    self:initPanel()
end
--弃用
local Modules = {
    -- [1155] = 0,
    -- [1163] = 1,
    [1194] = 2
}
local ModulesName = {
    -- [1155] = "n5",
    -- [1163] = "n6",
    [1194] = "n6",
    -- [1267] = "n72",
}
local KeyIcon = {
    -- [1155] = "221071070",
    -- [1163] = "221071071",
    [1194] = "221071072",
    -- [1267] = "221071205",
}
local BgIcon = {
    -- [1155] = "xunbao_012",
    -- [1163] = "xunbao_016",
    [1194] = "xunbao_017",
    -- [1267] = "xunbao_017",
}
local ItemScale = {
    -- [1155] = 0.8,
    -- [1163] = 1,
    [1194] = 1,
    -- [1267] = 0.8,
}


function XunBaoSingle:initPanel()
    local panelObj = self.mParent.view:GetChild(ModulesName[self.moduleId])
    --临时背包
    self.limitWareBtn = panelObj:GetChild("n7") 
    self.limitWareBtn.onClick:Add(self.onLimitWare,self)
    --积分商城
    local storeBtn = panelObj:GetChild("n11")
    storeBtn.onClick:Add(self.onClickStore,self)

    self.c1 = panelObj:GetController("c1") --免费&一次
    self.c2 = panelObj:GetController("c2") --全服&个人
    
    self.ybTxt = panelObj:GetChild("n28") --拥有元宝
    self.keyTxt = panelObj:GetChild("n24") --拥有钥匙
    self.scoreTxt = panelObj:GetChild("n17") --拥有积分
    self.cdTxt = panelObj:GetChild("n13")--免费cd
    
    --记录列表
    self.listView = panelObj:GetChild("n67")
    self:initListView()
    --全服记录
    local allBtn = panelObj:GetChild("n69") 
    allBtn.data = {status = 0}
    allBtn.onClick:Add(self.onClickRecord,self)
    --个人记录
    local selfBtn = panelObj:GetChild("n70") 
    selfBtn.data = {status = 1}
    selfBtn.onClick:Add(self.onClickRecord,self)
    --寻宝一次
    local onceOrFreeBtn = panelObj:GetChild("n6")
    onceOrFreeBtn.data = {status = 1}
    onceOrFreeBtn.onClick:Add(self.onClickBuy,self)
    --寻宝十次
    local tenBtn = panelObj:GetChild("n9") 
    tenBtn.data = {status = 2}
    tenBtn.onClick:Add(self.onClickBuy,self)
    --寻宝五十次
    local fiftyBtn = panelObj:GetChild("n10") 
    fiftyBtn.data = {status = 3}
    fiftyBtn.onClick:Add(self.onClickBuy,self)
    
    self.oneBtnRed = onceOrFreeBtn:GetChild("red")
    self.tenBtnRed = tenBtn:GetChild("red")
    self.fiftyBtnRed = fiftyBtn:GetChild("red")

    self.keyList = {}
    for i=1,3 do
        costList = conf.ActivityConf:getXunBaoCostByModule(self.moduleId,i)
        local needKeyTxt = panelObj:GetChild("n10"..i)
        needKeyTxt.text = costList.cost[2]
        table.insert(self.keyList,costList)
    end

    for i=1,4 do
        self.keyicon = panelObj:GetChild("n30"..i)
        -- self.keyicon.url = UIPackage.GetItemURL("xunbao" ,)  --钥匙icon
        self.keyicon.url = ResPath.iconRes(KeyIcon[self.moduleId])  --钥匙icon

    end

    self.awardList = {} --奖励列表
    for i=72,86 do
        local itemAward = panelObj:GetChild("n"..i) 
        table.insert(self.awardList,itemAward)
    end
    self.bg = panelObj:GetChild("n71")
    self.bg.url = UIPackage.GetItemURL("xunbao",BgIcon[self.moduleId])
    self:setAwardItem()
end
--设置奖励列表
function XunBaoSingle:setAwardItem()
    local openDay = cache.ActivityCache:getLoopDay()--获取开服天数
    local zhuangBeiItem = conf.ActivityConf:getZhuangBeiItem(openDay)
    local jinJieItem = conf.ActivityConf:getJinJieItem(openDay)
    local petItem = conf.ActivityConf:getPetItem(openDay)
    local jianLingItem = conf.ActivityConf:getJianLingItem(openDay)
    local t = {[1155] = zhuangBeiItem,[1163] = jinJieItem,[1194] = petItem--[[,[1267] = jianLingItem]] }
    for k,v in pairs(t[self.moduleId]) do
        if v.sort then 
            if v.sort == 7 or v.sort == 1 then
                self.awardList[v.sort]:SetScale(ItemScale[self.moduleId],ItemScale[self.moduleId])
            end
            if v.type == 1 then  
                self:setEquipItem()
            elseif v.type == 2 and v.item then
                local isquan = 0
                self:setPropItem(v,isquan)
            elseif v.type == 3 and v.item then
                self:setPropItem(v)
            end
        end
    end
end
--设置道具item
function XunBaoSingle:setPropItem(data,isquan)
    local awardData = data.item[1]  
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3],isquan = isquan}
    -- printt("@@",self.awardList[data.sort])
    GSetItemData(self.awardList[data.sort], itemData, true)
end
--设置装备item
function XunBaoSingle:setEquipItem()
    local roleLev = cache.PlayerCache:getRoleLevel()
    local equips = conf.ActivityConf:getXunBaoEquip()
    for i=1,#equips do
        if roleLev >= equips[i].level[1] and roleLev <= equips[i].level[2] then
            if equips[i].box then 
                local equipData = equips[i].box[1]  --宝箱样子 
                local itemData = {mid = equipData[1],amount = equipData[2],bind = equipData[3]}
                    GSetItemData(self.awardList[1], itemData, true)
                break
            end
        end
    end
end

function XunBaoSingle:initListView()
    self.listView:SetVirtual()
    -- self.listView.numItems = 0

    self.listView.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
end
function XunBaoSingle:cellData(index,obj)
    local key  = index + 1 
    local data 
    if self.c2.selectedIndex == 0 then
        data = self.data.allRecords
    else
        data = self.data.myRecords
    end
    local strText = data[key]
    local strList = string.split(strText,ChatHerts.PROINFOHERT) --以'@'分割
    local recordTxt = obj:GetChild("n1")
    local propList = string.split(strList[2],ChatHerts.SYSTEMPRO) --"|" 道具信息
    if propList[3] then 
        local propName = mgr.TextMgr:getColorNameByMid(propList[3],1)  --道具名（品质色）
        local propHref = "<a href="..strList[2]..">"..propName.."</a>"
        local str = language.xunbao10[self.moduleId]
        recordTxt.text = string.format(language.xunbao04, strList[1],str,propHref)
        recordTxt.onClickLink:Add(self.onClickLinkText,self)
    end
end
function XunBaoSingle:onClickLinkText(context)
    local strText = context.data  
    local strList = string.split(strText,ChatHerts.SYSTEMPRO) --以'|'分割
    mgr.ChatMgr:onLinkSystemPros(strText)
end

function XunBaoSingle:setData(data)
    self.data = data or self.data
    if self.data then 
        local ybData = cache.PackCache:getPackDataById(PackMid.gold)
        self.ybTxt.text = ybData.amount
        
        self.score = self.data.score   --将寻宝信息返回的积分赋值给兑换物品之后的积分
        self.scoreTxt.text = self.score

        -- print("现在有积分",self.score)
     
        self.keyId = conf.ActivityConf:getXunBaoCostByModule(self.moduleId,1).cost[1]

        local packData = cache.PackCache:getPackDataById(self.keyId)
        self.keyAmount = packData.amount
        self.keyTxt.text = self.keyAmount --钥匙个数
        
        ------积分商城按钮红点设置----
        if self.data.isPackAnyThing and self.data.isPackAnyThing == 1 then --仓库有东西
            self.limitWareBtn:GetChild("red").visible = true 
            self.packHaveThing = true
        else
            self.limitWareBtn:GetChild("red").visible = false 
            self.packHaveThing = false
        end

        if data.allRecords then 
            if self.c2.selectedIndex == 0 then --全服
                self.listView.numItems = #data.allRecords 
            elseif self.c2.selectedIndex == 1 then  --个人
                self.listView.numItems = #data.myRecords  
            end 
            self.lastUpdateTime = data.lastUpdateTime --上次免费次数更新时间
            if data.leftFreeTimes ~= 0 then  
                self.c1.selectedIndex = 0   --有免费次数
                self.oneBtnRed.visible = true 
            else
                self.c1.selectedIndex = 1
                self.oneBtnRed.visible = false 
            end
            --购买按钮红点设置
                self.tenBtnRed.visible = false 
                self.fiftyBtnRed.visible = false 
            if self.keyAmount >= self.keyList[3].cost[2] then --第三档
                self.oneBtnRed.visible = true 
                self.tenBtnRed.visible = true 
                self.fiftyBtnRed.visible = true 
            elseif self.keyAmount >= self.keyList[2].cost[2] then--第二档
                self.oneBtnRed.visible = true 
                self.tenBtnRed.visible = true 
            elseif self.keyAmount >= self.keyList[1].cost[2] then--第一档
                self.oneBtnRed.visible = true 
            end
        else 
            self.scoreTxt.text = self.data.score --兑换之后刷新积分
        end
        if not self.timer then
            self:timeTick()
            self.timer = self.mParent:addTimer(1, -1, handler(self,self.timeTick))
        end
    end
end
--添加计时器
function XunBaoSingle:timeTick()
    local t = {
    [1155] = "free_time_refresh",
    [1163] = "jinjie_free_time_refresh",
    [1194] = "pet_free_time_refresh",
    -- [1267] = "jianling_free_time_refresh"
}
    local upDataTime = conf.ActivityConf:getValue(t[self.moduleId])
    local leftTimes = self.lastUpdateTime + upDataTime[2] - mgr.NetMgr:getServerTime()
    if leftTimes < 0 then 
        leftTimes = 0
    end
    local str = GTotimeString2(leftTimes)
    self.cdTxt.text = str
    -- print("上次免费次数更新时间",self.lastUpdateTime,"配置时间",upDataTime[2],"服务器时间",mgr.NetMgr:getServerTime(),"倒计时",str)
end
--兑换完物品之后刷新积分
function XunBaoSingle:refreshScoreData(data)
    if data then 
        self.score = data.score
        self.scoreTxt.text = data.score
    end
end

function XunBaoSingle:onClickRecord(context)
    local status = context.sender.data.status
    if status == 0 then --全服
        self.listView.numItems = #self.data.allRecords 
    elseif status == 1 then  --个人
        self.listView.numItems = #self.data.myRecords  
    end
end

function XunBaoSingle:onClickBuy(context)
    local t = {
    [1155] = 1030155,
    [1163] = 1030160,
    [1194] = 1030172,
    -- [1267] = 1030197,
}
    local msg = t[self.moduleId]
    local alertSelect = cache.ActivityCache:getXunBaoAlert()
    local status = context.sender.data.status

    local keyCost
    local keyCount 
    if status == 1 then  --购买一次或免费
        if self.c1.selectedIndex == 0 then  --免费
            proxy.ActivityProxy:sendMsg(msg,{times = 1})
            return
        else
            keyCost = self.keyList[1].cost[2]
            keyCount = self.keyList[1].count
        end
    else
        keyCost = self.keyList[status].cost[2]
        keyCount = self.keyList[status].count
    end
    local data = {haveKeyAmount = self.keyAmount,needKeyAmount = keyCost , times = keyCount,alertSelect = alertSelect,msg = msg,mid = self.keyId ,moduleId = self.moduleId}
    self:judgeHintOpen(data)
end

--判断是否开启提示弹窗
function XunBaoSingle:judgeHintOpen(data)
    if not data then return end
    local haveKeyAmount = data.haveKeyAmount or 0
    local needKeyAmount = data.needKeyAmount or 0
    local times = data.times
    local alertSelect = data.alertSelect
    local msg = data.msg
    if not  alertSelect then 
        if haveKeyAmount < needKeyAmount  then
            mgr.ViewMgr:openView2(ViewName.HintView,data)--提示弹窗
        else
            proxy.ActivityProxy:sendMsg(msg,{times = times})
        end
    else --不再提醒
        proxy.ActivityProxy:sendMsg(msg,{times = times})
    end
end

function XunBaoSingle:onLimitWare()
    mgr.ViewMgr:openView(ViewName.LimitWareView,function(view)
        proxy.ActivityProxy:sendMsg(1030154,{reqType = 1})
    end)
end

--取出物品之后
function XunBaoSingle:refreshLimitWareRed()
    self.limitWareBtn:GetChild("red").visible = false 
    self.packHaveThing = false
end
function XunBaoSingle:getPackHaveThing()
    return self.packHaveThing
end

--积分商城
function XunBaoSingle:onClickStore()
    local score 
    if self.score then 
        score = self.score --兑换完物品的积分
    else
        score = self.data.score --没有兑换，打开界面的积分
    end
    local data = {score = self.score,moduleId = self.moduleId }  --原来score = self.data.score
    mgr.ViewMgr:openView2(ViewName.ScoreStroeView,data)
end

function XunBaoSingle:clear()
    -- print("self.timers",self.timer)
    if self.timer then
        -- print("里面清理")
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

return XunBaoSingle