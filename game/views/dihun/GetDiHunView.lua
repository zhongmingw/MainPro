--
-- Author: 
-- Date: 2018-11-27 21:05:11
--

local GetDiHunView = class("GetDiHunView", base.BaseView)

function GetDiHunView:ctor()
    GetDiHunView.super.ctor(self)
    self.uiLevel = UILevel.level3 

end

function GetDiHunView:initView()
    local closeBtn = self.view:GetChild("n9")
    self:setCloseBtn(closeBtn)

    self.modelPanel = self.view:GetChild("n10")

    self.nameIcon = self.view:GetChild("n2")

    self.attTxt = self.view:GetChild("n6")

    self.power = self.view:GetChild("n5")

    self.skill = self.view:GetChild("n7")
    self.skill.onClick:Add(self.onClickBtn,self)

end

function GetDiHunView:initData(data)
    local confData = conf.DiHunConf:getDiHunInfoByType(data.type)

    self.nameIcon.url = UIPackage.GetItemURL("dihun" , confData.icon)

    local  modelObj = self:addModel(confData.modle_id,self.modelPanel)
    modelObj:setScale(100)
    modelObj:setRotationXYZ(0,166,0)
    modelObj:setPosition(40,-171,113)

    self.power.text = data.power

    --设置帝魂技能
    local star = data.star == -1 and 0 or data.star +1
    local id = tonumber(data.type)*1000 + star
    self.skill.data = {id = id}

    local skillConf = conf.DiHunConf:getDhSkillById(id)
    self.skill.icon = ResPath.iconRes(skillConf.skill_icon)
    self.skill.title = skillConf.name

    local attConfData = conf.DiHunConf:getDhAttById(data.type,0,0)
    local attData = GConfDataSort(attConfData)
    local str = ""
    for k,v in pairs(attData) do
        local str1 = conf.RedPointConf:getProName(v[1])..":  "..GProPrecnt(v[1],math.floor(v[2]))
        if k ~= #attData then
            str1 = str1.."\n"
        end
        str = str..str1
    end
    self.attTxt.text = str
    
end

function GetDiHunView:onClickBtn(context)
    local btn = context.sender
    local data = btn.data
    mgr.ViewMgr:openView2(ViewName.DiHunSkillView,data)
end

return GetDiHunView