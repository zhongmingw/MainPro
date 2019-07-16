--
-- Author: ohf
-- Date: 2017-03-06 20:31:51
--
--剧情副本
local PlotPanel = class("PlotPanel",import("game.base.Ref"))

function PlotPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function PlotPanel:initPanel()
    self.confPlotData = conf.FubenConf:getPassPlot()

    local panelObj = self.mParent:getChoosePanelObj(1022)
    self.listView = panelObj:GetChild("n10")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.scrollPane.onScrollEnd:Add(self.onPackScrollPage, self)
    

    self.titleChapter = panelObj:GetChild("n2")
    
    self.awardsListView = panelObj:GetChild("n11")--扫荡奖励列表
    self.awardsListView:SetVirtual()
    self.awardsListView.itemRenderer = function(index, obj)
        self:cellAwardsData(index, obj)
    end

    local sweepBtn = panelObj:GetChild("n6")--一键扫荡
    self.sweepBtn = sweepBtn
    sweepBtn.onClick:Add(self.onClickSweep,self)
    if g_ios_test then
        sweepBtn.visible = false
    else
        sweepBtn.visible = true
    end

    local desc = panelObj:GetChild("n8")
    desc.text = language.fuben23..mgr.TextMgr:getTextColorStr(language.fuben06, 14)..language.fuben24

    local ruleBtn = panelObj:GetChild("n9")--规则按钮
    ruleBtn.onClick:Add(self.onClickRule,self)
    if g_ios_test then
        ruleBtn.visible = false
    else
        ruleBtn.visible = true
    end
    
    local leftBtn = panelObj:GetChild("n12")
    leftBtn.onClick:Add(self.onClickLeft,self)
    local rightBtn = panelObj:GetChild("n13")
    rightBtn.onClick:Add(self.onClickRight,self)
end

function PlotPanel:refreshRed()
    local redVisile = false
    if self.mData.maxPassfbId > 0 and self.mData.canFbNum > 0 then
        redVisile = true
    end
    self.sweepBtn:GetChild("red").visible = redVisile
end

function PlotPanel:setData(data)
    self.mData = data
    self:refreshRed()
    local len = #self.confPlotData
    self.listView.numItems = len
    local index = 1
    if cache.FubenCache:getPlotIndex() then--打完回来
        index = self:getPassNum(cache.FubenCache:getPlotIndex())
    else--打开界面
        local minPassId = data and data.minPassId or 0
        index = self:getPlotIndex(minPassId)
    end
    if index >= len then
        index = len
    end
    self.listView:ScrollToView(index - 1)
    self:setChapterTitle(index)
    self:setSweepAwards(self.confPlotData[index])
end
--返回当前章节可打的章节数
function PlotPanel:getPassNum(index)
    local scenes = self:getScenes(index)
    local num = 0
    for k,v in pairs(scenes) do
        local id = tonumber(string.sub(v,1,6))
        local fubenIds = self.mData and self.mData.fubenIds
        if fubenIds and fubenIds[id] then
            num = num + 1
        end
    end
    if num >= 3 then
        return index + 1
    else
        return index
    end
end
--根据最小可打关卡返回对应的章节
function PlotPanel:getPlotIndex(passId)
    if self.confPlotData then
        for index,lists in pairs(self.confPlotData) do
            for k,v in pairs(lists) do
                if v.id and v.id == passId then
                    return index
                end
            end
        end
    end
    return 1
end

function PlotPanel:cellData(index, cell)
    local lists = self.confPlotData[index + 1]
    local passList = {}
    for k,data in pairs(lists) do
        local id = tonumber(string.sub(data.id,1,6))
        local isNotFind = true
        local fubenIds = self.mData and self.mData.fubenIds
        if fubenIds and fubenIds[id] then
            isNotFind = false
        end
        if isNotFind then
            table.insert(passList, id)
        end
    end
    table.sort(passList, function(a,b)
        return a < b
    end)
    for k,data in pairs(lists) do
        local fubenItem = cell:GetChild("n"..k)
        local icon = fubenItem:GetChild("icon")
        icon.url = ""
        icon.url = UIItemRes.fuebenImg..data.view_icon
        local title = fubenItem:GetChild("n7")
        title.text = data.name
        local number = fubenItem:GetChild("n6")
        number.text = k
        local titleAward = fubenItem:GetChild("n3")

        local awards = data.first_pass_award
        local maxPassfbId = self.mData.maxPassfbId
        if self.mData and data.id > maxPassfbId then
            titleAward.url = UIItemRes.plotFuben02[1]
        else
            awards = data.normal_drop
            titleAward.url = UIItemRes.plotFuben02[2]
        end
        local awardsList = {}
        for i=12,14 do
            local awards = fubenItem:GetChild("n"..i)
            table.insert(awardsList, awards)
        end

        local sceneId = tonumber(string.sub(data.id,1,6))
        self:setAwardsData(awardsList,awards)
        local warBtn = fubenItem:GetChild("n8")
        warBtn.data = sceneId
        warBtn.onClick:Add(self.onClickWar,self)
        local redPoint = warBtn:GetChild("red")
        local num = sceneId - tonumber(string.sub(maxPassfbId,1,6))
        if num == Fuben.plot or num == 1 then--如果是第一关或者已经打到关卡的下面一关
            local sceneConfig = conf.SceneConf:getSceneById(sceneId)
            local lvl = sceneConfig and sceneConfig.lvl or 1
            local playLv = cache.PlayerCache:getRoleLevel()
            if playLv >= lvl then--可以打的关卡给红点
                redPoint.visible = true
            else
                redPoint.visible = false
            end
        else
            redPoint.visible = false
        end
        local arleayImg = fubenItem:GetChild("n4")
        local titleFrame = fubenItem:GetChild("n5")
        local lockDesc1 = fubenItem:GetChild("n11")
        local lockDesc2 = fubenItem:GetChild("n10")
        local frame = fubenItem:GetChild("n9")

        arleayImg.visible = false
        lockDesc1.visible = false
        lockDesc2.visible = false
        frame.visible = false
        warBtn.visible = false
        titleFrame.grayed = true
        icon.grayed = true
        fubenItem.selected = false
        local fubenIds = self.mData and self.mData.fubenIds
        if fubenIds and fubenIds[sceneId] then
            arleayImg.visible = true
            titleFrame.grayed = true
            icon.grayed = true
            fubenItem.touchable = false
        else
            if cache.PlayerCache:getRoleLevel() >= data.open_lv then
                warBtn.visible = true
                titleFrame.grayed = false
                icon.grayed = false
            else
                lockDesc1.text = data.open_lv
                lockDesc1.visible = true
                lockDesc2.visible = true
                frame.visible = true
                titleFrame.grayed = false
                icon.grayed = false
            end
            fubenItem.touchable = true
            if passList[1] and passList[1] == id or k == 1 then
                fubenItem.selected = true
            end
        end
    end
end
--设置奖励
function PlotPanel:setAwardsData(awardsList,awards)
    local len = #awards
    for k,v in pairs(awardsList) do
        if k == 1 then
            awardsList[k].x = 154
        elseif k == 2 then
            awardsList[k].x = 210
        elseif k == 3 then
            awardsList[k].x = 266
        end
        if len == 1 then
            if k == 2 then
                local data = {mid = awards[1][1],amount = awards[1][2],bind = awards[1][3]}
                GSetItemData(v, data, true)
            else
                awardsList[k].visible = false
            end
        elseif len == 2 then
            if k == 3 then
                awardsList[k].visible = false
            else
                if k == 1 then
                    awardsList[k].x = 190
                elseif k == 2 then
                    awardsList[k].x = 246
                end
                local data = {mid = awards[k][1],amount = awards[k][2],bind = awards[k][3]}
                GSetItemData(v, data, true)
            end
        else
            local data = {mid = awards[k][1],amount = awards[k][2],bind = awards[k][3]}
            GSetItemData(v, data, true)
        end 
    end
end

function PlotPanel:onPackScrollPage()
    local index = self.listView.scrollPane.currentPageX + 1
    self:setChapterTitle(index)
    cache.FubenCache:setPlotIndex(index)
    self.pageIndex = index
end

function PlotPanel:setChapterTitle(index)
    local scenes = self:getScenes(index)
    local sceneId = tonumber(string.sub(scenes[1],1,6))
    local sceneData = conf.SceneConf:getSceneById(sceneId)
    local img = sceneData and sceneData.title_font or ""
    self.titleChapter.url = UIPackage.GetItemURL("fuben" , tostring(img))
end

function PlotPanel:getScenes(index)
    local lists = self.confPlotData[index]
    local scenes = {}
    for k,v in pairs(lists) do
        local id = tonumber(string.sub(v.id,1,6))
        table.insert(scenes, id)
    end
    return scenes
end

--设置一键扫荡的奖励
function PlotPanel:setSweepAwards(lists)
    self.awards = {}
    for k,v in pairs(lists) do
        local awards = v.normal_drop
        if awards then
            for k,v in pairs(awards) do
                table.insert(self.awards, v)
            end
        end
    end
    self.awardsListView.numItems = #self.awards
end

function PlotPanel:cellAwardsData(index,cell)
    local award = self.awards[index + 1]
    local data = {mid = award[1],amount = award[2],bind = award[3]}
    GSetItemData(cell, data, true)
end

function PlotPanel:onClickWar(context)
    mgr.FubenMgr:gotoFubenWar(context.sender.data)
end

function PlotPanel:onClickSweep()
    if self.mData.maxPassfbId > 0 and self.mData.canFbNum > 0 then
        -- local money =  conf.FubenConf:getValue("juqing_saodang_cost") * self.mData.canFbNum
        -- local text = string.format(language.fuben38, money)
        -- local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(text, 11),sure = function()
        --     local bmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
        --     local tmoney = cache.PlayerCache:getTypeMoney(MoneyType.copper) or 0--拥有的金钱
        --     if tmoney >= money or bmoney >= money then
        --         proxy.FubenProxy:send(1024202)
        --     else
        --         GComAlter(language.gonggong29)
        --     end
        -- end}
        proxy.FubenProxy:send(1024202)
        -- GComAlter(param)
    else
        GComAlter(language.fuben37)
    end
end

function PlotPanel:onClickLeft()
    local index = self.listView.scrollPane.currentPageX - 1
    if self.listView.scrollPane.currentPageX == 0 then
        GComAlter(language.fuben75)
    end
    if index <= 0 then
        index = 0
        GComAlter(language.fuben75)
    end
    self:setChapterTitle(index + 1)
    self.listView:ScrollToView(index,true)
end

function PlotPanel:onClickRight()
    local index = self.listView.scrollPane.currentPageX + 1
    local len = #self.confPlotData - 1
    if self.listView.scrollPane.currentPageX == len then
        GComAlter(language.fuben76)
    end
    if index >= len then
        index = len
    end
    self:setChapterTitle(index + 1)
    self.listView:ScrollToView(index,true)
end
--规则
function PlotPanel:onClickRule()
    GOpenRuleView(1023)
end

function PlotPanel:clear()
    self.listView.numItems = 0
end

function PlotPanel:destory()
    if g_var.gameFrameworkVersion >= 2 then
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_022")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_023")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_024")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_054")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_055")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_056")
    end
end

return PlotPanel