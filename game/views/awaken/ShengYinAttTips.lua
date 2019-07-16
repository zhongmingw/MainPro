--
-- Author: 
-- Date: 2018-09-17 15:55:01
--

local ShengYinAttTips = class("ShengYinAttTips", base.BaseView)

function ShengYinAttTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function ShengYinAttTips:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    self.content = self.view:GetChild("n5"):GetChild("n5")
end

function ShengYinAttTips:initData(data)
    local equippedPartData = cache.PackCache:getShengYinEquipData()
    -- printt("已装备",equippedPartData)
    local allAttData = {}
    --装备道具属性
    for k,v in pairs(equippedPartData) do
        local attiData = conf.ItemArriConf:getItemAtt(v.mid)
        local t = GConfDataSort(attiData)
        self:setHashData(t,allAttData)
    end



    --激活套装属性
    if data and data.suitInfo then
        for k,v in pairs(data.suitInfo) do
            local suitData = conf.ShengYinConf:getSuitAttrById(v)--套装属性
            local t = GConfDataSort(suitData)
            -- printt("激活套装",suitData)
            self:setHashData(t,allAttData)              

        end
    end
    --强化属性
    local partInfo = cache.AwakenCache:getShengYinPartInfo()
    local strengAttList = {}
    for k,v in pairs(partInfo) do
        if v.strenLev > 0 then
            local strengInfo = conf.ShengYinConf:getStrenInfo(v.part,v.strenLev)
            local t = GConfDataSort(strengInfo)
            self:setHashData(t,allAttData)              
        end

    end

    -- printt("所有属性",allAttData)
    for k,v in pairs(allAttData) do
        if tonumber(v[1]) >= 340 and tonumber(v[1]) <= 350 then
            v.type = 1--灵力
        else
            v.type = 2--基础属性
        end
    end
    table.sort(allAttData,function (a,b)
        if a.type ~= b.type then
            return a.type < b.type
        elseif a[1] ~= b[1] then
            return a[1] < b[1]
        end
    end )
    local str = ""
    for k,v in pairs(allAttData) do
        local str1 = conf.RedPointConf:getProName(v[1]).." [color=#0B8109]+"..GProPrecnt(v[1],math.floor(v[2])).."[/color]"
       
        if k ~= #allAttData then
            str1 = str1.."\n"
        end
        str = str..str1
    end

    --极品属性
    local colorAttList = {}
    for k,v in pairs(equippedPartData) do
        self:addColorAtt(v.colorAttris,colorAttList)
    end
    -- printt("极品属性",colorAttList)
    local colorStr = ""
    if #colorAttList > 0 then
        for k,v in pairs(colorAttList) do
            local str1 = self:attiCallback(v.type,v.value)
            if k~= #colorAttList then
                str1 = str1.."\n"
            end
            colorStr = colorStr..str1
        end
    end
    str = str .."\n".. colorStr
    self.content.text = str
end

--极品属性
function ShengYinAttTips:attiCallback(id,value)
    -- body
    local attiData = conf.ItemConf:getEquipColorAttri(id)
    local color = attiData and attiData.color or 1
    local attType = attiData and attiData.att_type or 0
    local name = conf.RedPointConf:getProName(attType)
    local maxColor = conf.ItemConf:getEquipColorGlobal("max_color")
    local attiValue = "+"..GProPrecnt(attType,value)
    if color >= maxColor then--是否是最高品质
        local attiRange = attiData.att_range or {}
        local maxValue = attiRange[#attiRange] and attiRange[#attiRange][2]
        if maxValue and value >= maxValue then
            attiValue = attiValue--..language.pack41--获得了最佳的极品属性
        end
    end
    local str = ""
    local atti = 0
    str = name..attiValue
    return mgr.TextMgr:getQualityAtti(str,color)
end

function ShengYinAttTips:setHashData(data,tar)
    for k,v in pairs(data) do
        local flag = false
        for i,j in pairs(tar) do
            if j[1] == v[1] then
                tar[i][2] = j[2] + v[2]
                flag = true
            end
        end
        if not flag then
            table.insert(tar,v)
        end
    end
end

--相同类型的极品属性相加
function ShengYinAttTips:addColorAtt(data,tar)
    for k,v in pairs(data) do
        local attType1 = conf.ItemConf:getEquipColorAttri(v.type).att_type
        local flag = false 
        for i,j in pairs(tar) do
            local attType2 = conf.ItemConf:getEquipColorAttri(j.type).att_type
            if attType1 == attType2 then
                j.value = j.value +v.value
                flag = true
            end
        end
        if not flag then
            table.insert(tar,v)
        end
    end
end

return ShengYinAttTips