local ShengXiaoProxy = class("ShengXiaoProxy", base.BaseProxy)

function ShengXiaoProxy:init()
	self:add(5660101, self.add5660101)	-- 生肖信息
	self:add(5660102, self.add5660102)	-- 生肖技能位扩展
	self:add(5660103, self.add5660103)	-- 生肖装备穿戴
	self:add(5660104, self.add5660104)	-- 生肖强化
	self:add(5660105, self.add5660105)	-- 生肖分解
	self:add(5660106, self.add5660106)	-- 生肖进阶
	self:add(5660107, self.add5660107)	-- 生肖拆解
	self:add(5660108, self.add5660108)	-- 生肖技能激活

	self:add(5030696, self.add5030696)	-- 生肖宝藏
	self:add(5030697, self.add5030697)	-- 生肖宝藏仓库信息

	self:add(8240304, self.add8240304)	-- 生肖战力广播
end

-- 生肖信息
function ShengXiaoProxy:add5660101(data)
	if data.status == 0 then
		cache.ShengXiaoCache:setSxInfo(data)

		self:flushView(data)
	else
		GComErrorMsg(data.status)
	end
end

-- 技能扩展
function ShengXiaoProxy:add5660102(data)
	if data.status == 0 then
		cache.ShengXiaoCache:updateSkillMax(data.skillMax)

		self:flushView(data)
	else
		GComErrorMsg(data.status)
	end
end

-- 穿戴
function ShengXiaoProxy:add5660103(data)
	if data.status == 0 then
		cache.ShengXiaoCache:updateSxInfo(data.sxInfo)

		self:flushView(data)
	else
		GComErrorMsg(data.status)
	end
end

-- 强化
function ShengXiaoProxy:add5660104(data)
	if data.status == 0 then
		cache.ShengXiaoCache:updateSxPartInfo(data)
		cache.ShengXiaoCache:updateSxScore(data.score)

		self:flushView(data)
	else
		GComErrorMsg(data.status)
	end
end

-- 分解
function ShengXiaoProxy:add5660105(data)
	if data.status == 0 then
		cache.ShengXiaoCache:onDecompose(data)

		self:flushView(data)
	else
		GComErrorMsg(data.status)
	end
end

-- 进阶
function ShengXiaoProxy:add5660106(data)
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.ShengXiaoJinJieView)
		if view then
		    view:closeView()
		end
		cache.ShengXiaoCache:updateSxInfo(data.sxInfo)
		self:flushView(data)
	else
		GComErrorMsg(data.status)
	end
end

-- 拆解
function ShengXiaoProxy:add5660107(data)
	if data.status == 0 then
		cache.ShengXiaoCache:onChaiJie(data)

		self:flushView(data)
	else
		GComErrorMsg(data.status)
	end
end

-- 技能激活
function ShengXiaoProxy:add5660108(data)
	if data.status == 0 then
		cache.ShengXiaoCache:updateSxInfo(data.sxInfo)

		self:flushView(data)
	else
		GComErrorMsg(data.status)
	end
end

-- 生肖宝藏
function ShengXiaoProxy:add5030696(data)
	if data.status == 0 then
		cache.ShengXiaoCache:setBaoZangInfo(data)
		if data.reqType ~= 0 then
			local wareInfo = cache.ShengXiaoCache:getBaoZangInfo()
			if (nil == next(wareInfo)
				or nil == wareInfo.itemInfos
				or #wareInfo.itemInfos <= 0) then
				local infos = {itemInfos = data.items}
				cache.ShengXiaoCache:setBaoZangWareInfo(infos)
			end
		end
		-- 抽十次，弹奖励窗口
		if data.reqType == 2 then
			GOpenAlert3(data.items)
		elseif data.reqType == 1 then
			for k, v in pairs(data.items) do
				local updateData = clone(v)
				updateData.amount = v.updateNum
				updateData.isSXBZ = true
				mgr.ItemMgr:addItem(updateData)
			end
		end
		self:flushView(data)
	else
		GComErrorMsg(data.status)
	end
end

-- 生肖宝藏仓库
function ShengXiaoProxy:add5030697(data)
	if data.status == 0 then
		cache.ShengXiaoCache:setBaoZangWareInfo(data)

		local view = mgr.ViewMgr:get(ViewName.ShengXiaoBaoZangWareView)
		if view then
		    view:flush(data)
		end

		local view2 = mgr.ViewMgr:get(ViewName.KageeViewNew)
		if view2 then
		    view2:flush(data)
		end
	else
		GComErrorMsg(data.status)
	end
end

-- 生肖战力
function ShengXiaoProxy:add8240304(data)
	if data.status == 0 then
		for k, v in pairs(data.power) do
			cache.ShengXiaoCache:updateSxPower(k, v)
		end

		self:flushView(data)
	else
		GComErrorMsg(data.status)
	end
end

------------------------ 客户端

-- 获取全部信息
function ShengXiaoProxy:sendGetInfo()
	self:send(1660101)
end

-- 扩展技能
function ShengXiaoProxy:sendExtendSkill()
	self:send(1660102)
end

-- 穿戴，reqType：0：穿 1：脱
function ShengXiaoProxy:sendDressEquip(reqType, indexs, partInfo, type)
	local params = {}
	params.reqType = reqType or 0
	params.indexs = indexs or {}
	params.partInfo = partInfo or {}
	params.type = type or 0
	self:send(1660103, params)
end

-- reqType:0：强化 1：一键强化
function ShengXiaoProxy:sendStrengthen(reqType, type, part)
	local params = {}
	params.reqType = reqType or 0
	params.part = part or 0
	params.type = type or 0
	self:send(1660104, params)
end

-- 分解
function ShengXiaoProxy:sendDecompose(indexs)
	local params = {}
	params.indexs = indexs or {}
	self:send(1660105, params)
end

-- 升阶
function ShengXiaoProxy:sendUpgrade(type, part)
	local params = {}
	params.type = type or 0
	params.part = part or 0
	self:send(1660106, params)
end

-- 拆解
function ShengXiaoProxy:sendChaiJie(index)
	local params = {}
	params.index = index or 0
	self:send(1660107, params)
end

-- 技能激活 0：取消激活 1：激活
function ShengXiaoProxy:sendActiveSkill(reqType, type)
	local params = {}
	params.reqType = reqType or 0
	params.type = type or 0
	self:send(1660108, params)
end

-- 获取宝藏信息，reqType：0：显示 1：抽一次 2：抽十次
function ShengXiaoProxy:sendGetBaoZangInfo(reqType, stage, moneyType)
	local params = {}
	params.reqType = reqType or 0
	params.stage = stage or 0
	params.moneyType = moneyType or 0
	self:send(1030696, params)
end

-- 获取宝藏仓库信息，reqType：0：物品信息 1：一键取出
function ShengXiaoProxy:sendGetBaoZangWareInfo(reqType)
	local params = {}
	params.reqType = reqType or 0
	self:send(1030697, params)
end

function ShengXiaoProxy:flushView(data)
	local view = mgr.ViewMgr:get(ViewName.KageeViewNew)
	if view then
	    view:flush(data)
	end
	local view2 = mgr.ViewMgr:get(ViewName.ShengXiaoPackView)
	if view2 then
	    view2:flush(data)
	end

	local view3 = mgr.ViewMgr:get(ViewName.ShengXiaoFenJieView)
	if view3 then
	    view3:flush(data)
	end

	local view4 = mgr.ViewMgr:get(ViewName.ShengXiaoStrengthenView)
	if view4 then
	    view4:flush(data)
	end

	local view5 = mgr.ViewMgr:get(ViewName.ShengXiaoExtendView)
	if view5 then
	    view5:flush(data)
	end
end

return ShengXiaoProxy