--
-- Author: ohf
-- Date: 2017-03-30 15:05:49
--
--练级谷
local LevelPanel = class("LevelPanel",import("game.base.Ref"))

function LevelPanel:ctor(mParent)
    self.mParent = mParent
    self.imgPath = nil
    self.leftTime = 0
    self:initPanel()
end

function LevelPanel:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1025)
    local btn = panelObj:GetChild("n4")
    self.btn = btn
    btn.onClick:Add(self.onClickWar,self)

    local ruleBtn = panelObj:GetChild("n9")
    ruleBtn.onClick:Add(self.onClickRule,self)
    if g_ios_test then
        ruleBtn.visible = false
    else
        ruleBtn.visible = true
    end

    self.fontImg1 = panelObj:GetChild("n15")
    self.fontImg2 = panelObj:GetChild("n16")

    panelObj:GetChild("n17").touchable = false
    panelObj:GetChild("n18").touchable = false
    self.incomeText = panelObj:GetChild("n19")--本日收益
    self.lvDesc1 = panelObj:GetChild("n20")
    self.lvDesc2 = panelObj:GetChild("n22")
    
    self.timeText = panelObj:GetChild("n23")--倒计时
    self.timeText.text = ""

    self.listView1 = panelObj:GetChild("n25")--掉落预览
    self.listView1:SetVirtual()
    self.listView1.itemRenderer = function(index,obj)
        self:cellDropData(index, obj)
    end

    self.listView2 = panelObj:GetChild("n26")
    self.listView2:SetVirtual()
    self.listView2.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end

    local buyTimeBtn = panelObj:GetChild("n27")
    buyTimeBtn.onClick:Add(self.onClickBuyTime,self)
    self.bgImg = panelObj:GetChild("n2")
    --self.bgImg.url = UIItemRes.levelFuben01
    self.sweepBtn = panelObj:GetChild("n28")
    self.sweepBtn.onClick:Add(self.onClickSweep,self)
    if g_ios_test then
        self.sweepBtn.visible = false
    else
        self.sweepBtn.visible = true
    end
end

function LevelPanel:updateBgImg()
    -- if self.imgPath then
    --     UnityResMgr:UnloadAssetBundle(self.imgPath, true)
    --     self.bgImg.url = ""
    -- end
    self.imgPath = UIItemRes.levelFuben01
    self.bgImg.url = self.imgPath
end

function LevelPanel:setData(data)
    if self.bgImg.url == "" then
        --self.bgImg.url = UIItemRes.levelFuben01
        self:updateBgImg()
    end
    self.sceneId = data and data.sceneId or 0
    self.leftTime = data and data.leftTime or 0--剩余挑战时间(秒数)
    local playerlv = cache.PlayerCache:getRoleLevel()
    self.lvDesc1.text = string.format(language.fuben48, playerlv)
    local sceneData = conf.SceneConf:getSceneById(self.sceneId)
    local str = sceneData and sceneData.name or ""
    self.lvDesc2.text = language.gonggong35..str..language.gonggong36
    self.timeText.text = GTotimeString2(self.leftTime)
    local sceneData = conf.SceneConf:getSceneById(self.sceneId)
    self.dropData = sceneData and sceneData.normal_drop or {}
    self.listView1.numItems = #self.dropData
    local incomeMap = data and data.incomeMap or {}
    self.awards = GGetLevelAwards(incomeMap)--本日收益
    local incomeNum = #self.awards
    if incomeNum <= 0 then
        self.fontImg2.visible = true
        self.listView2.visible = false
    else
        self.fontImg2.visible = false
        self.listView2.visible = true
        self.listView2.numItems = incomeNum
    end
    local visible = false
    local sweepVisible = false
    if self.leftTime > 0 then
        visible = true
        sweepVisible = cache.PlayerCache:VipIsActivate(3)
    end
    self.btn:GetChild("red").visible = visible
    self.sweepBtn:GetChild("red").visible = sweepVisible
    self.sweepCost = data.cost or 0--扫荡消耗元宝
    if visible == false and sweepVisible == false then
        local redNum = cache.PlayerCache:getRedPointById(attConst.A10316)
        mgr.GuiMgr:redpointByID(attConst.A10316,redNum)
    end
end

--掉落预览
function LevelPanel:cellDropData(index,obj)
    local data = self.dropData[index + 1]
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj, itemData, true)
end

--本日收益预览
function LevelPanel:cellAwardsData(index,obj)
    local data = self.awards[index + 1]

    if data.amount > 100000 then  --EVE 特殊处理：练级谷预览面板不显示小数，只取整
        data.amount = math.round(data.amount/(100000/10))*10000  
    end 

    local itemData = {mid = data.mid,amount = data.amount,bind = data.bind}
    GSetItemData(obj, itemData, true)
end

function LevelPanel:onClickWar()
    mgr.FubenMgr:gotoFubenWar(self.sceneId)
end

--一键扫荡
function LevelPanel:onClickSweep()
    if not cache.PlayerCache:VipIsActivate(3) then--是否钻石仙尊
        local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(language.fuben105, 11),sure = function()
            GOpenView({id = 1050})
        end}
        GComAlter(param)
        return
    end
    if self.leftTime <= 0 then
        GComAlter(language.fuben107)
        return
    end
    if not self.sweepCost or self.sweepCost <= 0 then
        return
    end
    mgr.ViewMgr:openView2(ViewName.LevelSweepView, {leftTime = self.leftTime,cost = self.sweepCost})
end

function LevelPanel:onClickRule()
    GOpenRuleView(1029)
end

function LevelPanel:onClickBuyTime()
    if cache.PlayerCache:VipIsActivate(1) then
        mgr.ViewMgr:openView(ViewName.LevelTipView, function(view)
            view:setData(1)
        end)
    else
        GComAlter(language.vip22)
    end
end

function LevelPanel:clear()
    self.bgImg.url = ""
    self.sweepCost = 0
end

function LevelPanel:destory()
    if self.imgPath then
        self.bgImg.url = ""
        UnityResMgr:UnloadAssetBundle(self.imgPath, true)
    end
end

return LevelPanel