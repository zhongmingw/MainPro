--
-- Author: Your Name
-- Date: 2017-11-25 14:21:26
--

local MarryInviteView = class("MarryInviteView", base.BaseView)

function MarryInviteView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function MarryInviteView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(btnClose)

    self.txtHasTab = self.view:GetChild("n16"):GetChild("n0")
    self.listView = self.view:GetChild("n18")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.dec = self.view:GetChild("n1")
    local inviteNums = conf.MarryConf:getValue("wedding_banquet_invite_count")
    self.dec.text = string.format(language.marryiage50,inviteNums)
    self.dec2 = self.view:GetChild("n2")
    self.addNumBtn = self.view:GetChild("n3")
    self.addNumBtn.onClick:Add(self.onClickAdd,self)
    self.controller = self.view:GetController("c1")
    self.controller.onChanged:Add(self.onController,self)
end

function MarryInviteView:onController()
    if self.controller.selectedIndex == 0 then
        self.reqType = 1
        proxy.MarryProxy:sendMsg(1390303,{reqType = 1})
    elseif self.controller.selectedIndex == 1 then
        self.reqType = 2
        proxy.MarryProxy:sendMsg(1390303,{reqType = 2})
    elseif self.controller.selectedIndex == 2 then
        self.reqType = 3
        proxy.MarryProxy:sendMsg(1390303,{reqType = 3})
    end
end

function MarryInviteView:celldata( index,obj )
    local data = self.notInvited[index+1]
    if data then
        local nameTxt = obj:GetChild("n0")
        nameTxt.text = data.roleName
        local addBtn = obj:GetChild("n1")
        addBtn.data = data
        addBtn.onClick:Add(self.onClickInvite,self)
    end
end

function MarryInviteView:initData()
    self.controller.selectedIndex = 0
    self:onController()
end

function MarryInviteView:onClickInvite(context)
    local data = context.sender.data
    -- local maxNum = conf.MarryConf:getValue("invite_guests_max_count")
    -- print("次数",self.inviteCount,maxNum)
    if self.inviteCount > #self.invited then
        proxy.MarryProxy:sendMsg(1390303,{reqType = 4,roleId = data.roleId})
        self:onController()
    else
        GComAlter(language.marryiage51)
    end
end

function MarryInviteView:onClickAdd()
    mgr.ViewMgr:openView(ViewName.InvitePeople, function(view)
        view:setInviteCount(self.inviteCount)
    end)
end

function MarryInviteView:refreshRed(reqType)
    if self.reqType ~= reqType then
        self:onController()
    end
end

function MarryInviteView:setData(data)
    self.data = data
    self.invited = data.invited --已被邀请的
    self.notInvited = data.invite --未被邀请的
    self.inviteCount = data.inviteCount --最大邀请人数
    -- printt("0000000000",data)
    self.listView.numItems = self.notInvited and #self.notInvited or 0

    self.txtHasTab.text = ""
    for k,v in pairs(self.invited) do
        self.txtHasTab.text = self.txtHasTab.text .. v.roleName .."\n"
    end
    self.dec2.text = string.format(language.marryiage28,#self.invited,data.inviteCount)
end

return MarryInviteView