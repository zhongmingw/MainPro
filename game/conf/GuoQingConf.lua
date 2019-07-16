--
-- Author: Your Name
-- Date: 2018-09-18 14:51:55
--
local GuoQingConf = class("GuoQingConf",base.BaseConf)

function GuoQingConf:init()
    self:addConf("gq_showlist")
    self:addConf("gq_global")
    self:addConf("gq_login_award")--登录有礼
    self:addConf("gq_recharge_gift")--充值大礼
    self:addConf("gq_consume_gift")--消费豪礼
    self:addConf("gq_exchange")--欢乐兑换

end

function GuoQingConf:getValue(id)
    return self.gq_global[tostring(id)]
end

function GuoQingConf:getShowList()
    -- body
    return table.values(self.gq_showlist)
end

--登录有礼
function GuoQingConf:getLoginAwardById(id)
    return self.gq_login_award[tostring(id)]
end

--充值大礼
function GuoQingConf:getRechargeAwards(id)
    return self.gq_recharge_gift[tostring(id)]
end

--消费豪礼
function GuoQingConf:getCostGiftAwards(id)
    return self.gq_consume_gift[tostring(id)]
end

--欢乐兑换
function GuoQingConf:getExchangeData()
    local data = {}
    for k,v in pairs(self.gq_exchange) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

return GuoQingConf