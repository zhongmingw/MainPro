local QiBingCache = class("QiBingCache", base.BaseCache)

-- 强化石道具ID
QiBingCache.QHSICON = {
    [1] = 221043819,
    [2] = 221043821,
    [3] = 221043823,
}

QiBingCache.QHSIcon = {
    [1] = "221071783",
    [2] = "221071784",
    [3] = "221071785",
}

function QiBingCache:init()
	self.qiBingInfo = {}
end

function QiBingCache:setQiBingInfo(info)
	self.qiBingInfo.qhsMap = info.qhsMap
	self.qiBingInfo.huanhuaId = info.huanhuaId
	for k, v in pairs(info.qiBingInfo) do
		local tIndex = math.floor(v.id / 100)
		self.qiBingInfo[tIndex] = self.qiBingInfo[tIndex] or {}
		self.qiBingInfo[tIndex][v.id] = v
	end
	for i = 1, 3 do
		table.sort(self.qiBingInfo[i] or {}, function(a, b)
			return a.id < b.id
		end)
	end
end

-- 更新强化等级
function QiBingCache:updateQiBingQhLv(id, level)
	local info = self:getQiBingInfo(id)
	if nil == info then
		return
	end
	info.qhLev = level
end

-- 更新升星等级
function QiBingCache:updateQiBingSxLv(id, level)
	local info = self:getQiBingInfo(id)
	if nil == info then
		return
	end
	info.sxLev = level
end

-- 更新神铸等级
function QiBingCache:updateQiBingFlLv(id, level, flAttrLev)
	local info = self:getQiBingInfo(id)
	if nil == info then
		return
	end
	info.flLev = level
	info.flAttrLev = flAttrLev
end

function QiBingCache:updatePower(id, power)
	local info = self:getQiBingInfo(id)
	if nil == info then
		return
	end
	info.power = power
end

function QiBingCache:updateQhsMap(index, value)
	self.qiBingInfo.qhsMap[index] = value
end

function QiBingCache:updateHuanhuaId(huanhuaId)
	self.qiBingInfo.huanhuaId = huanhuaId
end

function QiBingCache:getAllInfo()
	return self.qiBingInfo
end

function QiBingCache:getQiBingInfo(id)
	local tIndex = math.floor(id / 100)
	local info = self.qiBingInfo[tIndex]
	return info and info[id]
end

function QiBingCache:getQiBingType(index, sort)
	if not sort then
		return self.qiBingInfo[index] or {}
	end
	local list = {}
	for k, v in pairs(self.qiBingInfo[index] or {}) do
		table.insert(list, v)
	end
	table.sort(list, function(a, b)
		return a.id < b.id
	end)
	return list
end

-- 强化红点
function QiBingCache:calcStrengthenRedPoint(id, qhLev)
	local info = self:getQiBingInfo(id)
	if nil == info then
		return false
	end
	qhLev = qhLev or info.qhLev
	if qhLev <= 0 then
		return false
	end
	local confData = conf.QiBingConf:getQhDataByLv(qhLev > 0 and qhLev or 1, id)
	local nextConfData = conf.QiBingConf:getQhDataByLv(qhLev + 1, id)
	if nil == nextConfData or nil == confData then
		return false
	end
	local qhsType = confData.cost_qhs[1][1]
	local needCount = confData.cost_qhs[1][2]
	local myCount = self.qiBingInfo.qhsMap[qhsType]
	if needCount > myCount then
		return false
	end
	return true
end

-- 神铸红点
function QiBingCache:calcShenZhuRedPoint(id, flLev)
	local info = self:getQiBingInfo(id)
	if nil == info then
		return false
	end
	flLev = flLev or info.flLev
	if info.qhLev <= 0 then
		return false
	end
	local confData = conf.QiBingConf:getFlDataByLv(flLev > 0 and flLev or 1, id)
	local nextConfData = conf.QiBingConf:getFlDataByLv(flLev + 1, id)
	if nil == nextConfData or nil == confData then
		return false
	end
	local itemId = confData.cost_item[1][1]
	local needCount = confData.cost_item[1][2]
	local itemData = cache.PackCache:getPackDataById(itemId, true)
	if needCount > itemData.amount then
		return false
	end
	return true
end

-- 升星红点
function QiBingCache:calcUpStarRedPoint(id, sxLev)
	local info = self:getQiBingInfo(id)
	if nil == info then
		return false
	end
	sxLev = sxLev or info.sxLev
	if info.qhLev <= 0 then
		return false
	end
	local confData = conf.QiBingConf:getSxDataByLv(sxLev > 0 and sxLev or 1, id)
	local nextConfData = conf.QiBingConf:getSxDataByLv(sxLev + 1, id)
	if nil == nextConfData or nil == confData then
		return false
	end
	local itemId = confData.cost_item[1][1]
	local needCount = confData.cost_item[1][2]
	local itemData = cache.PackCache:getPackDataById(itemId, true)
	if needCount > itemData.amount then
		return false
	end
	return true
end

-- 激活红点
function QiBingCache:calcActiveRedPoint(id, qhLev)
	local info = self:getQiBingInfo(id)
	if nil == info then
		return false
	end
	qhLev = qhLev or info.qhLev
	if qhLev > 0 then
		return false
	end
	local confData = conf.QiBingConf:getQhDataByLv(qhLev, id)
	if nil == confData then
		return false
	end
	if confData.up_con == 1 then--手动激活
		return true
    elseif confData.up_con == 2 then--前一个神器达到xx级
        local beforInfo = self:getQiBingInfo(id - 1)
        if nil == beforInfo then
        	return false
        end
        if beforInfo.qhLev >= confData.con_value then
        	return true
        end
    else--道具激活
        local itemId = confData.cost_item[1][1]
        local needCount = confData.cost_item[1][2]
        local itemData = cache.PackCache:getPackDataById(itemId, true)
        if needCount > itemData.amount then
        	return false
        end
        return true
    end
end

function QiBingCache:calcFenJieRedPoint()
	local list = conf.QiBingConf:getFenjieList()
	for k, v in pairs(list) do
		local itemData = cache.PackCache:getPackDataById(v, true)
		if itemData.amount > 0 then
			return true
		end
	end
	return false
end

function QiBingCache:calcAllRedPoint()
	if self:calcFenJieRedPoint() then
		return true
	end
	for i = 1, 3 do
		local infos = self.qiBingInfo[i]
		for k, v in pairs(infos) do
			if self:calcStrengthenRedPoint(v.id, v.qhLev)
				or self:calcShenZhuRedPoint(v.id, v.flLev)
				or self:calcUpStarRedPoint(v.id, v.sxLev)
				or self:calcActiveRedPoint(v.id, v.qhLev) then

				return true
			end
		end
	end
	return false
end

return QiBingCache