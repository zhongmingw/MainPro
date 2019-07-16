--
-- Author: 
-- Date: 2018-08-08 20:18:37
--

local XianTongSkillUp = class("XianTongSkillUp", base.BaseView)

function XianTongSkillUp:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function XianTongSkillUp:initView()
    local window4 = self.view:GetChild("n0")
    local btnClose = window4:GetChild("n2")
    self:setCloseBtn(btnClose)

    self.skillIcon = self.view:GetChild("n8")
    self.skillname = self.view:GetChild("n9")
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
    btnUp.onClick:Add(self.onSkillUp,self)
    self.btnUp = btnUp

    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 1
    self:initDec()
end

function XianTongSkillUp:initDec()
    -- body
     self.skillname.text = ""

    self.dec1.text = language.xiantong23
    self.value1.text = ""
    self.dec2.text = language.zuoqi14
    self.value2.text = ""
    self.dec3.text = language.xiantong24
    self.value3.text = ""

    self.dec4.text = language.zuoqi16
    self.itemName.text = ""
    self.itemCount.text = ""
end

function XianTongSkillUp:initData(data)
    --self.data = data 
    self.confdata = data.info
    self.petData = data.petData
    self.skillname.text = self.confdata.name
    self.skillIcon.url = ResPath.iconRes(self.confdata.icon)
    --printt("data",self.confdata)
    local needlv = self.confdata.need_lev
    local decStr = string.format(language.xiantong15,needlv)
    --self.value2.text = self.confdata.dec
    if self.petData.talentInfo[self.confdata.id] then
        --激活了
        self.value1.text = decStr
        self.value2.text = self.confdata.dec 

        self.value3.visible = false
        self.dec3.visible = false
        self.yuan3.visible = false
    else
        --未激活
        self.value3.visible = true
        self.dec3.visible = true
        self.yuan3.visible = true
        self.value1.text = mgr.TextMgr:getTextColorStr(decStr,14) 
        self.value2.text = language.gonggong09 
        self.value3.text = self.confdata.dec
    end
    



end

function XianTongSkillUp:onBtnPlus()
    -- body
    --加号按钮
    local param = {}
    param.mId = self.mId 
    GGoBuyItem(param)
end

function XianTongSkillUp:onSkillUp()
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
    proxy.MarryProxy:sendMsg(1390604,{skillId = self.data.id,xtRoleId = self.data.xtRoleId})
end

function XianTongSkillUp:addMsgCallBack(data)
    -- body
    self.data.level = data.lev
    self:initData(self.data)
end

return XianTongSkillUp