--
-- Author: 
-- Date: 2018-08-06 16:23:55
--

local XianTongEquipUp = class("XianTongEquipUp", base.BaseView)

function XianTongEquipUp:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianTongEquipUp:initView()
    local window4 = self.view:GetChild("n0")
    local btnClose = window4:GetChild("n2")
    self:setCloseBtn(btnClose)

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


    local btnUp = self.view:GetChild("n7")
    btnUp.data = 0
    btnUp.onClick:Add(self.onSkillUp,self)
    self.btnUp = btnUp

    local btnUpTen = self.view:GetChild("n38") --EVE 升级十次
    btnUpTen.data = 1
    btnUpTen.onClick:Add(self.onSkillUp,self)
    self.btnUpTen = btnUpTen

    self:initDec()
end

function XianTongEquipUp:initDec( ... )
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
end

function XianTongEquipUp:initData(data)
    -- body
    self.data = data
    
    self.isUp = {false,false,false} 
    self.skillname.text = self.data.name
    local t = {}
    t.isCase = true
    t.url = ResPath.iconRes(self.data.icon)
    t.color = self.data.color
    GSetItemData(self.itemobj_see, t, false)
    --self.skillIcon.url = 
    --print("self.data.id",self.data.id,self.data.level)
    self.conddata = conf.MarryConf:getXTlev(self.data.petlevel)
    self.confup = conf.MarryConf:getEquipByLev(self.data.id,self.data.level)
    self.nextconf = conf.MarryConf:getEquipByLev(self.data.id,self.data.level+1)

    if self.data.level > 0 then
        self.skilllv.text = language.gonggong83
        ..mgr.TextMgr:getTextColorStr("Lv"..(self.data.level-1), 7)
    else
        self.skilllv.text = ""
    end

    local needlv = self.confup.need_lev
    local curjie = self.conddata.jie
    local decStr = string.format(language.xiantong15,needlv)
    if needlv <= curjie then
        --阶 满足
        self.value1.text = decStr
    else
        self.isUp[1] = true --坐骑阶数不满足
        self.value1.text = mgr.TextMgr:getTextColorStr(decStr,14) 
    end

    if self.data.level <= 0 then
        self.value2.text = language.zuoqi18
    else
        self.value2.text = self.confup.dec
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

     if self.nextconf then
        self.c2.selectedIndex = 0
        self.dec3.text = language.zuoqi15
        self.value3.text = self.nextconf.dec
    else
        self.c2.selectedIndex = 1
        self.isUp[3] = true 
    end
end
function XianTongEquipUp:onBtnPlus()
    -- body
    --加号按钮
    local param = {}
    param.mId = self.mId 
    GGoBuyItem(param)
end


function XianTongEquipUp:onSkillUp(context)
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
    param.reqType = context.sender.data
    param.xtRoleId = self.data.xtRoleId
     --printt(0)
    proxy.MarryProxy:sendMsg(1390603,param)
end

function XianTongEquipUp:addMsgCallBack(data)
    -- body
    self.data.level = data.lev
    self:initData(self.data)
end
return XianTongEquipUp