--
-- Author: ohf
-- Date: 2017-03-06 20:31:26
--
--铜钱副本
local CopperPanel = class("CopperPanel",import("game.base.Ref"))

function CopperPanel:ctor(mParent)
    self.mParent = mParent
    self.imgPath = nil
    self:initPanel()
end

function CopperPanel:initPanel()
    self.count = 0--今日剩余挑战次数
    self.sceneId = Fuben.copper
    local panelObj = self.mParent:getChoosePanelObj(1021)
    local warBtn = panelObj:GetChild("n4")
    self.warBtn = warBtn
    warBtn.onClick:Add(self.onClickWar,self)

    self.sweepBtn = panelObj:GetChild("n12")--经验扫荡
    self.sweepBtn.onClick:Add(self.onClickSweep,self)
    if g_ios_test then
        self.sweepBtn.visible = false
    else
        self.sweepBtn.visible = true
    end
    
    self.bgImg = panelObj:GetChild("n2")
    --self.bgImg.url = UIItemRes.copperFuben01
    self.countDesc = panelObj:GetChild("n7")--剩余次数描述
    self.warDesc = panelObj:GetChild("n8")--几点后可以挑战

    local desc = panelObj:GetChild("n6")--几点后重置副本
    desc.text = language.fuben23..mgr.TextMgr:getTextColorStr(language.fuben06, 14)..language.fuben24
    self.moneyProfit = panelObj:GetChild("n5")--预计收益
    
    self.model = panelObj:GetChild("n11")--摇钱树模型
    local ruleBtn = panelObj:GetChild("n9")
    ruleBtn.onClick:Add(self.onClickRule,self)
    if g_ios_test then
        ruleBtn.visible = false
    else
        ruleBtn.visible = true
    end
end

function CopperPanel:updateBgImg()
    -- if self.imgPath then
    --     UnityResMgr:UnloadAssetBundle(self.imgPath, true)
    --     self.bgImg.url = ""
    -- end
    self.imgPath = UIItemRes.copperFuben01
    self.bgImg.url = self.imgPath
end

function CopperPanel:setData(data)
    if self.bgImg.url == "" then
        self:updateBgImg()
    end
    self.mData = data
    local sceneConfig = conf.SceneConf:getSceneById(self.sceneId)
    self.diffTime = sceneConfig.diff_time
    local maxCount = sceneConfig.max_over_count
    local todayCount = data and data.todayCount or 0
    local count = maxCount - todayCount
    self.count = count
    local str = language.fuben03..count

    if count <= 0 then
        self.warBtn.enabled = false
        self.sweepBtn.enabled = false
        self.warDesc.text = ""
        self.countDesc.text = language.fuben03..mgr.TextMgr:getTextColorStr(count, 14)
    else
        self.warBtn.enabled = true
        self.sweepBtn.enabled = true
        local lastTime = self.mData and self.mData.lastTime or 0
        local severTime = mgr.NetMgr:getServerTime()
        local time = severTime - lastTime--已经过了多少时间
        cache.FubenCache:setCopperLastTime(lastTime)
        self.isCd = false
        if time < self.diffTime then
            self.isCd = true
            local redNum = cache.PlayerCache:getRedPointById(attConst.A50103) or 0
            mgr.GuiMgr:redpointByID(attConst.A50103,redNum)
        end
        if not self.timer then
            self:onTimer()
            self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
        end
        self.countDesc.text = mgr.TextMgr:getTextColorStr(str, 8)
    end
    local currId = data.currId
    if currId <= 0 then
        currId = 1
    end
    local passData = conf.FubenConf:getPassData(self.sceneId,currId)
    self.moneyProfit.text = passData and passData.desc or ""
    self:refreshRed()
end

function CopperPanel:refreshRed()
    local redNum = cache.PlayerCache:getRedPointById(attConst.A50103) or 0
    local redVisile = false
    if redNum > 0 then
        redVisile = true
    end
    self.warBtn:GetChild("red").visible = redVisile
    local sweepRedVisile = false
    local saodangId = self.mData and self.mData.saodangId or 0
    if self.count > 0 and cache.PlayerCache:VipIsActivate(2) then--可以扫荡
        sweepRedVisile = true
    end
    self.sweepBtn:GetChild("red").visible = sweepRedVisile
end

function CopperPanel:clear()
    self.bgImg.url = ""
    self:releaseTimer()
end

function CopperPanel:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function CopperPanel:onTimer()
    local lastTime = self.mData and self.mData.lastTime or 0
    local severTime = mgr.NetMgr:getServerTime()
    local time = severTime - lastTime--已经过了多少时间
    if time >= self.diffTime then
        self:releaseTimer()
        self.warDesc.text = language.fuben05
        self.isCd = false
        return
    end
    self.isCd = true
    local curTime = self.diffTime - time--还剩多少时间
    self.warDesc.text = GTotimeString(curTime)..language.fuben04
end

--规则
function CopperPanel:onClickRule()
    GOpenRuleView(1022)
end

--
function CopperPanel:onClickWar()
    if self.isCd then
        GComAlter(language.gonggong30)
        return
    end
    if not self.warBtn.grayed then
        mgr.FubenMgr:gotoFubenWar(self.sceneId)
    end
end
--一键扫荡
function CopperPanel:onClickSweep()
    if not cache.PlayerCache:VipIsActivate(2) then--是否黄金仙尊
        local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(language.fuben103, 11),sure = function()
            GOpenView({id = 1050})
        end}
        GComAlter(param)
        return
    end
    if not self.mData then
        return
    end
    -- if self.isCd then
    --     GComAlter(language.gonggong30)
    --     return
    -- end
    if self.count <= 0 then
        GComAlter(language.fuben102)
        return
    end
    proxy.FubenProxy:send(1027106)
end

function CopperPanel:destory()
    if self.imgPath then
        UnityResMgr:UnloadAssetBundle(self.imgPath, true)
        self.bgImg.url = ""
    end
end

return CopperPanel