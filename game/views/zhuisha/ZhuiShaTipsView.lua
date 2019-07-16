--
-- Author: Your Name
-- Date: 2018-07-12 20:26:57
--

local ZhuiShaTipsView = class("ZhuiShaTipsView", base.BaseView)

function ZhuiShaTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ZhuiShaTipsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.dec1 = self.view:GetChild("n4")
    self.dec2 = self.view:GetChild("n5")
    self.dec3 = self.view:GetChild("n6")
    local cancelBtn = self.view:GetChild("n2")
    self:setCloseBtn(cancelBtn)

    local sureBtn = self.view:GetChild("n1")
    sureBtn.onClick:Add(self.onClickSure,self)
end

function ZhuiShaTipsView:initData(data)
    self.data = data
    local t = clone(language.friend54)
    t[2].text = string.format(t[2].text,data.name)
    t[4].text = string.format(t[4].text,data.power)
    self.dec1.text = mgr.TextMgr:getTextByTable(t)
    self.dec3.text = language.friend56
    proxy.FriendProxy:sendMsg(1070205,{reqType = 0,roleId = data.roleId})
end

function ZhuiShaTipsView:setData(data)
    self.sceneId = data.sceneId
    local sceneConf = conf.SceneConf:getSceneById(data.sceneId)
    local t = clone(language.friend55)
    t[2].text = string.format(t[2].text,sceneConf.name)
    t[4].text = string.format(t[4].text,data.pox,data.poy)
    self.dec2.text = mgr.TextMgr:getTextByTable(t)
end

function ZhuiShaTipsView:onClickSure()
    if self.sceneId then
        proxy.FriendProxy:sendMsg(1070205,{reqType = 1,roleId = self.data.roleId})
    end
    local view = mgr.ViewMgr:get(ViewName.ZhuiShaView)
    if view then
        view:closeView()
    end
    self:closeView()
end

return ZhuiShaTipsView