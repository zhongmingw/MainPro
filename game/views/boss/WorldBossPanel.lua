--
-- Author: ohf
-- Date: 2017-04-10 14:25:55
--
--世界boss
local WorldBossPanel = class("WorldBossPanel",import("game.base.Ref"))

function WorldBossPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function WorldBossPanel:initPanel()
    self.mosterId = 0--怪物id
    self.leftTired = 0--疲劳值
    local panelObj = self.mParent.view:GetChild("n6")
    self.mainController = panelObj:GetController("c1")--主控制器
    self.mainController.selectedIndex = 0
    self.listView = panelObj:GetChild("n4")--boss
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    self.listView.scrollPane.onScroll:Add(self.doSpecialEffect, self)

    self.listAwardsList = panelObj:GetChild("n5")--掉落奖励
    self.listAwardsList:SetVirtual()
    self.listAwardsList.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end

    local desc = panelObj:GetChild("n7")
    desc.text = language.fuben58
    self.playerKill = panelObj:GetChild("n8")--上轮击杀者
    self.warLvText = panelObj:GetChild("n10")--挑战等级
    local warBtn = panelObj:GetChild("n11")
    warBtn.onClick:Add(self.onClickWar,self)
    self.countText = panelObj:GetChild("n12")
    -- panelObj:GetChild("n13").text = language.fuben69
    self.modelPanel = panelObj:GetChild("n14")
    self.bgImg = panelObj:GetChild("n3")
    local followBtn = panelObj:GetChild("n15")
    self.followBtn = followBtn
    followBtn.onChanged:Add(self.onClickFollow,self)
    local dec = panelObj:GetChild("n6") 
    dec.text = language.fuben168
    self.tipDesc = panelObj:GetChild("n21")
    self.tipDesc.text = language.fuben180

    local btn = panelObj:GetChild("n22")
    btn.onClick:Add(self.onClickXianshi,self)

    local addBtn = panelObj:GetChild("n16")--bxp 世界boss增加购买次数
    addBtn.onClick:Add(self.onClickAdd,self)
    local dec2 = panelObj:GetChild("n24")
    dec2.text = language.funben228
end

function WorldBossPanel:setGotoMonsterId(monsterId)
    self.gotoMonsterId = monsterId
end

function WorldBossPanel:setData(data)
    self.bgImg.url = UIItemRes.bossWorld
    self.bossInfos = data and data.bossInfos or {}
    self.leftTired = data and data.leftTired or 0
    self.tipConfMap = data and data.tipConfMap or {}
    self.dayBuyCount = data and data.dayBuyCount or 0
    table.sort(self.bossInfos,function(a,b)
        if a.sceneId == b.sceneId then
            local aConf = conf.MonsterConf:getInfoById(a.monsterId)
            local bConf = conf.MonsterConf:getInfoById(b.monsterId)
            local alvl = aConf and aConf.level or 0
            local blvl = bConf and bConf.level or 0
            return alvl < blvl
        else
            return a.sceneId < b.sceneId
        end
    end)
    if self.gotoMonsterId then--外部跳转
        for k,v in pairs(self.bossInfos) do
            if v.monsterId == self.gotoMonsterId then
                cache.FubenCache:setWordIndex(k - 1)
                break
            end
        end
    end
    self.listView.numItems = #self.bossInfos
    self.listView:ScrollToView(cache.FubenCache:getWordIndex())
    if self.gotoMonsterId then--外部跳转
        self.isSpecialEffect = false
    end
    self:initChooseBoss()
    self.countText.text = mgr.TextMgr:getTextColorStr(language.fuben68, 6)..mgr.TextMgr:getTextColorStr(self.leftTired, 7)
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.gotoMonsterId = nil
end

function WorldBossPanel:initChooseBoss()
    -- if self.isSpecialEffect then return end
    for k = 1,3 do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local index = change.index
            if index == cache.FubenCache:getWordIndex() then--选中boss
                cell.onClick:Call()
                break
            end
        end
    end
end

function WorldBossPanel:cellData(index,cell)
    local key = index + 1
    local data = self.bossInfos[key]
    local image1 = cell:GetChild("n1")
    local image2 = cell:GetChild("n2")
    local icon = cell:GetChild("icon")

    local sceneData = conf.SceneConf:getSceneById(data.sceneId)
    local isKuafu = cell:GetChild("n9")  --EVE 设置世界boss标志
    local cross = sceneData and sceneData.cross or 0
    if cross > 0 then 
        isKuafu.visible = true
    else  
        isKuafu.visible = false
    end
    local viewIcon = sceneData and sceneData.view_icon or ""
    icon.url = UIPackage.GetItemURL("boss" , tostring(viewIcon))
    local timeText = cell:GetChild("n10")--刷新时间
    local time = data.nextRefreshTime - mgr.NetMgr:getServerTime()
    if time > 0 then
        timeText.text = GTotimeString(time)
    else
        timeText.text = ""
    end
    local model = data.monsterId
    local mConf = conf.MonsterConf:getInfoById(model)
    local name = mConf and mConf.name or ""
    local bossText = cell:GetChild("n8")
    bossText.text = name
    local lvl_section = sceneData and sceneData.lvl_section
    local lvText = cell:GetChild("n7")
    local lvl = mConf and mConf.level or 1
    local str = "LV"..lvl
    if cache.PlayerCache:getRoleLevel() >= lvl then
        lvText.text = mgr.TextMgr:getTextColorStr(str, 5)
    else
        lvText.text = mgr.TextMgr:getTextColorStr(str, 14)
    end
    local arleayImg = cell:GetChild("n4")--已刷新
    local unAppear = cell:GetChild("n5")--未出现
    local bossStatu = data.bossStatu
    arleayImg.visible = false
    unAppear.visible = false
    image1.grayed = false
    image2.grayed = false
    icon.grayed = false
    if bossStatu == 1 then--已死亡
        image1.grayed = true
        image2.grayed = true
        icon.grayed = true
    elseif bossStatu == 2 then--未出现
        unAppear.visible = true
    elseif bossStatu == 3 then--已经刷新
        arleayImg.visible = true
    end
    cell.data = {data = data, index = index, model = model}
end
--掉落奖励
function WorldBossPanel:cellAwardsData(index,cell)
    local awardData = self.awards[index + 1]
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
    GSetItemData(cell, itemData, true)
end

function WorldBossPanel:onTimer()
    for k = 1,3 do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local data = change.data
            if data.bossStatu == 1 then--boss已经死了
                local timeText = cell:GetChild("n10")--刷新时间
                local time = data.nextRefreshTime - mgr.NetMgr:getServerTime()
                if time > 0 then
                    timeText.text = GTotimeString(time)
                else
                    timeText.text = ""
                    proxy.FubenProxy:send(1330201)
                    break
                end
            end
        end
    end
end

function WorldBossPanel:doSpecialEffect()
    self.isSpecialEffect = true
end
--选中boss
function WorldBossPanel:onClickItem(context)
    local cell = context.data
    local change = cell.data
    local data = change.data
    self.sceneId = data.sceneId
    local sceneData = conf.SceneConf:getSceneById(data.sceneId)
    self.playerKill.text = data.lastKillName
    local lvl = sceneData.lvl or 1
    self.warLvText.text = string.format(language.gonggong16, lvl)
    self.bossStatu = data.bossStatu
    cache.FubenCache:setWordIndex(cell.data.index)
    self:addBossModel(change.model)
    local optionVal = self.tipConfMap[self.mosterId] or 0--是否关注过
    if optionVal == 0 then
        self.followBtn.selected = false
    else
        self.followBtn.selected = true
    end
    self.isSpecialEffect = false
end

function WorldBossPanel:addBossModel(model)
    local mConf = conf.MonsterConf:getInfoById(model)
    self.mosterId = model
    local awardData = conf.FubenConf:getWorldBossAward(model)
    local awardLv = awardData and awardData.no_reward_lev or 1
    if cache.PlayerCache:getRoleLevel() >= awardLv then
        self.tipDesc.visible = true
    else
        self.tipDesc.visible = false
    end
    local name = mConf and mConf.name or ""
    self.awards = mConf and mConf.normal_drop or {}
    self.listAwardsList.numItems = #self.awards
    local src = mConf and mConf.src or 0
    local modelObj = self.mParent:addModel(src,self.modelPanel)--添加模型
    modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
    modelObj:setRotation(180)
    modelObj:setScale(100)
end

function WorldBossPanel:onClickWar()
    if self.leftTired <= 0 then
        GComAlter(language.fuben84)
        return
    end
    cache.FubenCache:setChooseBossId(self.mosterId)
    mgr.FubenMgr:gotoFubenWar2(self.sceneId)
end

function WorldBossPanel:onClickFollow()
    if self.mosterId > 0 then
        local optionVal = 0
        if self.followBtn.selected then
            optionVal = 1
        end
        self.tipConfMap[self.mosterId] = optionVal
        proxy.FubenProxy:send(1330203,{monsterId = self.mosterId,optionVal = optionVal})
    end
end

function WorldBossPanel:onClickXianshi()
    if self.mosterId > 0 then
        mgr.ViewMgr:openView2(ViewName.BossCCAwardsView, {mosterId = self.mosterId})
    end
end

function WorldBossPanel:onClickAdd()
    local vipConf = conf.VipChargeConf:getAllVIPAwards()
    local maxVIP = #vipConf - 1
    local curVipLv = cache.PlayerCache:getVipLv()
    --当前vip可购买次数
    local curCountConf = conf.VipChargeConf:getWorldBossRest(curVipLv)
    --最大可购买次数
    local maxCanRest = conf.VipChargeConf:getWorldBossRest(maxVIP)
    --当前剩余可购买次数
    local curCount = curCountConf - self.dayBuyCount
    local money = conf.FubenConf:getBossValue("world_boss_buy_cost")
    local t = clone(language.fuben225)
    t[1].text = string.format(t[1].text,money[2])
    t[3].text = string.format(t[3].text,curCount)
    --可以购买次数的VIp等级
    local nextVip
    for i= 0, maxVIP do
        local rest = conf.VipChargeConf:getWorldBossRest(i)
        if rest > curCountConf then
            nextVip = i
            break
        end
    end
    local param = {
        type = 14,
        richtext = mgr.TextMgr:getTextByTable(t),
        okUrl = UIItemRes.imagefons04,
        sure = function()
            if curCount <= 0 then--剩余疲劳值不足
                local t1 = clone(language.fuben226)
                t1[3].text = string.format(t1[3].text,nextVip and nextVip or maxVIP)
                local t2 = clone(language.fuben227)
                t2[1].text = string.format(t2[1].text,maxCanRest)
                if curCountConf == maxCanRest then
                     curVipLv = maxVIP
                end
                local richStr = tonumber(curVipLv) == tonumber(maxVIP) and t2 or t1
                local temp = {
                    type = 5,
                    sureIcon = curVipLv == maxVIP and UIItemRes.imagefons01 or UIItemRes.imagefons06,
                    richtext = mgr.TextMgr:getTextByTable(richStr),
                    sure = function ()
                        if curVipLv == maxVIP then
                        
                        else
                            GGoVipTequan(1)
                            self.mParent:closeView()
                        end
                    end
                }
                GComAlter(temp)
                return
            else
                proxy.FubenProxy:send(1330305,{sceneKind = 9,count = 1})--9:世界boss 31:宠物岛
            end
        end
    }
    GComAlter(param)
end

function WorldBossPanel:setBossLeftTimes(data)
    printt(">>>>",data)
    if data and data.sceneKind == 9 then
        self.mData = data
        self.leftTired = data and data.leftTired or 0
        self.countText.text = mgr.TextMgr:getTextColorStr(language.fuben165, 6)..mgr.TextMgr:getTextColorStr(self.leftTired, 7)
    end
end

function WorldBossPanel:clear()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
    self.isSpecialEffect = false
    self.mosterId = 0
    self.bgImg.url = ""
    self.listView.numItems = 0
end

return WorldBossPanel