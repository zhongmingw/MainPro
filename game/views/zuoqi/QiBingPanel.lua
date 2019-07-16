local QiBingPanel = class("QiBingPanel", import("game.base.Ref"))

local function setModel(self, data)
	local confData = conf.QiBingConf:getQiBingDataById(data.id)
	local modelId = confData.modelId--self.modelPanel
	if self.curModelId == modelId then
		return
	end
    self.shenqi = self.parent:addEffect(modelId, self.modelPanel)
    if nil == self.shenqi then
    	return
    end
    self.animation:Stop()

    self.shenqi.Scale = Vector3.New(confData.scale, confData.scale, confData.scale)
    local rotation = confData.rota
    self.shenqi.LocalRotation = Vector3.New(rotation[1], rotation[2], rotation[3])
    local pos = confData.pos
    self.shenqi.LocalPosition = Vector3.New(pos[1], pos[2], pos[3])
    self.curModelId = modelId

    self.animation:Play()
end

--强化石txt初始化
local function initQhsTxt(self)
    if not self.qiBingAllInfo then
        return
    end
    for k, v in pairs(self.consumeItems) do
        local txt = v:GetChild("n2")
        txt.text = self.qiBingAllInfo.qhsMap[k]
        local icon = v:GetChild("n1")
        icon.url = UIPackage.GetItemURL("_icons" , cache.QiBingCache.QHSIcon[k])
    end
end

local function setMidInfo(self, data)
	local leftConf = conf.QiBingConf:getQiBingDataById(data.id)
	self.nameImg.url = UIPackage.GetItemURL("zuoqi" , leftConf.imgId)
	self.fightPower.text = data.power
	self.levelVal.text = "LV." .. data.qhLev
	self.curLevel.text = "LV." .. data.qhLev
	self.nextLevel.text = "LV." .. (data.qhLev + 1)
end

local function setStrengthenItem(self, data)
	local mId = 0
	local textData = {}
	local needAmount = 0
	local isMax = false
	local myCount = 0
	if self.topToggle.selectedIndex == 0 then
		local qhData = conf.QiBingConf:getQhDataByLv(data.qhLev > 0 and data.qhLev or 1, data.id)
		local nextQhData = conf.QiBingConf:getQhDataByLv(data.qhLev > 0 and data.qhLev + 1 or 1, data.id)
		isMax = nil == nextQhData
		if not isMax then
			local qhsType = qhData.cost_qhs[1][1]
			mId = cache.QiBingCache.QHSICON[qhsType]
			needAmount = qhData.cost_qhs[1][2]
			myCount = self.qiBingAllInfo.qhsMap[qhsType]
		end
		self.strengthenItem.touchable = false
	else
		local flConf = conf.QiBingConf:getFlDataByLv(data.flLev > 0 and data.flLev or 1, data.id)
		local nextFlConf = conf.QiBingConf:getFlDataByLv(data.flLev > 0 and data.flLev + 1 or 1, data.id)
		isMax = nil == nextFlConf
		if not isMax then
			mId = flConf.cost_item[1][1]
			needAmount = flConf.cost_item[1][2]
			local itemData = cache.PackCache:getPackDataById(mId, true)
			myCount = itemData.amount
		end
		self.strengthenItem.touchable = true
	end

	self.strengthenItem.visible = not isMax
	self.strengthenText.visible = not isMax
	if isMax then
		return
	end
	textData = {
	        {text = myCount, color = 7},
	        {text = "/" .. needAmount, color = 7},
	}
	if needAmount > myCount then
	    textData[1].color = 14
	end
	local info = {mid = mId, amount = 0, bind = 0}
	GSetItemData(self.strengthenItem, info, true)
	self.strengthenText.text = mgr.TextMgr:getTextByTable(textData)
end

-- 神铸属性
local function setShenZhuAttrs(self, data)
	local isActive = data.flLev > 0
	local flConf = conf.QiBingConf:getFlDataByLv(isActive and data.flLev or 1, data.id)
    local color = isActive and 1 or 16
    local curAttrs = conf.QiBingConf:getFlShenZhuAttr(data.id, data.flAttrLev)
    local sxAttrs = conf.QiBingConf:getSxAttr(flConf.sx_id)
    curAttrs = GConfDataSort(curAttrs)
    sxAttrs = GConfDataSort(sxAttrs)
    local attrCfg = nil
    local sxAttrCfg = nil
     -- 神铸属性
	for k, v in pairs(self.shenZhuAttrs) do
		attrCfg = curAttrs[k]
		sxAttrCfg = sxAttrs[k]
		if nil ~= attrCfg and nil ~= sxAttrCfg then
			local attName = conf.RedPointConf:getProName(attrCfg[1])
			if attName ~= "" then
				v.key.text = mgr.TextMgr:getTextColorStr(attName .. ":", color)
				local varStr = isActive
								and attrCfg[2] .. string.format(
										"(%s)",
										math.floor(attrCfg[2] / sxAttrCfg[2] * 100) .. "%"
										)
								or attrCfg[2] .. language.shenqi05
				v.value.text = mgr.TextMgr:getTextColorStr(varStr, color)
			end
		end
	end
	local nextFlConf = conf.QiBingConf:getFlDataByLv(data.flLev + 1, data.id)
	self.maxFuLing.visible = nil == nextFlConf
	self.maxStrengthen.visible = false
	self.shenZhuBtn.grayed = (data.qhLev <= 0) or (nil == nextFlConf)
	self.shenZhuBtn.touchable = (data.qhLev > 0) and (nil ~= nextFlConf)
	self.shenZhuBtnRedImg.visible = (data.qhLev > 0) and cache.QiBingCache:calcShenZhuRedPoint(data.id, data.flLev)
end

local function setBaseAttrs(self, data)
	-- 当前强化配置
	local qhData = conf.QiBingConf:getQhDataByLv(data.qhLev > 0 and data.qhLev or 1, data.id)
	-- 下一强化等级配置
	local nextQhData = conf.QiBingConf:getQhDataByLv(data.qhLev + 1, data.id)
	local attrData = GConfDataSort(qhData) --强化属性
	local nextAttrData = GConfDataSort(nextQhData) --强化属性
	local isActive = data.qhLev > 0
	self.attrControl.selectedIndex = (isActive and nil ~= nextQhData) and 1 or 0
	local attrCfg = nil
	local nextAttrCfg = nil
	local color = isActive and 1 or 16
	for k, v in pairs(self.baseAttrs) do
		attrCfg = attrData[k]
		if nil ~= attrCfg then
			local attName = conf.RedPointConf:getProName(attrCfg[1])
			if attName ~= "" then
				v.key.text = mgr.TextMgr:getTextColorStr(attName .. ":", color)
				v.value.text = mgr.TextMgr:getTextColorStr(attrCfg[2], color)
				v.curVal.text = mgr.TextMgr:getTextColorStr(attrCfg[2], color)
				if nil ~= nextQhData then
					nextAttrCfg = nextAttrData[k]
					v.nextVal.text = mgr.TextMgr:getTextColorStr(nextAttrCfg[2], 4)
				end
			end
		end
	end
	self.maxStrengthen.visible = nil == nextQhData
	self.maxFuLing.visible = false
	self.strengthenBtn.grayed = not isActive or (nil == nextQhData)
	self.strengthenBtn.touchable = isActive and (nil ~= nextQhData)
	self.strengthenBtnRedImg.visible = isActive and cache.QiBingCache:calcStrengthenRedPoint(data.id, data.qhLev)
end

local function setActiveState(self, data)
	local isActive = data.qhLev > 0
	local jihuoStr = ""
	if not isActive then
		local qhData = conf.QiBingConf:getQhDataByLv(data.qhLev, data.id)
        if qhData.up_con == 1 then--手动激活
        	jihuoStr = language.shenqi01
        	self.activeBtn.grayed = false
        	self.activeBtn.touchable = true
        elseif qhData.up_con == 2 then--前一个神器达到xx级
            local leftId = data.id - 1
            local leftConf = conf.QiBingConf:getQiBingDataById(leftId)
            jihuoStr = string.format(language.shenqi02, leftConf.name, qhData.con_value)

            local leftData = cache.QiBingCache:getQiBingInfo(leftId)
            self.activeBtn.grayed = leftData.qhLev < qhData.con_value
            self.activeBtn.touchable = leftData.qhLev >= qhData.con_value
        else--道具激活
            local mId = qhData.cost_item[1][1]
            local needAmount = qhData.cost_item[1][2]
            local itemName = conf.ItemConf:getName(mId)
            jihuoStr = string.format(language.shenqi03, itemName)
            local itemData = cache.PackCache:getPackDataById(mId, true)
            local textData = {
                    {text = itemData.amount, color = 7},
                    {text = "/" .. needAmount, color = 7},
            }
            if needAmount > itemData.amount then
                textData[1].color = 14
                self.activeBtn.grayed = true
                self.activeBtn.touchable = false
            else
             	self.activeBtn.grayed = false
             	self.activeBtn.touchable = true
            end
            local info = {mid = mId, amount = 0, bind = 0}
            GSetItemData(self.activePropItem, info, true)
            self.activePropNum.text = mgr.TextMgr:getTextByTable(textData)
        end
        self.activeText.text = jihuoStr

        self.activePropGroup.visible = qhData.up_con ~= 1 and qhData.up_con ~= 2
        self.activeText.visible = qhData.up_con == 1 or qhData.up_con == 2
    else
    	self.starConTrl.selectedIndex = data.sxLev
    	self.activeBtn.touchable = true
    end
    self.upStarBtn.visible = isActive
    self.huanHuaBtn.visible = isActive and data.id ~= self.qiBingAllInfo.huanhuaId
	self.ativeComponents.visible = not isActive
	self.decomposeBtn.visible = isActive
	self.activeBtn.visible = not isActive

	self.lockIcon.visible = not isActive
	self.hadHuanhuaImg.visible = data.id == self.qiBingAllInfo.huanhuaId
	self.starsRoot.visible = isActive
	self.upStarBtnRedImg.visible = cache.QiBingCache:calcUpStarRedPoint(data.id, data.sxLev)
	self.topBaseRedImg.visible = cache.QiBingCache:calcStrengthenRedPoint(data.id, data.qhLev)
	self.topShenZhuRedImg.visible = cache.QiBingCache:calcShenZhuRedPoint(data.id, data.flLev)

	setMidInfo(self, data)
	if self.topToggle.selectedIndex == 0 then
		setBaseAttrs(self, data)
	else
		setShenZhuAttrs(self, data)
	end
	setStrengthenItem(self, data)
end

local function cellData(self, obj, data, index)
    local confData = conf.QiBingConf:getQiBingDataById(data.id)
    local qhData = conf.QiBingConf:getQhDataByLv(data.qhLev, data.id)
    local nameTxt = obj:GetChild("n2")
    local jihuoTxt = obj:GetChild("n4")
    local redImg = obj:GetChild("red")
    local stars = obj:GetChild("n6")
    local starsControl = stars:GetController("c1")

    nameTxt.text = confData.name
    local isActive = data.qhLev > 0
    stars.visible = isActive
    jihuoTxt.visible = not isActive
    local jihuoStr = ""
    if not isActive then
        if qhData.up_con == 1 then--手动激活
        	jihuoStr = language.shenqi01
        	redImg.visible = true
        elseif qhData.up_con == 2 then--前一个神器达到xx级
            local leftId = data.id - 1
            local leftConf = conf.QiBingConf:getQiBingDataById(leftId)
            jihuoStr = string.format(language.shenqi02, leftConf.name, qhData.con_value)
            -- 红点
            local beforInfo = cache.QiBingCache:getQiBingInfo(leftId)
            redImg.visible = beforInfo.qhLev >= qhData.con_value
        else--道具激活
            local mId = qhData.cost_item[1][1]
            local itemName = conf.ItemConf:getName(mId)
            jihuoStr = string.format(language.shenqi03, itemName)
            -- 红点
            local needCount = qhData.cost_item[1][2]
            local itemData = cache.PackCache:getPackDataById(mId, true)
            redImg.visible = needCount <= itemData.amount
        end
        jihuoTxt.text = jihuoStr
    else
    	starsControl.selectedIndex = data.sxLev
    	local isCanStrengthen = cache.QiBingCache:calcStrengthenRedPoint(data.id, data.qhLev)
    	local isCanShenZhu = cache.QiBingCache:calcShenZhuRedPoint(data.id, data.flLev)
    	local isCanUpStar = cache.QiBingCache:calcUpStarRedPoint(data.id, data.sxLev)
    	local isCanFenJie = cache.QiBingCache:calcFenJieRedPoint()
    	redImg.visible = isCanStrengthen or isCanShenZhu or isCanUpStar or isCanFenJie
    end

    local isSelect = self.curCellIndex == index
    if isSelect then
    	setActiveState(self, data)
    	setModel(self, data)
    end
    obj.selected = isSelect
    obj.data = {index = index, data = data}
    obj.onClick:Add(self.onClickQiBingCell, self)
end

local function setListTitleCell(self, obj, index)
	if nil == obj then
		return
	end
	local bgImg = obj:GetChild("n0")
    local titleImg = obj:GetChild("n1")
    local c1 = obj:GetController("c1")
    bgImg.url = UIPackage.GetItemURL("zuoqi", "shenqi_00" .. (index + 1))
    titleImg.url = UIPackage.GetItemURL("zuoqi", "qibing_00" .. index)

    c1.selectedIndex = (index == self.curTitleIndex and self.isShowCell) and 1 or 0

    obj.data = {index = index}
    obj.onClick:Add(self.onClickTitleCell, self)
end

local function setListView(self)
	self.listView.numItems = 0
    for i = 1, 3 do
    	local url = UIPackage.GetItemURL("zuoqi" , "TabItem1")
        local obj = self.listView:AddItemFromPool(url)
        setListTitleCell(self, obj, i)
        if self.curTitleIndex == i and self.isShowCell then
        	for k, v in pairs(cache.QiBingCache:getQiBingType(i, true)) do
                local url = UIPackage.GetItemURL("zuoqi" , "TabItem2")
                local obj = self.listView:AddItemFromPool(url)
                cellData(self, obj, v, self.curTitleIndex + k)
        	end
        end
    end

    self.listView:ScrollToView(self.curTitleIndex - 1, false)
    -- self.listView:AddSelection(self.curCellIndex - 1, true)
end

function QiBingPanel:ctor(mParent)
	self.parent = mParent

	-- 当前大标题索引
	self.curTitleIndex = 1
	-- 当前选择格子索引
	self.curCellIndex = self.curTitleIndex + 1

	self.isShowCell = true

	-- 信息
	self.qiBingAllInfo = {}

	self.consumeItems = {}
	-- 未激活或满级
	self.baseAttrs = {}
	-- 神铸属性
	self.shenZhuAttrs = {}

	self:initView()
end

function QiBingPanel:initView()
	local mainView = self.parent.qiBingPanel
	self.decomposeBtn = mainView:GetChild("n7")
	self.decomposeBtnImg = self.decomposeBtn:GetChild("red")
	self.decomposeBtn.onClick:Add(self.onClickDecompsoe, self)
	self.activeBtn = mainView:GetChild("n6")
	self.activeBtn.onClick:Add(self.onClickActiveBtn, self)

	-- 激活条件
	self.activeText = mainView:GetChild("n12")
	self.activePropGroup = mainView:GetChild("n18")
	self.activePropItem = mainView:GetChild("n13")
	self.activePropNum = mainView:GetChild("n300")
	self.ativeComponents = mainView:GetChild("n17")

	for i = 2, 4 do
		table.insert(self.consumeItems, mainView:GetChild("n" .. i))
	end

	self.listView = mainView:GetChild("n11")

	local qiBingItem = mainView:GetChild("n5")
	self.attrControl = qiBingItem:GetController("c2")
	self.topToggle = qiBingItem:GetController("c1")
	self.topToggle.onChanged:Add(self.onTopToggleChange, self)

	self.animation = qiBingItem:GetTransition("t0")

	self.topBaseRedImg = qiBingItem:GetChild("basered")
	self.topShenZhuRedImg = qiBingItem:GetChild("shenzhured")

	-- self.qiBingName = qiBingItem:GetChild("n12")
	self.nameImg = qiBingItem:GetChild("nameImg")
	self.lockIcon = qiBingItem:GetChild("n10")

	-- 星星组件
	self.starsRoot = qiBingItem:GetChild("n79")
	local starItem = qiBingItem:GetChild("n9")
    self.starConTrl = starItem:GetController("c1")
    self.starConTrl.selectedIndex = 0

    -- 升星按钮
    self.upStarBtn = qiBingItem:GetChild("n200")
    self.upStarBtn.onClick:Add(self.onClickUpStarBtn, self)
    self.upStarBtnRedImg = qiBingItem:GetChild("redpoint")

    -- 幻化按钮
    self.huanHuaBtn = qiBingItem:GetChild("n201")
    self.huanHuaBtn.onClick:Add(self.onClickHuanHuaBtn, self)

    -- 已幻化图标
    self.hadHuanhuaImg = qiBingItem:GetChild("n203")

    self.maxStrengthen = qiBingItem:GetChild("n83")
    self.maxFuLing = qiBingItem:GetChild("n82")

    self.strengthenBtn = qiBingItem:GetChild("n73")
    self.strengthenBtn.onClick:Add(self.onClickStrengthenBtn, self)
    self.strengthenBtnRedImg = self.strengthenBtn:GetChild("red")

    self.shenZhuBtn = qiBingItem:GetChild("n77")
    self.shenZhuBtn.onClick:Add(self.onClickShenZhuBtn, self)
    self.shenZhuBtnRedImg = self.shenZhuBtn:GetChild("red")

    -- 强化或者附灵道具格子
    self.strengthenItem = qiBingItem:GetChild("n75")
    self.strengthenText = qiBingItem:GetChild("n210")

    -- 展示模型节点
    self.modelPanel = qiBingItem:GetChild("n40")

    self.levelVal = qiBingItem:GetChild("levelVal")
    self.curLevel = qiBingItem:GetChild("curLv")
    self.nextLevel = qiBingItem:GetChild("nextLv")
    self.fightPower = qiBingItem:GetChild("n92")

    -- 基础属性
    for i = 1, 4 do
    	local attrName = qiBingItem:GetChild("n" .. i + 18)
    	local attrValue = qiBingItem:GetChild("n" .. i + 22)
    	local curVal = qiBingItem:GetChild("n" .. i + 99)
    	local nextVal = qiBingItem:GetChild("n" .. i + 103)
    	table.insert(
    		self.baseAttrs,
			{key = attrName,
			value = attrValue,
			curVal = curVal,
			nextVal = nextVal}
    	)
    end

    -- 神铸属性
    for i = 1, 3 do
    	local attrName = qiBingItem:GetChild("n" .. i + 27)
    	local attrValue = qiBingItem:GetChild("n" .. i + 31)
    	table.insert(self.shenZhuAttrs, {key = attrName, value = attrValue})
    end

    -- 玩法说明
    local helpBtn = qiBingItem:GetChild("n95")
    helpBtn.onClick:Add(self.onClickHelpBtn, self)
end

function QiBingPanel:flush(data)
	self.qiBingAllInfo = cache.QiBingCache:getAllInfo()

	if data.msgId == 5650101 then
		self:JumpToIndex()

		setListView(self)
		initQhsTxt(self)
		self.decomposeBtnImg.visible = cache.QiBingCache:calcFenJieRedPoint()

	elseif data.msgId == 5650102
	 	or data.msgId == 5650103
	  	or data.msgId == 5650104 then

	  	setListView(self)
	  	initQhsTxt(self)
	elseif data.msgId == 5650105 then

		setListView(self)
		initQhsTxt(self)
		self.decomposeBtnImg.visible = cache.QiBingCache:calcFenJieRedPoint()

	elseif data.msgId == 5650106 then
		setListView(self)
	elseif data.msgId == 8240303 then
		local list = cache.QiBingCache:getQiBingType(self.curTitleIndex, true)
		local cellData = list[self.curCellIndex - self.curTitleIndex]
		if nil ~= cellData then
			setMidInfo(self, cellData)
		end
	end
end

-- 打开的时候，检测是否有可激活的，有的话，直接选中
function QiBingPanel:JumpToIndex()
	for i = 1, 3 do
		local infos = cache.QiBingCache:getQiBingType(i, true)
		for k, v in pairs(infos) do
			if cache.QiBingCache:calcActiveRedPoint(v.id, v.qhLev)
				or cache.QiBingCache:calcShenZhuRedPoint(v.id, v.flLev)
				or cache.QiBingCache:calcUpStarRedPoint(v.id, v.sxLev)
				or cache.QiBingCache:calcStrengthenRedPoint(v.id, v.qhLev) then

				self.curTitleIndex = i
				self.curCellIndex = k + self.curTitleIndex
				return
			end
		end
	end
end

function QiBingPanel:closeView()
	self.curModelId = -1
	self.isShowCell = true
end

-- 分解按钮
function QiBingPanel:onClickDecompsoe()
	mgr.ViewMgr:openView2(ViewName.QiBingFenJie)--道具飘显示层
end

-- 激活按钮
function QiBingPanel:onClickActiveBtn()
	local list = cache.QiBingCache:getQiBingType(self.curTitleIndex, true)
	local data = list[self.curCellIndex - self.curTitleIndex]
	if nil == data then
		return
	end
	proxy.QiBingProxy:sendStrengthen(data.id, data.qhLev)
end

-- 升星
function QiBingPanel:onClickUpStarBtn()
	local list = cache.QiBingCache:getQiBingType(self.curTitleIndex, true)
	local data = list[self.curCellIndex - self.curTitleIndex]
	if nil == data then
		return
	end
	mgr.ViewMgr:openView2(ViewName.QiBingUpStarView, {data = data})
end

-- 点击幻化
function QiBingPanel:onClickHuanHuaBtn()
	local list = cache.QiBingCache:getQiBingType(self.curTitleIndex, true)
	local data = list[self.curCellIndex - self.curTitleIndex]
	proxy.QiBingProxy:sendHunaHua(0, data.id)
end

-- 点击强化
function QiBingPanel:onClickStrengthenBtn()
	local list = cache.QiBingCache:getQiBingType(self.curTitleIndex, true)
	local data = list[self.curCellIndex - self.curTitleIndex]
	-- 当前强化配置
	local confData = conf.QiBingConf:getQhDataByLv(data.qhLev > 0 and data.qhLev or 1, data.id)
	-- 下一强化等级配置
	local nextQhData = conf.QiBingConf:getQhDataByLv(data.qhLev + 1, data.id)
	if nil ~= nextQhData then
	    local costMid = confData.cost_qhs[1][1]
	    local costAmount = confData.cost_qhs[1][2]
	    local myCount = self.qiBingAllInfo.qhsMap[costMid]
	    if myCount >= costAmount then
	        proxy.QiBingProxy:sendStrengthen(data.id, data.qhLev)
	    else
	        GComAlter(language.shenqi07)
	    end
	else
	    GComAlter(language.zuoqi12_1)
	end
end

-- 点击神铸
function QiBingPanel:onClickShenZhuBtn()
	local list = cache.QiBingCache:getQiBingType(self.curTitleIndex, true)
	local data = list[self.curCellIndex - self.curTitleIndex]
	-- 当前配置
	local confData = conf.QiBingConf:getFlDataByLv(data.flLev, data.id)
	-- 下一等级配置
	local nextFlData = conf.QiBingConf:getFlDataByLv(data.flLev + 1, data.id)
	if nil ~= nextFlData then
	    local costMid = confData.cost_item[1][1]
	    local costAmount = confData.cost_item[1][2]
		local itemData = cache.PackCache:getPackDataById(costMid, true)
	    if itemData.amount >= costAmount then
	        proxy.QiBingProxy:sendFuLing(data.id, data.flLev)
	    else
	        GComAlter(language.qibing1)
	    end
	else
	    GComAlter(language.zuoqi12_1)
	end
end

-- 玩法说明
function QiBingPanel:onClickHelpBtn()
    GOpenRuleView(1169)
end

function QiBingPanel:onTopToggleChange()
	local list = cache.QiBingCache:getQiBingType(self.curTitleIndex, true)
	local data = list[self.curCellIndex - self.curTitleIndex]
	if self.topToggle.selectedIndex == 0 then
		setBaseAttrs(self, data)
	else
		setShenZhuAttrs(self, data)
	end
	setStrengthenItem(self, data)
end

function QiBingPanel:onClickTitleCell(context)
	local cell = context.sender
    local data = cell.data
    if data.index ~= self.curTitleIndex then
    	self.isShowCell = true
    else
    	self.isShowCell = not self.isShowCell
    end
    self.curTitleIndex = data.index
    self.curCellIndex = self.curTitleIndex + 1
    setListView(self)
end

function QiBingPanel:onClickQiBingCell(context)
	local cell = context.sender
    local data = cell.data
    if data.index == self.curCellIndex then
    	return
    end
    self.curCellIndex = data.index

    setActiveState(self, data.data)
    setModel(self, data.data)
end

return QiBingPanel