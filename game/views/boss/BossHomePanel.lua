--
-- Author: 
-- Date: 2017-10-17 15:32:40
--

local BossHomePanel = class("BossHomePanel",import("game.base.Ref"))

function BossHomePanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function BossHomePanel:initPanel()
    self.mosterId = 0--怪物id
    local panelObj = self.mParent.view:GetChild("n26")
    self.mainController = panelObj:GetController("c1")--主控制器
    self.mainController.selectedIndex = 2

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
    panelObj:GetChild("n12").text = mgr.TextMgr:getTextColorStr(language.fuben122, 6)
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
end

function BossHomePanel:setGotoSceneId(sceneId)
    self.gotoSceneId = sceneId
end

function BossHomePanel:setGotoMonsterId(monsterId)
    self.gotoMonsterId = monsterId
end

function BossHomePanel:setData(data)
    self.bgImg.url = UIItemRes.bossWorld
    local bossInfos = data and data.bossInfos or {}
    self.tipConfMap = data and data.tipConfMap or {}
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
            page = page + 1
        end
        table.insert(self.bossInfos[sceneId], v)
    end
    local pageIndex = 0--跳转的页签
    if self.gotoSceneId then
        pageIndex = self.gotoSceneId - BossScene.bosshome
    end
    if self.gotoMonsterId then--外部跳转
        for sceneId,bossList in pairs(self.bossInfos) do
            for k,v in pairs(bossList) do
                if v.monsterId == self.gotoMonsterId then
                    cache.FubenCache:setBossHomeIndex(k - 1)
                    pageIndex = sceneId - BossScene.bosshome
                    break
                end
            end
        end
    end

    self.sceneListView.numItems = page
    self.sceneListView:ScrollToView(pageIndex)
    self:initChooseScene(pageIndex)
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.gotoSceneId = nil
    self.gotoMonsterId = nil
end

function BossHomePanel:initChooseScene(pageIndex)
    local max = self.sceneListView.numItems
    if max > 8 then
        max = 8
    end
    for k = 1,max do
        local cell = self.sceneListView:GetChildAt(k - 1)
        if cell then
            local sceneData = cell.data
            local sceneId = sceneData.id
            local chooseSceneId = BossScene.bosshome + pageIndex
            if sceneId == chooseSceneId then--选中boss
                cell.onClick:Call()
                break
            end
        end
    end
end
--层数
function BossHomePanel:cellSceneData(index,cell)
    local sceneData = conf.SceneConf:getSceneById(index + BossScene.bosshome)
    cell.title = sceneData and sceneData.name or "Boss之家"
    cell.data = sceneData
end

function BossHomePanel:onClickSceneItem(context)
    local sceneData = context.data.data
    local sceneId = sceneData.id or BossScene.bosshome
    self.bossList = self.bossInfos[sceneId]
    self.listView.numItems = #self.bossList
    if cache.FubenCache:getBossHomeIndex() > #self.bossList - 1 then
        cache.FubenCache:setBossHomeIndex(0)
    end
    self.listView:ScrollToView(cache.FubenCache:getBossHomeIndex())
    for k = 1,#self.bossList do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local index = change.index
            if index == cache.FubenCache:getBossHomeIndex() then--选中boss
                cell.onClick:Call()
                break
            end
        end
    end
end
--boss列表
function BossHomePanel:cellData(index,cell)
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

function BossHomePanel:cellAwardsData(index, cell)
    local awardData = self.awards[index + 1]
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
    GSetItemData(cell, itemData, true)
end

function BossHomePanel:onTimer()
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
                        -- proxy.FubenProxy:send(1450101)
                        data.nextRefreshTime = 0
                        data.bossStatu = 3
                        break
                    end
                end
            end
        end
    end
end

function BossHomePanel:onClickItem(context)
    local cell = context.data
    local change = cell.data
    local data = change.data
    self.sceneId = data.sceneId
    local sceneData = conf.SceneConf:getSceneById(data.sceneId)
    self.playerKill.text = data.lastKillName
    local lvl = sceneData.lvl or 1
    self.warLvText.text = string.format(language.gonggong16, lvl)
    self.bossStatu = data.bossStatu
    cache.FubenCache:setBossHomeIndex(cell.data.index)
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

function BossHomePanel:addBossModel(model)
    local mConf = conf.MonsterConf:getInfoById(model)
    self.mosterId = model
    local awardData = conf.FubenConf:getBossHomeAward(model)
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
function BossHomePanel:onClickFollow()
    if self.mosterId > 0 then
        local optionVal = 0
        if self.followBtn.selected then
            optionVal = 1
        end
        self.tipConfMap[self.mosterId] = optionVal
        proxy.FubenProxy:send(1450103,{monsterId = self.mosterId,optionVal = optionVal})
    end
end

function BossHomePanel:onClickXianshi()
    if self.mosterId > 0 then
        mgr.ViewMgr:openView2(ViewName.BossCCAwardsView, {mosterId = self.mosterId})
    end
end

function BossHomePanel:onClickWar()
    local confData = conf.FubenConf:getBossHomeLayer(self.sceneId)
    local cons = confData and confData.con or {}
    local notXianzun = true
    for k,v in pairs(cons) do
        if cache.PlayerCache:VipIsActivate(tonumber(v)) then--拥有了其中一个仙尊
            notXianzun = false
            break
        end
    end
    if notXianzun then
        local xianZun = cons[1] or 1
        local gold = confData and confData.cost_gold or 0
        local param = {type = 14,richtext = mgr.TextMgr:getTextColorStr(string.format(language.fuben123, language.fuben124[xianZun], gold), 6),cancelUrl = UIItemRes.imagefons05,sure = function()
            cache.FubenCache:setChooseBossId(self.mosterId)
            mgr.FubenMgr:gotoFubenWar2(self.sceneId)
        end,cancel = function()
            GOpenView({id = 1050})
        end}
        GComAlter(param)
    else
        cache.FubenCache:setChooseBossId(self.mosterId)
        mgr.FubenMgr:gotoFubenWar2(self.sceneId)
    end
end

function BossHomePanel:clear()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
    self.mosterId = 0
    self.bgImg.url = ""
    self.sceneListView.numItems = 0
    self.listView.numItems = 0
end

return BossHomePanel