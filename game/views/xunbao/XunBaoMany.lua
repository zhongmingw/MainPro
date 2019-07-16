--
-- Author: 
-- Date: 2018-06-27 19:21:45
--寻宝分页(装备，神器)

local XunBaoMany = class("XunBaoMany",import("game.base.Ref"))
--index:寻宝主界面控制器下标
function XunBaoMany:ctor(mParent,index,moduleId)
    self.mParent = mParent
    self.index = index
    self.moduleId = moduleId
    self:initPanel()

end
local ModuleId = {
    [0] = {1155,1163,1343,1437},--装备， 进阶,仙装,奇兵
    [3] = {1239,1240,1450},--神器，洪荒,鸿蒙
    [4] = {1267,1358,1362},--剑灵,圣印,剑神装备
}
local ModulesName = {
    [0] = "n5",
    [3] = "n7",
    [4] = "n72",
}
local KeyIcon = {
    [0] = {[1155]="221071070",[1163]="221071071",[1343] = "221071490",[1437]="221071770"},--装备， 进阶,仙装，奇兵
    [3] = {[1239]="221071163",[1240]="221071164",[1450]="221071833"},--神器，洪荒,鸿蒙
    [4] = {[1267]="221071205",[1358]="221071559",[1362]="221071571"},--剑灵,圣印,剑神装备
}
local BgIcon = {
    [0] = {[1155]="xunbao_012", [1163]="xunbao_016",[1343] = "xunbao_031",[1437]="xunbao_038"},--装备， 进阶,仙装,奇兵
    [3] = {[1239]= "xunbao_012", [1240]="xunbao_017",[1450]="xunbao_012"},--神器，洪荒，鸿蒙
    [4] = {[1267]= "xunbao_017",[1358]= "xunbao_035",[1362]= "xunbao_037"},--剑灵,圣印,剑神装备
}
--进阶的1，7号位置的缩放比例
local ItemScale = {
    [0] = {[1155]=0.8,[1163]=1,[1343]=1,[1437]=0.8},
    [3] = {[1239]=0.8,[1240]=0.8,[1450]=0.8},
    [4] = {[1267]=0.8,[1358]=0.8,[1362]=0.8},
}
local redPoint = {
    [1155] = attConst.A30125,
    [1163] = attConst.A30128,
    [1239] = attConst.A30149,
    [1240] = attConst.A30150,
    [1343] = attConst.A30181,
    [1437] = attConst.A30251,
    [1267] = attConst.A30157,
    [1358] = attConst.A30216,
    [1362] = attConst.A30218,
    [1450] = attConst.A30256,
}

function XunBaoMany:initPanel()
    self:setConst()

    self.panelObj = self.mParent.view:GetChild(self.modulesName)
    --临时背包
    self.limitWareBtn = self.panelObj:GetChild("n7") 
    self.limitWareBtn.onClick:Add(self.onLimitWare,self)
    --积分商城
    local storeBtn = self.panelObj:GetChild("n11")
    storeBtn.onClick:Add(self.onClickStore,self)

    self.c1 = self.panelObj:GetController("c1") --免费&一次
    self.c2 = self.panelObj:GetController("c2") --全服&个人
    
    self.ybTxt = self.panelObj:GetChild("n28") --拥有元宝
    self.keyTxt = self.panelObj:GetChild("n24") --拥有钥匙
    self.scoreTxt = self.panelObj:GetChild("n17") --拥有积分
    self.cdTxt = self.panelObj:GetChild("n13")--免费cd
    
    --记录列表
    self.listView = self.panelObj:GetChild("n67")
    self:initListView()
    --全服记录
    local allBtn = self.panelObj:GetChild("n69") 
    allBtn.data = {status = 0}
    allBtn.onClick:Add(self.onClickRecord,self)
    --个人记录
    local selfBtn = self.panelObj:GetChild("n70") 
    selfBtn.data = {status = 1}
    selfBtn.onClick:Add(self.onClickRecord,self)
    --寻宝一次
    local onceOrFreeBtn = self.panelObj:GetChild("n6")
    onceOrFreeBtn.data = {status = 1}
    onceOrFreeBtn.onClick:Add(self.onClickBuy,self)
    --寻宝十次
    local tenBtn = self.panelObj:GetChild("n9") 
    tenBtn.data = {status = 2}
    tenBtn.onClick:Add(self.onClickBuy,self)
    --寻宝五十次
    local fiftyBtn = self.panelObj:GetChild("n10") 
    fiftyBtn.data = {status = 3}
    fiftyBtn.onClick:Add(self.onClickBuy,self)
    
    self.oneBtnRed = onceOrFreeBtn:GetChild("red")
    self.tenBtnRed = tenBtn:GetChild("red")
    self.fiftyBtnRed = fiftyBtn:GetChild("red")
    --寻宝分页
    self.tabList = self.panelObj:GetChild("n87")
    self.tabList.itemRenderer = function(index,obj)
        self:cellDataTab(index, obj)
    end
    self.tabList.numItems = 0
    self.tabList.onClickItem:Add(self.onTabListClick,self) 

    self.awardList = {} --奖励列表
    for i=72,86 do
        local itemAward = self.panelObj:GetChild("n"..i) 
        table.insert(self.awardList,itemAward)
    end
  
    self.tabIndex = self.moduleId
end

function XunBaoMany:initData(moduleId)
    self.moduleId = moduleId
    self:setTabList()--设置分页开启
    self:initAct()--初始分页的选择
    self:setShow()
end

function XunBaoMany:setConst()
    self.modulesName = ModulesName[self.index]
    self.keyIcon = KeyIcon[self.index][self.moduleId]
    self.bgIcon = BgIcon[self.index][self.moduleId]
    self.itemScale = ItemScale[self.index][self.moduleId]
    -- print("self.modulesName",self.modulesName)
    -- print("self.keyIcon",self.keyIcon)
    -- print("self.bgIcon",self.bgIcon)
    -- print("self.itemScale",self.itemScale)
end
function XunBaoMany:setTabList()
    self.openList = {}
    for k,v in pairs(ModuleId[self.index]) do
        local isOpen = mgr.ModuleMgr:CheckView(v)
        if isOpen then 
            table.insert(self.openList,v)
        end
    end
    self.tabList.numItems = #self.openList
end

function XunBaoMany:initAct()
    local isFind = false
    for k = 1,self.tabList.numItems do
        local cell = self.tabList:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local moduleId = change.moduleId
            if self.moduleId == moduleId then
                cell.onClick:Call()
                isFind =true
                break
            end
        end
    end
    if not isFind then
        if self.tabList.numItems > 0 then
            local cell = self.tabList:GetChildAt(0)
            if cell then
                cell.onClick:Call()
            end
        end
    end
end
function XunBaoMany:setShow()
    self.keyList = {}
    for i=1,3 do
        costList = conf.ActivityConf:getXunBaoCostByModule(self.moduleId,i)
        local needKeyTxt = self.panelObj:GetChild("n10"..i)
        needKeyTxt.text = costList.cost[2]
        table.insert(self.keyList,costList)
    end
    for i=1,4 do
        local keyicon = self.panelObj:GetChild("n30"..i)
        -- keyicon.url = UIPackage.GetItemURL("xunbao" ,self.keyIcon)  --钥匙icon
        keyicon.url = ResPath.iconRes(self.keyIcon)  --钥匙icon
    end
    self.bg = self.panelObj:GetChild("n71")
    self.bg.url = UIPackage.GetItemURL("xunbao",self.bgIcon)
end

function XunBaoMany:cellDataTab(index,obj)
    local moduleId = self.openList[index+1]
    obj.title = language.xunbao10[moduleId]
    local tempData = {moduleId = moduleId}
    obj.data = tempData
    local var = cache.PlayerCache:getRedPointById(redPoint[moduleId])
    local redImg = obj:GetChild("red")
    if redPoint[moduleId] == attConst.A30125 then 
        redImg.visible = false
        -- print("var",var,self.packHaveThing)
        if var > 0 then  
            if var >= 1 then
                if var == 1 and self.packHaveThing then
                    redImg.visible = false
                else
                    redImg.visible = true
                end
            end
        end
    else
        redImg.visible = var > 0 and true or false
    end
end

function XunBaoMany:onTabListClick(context)
    local cell = context.data
    local data = cell.data
    self.moduleId = data.moduleId
    self:onController()
end

function XunBaoMany:onController()
    self:setConst()
    self:setShow()
    local openDay = cache.ActivityCache:getLoopDay()--获取开服天数
    if self.moduleId == 1155 then --装备寻宝奖励
        proxy.ActivityProxy:sendMsg(1030152) --请求装备寻宝信息
        self.awardItem = conf.ActivityConf:getZhuangBeiItem(openDay)
    elseif self.moduleId == 1163 then --进阶
        proxy.ActivityProxy:sendMsg(1030156) --请求进阶寻宝信息
        self.awardItem = conf.ActivityConf:getJinJieItem(openDay)
    elseif self.moduleId == 1239 then --神器
        proxy.ActivityProxy:sendMsg(1030189) --请求神器寻宝信息
        self.awardItem = conf.ActivityConf:getShenQiItem(openDay)
    elseif self.moduleId == 1240 then --洪荒
        proxy.ActivityProxy:sendMsg(1030192) --请求洪荒寻宝信息
        self.awardItem = conf.ActivityConf:getHonghuangItem(openDay)
    elseif self.moduleId == 1343 then --仙装
        proxy.ActivityProxy:sendMsg(1030246) --请求仙装寻宝信息
        self.awardItem = conf.ActivityConf:getXianZhuangItem(openDay)
    elseif self.moduleId == 1267 then --剑灵
        proxy.ActivityProxy:sendMsg(1030195)--请求剑灵寻宝信息
        self.awardItem = conf.ActivityConf:getJianLingItem(openDay)
    elseif self.moduleId == 1358 then --圣印
        proxy.ActivityProxy:sendMsg(1030622)--请求圣印寻宝信息
        self.awardItem = conf.ActivityConf:getShengYinItem(openDay)
    elseif self.moduleId == 1362 then --剑神装备
        proxy.ActivityProxy:sendMsg(1030630)--请求剑神装备寻宝信息
        self.awardItem = conf.ActivityConf:getJianShenItem(openDay)
    elseif self.moduleId == 1437 then --奇兵
        proxy.ActivityProxy:sendMsg(1030683)--请求奇兵寻宝信息
        self.awardItem = conf.ActivityConf:getQiBingItem(openDay)
    elseif self.moduleId == 1450 then --鸿蒙
        proxy.ActivityProxy:sendMsg(1030693)--请求鸿蒙寻宝信息
        self.awardItem = conf.ActivityConf:getHongMengItem(openDay)
    end
    --print("self.moduleId",self.moduleId)
    self:setAwardItem()
end

--设置奖励列表
function XunBaoMany:setAwardItem()
    for k,v in pairs(self.awardItem) do
        if v.sort then 
            if v.sort == 7 or v.sort == 1 then
                self.awardList[v.sort]:SetScale(self.itemScale,self.itemScale)
            end
            if v.type == 1 then  
                if self.moduleId == 1343 then
                    self:setXianzhuangItem()
                else
                    self:setEquipItem()
                end
            elseif v.type == 2 and v.item then
                local isquan = 0
                self:setPropItem(v,isquan)
            elseif v.type == 3 and v.item then
                self:setPropItem(v)
            end
        end
    end
end
--仙装
function XunBaoMany:setXianzhuangItem( ... )
    -- body
    local a541 = cache.PlayerCache:getAttribute(541)
    local equips = conf.ActivityConf:getXianZhuangEquip()
    for i=1,#equips do
        if a541 >= equips[i].level[1] and a541 <= equips[i].level[2] then
            if equips[i].box then 
                local equipData = equips[i].box[1]  --宝箱样子 
                local itemData = {mid = equipData[1],amount = equipData[2],bind = equipData[3]}
                GSetItemData(self.awardList[1], itemData, true)
                break
            end
        end
    end
end

--设置装备item
function XunBaoMany:setEquipItem()
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

--设置道具item
function XunBaoMany:setPropItem(data,isquan)
    local awardData = data.item[1]  
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3],isquan = isquan}

    if ( data.sort == 13 or data.sort == 15 ) and self.moduleId == 1343 then
        --按飞升等级显示icon
        local t = {
            [13] = "feisheng_1",
            [15] = "feisheng_2"
        }
        local info = conf.ActivityConf:getValue(t[data.sort])
        local a541 = cache.PlayerCache:getAttribute(541)
        itemData.mid = info[a541] or info[1] 
        itemData.eStar = 2
       -- print("itemData.mid",itemData.mid,data.sort)
    elseif ( data.sort == 13 or data.sort == 15 ) and self.moduleId == 1362 then
        itemData.eStar = 1
    end

    GSetItemData(self.awardList[data.sort], itemData, true)    
end
function XunBaoMany:initListView()
    self.listView:SetVirtual()
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
end
function XunBaoMany:cellData(index,obj)
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
function XunBaoMany:onClickLinkText(context)
    local strText = context.data  
    local strList = string.split(strText,ChatHerts.SYSTEMPRO) --以'|'分割
    mgr.ChatMgr:onLinkSystemPros(strText)
end

function XunBaoMany:setData(data)
    self.data = data or self.data
    if self.data then 
        local ybData = cache.PackCache:getPackDataById(PackMid.gold)
        self.ybTxt.text = ybData.amount
        
        self.score = self.data.score   --将寻宝信息返回的积分赋值给兑换物品之后的积分
        self.scoreTxt.text = self.score

        -- print("现在有积分",self.score)

        ------积分商城按钮红点设置----
        if self.data.isPackAnyThing and self.data.isPackAnyThing == 1 then --仓库有东西
            self.limitWareBtn:GetChild("red").visible = true 
            self.packHaveThing = true
        else
            self.limitWareBtn:GetChild("red").visible = false 
            self.packHaveThing = false
        end
        
        self:setTabList()--设置分页

        self.keyId = conf.ActivityConf:getXunBaoCostByModule(self.moduleId,1).cost[1]

        local packData = cache.PackCache:getPackDataById(self.keyId)
        self.keyAmount = packData.amount
        self.keyTxt.text = self.keyAmount --钥匙个数
        
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
function XunBaoMany:timeTick()
    local t = {
        [0] = {[1155] = "free_time_refresh",[1163] = "jinjie_free_time_refresh",[1343]="xianequip_free_time_refresh",[1437]="qibing_free_time_refresh"},--装备， 进阶 ,仙装,奇兵
        [3] = {[1239] = "shenqi_free_time_refresh",[1240] = "honghuang_free_time_refresh",[1450] = "hm_free_time_refresh" },--神器，洪荒,鸿蒙
        [4] = {[1267] = "jianling_free_time_refresh",[1358] = "shengyin_free_time_refresh",[1362] = "jianshen_free_time_refresh"},--剑灵,圣印,剑神装备
    }
    local upDataTime = conf.ActivityConf:getValue(t[self.index][self.moduleId])
    local leftTimes = self.lastUpdateTime + upDataTime[2] - mgr.NetMgr:getServerTime()
    if leftTimes < 0 then 
        leftTimes = 0
    end
    local str = GTotimeString2(leftTimes)
    self.cdTxt.text = str
    -- print("上次免费次数更新时间",self.lastUpdateTime,"配置时间",upDataTime[2],"服务器时间",mgr.NetMgr:getServerTime(),"倒计时",str)
end
--兑换完物品之后刷新积分
function XunBaoMany:refreshScoreData(data)
    if data then 
        self.score = data.score
        self.scoreTxt.text = data.score
    end
end

function XunBaoMany:onClickRecord(context)
    local status = context.sender.data.status
    if status == 0 then --全服
        self.listView.numItems = #self.data.allRecords 
    elseif status == 1 then  --个人
        self.listView.numItems = #self.data.myRecords  
    end
end

function XunBaoMany:onClickBuy(context)
    local t = {
        [0] = {[1155] = 1030155,[1163] = 1030160,[1343] = 1030248,[1437]= 1030685},--装备,进阶,仙装，奇兵
        [3] = {[1239] = 1030191,[1240] = 1030194,[1450] = 1030695},--神器，洪荒,鸿蒙
        [4] = {[1267] = 1030197,[1358] = 1030624,[1362] = 1030632},--剑灵,圣印,剑神装备
    }
    local msg = t[self.index][self.moduleId]
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
--[[data{haveKeyAmount 拥有钥匙，needKeyAmount 需要钥匙，times 寻宝次数 alertSelect 不再提示
 msg 消息号，mid 钥匙id，moduleId 模块id}
]]
function XunBaoMany:judgeHintOpen(data)
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

function XunBaoMany:onLimitWare()
    mgr.ViewMgr:openView(ViewName.LimitWareView,function(view)
        proxy.ActivityProxy:sendMsg(1030154,{reqType = 1})
    end)
end

--取出物品之后
function XunBaoMany:refreshLimitWareRed()
    self.limitWareBtn:GetChild("red").visible = false 
    self.packHaveThing = false
end
function XunBaoMany:getPackHaveThing()
    return self.packHaveThing
end

--积分商城
function XunBaoMany:onClickStore()
    local score 
    if self.score then 
        score = self.score --兑换完物品的积分
    else
        score = self.data.score --没有兑换，打开界面的积分
    end
    local data = {score = self.score,moduleId = self.moduleId}  --原来score = self.data.score
    mgr.ViewMgr:openView2(ViewName.ScoreStroeView,data)
end

function XunBaoMany:clear()
    -- print("self.timers",self.timer)
    if self.timer then
        -- print("里面清理")
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

return XunBaoMany
