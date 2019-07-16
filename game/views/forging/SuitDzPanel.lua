--
-- Author: 
-- Date: 2017-10-30 15:47:58
--
--套装锻造界面
local SuitDzPanel = class("SuitDzPanel",import("game.base.Ref"))

local ZHUX,ZHUS = 1,2--诛仙,诸神
local SZHUX,SZHUS = 3,4--饰品诛仙,饰品诸神
local ZMIN,ZMAX = 1,8--饰品诛仙,诸神
local SZMIN,SZMAX = 9,12--饰品诛仙,诸神

function SuitDzPanel:ctor(mParent)
    self.mParent = mParent
    self.mSuitEffectId = 0--套装前缀
    self.part = 0--选中的装备部位
    self:initPanel()
end

function SuitDzPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n16")
    self.c1 = panelObj:GetController("c1")--主控制器
    self.listView = panelObj:GetChild("n4")--套装列表
    self.chooseItem = panelObj:GetChild("n11")--选中的装备
    self.chooseName = panelObj:GetChild("n21")
    self.materialList = {}
    for i=12,14 do--套装材料
        table.insert(self.materialList, panelObj:GetChild("n"..i))
    end
    self.titleDesc = panelObj:GetChild("n16")--套装标题
    self.attiListView = panelObj:GetChild("n15")--属性列表
    self.attiListView.itemRenderer = function(index,obj)
        self:cellAttiData(index, obj)
    end
    self.attiListView.numItems = 0
    local ruleBtn = panelObj:GetChild("n18")
    ruleBtn.onClick:Add(self.onClickRule,self)
    panelObj:GetChild("n19").text = language.forging65
    self.titleCount = panelObj:GetChild("n17")
    self.titleCount.text = language.forging87
    panelObj:GetChild("n24").text = language.forging86
    self.awakenAttri = panelObj:GetChild("n25")--单件觉醒属性
    self.awakenDzBtn = panelObj:GetChild("n20")
    self.awakenDzBtn.onClick:Add(self.onClickSuitAwaken,self)
end
--服务器返回数据
function SuitDzPanel:setData(data)
    self.mData = data
    self.attiTypes = clone(conf.ForgingConf:getValue("equip_suit_types"))
    self.openIndex = ZHUX
    self:setListViewData()
end

function SuitDzPanel:setListViewData()
    local num, index = 0, 1
    self.listView.numItems = 0
    for k,data in pairs(self.attiTypes) do
        num = num + 1
        local url = UIPackage.GetItemURL("forging" , "RadioChooseItem")
        local obj = self.listView:AddItemFromPool(url)
        self:cellSuitData1({index = k,suitId = data},obj)
        local min,max = ZMIN,ZMAX--装备
        if k > 2 then min,max = SZMIN,SZMAX end--饰品
        if k == self.openIndex then
            index = num
            local arleayDzs = {}
            local callback = function(part)
                num = num + 1
                local url = UIPackage.GetItemURL("forging" , "SuitDzItem")
                local obj = self.listView:AddItemFromPool(url)
                self:cellSuitData2(part, obj)
            end
            for i=min,max do
                callback(i)
            end
        end
    end
    self.listView:ScrollToView(index - 1)
    self:refreshRed()
end
--父标签
function SuitDzPanel:cellSuitData1(data,obj)
    local names = conf.ForgingConf:getValue("equip_suit_names")
    local name = names[data.index] or ""
    obj:GetChild("title").text = name
    data.title = name
    obj.data = data
    obj.onClick:Add(self.onClickSuitItem,self)
    local controller = obj:GetController("button")--主控制器
    if data.index == self.openIndex then
        self.titleDesc.text = name
        self.mSuitEffectId = data.suitId
        controller.selectedIndex = 1
    else
        controller.selectedIndex = 0
    end
end
--子标签
function SuitDzPanel:cellSuitData2(part,obj)
    local equipObj = obj:GetChild("n6")
    local desc = obj:GetChild("n5")
    local equipData = cache.PackCache:getEquipDataByPart(part)
    if equipData then
        obj.title = mgr.TextMgr:getColorNameByMid(equipData.mid)
        local t = clone(equipData)
        t.isquan = true
        GSetItemData(equipObj, t)
    else
        desc.text = ""
        obj.title = language.forging61
        GSetItemData(equipObj, {isCase = true,color = 5})
    end
    obj.data = {part = part,equipData = equipData}
    obj.onClick:Add(self.onClickItem,self)
    if part == 1 or part == 9 then
        obj.onClick:Call()
    end
end
--刷新红点
function SuitDzPanel:refreshRed()
    local reds = {[ZHUX] = {},[ZHUS] = {},[SZHUX] = {},[SZHUS] = {}}
    local isAwakens = {[ZHUX] = false,[ZHUS] = false,[SZHUX] = false,[SZHUS] = false}--是否有诛仙诛神的锻造
    local num = 0
    local callback = function(index,i)
        if self:getIsRed(index,i) then--诛仙
            reds[index][i] = 1
            isAwakens[index] = true
        end
    end
    for i=ZMIN,ZMAX do
        callback(ZHUX,i)--诛仙
        callback(ZHUS,i)--诸神
    end
    for i=SZMIN,SZMAX do
        callback(SZHUX,i)--饰品诛仙
        callback(SZHUS,i)--饰品诸神
    end
    local redvisibles = {[ZHUX] = isAwakens[ZHUX],[ZHUS] = isAwakens[ZHUS],[SZHUX] = isAwakens[SZHUX],[SZHUS] = isAwakens[SZHUS]}
    for i=1,self.listView.numItems do
        local obj = self.listView:GetChildAt(i - 1)
        local data = obj.data
        if data.suitId then--父标签
            obj:GetChild("n4").visible = redvisibles[data.index]--子标签存在一个以上红点
        else--子标签
            local isRed = false
            if reds[self.openIndex][data.part] then isRed = true end
            obj:GetChild("n4").visible = isRed
            local equipData = cache.PackCache:getEquipDataByPart(data.part)
            if equipData then
                local color = conf.ItemConf:getQuality(equipData.mid)
                local stage = conf.ItemConf:getStagelvl(equipData.mid)
                local star = mgr.ItemMgr:getColorBNum(equipData)
                local minStar,minColor = 0,0,0--最小锻造阶数,最小锻造星数,最小锻造品质
                local str = language.forging70[self.openIndex]
                local suitData = cache.PackCache:getSuitAwakenData(data.part)
                local id = self:getAwakenId(self.openIndex,data.part)
                local confData = conf.ForgingConf:getEquipJuexing(id)
                local nextId = id + 1
                local nextData = conf.ForgingConf:getEquipJuexing(nextId)
                local lv = id % 100
                local equipJie = confData and confData.equip_jie or 0--觉醒的阶数
                if self.openIndex == ZHUX or self.openIndex == SZHUX then--诛仙套装
                    minStar = conf.ForgingConf:getValue("equip_suit_zx_min_star")
                    minColor = conf.ForgingConf:getValue("equip_suit_zx_min_color")
                    if suitData then--还没锻造诛仙套装
                        if suitData.zxLev > 0 then
                            if nextData then
                                str = string.format(language.forging71, lv)
                            else
                                str = language.forging88
                            end
                        end
                    end
                    if star < minStar or color < minColor then
                        str = string.format(language.forging63, language.pack35[minColor], equipJie, minStar)
                    elseif stage < equipJie then
                        str = string.format(language.forging64, equipJie)
                    end
                else--诸神套装
                    minStar = conf.ForgingConf:getValue("equip_suit_zs_min_star")
                    minColor = conf.ForgingConf:getValue("equip_suit_zs_min_color")
                    if suitData then--还没锻造诛仙套装
                        if suitData.zxLev <= 0 then
                            str = language.forging69
                        else
                            if star < minStar or color < minColor then
                                str = string.format(language.forging63, language.pack35[minColor], equipJie, minStar)
                            elseif stage < equipJie then
                                str = string.format(language.forging64, equipJie)
                            end
                        end
                        if suitData.zsLev > 0 then 
                            if nextData then
                                str = string.format(language.forging71, lv)
                            else
                                str = language.forging88
                            end
                        end
                    else
                        str = language.forging69
                    end
                end
                obj:GetChild("n5").text = str
            else
                obj:GetChild("n5").text = ""
            end
        end
    end
    if not (isAwakens[ZHUX] or isAwakens[ZHUS] or isAwakens[SZHUX] or isAwakens[SZHUS]) then--没有红点就刷新
        mgr.GuiMgr:redpointByVar(attConst.A10250,0)
    end
end
--结算每一条的红点
function SuitDzPanel:getIsRed(index,part)
    local equipData = cache.PackCache:getEquipDataByPart(part)
    if equipData then
        local stage = conf.ItemConf:getStagelvl(equipData.mid)
        local color = conf.ItemConf:getQuality(equipData.mid)
        local star = mgr.ItemMgr:getColorBNum(equipData)
        local minStar,minColor = 0--最小锻造阶数,最小锻造星数,最小锻造品质
        if index == ZHUX or index == SZHUX then--诛仙套装
            minStar = conf.ForgingConf:getValue("equip_suit_zx_min_star")
            minColor = conf.ForgingConf:getValue("equip_suit_zx_min_color")
        else--诸神套装
            minStar = conf.ForgingConf:getValue("equip_suit_zs_min_star")
            minColor = conf.ForgingConf:getValue("equip_suit_zs_min_color")
        end
        if color >= minColor and star >= minStar then
            local suitData = cache.PackCache:getSuitAwakenData(part)
            local isNotDz = false--是否可以锻造了
            if suitData then
                if index == ZHUX or index == SZHUX then--诛仙
                    isNotDz = true
                elseif index == ZHUS or index == SZHUS then--诸神
                    if suitData.zxLev >= 1 then--必须要锻造了诛仙才可以锻造诸神
                        isNotDz = true--还没锻造
                    end
                end
            else
                if index == ZHUX or index == SZHUX then isNotDz = true end--还没锻造
            end
            if not isNotDz then return false end
            local id = self:getAwakenId(index,part)
            local confData = conf.ForgingConf:getEquipJuexing(id)
            local conZxLev = confData and confData.con_zx_lev or 0
            if suitData.zxLev < conZxLev then return false end
            local nextData = conf.ForgingConf:getEquipJuexing(id + 1)
            if not nextData then return false end
            local equipJie = confData and confData.equip_jie or 0
            if stage < equipJie then return false end
            local costItems = confData and confData.cost_items or {}
            local num = 0
            for k,v in pairs(self.materialList) do--显示材料
                local item = costItems[k]
                if item then
                    local costAmount = item[2]
                    local packData = cache.PackCache:getPackDataById(item[1])
                    if packData.amount >= costAmount then num = num + 1 end
                end
            end
            if num >= #costItems then return true end
        end
    end
    return false
end
--返回套装类型
function SuitDzPanel:getSuitIndex(index)
    local mIndex = index or self.openIndex
    if mIndex == SZHUX then--饰品的特殊是处理
        mIndex = ZHUX
    elseif mIndex == SZHUS then
        mIndex = ZHUS
    end
    return mIndex or 0
end
--返回等级类型
function SuitDzPanel:getIndexLevel(part,index)
    local part = part or self.part
    local data = cache.PackCache:getSuitAwakenData(part) or {}
    local zxLev,zsLev = data.zxLev or 0,data.zsLev or 0
    local t = {[ZHUX] = zxLev,[ZHUS] = zsLev,[SZHUX] = zxLev,[SZHUS] = zsLev} 
    local mIndex = index or self.openIndex
    return t[mIndex] or 0
end
--返回锻造id
function SuitDzPanel:getChooseId(index,part,stage)
    return index * 10000000 + stage * 1000 + part
end
--刷新选中的
function SuitDzPanel:refreshChoose(data)
    if data then
        self:refreshRed()
    end
    self:setSuitData()
    self:setAwakenData()
end
--觉醒属性id
function SuitDzPanel:getAwakenId(index,part)
    local part = part or self.part
    return self:getSuitIndex(index) * 100000 + part * 1000 + self:getIndexLevel(part,index)
end
--觉醒属性
function SuitDzPanel:setAwakenData()
    local awakenId = self:getAwakenId()
    local confData = conf.ForgingConf:getEquipJuexing(awakenId)
    local nextData = conf.ForgingConf:getEquipJuexing(awakenId + 1)
    self.awakenAttri.text = self:getAttriStr(confData,nextData)--单件觉醒属性 --单件下一级醒属性
    --显示材料
    local costItems = confData and confData.cost_items or {}
    local materialNum = 0--记录可满足锻造的材料
    for k,v in pairs(self.materialList) do--显示材料
        local item = costItems[k]
        local itemObj = v:GetChild("n0")
        local title = v:GetChild("n2")
        local lock = v:GetChild("n3")
        if item then
            local costAmount = item[2]
            local itemData = {mid = item[1],amount = 1, bind = item[3],isquan = true}
            GSetItemData(itemObj, itemData, true)
            local packData = cache.PackCache:getPackDataById(item[1])
            local str = packData.amount.."/"..costAmount
            local color = 14
            if packData.amount >= costAmount then
                color = 7
                materialNum = materialNum + 1
            end
            title.text = mgr.TextMgr:getTextColorStr(str, color)
            lock.visible = false
        else
            title.text = ""
            lock.visible = true
            GSetItemData(itemObj, {isCase = 1,color = 5}, false)--bxp改false
        end
    end
    --判断是否可以锻造了
    local suitData = cache.PackCache:getSuitAwakenData(part)
    local isKyAwaken = false--是否可以锻造了
    if materialNum > 0 and materialNum >= #costItems and self.c1.selectedIndex == 0 then
        if suitData then
            if self.openIndex == ZHUX or self.openIndex == SZHUX then--诛仙
                if suitData.zxLev <= 0 then
                    isKyAwaken = true--可以锻造
                end
            elseif self.openIndex == ZHUS or self.openIndex == SZHUS then--诸神
                if suitData.zxLev >= 1 and suitData.zsLev <= 0 then--必须要锻造了诛仙才可以锻造诸神
                    isKyAwaken = true--可以锻造
                end
            end
        else isKyAwaken = true end--可以锻造
    end
    local stage = 0
    if self.equipData then
        stage = conf.ItemConf:getStagelvl(self.equipData.mid)
    end
    local equipJie = confData and confData.equip_jie or 0--觉醒的阶数
    if stage < equipJie then isKyAwaken = false end
    local awakenJie = awakenId % 100
    if awakenJie >= conf.ForgingConf:getValue("equip_max_stage") then isKyAwaken = false end
    self.awakenDzBtn.enabled = isKyAwaken
end
--返回属性描述
function SuitDzPanel:getAttriStr(attiData,nextData)
    local t1 = GConfDataSort(attiData)
    local t2 = GConfDataSort(nextData)
    local str = ""--当前属性
    local url = ResPath.iconload("shengxing_003","forging")
    local imgStr = mgr.TextMgr:getImg(url)
    for k,v in pairs(t1) do
        local value = v[2]
        local cur = conf.RedPointConf:getProName(v[1]).."+"..GProPrecnt(v[1],value)
        local nextStr = imgStr..language.forging88
        if t2[k] then
            nextStr = imgStr..mgr.TextMgr:getTextColorStr(GProPrecnt(t2[k][1],t2[k][2]), 7)
        end
        if not nextData then
            nextStr = ""
        end
        local str1 = cur..nextStr
        if k ~= #t1 then 
            str1 = str1.."\n" 
        end
        str = str..str1
    end
    return str
end
--显示套装属性
function SuitDzPanel:setSuitData()
    if self.equipData then
        local t = clone(self.equipData)
        t.isquan = true
        GSetItemData(self.chooseItem, t, true)--装备icon
        self.chooseName.text = mgr.TextMgr:getColorNameByMid(self.equipData.mid)--装备名字
        local part = conf.ItemConf:getPart(self.equipData.mid)
        local stage = conf.ItemConf:getStagelvl(self.equipData.mid)
        local color = conf.ItemConf:getQuality(self.equipData.mid)
        local star = mgr.ItemMgr:getColorBNum(self.equipData)
        local minStar,minColor = 0,0,0--最小锻造阶数,最小锻造星数,最小锻造品质
        if self.openIndex == ZHUX or self.openIndex == SZHUX then--诛仙套装
            minStar = conf.ForgingConf:getValue("equip_suit_zx_min_star")
            minColor = conf.ForgingConf:getValue("equip_suit_zx_min_color")
        else--诸神套装
            minStar = conf.ForgingConf:getValue("equip_suit_zs_min_star")
            minColor = conf.ForgingConf:getValue("equip_suit_zs_min_color")
        end
        local confData = conf.ForgingConf:getEquipJuexing(self:getAwakenId(self.openIndex,part))
        if not (color >= minColor and star >= minStar) then--无属性
            self.c1.selectedIndex = 1
            self.awakenDzBtn.enabled = false
        else--有属性
            self.c1.selectedIndex = 0
            local awakenData = cache.PackCache:getSuitAwakenData(part)
            local effectlv = self:getSuitLvAndNum()
            local mSuitId = self.mSuitEffectId * 100 + effectlv * 1000 + 3
            if effectlv == 0 then mSuitId = mSuitId + 1000 end
            local effectList = conf.ForgingConf:getAwakenSuitEffect(mSuitId)
            self.effectList = effectList
            local name = effectList[1].name or ""
            self.titleDesc.text = name--套装名字
            self.attiListView.numItems = #self.effectList
            local num = 0
            for k,v in pairs(cache.PackCache:getSuitAwakens()) do--计算当期阶激活了多少装备
                if self.openIndex == SZHUX or self.openIndex == SZHUS then
                    if k > ZMAX then
                        if self.openIndex == SZHUX then
                            if v.zxLev >= 1 then num = num + 1 end
                        elseif self.openIndex == SZHUS then
                            if v.zxLev >= 1 and v.zsLev >= 1 then--必须要锻造了诛仙才可以锻造诸神
                                num = num + 1
                            end
                        end
                    end
                elseif self.openIndex == ZHUX or self.openIndex == ZHUS then--诛仙
                    if k <= ZMAX then
                        if self.openIndex == ZHUX then
                            if v.zxLev >= 1 then num = num + 1 end                                 
                        elseif self.openIndex == ZHUS then
                            if v.zxLev >= 1 and v.zsLev >= 1 then--必须要锻造了诛仙才可以锻造诸神
                                num = num + 1
                            end
                        end
                    end
                end
            end
        end
        self.part = part
    else
        self.c1.selectedIndex = 1
        self.awakenDzBtn.enabled = false
        for k,v in pairs(self.materialList) do--显示材料
            v:GetChild("n2").text = ""
            GSetItemData(v:GetChild("n0"), {isCase = 1,color = 5}, true)
            v:GetChild("n3").visible = true
        end
        self.chooseItem.visible = false
        self.chooseName.text = ""
    end
end
--计算套装等级和对应的装备数量
function SuitDzPanel:getSuitLvAndNum(key,max)
    local index = self.openIndex--计算单件套装类型（看配置）
    local num = 0
    local awakens = cache.PackCache:getSuitAwakens()
    local minLv = 0
    local count = 0
    local scount = 0
    for k,v in pairs(awakens) do--计算当前要激活的等级
        local isCan = false
        if index == ZHUX or index == ZHUS then
            if v.part <= ZMAX then 
                isCan = true
                count = count + 1
            end
        else
            if v.part > ZMAX then 
                isCan = true
                scount = scount + 1
            end
        end
        if isCan then
            if index == SZHUX or index == ZHUX then
                if minLv == 0 then minLv = v.zxLev end
                if v.zxLev < minLv then minLv = v.zxLev end
            elseif index == ZHUS or index == SZHUS then--诛仙
                if minLv == 0 then minLv = v.zsLev end
                if v.zsLev < minLv then minLv = v.zsLev end
            end
        end
    end
    if index == ZHUX or index == ZHUS then
        if count < 8 then minLv = 1 end
    else
        if scount < 4 then minLv = 1 end
    end
    if minLv == 0 then minLv = 1 end
    if key and max and key == max then minLv = minLv + 1 end
    for k,v in pairs(awakens) do--计算当期阶激活了多少装备
        local isCan = false
        if index == ZHUX or index == ZHUS then
            if v.part <= ZMAX then isCan = true end
        else
            if v.part > ZMAX then isCan = true end
        end
        if isCan then
            if index == SZHUX or index == ZHUX then
                if v.zxLev >= minLv then num = num + 1 end
            elseif index == ZHUS or index == SZHUS then--诛仙
                if v.zsLev >= minLv then num = num + 1 end
            end
        end
    end
    return minLv,num
end
--属性预览
function SuitDzPanel:cellAttiData(key,cell)
    local data = self.effectList[key + 1]
    local equipNum = data.equip_num
    local suitType = math.floor(data.id / 100000)--计算套装类型
    local index = self.openIndex--计算单件套装类型（看配置）
    local str = ""
    if index == ZHUX or index == ZHUS then
        str = language.forging90
    elseif index == SZHUX or index == SZHUS then--诛仙
        str = language.forging91
    end
    local minLv,num = 0,0
    if key > 0 then
        minLv,num = self:getSuitLvAndNum(key + 1,#self.effectList)
    else
        minLv,num = self:getSuitLvAndNum()
    end
    cell:GetChild("n0").text = string.format(str, language.gonggong21[minLv],minLv)
    local str1 = string.format(language.forging93, num, equipNum)
    local color = 14
    local str2 = language.gonggong09
    if num >= equipNum then
        color = 7
        str2 = language.gonggong10
    end
    cell:GetChild("n2").text = language.forging92..mgr.TextMgr:getTextColorStr(str1, 7)..mgr.TextMgr:getTextColorStr(str2, color)
    cell:GetChild("n1").text = self:getAttriStr(data)
end
--套装预览
function SuitDzPanel:onClickSuitItem(context)
    local cell = context.sender
    local data = cell.data
    if self.openIndex == data.index then
        self.openIndex = 0
    else
        self.openIndex = data.index
    end
    self.titleDesc.text = data.title
    self.mSuitEffectId = data.suitId
    self:setListViewData()
end

function SuitDzPanel:onClickItem(context)
    local cell = context.sender
    local data = cell.data
    self.equipData = data.equipData
    self:refreshChoose()
end
--觉醒
function SuitDzPanel:onClickSuitAwaken()
    local reqType = self:getSuitIndex()
    if reqType == 2 then
        local awakenData = cache.PackCache:getSuitAwakenData(self.part)
        local confData = conf.ForgingConf:getEquipJuexing(self:getAwakenId())
        local conZxLev = confData and confData.con_zx_lev or 0
        if awakenData.zxLev < conZxLev then
            GComAlter(string.format(language.forging89, conZxLev))
            return
        end
    end
    
    proxy.ForgingProxy:send(1100116,{reqType = reqType, part = self.part})
end

function SuitDzPanel:onClickRule()
    GOpenRuleView(1054)
end

function SuitDzPanel:clear()

end

return SuitDzPanel