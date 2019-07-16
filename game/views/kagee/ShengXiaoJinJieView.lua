local ShengXiaoJinJieView = class("ShengXiaoJinJieView", base.BaseView)

local ITEM_NUM = 3

local function setInfo(self)
	local info = cache.ShengXiaoCache:getSxInfo(self.id)
	if nil == info then
		return
	end
	local partInfo = info.partInfos[self.part]
	local mid = partInfo.itemInfo.mid or 0
	local itemData = {mid = mid, amount = 0, bind = 0}

	local curScore = 0
	local nextScore = 0

	-- 当前装备可以升的最大阶数
	local maxGrade = conf.ShengXiaoConf:getGlobalCfg().maxGrade
	local jinJieMap = conf.ShengXiaoConf:getJinJieMapCfg(mid)

	local itemName = conf.ItemConf:getName(mid)
	self.curName.text = itemName
	self.nextName.text = itemName

	local equipGrade = conf.ItemConf:getStagelvl(mid)

	-- local isMaxGrade = equipGrade >= maxGrade
	local isMaxGrade = nil == jinJieMap

	self.upGradeBtn.grayed = isMaxGrade
	self.upGradeBtn.touchable = not isMaxGrade

	self.nextCom.visible = not isMaxGrade
	self.arrow.visible = not isMaxGrade

	-- 格子数据
	GSetItemData(self.curItemCell, itemData)

	local curItemConf = conf.ItemConf:getItem(mid)
	self.curEquipType.text = curItemConf.part_name
	if not isMaxGrade then
		local nextiIemData = {mid = jinJieMap.next_id, amount = 0, bind = 0}
		GSetItemData(self.nextItemCell, nextiIemData)
		local nextConf = conf.ItemConf:getItem(jinJieMap.next_id)
		self.nextEquipType.text = nextConf.part_name
	end

	-- 设置极品属性
	local curBestAtts = {}
	local nextBestAtts = {}
	for k, v in pairs(partInfo.itemInfo.colorAttris) do
		local curKey, curValue = conf.ShengXiaoConf:getBestAttrs(v.type, v.value)
		local nextKey, nextValueStr, nextVal = conf.ShengXiaoConf:getBestAttrs(v.type + 1)
		table.insert(curBestAtts, {curKey, curValue})
		table.insert(nextBestAtts, {nextKey, nextValueStr})

		curScore = curScore + mgr.ItemMgr:birthAttScore(v.type, v.value)
		nextScore = nextScore + mgr.ItemMgr:birthAttScore(v.type + 1, nextVal)
	end
	for k, v in pairs(self.curBestAttrs) do
		if nil ~= curBestAtts[k] then
			v.name.text = curBestAtts[k][1]
			v.value.text = curBestAtts[k][2]
		else
			v.name.text = ""
			v.value.text = ""
		end
		if nil ~= nextBestAtts[k] and not isMaxGrade then
			self.nextBestAttrs[k].name.text = nextBestAtts[k][1]
			self.nextBestAttrs[k].value.text = nextBestAtts[k][2]
		else
			self.nextBestAttrs[k].name.text = ""
			self.nextBestAttrs[k].value.text = ""
		end
	end

	local baseAttrs = {}
	local curSpecialAttrs = {}

	-- 区分基础属性和基础属性
	local attiData = conf.ItemArriConf:getItemAtt(partInfo.itemInfo.mid)
	local baseConf = GConfDataSort(attiData)
	for k, v in pairs(baseConf) do
		if not conf.ShengXiaoConf:isSpecialAttr(v[1]) then
			baseAttrs["att_" .. v[1]] = baseAttrs["att_" .. v[1]] or 0
			baseAttrs["att_" .. v[1]] = baseAttrs["att_" .. v[1]] + v[2]
		else
			curSpecialAttrs["att_" .. v[1]] = curSpecialAttrs["att_" .. v[1]] or 0
			curSpecialAttrs["att_" .. v[1]] = curSpecialAttrs["att_" .. v[1]] + v[2]
		end
	end

	baseAttrs = GConfDataSort(baseAttrs)
	curSpecialAttrs = GConfDataSort(curSpecialAttrs)

	-- 下一阶装备属性配置
	local nextSpecialCfg = conf.ItemConf:getItemPro(jinJieMap and jinJieMap.next_id or 0)
	local nextSpecialAttrs = {}
	local nextBaseAttrs = {}
	nextSpecialCfg = GConfDataSort(nextSpecialCfg)

	-- 区分特殊属性和基础属性
	for k, v in pairs(nextSpecialCfg) do
		if not conf.ShengXiaoConf:isSpecialAttr(v[1]) then
			nextBaseAttrs["att_" .. v[1]] = nextBaseAttrs["att_" .. v[1]] or 0
			nextBaseAttrs["att_" .. v[1]] = nextBaseAttrs["att_" .. v[1]] + v[2]
		else
			nextSpecialAttrs["att_" .. v[1]] = nextSpecialAttrs["att_" .. v[1]] or 0
			nextSpecialAttrs["att_" .. v[1]] = nextSpecialAttrs["att_" .. v[1]] + v[2]
		end
	end

	nextSpecialAttrs = GConfDataSort(nextSpecialAttrs)
	nextBaseAttrs = GConfDataSort(nextBaseAttrs)

	-- 强化属性
	local strengAttrs = conf.ShengXiaoConf:getStrenCfg(self.part, partInfo.strenLevel)
	strengAttrs = GConfDataSort(strengAttrs)

	-- 基础属性
	for k, v in pairs(self.curBaseAttrs) do
		if nil ~= baseAttrs[k] then
			local attName = conf.RedPointConf:getProName(baseAttrs[k][1])
			v.name.text = attName
			if nil ~= strengAttrs[k] then
				local strenStr = string.format(language.kagee40, strengAttrs[k][2])
				curScore = curScore
							+ mgr.ItemMgr:baseAttScore(strengAttrs[k][1], strengAttrs[k][2])
							+ mgr.ItemMgr:baseAttScore(baseAttrs[k][1], baseAttrs[k][2])

				nextScore = nextScore
							+ mgr.ItemMgr:baseAttScore(strengAttrs[k][1], strengAttrs[k][2])
							+ mgr.ItemMgr:baseAttScore(nextBaseAttrs[k][1], nextBaseAttrs[k][2])

				strenStr = mgr.TextMgr:getTextColorStr(strenStr, 7)
				v.value.text = baseAttrs[k][2] .. strenStr
				if not isMaxGrade then
					self.nextBaseAttrs[k].name.text = attName
					self.nextBaseAttrs[k].value.text = nextBaseAttrs[k][2] .. strenStr
				end
			else
				v.value.text = baseAttrs[k][2]
			end
		else
			v.name.text = ""
			v.value.text = ""
			self.nextBaseAttrs[k].name.text = ""
			self.nextBaseAttrs[k].value.text = ""
		end
	end

	-- 特殊属性
	for k, v in pairs(self.curSpecialAttrs) do
		if nil ~= curSpecialAttrs[k] then
			local attName = conf.RedPointConf:getProName(curSpecialAttrs[k][1])
			v.name.text = attName
			v.value.text = curSpecialAttrs[k][2]
			if not isMaxGrade and nil ~= nextSpecialAttrs[k] then
				self.nextSpecialAttrs[k].name.text = attName
				self.nextSpecialAttrs[k].value.text = nextSpecialAttrs[k][2]
			end
		else
			v.name.text = ""
			v.value.text = ""
			self.nextSpecialAttrs[k].name.text = ""
			self.nextSpecialAttrs[k].value.text = ""
		end
	end

	-- 进阶材料
	local jinjieCfg = conf.ShengXiaoConf:getJinJieCost(equipGrade)
	if nil ~= jinjieCfg.items then
		local tempJinJie = nil
		for k, v in pairs(self.itemList) do
			tempJinJie = jinjieCfg.items[k]
			v.item.visible = nil ~= tempJinJie
			v.cost.visible = nil ~= tempJinJie
			if nil ~= tempJinJie then
				local tempData = {
						mid = tempJinJie[1],
						amount = 0,
						bind = tempJinJie[3] and tempJinJie[3] or 0
				}
				local itemData = cache.PackCache:getPackDataById(tempJinJie[1], true)
				local myCount = itemData.amount
				GSetItemData(v.item, tempData, true)
				local textData = {
			        {text = myCount, color = 7},
			        {text = "/" .. tempJinJie[2], color = 7},
				}
				if tempJinJie[2] > myCount then
				    textData[1].color = 14
				end
				v.cost.text = mgr.TextMgr:getTextByTable(textData)
			end
		end
	end

	self.curScore.text = curScore
	self.nextScore.text = nextScore
end

local function getAttrs(com)
	local name = com:GetChild("name")
	local value = com:GetChild("value")
	return {name = name, value = value}
end

local function getComponentChild(self, com, prefix)
	local name = com:GetChild("n3")
	local score = com:GetChild("n7")
	local equipType = com:GetChild("n21")
	com:GetChild("n39").touchable = false
	local itemCell = com:GetChild("n39"):GetChild("n5")

	for i = 1, ITEM_NUM do
		local curBaseRoot = com:GetChild("baseAttr" .. i)
		self[prefix .. "BaseAttrs"][i] = getAttrs(curBaseRoot)

		local curBestRoot = com:GetChild("bestAttr" .. i)
		self[prefix .. "BestAttrs"][i] = getAttrs(curBestRoot)
	end

	self[prefix .. "SpecialAttrs"] = {getAttrs(com:GetChild("specialAttr1"))}
	self[prefix .. "Name"] = name
	self[prefix .. "Score"] = score
	self[prefix .. "EquipType"] = equipType
	self[prefix .. "ItemCell"] = itemCell
end

function ShengXiaoJinJieView:ctor()
	self.super.ctor(self)
	self.uiClear = UICacheType.cacheTime
	self.uiLevel = UILevel.level2
	self.itemList = {}
	self.curBaseAttrs = {}		-- 当前基础属性
	self.curBestAttrs = {}		-- 当前极品属性
	self.curSpecialAttrs = {}	-- 当前特殊属性
	self.curName = ""
	self.curScore = 0
	self.curEquipType = ""
	self.curItemCell = nil

	self.nextBaseAttrs = {}		-- 下一基础属性
	self.nextBestAttrs = {}		-- 下一极品属性
	self.nextSpecialAttrs = {}	-- 下一特殊属性
	self.nextName = ""
	self.nextScore = 0
	self.nextEquipType = ""
	self.nextItemCell = nil
end

function ShengXiaoJinJieView:initView()
	local curCom = self.view:GetChild("n23")
	getComponentChild(self, curCom, "cur")

	self.nextCom = self.view:GetChild("n28")
	self.nextTitle = self.nextCom:GetChild("n2")
	self.nextTitle.text = language.kagee33

	self.arrow = self.view:GetChild("n29")

	getComponentChild(self, self.nextCom, "next")

	self.upGradeBtn = self.view:GetChild("n22")
	self.upGradeBtn.onClick:Add(self.onClickUpGradeBtn, self)

	for i = 1, ITEM_NUM do
		local cost = self.view:GetChild("cost" .. i)
		local item = self.view:GetChild("item" .. i)
		self.itemList[i] = {item = item, cost = cost}
	end

	local closeBtn = self.view:GetChild("n0"):GetChild("n7")
	closeBtn.onClick:Add(self.onClickClose, self)

	self.curItemCell.touchable = false
	self.nextItemCell.touchable = false
end

function ShengXiaoJinJieView:initData(data)
	self.id = data.id
	self.part = data.part
	setInfo(self)
end

function ShengXiaoJinJieView:onClickUpGradeBtn()
	local info = cache.ShengXiaoCache:getSxInfo(self.id)
	if nil == info then
		return
	end
	local partInfo = info.partInfos[self.part]
	local mid = partInfo.itemInfo.mid or 0
	local equipGrade = conf.ItemConf:getStagelvl(mid)
	local jinjieCfg = conf.ShengXiaoConf:getJinJieCost(equipGrade)
	if nil == jinjieCfg then
		return
	end
	for k, v in pairs(jinjieCfg.items or {}) do
		local tempData = {
				mid = v[1],
				amount = 0,
				bind = v[3] and v[3] or 0
		}
		local itemData = cache.PackCache:getPackDataById(v[1], true)
		local myCount = itemData.amount
		if v[2] > myCount then
			GComAlter(language.kagee41)
			return
		end
	end
	proxy.ShengXiaoProxy:sendUpgrade(self.id, self.part)
end

function ShengXiaoJinJieView:onClickClose()
	self:closeView()
end

function ShengXiaoJinJieView:flush()
end

return ShengXiaoJinJieView