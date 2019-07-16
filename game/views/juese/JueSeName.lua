--
-- Author: 
-- Date: 2017-02-08 19:55:58
--

local JueSeName = class("JueSeName", base.BaseView)

function JueSeName:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function JueSeName:initData()
    -- body
   self.input.text = ""
   self.bangpai = nil
   self.selectskin = nil  
   self.change = nil 

   self.window.icon = UIItemRes.juese01[1]
end

function JueSeName:initView()
    self.window = self.view:GetChild("n2")
    local btnClose = self.window:GetChild("n2")
    self:setCloseBtn(btnClose)
    --btnClose.onClick:Add(self.onBtnClose,self)

    self.dec1 = self.view:GetChild("n6")
    self.dec2 = self.view:GetChild("n7")
    self.dec3 = self.view:GetChild("n11")
    self.input = self.view:GetChild("n8")
    
    local btnCancel = self.view:GetChild("n4")
    self:setCloseBtn(btnCancel)

    local btnSure = self.view:GetChild("n5")
    btnSure.onClick:Add(self.onBtnSure,self)

    self.btnSure = btnSure
end

function JueSeName:setData(data_)
    local param = {}
    param.name = ""
    param.reqType = 0
    param.index = 0
    proxy.PlayerProxy:send(1020204)

    
    self.dec1.text = language.juese18
    self.dec2.text = language.juese19
    self.dec3.text = string.format(language.juese20,conf.SysConf:getValue("name_change_level")) 
    self.input.text = ""

    -- if cache.PlayerCache:getRedPointById(10301) > 0 then
    --     self.btnSure.visible = true   --enabled
    -- else
    --     self.btnSure.visible = false
    -- end
end

function JueSeName:onBtnSure()
    -- body
    if self.input.text == "" then
        GComAlter(language.juese18)
        return
    end

    if self.selectskin then
        self:changeHuobanName()
        return 
    elseif self.change then
        self:changOtherName()
        return
    end
    -- local level = conf.SysConf:getValue("name_change_level")
    -- if self.data.leftFreeCount
    -- if cache.PlayerCache:getRoleLevel() >= level then
    --     GComAlter( string.format(language.juese21,level) )
    --     return
    -- end


    local param = {}
    param.name = self.input.text
    param.reqType = 1
    param.index = 0

    if self.bangpai then
        param.reqType = 3
    end

    proxy.PlayerProxy:send(1020204,param)

    self:onBtnClose()
end

--伙伴改名
function JueSeName:setDataHuoBan(data,skins)
    -- body
    self.btnSure.visible = true
    self.selectskin = data
    self.dec1.text = language.huoban27
    self.dec2.text = language.huoban40
    local param 
    for k ,v in pairs(skins) do
        if v.skinId == self.selectskin then
            param = v 
            break
        end
    end
    if param and param.changeNameCount >= conf.HuobanConf:getValue("free_change_name_count",0)  then
        local var = param.changeNameCount - conf.HuobanConf:getValue("free_change_name_count",0) + 1
        local moneyTable = conf.HuobanConf:getValue("change_name_cost",0)
        local use = moneyTable[var] or moneyTable[#moneyTable]
        local t = clone(language.huoban31)
        t[2].text = string.format(t[2].text,use)
        self.dec3.text = mgr.TextMgr:getTextByTable(t)
    else
        self.dec3.text = language.huoban28
    end
end

function JueSeName:setDataBangPai(data)
    -- body
    self.bangpai = true
    self.dec1.text = language.bangpai16
    self.dec2.text = ""
    self.dec3.text = language.bangpai152

end

function JueSeName:changeHuobanName()
    -- body

    local param = {}
    --plog("self.selectskin",self.selectskin)
    param.name = string.trim(self.input.text)
    param.skinId = self.selectskin
    proxy.HuobanProxy:send(1200106,param)

    self:closeView()
end

function JueSeName:setDataPetName(data)
    -- body
    self.data = data
    self.change  = "pet"

    self.window.icon = UIItemRes.juese01[2]
    self.dec1.text = language.pet44
    self.input.text = ""
    self.dec2.text = language.juese19


    local money = conf.PetConf:getValue("pet_rename_cost")
    local param = clone(language.juese23)

    param[4].text = string.format(param[4].text,money)
    if money > cache.PlayerCache:getTypeMoney(MoneyType.gold) then
        param[4].color = 14
    else
        param[4].color = 7
    end

    self.dec3.text = mgr.TextMgr:getTextByTable(param)
end

function JueSeName:setXTDataName(data)
    -- body
    self.data = data
    self.change  = "xt"

    self.window.icon = UIItemRes.juese01[3]
    self.dec1.text = language.xiantong19
    self.input.text = ""
    self.dec2.text = language.juese19


    local money = conf.MarryConf:getXTValue("xt_rename_cost")[1]
    local param = clone(language.juese23)
    param[3].url = UIItemRes.moneyIcons[MoneyType.bindGold]
    param[4].text = string.format(param[4].text,money)
    if money > cache.PlayerCache:getTypeMoney(MoneyType.bindGold) then
        param[4].color = 14
    else
        param[4].color = 7
    end

    self.dec3.text = mgr.TextMgr:getTextByTable(param)
end

function JueSeName:changOtherName()
    -- body
    if not self.change then
        return
    end
    if self.input.text == "" then
        GComAlter(language.gonggong123)
        return
    end
    if self.change == "pet" then
        if not self.data then
            return
        end

        local param = {}
        param.petRoleId = self.data.petRoleId
        param.name = string.trim(self.input.text)
        proxy.PetProxy:sendMsg(1490111,param)
    elseif self.change == "xt" then
        if not self.data then
            return
        end

        local param = {}
        param.xtRoleId = self.data.xtRoleId
        param.name = string.trim(self.input.text)
        proxy.PetProxy:sendMsg(1390608,param)
    end
    self:onBtnClose()
end

function JueSeName:onBtnClose()
    -- body
    self:closeView()
end


function JueSeName:add5020204(data)
    -- body
    self.data = data

    if data.leftMergeFreeCount > 0 then
        --剩余合服免费改名次数
        self.dec3.text = language.juese31
    elseif data.leftFreeCount > 0 and cache.PlayerCache:getRoleLevel() <= conf.SysConf:getValue("name_change_level") then
        --有免费改名次数
    else
        --消耗（元宝图标）：20
        local t = conf.SysConf:getValue("change_name_cost")
        local money = t[data.changeNameCount+1] or t[#t]
        local param = clone(language.juese23)

        param[4].text = string.format(param[4].text,money)
        if money > cache.PlayerCache:getTypeMoney(MoneyType.gold) then
            param[4].color = 14
        else
            param[4].color = 7
        end

        self.dec3.text = mgr.TextMgr:getTextByTable(param)
    end
end
return JueSeName