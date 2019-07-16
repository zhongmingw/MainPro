--
-- Author: 
-- Date: 2017-12-26 11:10:17
--
--雪地大作战
local ActiveXdzz = class("ActiveXdzz",import("game.base.Ref"))

function ActiveXdzz:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
    self.time = 0
    self.nextStartTime = 0
end

function ActiveXdzz:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1166)
    panelObj:GetChild("n7").text = language.ydact01
    panelObj:GetChild("n8").text = language.ydact02
    local actDuration = conf.ActivityWarConf:getSnowGlobal("act_duration")
    panelObj:GetChild("n9").text = self:getTime(actDuration[1]).."-"..self:getTime(actDuration[2])
    panelObj:GetChild("n10").text = language.ydact04
    self.bg = panelObj:GetChild("n16")
    self.timeText = panelObj:GetChild("n18")
    local warBtn = panelObj:GetChild("n19")
    self.warRed = warBtn:GetChild("red")
    warBtn.onClick:Add(self.onClickWar,self)

    local ruleBtn = panelObj:GetChild("n20")
    ruleBtn.onClick:Add(self.onClickRule,self)
end

function ActiveXdzz:getTime(time)
    local timeTab = os.date("*t",time)
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

function ActiveXdzz:setData(data)
    self.time = data and data.leftSec or self.time
    self.nextStartTime = data and data.nextStartTime or self.nextStartTime
    if self.time <= 0 then
        self.warRed.visible = false
        mgr.GuiMgr:redpointByVar(attConst.A50120,0)
    else
        self.warRed.visible = true
        mgr.GuiMgr:redpointByVar(attConst.A50120,1)
    end
    if self.bg.url and self.bg.url ~= "" then
        return
    end
    self.imgPath = UIItemRes.activeIcons.."yuandankuaile_002"
    self.mParent:setLoaderUrl(self.bg,self.imgPath)
end

function ActiveXdzz:onTimer()
    if self.time <= 0 then
        if self.warRed.visible then
            self.warRed.visible = false
            mgr.GuiMgr:redpointByVar(attConst.A50120,0)
        end
        local time = math.max(self.nextStartTime - mgr.NetMgr:getServerTime(), 0)
        self.timeText.text = language.ydact015..mgr.TextMgr:getTextColorStr(GTotimeString(time), 4)
        if time <= 0 then
            proxy.ActivityProxy:send(1470101)
            return
        end
    else
        if not self.warRed.visible then
            self.warRed.visible = true
            mgr.GuiMgr:redpointByVar(attConst.A50120,1)
        end
        self.timeText.text = language.ydact05..mgr.TextMgr:getTextColorStr(GTotimeString(self.time), 4)
        self.time = self.time - 1
    end
end

function ActiveXdzz:onClickWar()
    if self.time <= 0 then
        GComAlter(language.acthall03)
        return
    end
    mgr.FubenMgr:gotoFubenWar(XdzzScene)
end

--帮助
function ActiveXdzz:onClickRule()
    GOpenRuleView(1073)
end


function ActiveXdzz:clear()
    self.bg.url = ""
end

return ActiveXdzz