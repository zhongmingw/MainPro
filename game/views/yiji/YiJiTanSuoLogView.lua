--
-- Author: Your Name
-- Date: 2018-12-19 14:20:45
--

local YiJiTanSuoLogView = class("YiJiTanSuoLogView", base.BaseView)

function YiJiTanSuoLogView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function YiJiTanSuoLogView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.logTxt = self.view:GetChild("n2"):GetChild("n0")
end

function YiJiTanSuoLogView:initData()
    local logTab = cache.YiJiTanSuoCache:getTanSuoLogs()
    local str = ""
    if #logTab > 0 then
        for i=1,#logTab do
            local strTab = string.split(logTab[i],"|")
            local timeStr = strTab[1]
            local logs = strTab[2]
            str = str .. "[color=#0B8109]" .. GToTimeString14(timeStr) .. "[/color]" .. "  " .. logs .. "\n"
        end
    end
    self.logTxt.text = str
end

return YiJiTanSuoLogView