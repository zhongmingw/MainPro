--
-- Author: 
-- Date: 2019-01-07 20:33:36
--
local XiaoNianConf = class("XiaoNianConf",base.BaseConf)

function XiaoNianConf:init()
    self:addConf("xn_login")--小年登录
    self:addConf("xn_xycc_rank")--小年降妖
    self:addConf("xn_global")--
    self:addConf("xn_showlist")--
    self:addConf("xn_exchange")--小年兑换
    self:addConf("xn_sId")--
    self:addConf("xn_jz")--小年祭灶
    self:addConf("xnhl")--小年豪礼
    self:addConf("xnpuke")--小年扑克

end

function XiaoNianConf:getPuKe(id)
    return self.xnpuke[tostring(id)]
end

function XiaoNianConf:getValue(id)
    return self.xn_global[tostring(id)]
end

function XiaoNianConf:SceneName(id)
    return self.xn_sId[tostring(id)]
end

function XiaoNianConf:getZqhlAward()
    local data = {}
    for k,v in pairs(self.xnhl) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function XiaoNianConf:getSuitFuse()
    local type = -1
    local data = {}
    for k,v in pairs(self.xn_exchange) do
        table.insert(data, v)
    end
    table.sort(data,function(a,b)
        return a.type < b.type
    end)
    local suit = {}
    for k,v in pairs(data) do
        --print("v",v.type)
        if v.type > type then
            type = v.type
            local i = #suit + 1
            local suitData = self:getSuitFuseData(type)
            local len = #suitData
            local t = {type = v.type, open = 0,suitData = suitData}
            --print("iiii",i,t,len,v.type)
            suit[i] = t
            suit[i].typename = v.type_name
        end
    end
 
    return suit
end

function XiaoNianConf:getSuitFuseData(type)
    local data = {}
    for k,v in pairs(self.xn_exchange) do
        if type == v.type then
            table.insert(data, v)
        end
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end

--小年兑换
function XiaoNianConf:getExchange(flag)
    local data = {}
    for k,v in pairs(self.xn_exchange) do
        if flag == v.type then
            table.insert(data,v)
        end
    end
    table.sort( data, function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end )
    return data
end

--小年兑换id
function XiaoNianConf:getExchangeById(id)
    return self.xn_exchange[tostring(id)]
end
--小年登录
function XiaoNianConf:getLogin()
    local data = {}
    for k,v in pairs(self.xn_login) do
        table.insert(data,v)
    end
    table.sort( data, function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end )
    return data
end

function XiaoNianConf:getXiangYaoData(type)
    local data = {}
    for k,v in pairs(self.xn_xycc_rank) do
        if v.type == type then
            table.insert(data, v)
        end
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end

function XiaoNianConf:getShowList()
    -- body
    return table.values(self.xn_showlist)
end

function XiaoNianConf:getXiaoNianJiZhao(type)
    local data = {}
    for k,v in pairs(self.xn_jz) do
        if v.type == type then
            table.insert(data, v)
        end
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end

return XiaoNianConf