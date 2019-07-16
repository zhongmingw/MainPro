--
-- Author: 
-- Date: 2017-03-07 10:26:09
--

local BangPaiSetApply = class("BangPaiSetApply", base.BaseView)

function BangPaiSetApply:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function BangPaiSetApply:initData()
    -- body
    self.radio1.selected = true
    self.radio2.selected = true
    self.radio3.selected = true

    self.input1.text = 1
    self.input2.text = 1
    self.input3.text = 0
end

function BangPaiSetApply:initView()
    local btn = self.view:GetChild("n1"):GetChild("n2")
    btn.onClick:Add(self.onBtnClose,self)

    self.input1 = self.view:GetChild("n14")
    self.input1.onFocusOut:Add(self.onLvInput,self)
    self.input2 = self.view:GetChild("n15")
    self.input2.onFocusOut:Add(self.onVipInput,self)
    self.input3 = self.view:GetChild("n16")
    self.input3.onFocusOut:Add(self.onPowerInput,self)

    local dec1 = self.view:GetChild("n4")
    dec1.text = language.bangpai30

    local dec1 = self.view:GetChild("n11")
    dec1.text = language.bangpai31

    local dec1 = self.view:GetChild("n12")
    dec1.text = language.bangpai32

    local dec1 = self.view:GetChild("n13")
    dec1.text = language.bangpai33

    self.radio1 = self.view:GetChild("n8")
    self.radio2 = self.view:GetChild("n9")
    self.radio3 = self.view:GetChild("n10")

    local btnSure = self.view:GetChild("n19")
    btnSure.onClick:Add(self.onSure,self)
end

function BangPaiSetApply:onLvInput()
    -- body
    --plog("ddd",self.input1.text)
    if self.input1.text == "" then
        self.input1.text = 1
    elseif tonumber(self.input1.text) < 0 then
        self.input1.text = 0
    end
end

function BangPaiSetApply:onVipInput()
    -- body
    if self.input2.text == "" then
        self.input2.text = 0
    elseif tonumber(self.input2.text) > 10 then
        self.input2.text = 10 
    elseif tonumber(self.input2.text) < 0 then
        self.input2.text = 0 
    end
end

function BangPaiSetApply:onPowerInput()
    -- body
    if self.input3.text == "" then
        self.input3.text = 0
    elseif tonumber(self.input3.text)<0 then
        self.input3.text = 0
    end
end

function BangPaiSetApply:setData(data_)

end

function BangPaiSetApply:onSure()
    -- body
    local param = {}
    param.level = self.radio1.selected and self.input1.text or -1
    param.vipLevel = self.radio2.selected and self.input2.text or -1
    param.power = self.radio3.selected and self.input3.text or -1
    param.reqType = 2

    proxy.BangPaiProxy:sendMsg(1250208, param)
    self:closeView()
end

function BangPaiSetApply:onBtnClose()
    -- body
    self:closeView()
end


function BangPaiSetApply:add5250208(data)
    -- body
    if #data.settings == 0 then
        return
    end


    self.input1.text = data.settings[1] or 0--data.level
    self.input2.text = data.settings[2] or 0--data.vipLevel
    self.input3.text = data.settings[3] or 0--data.power

    if data.settings[1] then
        self.radio1.selected = true
    else
        self.radio1.selected = false
    end

    if data.settings[2] then
        self.radio2.selected = true
    else
        self.radio2.selected = false
    end

    if data.settings[3] then
        self.radio3.selected = true
    else
        self.radio3.selected = false
    end
end

return BangPaiSetApply