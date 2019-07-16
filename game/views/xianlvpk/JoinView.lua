--
-- Author: 
-- Date: 2018-07-24 21:57:10
--

local JoinView = class("JoinView", base.BaseView)

function JoinView:ctor()
    JoinView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function JoinView:initView()
    self.inPutTxt = self.view:GetChild("n6")
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    local cancelBtn = self.view:GetChild("n3")
    self:setCloseBtn(closeBtn)
    self:setCloseBtn(cancelBtn)
    local sureBtn = self.view:GetChild("n1")
    sureBtn.onClick:Add(self.onJoin,self)
end

function JoinView:initData(data)
    self.msgId = data and data.msgId
    local needYb = self.view:GetChild("n11")
    local cost = conf.XianLvConf:getValue("sign_up_cost")
    needYb.text = cost[2]
    local haveYb = self.view:GetChild("n12")
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    haveYb.text = ybData.amount
    self.inPutTxt.text = ""
    
end

function JoinView:onJoin()
    local teamName = string.trim(self.inPutTxt.text)
    if string.trim(teamName) == "" then
        GComAlter(language.xianlv16_02)
        return
    end
    if self.msgId and self.msgId == 5540101 then
        proxy.XianLvProxy:sendMsg(1540102,{reqType = 1,teamName = teamName})
    elseif self.msgId and self.msgId == 5540201 then--全服
        proxy.XianLvProxy:sendMsg(1540202,{reqType = 1,teamName = teamName})
    end
    self.inPutTxt.text = ""
end

return JoinView