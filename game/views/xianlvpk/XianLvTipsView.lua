--
-- Author: 
-- Date: 2018-08-09 17:33:47
--

local XianLvTipsView = class("XianLvTipsView", base.BaseView)

function XianLvTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function XianLvTipsView:initView()
    local closeBtn = self.view:GetChild("n4")
    self:setCloseBtn(closeBtn)
    local titleText = self.view:GetChild("n9")
    titleText.text = language.xianlv38
    -- self.icon = self.view:GetChild("n11")
    self.timeText = self.view:GetChild("n12")
    self.descText = self.view:GetChild("n7")
    local goBtn = self.view:GetChild("n3")
    goBtn.onClick:Add(self.onClickGoBtn,self)
end


function XianLvTipsView:initData(data_8230506)
    self.data = data_8230506
    local reqType = data_8230506.reqType

    local t = clone(language.xianlv36)
    t[2].text = string.format(t[2].text,language.xianlv37[reqType])
    self.descText.text = mgr.TextMgr:getTextByTable(t)
    if reqType == 1 then
        self.timeText.text = ""
    else
        local nowTime = mgr.NetMgr:getServerTime()
        self.time = data_8230506.nextStartTime - nowTime
        if not self.tipTimer then
            self:onTiemr()
            self.tipTimer = self:addTimer(1, -1, handler(self, self.onTiemr))
        end
    end

end

function XianLvTipsView:releaseTimer()
    if self.tipTimer then
        self:removeTimer(self.tipTimer)
        self.tipTimer = nil
    end
end

function XianLvTipsView:onTiemr()
    self.timeText.text = GTotimeString(self.time)
    if self.time <= 0 then
        self:releaseTimer()
        self.time = 0
        return
    end
    self.time = self.time - 1
end

function XianLvTipsView:onClickGoBtn()
    local id = self.data.actId == 5010 and 1351 or 1280
    GOpenView({id = id})
    self:closeView()
end

function XianLvTipsView:setData(data_)

end

return XianLvTipsView