--
-- Author: 
-- Date: 2018-12-10 14:51:14
--2018圣诞节
local ShengDanConf = class("ShengDanConf",base.BaseConf)

function ShengDanConf:init()
    self:addConf("mc_global")
    self:addConf("mc_wish")--许愿圣诞树
    self:addConf("mc_login")
    self:addConf("mc_exchange")
    self:addConf("mc_task_award")
    self:addConf("mc_task_info")
    self:addConf("mc_fuben_double")--双倍副本
    self:addConf("mc_recharge")--累计充值
    self:addConf("mc_item")

end

function ShengDanConf:getValue(id)
    -- body
    return self.mc_global[id..""]
end

function ShengDanConf:getLoginAward(_type,id)
    for k,v in pairs(self.mc_login) do
        if _type == math.floor(v.id/10000) and id == v.id %10000 then
            return v 
        end
    end
end

function ShengDanConf:getWishTree()
    local data = {}
    for k,v in pairs(self.mc_wish) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ShengDanConf:getExchageAward()
    local data = {}
    for k,v in pairs(self.mc_exchange) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ShengDanConf:getTaskAward()
    local data = {}
    for k,v in pairs(self.mc_task_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.score ~= b.score then
            return a.score > b.score
        end
    end)
    return data
end

function ShengDanConf:getTaskInfo()
    local data = {}
    for k,v in pairs(self.mc_task_info) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
function ShengDanConf:getDoubleFuBenInfo(id)
    return self.mc_fuben_double[tostring(id)]
end
function ShengDanConf:getZqhlAward()
    local data = {}
    for k,v in pairs(self.mc_recharge) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end


function ShengDanConf:getShengDanItem()
    local data = {}
    for k,v in pairs(self.mc_item) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end


return ShengDanConf