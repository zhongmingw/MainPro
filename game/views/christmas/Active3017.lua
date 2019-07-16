--
-- Author: Your Name
-- Date: 2017-12-18 21:37:00
--圣诞活动击杀boss
local Active3017 = class("Active3017",import("game.base.Ref"))

function Active3017:ctor(param)
    self.view = param
    self:initView()
end

function Active3017:initView()
    -- body
    self.actTimeTxt = self.view:GetChild("n3")
    self.decTxt = self.view:GetChild("n4")
end

function Active3017:onTimer()
    -- body
end

function Active3017:setCurId(id)
    -- body
    
end


function Active3017:add5030164(data)
    -- body
    -- printt("击杀boss",data)
    self.data = data
    local startTab = os.date("*t",data.actStartTime)
    local endTab = os.date("*t",data.actEndTime)
    local startTxt = startTab.month .. language.gonggong79 .. startTab.day .. language.gonggong80 .. string.format("%02d",startTab.hour) .. ":" .. string.format("%02d",startTab.min)
    local endTxt = endTab.month .. language.gonggong79 .. endTab.day .. language.gonggong80 .. string.format("%02d",endTab.hour) .. ":" .. string.format("%02d",endTab.min)
    self.actTimeTxt.text = startTxt .. "-" .. endTxt
    self.decTxt.text = language.active45
    local gotoBtn = self.view:GetChild("n7")
    gotoBtn.onClick:Add(self.onClickGoTo,self)
end

function Active3017:onClickGoTo()
    GOpenView({id = 1049})
end

return Active3017