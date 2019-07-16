--
-- Author: 
-- Date: 2018-07-16 11:02:54
--五行神殿

local WuXingPanel = class("WuXingPanel",import("game.base.Ref"))

function WuXingPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function WuXingPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n31")
    self.mainController = panelObj:GetController("c1")--主控制器
    self.mainController.selectedIndex = 6
    self.listView = panelObj:GetChild("n4")--列表
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    self.listView.scrollPane.onScroll:Add(self.doSpecialEffect, self)

    self.awardsListView = panelObj:GetChild("n5")--掉落奖励
    self.awardsListView:SetVirtual()
    self.awardsListView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end
    local warBtn = panelObj:GetChild("n11")
    warBtn.onClick:Add(self.onClickWar,self)
    self.bgImg = panelObj:GetChild("n3")

    self.modelPanel = panelObj:GetChild("n14")

    local followBtn = panelObj:GetChild("n15")
    self.followBtn = followBtn
    followBtn.onChanged:Add(self.onClickFollow,self)
    self.warLvText = panelObj:GetChild("n10")--挑战等级
    self.playerKill = panelObj:GetChild("n8")--上轮击杀者
    self.tipDesc = panelObj:GetChild("n21")
    self.tipDesc.text = language.fuben180

    local btn = panelObj:GetChild("n22")
    btn.onClick:Add(self.onClickXianshi,self)

    local textDec = panelObj:GetChild("n23")
    textDec.text = language.funben229
end

function WuXingPanel:setGotoMonsterId(monsterId)
    self.gotoMonsterId = monsterId
end


function WuXingPanel:setData(data)
    self.bgImg.url = UIItemRes.bossWorld
    self.bossInfos = data and data.bossInfos or {}
    self.tipConfMap = data and data.tipConfMap or {}
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
                cache.FubenCache:setWuXingIndex(k - 1)
                break
            end
        end
    end
    self.listView.numItems = #self.bossInfos
    self.listView:ScrollToView(cache.FubenCache:getWuXingIndex())
    if self.gotoMonsterId then--外部跳转
        self.isSpecialEffect = false
    end
    self:initChooseBoss()
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.gotoMonsterId = nil
end

function WuXingPanel:initChooseBoss()
    for k = 1,#self.bossInfos do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local index = change.index
            if index == cache.FubenCache:getWuXingIndex() then--选中boss
                cell.onClick:Call()
                break
            end
        end
    end
end

function WuXingPanel:doSpecialEffect()
    self.isSpecialEffect = true
end

function WuXingPanel:onClickXianshi()
    if self.mosterId > 0 then
        mgr.ViewMgr:openView2(ViewName.BossCCAwardsView, {mosterId = self.mosterId})
    end
end

function WuXingPanel:cellData(index, cell)
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
    print("下一次刷新时间-当前服务器时间",(data.nextRefreshTime-mgr.NetMgr:getServerTime()))
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

function WuXingPanel:cellAwardsData(index, cell)
    local awardData = self.awards[index + 1]
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
    GSetItemData(cell, itemData, true)
end

function WuXingPanel:onTimer()
    if self.listView.numItems > 0 then
        for k = 1,#self.bossInfos do
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
                        proxy.FubenProxy:send(1330901)
                        break
                    end
                end
            end
        end
    end
end

function WuXingPanel:onClickWar()
    if self.sceneId then
        cache.FubenCache:setChooseBossId(self.mosterId)
        mgr.FubenMgr:gotoFubenWar(self.sceneId)
    end
end

function WuXingPanel:onClickItem(context)
    local cell = context.data
    local change = cell.data
    local data = change.data
    self.sceneId = data.sceneId
    print("boss对应场景ID",data.sceneId)
    local sceneData = conf.SceneConf:getSceneById(data.sceneId)
    self.playerKill.text = data.lastKillName
    local lvl = sceneData.lvl or 1
    self.warLvText.text = string.format(language.gonggong16, lvl)
    self.bossStatu = data.bossStatu
    cache.FubenCache:setWuXingIndex(cell.data.index)
    self:addBossModel(change.model)
    local optionVal = self.tipConfMap[self.mosterId] or 0--是否关注过
    if optionVal == 0 then
        self.followBtn.selected = false
    else
        self.followBtn.selected = true
    end
    self.isSpecialEffect = false
    
end

function WuXingPanel:addBossModel(model)
    local mConf = conf.MonsterConf:getInfoById(model)
    self.mosterId = model
    local awardData = {}

    awardData = conf.FubenConf:getWxsdAward(model)
    local awardLv = awardData and awardData.no_reward_lev or 1
    if cache.PlayerCache:getRoleLevel() >= awardLv then
        self.tipDesc.visible = true
    else
        self.tipDesc.visible = false
    end
    local name = mConf and mConf.name or ""
    self.awards = mConf and mConf.normal_drop or {}
    self.awardsListView.numItems = #self.awards
    local src = mConf and mConf.src or 0
    print("设置模型",model,src)
    local modelObj = self.mParent:addModel(src,self.modelPanel)--添加模型
    modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
    modelObj:setRotation(180)
    modelObj:setScale(100)
end

--关注
function WuXingPanel:onClickFollow()
    if self.mosterId > 0 then
        local optionVal = 0
        if self.followBtn.selected then
            optionVal = 1
        end
        self.tipConfMap[self.mosterId] = optionVal
        proxy.FubenProxy:send(1330902,{monsterId = self.mosterId,optionVal = optionVal})
    end
end


function WuXingPanel:clear()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
    self.isSpecialEffect = false
    self.mosterId = 0
    self.bgImg.url = ""
    self.listView.numItems = 0
end

return WuXingPanel
