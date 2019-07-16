--
-- Author: 
-- Date: 2018-08-08 17:26:50
--

local XianTongMgr = class("XianTongMgr")

function XianTongMgr:ctor()
    
end

--排序
function XianTongMgr:sortPet(data)
    -- body
    local onwarpet = cache.MarryCache:getCurpetRoleId()
    --排序按出战宠物排第一，其他宠物按 品质 战力 ID 降序排。
    table.sort(data,function(a,b)
        -- body
        local aonwar = a.xtRoleId == onwarpet and 1 or 2
        local bonwar = b.xtRoleId == onwarpet and 1 or 2

        if aonwar == bonwar then
            local ainfo = conf.MarryConf:getPetItem(a.xtId)
            local binfo = conf.MarryConf:getPetItem(b.xtId)
            if ainfo and binfo then
                if ainfo.color == binfo.color then
                    if a.power == b.power then
                        if a.xtId == b.xtId then
                            return a.xtRoleId < b.xtRoleId
                        else
                            return a.xtId > b.xtId
                        end
                    else
                        return a.power > b.power
                    end
                else
                    return ainfo.color > binfo.color
                end
            else
                if a.xtId == b.a.xtId then
                    return a.xtRoleId < b.xtRoleId
                else
                    return a.xtId > b.xtId
                end
                
            end
        else
            return aonwar < bonwar
        end
    end)
end


--计算宠物属性
function XianTongMgr:getPetPro(data)
    -- body
    if not data then
        return {}
    end


    local protable = {}
    local confdata = conf.MarryConf:getPetItem(data.xtId)
    --宠物等级属性
    local _confdata = conf.MarryConf:getXTlev(data.level)
    local protable = GConfDataSort(_confdata)
    --printt("宠物等级属性",protable)
    for k , v in pairs(protable) do
        protable[k][2] =  v[2] * data.growValue / 100
    end
    --printt("宠物*成长之后的",protable)
    --装备加
    if data.equipInfo then
        for k ,v in pairs(data.equipInfo) do
            --printt("装备属性 = "..k,GConfDataSort(conf.MarryConf:getEquipByLev(k,v)))
            G_composeData(protable,GConfDataSort(conf.MarryConf:getEquipByLev(k,v)))
        end
    end
    --printt("叠加装备后",protable)
    --天赋加
    local t = {}
    if data.talentInfo then
        for k , v in pairs(data.talentInfo) do
            --累积属性
            G_composeData(t,GConfDataSort(conf.MarryConf:getTalentBy(k)))
        end
    end

    --printt("protable",protable)
    for k ,v in pairs(t) do
        for i , j in pairs(protable) do
            if j[1] + 100 == v[1] then
                protable[i][2] = protable[i][2] * (1+v[2]/ 10000) 
                break
            end
        end
    end
    --printt("protable_tianfu",protable)
    return protable
end

--获取背包技能书
function XianTongMgr:getPackSkillItem()
    -- body
    local skilllist = {}
    local condata = conf.MarryConf:getAllSkill()
    for k , v in pairs(condata) do
        if v.mid then
            local packdata = cache.PackCache:getPackDataById(v.mid)
            if packdata.amount > 0 then
                table.insert(skilllist,v)
            end
        end
    end

     table.sort(skilllist,function(a,b)
        -- body
        return a.mid < b.mid
    end)

    return skilllist
end

return XianTongMgr