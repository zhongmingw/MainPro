--
-- Author: 
-- Date: 2018-10-22 15:13:55
--

local AlertWSJView = class("AlertWSJView", base.BaseView)

function AlertWSJView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function AlertWSJView:initView()
    self:setCloseBtn(self.view:GetChild("n14"))
    self.view:GetChild("n9").text = language.wsj05
    local openTime = conf.WSJConf:getValue("open_time")
    local actTime = conf.WSJConf:getValue("wsj_act_time")
    local confData = conf.WSJConf:getWSJFloorAward()

    local t = clone(language.wsj06)
    t[2].text = string.format(t[2].text,GTotimeString10(openTime[1]),GTotimeString10(openTime[1]+actTime),GTotimeString10(openTime[2]),GTotimeString10(openTime[2]+actTime))
    t[4].text = string.format(t[4].text,#confData)

    self.view:GetChild("n10").text = mgr.TextMgr:getTextByTable(t)

    local goFubenBtn = self.view:GetChild("n11")
    goFubenBtn:GetChild("red").visible = false
    goFubenBtn.onClick:Add(self.goFuben,self)
end

function AlertWSJView:goFuben()
    mgr.FubenMgr:gotoFubenWar(WJSScene)
end

function AlertWSJView:setData(data_)

end

return AlertWSJView