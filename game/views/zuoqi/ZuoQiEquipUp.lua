--
-- Author: 
-- Date: 2017-02-20 16:09:40
--

local ZuoQiEquipUp = class("ZuoQiEquipUp", base.BaseView)
local redpoint = {10216,10207,10210,10208,10209,10262}
function ZuoQiEquipUp:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function ZuoQiEquipUp:initData(data)
    -- body
    self.data = data
    --self:setData(data)
end

function ZuoQiEquipUp:initView()
    local window4 = self.view:GetChild("n0")
    local btnClose = window4:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")

    self.itemobj_see = self.view:GetChild("n10")

    self.skillname = self.view:GetChild("n9")
    self.skillIcon = self.itemobj_see:GetChild("icon") 
    self.skilllv = self.view:GetChild("n37")
    
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
    btnUp.onClick:Add(self.onSkillUp,self)
    self.btnUp = btnUp

    local btnUpTen = self.view:GetChild("n38") --EVE 升级十次
    btnUpTen.onClick:Add(self.onSkillUpTen,self)
    self.btnUpTen = btnUpTen

    local dec = self.view:GetChild("n34")
    dec.text = language.gonggong72

    self.radio = self.view:GetChild("n33")
    self.radio.onClick:Add(self.onBtnRadio,self)

    self:initDec()
end

function ZuoQiEquipUp:initDec()
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

    self.skilllv.text = ""

    self.itemobj_see:GetChild("n4").visible = false
    self.itemobj_see:GetChild("title").visible = false
    self.itemobj_see:GetChild("n8").visible = false
    self.itemobj_see:GetChild("n18").visible = false
    self.itemobj_see:GetChild("n11").visible = false
    self.itemobj_see:GetChild("n19").visible = false
end

function ZuoQiEquipUp:setCommon(flag)
    self.isUp = {false,false,false} 
    self.skillname.text = self.condata.name
    self.skillIcon.url = ResPath.iconRes(self.condata.icon) --UIPackage.GetItemURL("_icons" , ""..self.condata.icon)
    local needlv 
    if self.index == 0 then
        needlv = self.confup.horse_lev
    else
        needlv = self.confup.need_lev
    end
    local decStr = string.format(language.zuoqi17[self.index+1],needlv) 

    local maxto = conf.ZuoQiConf:getValue("endmaxjie",self.index) or 10
    if needlv <= self.data.maxjie then
        self.value1.text =  decStr
    elseif needlv > maxto then
        self.value1.text =  string.format(language.zuoqi17[self.index+1],maxto)  --decStr
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
            local t = {mid = v[1]}
            t.isquan = true
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
        self.isUp[2] = true
        self.itemObj.visible = false
    end

    
    if self.nextconf and needlv <= maxto then
        self.c2.selectedIndex = 0
        self.dec3.text = language.zuoqi15
        self.value3.text = self.nextconf.dec
    else
        self.c2.selectedIndex = 1
        self.isUp[3] = true 
    end

    -- --红点改变
    -- if flag then
    --     for k ,v in pairs(self.isUp) do
    --         if v then
    --             --plog("红点扣除")
    --             mgr.GuiMgr:redpointByID(redpoint[self.index+1])
    --             break
    --         end
    --     end
    -- end
end

function ZuoQiEquipUp:onBtnRadio()
    -- body
    cache.ZuoQiCache:setEquipRadio(self.radio.selected)
end

function ZuoQiEquipUp:setData(index,flag)
    self.index = index 
    --self.data = data
    self.c1.selectedIndex = index

    self.index = index 
    self.condata = conf.ZuoQiConf:getEquipById(self.data.id,index)
    self.confup = conf.ZuoQiConf:getEquipByLev(self.data.id,self.data.lv,index)
    self.nextconf = conf.ZuoQiConf:getEquipByLev(self.data.id,self.data.lv+1,index)

    self.radio.selected = cache.ZuoQiCache:getEquipRadio(self.data.id,index)
    if self.data.lv > 0 then
        self.skilllv.text = language.gonggong83
        ..mgr.TextMgr:getTextColorStr("Lv"..(self.data.lv-1), 7)
    else
        self.skilllv.text = ""
    end

    self:setCommon(flag) 
  
end

function ZuoQiEquipUp:onBtnPlus()
    -- body
    --加号按钮
    local param = {}
    param.mId = self.mId 
    GGoBuyItem(param)
end

function ZuoQiEquipUp:onSkillUp()
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
    --self:add5120104()
    local param = {}
    param.equipId = self.data.id
    param.reqType = self.radio.selected and 1 or 0
    if self.index == 0 then
        proxy.ZuoQiProxy:send(1120103,param)
    elseif self.index == 1 then
        proxy.ZuoQiProxy:send(1160103,param)
    elseif self.index == 2 then
        proxy.ZuoQiProxy:send(1170103,param)
    elseif self.index == 3 then
        proxy.ZuoQiProxy:send(1140103,param)
    elseif self.index == 4 then
        proxy.ZuoQiProxy:send(1180103,param)
    elseif self.index == 5 then
        proxy.ZuoQiProxy:send(1560103,param)
    end
end

--EVE 升级十次
function ZuoQiEquipUp:onSkillUpTen()
    self.radio.selected = true
    self:onSkillUp()
end

function ZuoQiEquipUp:onBtnClose()
    -- body
    self:closeView()
end
--坐骑
function ZuoQiEquipUp:add5120103(data)
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
--限于
function ZuoQiEquipUp:add5140103(data )
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
--神兵
function ZuoQiEquipUp:add5160103(data )
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
--仙器
function ZuoQiEquipUp:add5180103(data )
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
--法宝
function ZuoQiEquipUp:add5170103(data )
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
function ZuoQiEquipUp:add5560103(data )
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
function ZuoQiEquipUp:add5090102()
    -- body
    self:setData(self.index)
end
return ZuoQiEquipUp