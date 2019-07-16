--
-- Author: 
-- Date: 2018-10-29 14:54:48
--

local TaiGuXuanJingPanel = class("TaiGuXuanJingPanel",import("game.base.Ref"))

function TaiGuXuanJingPanel:ctor(parent)
    self.parent = parent
    self.view = parent.view:GetChild("n35")
    self:initView()
end

function TaiGuXuanJingPanel:initView()
    self.mainController = self.view:GetController("c1")--主控制器
    self.mainController.selectedIndex = 8
    
    self.sceneListView = self.view:GetChild("n17")--场景层
    self.sceneListView:SetVirtual()
    self.sceneListView.itemRenderer = function(index,obj)
        self:cellSceneData(index, obj)
    end
    self.sceneListView.onClickItem:Add(self.onClickSceneItem,self)

    self.listView = self.view:GetChild("n4")--boss
    -- self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)

    self.listAwardsList = self.view:GetChild("n5")--掉落奖励
    self.listAwardsList:SetVirtual()
    self.listAwardsList.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end

    local desc = self.view:GetChild("n7")
    desc.text = language.fuben58
    self.bgImg = self.view:GetChild("n3")
    self.playerKill = self.view:GetChild("n8")--上轮击杀者
    self.warLvText = self.view:GetChild("n10")--挑战等级
    self.warLvText.text = ""

    local warBtn = self.view:GetChild("n11")
    warBtn.onClick:Add(self.onClickWar,self)
    self.TiredTxt = self.view:GetChild("n12")--.text = mgr.TextMgr:getTextColorStr(language.fuben122, 6)
    self.modelPanel = self.view:GetChild("n14")
    local followBtn = self.view:GetChild("n15")
    self.followBtn = followBtn
    followBtn.onChanged:Add(self.onClickFollow,self)

    local dec = self.view:GetChild("n6") 
    dec.text = language.fuben169
    self.tipDesc = self.view:GetChild("n21")
    self.tipDesc.text = language.fuben180

    local btn = self.view:GetChild("n22")
    btn.onClick:Add(self.onClickXianshi,self)

    local btn1 = self.view:GetChild("n25")
    btn1.onClick:Add(self.onClickKuaFu,self)
end


-- array<TgxjBossInfo> 变量名：bossInfos   说明：boss信息
-- int32
-- 变量名：leftTired   说明：leftTired
-- map<int32,int32>
-- 变量名：tipConfMap  说明：tipConfMap
function TaiGuXuanJingPanel:setData(data)
    printt("太古玄境信息>>>>>>>>>>>>>",data)

    self.data = data 
    self.bgImg.url = UIItemRes.bossWorld
    self.bossInfos = data and data.bossInfos or {}
    self.leftTired = data and data.leftTired or 0
    self.tipConfMap = data and data.tipConfMap or {}
    self.sceneData = {}--场景列表
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
    --刷新层数列表
    local page = 0
    local bossInfos = {}
    for k,v in pairs(self.bossInfos) do
        local  sceneId = v.sceneId
        if not bossInfos[sceneId] then
            bossInfos[sceneId] = {}
            table.insert(self.sceneData, {sId = sceneId})
            page = page + 1 
        end
    end
 
    table.sort(self.sceneData,function(a,b)
        if a.sId~= b.sId then
            return a.sId < b.sId
        end
    end)
    self.sceneListView.numItems = page
       --默认选第一个
    local cell = self.sceneListView:GetChildAt(0)
    cell.onClick:Call()
    -- self.listView:ScrollToView(cache.TaiGuXuanJingCache:getChooseIndex() or 0)
    self.TiredTxt.text = mgr.TextMgr:getTextColorStr(language.fuben68, 6)..mgr.TextMgr:getTextColorStr(self.leftTired, 7)
    if self.timer then
        self.parent:removeTimer(self.timer)
        self.timer = nil
    end
    self.timer = self.parent:addTimer(1, -1, handler(self, self.onTimer))
    
end

function TaiGuXuanJingPanel:onTimer()
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
                    proxy.TaiGuXuanJingProxy:send(1331501)
                    break
                end
            end
        end
    end
end

function TaiGuXuanJingPanel:cellData(index,cell)
    local key = index + 1
    local data = self.bosssceneInfos[key]
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

--层数
function TaiGuXuanJingPanel:cellSceneData(index,cell)

    local sceneId = self.sceneData[index + 1].sId

    local sceneData = conf.SceneConf:getSceneById(sceneId)
    if sceneData.cross and sceneData.cross == 2 then
        cell:GetChild("n5").visible = true
    else
        cell:GetChild("n5").visible = false
    end
    cell.title = sceneData and sceneData.name or "太古玄境"
    cell.data = sceneData
end

function TaiGuXuanJingPanel:onClickSceneItem(context)
    local btn = context.data
    if btn.data then
        self.bosssceneInfos = {}
        local sId = btn.data.id
        self.sceneId = sId
        --等级限制
        local index = sId%1000 - 1
        local openLv = conf.FubenConf:getBossValue("cross_tgxj_boss_lvs")[index] or 0
        if cache.PlayerCache:getRoleLevel() < openLv then
            GComAlter(string.format(language.tgxj01, openLv))
            btn.selected = false
            if self.chooseBtn then self.chooseBtn.selected = true   end
            return
        end
        self.chooseBtn = btn
        self.listView.numItems = 0
        local sConf = conf.SceneConf:getSceneById(sId)
        for k,v in pairs(self.bossInfos) do
            if v.sceneId == self.sceneId  and v.agentServerId == 0  then
                table.insert(self.bosssceneInfos,v)
            end
        end
        -- printt(self.bossInfos,"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        -- for k,v in pairs(self.bossInfos) do
        --     printt(v)
        -- end
        -- printt(self.sceneId,"!!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",self.bosssceneInfos)
        self.listView.numItems = #self.bosssceneInfos
        if #self.bosssceneInfos > 0 then
            local cell = self.listView:GetChildAt(0)
            cell.onClick:Call()
        end
    end
end


function TaiGuXuanJingPanel:onClickFollow()
    if self.mosterId > 0 then
        local optionVal = 0
        if self.followBtn.selected then
            optionVal = 1
        end
        self.tipConfMap[self.mosterId] = optionVal
        proxy.TaiGuXuanJingProxy:send(1331503,{monsterId = self.mosterId,optionVal = optionVal})
    end
end

function TaiGuXuanJingPanel:onClickXianshi(context)
    if self.mosterId > 0 then
       
        mgr.ViewMgr:openView2(ViewName.BossCCAwardsView, {mosterId = self.mosterId})
    end
end

function TaiGuXuanJingPanel:onClickKuaFu(context)
   local data = {}
   local sceneId = 275002
   for k,v in pairs(self.bossInfos) do
       if v.sceneId == sceneId then
            table.insert(data,clone(v))
       end
   end
    mgr.ViewMgr:openView2(ViewName.KuaFuLveDuo,data)
end


function TaiGuXuanJingPanel:clear()
    if self.timer then
        self.parent:removeTimer(self.timer)
        self.timer = nil
    end
    self.mosterId = 0
    self.listView.numItems = 0
    self.bgImg.url = ""
    self.sceneListView.numItems = 0
    self.sceneId = nil
end

--选中boss
function TaiGuXuanJingPanel:onClickItem(context)
    local cell = context.data
    local change = cell.data
    local data = change.data
    self.sceneId = data.sceneId
    local sceneData = conf.SceneConf:getSceneById(data.sceneId)
    self.playerKill.text = data.lastKillName
    -- local lvl = sceneData.lvl or 1
    -- self.warLvText.text = string.format(language.gonggong16, lvl)
    self.bossStatu = data.bossStatu
    cache.TaiGuXuanJingCache:setChooseIndex(cell.data.index)
    self:addBossModel(change.model)
    local optionVal = self.tipConfMap[self.mosterId] or 0--是否关注过
    if optionVal == 0 then
        self.followBtn.selected = false
    else
        self.followBtn.selected = true
    end
end


function TaiGuXuanJingPanel:addBossModel(model)
    local mConf = conf.MonsterConf:getInfoById(model)
    self.mosterId = model
    local awardData = conf.FubenConf:getTaiGuXuanJingAward(model)
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
    local modelObj = self.parent:addModel(src,self.modelPanel)--添加模型
    modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
    modelObj:setRotation(180)
    modelObj:setScale(100)
end

--掉落奖励
function TaiGuXuanJingPanel:cellAwardsData(index,cell)
    local awardData = self.awards[index + 1]
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
    GSetItemData(cell, itemData, true)
end

function TaiGuXuanJingPanel:onClickWar()
    if self.leftTired <= 0 then
        GComAlter(language.fuben84)
        return
    end
    cache.TaiGuXuanJingCache:setChooseBossId(self.mosterId)
 
    --缓存服务器id
    for k,v in pairs(self.bossInfos) do
        if v.sceneId == self.sceneId and v.agentServerId == 0 then 

            cache.TaiGuXuanJingCache:setagentServerId(v.agentServerId)
            break
        end
    end
    mgr.FubenMgr:gotoFubenWar2(self.sceneId)
end

function  TaiGuXuanJingPanel:updateTaiGuXuanJing( data )
    
end

function TaiGuXuanJingPanel:setGotoMonsterId(monsterId)

    self.gotoMonsterId = monsterId
end

return TaiGuXuanJingPanel