--
-- Author: 
-- Date: 2018-09-26 17:07:49
--
local pairs = pairs
local ShenZhuangAttTips = class("ShenZhuangAttTips", base.BaseView)

function ShenZhuangAttTips:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function ShenZhuangAttTips:initView()
     self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
     self.TextShow = self.view:GetChild("n5"):GetChild("n5")
end

function ShenZhuangAttTips:initData(data)
    local countSuit = CGActShengZhuangSuitBystartNum()

    local protable = {}
    local data = cache.PackCache:getShengZhuangEquipData()
     --累计装备属性
    if data then
        for k ,v in pairs(data) do
            --基础属性
            local _equipBase = GConfDataSort(conf.ItemArriConf:getItemAtt(v.mid)) 
            G_composeData(protable,_equipBase)
            --printt("基础属性",protable)
            --极品属性
            for i , j in pairs(v.colorAttris) do
                local attiData = conf.ItemConf:getEquipColorAttri(j.type)
                if attiData and attiData.att_type then
                    G_composeData(protable,{{attiData.att_type,j.value}})
                end
            end 
            --printt("极品属性",protable)
        end
    end
    --printt("装备总属性",protable)
    --累计套装属性
    local condata = conf.AwakenConf:getAllSuitAttr()
    table.sort(condata,function(a,b)
        -- body
        local astart = string.sub(tostring(a.id),4,4)
        local bstart = string.sub(tostring(b.id),4,4)
        if bstart == astart then
            return a.num > b.num
        else
            return astart > bstart 
        end
    end)

    local donestar = {}
    for k ,v in pairs(condata) do
        local start = string.sub(tostring(v.id),4,4)
        if countSuit["num"..start] >= v.num and not donestar[v.num] then
            --print(v.id,v.num)
            donestar[v.num] = 1
            --计算激活的
            G_composeData(protable,GConfDataSort(v))
        end
    end

    --printt("累计套装属性",protable)

    table.sort(protable,function(a,b)
        -- body 
        local asort = conf.RedPointConf:getProSort(a[1]) 
        local bsort = conf.RedPointConf:getProSort(b[1]) 
        if asort == bsort then
            return a[1]<b[1]
        else
            return asort < bsort
        end
    end)

    local str3 = ""
    for k,v in pairs(protable) do
        local var = GProPrecnt(v[1],math.floor(v[2]))
        str3 = str3..conf.RedPointConf:getProName(v[1])..  mgr.TextMgr:getTextColorStr("+"..tostring(var), 7)
        if i ~= #protable then
            str3 = str3.."\n"
        end
    end
    self.TextShow.text = str3


    -- local data = cache.PackCache:getShengZhuangEquipData()
    -- local data1 = {}
    -- local str3 = ""
    -- for k,v in pairs(data) do
    --     local attiData = conf.ItemArriConf:getItemAtt(v.mid)   -- 基础属性
    --     local JiPinData = self:jiPin(v)                  --极品属性                           
    --     G_composeData(data1, GConfDataSort(attiData))
    --     G_composeData(data1, GConfDataSort(JiPinData))
    -- end
    -- printt(data1)
    -- for k,v in pairs(data1) do
    --    str3 = str3..conf.RedPointConf:getProName(v[1]).." +".."[color=#0B8109]"..GProPrecnt(v[1],math.floor(v[2])).."[/color]"
    --     if i ~= #data1 then
    --             str3 = str3.."\n"
    --     end
    -- end
    -- self.TextShow.text = str3
end


function ShenZhuangAttTips:jiPin(data)
    local tabledata = {}
    local colorAttris = data.colorAttris
    if colorAttris and #colorAttris > 0 then--系统生成属性
        for k,v in pairs(colorAttris) do
            table.insert(tabledata,{v.type,v.value})
        end
    else
        local birthAtt = conf.ItemConf:getBaseBirthAtt(data.mid) --推荐属性
        local isTuijian = true
        if not birthAtt then--固定生成的属性不走推荐
            isTuijian = false
            birthAtt = conf.ItemConf:getBirthAtt(data.mid) or {}
        end
        for k,v in pairs(birthAtt) do
            if k % 2 == 0 then--值
                local type,value = birthAtt[k - 1],birthAtt[k]
                table.insert(tabledata, {type,value})
            end
        end
    end
    return tabledata
end

return ShenZhuangAttTips