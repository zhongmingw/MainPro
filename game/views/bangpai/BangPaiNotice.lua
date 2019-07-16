--
-- Author: 
-- Date: 2017-03-09 21:35:40
--

local BangPaiNotice = class("BangPaiNotice", base.BaseView)

function BangPaiNotice:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function BangPaiNotice:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    local dec = self.view:GetChild("n3") 
    dec.text = language.bangpai05

    self.input = self.view:GetChild("n6")

    local btnSure =  self.view:GetChild("n1")
    btnSure.onClick:Add(self.onSure,self)
end

function BangPaiNotice:setData(data_)
    self.input = data_
end

function BangPaiNotice:onSure()
    -- body
    local param = {}
    param.notice = self.input.text
    proxy.BangPaiProxy:sendMsg(1250206, param)
    self:onBtnClose()
end

function BangPaiNotice:onBtnClose( ... )
    -- body
    self:closeView()
end

return BangPaiNotice