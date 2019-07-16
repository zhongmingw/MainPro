local QiBingProxy = class("QiBingProxy", base.BaseProxy)

function QiBingProxy:init()
	self:add(5650101, self.add5650101)	-- 奇兵系统
	self:add(5650102, self.add5650102)	-- 奇兵激活强化
	self:add(5650103, self.add5650103)	-- 奇兵附灵
	self:add(5650104, self.add5650104)	-- 奇兵升星
	self:add(5650105, self.add5650105)	-- 奇兵分解
	self:add(5650106, self.add5650106)	-- 奇兵幻化
	self:add(8240302, self.add8240302)	-- 广播奇兵强化石数值
	self:add(8240303, self.add8240303)	-- 广播奇兵战力
end

function QiBingProxy:add5650101(data)
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
		cache.QiBingCache:setQiBingInfo(data)
		if view then
		    view:addMsgCallBack(data)
		end
	else
		GComErrorMsg(data.status)
	end
end

function QiBingProxy:add5650102(data)
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
		cache.QiBingCache:updateQiBingQhLv(data.qiBingId, data.qhLev)
		if view then
		    view:addMsgCallBack(data)
		end
	else
		GComErrorMsg(data.status)
	end
end

function QiBingProxy:add5650103(data)
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
		cache.QiBingCache:updateQiBingFlLv(data.qiBingId, data.flLev, data.flAttrLev)
		if view then
		    view:addMsgCallBack(data)
		end
	else
		GComErrorMsg(data.status)
	end
end

function QiBingProxy:add5650104(data)
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
		cache.QiBingCache:updateQiBingSxLv(data.qiBingId, data.sxLev)
		if view then
		    view:addMsgCallBack(data)
		end
		local starView = mgr.ViewMgr:get(ViewName.QiBingUpStarView)
		if starView then
			starView:refreshSx(data)
		end
	else
		GComErrorMsg(data.status)
	end
end

function QiBingProxy:add5650105(data)
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
		if view then
		    view:addMsgCallBack(data)
		end

		local decomposeview = mgr.ViewMgr:get(ViewName.QiBingFenJie)
		if decomposeview then
		    decomposeview:refreshQhsMap(data)
		end
	else
		GComErrorMsg(data.status)
	end
end

function QiBingProxy:add5650106(data)
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
		cache.QiBingCache:updateHuanhuaId(data.qiBingId)

		if view then
		    view:addMsgCallBack(data)
		end
	else
		GComErrorMsg(data.status)
	end
end

function QiBingProxy:add8240302(data)
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
		for k, v in pairs(data.qhsMap) do
			cache.QiBingCache:updateQhsMap(k, v)
		end
		if view then
		    view:addMsgCallBack(data)
		end

		local decomposeview = mgr.ViewMgr:get(ViewName.QiBingFenJie)
		if decomposeview then
		    decomposeview:refreshQhsMap(data)
		end
	else
		GComErrorMsg(data.status)
	end
end

function QiBingProxy:add8240303(data)
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
		for k, v in pairs(data.power) do
			cache.QiBingCache:updatePower(k, v)
		end
		if view then
		    view:addMsgCallBack(data)
		end
	else
		GComErrorMsg(data.status)
	end
end

function QiBingProxy:sendGetInfo()
	self:send(1650101)
end

function QiBingProxy:sendStrengthen(qiBingId, qhLev)
	local params = {}
	params.qiBingId = qiBingId
	params.qhLev = qhLev
	self:send(1650102, params)
end

function QiBingProxy:sendFuLing(qiBingId, flLev)
	local params = {}
	params.qiBingId = qiBingId
	params.flLev = flLev
	self:send(1650103, params)
end

function QiBingProxy:sendUpStar(qiBingId, sxLev)
	local params = {}
	params.qiBingId = qiBingId
	params.sxLev = sxLev
	self:send(1650104, params)
end

function QiBingProxy:sendDecompose(indexs)
	local params = {}
	params.indexs = indexs
	self:send(1650105, params)
end

function QiBingProxy:sendHunaHua(reqType, qiBingId)
	local params = {}
	params.qiBingId = qiBingId
	params.reqType = reqType
	self:send(1650106, params)
end

return QiBingProxy