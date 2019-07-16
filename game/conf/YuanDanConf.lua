--
-- Author: 
-- Date: 2018-12-17 22:34:54
--
local YuanDanConf = class("YuanDanConf",base.BaseConf)

function YuanDanConf:init()
    self:addConf("ny_global")
    self:addConf("ny_login")
    self:addConf("ny_invest")--投资
    self:addConf("ny_bless")--祈福
    self:addConf("ny_recharge")--转盘
    self:addConf("ny_explore_conf")--探索
    self:addConf("ny_explore_award")--探索



end

function YuanDanConf:getValue(id)
    -- body
    return self.ny_global[id..""]
end

function YuanDanConf:getLoginAward(_type,id)
    for k,v in pairs(self.ny_login) do
        if _type == math.floor(v.id/10000) and id == v.id %10000 then
            return v 
        end
    end
end

function YuanDanConf:getQiFuDataByType(_type)
    local data = {}
    for k,v in pairs(self.ny_bless) do
        if v.type == _type then
            table.insert(data,v)
        end
    end
    table.sort(data,function ( a,b )
        return a.id < b.id
    end)
    return data
end
function YuanDanConf:getTouZiData()
    local data = {}
    for k,v in pairs(self.ny_invest) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--元旦探索
function YuanDanConf:getYuanDanTanSuoDataByType(_type)
    local data = {}
    for k,v in pairs(self.ny_explore_conf) do
        if math.floor(v.id/1000) == _type then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function YuanDanConf:getTanSuoAwardData(id)
    return self.ny_explore_award[tostring(id)]
end

function YuanDanConf:getZhuanPanData(Id)
    local data = {}
    for k,v in pairs(self.ny_recharge) do
        if math.floor(v.id/10000) == Id then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

return YuanDanConf