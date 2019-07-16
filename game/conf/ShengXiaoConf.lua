local ShengXiaoConf = class("ShengXiaoConf", base.BaseConf)

function ShengXiaoConf:init()
	self:addConf("shengxiao_type")	--生肖种类
    self:addConf("shengxiao_stren")	--生肖强化
    self:addConf("shengxiao_skill")	--生肖技能
    self:addConf("shengxiao_fenjie") --生肖材料分解
    self:addConf("shengxiao_global")  --生肖全局
    self:addConf("shengxiao_jinjie")  --生肖进阶
    self:addConf("shengxiao_skill_id")  --生肖技能
    self:addConf("shengxiao_jinjie_map")  --生肖进阶图鉴

    self:addConf("sxbz")  --生肖宝藏
end

function ShengXiaoConf:getTypeCfg(id)
	return self.shengxiao_type[tostring(id)]
end

local list = {}
-- 初始化类型列表，区分类型
function ShengXiaoConf:getTypeList()
	if nil == next(list) then
		local sxType = 0
		for k, v in pairs(self.shengxiao_type) do
			sxType = math.floor(v.id / 100)
			list[sxType] = list[sxType] or {}
			table.insert(list[sxType], v)
		end
		for k, v in pairs(list) do
			table.sort(v, function(a, b)
				return a.id < b.id
			end)
		end
	end
	return list
end

local allTypeList = {}
-- 不区分类型
function ShengXiaoConf:getAllTypeList()
	if nil == next(allTypeList) then
		for k, v in pairs(self.shengxiao_type) do
			table.insert(allTypeList, v)
		end
		table.sort(allTypeList, function(a, b)
			return a.id < b.id
		end)
	end
	return allTypeList
end

-- 获取强化等级配置
function ShengXiaoConf:getStrenCfg(part, level)
	local tempId = part * 1000 + level
	return self.shengxiao_stren[tostring(tempId)]
end

function ShengXiaoConf:getGlobalCfg()
	return self.shengxiao_global
end

-- 根据装备阶数获取装备的最大强化等级
function ShengXiaoConf:getEquipMaxStrengLv(itemId)
	local stage_lvl = conf.ItemConf:getStagelvl(itemId)
	stage_lvl = stage_lvl > 10 and stage_lvl - 1 or stage_lvl
	return self.shengxiao_global.sx_stren_max[stage_lvl]
			and self.shengxiao_global.sx_stren_max[stage_lvl][2]
			or 999
end

-- 获取强化总属性
function ShengXiaoConf:getAttrs(id)
	local attrs = {}
	local info = cache.ShengXiaoCache:getSxInfo(id)
	if nil == info then
		return attrs
	end

	local strenCfg = nil

	for k, v in pairs(info.partInfos) do
		strenCfg = self:getStrenCfg(k, v.strenLevel)
		if nil ~= strenCfg then
			for k2, v2 in pairs(strenCfg) do
				if nil ~= string.find(k2, "att_") then
					attrs[k2] = attrs[k2] or 0
					attrs[k2] = attrs[k2] + v2
				end
			end
		end
		if v.itemInfo.mid > 0 then
			local attiData = conf.ItemArriConf:getItemAtt(v.itemInfo.mid)
			local baseAttrs = GConfDataSort(attiData)

			for k3, v3 in pairs(baseAttrs) do
				if not self:isSpecialAttr(k3) then
					attrs["att_" .. v3[1]] = attrs["att_" .. v3[1]] or 0
					attrs["att_" .. v3[1]] = attrs["att_" .. v3[1]] + v3[2]
				end
			end
		end
	end
	return attrs
end

-- 是否是特殊属性
function ShengXiaoConf:isSpecialAttr(id)
	for k, v in pairs(self.shengxiao_global.speicalAttrs) do
		if v == id then
			return true
		end
	end
end

-- 极品属性
function ShengXiaoConf:getBestAttrs(id, value)
	local attiData = conf.ItemConf:getEquipColorAttri(id)
    local color = attiData and attiData.color or 1
    local attType = attiData and attiData.att_type or 0
    local name = conf.RedPointConf:getProName(attType)
    local maxColor = conf.ItemConf:getEquipColorGlobal("max_color")
    local attiRange = attiData.att_range or {}
    value = value or (attiRange[#attiRange] and attiRange[#attiRange][2])
    local attiValue = "+" .. GProPrecnt(attType, value)
    -- if color >= maxColor then--是否是最高品质
        -- local attiRange = attiData.att_range or {}
        -- local maxValue = attiRange[#attiRange] and attiRange[#attiRange][2]
        -- if maxValue and value >= maxValue then
        --     attiValue = attiValue .. language.pack41--获得了最佳的极品属性
        -- end
    -- end
    -- local str = name .. attiValue
    -- return mgr.TextMgr:getQualityAtti(str, color)
    return name, attiValue, value
end

-- 根据装备阶数拿进阶配置
function ShengXiaoConf:getJinJieCost(grade)
	for k, v in pairs(self.shengxiao_jinjie) do
		if v.level == grade then
			return v
		end
	end
end

function ShengXiaoConf:getAllSpecialAttrs()
	local infos = cache.ShengXiaoCache:getAllSxInfo()
	local attrs = {}
	for k, v in pairs(infos) do
		for k2, v2 in pairs(v.partInfos) do
			if v2.itemInfo.mid > 0 then
				local attiData = conf.ItemArriConf:getItemAtt(v2.itemInfo.mid)
				local baseAttrs = GConfDataSort(attiData)
				for k3, v3 in pairs(baseAttrs) do
					if self:isSpecialAttr(v3[1]) then
						attrs["att_" .. v3[1]] = attrs["att_" .. v3[1]] or 0
						attrs["att_" .. v3[1]] = attrs["att_" .. v3[1]] + v3[2]
					end
				end
			end
		end
	end
	return attrs
end

-- 获取技能信息配置
function ShengXiaoConf:getSkillCfg(skillId)
	return self.shengxiao_skill_id[tostring(skillId)]
end

-- 获取技能扩展配置
function ShengXiaoConf:getSKillExtendCfg(level)
	return self.shengxiao_skill[tostring(level)]
end

-- 获取分解配置
function ShengXiaoConf:getDecomposeCfg(id)
	return self.shengxiao_fenjie[tostring(id)]
end

-- 获取进阶配置
function ShengXiaoConf:getJinJieMapCfg(id)
	return self.shengxiao_jinjie_map[tostring(id)]
end

-- 生肖宝藏配置
function ShengXiaoConf:getBaoZangCfg(id)
	return self.sxbz[tostring(id)]
end

function ShengXiaoConf:getSkillLv(id)
	local info = cache.ShengXiaoCache:getSxInfo(id)
	local list = {}
	for k, v in pairs(info.partInfos) do
		if v.itemInfo.mid <= 0 then
			return 1, false
		else
			local stage_lvl = conf.ItemConf:getStagelvl(v.itemInfo.mid)
			local level = 1
			local skilLCfg = self:getSkillCfg(id * 1000 + level)
			list[level] = list[level] or 0
			while(nil ~= skilLCfg) do
				if skilLCfg.condition <= stage_lvl then
					list[level] = list[level] + 1
				end
				level = level + 1
				list[level] = list[level] or 0
				skilLCfg = self:getSkillCfg(id * 1000 + level)
			end
		end
	end
	for i = #list, 1, -1 do
		if list[i] >= 4 then
			return i, true
		end
	end
	return 1, false
end

return ShengXiaoConf