--
-- Author: Your Name
-- Date: 2018-01-18 16:29:27
--

local AwardsTipsView = class("AwardsTipsView", base.BaseView)

function AwardsTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function AwardsTipsView:initView()
    self:setCloseBtn(self.view)
    self.decTxt = self.view:GetChild("n3")
end

function AwardsTipsView:initData(data)
    local awards = data.awards
    local text = ""
    for k,v in pairs(awards) do
        local mid = v[1]
        local num = v[2]
        local name = conf.ItemConf:getName(mid)
        local color = conf.ItemConf:getQuality(mid)
        text = text .. "[color="..Quality1[color].."]"..name.."[/color]"
        text = text .. "[color="..TextColors[6].."]".."*".."[/color]"
        text = text .. "[color="..TextColors[7].."]"..num.."[/color]" .. "\n"
    end
    self.decTxt.text = text
end

return AwardsTipsView