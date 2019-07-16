--
-- Author: 
-- Date: 2018-08-09 19:22:25
--

local XiantongSkillMsgTips = class("PetSkillMsgTips", base.BaseView)

function XiantongSkillMsgTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function XiantongSkillMsgTips:initView()
     local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    local itemSkill = self.view:GetChild("n1")
    self.icon = itemSkill:GetChild("n2")
    self.jiaobiao = itemSkill:GetChild("n4")

    self.name = self.view:GetChild("n2")
    self.name.text = ""

    self.type = self.view:GetChild("n3")
    self.type.text = ""

    self.desc = self.view:GetChild("n4")

    self.ground =  self.view:GetChild("n6")
    self.oldxy = self.ground.xy
end

function XiantongSkillMsgTips:initData(data)
    if data.pos then
        self.ground.x = 275
        self.ground.y = 318
    else
        self.ground.xy = self.oldxy
    end 
    --printt(data)

    --self.data = conf.MarryConf:getPetSkillById(data.id)
    self.icon.url = ResPath.iconRes(data.icon) 

    self.jiaobiao.visible = false
    if data.jiaobiao then
        self.jiaobiao.visible = true
        self.jiaobiao.url = ResPath.iconOther(data.jiaobiao)
    end

    self.name.text = data.name 
   
    self.type.text =  ""
    local str1 = mgr.TextMgr:getTextColorStr(language.xiantong26, 13)
    self.desc.text = str1 .. (data.desc or "")
end

return XiantongSkillMsgTips