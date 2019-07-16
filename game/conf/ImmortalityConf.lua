--修仙配置
local ImmortalityConf = class("ImmortalityConf",base.BaseConf)

function ImmortalityConf:init()
    self:addConf("exp_way")               --获取经验途径配置
    self:addConf("xiuxian_active_award")  --活跃值对应奖励配置
    self:addConf("xiuxian_attr")          --属性加成配置
    self:addConf("xiuxian_global")          --属性加成配置
end

--获取修仙属性表
function ImmortalityConf:getAttrData()
    local data = {}
    for k,v in pairs(self.xiuxian_attr) do
        table.insert(data,v)
    end
    return data
end

--修仙属性读取
function ImmortalityConf:getValue(id)
    return self.xiuxian_global[tostring(id)]
end

--获取修仙等级对应属性
function ImmortalityConf:getAttrDataByLv( lv )
    if self.xiuxian_attr[tostring(lv)] then
        return self.xiuxian_attr[tostring(lv)]
    end
    return nil
end

--获取经验途径(等级开启筛选 lv)
function ImmortalityConf:getWayData( lv )
    local data = {}
    for k,v in pairs(self.exp_way) do
        if lv >= v.openLv then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if tonumber(a.sort) ~= tonumber(b.sort) then
            return tonumber(a.sort) < tonumber(b.sort)
        end
    end)
    return data
end

--获取活跃度奖励信息
function ImmortalityConf:getActiveAwardsData( id )
    local data = {}
    for k,v in pairs(self.xiuxian_active_award) do
        if math.floor(v.id/1000) == id then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if tonumber(a.id) ~= tonumber(b.id) then
            return tonumber(a.id) < tonumber(b.id)
        end
    end)
    return data
end



return ImmortalityConf