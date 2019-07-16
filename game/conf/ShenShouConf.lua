--
-- Author: Your Name
-- Date: 2018-09-03 14:36:04
--

local ShenShouConf = class("ShenShouConf", base.BaseConf)

function ShenShouConf:ctor()
    self:addConf("ss_global")--
    self:addConf("shenshou_attr")--
    self:addConf("shenshou_zz_hole")--
    self:addConf("shenshou_equip_up")--
    self:addConf("shenshou_skill")--
    self:addConf("shenshou_equip_compose")--神兽装备合成
end

function ShenShouConf:getShenShouGodEquipCompose(id)
    return self.shenshou_equip_compose[tostring(id)]
end
function ShenShouConf:getShenShouGodEquipCompose2(id)
    local data = {}
    for k,v in pairs(self.shenshou_equip_compose) do
        local part =v.id%100000%10000%100
        if math.floor(v.id/100) == id and #v.cost_item == 1 then
            table.insert(data,v)
        end
    end
    return data
end

function ShenShouConf:getValue(id)
    return self.ss_global[tostring(id)]
end

function ShenShouConf:getShenShouData()
    local data = {}
    for k,v in pairs(self.shenshou_attr) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ShenShouConf:getShenShouDataById(id)
    local data = nil
    for k,v in pairs(self.shenshou_attr) do
        if v.id == id then
            data = v
        end
    end
    return data
end

--获取神兽上阵位开启限制
function ShenShouConf:getOpenLimitByNum(num)
    local data = nil
    for k,v in pairs(self.shenshou_zz_hole) do
        if num == v.id then
            data = v
            break
        end
    end
    return data
end

--
function ShenShouConf:getEquipLevelUp(data)
    local condata = conf.ItemConf:getItem(data.mid)

    local index = string.format("1%02d%02d%03d",condata.color,condata.part,data.level)
    return self.shenshou_equip_up[tostring(index)]
end

function ShenShouConf:getLevelDataById(id)
    return self.shenshou_equip_up[tostring(id)]
end

--神兽装备属性
function ShenShouConf:getEquipPro(data)
    -- body
    if not data then
        return {}
    end
    local t = {}
    if data.level > 0 then
        t = GConfDataSort(self:getEquipLevelUp(data))
    end
    
    local t1 = GConfDataSort(conf.ItemArriConf:getItemAtt(data.mid))
    G_composeData(t,t1)
    return t
end

--神兽技能
function ShenShouConf:getSkillById(id)
    return self.shenshou_skill[tostring(id)]
end

return ShenShouConf