--
-- Author: 
-- Date: 2017-03-11 14:12:31
--

local BangPaiExpInfo = class("BangPaiExpInfo", base.BaseView)

function BangPaiExpInfo:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function BangPaiExpInfo:initView()
    local btnClose = self.view:GetChild("n1"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    local dec = self.view:GetChild("n2")
    dec.text = language.bangpai109

    local dec1 = self.view:GetChild("n3")
    dec1.text = language.bangpai110

    local dec1 = self.view:GetChild("n4")
    dec1.text = language.bangpai111

    self.text = self.view:GetChild("n5")
end

function BangPaiExpInfo:setData(data_)
    --plog("ssssssssssssss")
    local confData  = conf.BangPaiConf:getBangLev(cache.BangPaiCache:getBangLev()
        ,cache.BangPaiCache:getBangType())
    if confData then
        self.text.text = string.format(language.gonggong23,data_.dayGotExp,confData.day_exp_max) 
    else
        self.text.text = data_.dayGotExp
    end
end

function BangPaiExpInfo:onBtnClose()
    -- body
    self:closeView()
end

return BangPaiExpInfo