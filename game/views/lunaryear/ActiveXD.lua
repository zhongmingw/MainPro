--
-- Author: EVE 
-- Date: 2018-01-24 16:27:32
-- 小年登录

local ActiveXD = class("ActiveXD",import("game.base.Ref"))

function ActiveXD:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ActiveXD:initPanel()
    local panelObj = self.mParent:getPanelObj(1058)
    
    --时间和内容
    local actDuration = conf.ActivityWarConf:getSnowGlobal("act_duration")
    panelObj:GetChild("n9").text = self:getTime(actDuration[1]).."—"..self:getTime(actDuration[2])
    panelObj:GetChild("n10").text = language.lunaryear05

    --背景图
    self.bg = panelObj:GetChild("n16")

    --结算倒计时显示
    self.timeText = panelObj:GetChild("n18")

    --开始作战按钮
    local warBtn = panelObj:GetChild("n19")
    self.warRed = warBtn:GetChild("red")
    warBtn.onClick:Add(self.onClickWar,self)

    --规则
    local ruleBtn = panelObj:GetChild("n20")
    ruleBtn.onClick:Add(self.onClickRule,self)
end

function ActiveXD:getTime(time)
    local timeTab = os.date("*t",time)
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

function ActiveXD:setData(data)
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

function ActiveXD:onTimer()
    if not self.time then return end
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

function ActiveXD:onClickWar()
    if self.time <= 0 then
        GComAlter(language.acthall03)
        return
    end
    mgr.FubenMgr:gotoFubenWar(XdzzScene)
end

--帮助
function ActiveXD:onClickRule()
    GOpenRuleView(1073)
end


function ActiveXD:clear()
    self.bg.url = ""
end

return ActiveXD