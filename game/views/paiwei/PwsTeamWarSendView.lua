--
-- Author: Your Name
-- Date: 2018-01-16 19:48:04
--

local PwsTeamWarSendView = class("PwsTeamWarSendView", base.BaseView)

function PwsTeamWarSendView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function PwsTeamWarSendView:initView()
    self.refuseBtn = self.view:GetChild("n12")
    self.refuseBtn.onClick:Add(self.onClickRefuse,self)
    self.agreeBtn = self.view:GetChild("n13")
    self.agreeBtn.onClick:Add(self.onClickAgree,self)
    self.roleList = {}
    for i=1,3 do
        table.insert(self.roleList,self.view:GetChild("n"..(5+1)))
    end
    self.bar = self.view:GetChild("n11")
    self.roleItems = {}
    for i=6,8 do
        local role = self.view:GetChild("n"..i)
        table.insert(self.roleItems, role)
    end
end

function PwsTeamWarSendView:initData(data)
    self.lastTime = 10
    self.bar.value = self.lastTime
    self.bar.max = 10
    self.bar:GetChild("n2").text = self.lastTime
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil 
    end
    self.timer = self:addTimer(1, -1, handler(self, self.timeTick))
end

function PwsTeamWarSendView:timeTick()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.bar.value = self.lastTime
        self.bar:GetChild("n2").text = self.lastTime
    else
        self:closeView()
    end
end

function PwsTeamWarSendView:setData(data)
    self.data = data
    local members = data.members
    local zbNum = 0--记录准备人数
    local roleId = cache.PlayerCache:getRoleId()
    if roleId == self.data.captainRoleId then
        self.agreeBtn.grayed = true
        self.agreeBtn.touchable = false
    else
        self.agreeBtn.grayed = false
        self.agreeBtn.touchable = true
    end
    for k,v in pairs(self.roleItems) do
        local icon = v:GetChild("n9"):GetChild("n0")
        local name = v:GetChild("n3")
        local captain = v:GetChild("n6")
        local zbIcon = v:GetChild("n7")
        local powerText = v:GetChild("n10")
        local teamData = members[k]
        if teamData then
            icon.url = GGetMsgByRoleIcon(teamData.roleIcon,teamData.roleId,function(t)
                if icon then icon.url = t.headUrl end
            end).headUrl
            name.text = teamData.roleName
            if teamData.roleId == data.captainRoleId then--队长
                captain.visible = true
            else
                captain.visible = false
            end
            if data.roleId == teamData.roleId then
                teamData.reqType = data.reqType
            end
            if teamData.ready and teamData.ready == 1 then--已经准备了
                zbIcon.url = UIPackage.GetItemURL("paiwei","dujie_001")
                zbNum = zbNum + 1
            else
                if teamData.roleId == data.captainRoleId then--如果是队长
                    zbIcon.url = UIPackage.GetItemURL("paiwei","dujie_001")
                    zbNum = zbNum + 1
                else
                    zbIcon.url = UIPackage.GetItemURL("paiwei","dujie_002")
                end
            end
            powerText.text = string.format(language.team67, GTransFormNum(teamData.power))
        else
            zbIcon.url = UIPackage.GetItemURL("paiwei","dujie_002")
            captain.visible = false
            icon.url = ""
            name.text = ""
            powerText.text = ""
        end
    end

end
--拒绝
function PwsTeamWarSendView:onClickRefuse()
    proxy.QualifierProxy:sendMsg(1480205,{reqType = 4})
end
--同意
function PwsTeamWarSendView:onClickAgree()
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.gonggong41)
    else
        proxy.QualifierProxy:sendMsg(1480205,{reqType = 3})
    end
end


return PwsTeamWarSendView