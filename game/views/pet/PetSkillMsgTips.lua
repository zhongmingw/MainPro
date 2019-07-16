--
-- Author: 
-- Date: 2018-01-12 14:58:18
--

local PetSkillMsgTips = class("PetSkillMsgTips", base.BaseView)

function PetSkillMsgTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function PetSkillMsgTips:initView()
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

function PetSkillMsgTips:initData(data)
    -- body
    if type(data) == "table" then
        self.ground.x = 275
        self.ground.y = 318
        self.data = conf.PetConf:getPetSkillById(data.data)
    else
        self.data = conf.PetConf:getPetSkillById(data)
        self.ground.xy = self.oldxy
    end 

    

    self.icon.url = ResPath.iconRes(self.data.icon) 

    self.jiaobiao.visible = false
    if self.data.jiaobiao then
        self.jiaobiao.visible = true
        self.jiaobiao.url = ResPath.iconOther(self.data.jiaobiao)
    end

    self.name.text = self.data.name 
    local str = ""
    local number = #self.data.skill_type
    for k , v in pairs(self.data.skill_type) do
        str = str .. language.pet17[v]
        if k ~= number then
            str = str .. ","
        end
    end
    self.type.text =  language.pet16..str
    local str1 = mgr.TextMgr:getTextColorStr(language.pet18, 13)
    self.desc.text = str1 .. (self.data.desc or "")
end

function PetSkillMsgTips:setData(data_)

end

return PetSkillMsgTips