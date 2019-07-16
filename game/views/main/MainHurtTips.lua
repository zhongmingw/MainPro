--
-- Author: 
-- Date: 2017-06-16 21:28:38
--

local MainHurtTips = class("MainHurtTips", base.BaseView)

function MainHurtTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function MainHurtTips:initData(data)
    -- body
    self.target = data --目标
    self.name.text = data.roleName .. "\n"..language.gonggong63



end

function MainHurtTips:initView()
    local btn = self.view:GetChild("n1")
    btn.onClick:Add(self.addFight,self)

    self.name = self.view:GetChild("n2")
end

function MainHurtTips:setData(data_)

end

function MainHurtTips:addFight()
    -- body
    local myGangId = cache.PlayerCache:getGangId()
    -- print("目标仙盟",self.target.gangId,type(self.target.gangId))
    -- print("myGangId",myGangId,type(myGangId))

    local teamMembers = cache.TeamCache:getTeamMembers()
    local isSameTeam = false
    for k,v in pairs(teamMembers) do
        if v.roleId == self.target.roleId then
            isSameTeam = true
            break
        end
    end
    -- print("isSameTeam",isSameTeam)
    --仙盟id是64位字符串
    if (self.target.gangId == myGangId and myGangId ~= "0") or isSameTeam then
        --发动前一刻还是要判定玩家是否存在
        -- print("切换杀戮")
        if cache.PlayerCache:getPKState() ~= PKState.kill then
            proxy.PlayerProxy:send(1020106,{pkState = PKState.kill})
        end
    else
        -- print("切换仙盟")
        if cache.PlayerCache:getPKState() ~= PKState.team then
            proxy.PlayerProxy:send(1020106,{pkState = PKState.team})
        end
    end
    mgr.FightMgr:fightByTarget(self.target)

    self:closeView()
end



return MainHurtTips