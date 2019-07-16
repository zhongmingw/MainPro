local ShengXiaoSkillInfoView = class("ShengXiaoSkillInfoView", base.BaseView)

function ShengXiaoSkillInfoView:ctor()
	self.super.ctor(self)
	self.uiClear = UICacheType.cacheTime
	self.uiLevel = UILevel.level2
end

function ShengXiaoSkillInfoView:initView()
	self.icon = self.view:GetChild("icon")
	self.name = self.view:GetChild("name")
	self.level = self.view:GetChild("level")
	self.decs = self.view:GetChild("decs")
	self.condition = self.view:GetChild("condition")

	local closeBtn = self.view:GetChild("n0"):GetChild("n2")
	closeBtn.onClick:Add(self.onClickClose, self)
end

function ShengXiaoSkillInfoView:initData(data)
	self.id = data.id
	local info = cache.ShengXiaoCache:getSxInfo(data.id)
	if nil == info then
		return
	end
	local isActive = info.skillId > 0
	local skillLv, isCanUse = conf.ShengXiaoConf:getSkillLv(info.type)
	local tempSkillId = isActive and info.skillId or data.id * 1000 + skillLv
	local skillCfg = conf.ShengXiaoConf:getSkillCfg(tempSkillId)
	if nil == skillCfg then
		return
	end
	local nextSkilLCfg = conf.ShengXiaoConf:getSkillCfg(tempSkillId + 1)
	local level = isActive and info.skillId % 1000 or skillLv

	self.condition.visible = nil ~= nextSkilLCfg
	if nil ~= nextSkilLCfg then
		local tempCondition = isCanUse and nextSkilLCfg.condition or skillCfg.condition
		local stageStr = tempCondition < 10 and language.kagee53 or language.kagee54
		tempCondition = tempCondition < 10 and tempCondition or (tempCondition - 10)

		local str = string.format(
			language.kagee45,
			tempCondition,
			stageStr,
			isCanUse and language.kagee43 or language.kagee42)

		self.condition.text = str
	end


	self.decs.text = skillCfg.ms or ""

	self.name.text = skillCfg.name

	self.level.text = "LV." .. mgr.TextMgr:getTextColorStr(level, 7)

	self.icon.url = UIPackage.GetItemURL("kagee" , skillCfg.skill_icon)
end

function ShengXiaoSkillInfoView:onClickClose()
	self:closeView()
end

return ShengXiaoSkillInfoView