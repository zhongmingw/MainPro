--
-- Author: wx
-- Date: 2018-08-21 15:31:16
--

local FeishengPanel = class("FeishengPanel",import("game.base.Ref"))

function FeishengPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function FeishengPanel:initPanel()
    -- body
    local panelObj = self.mParent.view:GetChild("n32")
    self.mainController = panelObj:GetController("c1")--主控制器
    self.mainController.selectedIndex = 2
    self.listView = panelObj:GetChild("n4")--列表
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj) --boss
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

function FeishengPanel:cellData( index, obj )
    -- body
end

function FeishengPanel:doSpecialEffect()
    -- body
    self.isSpecialEffect = true
end

function FeishengPanel:onClickItem(context)
    local cell = context.data
    local data = cell.data
end

function FeishengPanel:cellAwardsData( index, obj )
    -- body
end

function FeishengPanel:onClickWar()
    -- body
    if self.sceneId then
        cache.FubenCache:setChooseBossId(self.mosterId)
        mgr.FubenMgr:gotoFubenWar(self.sceneId)
    end
end

--关注
function FeishengPanel:onClickFollow()
    if self.mosterId > 0 then
        local optionVal = 0
        if self.followBtn.selected then
            optionVal = 1
        end
        self.tipConfMap[self.mosterId] = optionVal
        proxy.FubenProxy:send(1330902,{monsterId = self.mosterId,optionVal = optionVal})
    end
end
function FeishengPanel:clear()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
    self.isSpecialEffect = false
    self.mosterId = 0
    self.bgImg.url = ""
    self.listView.numItems = 0
end

function FeishengPanel:onClickXianshi()
    if self.mosterId > 0 then
        mgr.ViewMgr:openView2(ViewName.BossCCAwardsView, {mosterId = self.mosterId})
    end
end

function FeishengPanel:onTimer()
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

function FeishengPanel:addBossModel(model)
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

function FeishengPanel:initChooseBoss()
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

function FeishengPanel:setData(data)
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
function FeishengPanel:setGotoMonsterId(monsterId)
    self.gotoMonsterId = monsterId
end

return FeishengPanel