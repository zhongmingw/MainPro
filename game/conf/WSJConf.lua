--
-- Author: 
-- Date: 2018-10-22 15:40:58
--
local WSJConf = class("WSJConf",base.BaseConf)

function WSJConf:init()
    self:addConf("wsj_global")
    self:addConf("halloween_recharge") -- 万圣节累充活动
    self:addConf("halloween_lottery") -- 捣蛋南瓜田活动       
    self:addConf("halloween_login_award") --登录累充
    self:addConf("halloween_exchange") --兑换
    self:addConf("wsj_floor_condi") --降妖除魔



end

function WSJConf:getValue(id)
    -- body
    return self.wsj_global[id..""]
end

-- 万圣节累充活动
function WSJConf:getHalloweenAward()
    local data = {}
    for k,v in pairs(self.halloween_recharge) do
        table.insert(data,v)
    end

    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

-- 捣蛋南瓜田活动
function WSJConf:getNanGuaAward()
    local data = {}
    for k,v in pairs(self.halloween_lottery) do
        if v.show and v.show == 1 then
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

function WSJConf:getNanGua()
    local data = {}
    for k,v in pairs(self.halloween_lottery) do
        table.insert(data,v)
    end
    
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function WSJConf:getLoginAward(_type,id)
    for k,v in pairs(self.halloween_login_award) do
        if _type == math.floor(v.id/10000) and id == v.id %10000 then
            return v 
        end
    end
end

function WSJConf:getExchageAward()
    local data = {}
    for k,v in pairs(self.halloween_exchange) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function WSJConf:getWSJFloorAward()
    local data = {}
    for k,v in pairs(self.wsj_floor_condi) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function WSJConf:getWSJAwardByFloor(floor)
    for k,v in pairs(self.wsj_floor_condi) do
        if v.id%100 == floor then
            return v
        end
    end
end

return WSJConf