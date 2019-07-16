--
-- Author: Your Name
-- Date: 2017-11-30 21:28:28
--

local InvitePeople = class("InvitePeople", base.BaseView)

function InvitePeople:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function InvitePeople:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.decTxt = self.view:GetChild("n2")
    self.numTxt = self.view:GetChild("n6")
    self.sumTxt = self.view:GetChild("n9")
    self.minusBtn = self.view:GetChild("n4")
    self.minusBtn.onClick:Add(self.onClickMinus,self)
    self.addBtn = self.view:GetChild("n5")
    self.addBtn.onClick:Add(self.onClickAdd,self)
    self.sureBtn = self.view:GetChild("n10")
    self.sureBtn.onClick:Add(self.onClickSure,self)
end

function InvitePeople:onClickMinus()
    if self.nums > 1 then
        self.nums = self.nums - 1
        self.sumPrice = self.price*self.nums
        self.numTxt.text = self.nums
        self.sumTxt.text = self.sumPrice
    end
end

function InvitePeople:onClickAdd()
    if self.nums < self.inviteNums then
        self.nums = self.nums + 1
        self.sumPrice = self.price*self.nums
        self.numTxt.text = self.nums
        self.sumTxt.text = self.sumPrice
    end
end

function InvitePeople:onClickSure()
    if self.nums > self.inviteNums then
        GComAlter(language.marryiage52)
    else
        proxy.MarryProxy:sendMsg(1390303,{reqType = 5,num = self.nums})
        self:closeView()
    end
end

function InvitePeople:setInviteCount(inviteCount)
    self.inviteNums = conf.MarryConf:getValue("invite_guests_max_count") - inviteCount
    self.decTxt.text = string.format(language.marryiage49,self.inviteNums)
end

function InvitePeople:initData(data)
    self.price = conf.MarryConf:getValue("add_invite_guests_cost")
    self.nums = 1
    self.sumPrice = self.price*self.nums
    self.numTxt.text = self.nums
    self.sumTxt.text = self.sumPrice
end

return InvitePeople