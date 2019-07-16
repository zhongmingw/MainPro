--
-- Author: 
-- Date: 2018-01-30 15:52:32
--
--猜灯谜会
local ActiveCdmh = class("ActiveCdmh",import("game.base.Ref"))

function ActiveCdmh:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
    self.time = 0
    self.nextOpenTime = 0
end

function ActiveCdmh:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1211)
    panelObj:GetChild("n7").text = language.lantern01
    panelObj:GetChild("n8").text = language.lantern02
    self.timeDesc = panelObj:GetChild("n9")
    panelObj:GetChild("n10").text = language.lantern05
    self.bg = panelObj:GetChild("n16")
    self.timeText = panelObj:GetChild("n18")
    local warBtn = panelObj:GetChild("n19")
    self.warRed = warBtn:GetChild("red")
    warBtn.onClick:Add(self.onClickWar,self)

    local ruleBtn = panelObj:GetChild("n20")
    ruleBtn.onClick:Add(self.onClickRule,self)
    local awardYl = panelObj:GetChild("n21")
    awardYl.onClick:Add(self.onClickAwardYl,self)
end

function ActiveCdmh:setData(data)
    self.time = data and data.leftSec or self.time
    self.nextOpenTime = data and data.nextOpenTime or self.nextOpenTime
    if self.time <= 0 then
        self.warRed.visible = false
        mgr.GuiMgr:redpointByVar(attConst.A20166,0)
    else
        self.warRed.visible = true
        mgr.GuiMgr:redpointByVar(attConst.A20166,1)
    end
    self.timeDesc.text = self:getTime(data.actStartTime).."—"..self:getTime(data.actEndTime)
    if self.bg.url and self.bg.url ~= "" then
        return
    end
    self.imgPath = UIItemRes.activeIcons.."yuanxiaodenghui_002"
    self.mParent:setLoaderUrl(self.bg,self.imgPath)
end

function ActiveCdmh:onTimer()
    if self.time <= 0 then
        if self.warRed.visible then
            self.warRed.visible = false
            mgr.GuiMgr:redpointByVar(attConst.A20166,0)
        end
        local time = math.max(self.nextOpenTime - mgr.NetMgr:getServerTime(), 0)
        self.timeText.text = language.ydact015..mgr.TextMgr:getTextColorStr(GTotimeString(time), 4)
        if time <= 0 then
            proxy.ActivityWarProxy:send(1030179,{reqType = 1,cid = 0})
            return
        end
    else
        if not self.warRed.visible then
            self.warRed.visible = true
            mgr.GuiMgr:redpointByVar(attConst.A20166,1)
        end
        self.timeText.text = language.ydact05..mgr.TextMgr:getTextColorStr(GTotimeString(self.time), 4)
        self.time = self.time - 1
    end
end

function ActiveCdmh:onClickWar()
    if self.time <= 0 then
        GComAlter(language.acthall03)
        return
    end
    plog("LanternScene",LanternScene)
    mgr.FubenMgr:gotoFubenWar(LanternScene)
end

--帮助
function ActiveCdmh:onClickRule()
    GOpenRuleView(1081)
end

function ActiveCdmh:onClickAwardYl()
    mgr.ViewMgr:openView2(ViewName.LanternAwardsView)
end

function ActiveCdmh:getTime(time)
    local timeTab = os.date("*t",time)
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

function ActiveCdmh:clear()
    self.bg.url = ""
end

return ActiveCdmh