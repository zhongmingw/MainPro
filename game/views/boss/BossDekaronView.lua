--
-- Author: 
-- Date: 2017-07-18 15:48:10
--

local BossDekaronView = class("BossDekaronView", base.BaseView)

local TimeClose = 10

function BossDekaronView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function BossDekaronView:initView()
    self.ctrl = self.view:GetController("c1")
    local btnClose = self.view:GetChild("n3")
    btnClose.onClick:Add(self.onClickClose,self)
    self.timeText = self.view:GetChild("n4")
    self.timeText.text = ""
    self.worldBoss1 = self.view:GetChild("n5")
    self.worldBoss2 = self.view:GetChild("n6")
    self.worldListView = self.worldBoss2:GetChild("n10")
    self.worldListView:SetVirtual()
    self.worldListView.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end

    self.eliteBoss = self.view:GetChild("n7")
    self.eliteListView = self.eliteBoss:GetChild("n1")
    self.eliteListView:SetVirtual()
    self.eliteListView.itemRenderer = function(index,obj)
        self:cellRankData(index, obj)
    end
    self.awakenBoss1 = self.view:GetChild("n8")
    self.awakenBoss2 = self.view:GetChild("n9")
    self.titleImg = self.view:GetChild("n2")
end
--1.世界boss 50%提示 2.世界boss结算提示 3.精英boss结算提示,
function BossDekaronView:setData(data,type)
    if type == 5 then
        self.ctrl.selectedIndex = 1
    else
        self.ctrl.selectedIndex = type - 1
    end
    
    self.mData = data
    if type == 1 then
        -- self.titleImg.url = UIPackage.GetItemURL(UICommonRes[6] , tostring(UIItemRes.gxhd01)) --标题
        self:setWordBoss1()
    elseif type == 2 then
        -- self.titleImg.url = UIPackage.GetItemURL(UICommonRes[6] , tostring(UIItemRes.gxhd01)) --标题
        self:setWordBoss2()
    elseif type == 3 then
        self:setEliteBoss()
    elseif type == 4 then
        self:setAwakenBoss1()
    elseif type == 5 then
        --家园boss击杀
        self:setHomeBoss()
    end
    self.time = TimeClose
    if not self.bossTimer then
        self.bossTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    if gRole and type > 3 then
        gRole:stopAI()
        mgr.HookMgr:cancelHook()
    end
end

function BossDekaronView:onTimer()
    self.timeText.text = mgr.TextMgr:getTextColorStr(string.format(language.fuben11, self.time), 7)
    if self.time <= 0 then
        self:onClickClose()
        return
    end
    self.time = self.time - 1
end

function BossDekaronView:setWordBoss1()
    local richText = clone(language.fuben86)
    richText[2].text = string.format(richText[2].text, self.mData.bossName)
    self.worldBoss1:GetChild("n0").text = mgr.TextMgr:getTextByTable(richText)
    local sceneId = self.mData.sceneId or 0
    local confData = conf.FubenConf:getWorldAward(sceneId,3)
    local awards = confData and confData.items or {}
    local listView = self.worldBoss1:GetChild("n1")
    listView.itemRenderer = function(index,obj)
        local award = awards[index + 1]
        local itemData = {mid = award[1],amount = award[2], bind = award[3]}
        GSetItemData(obj, itemData)
    end
    listView.numItems = #awards
end

function BossDekaronView:setWordBoss2()
    local richText = clone(language.fuben87)
    richText[2].text = string.format(richText[2].text, self.mData.bossName)
    self.worldBoss2:GetChild("n0").text = mgr.TextMgr:getTextByTable(richText)
    self.worldBoss2:GetChild("n4").text = language.fuben88
    self.worldBoss2:GetChild("n7").text = mgr.TextMgr:getTextColorStr(self
        .mData.hateRoleName, 3)
    local sceneId = self.mData.sceneId or 0
    local hateItem = self.worldBoss2:GetChild("n1")--仇恨归属
    local confData = conf.FubenConf:getWorldAward(sceneId,1)
    local award = confData and confData.items[1] or {}
    
    self.worldListView.numItems = #self.mData.items
end

function BossDekaronView:cellAwardData(index, obj)
    local itemData = self.mData.items[index + 1]
    GSetItemData(obj, itemData)
end

--[[结构体描述：boss排名信息
结构体名：BossRankInfo
备注：备注：
1   int64   变量名: roleId 说明: 角色Id
2   string  变量名: roleName   说明: 玩家名字
3   int32   变量名: hurtPercent    说明: 伤害百分比
4   int32   变量名: rank   说明: 排名]]
function BossDekaronView:setEliteBoss()
    local richText 
    if mgr.FubenMgr:isKuaFuBoss(self.mData.sceneId) then
        --如果是跨服精英boss
        self.titleImg.url = UIPackage.GetItemURL("boss" , tostring(UIItemRes.eliteBoss01)) --标题
        richText = clone(language.fuben94)
    else
        self.titleImg.url = UIPackage.GetItemURL("boss" , tostring(UIItemRes.eliteBoss01)) --标题
        --单服精英boss
        richText = clone(language.fuben93)
    end
    richText[2].text = string.format(richText[2].text, self.mData.bossName)
    self.eliteBoss:GetChild("n0").text = mgr.TextMgr:getTextByTable(richText)
    self.eliteListView.numItems = #self.mData.ranking
end

function BossDekaronView:cellRankData(index,cell)
    local data = self.mData.ranking[index + 1]
    local rank = data.rank
    cell:GetChild("n1").text = rank
    cell:GetChild("n2").text = data.roleName
    cell:GetChild("n3").text = string.format("%.1f", (data.hurtPercent / 100)).."%"
    local listView = cell:GetChild("n0")
    local confData = {}
    if mgr.FubenMgr:isKuaFuBoss(self.mData.sceneId) then
        --如果是跨服精英boss
        confData = conf.KuaFuConf:getEliteAward(self.mData.sceneId,rank)
    else
        confData = conf.FubenConf:getEliteAward(self.mData.sceneId,rank)
    end
    local awards = confData and confData.items or {}
    listView.itemRenderer = function(index,obj)
        local award = awards[index + 1]
        local itemData = {mid = award[1],amount = award[2], bind = award[3]}
        GSetItemData(obj, itemData)
    end
    listView.numItems = #awards
end

function BossDekaronView:setHomeBoss()
    -- body
    local richText = clone(language.fuben87)
    richText[2].text = string.format(richText[2].text, self.mData.bossName)
    self.worldBoss2:GetChild("n0").text = mgr.TextMgr:getTextByTable(richText)

    self.worldBoss2:GetChild("n4").text = language.fuben88
    self.worldBoss2:GetChild("n7").text = mgr.TextMgr:getTextColorStr(self
        .mData.hateRoleName, 3)

    self.worldListView.numItems = #self.mData.items
end

function BossDekaronView:setAwakenBoss1()
    local richText = clone(language.awaken42)
    local monsterId = self.mData and self.mData.monsterId or 0
    local mConf = conf.MonsterConf:getInfoById(monsterId)
    local name = mConf and mConf.name or ""
    richText[2].text = string.format(richText[2].text, name)
    self.awakenBoss1:GetChild("n0").text = mgr.TextMgr:getTextByTable(richText)
    self.awakenBoss1:GetChild("n4").text = language.fuben88
    self.awakenBoss1:GetChild("n5").text = language.fuben89
    self.awakenBoss1:GetChild("n6").text = language.awaken43
    self.awakenBoss1:GetChild("n7").text = mgr.TextMgr:getTextColorStr(self
        .mData.hateRoleName, 3)
    self.awakenBoss1:GetChild("n8").text = mgr.TextMgr:getTextColorStr(self.mData.killerName, 3)
    self.awakenBoss1:GetChild("n9").text = language.awaken44[1]
    self.awakenBoss1:GetChild("n10").text = language.awaken44[2]
    self.awakenBoss1:GetChild("n11").text = language.awaken44[3]
    -- local sceneId = self.mData.sceneId or 0
    local confData = conf.AwakenConf:getJsdBossAward(monsterId)
    local hateItem = self.awakenBoss1:GetChild("n1")--仇恨归属
    local award = confData and confData.hate_items[1] or {}
    local itemData = {mid = award[1],amount = award[2], bind = award[3]}
    GSetItemData(hateItem, itemData)

    local killItem = self.awakenBoss1:GetChild("n2")--最后一刀
    local award = confData and confData.kill_items[1] or {}
    local itemData = {mid = award[1],amount = award[2], bind = award[3]}
    GSetItemData(killItem, itemData)

    local normalItem = self.awakenBoss1:GetChild("n3")--参与者
    local award = confData and confData.join_items[1] or {}
    local itemData = {mid = award[1],amount = award[2], bind = award[3]}
    GSetItemData(normalItem, itemData)
end

function BossDekaronView:setAwakenBoss2()
    -- body
end

function BossDekaronView:onClickClose()
    if self.bossTimer then
        self:removeTimer(self.bossTimer)
        self.bossTimer = nil
    end
    if self.ctrl.selectedIndex >= 2 then
        mgr.FubenMgr:quitFuben()
    end
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isKuafuWorld(sId) then
        -- if cache.FubenCache:getKuafuBossTired() == 1 then
        --     -- local text = language.fuben213
        --     -- local param = {type = 8,richtext = mgr.TextMgr:getTextColorStr(text, 6),richtext1 = language.tip12,sureIcon = UIItemRes.imagefons01,sure = function(isNotTip)
        --     --     cache.FubenCache:setKuafuBossNotTip(isNotTip)
        --     -- end}
        --     -- GComAlter(param)
        --     mgr.ViewMgr:openView2(ViewName.BossTiredTipView,data)
        -- end
        --cache.FubenCache:setKuafuBossTired(cache.FubenCache:getKuafuBossTired() - 1)
    end
    self:closeView()
end

return BossDekaronView