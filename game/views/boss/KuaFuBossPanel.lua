--
-- Author: 
-- Date: 2018-01-10 16:20:01
--
--宠物岛
local KuaFuBossPanel = class("KuaFuBossPanel",import("game.base.Ref"))

function KuaFuBossPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function KuaFuBossPanel:initPanel()
    self.mosterId = 0--怪物id
    local panelObj = self.mParent.view:GetChild("n28")
    self.mainController = panelObj:GetController("c1")--主控制器
    self.mainController.selectedIndex = 4

    self.sceneListView = panelObj:GetChild("n17")--场景层
    self.sceneListView:SetVirtual()
    self.sceneListView.itemRenderer = function(index,obj)
        self:cellSceneData(index, obj)
    end
    self.sceneListView.onClickItem:Add(self.onClickSceneItem,self)

    self.listView = panelObj:GetChild("n4")--boss
    -- self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)

    self.listAwardsList = panelObj:GetChild("n5")--掉落奖励
    self.listAwardsList:SetVirtual()
    self.listAwardsList.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end

    local desc = panelObj:GetChild("n7")
    desc.text = language.fuben58
    self.descText = panelObj:GetChild("n9")
    self.descText.text = ""
    self.playerKill = panelObj:GetChild("n8")--上轮击杀者
    self.warLvText = panelObj:GetChild("n10")--挑战等级
    local warBtn = panelObj:GetChild("n11")
    warBtn.onClick:Add(self.onClickWar,self)
    self.countText = panelObj:GetChild("n12")
    self.modelPanel = panelObj:GetChild("n14")
    self.bgImg = panelObj:GetChild("n3")
    local followBtn = panelObj:GetChild("n15")
    self.followBtn = followBtn
    followBtn.onChanged:Add(self.onClickFollow,self)

    local dec = panelObj:GetChild("n6") 
    dec.text = language.fuben169
    self.tipDesc = panelObj:GetChild("n21")
    self.tipDesc.text = language.fuben180

    local btn = panelObj:GetChild("n22")
    btn.onClick:Add(self.onClickXianshi,self)

    local addBtn = panelObj:GetChild("n16")--bxp 世界boss增加购买次数
    addBtn.onClick:Add(self.onClickAdd,self)

    local dec2 = panelObj:GetChild("n24")
    dec2.text = language.funben228
end

-- function KuaFuBossPanel:setGotoSceneId(sceneId)
--     self.gotoSceneId = sceneId
-- end

function KuaFuBossPanel:setGotoMonsterId(monsterId)
    self.gotoMonsterId = monsterId
end

function KuaFuBossPanel:setData(data)
    self.bgImg.url = UIItemRes.bossWorld
    local bossInfos = data and data.bossInfos or {}
    self.leftTired = data and data.leftTired or 0
    self.tipConfMap = data and data.tipConfMap or {}
    self.dayBuyCount = data and data.dayBuyCount or 0
    -- printt("当前boss信息>>>>>>>>>>>>>",bossInfos)
    local sceneId = bossInfos[1].sceneId
    -- local sceneData = conf.SceneConf:getSceneById(sceneId)
    -- local kind = sceneData and sceneData.kind or 0
    -- if kind == SceneKind.kuafuworld then
    --     self.initSceneId = BossScene.kuafuworld
    -- else
    --     self.initSceneId = BossScene.kfpet
    -- end
    if not self.initSceneId then
        self.initSceneId = sceneId
    end
    table.sort(bossInfos,function(a,b)
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
    self.bossInfos = {}--二维表
    local page = 0
    for k,v in pairs(bossInfos) do
        local sceneId = v.sceneId
        if not self.bossInfos[sceneId] then
            self.bossInfos[sceneId] = {}
            -- print("宠物岛sceneid>>>>>>>>>>>>>>>",sceneId)
            page = page + 1
        end
        table.insert(self.bossInfos[sceneId], v)
    end
    local pageIndex = 0--跳转的页签
    -- if self.gotoSceneId then
    --     pageIndex = self.gotoSceneId - BossScene.kuafuworld
    -- end
    if self.gotoMonsterId then--外部跳转
        for sceneId,bossList in pairs(self.bossInfos) do
            for k,v in pairs(bossList) do
                if v.monsterId == self.gotoMonsterId then
                    cache.FubenCache:setKuafuBossIndex(k - 1)
                    pageIndex = (sceneId - self.initSceneId)==0 and 0 or 1
                    break
                end
            end
        end
    end

    self.sceneListView.numItems = page
    self.sceneListView:ScrollToView(pageIndex)
    self:initChooseScene(pageIndex)
    self.countText.text = mgr.TextMgr:getTextColorStr(language.fuben68, 6)..mgr.TextMgr:getTextColorStr(self.leftTired, 7)
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    -- self.gotoSceneId = nil
    self.gotoMonsterId = nil
end

function KuaFuBossPanel:initChooseScene(pageIndex)
    local max = self.sceneListView.numItems
    if max > 8 then
        max = 8
    end
    for k = 1,max do
        local cell = self.sceneListView:GetChildAt(k - 1)
        if cell then
            local sceneData = cell.data
            local sceneId = sceneData.id
            -- print("选中场景id>>>>>>>>>>",sceneId)
            -- local chooseSceneId = self.initSceneId + pageIndex
            if sceneId == self.initSceneId then--选中boss
                cell.onClick:Call()
                break
            end
        end
    end
end
--层数
function KuaFuBossPanel:cellSceneData(index,cell)
    local sceneId = self.initSceneId
    for k,v in pairs(self.bossInfos) do
        if v[1].sceneId%1000 == index+1 then
            sceneId = v[1].sceneId
            break
        end
    end
    local sceneData = conf.SceneConf:getSceneById(sceneId)
    if sceneData.cross and sceneData.cross == 2 then
        cell:GetChild("n5").visible = true
    else
        cell:GetChild("n5").visible = false
    end
    cell.title = sceneData and sceneData.name or "Boss之家"
    cell.data = sceneData
end

function KuaFuBossPanel:onClickSceneItem(context)
    local btn = context.data
    local sceneData = context.data.data
    local sceneId = sceneData.id or self.initSceneId
    self.initSceneId = sceneId
    -- print("场景id>>>>>>>>>>>",sceneId,sceneData.id,BossScene.kuafuworld)
    -- printt("场景boss信息>>>>>>>>",self.bossInfos)
    local index = sceneId%1000 - 1
    local openLv = conf.FubenConf:getBossValue("cross_world_boss_lvs")[index] or 0
    if cache.PlayerCache:getRoleLevel() < openLv then
        GComAlter(string.format(language.gonggong07, openLv))
        btn.selected = false
        if self.chooseBtn then self.chooseBtn.selected = true end
        return
    end
    self.chooseBtn = btn
    self.bossList = self.bossInfos[sceneId]
    self.listView.numItems = #self.bossList
    -- print("滚动索引>>>>>>>>>>>>",cache.FubenCache:getKuafuBossIndex())
    if cache.FubenCache:getKuafuBossIndex() > #self.bossList - 1 then
        cache.FubenCache:setKuafuBossIndex(0)
    end
    self.listView:ScrollToView(cache.FubenCache:getKuafuBossIndex())
    for k = 1,#self.bossList do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local index = change.index
            if index == cache.FubenCache:getKuafuBossIndex() then--选中boss
                cell.onClick:Call()
                break
            end
        end
    end
end
--boss列表
function KuaFuBossPanel:cellData(index,cell)
    local key = index + 1
    local data = self.bossList[key]
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

function KuaFuBossPanel:cellAwardsData(index, cell)
    local awardData = self.awards[index + 1]
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
    GSetItemData(cell, itemData, true)
end

function KuaFuBossPanel:onTimer()
    if self.listView.numItems > 0 then
        for k = 1,self.listView.numItems do
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
                        plog("boss刷新时间",data.nextRefreshTime,"当前服务器时间",mgr.NetMgr:getServerTime(),time,data.monsterId.."的时间已到,需要刷新")
                        data.nextRefreshTime = 0
                        data.bossStatu = 3
                        proxy.FubenProxy:send(1330501)
                        break
                    end
                end
            end
        end
    end
end

function KuaFuBossPanel:onClickItem(context)
    local cell = context.data
    local change = cell.data
    local data = change.data
    self.sceneId = data.sceneId
    local sceneData = conf.SceneConf:getSceneById(data.sceneId)
    self.playerKill.text = data.lastKillName
    local lvl = sceneData.lvl or 1
    self.warLvText.text = string.format(language.gonggong16, lvl)
    self.bossStatu = data.bossStatu
    cache.FubenCache:setKuafuBossIndex(cell.data.index)
    self:addBossModel(change.model)
    local optionVal = self.tipConfMap[self.mosterId] or 0--是否关注过
    if optionVal == 0 then
        self.followBtn.selected = false
    else
        self.followBtn.selected = true
    end
    local confData = conf.FubenConf:getBossHomeLayer(self.sceneId)
    local cons = confData and confData.con or {}
    local xianZun = cons[1] or 1
    self.descText.text = string.format(language.fuben126, language.fuben124[xianZun])
end

function KuaFuBossPanel:addBossModel(model)
    local mConf = conf.MonsterConf:getInfoById(model)
    self.mosterId = model
    local awardData = conf.FubenConf:getKuafuWorldAward(model)
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
--关注
function KuaFuBossPanel:onClickFollow()
    if self.mosterId > 0 then
        local optionVal = 0
        if self.followBtn.selected then
            optionVal = 1
        end
        self.tipConfMap[self.mosterId] = optionVal
        proxy.FubenProxy:send(1330503,{monsterId = self.mosterId,optionVal = optionVal})
    end
end

function KuaFuBossPanel:onClickXianshi()
    if self.mosterId > 0 then
        mgr.ViewMgr:openView2(ViewName.BossCCAwardsView, {mosterId = self.mosterId})
    end
end

function KuaFuBossPanel:onClickWar()
    local leftTired = self.leftTired or 0
    if leftTired <= 0 then
        return GComAlter(language.kuafu13)
    end
    cache.FubenCache:setKuafuBossTired(leftTired)
    cache.FubenCache:setChooseBossId(self.mosterId)
    if self.sceneId then
        mgr.FubenMgr:gotoFubenWar2(self.sceneId)
    end
end

function KuaFuBossPanel:onClickAdd()
    local vipConf = conf.VipChargeConf:getAllVIPAwards()
    local maxVIP = #vipConf - 1
    local curVipLv = cache.PlayerCache:getVipLv()
    --当前vip可购买次数
    local curCountConf = conf.VipChargeConf:getPetBossReset(curVipLv)
     --最大可购买次数
    local maxCanRest = conf.VipChargeConf:getPetBossReset(maxVIP)
    --当前可购买次数
    local curCount = curCountConf - self.dayBuyCount
    local money = conf.FubenConf:getBossValue("cwd_boss_buy_cost")
    local t = clone(language.fuben225)
    t[1].text = string.format(t[1].text,money[2])
    t[3].text = string.format(t[3].text,curCount)
    --可以购买次数的VIp等级
    local nextVip
    for i= 0, maxVIP do
        local rest = conf.VipChargeConf:getPetBossReset(i)
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
                proxy.FubenProxy:send(1330305,{sceneKind = 31,count = 1})--9:世界boss 31:宠物岛
            end
        end
    }
    GComAlter(param)
end

function KuaFuBossPanel:setKuFuLeftTimes(data)
    if data and data.sceneKind == 31 then
        self.mData = data
        self.leftTired = data and data.leftTired or 0
        cache.FubenCache:setKuafuBossTired(self.leftTired)
        self.countText.text = mgr.TextMgr:getTextColorStr(language.fuben165, 6)..mgr.TextMgr:getTextColorStr(self.leftTired, 7)
    end
end


function KuaFuBossPanel:clear()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
    self.mosterId = 0
    self.bgImg.url = ""
    self.sceneListView.numItems = 0
    self.listView.numItems = 0
    self.initSceneId = nil
end

return KuaFuBossPanel