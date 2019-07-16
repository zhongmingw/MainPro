--背包缓存
local PackCache = class("PackCache",base.BaseCache)

local divisor = 100000
local wareIndex = Pack.ware--仓库item
local packIndex = Pack.pack--背包信息
local equipIndex = Pack.equip--已穿戴的装备
local limitIndex = Pack.limit--临时背包
local shengZhuangEquip = Pack.shengZhuangEquip
local shengZhuangPack = Pack.shengZhuangPack
function PackCache:init()
	self.packData = {
		[wareIndex] = {},--仓库item
		[packIndex] = {},--背包信息
		[equipIndex] = {},--已穿戴的装备
		[limitIndex] = {},--临时背包
		-- [equipawaken] = {},--剑神已穿戴的装备
		[Pack.JianLing] = {},--剑神已穿戴的装备
		[Pack.equipxian] = {},--现状
		[Pack.shengYinPack] = {},--圣印背包
		[Pack.shengYinEquip] = {},--已装备圣印
		[Pack.shengZhuangPack] = {},--圣装背包
		[Pack.shengZhuangEquip] = {}, -- 圣装装备
		[Pack.elementPack] = {}, -- 元素背包
		[Pack.elementEquip] = {}, -- 装备元素
		[Pack.dihun] = {}, -- 帝魂背包
		[Pack.shengXiao] = {}, -- 生肖背包
	}
	self.packAtti = {}--背包部分属性，比如格子已开启数量和时间
	self.forgingData = {}--锻造十个部位缓存
	self.advPros = {}--进阶丹道具
	self.sPros = {}--资质丹、潜力丹道具
	self.dropRoleId = 1--掉落物的roleId
	self.notAdvancedTip = {}
	self.suitAwakens = {}--套装锻造数据
	self.rareEquipData = {}--稀有装备
end

function PackCache:setGridKeyData(k,v)
	self.packAtti[k] = v
end

function PackCache:getGridKeyData(k)
	return self.packAtti[k] or 0
end

--设置背包数据
function PackCache:setPackData(items)
	-- print("设置背包~~~~~~~~~~~~~~~~~~~~~~")
	for k,v in pairs(items) do
		local iType = math.floor(v.index / divisor) * divisor
		-- print("背包Type~~~~~~~~~~~",iType)
		if iType == wareIndex then--仓库
			self.packData[wareIndex][v.index] = v
		elseif iType == packIndex then--背包
			self.packData[packIndex][v.index] = v
		elseif iType == equipIndex then--已穿戴的装备
			self.packData[equipIndex][v.index] = v
		elseif iType == limitIndex then--临时背包
			self.packData[limitIndex][v.index] = v
		-- elseif iType == equipawaken then--剑神已经已穿戴的装备
		-- 	self.packData[equipawaken][v.index] = v
		elseif iType == Pack.JianLing then
			--五行
			self.packData[Pack.JianLing][v.index] = v
		elseif iType == Pack.equipxian then--已穿戴的仙
			self.packData[Pack.equipxian][v.index] = v
		elseif iType == Pack.shengYinPack then--圣印背包
			self.packData[Pack.shengYinPack][v.index] = v
		elseif iType == Pack.shengYinEquip then--已装备圣印
			self.packData[Pack.shengYinEquip][v.index] = v
		elseif iType == Pack.shengZhuangPack then--圣装装备背包
			self.packData[Pack.shengZhuangPack][v.index] = v
		elseif iType == Pack.shengZhuangEquip then--已装备圣装装备
			self.packData[Pack.shengZhuangEquip][v.index] = v
		elseif iType == Pack.elementPack then--元素背包
			self.packData[Pack.elementPack][v.index] = v
		elseif iType == Pack.elementEquip then--已装备元素
			self.packData[Pack.elementEquip][v.index] = v
		elseif iType == Pack.dihun then--帝魂
			self.packData[Pack.dihun][v.index] = v
		elseif iType == Pack.shengXiao then--生肖
			self.packData[Pack.shengXiao][v.index] = v
		end
	end
	--根据类型设置元素背包
	self:setEleByType()
end

--获取仓库数据
function PackCache:getWareData(isPage)
	local data = self.packData[wareIndex]
	table.sort(data,function(a,b)
		local asort = conf.ItemConf:getSort(a.mid)
		local bsort = conf.ItemConf:getSort(b.mid)
		if asort == bsort then
			return a.mid < b.mid
		else
			return asort < bsort
		end
	end)
	if isPage then
		return self:getTabData(data)--分页的数据
	end
	return data
end
--获取items，除了临时背包和仓库
function PackCache:getItems()
	local items = {}
	-- for index,data in pairs(self.packData) do
	-- 	if index == packIndex or index == equipIndex then
	-- 		for k,v in pairs(data) do
	-- 			table.insert(items, v)
	-- 		end
	-- 	end
	-- end
	for k,v in pairs(self.packData[equipIndex]) do
		table.insert(items, v)
	end
	for k,v in pairs(self.packData[packIndex]) do
		table.insert(items, v)
	end
	-- table.sort(items,function(a,b)
	-- 	return a.index < b.index
	-- end)
	return items
end

--获取背包所有item
function PackCache:getPackData()
	local data = self.packData[packIndex]
	return data
end
--获取背包所有圣装item
function PackCache:getShengZhuangPackData()
	local data = self.packData[shengZhuangPack]
	return data
end

--根据index获取圣装背包的道具
function PackCache:getShengZhuangPackDataByIndex(index)
	return self.packData[shengZhuangPack] and self.packData[shengZhuangPack][index]
end

--获取消耗品道具信息
function PackCache:getPackProsData(isPage)
	local iType = {Pack.prosType,Pack.gemType}--道具大类型（消耗道具，宝石）
	local data = self:getPackDataByType(iType)
	-- printt(data)
	if isPage then
		return self:getTabData(data)--返回分页的数据
	end
	return data
end
--获取背包的装备信息
function PackCache:getPackEquipData(isPage)
	local iType = Pack.equipType--装备大类型
	local data = self:getPackDataByType(iType)
	if isPage then
		return self:getTabData(data)--返回分页的数据
	end
	return data
end
--获取背包的仙装信息
function PackCache:getPacXiankEquipData( isPage )
	-- bod
	local iType = Pack.xianzhuang--装备大类型
	local data = self:getPackDataByType(iType)
	if isPage then
		return self:getTabData(data)--返回分页的数据
	end
	return data
end

--获取背包的剑神装备装备信息
function PackCache:getPackAwakenEquipData(isPage)
	local iType = Pack.equipawkenType--装备大类型
	local data = self:getPackDataByType(iType)
	if isPage then
		return self:getTabData(data)--返回分页的数据
	end
	return data
end

--获取背包宝石信息
function PackCache:getPackGemData(isPage)
	local iType = Pack.gemType--宝石大类型
	local data = self:getPackDataByType(iType)
	if isPage then
		return self:getTabData(data)--返回分页的数据
	end
	return data
end
--获取可分解的道具
function PackCache:getSplitPros(isPage)
	local data = {}
	for k,item in pairs(self:getPackData()) do
		local confData = conf.ForgingConf:getEquipSplit(item.mid)
		if confData then
			table.insert(data, item)
		end
	end
	table.sort(data,function(a,b)
		return a.index < b.index
	end)
	if isPage then
		return self:getTabData(data)--返回分页的数据
	end
	return data
end
--根据类型提取背包数据
function PackCache:getPackDataByType(iType)
	local data = {}
	if type(iType) == "table" then--如果是数组
		for _,v in pairs(iType) do
			for k,item in pairs(self:getPackData()) do
				local type = conf.ItemConf:getType(item.mid)
				if type == v then
					table.insert(data, item)
				end
			end
		end
	else
		for k,item in pairs(self:getPackData()) do
			local type = conf.ItemConf:getType(item.mid)
			if type == iType then
				table.insert(data, item)
			end
		end
	end
	if type(iType) ~= "table" and iType == Pack.equipType then--装备排序
		table.sort(data,function(a,b)
			local astageLvl = conf.ItemConf:getStagelvl(a.mid)
			local bstageLvl = conf.ItemConf:getStagelvl(b.mid)
			local asort = conf.ItemConf:getSort(a.mid)
			local bsort = conf.ItemConf:getSort(b.mid)
			if astageLvl == bstageLvl then
				if asort == bsort then
					return a.mid < b.mid
				else
					return asort > bsort
				end
			else
				return astageLvl > bstageLvl
			end
		end)
	elseif type(iType) ~= "table" and iType == Pack.equippetType then--宠物装备排序
		table.sort(data,function(a,b)
			local aconf = conf.ItemConf:getItem(a.mid)
			local bconf = conf.ItemConf:getItem(b.mid)

			if aconf.color ~= bconf.color then
				return aconf.color > bconf.color
			else
				local astart = mgr.ItemMgr:getColorBNum(a)
				local bstart = mgr.ItemMgr:getColorBNum(b)
				if astart ~= bstart then
					return astart > bstart
				else
					return a.mid < b.mid
				end
			end
		end)
	elseif type(iType) ~= "table" and iType == Pack.shenshouEquipType then--神兽装备排序
		table.sort(data,function(a,b)
			local aconf = conf.ItemConf:getItem(a.mid)
			local bconf = conf.ItemConf:getItem(b.mid)

			if aconf.color ~= bconf.color then
				return aconf.color > bconf.color
			else
				local astart = mgr.ItemMgr:getColorBNum(a)
				local bstart = mgr.ItemMgr:getColorBNum(b)
				if astart ~= bstart then
					return astart > bstart
				else
					return a.mid < b.mid
				end
			end
		end)
	else--其他道具排序
		table.sort(data,function(a,b)
			local asort = conf.ItemConf:getSort(a.mid)
			local bsort = conf.ItemConf:getSort(b.mid)
			if asort == bsort then
				return a.mid < b.mid
			else
				return asort < bsort
			end
		end)
	end
	return data
end
--给数据分页
function PackCache:getTabData(data)
	local iconNum = Pack.iconNum--每一页的道具数量
	local pageIndex = 1
	local pageData = {}
	for k,v in pairs(data) do
		if pageData[pageIndex] then
			if table.nums(pageData[pageIndex]) >= iconNum then--如果当前页已经存满16个道具
				pageIndex = pageIndex + 1
				pageData[pageIndex] = {}
			end
			table.insert(pageData[pageIndex], v)
		else
			pageData[pageIndex] = {}
			table.insert(pageData[pageIndex], v)
		end
	end
	return pageData
end
--返回已装备的信息
function PackCache:getEquipData()
	return self.packData[equipIndex]
end
--根据index获取已穿戴装备
function PackCache:getEquipByIndex(index)
	local data = self.packData[equipIndex] and self.packData[equipIndex][index]
	return data
end

--返回已装备的仙信息
function PackCache:getXianEquipData()
	return self.packData[Pack.equipxian]
end
--根据index获取已穿戴仙装备
function PackCache:getXianEquipByIndex(index)
	local data = self.packData[Pack.equipxian] and self.packData[Pack.equipxian][index]
	return data
end

--返回剑神已装备的信息
-- function PackCache:getAwakenEquipData()
-- 	return self.packData[equipawaken]
-- end

--返回五行装备的信息
function PackCache:getJianLingquipData()
	return self.packData[Pack.JianLing]
end

--返回圣裝背包的信息
function PackCache:getShenZhuangData()
	return self.packData[Pack.shengZhuangPack]
end

--返回圣裝背包裡面碎片的數量
function PackCache:getShenZhuangDebrisNum(id)
	--print(id,"getShenZhuangDebrisNum")
	local data = {mid = id, index = 0, amount = 0, bind = 0,colorAttris = {}}
	for k,v in pairs (self.packData[Pack.shengZhuangPack]) do

		if tonumber(v.mid) == tonumber(id) then
		   -- data = {mid = v.id,  amount = v.amount}
		    --print("data.amount",data.amount)
		    data.amount = data.amount + v.amount
		else
			--print("該圣裝背包沒有此碎片id")
		end
	end

	return data
end

--返回圣印背包的信息
function PackCache:getShengYinData()
	return self.packData[Pack.shengYinPack]

end
function PackCache:getShengYinDataById()

end
--不重叠
function PackCache:getShengYinDiffById(id)
	-- body
	local _t = {}
	for k ,v in pairs(self:getShengYinData()) do
		if v.mid == id then
			table.insert(_t,v)
		end
	end
	return _t
end

function PackCache:getShengYinById(id)
	local data = {mid = id, index = 0, amount = 0, bind = 0,colorAttris = {}}
	for k ,v in pairs(self:getShengYinData()) do
		if v.mid == id then
			data.amount = data.amount + 1
		end
	end
	return data
end
function PackCache:getShengZhuangById(id)
	local data = {mid = id, index = 0, amount = 0, bind = 0,colorAttris = {}}
	for k ,v in pairs(self:getShenZhuangData()) do
		if v.mid == id then
			data.amount = data.amount + 1
		end
	end
	return data
end

--根据index获取圣印背包装备
function PackCache:getShengYinDataByIndex(index)
	return self.packData[Pack.shengYinPack] and self.packData[Pack.shengYinPack][index]
end

--根据index获取圣装背包装备
function PackCache:getShengZhuangDataByIndex(index)

	return self.packData[Pack.shengZhuangPack] and self.packData[Pack.shengZhuangPack][index]
end

--返回已装备圣印的信息
function PackCache:getShengYinEquipData()
	return self.packData[Pack.shengYinEquip]
end

--返回已装备圣装的信息
function PackCache:getShengZhuangEquipData()

	return self.packData[Pack.shengZhuangEquip]
end
-- --更新已裝備圣裝的信息
-- function PackCache:updateShengZhuangEquipData(data)
-- 	 self.packData[Pack.shengZhuangEquip]
-- end

function PackCache:getAwakenEquipDataByPart(part)
	-- body
	local data = self:getAwakenEquipData()
	if not data then
		return nil
	end
	for k ,v in pairs(data) do
		if conf.ItemConf:getPart(v.mid) == part then
			return v
		end
	end
	return nil
end

--返回剑神 根据index获取已穿戴装备
-- function PackCache:getAwakenEquipByIndex(index)
-- 	local data = self.packData[equipawaken] and self.packData[equipawaken][index]
-- 	return data
-- end

--返回临时背包数据
function PackCache:getLimitPackData()
	return self.packData[limitIndex]
end
function PackCache:clearLimitPackData()
	self.packData[limitIndex] = {}
end

function PackCache:getLimitDataById(id)
	local data = {mid = id, index = 0, amount = 0}
	local iType = conf.ItemConf:getType(id)
	local moneyType = MoneyPro[id]
	if moneyType then
		data = {mid = id, index = 0, amount = cache.PlayerCache:getTypeMoney(moneyType)}
		return data
	end
	local proData = {}
	local count = 0
	local limitPackData = self:getLimitPackData()
	for k,v in pairs(limitPackData) do
		if v.mid == id then
			if iType == Pack.equipType then
				count = count + 1
				data.index = v.index
				data.bind = v.bind
				data.mid = v.mid
				data.amount = count
			else
				table.insert(proData, v)
			end
		end
	end

	if iType ~= Pack.equipType then
		local index = 0
		local amount = 0
		for k,v in pairs(proData) do
			amount = v.amount + amount
			index = v.index
		end
		data = {mid = id, index = index, amount = amount}
	end
	return data
end
--修改数据
function PackCache:updatePackData(itemSeq,changeItems)
	for k,v in pairs(changeItems) do
		self.packData[itemSeq][v.index] = v--添加或者改变
	end
	for k,v in pairs(self.packData[itemSeq]) do
		if v.amount <= 0 then--删除
			self.packData[itemSeq][v.index] = nil
		end
	end
end

--更新圣印背包
function PackCache:updateShengYinPackData(changeItems)
	for k,v in pairs(changeItems) do
		self.packData[Pack.shengYinPack][v.index] = v--添加或者改变
	end
	for k,v in pairs(self.packData[Pack.shengYinPack]) do
		if v.amount <= 0 then--删除
			self.packData[Pack.shengYinPack][v.index] = nil
		end
	end
end

--更新圣装背包
function PackCache:updateShengZhuangPackData(changeItems)
	for k,v in pairs(changeItems) do
		self.packData[Pack.shengZhuangPack][v.index] = v--添加或者改变
	end
	for k,v in pairs(self.packData[Pack.shengZhuangPack]) do
		if v.amount <= 0 then--删除
			self.packData[Pack.shengZhuangPack][v.index] = nil
		end
	end
end

--更新圣装背包
function PackCache:updateShengXiaoPackData(changeItems)
	for k,v in pairs(changeItems) do
		self.packData[Pack.shengXiao][v.index] = v--添加或者改变
	end
	for k,v in pairs(self.packData[Pack.shengXiao]) do
		if v.amount <= 0 then--删除
			self.packData[Pack.shengXiao][v.index] = nil
		end
	end
end

--更新圣装装备
function PackCache:updateShengZhuangEquipData(changeItems)

	for k,v in pairs(changeItems) do
		self.packData[Pack.shengZhuangEquip][v.index] = v--添加或者改变
	end
	for k,v in pairs(self.packData[Pack.shengZhuangEquip]) do
		if v.amount <= 0 then--删除
			self.packData[Pack.shengZhuangEquip][v.index] = nil
		end
	end
end

--找出所有mid 相同的道具而且数量不叠加
function PackCache:getPackDataByIdnotDieJia(id)
	-- body
	local _t = {}
	for k ,v in pairs(self:getPackData()) do
		if v.mid == id then
			table.insert(_t,v)
		end
	end
	return _t
end

--根据id寻找背包道具 isCount--是否要获取道具的总数，一般只有装备和坐骑用到,isBind优先取绑定的
function PackCache:getPackDataById(id,isCount,isBind)
	local data = {mid = id, index = 0, amount = 0, bind = 0,colorAttris = {}}
	local iType = conf.ItemConf:getType(id)
	local moneyType = MoneyPro[id]
	if moneyType then
		data = {mid = id, index = 0, amount = cache.PlayerCache:getTypeMoney(moneyType), bind = 0}
		return data
	end
	local proData = {}
	local count = 0
	for k,v in pairs(self:getPackData()) do
		if v.mid == id then
			if iType == Pack.equipType then
				count = count + 1
				data.index = v.index
				data.bind = v.bind
				data.mid = v.mid
				data.amount = count
				data.colorAttris = v.colorAttris
			else
				table.insert(proData, v)
			end
		end
	end

	if iType == Pack.equipType then
		local part = conf.ItemConf:getPart(id)
		local equip = self:getEquipDataByPart(part)--寻找同部位的装备
		if equip and equip.mid == id then
			data.amount = data.amount + 1
			data.bind = equip.bind
			data.colorAttris = equip.colorAttris
		end
	else
		local index = 0
		local amount = 0
		local bind = 0
		local colorAttris = nil
		for k,v in pairs(proData) do
			amount = v.amount + amount
			index = v.index
			bind = v.bind
			colorAttris = v.colorAttris
			if v.bind == 1 and isBind then
				return {mid = v.mid, index = v.index, amount = v.amount,bind = v.bind,colorAttris = colorAttris}
			end
		end
		data = {mid = id, index = index, amount = amount,bind = bind,colorAttris = colorAttris}
	end
	--返回圣装
	if iType == Pack.equipawkenType then
		return self:getShenZhuangDebrisNum(id)
	end
	return data
end
--时间还没有超过限制时间的道具
function PackCache:getPackDataByIdLimitTime(id)
	-- body
	local data = {mid = id, index = 0, amount = 0, bind = 0}
	local iType = conf.ItemConf:getType(id)
	local limitTime = conf.ItemConf:getlimitTime(id)
	--plog("limitTime",limitTime)
	if iType ~= Pack.prosType then
		return 0
	end

	local amount = 0
	for  k , v in pairs(self:getPackData()) do
		if tonumber(v.mid) == tonumber(id) then
			if limitTime then
				--检测是否超时
				local var = mgr.NetMgr:getServerTime() - (v.propMap[attConst.packAging] or 0)
				if var < limitTime then
					amount = amount + v.amount
				end
			else
				amount = amount + v.amount
			end
		end
	end

	return amount
end

function PackCache:checkisGao7(v)
	-- body
	if v == PackMid.zuoqi1 or v == PackMid.zuoqi2
		or v == PackMid.xianyu1 or v == PackMid.xianyu2
		or v == PackMid.shengbing1 or v == PackMid.shengbing2
		or v ==PackMid.xianqi1 or v == PackMid.xianqi2
		or v == PackMid.fabao1 or v == PackMid.fabao2
		or v == PackMid.lingyu1 or v == PackMid.lingyu2
		or v == PackMid.lingbing1 or v == PackMid.lingbing2
		or v == PackMid.lingqi1 or v == PackMid.lingqi2
		or v == PackMid.lingbao1 or v == PackMid.lingbao2
		or v == PackMid.qlb1 then
			return true
		end

	return false
end

function PackCache:checkisGao10(v)
	-- body
	if v == PackMid.zuoqi3
		or v == PackMid.xianyu3
		or v == PackMid.shengbing3
		or v ==PackMid.xianqi3
		or v == PackMid.fabao3
		or v == PackMid.lingyu3
		or v == PackMid.lingbing3
		or v == PackMid.lingqi3
		or v == PackMid.lingbao3
		or v == PackMid.qlb2 then
			return true
		end

	return false
end

function PackCache:checkIs7(v)
	-- body
	local need = 7
	if v == PackMid.zuoqi1 or v == PackMid.zuoqi2 then
		return  cache.PlayerCache:getDataJie(1001) >= need , 1001
	elseif v == PackMid.xianyu1 or v == PackMid.xianyu2 then
		return  cache.PlayerCache:getDataJie(1002) >= need , 1002
	elseif v == PackMid.shengbing1 or v == PackMid.shengbing2 then
		return cache.PlayerCache:getDataJie(1003) >= need , 1003
	elseif v == PackMid.xianqi1 or v == PackMid.xianqi2 then
		return cache.PlayerCache:getDataJie(1004) >= need ,1004
	elseif v == PackMid.fabao1 or v == PackMid.fabao2 then
		return cache.PlayerCache:getDataJie(1005) >= need ,1005
	elseif v == PackMid.lingyu1 or v == PackMid.lingyu2 then
		return cache.PlayerCache:getDataJie(1007) >= need ,1007
	elseif v == PackMid.lingbing1 or v == PackMid.lingbing2 then
		return cache.PlayerCache:getDataJie(1008) >= need ,1008
	elseif v == PackMid.lingqi1 or v == PackMid.lingqi2 then
		return cache.PlayerCache:getDataJie(1009) >= need ,1009
	elseif v == PackMid.lingbao1 or v == PackMid.lingbao2 then
		return cache.PlayerCache:getDataJie(1010) >= need ,1010
	elseif v == PackMid.qlb1  then
		return cache.PlayerCache:getDataJie(1287) >= need ,1287
	end
	return false
end

function PackCache:checkIs10(v)
	-- body
	local need = 10
	if v == PackMid.zuoqi3 then
		return  cache.PlayerCache:getDataJie(1001) >= need , 1001
	elseif v == PackMid.xianyu3 then
		return  cache.PlayerCache:getDataJie(1002) >= need , 1002
	elseif v == PackMid.shengbing3 then
		return cache.PlayerCache:getDataJie(1003) >= need , 1003
	elseif v == PackMid.xianqi3 then
		return cache.PlayerCache:getDataJie(1004) >= need ,1004
	elseif v == PackMid.fabao3 then
		return cache.PlayerCache:getDataJie(1005) >= need ,1005
	elseif v == PackMid.lingyu3 then
		return cache.PlayerCache:getDataJie(1007) >= need ,1007
	elseif v == PackMid.lingbing3 then
		return cache.PlayerCache:getDataJie(1008) >= need ,1008
	elseif v == PackMid.lingqi3 then
		return cache.PlayerCache:getDataJie(1009) >= need ,1009
	elseif v == PackMid.lingbao3 then
		return cache.PlayerCache:getDataJie(1010) >= need ,1010
	elseif v == PackMid.qlb2 then
		return cache.PlayerCache:getDataJie(1287) >= need ,1287
	end
	return false
end

function PackCache:getLinkCost(mid)
	-- body
	local condata = conf.ItemConf:getItem(mid)
	if not condata then
		return 0
	end
	local count = 0

	if not condata.link_items then
		count = self:getPackDataById(mid).amount
	else
		for k ,v in pairs(condata.link_items) do
			local flag = false
			if self:checkisGao7(v) then
				flag = self:checkIs7(v)
			elseif self:checkisGao10(v) then
				flag = self:checkIs10(v)
			else
				flag = true
			end
			if flag then
				count = count + self:getPackDataByIdLimitTime(v)
			end
		end
	end

	return count
end
--根据index获取背包的道具
function PackCache:getPackDataByIndex(index)
	-- for k,v in pairs(self:getPackData()) do
	-- 	if v.index == index then
	-- 		return v
	-- 	end
	-- end
	return self.packData[packIndex] and self.packData[packIndex][index]
end

--根据id寻找已穿戴的装备 一般只有装备和坐骑用到
function PackCache:getEquipDataById(id)
	local data = {mid = id, index = 0, amount = 0}
	for k,v in pairs(self:getEquipData()) do
		if v.mid == id then
			data = v
			break
		end
	end
	return data
end
--根据part寻找已穿戴的装备 一般只有装备和坐骑用到
function PackCache:getEquipDataByPart(part)
	local index = Pack.equip + part
	local data = self.packData[equipIndex] and self.packData[equipIndex][index]
	return data
end
--根据part寻找已穿戴的装备 一般只有装备和坐骑用到
function PackCache:getXianEquipDataByPart(part)
	local index = Pack.equipxian + part
	local data = self.packData[Pack.equipxian] and self.packData[Pack.equipxian][index]
	return data
end
--根据part寻找已穿戴的装备 一般只有装备和坐骑用到
function PackCache:getShengYinEquipDataByPart(part)
	local index = Pack.shengYinEquip + part
	local data = self.packData[Pack.shengYinEquip] and self.packData[Pack.shengYinEquip][index]
	return data
end

--根据part寻找已穿戴的装备 一般只有装备和坐骑用到
function PackCache:getShengZhuangEquipDataByPart(part)
	local index = Pack.shengZhuangEquip + part
	local data = self.packData[Pack.shengZhuangEquip] and self.packData[Pack.shengZhuangEquip][index]
	return data
end


--清理背包
function PackCache:cleanPack(itemIndex)
	self.packData[itemIndex] = nil
	self.packData[itemIndex] = {}
end

--更新锻造信息
function PackCache:updataForg(data)
	--更新所有部位
	if data.part == 0 then--先清理缓存
		self.forgingData = nil
		self.forgingData = {}
		for k,v in pairs(data.partInfos) do
			self.forgingData[k] = v
		end
	else--更新单个部位
		local isUpdate = false
		for _,v in pairs(data.partInfos) do
			for k,data in pairs(self.forgingData) do
				if v.part == data.part then
					self.forgingData[k] = v
					isUpdate = true
					break
				end
			end
		end
		if not isUpdate then
			table.insert(self.forgingData, data.partInfos[1])
		end
	end

end
--更新升星
function PackCache:updataStar(data)
	for k,v in pairs(self.forgingData) do
		if v.part == data.part then
			self.forgingData[k] = data
			break
		end
	end
end
--更新宝石
function PackCache:updataCamo(data)
	for k,v in pairs(self.forgingData) do
		if v.part == data.part then
			self.forgingData[k] = data
			break
		end
	end
end
--返回锻造数据
function PackCache:getForgData(part)
	if part then
		for k,v in pairs(self.forgingData) do
			if v.part == part then
				return v
			end
		end
	else
		return self.forgingData
	end
end
--判断有多少部位达到了该星级
function PackCache:getNumbyStar(star)
	local starLv = 0
	for k,v in pairs(self.forgingData) do
		starLv = starLv + v.starLev
	end
	return starLv
end
--判断有多少部位达到了该宝石数量
function PackCache:getNumbyGem(gem_cons)
	local count = 0
	for k,v in pairs(self.forgingData) do
		for _,id in pairs(v.gemMap) do
			if id > 0 then
				local lv = tonumber(string.sub(id, 8, 9))
				if lv >= gem_cons[2] then
					count = count + 1
				end
			end
		end
	end
	return count
end
--结算宝石总等级
function PackCache:getAllGemlv()
	local lvl = 0
	for k,v in pairs(self.forgingData) do
		for _,id in pairs(v.gemMap) do
			if id > 0 then
				lvl = lvl + tonumber(string.sub(id, 8, 9))
			end
		end
	end
	return lvl
end
--当前部位宝石总战斗力
function PackCache:getCameoPower(part)
	local power = 0
	for k,v in pairs(self.forgingData) do
		if v.part == part then
			for _,id in pairs(v.gemMap) do
				if id > 0 then
					local attiPower = conf.ItemConf:getPower(id)or 0
					power = power + attiPower
				end
			end
		end
	end
	return power
end
--判断是否有即将过期的道具
function PackCache:getOverdueProp()
	local lists = {}
	for k,v in pairs(self:getPackData()) do
		local propTime = v.propMap and v.propMap[attConst.packAging]
		if propTime then
			local limitTime = conf.ItemConf:getlimitTime(v.mid) or 0
			local time = limitTime + propTime - mgr.NetMgr:getServerTime()
			if limitTime > 0 then
				plog(limitTime,propTime,mgr.NetMgr:getServerTime(),time)
			end
			if time >= 0 and time <= 21600 and limitTime > 0 then
				local data = clone(v)
				table.insert(lists, data)
			end
		end
	end
	return lists
end

function PackCache:setPackOverdue(isFind)
	self.isFindOverdue = isFind
end

function PackCache:getPackOverdue()
	return self.isFindOverdue
end
--是否强化
function PackCache:setIsStreng(isStreng)
	self.isStreng = isStreng
end
--
function PackCache:getIsStreng()
	return self.isStreng
end
--是否升星
function PackCache:setIsStar(isStar)
	self.isStar = isStar
end
--
function PackCache:getIsStar()
	return self.isStar
end
--进阶丹提示时间缓存
function PackCache:setAdvTipTime()
	self.advTipTime = mgr.NetMgr:getServerTime()
end

function PackCache:getAdvTipTime()
	return self.advTipTime or mgr.NetMgr:getServerTime()
end
--进阶丹道具缓存
function PackCache:setAdvPros(data)
	if not data then return end
	local isFind = false
	for k,v in pairs(self.advPros) do
		if data.modelId then
			if v.modelId and v.modelId == data.modelId then
				isFind = true
				break
			end
		else
			if v and v.mid and data and data.mid then
				local tabType1 = conf.ItemConf:getTabType(v.mid)
				local tabType2 = conf.ItemConf:getTabType(data.mid)
		        if tabType1 and tabType2 and type(tabType1) ~= "number" and type(tabType2) ~= "number" and tabType1[1] == tabType2[1] then
		            isFind = true
		            break
		        end
	    	end
		end
	end
	if not isFind then --没有找到相同的就添加
		table.insert(self.advPros, data)
	end
end

function PackCache:cleanAdvPros(one)
	if one then
		if #self.advPros > 0 then
			table.remove(self.advPros,1)
		end
	else
		self.advPros = {}
	end
end

function PackCache:getOneAdvPro()
	if #self.advPros > 0 then
		return self.advPros[1]
	end
end

function PackCache:getAdvPros()
	return self.advPros
end
--资质丹、潜力丹
function PackCache:setSPros(data)
	local isFind = false
	for k,v in pairs(self.sPros) do
		if v.mid == data.mid then
			isFind = true
			self.sPros[k] = data
		end
	end
	if not isFind then
		table.insert(self.sPros, data)
	end
end

function PackCache:getOneSPro()
	if #self.sPros > 0 then
		return self.sPros[1]
	end
end

function PackCache:cleanSPros(one)
	if one then
		if #self.sPros > 0 then
			table.remove(self.sPros,1)
		end
	else
		self.sPros = {}
	end
end

function PackCache:getSPros()
	return self.sPros
end
--是否打开过临时背包提示
function PackCache:setIsOpenLimitTip(isOpenLimitTip)
	self.isOpenLimitTip = isOpenLimitTip
end

function PackCache:getIsOpenLimitTip()
	return self.isOpenLimitTip
end
--是否打开过临时背包1小时提示
function PackCache:setIsOpenLimitTip1(isOpenLimitTip)
	self.isOpenLimitTip1 = isOpenLimitTip
end

function PackCache:getIsOpenLimitTip1()
	return self.isOpenLimitTip1
end

function PackCache:setDropRoleId()
	self.dropRoleId = self.dropRoleId + 1
end

function PackCache:getDropRoleId()
	return self.dropRoleId
end
--是否要弹进阶小弹窗
function PackCache:setNotAdvancedTip(id,Not)
	self.notAdvancedTip[id] = Not
end

function PackCache:getNotAdvancedTip(id)
	return self.notAdvancedTip[id]
end
--设置套装锻造数据
function PackCache:setsuitAwakens(data)
	self.awakenEquip = nil
	self.suitAwakens = data
end

function PackCache:updateSuitAwakens(part,awakens)
	self.awakenEquip = nil
	for k1,v1 in pairs(awakens) do
		for k2,v2 in pairs(self.suitAwakens) do
			if v1.part == v2.part then
				self.suitAwakens[k2] = v1
			end
		end
	end
end

function PackCache:getSuitAwakenData(part)
	if self.awakenEquip and self.awakenEquip.part == part then
		return self.awakenEquip
	end
	for k,v in pairs(self.suitAwakens) do
		if v.part == part then
			self.awakenEquip = v
			return v
		end
	end
	return nil
end

function PackCache:getSuitAwakens()
	return self.suitAwakens or {}
end
--添加稀有装备
function PackCache:addRareEquipData(data)
	table.insert(self.rareEquipData, data)
end

function PackCache:cleanRareEquipData(isAll)
	if isAll then
		self.rareEquipData = {}
	else
		table.remove(self.rareEquipData,1)
	end
end

function PackCache:getRareEquipData()
	if #self.rareEquipData > 0 then
		return self.rareEquipData[1]
	end
	return nil
end
--获取元素背包
function PackCache:getElementPackData()
	return self.packData[Pack.elementPack]
end

--根据index获取元素
function PackCache:getElementByIndex(index)
	return self.packData[Pack.elementPack] and self.packData[Pack.elementPack][index]
end
--获取已经装备的元素
function PackCache:getElementEquipData()
	return self.packData[Pack.elementEquip]
end

function PackCache:setEleByType()
	self.eleByType = {}
	for i=1,14 do
		self.eleByType[i] = self:getElementEquipByType(i)
	end
end
--根据背包小类获取已装备的元素(只调用一次)
function PackCache:getElementEquipByType(subType)
	local data = self:getElementEquipData()
	for k,v in pairs(data) do
		local _type = conf.ItemConf:getSubType(v.mid)
		if subType == _type then
			return v
		end
	end
end
--根据背包小类获取已装备的元素
function PackCache:getEleByType(subType)
	return self.eleByType[subType]
end

--根据已装备元素品质数量判断激活技能
function PackCache:isOpenSkillByEleColorNum(color,num)
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
--已镶嵌元素
    local eleNum = elementDataByColor[color] and table.nums(elementDataByColor[color]) or 0
    -- local needNum = 0
    -- for k,v in pairs(openSkill) do
    -- 	if v[1] == color then
    -- 		needNum = v[2]
    -- 		break
    -- 	end
    -- end
    return eleNum >= num
end


function PackCache:getElementById(id)
	local data = {mid = id, index = 0, amount = 0, bind = 0,colorAttris = {}}
	for k ,v in pairs(self:getElementPackData()) do
		if v.mid == id then
			data.amount = data.amount + v.amount
		end
		-- if id == v.mid then
		-- 	return v
		-- end
	end
	return data
end

--更新元素背包
function PackCache:updateElementPack(changeItems)
	for k,v in pairs(changeItems) do
		self.packData[Pack.elementPack][v.index] = v--添加或者改变
	end
	for k,v in pairs(self.packData[Pack.elementPack]) do
		if v.amount <= 0 then--删除
			self.packData[Pack.elementPack][v.index] = nil
		end
	end
end

--获取帝魂背包
function PackCache:getDiHunPackData()
	return self.packData[Pack.dihun]
end
--根据类型和部位获得帝魂背包内数据
function PackCache:getDiHunPackDataBySubTypeAndPart(_subType,_part)
	local data = self:getDiHunPackData()
	local mData = {}
	for k,v in pairs(data) do
		local subType = conf.ItemConf:getSubType(v.mid)
		local part = conf.ItemConf:getPart(v.mid)
		if subType == _subType and part == _part then
			table.insert(mData,v)
		end
	end
	return mData
end

--根据index获取帝魂背包装备
function PackCache:getDiHunDataByIndex(index)
	return self.packData[Pack.dihun] and self.packData[Pack.dihun][index]
end

function PackCache:getPaoGuangRed()
    local paoGuangLv = conf.ForgingConf:getValue("equip_gem_polish_lev")
	local forgData = self:getForgData()
	for _,data in pairs(forgData) do
        for k,mid in pairs(data.gemMap) do
            if mid ~= 0 then
                local gemType = conf.ItemConf:getGemType(mid)
                local gemlvl = conf.ItemConf:getLvl(mid)

                local polishLev = data and data.gemPolish and data.gemPolish[k] and data.gemPolish[k].polishLev or 0
                local id = gemType *1000 + polishLev
                local confData = conf.ForgingConf:getGemPolishById(id)
                local listnumber = {}
                if confData and confData.items and gemlvl >= paoGuangLv then
                    for _,j in pairs(confData.items) do
                        local _packdata = cache.PackCache:getPackDataById(j[1])
                        table.insert(listnumber,math.floor(_packdata.amount/j[2]))
                    end
                    local redNum = math.min(unpack(listnumber))
                    if redNum > 0 then
                    	return redNum
                    end
                end
            end
        end
    end
    return 0

end

function PackCache:getShengXiaoData()
	return self.packData[Pack.shengXiao]
end

return PackCache