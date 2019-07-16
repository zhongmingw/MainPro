--
-- Author: 
-- Date: 2018-10-31 15:02:56
--

local SkillInfoView = class("SkillInfoView", base.BaseView)

function SkillInfoView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true

end

function SkillInfoView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    self.icon = self.view:GetChild("n4")
    self.name = self.view:GetChild("n5")
    self._type = self.view:GetChild("n6")
    self.coolTime = self.view:GetChild("n8")
    --技能效果
    self.effect = self.view:GetChild("n9")
    --激活条件
    self.condition  = self.view:GetChild("n10")

end

function SkillInfoView:initData(data)
    if data then
        local skillId = data.skillId

        -- local skillConf = conf.SkillConf:getSkillByIndex(skillId)
        local skillConf = conf.SkillConf:getSkillConfByid(skillId)
        local preid = skillConf and skillConf.s_pre
        local skillCareerConf = conf.SkillConf:getSkiilCareerById(preid)
        --设置icon
        self.icon.url = ResPath.iconRes(skillCareerConf.icon)
        self.icon.grayed = data.isGrayed
        --名称
        self.name.text = skillCareerConf.name
        --类型描述
        self._type.text = skillCareerConf.etypedec
        --冷缺时间
        self.coolTime.text = tonumber(skillConf.cool_time) .."s"
        --效果描述
        local id = preid..string.format("%03d",1)
        local skillEffectConfData = conf.SkillConf:getSkillByIndex(id)
        self.effect.text = skillEffectConfData.dec
        --装备数量
        local equipData = cache.PackCache:getElementEquipData()
        local openSkill = conf.EightGatesConf:getValue("bm_skill")
        local elementDataByColor = {}
        for k,v in pairs(openSkill) do
            if not elementDataByColor[v[1]] then
                 elementDataByColor[v[1]] = {}
            end
        end
        for k,v in pairs(elementDataByColor) do
            for i,j in pairs(equipData) do
                local color = conf.ItemConf:getQuality(j.mid)
                if color >= k then
                    table.insert(elementDataByColor[k],j)
                end
            end
        end

        -- printt("elementDataByColor",elementDataByColor)
        local str = ""
        local color = 14
        local haveEle = elementDataByColor[openSkill[data.num][1]] and table.nums(elementDataByColor[openSkill[data.num][1]]) or 0
        -- print("已装备",language.gonggong110[openSkill[data.num][1]],"元素",haveEle,"个")
        local color = haveEle >= tonumber(openSkill[data.num][2]) and 7 or 14
        local textData = {
            {text = haveEle,color = color},
            {text = "/"..openSkill[data.num][2],color = 7},
        }
        str = mgr.TextMgr:getTextByTable(textData)
        self.condition.text = string.format(language.eightgates11, str,language.gonggong110[openSkill[data.num][1]])
    end
end

function SkillInfoView:setData(data_)

end

return SkillInfoView