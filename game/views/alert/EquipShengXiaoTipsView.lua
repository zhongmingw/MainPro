local dian = mgr.TextMgr:getImg(UIItemRes.dian01)
local _height = {91,113}
local EquipShengXiaoTipsView = class("EquipTipsView", base.BaseView)

local DECOMPOSE_ICON_URL = "ui://_others/shengxiao_055"

local DressHandler = 1      -- 穿戴
local ReplaceHandler = 2    -- 替换
local StrengthenHandler = 3 -- 强化
local DecomposeHandler = 4  -- 分解
local ChaiJieHandler = 5    -- 拆解
local TakeoffHandler = 6    -- 卸下

local BTN_HANDLER = {
    -- 穿戴
    [DressHandler] = function(self, context)
        local confData = conf.ItemConf:getItem(self.packdata.mid)
        proxy.ShengXiaoProxy:sendDressEquip(0, {self.packdata.index}, {confData.part}, self.info.id)
        self:closeView()
    end,

    -- 替换
    [ReplaceHandler] = function(self, context)
        local confData = conf.ItemConf:getItem(self.packdata.mid)
        proxy.ShengXiaoProxy:sendDressEquip(0, {self.packdata.index}, {confData.part}, self.info.id)
        self:closeView()
    end,

    -- 强化
    [StrengthenHandler] = function(self, context)
        if nil ~= self.info and nil ~= self.info.id then
            mgr.ViewMgr:openView2(ViewName.ShengXiaoStrengthenView, {id = self.info.id})
        end
        self:closeView()
    end,

    -- 分解
    [DecomposeHandler] = function(self, context)
        mgr.ViewMgr:openView2(ViewName.ShengXiaoFenJieView)
        self:closeView()
    end,

    -- 拆解
    [ChaiJieHandler] = function(self, context)
        local confData = conf.ItemConf:getItem(self.packdata.mid)
        local fhCfg = conf.ShengXiaoConf:getJinJieCost(confData.stage_lvl)
        local str = language.kagee51
        if nil ~= fhCfg and nil ~= fhCfg.fanhuan then

            str = str .. "\n" .. language.kagee52
            local jinJieMap = conf.ShengXiaoConf:getJinJieMapCfg(self.packdata.mid)
            if nil ~= jinJieMap then
                local firstCfg = conf.ItemConf:getItem(jinJieMap.first_id)
                if nil ~= firstCfg then
                    local stage = firstCfg.stage_lvl < 10
                                    and firstCfg.stage_lvl
                                    or firstCfg.stage_lvl - 10
                    local stageStr = firstCfg.stage_lvl < 10
                                    and language.kagee53
                                    or language.kagee54

                    str = str .. mgr.TextMgr:getTextColorStr(stage, 7) .. stageStr .. firstCfg.name .. "，"
                end
            end
            for k, v in pairs(fhCfg.fanhuan) do
                local fhItemCfg = conf.ItemConf:getItem(v[1])

                str = str .. fhItemCfg.name .. mgr.TextMgr:getTextColorStr(v[2], 7)
                if k ~= #fhCfg.fanhuan then
                    str = str .. "，"
                end
            end
        end
        local index = self.packdata.index
        local params = {}
        params.content = str
        params.rightHandler = function()
            proxy.ShengXiaoProxy:sendChaiJie(index)
        end
        mgr.ViewMgr:openView2(ViewName.Alert22, params)
        self:closeView()
    end,

    -- 卸下
    [TakeoffHandler] = function(self, context)
        local confData = conf.ItemConf:getItem(self.packdata.mid)
        proxy.ShengXiaoProxy:sendDressEquip(1, {confData.part}, {}, self.info.id)
        self:closeView()
    end,
}

local BTN_INFO = {
    {name = language.pack01, handler = BTN_HANDLER[DressHandler]},
    {name = language.pack37, handler = BTN_HANDLER[ReplaceHandler]},
    {name = language.pack49, handler = BTN_HANDLER[StrengthenHandler]},
    {name = language.pack44, handler = BTN_HANDLER[DecomposeHandler]},
    {name = language.pack45, handler = BTN_HANDLER[ChaiJieHandler]},
    {name = language.pack09, handler = BTN_HANDLER[TakeoffHandler]},
}

local CHAI_JIE_GRADE = 12   -- 拆解的装备阶数

function EquipShengXiaoTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
    --self.uiClear = UICacheType.cacheDisabled
end

function EquipShengXiaoTipsView:initView()
    self.leftpanel = self.view:GetChild("n0")
    self.oldxy = self.leftpanel.xy
    self.rightpanel = self.view:GetChild("n1")

    self.leftpanel.visible = false
    self.rightpanel.visible = false

    self.leftxy = {
        self.leftpanel:GetChild("n44").xy,
        self.leftpanel:GetChild("n48").xy,
        self.leftpanel:GetChild("n45").xy,
    }
    self.rightxy = {
        self.rightpanel:GetChild("n50").xy,
        self.rightpanel:GetChild("n56").xy,
        self.rightpanel:GetChild("n51").xy,
    }

    self:setCloseBtn(self.blackView)
end

function EquipShengXiaoTipsView:initData()
    self.leftpanel:GetChild("n44").xy = self.leftxy[1]
    self.leftpanel:GetChild("n48").xy = self.leftxy[2]
    self.leftpanel:GetChild("n45").xy = self.leftxy[3]

    self.rightpanel:GetChild("n50").xy = self.rightxy[1]
    self.rightpanel:GetChild("n56").xy = self.rightxy[2]
    self.rightpanel:GetChild("n51").xy = self.rightxy[3]
end

-- data_：背包数据或者身上数据
function EquipShengXiaoTipsView:setData(data_, info)
    if not data_  and not info then
        return self:closeView()
    end
    self.leftpanel.visible = false
    self.rightpanel.visible = false

    self.btnInfos = {}
    self.packdata = data_ --背包装备
    self.info = info

    self.partEquip = nil
    if nil ~= info and nil ~= info.id then
        local sxInfo = cache.ShengXiaoCache:getSxInfo(info.id)
        local confData = conf.ItemConf:getItem(data_.mid)
        local partInfo = sxInfo.partInfos[confData.part]
        if partInfo.itemInfo.mid > 0 then
            self.partEquip = partInfo.itemInfo
        end
        -- 是否在背包
        if info.isPack then
            if confData.stage_lvl >= CHAI_JIE_GRADE then
                table.insert(self.btnInfos, BTN_INFO[5])
            else
                table.insert(self.btnInfos, BTN_INFO[4])
            end
            if nil ~= self.partEquip then
                table.insert(self.btnInfos, 1, BTN_INFO[2])
                self.leftpanel.xy = self.oldxy
                self:initLeft(self.partEquip)
                self:initRight(data_)
            else
                table.insert(self.btnInfos, 1, BTN_INFO[1])
                self.leftpanel:Center()
                self:initLeft(data_)
            end

        -- 是否是身上装备
        elseif info.isDress then
            table.insert(self.btnInfos, BTN_INFO[3])
            if partInfo.strenLevel <= 0 then
                table.insert(self.btnInfos, BTN_INFO[6])
            end
            self.leftpanel:Center()
            self:initLeft(data_)
        else
            self.leftpanel:Center()
            self:initLeft(data_)
        end
    else
        self.leftpanel:Center()
        self:initLeft(data_)
    end
end
--按钮状态
function EquipShengXiaoTipsView:setBtnSeeinfo(way)
    -- body
     --3个按钮
    local btn1, btn2, btn3 = nil, nil, nil
    local c1 = nil
    local p1, p2 = nil, nil
    local xylist = nil
    if way == 1 then
        btn1 = self.leftpanel:GetChild("n44")
        btn2 = self.leftpanel:GetChild("n48")
        btn3 = self.leftpanel:GetChild("n45")
        c1 = self.leftpanel:GetController("c1")

        p1 = self.leftpanel:GetChild("n42")
        p2 = self.leftpanel:GetChild("n43")

        xylist = self.leftxy

    else
        btn1 = self.rightpanel:GetChild("n50")
        btn2 = self.rightpanel:GetChild("n56")
        btn3 = self.rightpanel:GetChild("n51")
        c1 = self.rightpanel:GetController("c1")

        p1 = self.rightpanel:GetChild("n48")
        p2 = self.rightpanel:GetChild("n49")
        xylist = self.rightxy
    end
    local btnList = {[1] = btn1, [2] = btn2, [3] = btn3}
    c1.selectedIndex = #self.btnInfos > 0 and 1 or 0
    for i = 1, 3 do
        btnList[i].onClick:Clear()
        btnList[i].visible = nil ~= self.btnInfos[i]
        if nil ~= self.btnInfos[i] then
            btnList[i].title = self.btnInfos[i].name
            btnList[i].onClick:Add(self.btnInfos[i].handler, self)
            btnList[i].xy = xylist[i]
        end
    end

    local count = (btn1.visible and 1 or 0) + (btn2.visible and 1 or 0) + (btn3.visible and 1 or 0)
    if count == 3 then
        p1.height = 158
    elseif count == 2 then
        p1.height = 115
    else
        p1.height = 74
    end
end

--极品属性
function EquipShengXiaoTipsView:attiCallback(id, value, isTuijian)
    local attiData = conf.ItemConf:getEquipColorAttri(id)
    local color = attiData and attiData.color or 1
    local attType = attiData and attiData.att_type or 0
    local name = conf.RedPointConf:getProName(attType)
    local maxColor = conf.ItemConf:getEquipColorGlobal("max_color")
    local attiValue = "+" .. GProPrecnt(attType, value)
    if color >= maxColor then--是否是最高品质
        local attiRange = attiData.att_range or {}
        local maxValue = attiRange[#attiRange] and attiRange[#attiRange][2]
        if maxValue and value >= maxValue then
            attiValue = attiValue..language.pack41--获得了最佳的极品属性
        end
    end
    local str = ""
    if isTuijian then
        str = language.equip08 .. " " .. name .. attiValue
    else
        str = name .. attiValue
    end
    return mgr.TextMgr:getQualityAtti(str, color)
end

function EquipShengXiaoTipsView:setlistMsg(listView, data)
    listView.numItems = 0
    --基础属性
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    local baseitem = listView:AddItemFromPool(url)
    local attiData = conf.ItemArriConf:getItemAtt(data.mid)
    local baseAttrs = GConfDataSort(attiData)
    local score = 0--基础评分
    local str = ""
    local specialList = {}

    for k, v in pairs(baseAttrs) do
        -- 是否是特殊属性
        if conf.ShengXiaoConf:isSpecialAttr(v[1]) then
            specialList["att_" .. v[1]] = specialList["att_" .. v[1]] or 0
            specialList["att_" .. v[1]] = specialList["att_" .. v[1]] + v[2]
        else
            local name = conf.RedPointConf:getProName(v[1])
            local str1 = dian .. " " .. name .. " " .. v[2]
             if k ~= #baseAttrs then
                str1 = str1.."\n"
            end
            str = str..str1
            score = score + mgr.ItemMgr:baseAttScore(v[1], v[2])--计算综合战斗力
        end
    end
    baseitem:GetChild("n0").text = language.equip02[3]
    baseitem:GetChild("n8").text = str
    baseitem:GetChild("n1").text = ""

    --极品属性
    str = ""
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    baseitem = listView:AddItemFromPool(url)
    local synScore = 0--综合战斗力
    local colorAttris = data.colorAttris
    if colorAttris and #colorAttris > 0 then--系统生成属性
        baseitem:GetChild("n0").text = language.equip02[2]
        for k, v in pairs(colorAttris) do
            local str1 = self:attiCallback(v.type, v.value)
            if k ~= #colorAttris then
                str1 = str1 .. "\n"
            end
            str = str .. str1
            synScore = synScore + mgr.ItemMgr:birthAttScore(v.type, v.value)--计算综合评分
        end
    else
        local birthAtt = conf.ItemConf:getBaseBirthAtt(data.mid)--推荐属性
        local isTuijian = true
        if not birthAtt then--固定生成的属性不走推荐
            isTuijian = false
            birthAtt = conf.ItemConf:getBirthAtt(data.mid) or {}
            baseitem:GetChild("n0").text = language.equip02[2]
        else
            baseitem:GetChild("n0").text = language.equip02[2]
                                            .. string.format(language.equip07, #birthAtt / 2)
        end
        if #birthAtt <= 0 then
            str = language.kagee67
        else
            for k, v in pairs(birthAtt) do
                if k % 2 == 0 then--值
                    local type, value = birthAtt[k - 1], birthAtt[k]
                    local str1 = self:attiCallback(type, value, isTuijian)
                    if k ~= #birthAtt then
                        str1 = str1.."\n"
                    end
                    str = str .. str1
                    if not isTuijian then--如果是固定生成的
                        synScore = synScore + mgr.ItemMgr:birthAttScore(type, value)--计算综合评分
                    end
                end
            end
        end
    end
    baseitem:GetChild("n1").text = ""
    baseitem:GetChild("n8").text = str

    specialList = GConfDataSort(specialList)

    if #specialList > 0 then
        str = ""
        local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
        local specialItem = listView:AddItemFromPool(url)

        -- 特殊属性
        specialItem:GetChild("n0").text = language.kagee49
        for k, v in pairs(specialList) do
            local name = conf.RedPointConf:getProName(v[1])
            local str1 = dian .. " " .. name .. " " .. v[2]
             if k ~= #baseAttrs then
                str1 = str1.."\n"
            end
            str = str .. str1
            score = score + mgr.ItemMgr:baseAttScore(v[1], v[2])--计算综合评分
        end
        specialItem:GetChild("n8").text = str
    end

    -- 分解获得
    local confData = conf.ItemConf:getItem(data.mid)
    if confData.stage_lvl < CHAI_JIE_GRADE then
        local sxDecomposeCfg = conf.ShengXiaoConf:getDecomposeCfg(data.mid)
        if nil ~= sxDecomposeCfg and nil ~= sxDecomposeCfg.items then
            local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
            local decomposeItem = listView:AddItemFromPool(url)
            str = ""
            decomposeItem:GetChild("n0").text = language.kagee50
            local decomposeIcon = mgr.TextMgr:getImg(DECOMPOSE_ICON_URL)
            local items = sxDecomposeCfg.items[1]
            local decomposeItemCfg = conf.ItemConf:getItem(items[1])
            str = dian .. " " .. decomposeIcon
                    .. decomposeItemCfg.name .. " "
                    .. mgr.TextMgr:getTextColorStr(items[2], 7)

            decomposeItem:GetChild("n8").text = str
        end
    end

    -- 每次都选中第一个
    listView:ScrollToView(0, false)

    return checkint(score), checkint(synScore)
end

function EquipShengXiaoTipsView:setgetwayList(listView1, condata)
    listView1.itemRenderer = function(index,obj)
        local info = condata.formview[index + 1]
        local id = info[1]
        local childIndex = info[2]
        local data = conf.SysConf:getModuleById(id)
        local lab = obj:GetChild("n1")
        lab.text = data.desc
        local btn = obj:GetChild("n0")
        btn.data = {id = id,childIndex = childIndex}
        btn.onClick:Add(self.onBtnGo, self)
    end
    listView1.numItems = condata.formview and #condata.formview or 0
end

function EquipShengXiaoTipsView:onBtnGo(context)
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end

function EquipShengXiaoTipsView:initLeft(data)
    self.leftmid = data.mid
    self.leftpanel.visible = true
    local condata = conf.ItemConf:getItem(data.mid)
    --道具icon
    local itemObj = self.leftpanel:GetChild("n19")
    GSetItemData(itemObj, data)

    local name = self.leftpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)
    --部位
    local partName = self.leftpanel:GetChild("n25")

    local isbind = self.leftpanel:GetChild("n26")
    isbind.text = ""

    local equipDesc1 = self.leftpanel:GetChild("n27")--
    partName.text = condata.part_name
    equipDesc1.text = mgr.TextMgr:getTextColorStr(language.kagee48, 13)

    local colorText1 = self.leftpanel:GetChild("n49")
    colorText1.text = language.pack33 ..
                        mgr.TextMgr:getQualityStr1(
                            language.pack35[condata.color],
                            condata.color)

    local level = self.leftpanel:GetChild("n50")
    level.text = language.gonggong83 .. (condata.lvl or 0)

    local need = self.leftpanel:GetChild("n28")
    need.text =  ""

    local basePower = self.leftpanel:GetChild("n18")

    local power1 = self.leftpanel:GetChild("n54")

    local isWear = self.leftpanel:GetChild("n4")
    isWear.visible = (nil ~= self.info and nil ~= self.info.isDress) and self.info.isDress or false

    --属性
    local listView = self.leftpanel:GetChild("n41")
    local score, score1 = self:setlistMsg(listView, data)
    basePower.text = score
    power1.text = score + score1

    self.base1 = power1.text
    --获取途径
    local listView1 = self.leftpanel:GetChild("n47")
    self:setgetwayList(listView1, condata)


    self.leftpanel:GetChild("n56").visible = false
    self.leftpanel:GetChild("n55").text = ""

    self:setBtnSeeinfo(1)
end

function EquipShengXiaoTipsView:initRight(data)
    self.rightmid = data.mid
    self.rightpanel.visible = true
    local condata = conf.ItemConf:getItem(data.mid)
    local itemObj = self.rightpanel:GetChild("n19")
    GSetItemData(itemObj, data)

    local name = self.rightpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    local partName = self.rightpanel:GetChild("n25")

    local isbind = self.rightpanel:GetChild("n26")
    isbind.text = ""

    local equipDesc1 = self.rightpanel:GetChild("n27")--几阶装备
    partName.text = condata.part_name
    equipDesc1.text = mgr.TextMgr:getTextColorStr(language.kagee48, 13)

    local colorText1 = self.rightpanel:GetChild("n58")
    colorText1.text = language.pack33 ..
                        mgr.TextMgr:getQualityStr1(
                            language.pack35[condata.color],
                            condata.color)

    local level = self.rightpanel:GetChild("n57")
    level.text = language.gonggong83 .. (condata.lvl or 0)

    local need = self.rightpanel:GetChild("n28")
    need.text =  ""

    local basePower = self.rightpanel:GetChild("n18")

    local power1 = self.rightpanel:GetChild("n62")
    power1.text = 0

    local isWear = self.rightpanel:GetChild("n4")
    isWear.visible = false

    --属性
    local listView = self.rightpanel:GetChild("n47")
    local score, score1 = self:setlistMsg(listView, data)

    basePower.text = score
    power1.text = score + score1

    local listView1 = self.rightpanel:GetChild("n55")
    self:setgetwayList(listView1, condata)

    self.rightpanel:GetChild("n64").visible = false
    self.rightpanel:GetChild("n63").text = ""


    --装备对比
    self:setEquipContrast()

    self:setBtnSeeinfo(2)
end

function EquipShengXiaoTipsView:setEquipContrast()
    local text1 = self.rightpanel:GetChild("n41")
    local text2 = self.rightpanel:GetChild("n42")
    local text3 = self.rightpanel:GetChild("n53")

    local text4 = self.rightpanel:GetChild("n43")
    local text5 = self.rightpanel:GetChild("n44")
    local text6 = self.rightpanel:GetChild("n54")

    text1.text = ""
    text2.text = ""
    text3.text = ""
    text4.text = ""
    text5.text = ""
    text6.text = ""

    local attiData1 = conf.ItemArriConf:getItemAtt(self.rightmid)
    local attiData2 = conf.ItemArriConf:getItemAtt(self.leftmid)
    local num = 0
    local function getText(num)
        if num < 0 then
            return mgr.TextMgr:getTextColorStr(num, 14)
        elseif num > 0 then
            return mgr.TextMgr:getTextColorStr("+"..num, 7)
        else
            return ""
        end
    end
    local t = GConfDataSort(attiData1)
    for k,v in pairs(t) do
        num = num + 1
        local att2 = attiData2 and attiData2["att_"..v[1]] or 0
        if num == 1 then
            text1.text = conf.RedPointConf:getProName(v[1])
            text4.text = getText(v[2] - att2)
        elseif num == 2 then
            text2.text = conf.RedPointConf:getProName(v[1])
            text5.text = getText(v[2] - att2)
        elseif num == 3 then
            text3.text = conf.RedPointConf:getProName(v[1])
            text6.text = getText(v[2] - att2)
        end
    end
end

return EquipShengXiaoTipsView