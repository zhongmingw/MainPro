--
-- Author: 
-- Date: 2017-03-28 16:01:23
--
--邀请队员
local TeamSearchView = class("TeamSearchView", base.BaseView)

function TeamSearchView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function TeamSearchView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    local dec = self.view:GetChild("n16")
    dec.text = language.team12
    local dec = self.view:GetChild("n18")
    dec.text = language.team13
    local dec = self.view:GetChild("n19")
    dec.text = language.team14

    self.listView = self.view:GetChild("n17")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    

    local btnReset = self.view:GetChild("n9")
    btnReset.onClick:Add(self.onBtnReset,self)
end

function TeamSearchView:initData()
    local btn = self.view:GetChild("n4")
    btn.title = language.team09
    local btn = self.view:GetChild("n5")
    btn.title = language.team10
    local btn = self.view:GetChild("n6")
    if cache.PlayerCache:getGangId().."" == "0" then
        btn.visible = false
    else
        btn.visible = true
    end
    btn.title= language.team11
end

function TeamSearchView:onController1()
    local reqType = 0
    if self.c1.selectedIndex == 0  then --附近
        reqType = 1
    elseif self.c1.selectedIndex == 1 then--好友
        reqType = 2
    elseif self.c1.selectedIndex == 2 then--帮派    
        reqType = 3
    end
    self.reqType = reqType
    proxy.TeamProxy:send(1300103,{reqType = reqType,page = 1})
end

function TeamSearchView:setData(data)
    local page = data.page
    if self.mData and page and page > 1 then
        if data and self.mData.page < page and data.users then
            self.mData.page = page
            self.mData.totalSum = data.totalSum
            for _,v in pairs(data.users) do
                table.insert(self.mData.users, v)
            end
        end
    else
        self.mData = {}
        self.mData.page = data.page
        self.mData.totalSum = data.totalSum
        self.mData.users = data.users
    end

    local numItems = #self.mData.users
    self.listView.numItems = numItems
    if page == 1 and numItems > 0 then
        self.listView:ScrollToView(0,false,true)
    end
end

function TeamSearchView:cellData(index,cell)
    if index + 1 >= self.listView.numItems then
        if not self.mData.users then
            return
        end
        if self.mData.page < self.mData.totalSum then 
           -- plog("下一页",self.mData.page + 1)
           proxy.TeamProxy:send(1300103,{reqType = self.reqType, page = self.mData.page + 1})
        end
    end
    local data = self.mData.users[index + 1]
    local nameText = cell:GetChild("n1")
    nameText.text = data.roleName
    local lvText = cell:GetChild("n2")
    lvText.text = data.level
    local gangText = cell:GetChild("n3")
    local gangName = data.gangName
    if gangName == 0 or string.utf8len(gangName) == 0 then
        gangName = language.team24
    end
    gangText.text = gangName
    local powerText = cell:GetChild("n6")
    powerText.text = GTransFormNum(data.power)
    local btn = cell:GetChild("n5")
    btn.data = data
    btn.onClick:Add(self.onClickInvitation,self)
end

function TeamSearchView:onClickInvitation(context)
    local cell = context.sender
    local data = cell.data
    local minLv,maxLv = cache.TeamCache:getTeamLv()
    if data.level < minLv or data.level > maxLv then
        GComAlter(language.team53)
    else
        proxy.TeamProxy:send(1300105,{tarRoleId = data.roleId})
    end
end

function TeamSearchView:onBtnReset()
    -- body
    proxy.TeamProxy:send(1300103,{reqType = self.reqType,page = 1})
end

return TeamSearchView