--
-- Author: Your Name
-- Date: 2018-01-29 20:51:49
--

local PwsTeamApplyView = class("PwsTeamApplyView", base.BaseView)

function PwsTeamApplyView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function PwsTeamApplyView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n5")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    --一键拒绝
    self.oneKeyRefuse = self.view:GetChild("n2")
    self.oneKeyRefuse.onClick:Add(self.onClickOneKeyRefuse,self)

end

function PwsTeamApplyView:cellData(index,obj)
    if index + 1 >= self.listView.numItems then
        if not self.applysData then
            return
        end
        if self.pageSum == self.page then
        elseif self.page and self.page < self.pageSum then
            proxy.QualifierProxy:sendMsg(1480211,{page = self.page+1})
        end
    end
    local data = self.applysData[index + 1]
    if data then
        local nameTxt = obj:GetChild("n1")
        local lvTxt = obj:GetChild("n2")
        local powerTxt = obj:GetChild("n3")
        nameTxt.text = data.roleName
        lvTxt.text = data.lev
        powerTxt.text = data.power
        local refuseBtn = obj:GetChild("n4")
        refuseBtn.data = data
        refuseBtn.onClick:Add(self.onClickRefuse,self)
        local agreeBtn = obj:GetChild("n5")
        agreeBtn.data = data
        agreeBtn.onClick:Add(self.onClickAgree,self)
    end
end

function PwsTeamApplyView:initData(data)
    self.applysData = {}
    self.page = 1
    proxy.QualifierProxy:sendMsg(1480211,{page = self.page})
end

function PwsTeamApplyView:setData(data)
    printt("申请列表信息",data)
    self.pageSum = data.pageSum
    self.page = data.page
    for k,v in pairs(data.applys) do
        table.insert(self.applysData,v)
    end
    self.listView.numItems = #self.applysData

end

function PwsTeamApplyView:onClickRefuse(context)
    local data = context.sender.data
    local roleId = cache.PlayerCache:getRoleId()
    local teamInfo = cache.PwsCache:getTeamInfo()
    if roleId == teamInfo.captainRoleId then
        local param = {roleId = data.roleId,reqType = 9,teamId = 0}
        proxy.QualifierProxy:sendMsg(1480204,param)
    else
        GComAlter(language.qualifier25)
    end
end

function PwsTeamApplyView:onClickAgree(context)
    local data = context.sender.data
    local roleId = cache.PlayerCache:getRoleId()
    local teamInfo = cache.PwsCache:getTeamInfo()
    if roleId == teamInfo.captainRoleId then
        local param = {roleId = data.roleId,reqType = 8,teamId = 0}
        proxy.QualifierProxy:sendMsg(1480204,param)
    else
        GComAlter(language.qualifier25)
    end
end

--刷新列表
function PwsTeamApplyView:refreshView()
    self.applysData = {}
    self.page = 1
    proxy.QualifierProxy:sendMsg(1480211,{page = self.page})
end

function PwsTeamApplyView:onClickOneKeyRefuse()
    if #self.applysData == 0 then
        GComAlter(language.qualifier39)
    else
        local roleId = cache.PlayerCache:getRoleId()
        local teamInfo = cache.PwsCache:getTeamInfo()
        if roleId == teamInfo.captainRoleId then
            local param = {roleId = 0,reqType = 10,teamId = 0}
            proxy.QualifierProxy:sendMsg(1480204,param)
        else
            GComAlter(language.qualifier25)
        end
    end
end

return PwsTeamApplyView