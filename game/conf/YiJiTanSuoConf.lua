--
-- Author: 
--遗迹探索
local YiJiTanSuoConf = class("YiJiTanSuoConf",base.BaseConf)
local table = table

function YiJiTanSuoConf:init()
    self:addConf("yjts_global")--
    self:addConf("city_info")--城池信息
    self:addConf("yjts_log")--探索记录
end

function YiJiTanSuoConf:getYiJiGlobal(id)
    return self.yjts_global[tostring(id)]
end

--所有城池信息
function YiJiTanSuoConf:getCityInfo()
    -- body
    local data = {}
    local tab = table.values(self.city_info)
    table.sort(tab,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    for k,v in pairs(tab) do
        local _type = math.floor(v.id/1000)
        if not data[_type] then
            data[_type] = {}
            table.insert(data[_type],v)
        else
            table.insert(data[_type],v)
        end
    end
    return data
end

function YiJiTanSuoConf:getAllCityData()
    return self.city_info
end

--根据id获取当前城池信息
function YiJiTanSuoConf:getCityInfoById(id)
    return self.city_info[tostring(id)]
end

--探索记录
function YiJiTanSuoConf:getRecordById(id)
    return self.yjts_log[tostring(id)]
end

return YiJiTanSuoConf