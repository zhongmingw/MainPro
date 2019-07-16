--
-- Author: 
-- Date: 2018-12-11 17:35:18
--
local DongZhiConf = class("DongZhiConf",base.BaseConf)

function DongZhiConf:init()
      self:addConf("ws_login_award")--登录有礼
    self:addConf("ws_recharge")--冬至连冲
    self:addConf("ws_lottery")--冬至抽奖
    self:addConf("ws_exchange")--冬至兑换
    self:addConf("ws_global")--global
    self:addConf("dz_showlist")--标题展示
    self:addConf("ws_rank_award")--记忆饺宴排行
    self:addConf("ws_memory")--记忆饺宴
    self:addConf("ws_item")



end

--登录有礼
function DongZhiConf:getLoginAwardById(id)
    return self.ws_login_award[tostring(id)]
end

--冬至兑换
function DongZhiConf:getDuiHuanData()
    local data = {}
    for k,v in pairs(self.ws_exchange) do
        table.insert(data,v)
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--记忆饺宴排行
function DongZhiConf:getRankData()
    local data = {}
    for k,v in pairs(self.ws_rank_award) do
        table.insert(data,v)
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
function DongZhiConf:getShowList()
    -- body
    return table.values(self.dz_showlist)
end

function DongZhiConf:getGlobal(value)
    -- body
   return self.ws_global[tostring(value)]
end


--冬至抽奖
function DongZhiConf:getDongZhiCHouJiang(typef)
    local data = {}
    for k,v in pairs(self.ws_lottery) do
        if v.type == typef then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--冬至抽奖
function DongZhiConf:getDongZhiCHouJiangShow()
    local data = {}
    for k,v in pairs(self.ws_lottery) do
        if v.show then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--冬至连冲
function DongZhiConf:getDongZhiLianChong()
    local data = {}
    for k,v in pairs(self.ws_recharge) do
        table.insert(data,v)
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end


--记忆饺宴
function DongZhiConf:getDongZhiJiaoYan(id)
    return self.ws_memory[tostring(id)]
end

--记忆饺宴
function DongZhiConf:getDongZhiJiaoYanNum()
    local data = {}
    for k,v in pairs(self.ws_memory) do
        table.insert(data,v)
    end
    table.sort(data,function (a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function DongZhiConf:getDongZhiItem()
    local data = {}
    for k,v in pairs(self.ws_item) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end


return DongZhiConf