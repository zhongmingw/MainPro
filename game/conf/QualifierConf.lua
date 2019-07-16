--成就配置
local QualifierConf = class("QualifierConf",base.BaseConf)

function QualifierConf:init()
    self:addConf("pws_global")
    self:addConf("pws_one_lev")--单人排位赛等级
    self:addConf("pws_one_award")--单人排位赛奖励
    self:addConf("pws_zd_lev")--组队排位赛等级
    self:addConf("pws_zd_icon")--战队图标
    self:addConf("pws_zd_award")--组队排位赛奖励
    self:addConf("pws_jhs_award")--季后赛奖励
end

--公用变量
function QualifierConf:getValue(id)
    return self.pws_global[id..""]
end

--当前等级对应单人段位数据
function QualifierConf:getPwsDataByLv( lv )
    return self.pws_one_lev[tostring(lv)]
end
--当前等级对应组队段位数据
function QualifierConf:getPwsTeamDataByLv( lv )
    return self.pws_zd_lev[tostring(lv)]
end

--单人排位赛目标奖励(1/5/10)
function QualifierConf:getPwsAwardsData()
    local data = {}
    for k,v in pairs(self.pws_one_award) do
        if v.type == 1 then
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
--单人排位目标奖励最大值
function QualifierConf:getMaxCount()
    local max = 1
    for k,v in pairs(self.pws_one_award) do
        if v.type == 1 then
            if v.con > max then
                max = v.con
            end
        end
    end
    return max
end
--排位赛竞技奖励
function QualifierConf:getPwsAimAwardsData()
    local data = {}
    for k,v in pairs(self.pws_one_award) do
        if v.type == 2 then
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
--组队排位等级信息
function QualifierConf:getPwTeamDataByLv(lv)
    return self.pws_zd_lev[tostring(lv)]
end
--组队排位赛目标奖励(1/5/10)
function QualifierConf:getPwsTeamAwardsData()
    local data = {}
    for k,v in pairs(self.pws_zd_award) do
        if v.type == 1 then
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
--组队排位目标奖励最大值
function QualifierConf:getTeamMaxCount()
    local max = 1
    for k,v in pairs(self.pws_zd_award) do
        if v.type == 1 then
            if v.con > max then
                max = v.con
            end
        end
    end
    return max
end
--组队排位赛竞技奖励
function QualifierConf:getPwsTeamAimAwardsData()
    local data = {}
    for k,v in pairs(self.pws_zd_award) do
        if v.type == 2 then
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
--战队图标
function QualifierConf:getTeamIconData()
    local data = {}
    for k,v in pairs(self.pws_zd_icon) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--根据id获取战队图标
function QualifierConf:getTeamIconById(id)
    return self.pws_zd_icon[tostring(id)]
end

--季后赛排行奖励
function QualifierConf:getPayoffAwards()
    local data = {}
    for k,v in pairs(self.pws_jhs_award) do
        if v.type == 3 then
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
--季后赛排名全服奖励
function QualifierConf:getSeverAwards()
    local data = {}
    for k,v in pairs(self.pws_jhs_award) do
        if v.type == 4 then
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

return QualifierConf