--
-- Author: ohf 
-- Date: 2017-03-09 11:16:46
--
--爬塔副本
local TowerPanel = class("TowerPanel",import("game.base.Ref"))

local defineNum = 1000
local barValue =  {13,30,50,70,90,100}
local levelNum = FuebenLevelNum.tower

function TowerPanel:ctor(mParent)
    self.effectList = {}
    self.downEffectList = {}
    self.mParent = mParent
    self:initPanel()
end

function TowerPanel:initPanel()
    self.sceneId = Fuben.tower
    self.scenePex = self.sceneId * defineNum
    self.confPassTower,self.lastData = conf.FubenConf:getPassTower()
    local panelObj = self.mParent:getChoosePanelObj(1024)
    self.listView = panelObj:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end

    local warBtn = panelObj:GetChild("n6")
    warBtn.onClick:Add(self.onClickWar,self)
    self.warRed = warBtn:GetChild("red")

    local sweepBtn = panelObj:GetChild("n7")--一键扫荡
    self.sweepBtn = sweepBtn
    sweepBtn.onClick:Add(self.onClickSweep,self)
    if g_ios_test then
        sweepBtn.visible = false
    else
        sweepBtn.visible = true
    end

    self.sweepText = panelObj:GetChild("n11")
    self.sweepText.text = ""

    self.timeText = panelObj:GetChild("n9")
    self.timeText.text = language.fuben23..mgr.TextMgr:getTextColorStr(language.fuben06, 14)..language.fuben24

    local ruleBtn = panelObj:GetChild("n8")
    ruleBtn.onClick:Add(self.onClickRule,self)
    if g_ios_test then
        ruleBtn.visible = false
    else
        ruleBtn.visible = true
    end

    local btnShop = panelObj:GetChild("n10")--爬塔商店
    btnShop.onClick:Add(self.onClickShop,self)
    if g_ios_test then
        btnShop.visible = false
    else
        btnShop.visible = true
    end
    local leftBtn = panelObj:GetChild("n5")
    leftBtn.onClick:Add(self.onClickLeft,self)
    local rightBtn = panelObj:GetChild("n4")
    rightBtn.onClick:Add(self.onClickRight,self)
end

function TowerPanel:setData(data)
    self.mData = data
    --当前可扫荡的关卡
    local passId = self.mData and self.mData.currId or 0
    self.currId = passId
    if passId == 0 then
        passId = self.scenePex
    end
    local saodangId = self.mData and self.mData.saodangMaxId or 0
    if saodangId - passId > 0 then
        local saodangPass = tonumber(string.sub(saodangId,7,9))
        self.sweepText.text = mgr.TextMgr:getTextColorStr(language.fuben44, 8)..mgr.TextMgr:getTextColorStr(string.format(language.bangpai127, saodangPass), 7)
        self.sweepBtn:GetChild("red").visible = true
    else
        self.sweepText.text = ""
        self.sweepBtn:GetChild("red").visible = false
    end 
    if cache.PlayerCache:getRedPointById(attConst.A50106) > 0 then
        self.warRed.visible = true
    else
        self.warRed.visible = false
    end
    -- printt(cache.FubenCache:getTowerFirst())
    local roleIcon = cache.PlayerCache:getRoleIcon()
    self.sex = GGetMsgByRoleIcon(roleIcon).sex
    self.listView.numItems = #self.confPassTower
    self:gotoScrollView()
end

function TowerPanel:cellData(index, cell)
    local bg = cell:GetChild("n39")
    bg.url = ""
    bg.url = UIItemRes.towerFuben02
    local lists = self.confPassTower[index + 1]
    local textList = {}
    for i=15,19 do
        local text = cell:GetChild("n"..i)
        table.insert(textList, text)
    end
    local arleayList = {}
    for i=29,33 do
        local arleayImg = cell:GetChild("n"..i)
        arleayImg.visible = false
        table.insert(arleayList, arleayImg)
    end
    local modelList = {}
    for i=34,38 do
        local model = cell:GetChild("n"..i)
        table.insert(modelList, model)
    end
    local downList = {}--特殊底盘
    for i=40,44 do
        local down = cell:GetChild("n"..i)
        down.url = UIItemRes.towerFuben03[1]
        table.insert(downList, down)
    end
    local topList = {}--标题
    for i=45,49 do
        local top = cell:GetChild("n"..i)
        top.url = ""
        table.insert(topList, top)
    end
    local awardBxList = {}--装备
    for i=21,25 do
        local awardBx = cell:GetChild("n"..i)
        awardBx.url = ""
        table.insert(awardBxList, awardBx)
    end
    local effectList = {}
    for i=54,58 do--底特效
        local effect = cell:GetChild("n"..i)
        effect.visible = false
        table.insert(effectList, effect)
    end
    local awardItem = cell:GetChild("n22")
    local bar = cell:GetChild("n28")
    for k,v in pairs(lists) do
        local passId = v.id
        local text = textList[k]
        text.text = tonumber(string.sub(passId,7,10))
        if self.currId >= passId then--已通关
            arleayList[k].visible = true
        end
        local isSpec = false--是否是特殊未首通关卡或者刚刚首通的关卡
        local firstModels = v.first_models
        local itemChest = v.item_chest
        local saodangId = self.mData and self.mData.saodangMaxId or 0
        local firstId = 0
        for k,v in pairs(cache.FubenCache:getTowerFirst()) do
            if v == passId then--找到刚刚首通过的关卡
                firstId = v
                break
            end
        end
        -- plog(firstId,saodangId)
        if firstId > 0 and firstId <= saodangId then--刚刚首通的关卡
            if firstModels or itemChest then
                isSpec = true
            end
        else
            if passId > saodangId then
                if firstModels or itemChest then
                    isSpec = true
                end
            end
        end
        local parent = modelList[k]
        if isSpec then
            if firstModels then
                topList[k].url = UIItemRes.towerFuben04[1]
                self:setPassModel(firstModels[self.sex],parent,120,RoleSexModel[self.sex].angle)
            end
            if itemChest then
                topList[k].url = UIItemRes.towerFuben04[2]
                local src = conf.ItemConf:getSrc(itemChest)
                awardBxList[k].url = ResPath.iconRes(tostring(src))
                self:setPassEffect1(parent,passId)
            end
            downList[k].url = UIItemRes.towerFuben03[2]
            effectList[k].visible = true
            self:setPassEffect2(effectList[k],passId)
        else
            self:setPassModel(v.model,parent,70,180)
        end
    end
    self:setProgressBar(index,bar,lists)
end

function TowerPanel:setPassModel(modelId,parent,modelScale,angle)
    local modelObj = self.mParent:addModel(modelId,parent)--添加模型
    modelObj:setPosition(parent.actualWidth/2,-parent.actualHeight-249,500)
    modelObj:setRotation(angle)
    local scale = modelScale or 70
    modelObj:setScale(scale)
end

function TowerPanel:setPassEffect1(parent,passId)
    if self.effectList[passId] then
        self.mParent:removeUIEffect(self.effectList[passId])
        self.effectList[passId] = nil
    end
    self.effectList[passId] = self.mParent:addEffect(4020202, parent)
    self.effectList[passId].LocalPosition = Vector3(50,-150,200)
    self.effectList[passId].Scale = Vector3.New(37,37,37)
end

function TowerPanel:setPassEffect2(parent,passId)
    if self.downEffectList[passId] then
        self.mParent:removeUIEffect(self.downEffectList[passId])
        self.downEffectList[passId] = nil
    end
    self.downEffectList[passId] = self.mParent:addEffect(4020137, parent)
    self.downEffectList[passId].LocalPosition = Vector3(85,-25,0)
    -- self.downEffectList[passId].Scale = Vector3.New(40,40,40)
end
--进度条
function TowerPanel:setProgressBar(index,bar,lists)
    local lockList = {}
    for i=2,6 do
        local lockIcon = bar:GetChild("n"..i)
        local icon = lockIcon:GetChild("n1")
        table.insert(lockList, icon)
    end
    local panelList = {}
    for i=7,11 do
        local awardPanel = bar:GetChild("n"..i)
        table.insert(panelList, awardPanel)
    end
    bar.max = 100
    local saodangId = self.mData and self.mData.saodangMaxId or 0
    if saodangId == 0 and index == 0 then--第一页第一关
        bar.value = barValue[1]
    elseif saodangId == lists[1].id - 1 then--每一页的第一关
        bar.value = barValue[1]
    else
        bar.value = 0
    end
    local playLv = cache.PlayerCache:getRoleLevel()
    for k,v in pairs(lists) do
        local icon = lockList[k]
        local panel = panelList[k]
        local openlv = v.open_lv or 1
        if playLv < openlv then
            icon.url = UIItemRes.towerFuben01[1]
        else
            icon.url = UIItemRes.towerFuben01[3]
        end
        if saodangId >= v.id then
            bar.value = barValue[k + 1]
            icon.url = UIItemRes.towerFuben01[2]
        end
        local awards = v.first_pass_award
        local first = true
        if saodangId >= v.id then
            awards = v.normal_drop
            first = false
        end
        self:setAwardsData(panel,awards,first,v)
    end
end
--奖励
function TowerPanel:setAwardsData(panel,awards,first,value)
    local len = #awards
    for i=1,3 do
        local award = panel:GetChild("n"..i)
        if i == 1 then
            award.x = 7
        elseif i == 2 then
            award.x = 60
        elseif i == 3 then
            award.x = 112
        end
        if len == 1 then
            if i == 2 then
                local data = {mid = awards[1][1],amount = awards[1][2],bind = awards[1][3]}
                GSetItemData(award, data, true)
            else
                award.visible = false
            end
        elseif len == 2 then
            if i == 3 then
                award.visible = false
            else
                award.x = award.x + 25
                local data = {mid = awards[i][1],amount = awards[i][2],bind = awards[i][3]}
                GSetItemData(award, data, true)
            end
        else
            local data = {mid = awards[i][1],amount = awards[i][2],bind = awards[i][3]}
            GSetItemData(award, data, true)
        end 
    end
    local text = panel:GetChild("n4")
    if first then
        text.text = mgr.TextMgr:getTextColorStr(language.fuben15, 3)
    else
        text.text = mgr.TextMgr:getTextColorStr(language.fuben16, 0)
    end
    local text2 = panel:GetChild("n5")
    text2.text = mgr.TextMgr:getTextColorStr(language.fuben46..GTransFormNum(value.power), 19)
    if self.mData.currId >= value.id then--已通关
        text2.text = mgr.TextMgr:getTextColorStr(language.fuben47, 19)
    end
end

function TowerPanel:gotoScrollView()
    local fubenIndex = 1
    for k,passList in pairs(self.confPassTower) do--跳转到最后已通关关卡
        for _,v in pairs(passList) do
            if tonumber(self.mData.currId)== v.id then
                fubenIndex = k
                break
            end
        end
    end
    self.listView:ScrollToView(fubenIndex - 1)
end
--进入副本
function TowerPanel:onClickWar()
    if self.mParent.isGuide then
        cache.GuideCache:setGuide(self.mParent.isGuide)
    end
    local passId = self.mData and self.mData.currId or 0
    local id = self.lastData.id
    if passId < id then
        mgr.FubenMgr:gotoFubenWar(self.sceneId)
    else
        GComAlter(language.fuben43)
    end
end

function TowerPanel:onClickSweep()
    local passId = self.mData.currId
    local saodangId = self.mData and self.mData.saodangMaxId or 0
    if passId < saodangId and saodangId > 0 then
        proxy.FubenProxy:send(1024302)
    else
        GComAlter(language.fuben37)
    end
end
--规则
function TowerPanel:onClickRule()
    GOpenRuleView(1025)
end

--爬塔商店
function TowerPanel:onClickShop()
    mgr.ViewMgr:closeAllView2()
    GOpenView({id = 1081})
end

function TowerPanel:onClickLeft()
    local index = self.listView.scrollPane.currentPageX - 1
    if self.listView.scrollPane.currentPageX == 0 then
        GComAlter(language.fuben75)
    end
    if index <= 0 then
        index = 0
    end
    self.listView:ScrollToView(index,true)
end

function TowerPanel:onClickRight()
    local index = self.listView.scrollPane.currentPageX + 1
    local len = #self.confPassTower - 1
    if self.listView.scrollPane.currentPageX == len then
        GComAlter(language.fuben76)
    end
    if index >= len then
        index = len
    end
    self.listView:ScrollToView(index,true)
end

function TowerPanel:clear()
    self.listView.numItems = 0
end

function TowerPanel:destory()
    if g_var.gameFrameworkVersion >= 2 then
        UnityResMgr:ForceDelAssetBundle(UIItemRes.towerFuben02)
    end
end

return TowerPanel