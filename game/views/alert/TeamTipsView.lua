--
-- Author: EVE
-- Date: 2017-08-08 20:59:21
--

local TeamTipsView = class("TeamTipsView", base.BaseView)

function TeamTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function TeamTipsView:initView()
    self.btnClose = self.view:GetChild("n0"):GetChild("n2")
    self.btnClose.onClick:Add(self.onCloseView,self)

    self.confPlus = conf.SysConf:getPlus() 

    self.textShow = self.view:GetChild("n1") 
    self.textShow.text = ""
end

function TeamTipsView:initData()
    self:refreshView()
end

function TeamTipsView:refreshView()
    -- plog("你是猪！")
    local teamSize = cache.TeamCache:getTeamMemberNum() --获取队伍人数
    -- plog("~~~~~~~~~~",teamSize)
    -- printt(self.confPlus)

    local twoReward = string.format(
        language.team28,
        language.team29[2],
        self.confPlus[2]) 

    local maxReward = string.format(
        language.team28,
        language.team29[3],
        self.confPlus[3]) 

    if teamSize ~= 0 then
        -- print("AAAAAAAAAAAAAAAAAAAAAAAAA")
        self.textShow.text = string.format(language.team28,
            language.team29[1],
            self.confPlus[teamSize]) .. "\n" .. twoReward .. "\n" ..maxReward
    else
        -- print("BBBBBBBBBBBBBBBBBBBBBBBBBB")
        self.textShow.text = string.format(language.team28,
            language.team29[1],
            self.confPlus[1]) .. "\n" .. twoReward .. "\n" .. maxReward
    end
end

function TeamTipsView:onCloseView()
    self:closeView()
end

return TeamTipsView