--
-- Author: 
-- Date: 2018-02-24 16:12:54
--
local RuneCache = class("RuneCache",base.BaseCache)
--[[
符文缓存
--]]
function RuneCache:init()
    self.fwDatas = {}
    self.equipFwDatas = {}
end

function RuneCache:setPackData(data)
    self.fwDatas = data.fwDatas--符文信息
end

function RuneCache:setEquipFwDatas(data)
    self.equipFwDatas = data--已装备符文数据
end

function RuneCache:getPackData()
    return self.fwDatas or {}
end

function RuneCache:getEquipFwDatas()
    return self.equipFwDatas or {}
end
--获取符文信息
function RuneCache:getPackDataByid(id)
    for k,v in pairs(self:getPackData()) do
        if v.mid == id then
            return v
        end
    end
    return nil
end
--获取符文等级高的符文
function RuneCache:getPackDataMaxId(id)
    local data = {}
    for k,v in pairs(self:getPackData()) do
        if v.mid == id then
            table.insert(data, v)
        end
    end
    table.sort(data,function(a,b)
        local aLv = a.propMap and a.propMap[517] or 0
        local bLv = b.propMap and b.propMap[517] or 0
        return aLv > bLv
    end)
    return data[1] or nil
end

function RuneCache:getEquipFwDataById(id)
    for k,v in pairs(self:getEquipFwDatas()) do
        if v.mid == id then
            return v
        end
    end
    return nil
end

function RuneCache:getEquipFwDataByType(types)
    local tCons = types or {}
    for k,v in pairs(self:getEquipFwDatas()) do
        local cons = conf.ItemConf:getContainType(v.mid) or {}
        for k,iType in pairs(cons) do
            for k,type in pairs(tCons) do
                if iType == type then
                    return v
                end
            end
        end
    end
    return nil
end
--有可镶嵌的符文
function RuneCache:isInlayRune()
    local data = {}
    for k,v in pairs(self:getPackData()) do
        local cons = conf.ItemConf:getContainType(v.mid)
        local equip = self:getEquipFwDataByType(cons)
        if not equip then
            return true
        end
    end
    return false
end

function RuneCache:getEquipFwDataByIndex(index)
    for k,v in pairs(self:getEquipFwDatas()) do
        if v.index == index then
            return v
        end
    end
    return nil
end

function RuneCache:updateRuneData(changeItems)
    for _,v1 in pairs(changeItems) do
        local isFind = false
        for k,v2 in pairs(self.fwDatas) do
            if v1.index == v2.index then
                isFind = true
                if v1.amount <= 0 then--删除
                    table.remove(self.fwDatas, k)
                    break
                else
                    self.fwDatas[k] = v1
                end
            end
        end
        if not isFind then
            table.insert(self.fwDatas, v1)
        end
    end
end

return RuneCache