--
-- Author: 
-- Date: 2017-02-27 15:24:13
--
MAX_JIE = {
    [1] = 12,
    [2] = 13,
    [3] = 13,
    [4] = 13,
    [5] = 13,
}
local HuobanEquipUp = class("HuobanEquipUp", base.BaseView)
local redpoint = {10211,10213,10212,10215,10214}
function HuobanEquipUp:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function HuobanEquipUp:initData(data)
    -- body
    self.data = data
end

function HuobanEquipUp:initView()
    local window4 = self.view:GetChild("n0")
    local btnClose = window4:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")

    self.itemobj_see = self.view:GetChild("n10")
    self.skillname = self.view:GetChild("n9")
    self.skillIcon = self.itemobj_see:GetChild("icon") 
    self.skilllv = self.view:GetChild("n30")

    self.dec1 = self.view:GetChild("n11")
    self.value1 = self.view:GetChild("n12")
    self.yuan1 = self.view:GetChild("n13")

    self.dec2 = self.view:GetChild("n14")
    self.value2 = self.view:GetChild("n15")
    self.yuan2 = self.view:GetChild("n16")

    self.dec3 = self.view:GetChild("n18")
    self.value3 = self.view:GetChild("n19")
    self.yuan3 = self.view:GetChild("n20")

    self.dec4 = self.view:GetChild("n21")
    self.itemName = self.view:GetChild("n22") 
    self.itemCount = self.view:GetChild("n23")
    self.itemObj = self.view:GetChild("n3")

    local btnPlus = self.view:GetChild("n6")
    btnPlus.onClick:Add(self.onBtnPlus,self)
    self.btnPlus = btnPlus
    if g_ios_test then    --EVE ios版属屏蔽加号
        btnPlus.scaleX = 0
        btnPlus.scaleY = 0
    end 

    local btnUp = self.view:GetChild("n7")
    --self.btnUpTitle = btnUp:GetChild("title")
    btnUp.onClick:Add(self.onSkillUp,self)
    self.btnUp = btnUp

    local btnUpTen = self.view:GetChild("n31") --EVE 升级10次
    btnUpTen.onClick:Add(self.onSkillUpTen,self)
    self.btnUpTen = btnUpTen

    local dec = self.view:GetChild("n28")
    dec.text = language.gonggong72

    self.radio = self.view:GetChild("n27")
    self.radio.onClick:Add(self.onBtnRadio,self)

    self:initDec()
end

function HuobanEquipUp:initDec()
    -- body
    self.skillname.text = ""
    self.dec1.text = language.zuoqi13 
    self.value1.text = ""
    self.dec2.text = language.zuoqi14
    self.value2.text = ""
    self.dec3.text = language.zuoqi15
    self.value3.text = ""
    self.dec4.text = language.zuoqi16
    self.itemName.text = ""
    self.itemCount.text = ""

    self.itemobj_see:GetChild("n4").visible = false
    self.itemobj_see:GetChild("title").visible = false
    self.itemobj_see:GetChild("n8").visible = false
    self.itemobj_see:GetChild("n18").visible = false
    self.itemobj_see:GetChild("n11").visible = false
    self.itemobj_see:GetChild("n19").visible = false
end

function HuobanEquipUp:setCommon(flag)
    -- body
    self.isUp = {false,false,false} 
    self.skillname.text = self.condata.name
    self.skillIcon.url = ResPath.iconRes(self.condata.icon) --UIPackage.GetItemURL("_icons" , ""..self.condata.icon)
    local needlv = self.confup.need_lev  
    -- if self.index == 0 then
    --     needlv = self.confup.horse_lev 
    -- end 

    local decStr = "" 
    if self.index == 0 then
        decStr = string.format(language.huoban16,needlv)
    elseif self.index == 1 then
        decStr = string.format(language.huoban12,needlv)
    elseif self.index == 2 then
        decStr = string.format(language.huoban13,needlv)
    elseif self.index == 3 then
        decStr = string.format(language.huoban14,needlv)
    elseif self.index == 4 then
        decStr = string.format(language.huoban15,needlv)
    end
    local maxto = conf.HuobanConf:getValue("endmaxjie",self.index) or MAX_JIE[self.index+1]
    if needlv <= self.data.maxjie then
        self.value1.text =  decStr
    elseif needlv > maxto then
        if self.index == 0 then
            decStr = string.format(language.huoban16,maxto)
        elseif self.index == 1 then
            decStr = string.format(language.huoban12,maxto)
        elseif self.index == 2 then
            decStr = string.format(language.huoban13,maxto)
        elseif self.index == 3 then
            decStr = string.format(language.huoban14,maxto)
        elseif self.index == 4 then
            decStr = string.format(language.huoban15,maxto)
        end
        self.value1.text =  decStr
    else
        self.isUp[1] = true --坐骑阶数不满足
        self.value1.text = mgr.TextMgr:getTextColorStr(decStr,14)
    end

    if self.data.lv <= 0 then
        self.value2.text = language.zuoqi18
        --self.btnUpTitle.text = language.zuoqi21
    else
        self.value2.text = self.confup.dec
        --self.btnUpTitle.text = language.zuoqi22
    end


    if self.confup.cost_items  then
        for k ,v in pairs(self.confup.cost_items) do
            if k > 1 then
                break
            end

            local t = {mid = v[1],isquan = true}
            self.mId = v[1]

            self.itemObj.visible = true
            GSetItemData(self.itemObj,t,true)
            self.itemName.text = conf.ItemConf:getName(v[1]) 

            local itemCount = cache.PackCache:getPackDataById(v[1])
            local param = {}
            if itemCount.amount < v[2] then
                self.isUp[2] = true
                table.insert(param,{color = 14,text = itemCount.amount})
            else
                
                table.insert(param,{color = 7,text = itemCount.amount})
            end
            table.insert(param,{color = 7,text = "/"..v[2]})

            self.itemCount.text = mgr.TextMgr:getTextByTable(param)
        end
    else
        self.itemObj.visible = false
    end

    if self.nextconf and needlv <= maxto then
        self.c2.selectedIndex = 0
        self.dec3.text = language.zuoqi15
        self.value3.text = self.nextconf.dec
    else
        self.c2.selectedIndex = 1
        self.isUp[3] = true
        self.value3.text = language.zuoqi19   
    end

    -- --红点改变
    -- if flag then
    --     for k ,v in pairs(self.isUp) do
    --         if v then
    --             mgr.GuiMgr:redpointByID(redpoint[self.index+1])
    --             break
    --         end
    --     end
    -- end
end
function HuobanEquipUp:onBtnRadio()
    -- body
    cache.ZuoQiCache:setEquipRadio(self.radio.selected)
end
function HuobanEquipUp:setData(index,flag)
    self.index = index 
    --self.data = data
    self.c1.selectedIndex = index

    self.condata = conf.HuobanConf:getEquipById(self.data.id,index)
    self.confup = conf.HuobanConf:getEquipLevData(self.data.id,self.data.lv,index)
    self.nextconf = conf.HuobanConf:getEquipLevData(self.data.id,self.data.lv+1,index) 

    self.radio.selected = cache.ZuoQiCache:getEquipRadio()

    if self.data.lv > 0 then
        self.skilllv.text = language.gonggong83
        ..mgr.TextMgr:getTextColorStr("Lv"..(self.data.lv-1), 7)
    else
        self.skilllv.text = ""
    end
    self:setCommon(flag)  
end

function HuobanEquipUp:onBtnPlus()
    -- body
    --加号按钮

    local param = {}
    param.mid = self.mId 

    --plog(self.mId , self.mId,self.mId)

    GGoBuyItem(param)
end

function HuobanEquipUp:onSkillUp()
    -- body 技能升级
    if self.isUp then
        for k ,v in pairs(self.isUp) do
            if v then
                if k == 1 then
                    GComAlter(self.value1.text)
                elseif k == 2 then
                    self:onBtnPlus()
                else
                    GComAlter(language.zuoqi19) 
                end
                return
            end
        end
    end
    local param = {}
    param.equipId = self.data.id
    param.reqType = self.radio.selected and 1 or 0
    if self.index == 0 then
        proxy.HuobanProxy:send(1200103,param)
    elseif self.index == 1 then
        proxy.HuobanProxy:send(1210103,param)
    elseif self.index == 2 then
        proxy.HuobanProxy:send(1220104,param)
    elseif self.index == 3 then
        proxy.HuobanProxy:send(1230103,param)
    elseif self.index == 4 then
        proxy.HuobanProxy:send(1240103,param)
    end
end

--EVE 升级十次
function HuobanEquipUp:onSkillUpTen()
    self.radio.selected = true
    self:onSkillUp()
end

function HuobanEquipUp:onBtnClose()
    -- body
    self:closeView()
end
--坐骑
function HuobanEquipUp:add5200103(data)
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end

function HuobanEquipUp:add5090102()
    -- body
    self:setData(self.index)
end

return HuobanEquipUp