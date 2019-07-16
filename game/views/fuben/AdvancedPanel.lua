--
-- Author: ohf
-- Date: 2017-03-06 20:30:35
--
--进阶副本
local AdvancedPanel = class("AdvancedPanel",import("game.base.Ref"))

function AdvancedPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function AdvancedPanel:initPanel()
    self.sweepList = {}--可扫荡关卡
    self.diff = 1
    self.confPassData = conf.FubenConf:getPassAdvanced()
    local panelObj = self.mParent:getChoosePanelObj(1019)
    self.c1 = panelObj:GetController("c1")
    self.listView = panelObj:GetChild("n3")
    -- self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    self.fubenItem = panelObj:GetChild("n22")
    self.fubenBtn = panelObj:GetChild("n4")--挑战 重置按钮
    self.fubenRed = self.fubenBtn:GetChild("red")
    self.fubenBtn.onClick:Add(self.onClickFuben,self)

    local sweepBtn = panelObj:GetChild("n6")
    self.sweepRed = sweepBtn:GetChild("red")
    sweepBtn.onClick:Add(self.onClickSweep,self)
    if g_ios_test then
        sweepBtn.visible = false
    else
        sweepBtn.visible = true
    end

    self.somoneyText = panelObj:GetChild("n30")
    self.somoneyText.text = 0
    self.moneyText = panelObj:GetChild("n15")
    self.moneyText.text = 0
    local ruleBtn = panelObj:GetChild("n18")
    ruleBtn.onClick:Add(self.onClickRule,self)
    if g_ios_test then
        ruleBtn.visible = false
    else
        ruleBtn.visible = true
    end
    local costText = panelObj:GetChild("n29")
    costText.text = language.fuben209
end
--进入界面
function AdvancedPanel:setData()
    self.listView.numItems = 0
    self.playLv = cache.PlayerCache:getRoleLevel()
    -- self.viplv = cache.PlayerCache:getVipLv()
    -- plog(self.maxResetCount)
    self.confPassData2 = {}
    for k,v in pairs(self.confPassData) do
        local sceneId = tonumber(string.sub(v.id,1,6))
        local sceneData = conf.SceneConf:getSceneById(sceneId)
        local openLv = sceneData and sceneData.lvl or 1
        if self.playLv >= openLv then--只加入等级达到的
            if sceneData.open_day then
                --开服天数限制
                local data = cache.ActivityCache:get5030111()
                if data and data.openDay >= sceneData.open_day then
                    table.insert(self.confPassData2, v)
                end  
            else
                table.insert(self.confPassData2, v)
            end
        end
    end
    self.listView.numItems = #self.confPassData2
end
--加载数据
function AdvancedPanel:cellData(index, cell)
    local fubenData = self.confPassData2[index + 1]
    local title = cell:GetChild("title")
    title.text = fubenData.name
    cell.data = {fubenData = fubenData,index = index}
    local key = cache.FubenCache:getAdvIndex() or 0
    if key >= #self.confPassData2 then key = 0 end
    if index == key then
        cell.selected = true
        local context = {data = cell}
        self:onClickItem(context)
    end
end

function AdvancedPanel:initRedPoint()
    local redNum = 0
    self.sweepList = {}--可扫荡关卡
    for k,v in pairs(self.confPassData2) do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local fubenData = cell.data.fubenData
            local sceneId = tonumber(string.sub(fubenData.id,1,6))
            local redPanel = cell:GetChild("n4")
            local redText = cell:GetChild("n5")
            local num = self.redMap and self.redMap[sceneId] or 0
            redText.visible = false
            if num > 0 then
                redPanel.visible = true
                redNum = redNum + 1
                v.red = 1
            else
                v.red = 0
                redPanel.visible = false
            end
            local confData = conf.FubenConf:getFubenSweepCost(fubenData.id)
            local sweepLv = confData and confData.lev or 1
            if cache.PlayerCache:getRoleLevel() >= sweepLv then
                table.insert(self.sweepList, v)
            end
        end
    end
    if redNum == 0 then--红点刷新
        mgr.GuiMgr:redpointByVar(attConst.A50101,0)
    end
    self:btnRedPoint()
end

function AdvancedPanel:btnRedPoint()
    local redNum = self.redMap and self.redMap[self.sceneId] or 0
    local warRedVisile = false
    local sweepRedVisile = false
    if redNum > 0 then
        -- plog("redNum",redNum)
        if self.c1.selectedIndex == 0 then--可挑战
            local lvl = self.fubenData.open_lv or 1
            local playLv = cache.PlayerCache:getRoleLevel()
            -- plog("可挑战",playLv,lvl)
            if playLv >= lvl then
                warRedVisile = true
            else
                GComAlter(string.format(language.gonggong07, lvl))
            end
        end
        --可扫荡
        -- local leftCount = self.diffCountMap and self.diffCountMap[1] or 0
        -- if leftCount > 0 and cache.PlayerCache:VipIsActivate(2) then
        --     -- plog("可扫荡",leftCount,cache.PlayerCache:VipIsActivate(2))
        --     sweepRedVisile = true
        -- end
        --bxp
        local mPassId = self.sceneId * 1000 + 1  --bxp 扫荡红点 
        local confData = conf.FubenConf:getFubenSweepCost(mPassId)
        local sweepLv = confData and confData.lev or 1
        if cache.PlayerCache:getRoleLevel() >= sweepLv or  self.todayResetCount == 1 then
            sweepRedVisile = true
        end
    end
    -- plog("warRedVisile",warRedVisile)
    self.fubenRed.visible = warRedVisile
    self.sweepRed.visible = sweepRedVisile
end

function AdvancedPanel:onClickItem(context)
    local cell = context.data
    local fubenData = cell.data.fubenData
    -- printt(lists)
    self.fubenData = fubenData
    local sceneId = tonumber(string.sub(fubenData.id,1,6))
    self.sceneId = sceneId
    proxy.FubenProxy:send(1024401,{sceneId = sceneId})
    cache.FubenCache:setAdvIndex(cell.data.index)
end
--选中的数据
function AdvancedPanel:updateFuben(data)
    self.todayResetCount = data and data.todayResetCount or 0
    self.diffCountMap = data and data.diffCountMap or {}
    self.redMap = data and data.redMap or {}

    local icon = self.fubenItem:GetChild("n1")
    icon.url = UIItemRes.fuebenImg..tostring(self.fubenData.view_icon)
    -- local titleImg = self.fubenItem:GetChild("n16")
    -- titleImg.url = UIPackage.GetItemURL("fuben" , tostring(UIItemRes.advFuben03[2]))
    local awards = self.fubenData.normal_drop
    local listView = self.fubenItem:GetChild("n13")
    listView:SetVirtual()
    listView.itemRenderer = function(index, obj)
        local award = awards[index + 1]
        local data = {mid = award[1],amount = award[2],bind = award[3]}
        GSetItemData(obj, data, true)
    end
    listView.numItems = #awards
    local textLv = self.fubenItem:GetChild("n12")
    local openFrame = self.fubenItem:GetChild("n5")
    local openlv = self.fubenData.open_lv or 1
    textLv.text = string.format(language.gonggong07, openlv)
    if self.playLv < openlv then
        textLv.visible = true
        openFrame.visible = true
    else
        textLv.visible = false
        openFrame.visible = false
    end
    self:setMyData()
    self:initRedPoint()
end
--扫荡后刷新副本
function AdvancedPanel:refreshFuben()
    GComAlter(language.fuben66)
    proxy.FubenProxy:send(1024401,{sceneId = self.sceneId})
end
--设置对应难度的数据
function AdvancedPanel:setMyData()
    local fubenId = self.fubenData.id
    local sceneId = tonumber(string.sub(fubenId,1,6))
    local leftCount = self.diffCountMap and self.diffCountMap[1] or 0
    self.fubenBtn.enabled = true
    if leftCount then
        if leftCount > 0 then--可挑战
            local maxOverCount = conf.SceneConf:getSceneById(sceneId).max_over_count
            if self.todayResetCount <= maxOverCount then  --bxp 从小于改为小于等于
                self.c1.selectedIndex = 0
            end
        else
            local count = conf.FubenConf:getValue("jinjie_fuben_max_buycount") or 0
            if self.todayResetCount >= count then
                self.fubenBtn.enabled = false
            end
            self.c1.selectedIndex = 1--可重置
        end
    else
        self.c1.selectedIndex = 0
    end
    self:setResetMoney()
end
--重置进阶副本
function AdvancedPanel:resetFuben(data)
    self.rmData = data
    GComAlter(language.fuben45)
    self.todayResetCount = data.todayResetCount
    if self.diffCountMap then
        self.diffCountMap[1] = data.leftCount
    end

    local sceneId = self.sceneId or 0
    proxy.FubenProxy:send(1024401,{sceneId = sceneId})
    GOpenAlert3(data.items)
end

--设置重置消耗的金币
function AdvancedPanel:setResetMoney()
    local sceneId = tonumber(string.sub(self.fubenData.id,1,6))
    --plog(sceneId,"sceneId")
    local value = conf.FubenConf:getValue("jinjie_fuben_cost")
    local money = 0
    money = value[self.diff]
    self.moneyText.text = money
    local value = conf.FubenConf:getValue("jinjie_fuben_so_cost")
    self.somoneyText.text = value[1]
end

function AdvancedPanel:onClickFuben()
    if not self.fubenData then return end
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    local data = self.fubenData
    -- if cell.alpha == 1 then
    local sceneId = tonumber(string.sub(data.id,1,6))
    if self.c1.selectedIndex == 0 then--可挑战
        local lvl = data.open_lv or 1
        local playLv = cache.PlayerCache:getRoleLevel()
        if playLv >= lvl then
            proxy.ThingProxy:sChangeScene(sceneId,0,0,3,data.id)
        else
            GComAlter(string.format(language.gonggong07, lvl))
        end
    elseif self.c1.selectedIndex == 1 then--可重置
        self:onClickReset()            
    end
    -- end
end

function AdvancedPanel:onClickSweep()
    if not self.sceneId then return end
    local mPassId = self.sceneId * 1000 + 1
    local confData = conf.FubenConf:getFubenSweepCost(mPassId)
    local sweepLv = confData and confData.lev or 1
    local leftCount = self.diffCountMap and self.diffCountMap[1] or 0 --剩余次数
    if self.todayResetCount and self.todayResetCount == 1 then --bxp  如果有重置，可直接扫荡
        if leftCount <= 0 then 
           GComAlter(language.fuben155) 
        else
            proxy.FubenProxy:send(1024403,{sceneId = self.sceneId,diff = 0,ids = {self.sceneId * 1000 + 1}})
        end
        return
    else  --没有重置  按照等级要求扫荡
        if cache.PlayerCache:getRoleLevel() < sweepLv then
            GComAlter(string.format(language.fuben197,sweepLv))
        elseif leftCount <= 0 then 
            GComAlter(language.fuben155) 
        else
            proxy.FubenProxy:send(1024403,{sceneId = self.sceneId,diff = 0,ids = {self.sceneId * 1000 + 1}})
        end
    end
end

--规则
function AdvancedPanel:onClickRule()
    GOpenRuleView(1020)
end
--重置
function AdvancedPanel:onClickReset()
    if not self.fubenData then return end
    local sceneId = tonumber(string.sub(self.fubenData.id,1,6))
    proxy.FubenProxy:send(1024402,{sceneId = self.sceneId,diff = 1}) 
end

function AdvancedPanel:clear()
    self.fubenItemList = {}
    self.sweepList = {}--可扫荡关卡
    -- for i=1,3 do
    --     local fubenItem = self.panelItem:GetChild("n"..i)
    --     local icon = fubenItem:GetChild("n1")
    --     icon.url = ""
    -- end
end

return AdvancedPanel