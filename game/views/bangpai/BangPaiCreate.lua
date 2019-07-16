--
-- Author: 
-- Date: 2017-03-03 16:54:00
--

local BangPaiCreate = class("BangPaiCreate", base.BaseView)

function BangPaiCreate:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function BangPaiCreate:initView()
    local btnClose = self.view:GetChild("n1"):GetChild("n2")
    btnClose.onClick:Add(self.onClickClose,self)

    local dec1 = self.view:GetChild("n8")
    dec1.text =  language.bangpai14
    local dec2 = self.view:GetChild("n9")
    dec2.text = language.bangpai05

    self.inputText1 = self.view:GetChild("n14")
    self.inputText2 = self.view:GetChild("n10")
    self.inputText2.text = language.bangpai149 --EVE 添加默认公告

    local btnCreate = self.view:GetChild("n15")
    btnCreate.onClick:Add(self.onCreate,self)

    local btnCreate2 = self.view:GetChild("n2")
    btnCreate2.onClick:Add(self.onCreate,self)

    local labCost = self.view:GetChild("n11")
    labCost.text = conf.BangPaiConf:getValue("create_gang_gold")

    local labCost2 = self.view:GetChild("n18")
    labCost2.text = conf.BangPaiConf:getValue("create_gang_tq")

    local dec = self.view:GetChild("n20")
    dec.text = language.bangpai144

    if g_is_banshu then
        btnCreate:SetScale(0,0)
        self.view:GetChild("n6").visible = false
        labCost.visible = false
        self.view:GetChild("n7").visible = false
        dec.visible = false
    end
end

function BangPaiCreate:setData(data_)

end

function BangPaiCreate:onCreate(context)
    -- body
    local btn = context.sender 
    if self.inputText1.text == "" then
        GComAlter(language.bangpai16)
        return
    end

    if cache.PlayerCache:getRoleLevel()<conf.BangPaiConf:getValue("create_gang_lev") then
        local str = string.format(language.bangpai15,conf.BangPaiConf:getValue("create_gang_lev"))
        GComAlter(str)
        return
    end
    local param = {}
    param.gangName = self.inputText1.text
    param.gangNotice = self.inputText2.text
    if btn.name == "n15" then
        param.reqType = 1
        local meoney = cache.PlayerCache:getTypeMoney(MoneyType.gold) --bindGold
        if meoney < conf.BangPaiConf:getValue("create_gang_gold") then
            GComAlter(language.gonggong18)
            return
        end
    else
        param.reqType = 0
        local meoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) --bindGold
        if meoney < conf.BangPaiConf:getValue("create_gang_tq") then
            GComAlter(language.gonggong05)
            return
        end
    end
    proxy.BangPaiProxy:sendMsg(1250101, param)
end


function BangPaiCreate:onClickClose()
    -- body
    self:closeView()
end
return BangPaiCreate