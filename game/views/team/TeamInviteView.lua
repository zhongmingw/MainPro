--
-- Author: 
-- Date: 2017-10-25 17:03:20
--

local TeamInviteView = class("TeamInviteView", base.BaseView)

local Time = 10

function TeamInviteView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function TeamInviteView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onClickRefuse,self)
    self.richText = self.view:GetChild("n2")

    self.timeTxt = self.view:GetChild("n3")
    local refuseBtn = self.view:GetChild("n4")
    refuseBtn.onClick:Add(self.onClickRefuse,self)
    local agreeBtn = self.view:GetChild("n5")
    agreeBtn.onClick:Add(self.onClickAgree,self)

    self.desc = self.view:GetChild("n6")
end

function TeamInviteView:initData(data)
    self.roleId = data.roleId
    local str = clone(language.team32)
    str[1].text = string.format(str[1].text, data.roleName)
    -- local redNum = 0
    -- redNum = cache.PlayerCache:getRedPointById(attConst.A50116) or 0
    local confData = conf.TeamConf:getTeamConfig(data.targetId)
    local sss = confData and confData.name or "无"
    str[2].text = string.format(str[2].text, sss) 
    self.desc.visible = false
    -- if redNum <= 0 then
    --     self.desc.visible = true
    --     self.desc.text = language.team41
    -- end
    self.richText.text = mgr.TextMgr:getTextByTable(str)
    self.time = Time
    self:onTimer()
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
end

function TeamInviteView:onTimer()
    if self.time <= 0 then
        cache.TeamCache:clearInvitation(0,true)
        self:removeTimer(self.timer)
        self:onClickRefuse()
        return
    end
    self.timeTxt.text = string.format(language.team17, self.time)
    self.time = self.time - 1
end

--拒绝
function TeamInviteView:onClickRefuse()
    proxy.TeamProxy:send(1300106,{tarRoleId = self.roleId,reqType = 2})
    self:closeView()
end
--同意
function TeamInviteView:onClickAgree()
    proxy.TeamProxy:send(1300106,{tarRoleId = self.roleId,reqType = 1})
    self:closeView()
end

return TeamInviteView