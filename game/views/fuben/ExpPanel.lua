--
-- Author: ohf
-- Date: 2017-03-06 20:31:06
--
--经验副本
local ExpPanel = class("ExpPanel",import("game.base.Ref"))

local defineNum = 1000
local levelNum = FuebenLevelNum.exp--每一个章节的关卡

function ExpPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ExpPanel:initPanel()
    self.confPassExps,self.lastData = conf.FubenConf:getPassExp()
    self.sceneId = Fuben.exp
    self.scenePex = self.sceneId * defineNum
    local panelObj = self.mParent:getChoosePanelObj(1023)
    self.listView = panelObj:GetChild("n1")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    self.listView.scrollPane.onScrollEnd:Add(self.onListScrollPage, self)

    self.panelBar = panelObj:GetChild("n5")

    self.awardsList = panelObj:GetChild("n22")
    self.awardsList:SetVirtual()
    self.awardsList.itemRenderer = function(index, obj)
        self:cellAwardsData(index, obj)
    end
    self.awardsList.scrollPane.onScrollEnd:Add(self.onAwardScrollPage, self)

    -- local fubenBtn = panelObj:GetChild("n11")--进入
    -- self.fubenBtn = fubenBtn
    -- fubenBtn.onClick:Add(self.onClickWar,self)
    -- self.fubenText = panelObj:GetChild("n24")

    --EVE 经验本 [继续] 按钮优化（优化对象：n11、n23、n24）
    local btnContinue =panelObj:GetChild("n28")
    self.btnContinue = btnContinue
    btnContinue.onClick:Add(self.onClickWar,self)
    --EVE END
    self.warRed = btnContinue:GetChild("red")

    local sweepBtn = panelObj:GetChild("n10")--一键扫荡
    self.sweepBtn = sweepBtn
    sweepBtn.onClick:Add(self.onClickSweep,self)
    if g_ios_test then
        sweepBtn.visible = false
    else
        sweepBtn.visible = true
    end
    
    self.sweepText = panelObj:GetChild("n25")
    self.sweepText.text = ""
    
    local desc = panelObj:GetChild("n14")
    desc.text = language.fuben23..mgr.TextMgr:getTextColorStr(language.fuben06, 14)..language.fuben24

    local ruleBtn = panelObj:GetChild("n13")--规则按钮
    ruleBtn.onClick:Add(self.onClickRule,self)
    if g_ios_test then
        ruleBtn.visible = false
    else
        ruleBtn.visible = true
    end
    local leftBtn1 = panelObj:GetChild("n2")
    leftBtn1.onClick:Add(self.onClickLeft1,self)
    local rightBtn1 = panelObj:GetChild("n3")
    rightBtn1.onClick:Add(self.onClickRight1,self)
    local leftBtn2 = panelObj:GetChild("n9")
    leftBtn2.onClick:Add(self.onClickLeft2,self)
    local rightBtn2 = panelObj:GetChild("n8")
    rightBtn2.onClick:Add(self.onClickRight2,self)
end

--领取首通奖励
function ExpPanel:setFirstData(data)
    local pass = data.passId - self.scenePex
    if self.mData.firstPassAwardMap then
        self.mData.firstPassAwardMap[pass] = 2
    end
    self:setData(self.mData,true)
end

function ExpPanel:setData(data,isRef)
    self.mData = data
    local currId = self.mData and self.mData.currId or 0
    self.currId = currId
    local pass = currId + 1
    local sceneConfig = conf.SceneConf:getSceneById(self.sceneId)
    if pass > sceneConfig.max_pass then
        -- self.fubenText.text = currId
        self.btnContinue.title = currId     --EVE 显示波次优化  优化对象：n24
        -- self.fubenBtn.enabled = false
        self.btnContinue.enabled = false  --EVE 优化对象：n23
    else
        -- self.fubenText.text = pass
        self.btnContinue.title = pass      --EVE 显示波次优化  优化对象：n24
        -- self.fubenBtn.enabled = true
        self.btnContinue.enabled = true  --EVE 优化对象：n23
    end
    if cache.PlayerCache:getRedPointById(attConst.A50105) > 0 then
        self.warRed.visible = true
    else
        self.warRed.visible = false
    end
    -- cache.FubenCache:setCurrPass(self.sceneId,self.scenePex + pass)
    local len = #self.confPassExps
    if not isRef then
        self.fubenIndex,self.awardsIndex = self:getFubenIndex()
    end
    self.listView.numItems = len
    self.awardsList.numItems = len
    self.listView:ScrollToView(self.fubenIndex - 1)
    self.awardsList:ScrollToView(self.awardsIndex - 1)
    --当前可扫荡的关卡
    local passId = currId + self.scenePex
    if self.currId == 0 then
        passId = self.scenePex
    end
    local saodangId = self.mData and self.mData.saodangId or 0
    
    if saodangId - passId > 0 then
        local saodangPass = tonumber(string.sub(saodangId,7,9))
        self.sweepText.text = mgr.TextMgr:getTextColorStr(language.fuben44, 8)..mgr.TextMgr:getTextColorStr(string.format(language.bangpai127, saodangPass), 7)
        self.sweepBtn:GetChild("red").visible = true
    else
        self.sweepText.text = ""
        self.sweepBtn:GetChild("red").visible = false
    end
end
--副本加载
function ExpPanel:cellData(index, cell)
    local passList = self.confPassExps[index + 1]
    local scenePex = self.scenePex
    local data1 = passList[1]
    local pass = data1.id - scenePex--第一关
    local data2 = passList[levelNum]
    local bosPass = data2.id - scenePex--boss关
    cell.data = index + 1
    local iconImg = cell:GetChild("n0")
    iconImg.url = ""
    iconImg.url = UIItemRes.fuebenImg..data2.view_icon
    local arleayImg = cell:GetChild("n3")--是否已通关
    local adoptText1 = cell:GetChild("n4")--已通关显示关卡的字段
    adoptText1.text = pass
    local adoptText2 = cell:GetChild("n5")
    adoptText2.text = bosPass
    local unadoptText1 = cell:GetChild("n6")--未通关时候显示关卡的字段
    unadoptText1.text = pass
    local unadoptText2 = cell:GetChild("n7")
    unadoptText2.text = bosPass

    adoptText1.visible = false
    adoptText2.visible = false
    unadoptText1.visible = false
    unadoptText2.visible = false
    if self.currId >= bosPass then
        iconImg.grayed = true
        arleayImg.grayed = false
        arleayImg.visible = true
        adoptText1.visible = true
        adoptText2.visible = true
    else
        iconImg.grayed = false
        arleayImg.visible = false
        unadoptText1.visible = true
        unadoptText2.visible = true
    end
end
--奖励加载
function ExpPanel:cellAwardsData(index, cell)
    local passList = self.confPassExps[index + 1]
    local scenePex = self.scenePex
    local max = #passList
    local data = passList[max]
    local awards = data.first_pass_award
    local pass = data.id - scenePex
    local red = cell:GetChild("n4")
    cell.max = 100
    local first = self.mData.firstPassAwardMap and self.mData.firstPassAwardMap[pass]
    local grayed = false
    local isGet = false
    local func = nil
    red.visible = false
    if first then
        if first == 2 then--已领取
            isGet = true
            grayed = true
        elseif first == 1 then--可领取
            red.visible = true
            func = function()
                proxy.FubenProxy:send(1024102,{passId = data.id})
            end
        end
    end
    local saodangId = self.mData and self.mData.saodangId or 0
    if data.id <= saodangId then 
        cell.value = cell.max
    else
        cell.value = 0
    end
    local itemObj = cell:GetChild("n2")
    local itemData = {mid = awards[1][1],amount = awards[1][2],bind = awards[1][3],isGet = isGet,grayed = grayed,func = func}
    GSetItemData(itemObj, itemData, true)
    local text = cell:GetChild("n3")
    cell.data = index + 1
    text.text = string.format(language.fuben07, pass)
end

function ExpPanel:getFubenIndex()
    local fubenIndex = 1
    local awardsIndex = 1
    for k,passList in pairs(self.confPassExps) do--跳转到最后已通关关卡
        for _,v in pairs(passList) do
            local data = passList[levelNum]
            local bosPass = data.id - self.scenePex--boss关
            local first = self.mData.firstPassAwardMap and self.mData.firstPassAwardMap[bosPass]
            if first and first == 2 then
                awardsIndex = k
            end
            if self.currId == bosPass then
                fubenIndex = k
            end
        end
    end
    return fubenIndex,awardsIndex
end

--点击副本
function ExpPanel:onClickItem(context)
    local cell = context.data
    local data = cell.data
end
--进入副本
function ExpPanel:onClickWar()
    -- plog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    --记录是否在
    if self.mParent.isGuide  then
        cache.GuideCache:setGuide(self.mParent.isGuide)
    end
    if not self.currId then return end
    local passId = self.currId + self.scenePex
    local id = self.lastData.id
    if passId < id then
        mgr.FubenMgr:gotoFubenWar(self.sceneId)
    else
        GComAlter(language.fuben43)
    end
end

function ExpPanel:onClickSweep()
    local passId = self.currId + self.scenePex
    local saodangId = self.mData and self.mData.saodangId or 0
    if passId < saodangId and saodangId > 0 then
        -- if self.currId <= 0 then
        --     passId = self.scenePex
        -- end
        -- local money = math.ceil((saodangId - passId) / 10) *conf.FubenConf:getValue("jingyan_saodang_cost")
        -- local text = string.format(language.fuben38, money)
        -- local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(text, 11),sure = function()
        --     local bmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
        --     local tmoney = cache.PlayerCache:getTypeMoney(MoneyType.copper) or 0--拥有的金钱
        --     if tmoney >= money  or bmoney >= money then
        --         proxy.FubenProxy:send(1024104)
        --     else
        --         GComAlter(language.gonggong29)
        --     end
        -- end}
        -- GComAlter(param)
        proxy.FubenProxy:send(1024104)
    else
        GComAlter(language.fuben37)
    end
end

function ExpPanel:onClickLeft1()
    self.fubenIndex = self.fubenIndex - 2
    if self.fubenIndex <= 0 then
        self.fubenIndex = 0
        GComAlter(language.fuben75)
    end
    self.listView:ScrollToView(self.fubenIndex,true)
end

function ExpPanel:onClickRight1()
    local len = #self.confPassExps - 1
    self.fubenIndex = self.fubenIndex + 2
    if self.fubenIndex >= len then
        self.fubenIndex = len
        GComAlter(language.fuben76)
    end
    self.listView:ScrollToView(self.fubenIndex,true)
end

function ExpPanel:onClickLeft2()
    self.awardsIndex = self.awardsIndex - 3
    if self.awardsIndex <= 0 then
        self.awardsIndex = 0
        GComAlter(language.fuben75)
    end
    self.awardsList:ScrollToView(self.awardsIndex,true)
end

function ExpPanel:onClickRight2()
    local len = #self.confPassExps - 1
    self.awardsIndex = self.awardsIndex + 3
    if self.awardsIndex >= len then
        self.awardsIndex = len
        GComAlter(language.fuben76)
    end
    self.awardsList:ScrollToView(self.awardsIndex,true)
end

function ExpPanel:onListScrollPage()
    if self.listView.numItems > 0 then
        local cell = self.listView:GetChildAt(0)
        self.fubenIndex = cell.data
    end
end

function ExpPanel:onAwardScrollPage()
    if self.awardsList.numItems > 0 then
        local cell = self.awardsList:GetChildAt(0)
        self.awardsIndex = cell.data
    end
end
--规则
function ExpPanel:onClickRule()
    GOpenRuleView(1024)
end

function ExpPanel:clear()
    self.listView.numItems = 0
end

return ExpPanel