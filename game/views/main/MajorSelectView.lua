--
-- Author: Your Name
-- Date: 2017-08-29 20:47:49
--

local MajorSelectView = class("MajorSelectView", base.BaseView)

function MajorSelectView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
end

function MajorSelectView:initView()
    local closeBtn = self.view:GetChild("n2")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.listView = self.view:GetChild("n6")
    self.selectBtn = self.view:GetChild("n10")
    self.selectBtn.onChanged:Add(self.onClickSingleBtn,self)
    self.autoBtn = self.view:GetChild("n12")
    self.autoBtn.onClick:Add(self.onClickAuto,self)
    self.c1 = self.view:GetController("c1")
    self:initListView()
end

function MajorSelectView:initData()
    self.match = 0
    self.c1.selectedIndex = 0
end

function MajorSelectView:initListView()
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function MajorSelectView:onClickSingleBtn()
    if self.selectBtn.selected then
        proxy.PlayerProxy:send(1020414,{reqType = 2,auto = 1,match = 0})
    else
        proxy.PlayerProxy:send(1020414,{reqType = 2,auto = 0,match = 0})
    end
end

function MajorSelectView:celldata( index,obj )
    local data = self.data.repairInfos[index+1]
    if data then
        local nameTxt = obj:GetChild("n0")
        local sexTxt = obj:GetChild("n1")
        local gangNameTxt = obj:GetChild("n2")
        nameTxt.text = data.roleName
        sexTxt.text = language.gonggong28[data.sex]
        gangNameTxt.text = data.gangName == "" and language.juese04  or data.gangName
        local inviteBtn = obj:GetChild("n3")
        inviteBtn.data = data
        inviteBtn.onClick:Add(self.onClickInvite,self)
    end
end

--邀请
function MajorSelectView:onClickInvite(context)
    local data = context.sender.data
    if gRole.isChangeBody then
        GComAlter(language.dazuo15)
    else
        if gRole:isMajor() then
            GComAlter(language.dazuo17)
            return
        end
        proxy.PlayerProxy:send(1020412,{reqType = 1,roleId = data.roleId})
    end
end

function MajorSelectView:onClickAuto()
    if gRole.isChangeBody then
        GComAlter(language.dazuo15)
    else
        if gRole:isMajor() then
            GComAlter(language.dazuo17)
            return
        end
        if self.match == 0 then
            proxy.PlayerProxy:send(1020412,{reqType = 3,roleId = 0,match = 1})
        else
            proxy.PlayerProxy:send(1020412,{reqType = 3,roleId = 0,match = 0})
        end
    end
end

function MajorSelectView:setAutoMatch( match )
    self.match = match
    self.c1.selectedIndex = self.match
end

function MajorSelectView:setData(data)
    self.data = data
    if data.auto == 1 then
        self.selectBtn.selected = true
    else
        self.selectBtn.selected = false
    end
    self.listView.numItems = #self.data.repairInfos
end

function MajorSelectView:onClickClose()
    self:closeView()
end

return MajorSelectView