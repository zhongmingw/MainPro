--
-- Author: Your Name
-- Date: 2018-01-30 16:56:56
--

local DismissTipsView = class("DismissTipsView", base.BaseView)

function DismissTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function DismissTipsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    local cancelBtn = self.view:GetChild("n6")
    self:setCloseBtn(cancelBtn)    
end

function DismissTipsView:initData(data)
    local sureBtn = self.view:GetChild("n7")
    sureBtn.data = data
    sureBtn.onClick:Add(self.onClickSure,self)
    local dec = self.view:GetChild("n5")
    if data.type == 1 then
        dec.text = language.qualifier23
    else
        dec.text = language.qualifier24
    end
end

function DismissTipsView:onClickSure(context)
    local data = context.sender.data
    local teamInfo = cache.PwsCache:getTeamInfo()
    if data.type == 1 then
        proxy.QualifierProxy:sendMsg(1480204,{teamId = teamInfo.teamId,reqType = 3,roleId = 0})
    else
        proxy.QualifierProxy:sendMsg(1480204,{teamId = teamInfo.teamId,reqType = 4,roleId = 0})
    end
    self:closeView()
end

return DismissTipsView