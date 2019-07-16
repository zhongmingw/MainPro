--
-- Author: 
-- Date: 2018-09-11 19:59:24
--
local ShengYinConf = class("ShengYinConf",base.BaseConf)

function ShengYinConf:init()
    self:addConf("sy_global")
    self:addConf("sy_stren_lev")--圣印强化属性
    self:addConf("sy_suit_attr")--圣印套装属性
    self:addConf("sy_shenghun")--圣魂
    self:addConf("sy_split")--分解
    self:addConf("sy_compose")--圣印合成

end
function ShengYinConf:getSycompose(id)
    return self.sy_compose[tostring(id)]
end
function ShengYinConf:getValue(id)
    return self.sy_global[tostring(id)]
end

function ShengYinConf:getSuitAttrById(id)
    return self.sy_suit_attr[tostring(id)]
end
function ShengYinConf:getSuitAttrByExtType(id)
    local data = {}
    for k,v in pairs(self.sy_suit_attr) do
        if math.floor(v.id/1000) == id then
            table.insert(data,v)
        end
    end
    table.sort( data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end )
    return data
end

function ShengYinConf:getStrenInfo(part,lv)
    for k,v in pairs(self.sy_stren_lev) do
        if (math.floor(v.id/1000)-1000) == part and v.id%1000 == lv then
            return v
        end 
    end
end
--获取所有的套装
function ShengYinConf:getSuitData()
    local data = {}
    local t = {}
    for k,v in pairs(self.sy_suit_attr) do
        table.insert(t,v)
    end
    table.sort(t, function (a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        elseif a.id ~= b.id then
            return a.id < b.id
        end
    end )
    for k,v in pairs(t) do
        local id = math.floor(v.id/1000)
        table.insert(data,id)
    end
    -- table.sort(data)
    local hashData = {}
    for k,v in pairs(data) do
        local index = table.indexof(hashData,tonumber(v))
        if not index then
            table.insert(hashData,v)
        end
    end
    -- table.sort(hashData)
    local suitData = {}
    for k,v in pairs(hashData) do
        local tempData = {}
        for _,j in pairs(self.sy_suit_attr) do
            if v == math.floor(j.id/1000) then
                table.insert(tempData,j)
            end
        end
        table.sort( tempData, function (a,b)
            if a.id ~= b.id then
                return a.id < b.id
            end
        end )
        table.insert(suitData,tempData)
    end
    return suitData
end

function ShengYinConf:shengHunInfoById(id)
    return self.sy_shenghun[tostring(id)]
end

function ShengYinConf:getShengHunData()
    local data = {}
    for k,v in pairs(self.sy_shenghun) do
        table.insert(data,v)
    end
    table.sort( data,function ( a,b )
        if a.id ~= b.id then
            return a.id < b.id
        end
    end )
    return data
end


function ShengYinConf:getSplitExp(id)
    return self.sy_split[tostring(id)]
end

-- function ShengYinConf:getCompose(color,part)
--     local id = (1000+color)*100+part
--     return self.sy_shenghun[tostring(id)]
-- end

return ShengYinConf