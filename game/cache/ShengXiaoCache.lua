local ShengXiaoCache = class("ShengXiaoCache", base.BaseCache)

function ShengXiaoCache:init()
	self.score = 0	-- 强化积分
	self.skillMax = 0	-- 可以激活几个技能
	self.sxInfo = {}	-- 生肖信息
	self.decomposeItems = {}		-- 分解后获得
	self.chaiJieItems = {}		-- 拆解后获得

	self.baoZangInfo = {}		-- 生肖宝藏信息

	self.isNoShowBindGoldTip = false	-- 宝藏召唤绑元提示
	self.isNoShowGoldTip = false		-- 宝藏召唤元宝提示

	self.baoZangWareInfo = {}		-- 生肖宝藏仓库数据
end

function ShengXiaoCache:setSxInfo(data)
	self.skillMax = data.skillMax
	self.score = data.score
	for k, v in pairs(data.sxInfo) do
		for k2, v2 in pairs(v.partInfos) do
			v2.itemInfo.isquan = true
		end
		self.sxInfo[v.type] = v
	end
end

function ShengXiaoCache:getSxInfo(id)
	return self.sxInfo[id]
end

function ShengXiaoCache:getSxPartInfo(sxType, part)
	local allList = conf.ShengXiaoConf:getAllTypeList()
	local typeIndex = 1
	for k, v in pairs(allList) do
		if v.type == sxType then
			typeIndex = k
			break
		end
	end
	local info = self.sxInfo[allList[typeIndex].id]
	return info.partInfos[part]
end

function ShengXiaoCache:getAllSxInfo()
	return self.sxInfo
end

function ShengXiaoCache:getScore()
	return self.score
end

function ShengXiaoCache:getSkillMax()
	return self.skillMax
end

function ShengXiaoCache:updateSkillMax(skillMax)
	self.skillMax = skillMax
end

function ShengXiaoCache:updateSxPartInfo(data)
	local info = self.sxInfo[data.type]
	if nil ~= info then
		data.partInfo.itemInfo.isquan = true
		info.partInfos[data.part] = data.partInfo
	end
end

-- 更新战力
function ShengXiaoCache:updateSxPower(id, power)
	self.sxInfo[id].power = power
end

function ShengXiaoCache:updateSxInfo(sxInfo)
	for k, v in pairs(sxInfo.partInfos) do
		v.itemInfo.isquan = true
	end
	self.sxInfo[sxInfo.type] = sxInfo
end

function ShengXiaoCache:updateSxScore(score)
	self.score = score
end

function ShengXiaoCache:onDecompose(data)
	self.score = data.score
	self.decomposeItems = data.items
end

function ShengXiaoCache:onChaiJie(data)
	self.chaiJieItems = data.items
end

-- 生肖宝藏数据
function ShengXiaoCache:setBaoZangInfo(data)
	self.baoZangInfo = data
end

function ShengXiaoCache:getBaoZangInfo()
	return self.baoZangInfo
end

-- 宝藏绑元消耗提示
function ShengXiaoCache:setBindGoldTipState(value)
	self.isNoShowBindGoldTip = value
end

function ShengXiaoCache:getBindGoldTipState()
	return self.isNoShowBindGoldTip
end

-- 宝藏元宝消耗提示
function ShengXiaoCache:setGoldTipState(value)
	self.isNoShowGoldTip = value
end

function ShengXiaoCache:getGoldTipState()
	return self.isNoShowGoldTip
end

-- 宝藏仓库
function ShengXiaoCache:setBaoZangWareInfo(info)
	self.baoZangWareInfo = info
end

function ShengXiaoCache:getBaoZangWareInfo()
	return self.baoZangWareInfo
end

-- 是否显示未激活按钮
function ShengXiaoCache:isShowNoActive(id)
	local info = self.sxInfo[id]
	if nil == info then
		return
	end
	if info.state == 1 or info.skillId > 0 then
		return false
	end
	local count = 0
	for k, v in pairs(info.partInfos) do
		if v.itemInfo.mid > 0 then
			local stage = conf.ItemConf:getStagelvl(v.itemInfo.mid)
			local skillCfg = conf.ShengXiaoConf:getSkillCfg(id * 1000 + 1)
			if nil ~= skillCfg then
				if skillCfg.condition <= stage then
					count = count + 1
				end
			end
		end
	end
	return count < 4
end

-- 获取已经激活的技能数量
function ShengXiaoCache:getActiveSkillNum()
	local num = 0
	for k, v in pairs(self.sxInfo) do
		if v.state == 1 then
			num = num + 1
		end
	end
	return num
end

-- 获取生肖背包数据
function ShengXiaoCache:getPackArray(sxType)
	local list = {}
	local packList = cache.PackCache:getShengXiaoData()
	for k, v in pairs(packList) do
		local itemCfg = conf.ItemConf:getItem(v.mid)
		if itemCfg.sub_type == sxType then
			table.insert(list, v)
		end
	end
	return list
end

-- 宝藏仓库红点
function ShengXiaoCache:isShowBaoZangWareRed()
	if nil == self.baoZangWareInfo then
		return false
	end
	return self.baoZangWareInfo.itemInfos
		and #self.baoZangWareInfo.itemInfos > 0
		or false
end

-- 宝藏红点
function ShengXiaoCache:isShowBaoZangRed()
	if nil == self.baoZangInfo
	or nil == self.baoZangInfo.freeTimes then
		return false
	end
	if self.baoZangInfo.freeTimes > 0 then
		return true
	end
	local money = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)
	local bzCfg = nil
	for i = 1, 5 do
		bzCfg = conf.ShengXiaoConf:getBaoZangCfg(i)
		if nil ~= bzCfg then
			if self.baoZangInfo.stageMax >= i then
				if money >= bzCfg.copper[1][2] then
					return true
				end
			end
		end
	end
	return self:isShowBaoZangWareRed()
end

-- 生肖装备部位红点
function ShengXiaoCache:isShowShengXiaoPartRed(id, part, isNoCheckPack)
	if nil == self.sxInfo then
		return
	end
	local info = self.sxInfo[id]
	if nil == info then
		return
	end
	local typeCfg = conf.ShengXiaoConf:getTypeCfg(id)
	local packList = self:getPackArray(typeCfg.type)
	local partInfo = info.partInfos[part]
	for k, v in pairs(packList) do
		local packPart = conf.ItemConf:getPart(v.mid)
		if partInfo.itemInfo.mid <= 0 then
			if packPart == part then
				return true
			end
		elseif packPart == part and not isNoCheckPack then
			local stage1 = conf.ItemConf:getStagelvl(partInfo.itemInfo.mid)
			local stage2 = conf.ItemConf:getStagelvl(v.mid)
			if stage2 > stage1 then
				return true
			end
		end
	end
	return false
end

-- 显示技能激活按钮红点
function ShengXiaoCache:isShowSkillRed(id)
	local activeNum = self:getActiveSkillNum()
	if self.skillMax <= activeNum then
		return false
	end
	local info = self.sxInfo[id]
	if info.state == 1 or info.skillId > 0 then
		return false
	end
	return not self:isShowNoActive(id)
end

-- 生肖强化部位红点
function ShengXiaoCache:isShowSxStrengPartRed(id, part)
	if nil == self.sxInfo then
		return
	end
	local info = self.sxInfo[id]
	if nil == info then
		return
	end
	local partInfo = info.partInfos[part]
	if partInfo.itemInfo.mid <= 0 then
		return false
	end
	local strengCfg = conf.ShengXiaoConf:getStrenCfg(part, partInfo.strenLevel)
	if nil == strengCfg then
		return false
	end
	local maxLevel = conf.ShengXiaoConf:getEquipMaxStrengLv(partInfo.itemInfo.mid)
	if maxLevel <= partInfo.strenLevel then
		return false
	end
	return strengCfg.need_cost <= self.score
end

-- 当前类型所有强化信息红点
function ShengXiaoCache:isShowSxStrengRed(id)
	for i = 1, 4 do
		if self:isShowSxStrengPartRed(id, i) then
			return true
		end
	end
	return false
end

function ShengXiaoCache:isShowTypeRed(id)
	for i = 1, 4 do
		if self:isShowShengXiaoPartRed(id, i) then
			return true
		end
	end
	return self:isShowSxStrengRed(id)
		or self:isShowSkillRed(id)
end

function ShengXiaoCache:isShowSxAllRed()
	local allList = conf.ShengXiaoConf:getAllTypeList()
	for k, v in pairs(allList) do
		if self:isShowTypeRed(v.id) then
			return true
		end
	end
	return false
end

return ShengXiaoCache