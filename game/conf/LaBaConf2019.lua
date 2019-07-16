--
-- Author: Your Name
-- Date: 2018-09-18 14:51:55
--
local LaBaConf2019 = class("LaBaConf2019",base.BaseConf)

function LaBaConf2019:init()
    self:addConf("lb_global")
    self:addConf("lb_login_award")--登录有礼
    self:addConf("lb_exchange")--腊八兑换
    self:addConf("lb_rank")--腊八排行
    self:addConf("lb_showlist")--腊八
end

function LaBaConf2019:getValue(id)
    return self.lb_global[tostring(id)]
end

function LaBaConf2019:getShowList()
    -- body
    return table.values(self.lb_showlist)
end

--登录有礼
function LaBaConf2019:getLoginAwardById(id)
    return self.lb_login_award[tostring(id)]
end

--腊八兑换
function LaBaConf2019:getExchange(flag)
    local data = {}
    for k,v in pairs(self.lb_exchange) do
        if flag == v.flag then
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

--腊八兑换id
function LaBaConf2019:getExchangeById(id)
    return self.lb_exchange[tostring(id)]
end
return LaBaConf2019