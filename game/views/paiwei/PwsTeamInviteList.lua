--
-- Author: Your Name
-- Date: 2018-01-15 15:46:42
--

local PwsTeamInviteList = class("PwsTeamInviteList", base.BaseView)

function PwsTeamInviteList:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function PwsTeamInviteList:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n2")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    local refreshBtn = self.view:GetChild("n3")
    refreshBtn.onClick:Add(self.refreshView,self)
end

function PwsTeamInviteList:celldata(index,obj)
    if index + 1 >= self.listView.numItems then
        if not self.inviteData then
            return
        end
        if self.pageSum == self.page then
        elseif self.page and self.page < self.pageSum then
            proxy.QualifierProxy:sendMsg(1480210,{page = self.page+1})
        end
    end
    local data = self.inviteData[index + 1]
    if data then
        local nameTxt = obj:GetChild("n2")
        local lvTxt = obj:GetChild("n3")
        local powerTxt = obj:GetChild("n4")
        nameTxt.text = data.roleName
        lvTxt.text = data.lev
        powerTxt.text = data.power
        local inviteBtn = obj:GetChild("n1")
        inviteBtn.grayed = false
        inviteBtn.touchable = true
        inviteBtn.data = data
        inviteBtn.onClick:Add(self.onClickInvite,self)
    end
end

function PwsTeamInviteList:initData(data)
    self.inviteData = {}
    self.page = 1
    proxy.QualifierProxy:sendMsg(1480210,{page = self.page})
end

function PwsTeamInviteList:setData(data)
    self.pageSum = data.pageSum
    self.page = data.page
    for k,v in pairs(data.roles) do
        table.insert(self.inviteData,v)
    end
    printt("排位赛队伍加入信息",self.inviteData)
    self.listView.numItems = #self.inviteData
end

--邀请
function PwsTeamInviteList:onClickInvite(context)
    local data = context.sender.data
    context.sender.grayed = true
    context.sender.touchable = false
    local param = {roleId = data.roleId,reqType = 5,teamId = 0}
    proxy.QualifierProxy:sendMsg(1480204,param)
end

--刷新列表
function PwsTeamInviteList:refreshView()
    self.inviteData = {}
    self.page = 1
    proxy.QualifierProxy:sendMsg(1480210,{page = self.page})
    GComAlter(language.gonggong39)
end

return PwsTeamInviteList