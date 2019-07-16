--
-- Author: 
-- Date: 2019-01-08 12:47:23
--
--
local BingXueConf = class("BingXueConf",base.BaseConf)

function BingXueConf:init()
    self:addConf("bxj_global")
    self:addConf("bxj_login")--登录有礼
    self:addConf("bxj_task_info")--冰雪节任务信息
    self:addConf("bxj_task_award")--冰雪节任务奖励
    self:addConf("bxj_exchange")--冰雪节兑换
    self:addConf("cost_lottery")--消费抽抽乐
    self:addConf("bxj_showlist")--侧边栏展示
end

function BingXueConf:getValue(id)
    return self.bxj_global[tostring(id)]
end

-- function BingXueConf:getShowList()
--     -- body
--     return table.values(self.lb_showlist)
-- end

function BingXueConf:getShowList()
    -- body
    return table.values(self.bxj_showlist)
end

--消费抽抽乐
function BingXueConf:getXiaoFeiData()
    -- body
    local data = {}
    for k,v in pairs(self.cost_lottery) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--登录有礼
function BingXueConf:getLoginAwardById(id)
    return self.bxj_login[tostring(id)]
end

--冰雪节兑换
function BingXueConf:getExchangeData()
    local data = {}
    for k,v in pairs(self.bxj_exchange) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--冰雪节任务信息
function BingXueConf:getTaskInfoData()
    -- body
    local data = {}
    for k,v in pairs(self.bxj_task_info) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--冰雪节登山任务奖励信息
function BingXueConf:getTaskAward()
    -- body
    local data = {}
    for k,v in pairs(self.bxj_task_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--腊八兑换id
-- function BingXueConf:getExchangeById(id)
--     return self.lb_exchange[tostring(id)]
-- end
return BingXueConf