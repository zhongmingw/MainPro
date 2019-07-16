local ItemConf = class("ItemConf",base.BaseConf)

function ItemConf:ctor()
    self:addConf("item")
    self:addConf("equip_color_attri")--装备极品属性
    self:addConf("equip_color_global")
    ---self:addConf("item_attri")
    self:runeItems()--符文
end
--是否假显示
function ItemConf:getRealMid(id)
	local item = self:getItem(id)
	if item then
		return item.real_mid or 0
	end
	return 0
end
--装备出生星数
function ItemConf:getEquipStar(id)
	local item = self:getItem(id)
	if item then
		return item.star_count or 0
	end
	return 0
end
--是否有道具圈圈
function ItemConf:getIsQuan(id)
	local item = self:getItem(id)
	return item and item.isquan or 0
end

--获取道具自动使用类型
function ItemConf:getAutoUseType(id)
	local item = self:getItem(id)
	if item then
		return item.auto_use_type
	end
	return 1
end

--道具使用和装备穿戴等级限制
function ItemConf:getLvl(id)
	-- body
	local item = self:getItem(id)
	if item then
		return item.lvl
	end
	return 1
end

--类型
function ItemConf:getType(id)
	local item = self:getItem(id)
	if item then
		return item.type
	end
	return 1
end
--排序
function ItemConf:getSort(id)
	local item = self:getItem(id)
	if item then
		return item.sort
	end
	return 1
end
--部位：装备用到
function ItemConf:getPart(id)
	local item = self:getItem(id)
	if item then
		return item.part
	end
	return 1
end
--品质
function ItemConf:getQuality(id)
	local item = self:getItem(id)
	if item then
		return item.color or 1
	end
	return 1
end
--绑定值
function ItemConf:getBind(id)
	local item = self:getItem(id)
	if item then
		return item.bind or 1
	end
	return 1
end
--名字
function ItemConf:getName(id)
	local item = self:getItem(id)
	if item then
		return item.name
	end
	return ""
end

--说明
function ItemConf:getDescribe(id)
	local item = self:getItem(id)
	if item then
		return item.describe
	end
	return ""
end
--类型描述
function ItemConf:getTypedec(id)
	local item = self:getItem(id)
	if item then
		return item.type_dec
	end
	return ""
end
--战斗力
function ItemConf:getPower(id)
	local item = self:getItem(id)
	if item then
		return item.power
	end
	return 0
end
--皮肤
function ItemConf:getSrc(id)
	local item = self:getItem(id)
	if item then
		return item.src
	end
	return 0
end


--道具价格
function ItemConf:getBuyPrice(id)
	local item = self:getItem(id)
	if item then
		return item.buy_price or 0
	end
end
--道具路徑
function ItemConf:getFormview(id)
	local item = self:getItem(id)
	if item then
		return item.formview
	end
	return {}
end
--购买类型
function ItemConf:getBuyType(id)
	local item = self:getItem(id)
	if item then
		return item.buy_type
	end
	return 1
end

--获取道具寄售标识
function ItemConf:getItemTrade( id )
	-- body
	local item = self:getItem(id)
	if item then
		return item.trade
	end
	return 0
end

--获取道具寄售参考价
function ItemConf:getItemTradePrice( id )
	-- body
	local item = self:getItem(id)
	if item then
		return item.type_price
	end
	return 0
end
--获取道具寄售价格范围
function ItemConf:getItemTradeRange( id )
	-- body
	local item = self:getItem(id)
	if item then
		return item.trade_range
	end
	return {}
end

function ItemConf:getTabType(id)
	-- body
	local item = self:getItem(id)
	if item then
		return item.tab_type
	end
	return 2
end
--装备阶数
function ItemConf:getStagelvl(id)
	local item = self:getItem(id)
	if item then
		return item.stage_lvl or 0
	end
	return 0
end
--道具的模型
function ItemConf:getModel(id)
	local item = self:getItem(id)
	if item then
		return item.model
	end
	return 0
end

function ItemConf:getArgsType(id)
	local item = self:getItem(id)
	if item and item.args then
		return item.args.arg_type
	end
	return 0
end
--道具对应的buffid
function ItemConf:getArgsType2(id)
	local item = self:getItem(id)
	if item and item.args then
		return item.args.arg_type2
	end
	return 0
end

function ItemConf:getArgsItem(id)
	local item = self:getItem(id)
	if item and item.args then
		return item.args.s_arg1 or {}
	end
	return {}
end
--ext01
function ItemConf:getItemExt(id)
	-- body
	local item = self:getItem(id)
	if item and item.ext01 then
		return item.ext01
	end
	return 0
end

--arg3
function ItemConf:getItemArg3(id)
	local item = self:getItem(id)
	if item and item.args then
		return item.args.arg3
	end
	return 0
end

--限制时间
function ItemConf:getlimitTime(id)
	local item = self:getItem(id)
	if item then
		return item.limit_time
	end
	return 0
end
--是否可以显示使用全部按钮
function ItemConf:getIsUseAll(id)
	local item = self:getItem(id)
	if item then
		return item.is_use_all
	end
	return 0
end
--背包小类
function ItemConf:getSubType(id)
	local item = self:getItem(id)
	if item then
		return item.sub_type
	end
	return 1
end

function ItemConf:getItem(id)
	local item = self.item[id..""]
	if not item then
		self:error(id)
		return nil
	end
	return item
end
---
function ItemConf:getItemPro(id)
	-- body
	return conf.ItemArriConf:getItemAtt(id)
end

function ItemConf:getItemCome(id)
	local item = self:getItem(id)
	if item then
		return item.come_id
	end
	return 0
end

--获取红包信息
function ItemConf:getRedBagData()
	-- body
	local data = {}
	for k,v in pairs(self.item) do
		if v.type == Pack.redBagType then
			table.insert(data,v)
		end
	end
	return data
end
--获取当前红包数额
function ItemConf:getRedBagMoney(id)
	-- body
	local item = self:getItem(id)
	if item then
		return item.redbag_args[1][3]
	end
	return 0
end
--获取当前红包数量
function ItemConf:getRedBagAmount(id)
	local item = self:getItem(id)
	if item then
		return item.redbag_args[1][2]
	end
	return 0
end
--获取当前红包类型
function ItemConf:getRedBagType(id)
	local item = self:getItem(id)
	if item then
		return item.ext_type
	end
	return 0
end
--获取装备外观
function ItemConf:getEquipSkins(id)
	local item = self:getItem(id)
	if item then
		return item.skin
	end
	return {}
end
--获取仓库属性跳转
function ItemConf:getAttiModule(id)
	local item = self:getItem(id)
	if item then
		return item.atti_module
	end
end

--获取套装属性跳转
function ItemConf:getSuitModule(id)
	local item = self:getItem(id)
	if item then
		return item.suit_module
	end
	return {}
end

--获取宝石类型
function ItemConf:getGemType(id)
	local item = self:getItem(id)
	if item then
		return item.gem_type
	end
	return 0
end

function ItemConf:getFuseCount(id)
	local item = self:getItem(id)
	if item then
		return item.fuse_count
	end
	return 0
end
--装备激活技能
function ItemConf:getSkillAffectId(id)
	local item = self:getItem(id)
	if item then
		return item.skill_affect_id
	end
	return 0
end

--为了获取时装模型 （这个也用于判断是否属于时装）
function ItemConf:getSuitmodel(id)
	-- body
	local item = self:getItem(id)
	return item.suitshow

end
--获取时装的Transform属性
function ItemConf:getSuitTransformDataById(id)          --getSuitTransformDataById
	local item = self:getItem(id)
	local temp = {}
	temp[1] = item.suit_pos
	temp[2] = item.suit_rotation
	temp[3] = item.suit_scale
	return temp
end
--获取套装的id
function ItemConf:getFashionsSuitId(id)
	local item = self:getItem(id)
	return item.issuit
end
--获取时装的升星信息
function ItemConf:getFashionStarData(id)
	local item = self:getItem(id)
	return item.suit_star
end
--时装展示时候是否需要角色外观(比如展示武器时，是否需要模特)
function ItemConf:getIsNeedModel(id)
	local item = self:getItem(id)
	return item.isNeedCloth
end
function ItemConf:getIsCanFloat(id)
	local item = self:getItem(id)
	return item.canfloat
end
--是否不可以丢弃
function ItemConf:getIsNotDiscard(id)
	local item = self:getItem(id)
	local isNotDiscard = item and item.isNotDiscard or 0
	return isNotDiscard
end
--出生极品属性
function ItemConf:getBirthAtt(id)
	local item = self:getItem(id)
	return item and item.birth_att
end
--推荐极品属性
function ItemConf:getBaseBirthAtt(id)
	local item = self:getItem(id)
	return item and item.base_birth_att
end
--掉落物是否显示名字
function ItemConf:getItemDropisV(id)
	local item = self:getItem(id)
	return item and item.is_visible_name or 0
end
--极品属性
function ItemConf:getEquipColorAttri(id)
	return self.equip_color_attri[tostring(id)]
end

function ItemConf:getEquipColorGlobal(id)
	return self.equip_color_global[tostring(id)]
end

--经验丹道具描述的经验显示
function ItemConf:getItemEXPDisplay(id)
	local item = self:getItem(id)
	if item then
		return item.is_show_exp
	end
	return 0
end

--经验丹的经验数值（用于计算）
function ItemConf:getItemValueOfEXP(id)
	local item = self:getItem(id)
	if item and item.args then
		return item.args
	end
	return 0
end
--符文类型
function ItemConf:getFwType(id)
	local item = self:getItem(id)
	if item then
		return item.fw_type or 0
	end
	return 0
end

--符文类型
function ItemConf:getContainType(id)
	local item = self:getItem(id)
	if item then
		return item.contain_type or {}
	end
	return {}
end
--符文吞噬经验
function ItemConf:getPartnerExp(id)
	local item = self:getItem(id)
	if item then
		return item.partner_exp or 0
	end
	return 0
end
--源计划开箱奖励
function ItemConf:getOpenAward(id)
	local item = self:getItem(id)
	if item then
		return item.open_award or {}
	end
	return {}
end
--符文列表
function ItemConf:runeItems()
	self.runeItems = {}
	for k,v in pairs(self.item) do
		if v.type == Pack.runeType then
			table.insert(self.runeItems, v)
		end
	end
end
--根据类型获取已解锁的符文列表
function ItemConf:getRuneItemsByType(fwType,towerMaxLevel)
	local list = {}
	for k,v in pairs(self.runeItems) do
		if v.fw_type == fwType then
			local floor = v.tower_floor or 0
			if v.default or towerMaxLevel >= floor then
				table.insert(list, v)
			end
		end
	end
	table.sort(list,function(a,b)
		return a.color < b.color
	end)
	return list
end

function ItemConf:getTowerFloor(id)
	local item = self:getItem(id)
	if item then
		return item.tower_floor or 0
	end
	return 0
end
--跳转时装升星模块id
function ItemConf:getSuitStarModel(id)
	local item = self:getItem(id)
	if item then
		return item.suit_star_model
	end
end

--根据id判断是否是时装碎片
function ItemConf:getIsSuitSuiPian(id)
	local item = self:getItem(id)
	if item.type and item.type == 2 then
		if item.sub_type and item.sub_type == 15 then
			return true
		end
	end
	return false
end

--根据id判断是否是光环
function ItemConf:getIsHalo(id)
	local item = self:getItem(id)
	if item.suit_star and item.suit_star[1] == 1013 then
		return true
	end
	return false
end

--圣印列表
function ItemConf:getShengYinItems()
	self.shengYinItems = {}
	for k,v in pairs(self.item) do
		if v.type == Pack.shengYinType then
			table.insert(self.shengYinItems, v)
		end
	end
	return self.shengYinItems
end

--圣印动画
function ItemConf:getShengYinMovie(id)
	local item = self:getItem(id)
	if item then
		return item.shengyin_movie or 0
	end
	return 0
end

--神装列表
function ItemConf:getGodEquipItems()
	local data = {}
	for k,v in pairs(self.item) do
		if v.type == Pack.equipType and v.color == 7 then
			table.insert(data, v)
		end
	end
	return data
end
--神装仙装
function ItemConf:getGodXianItems()
	local data = {}
	for k,v in pairs(self.item) do
		if v.type == Pack.xianzhuang and v.color == 7 then
			table.insert(data, v)
		end
	end
	return data
end


return ItemConf