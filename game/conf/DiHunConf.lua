--
-- Author: 
-- Date: 2018-11-27 12:01:11
--
local DiHunConf = class("DiHunConf",base.BaseConf)

function DiHunConf:init()
    self:addConf("dh_global")
    self:addConf("dh_info")
    self:addConf("dh_activation")
    self:addConf("dh_split")
    self:addConf("dh_stren")
    self:addConf("dh_skill")
    self:addConf("dh_equip_skill")--魂饰技能
    self:addConf("dh_task")--魂饰技能
end
function DiHunConf:getValue(id)
    return self.dh_global[tostring(id)]
end
function DiHunConf:getDiHunInfoByType(_type)
    return self.dh_info[tostring(_type)]
end
--根据类型和星数获取帝魂激活信息
function DiHunConf:getDhACtByTypeAndStar( _type,star )
    local data = {}
    for k,v in pairs(self.dh_activation) do
        if v.type == _type and v.star == star then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end


function DiHunConf:getDhAttById(_type,star,point)
    local star = star == -1 and 10 or star
    local id = ((_type*100)*10000+(star*1000))+point
    if self.dh_activation[tostring(id)] then
        return self.dh_activation[tostring(id)]
    else
        -- print("帝魂配置dh_activation缺少",id)
    end
end


function DiHunConf:getSplitExp(id)
    return self.dh_split[tostring(id)]
end

function DiHunConf:getDhStengById(_type,part,lv)
    local id = (((1000+_type)*1000+part)*1000+lv)
    return self.dh_stren[tostring(id)]
end

function DiHunConf:getDhSkillById(id)
    return self.dh_skill[tostring(id)]
end


function DiHunConf:getHsSkillByType(_type)
    local data = {}
    for k,v in pairs(self.dh_equip_skill) do
        if v.type == _type then
            table.insert(data,v)
        end
    end
    table.sort(data,function (a,b)
        return a.level < b.level
    end)
    return data
end

function DiHunConf:getDhTaskInfo()
    -- local data = {}
    -- for k,v in pairs(self.dh_task) do
    --     table.insert(data,v)
    -- end
    -- table.sort(data,function (a,b)
    --     return a.id < b.id
    -- end)
    -- return data

    local data = {}
    for k,v in pairs(self.dh_task) do
        local pre = math.floor(v.id/1000)%1000
        if not data[pre] then
            data[pre] = {}
        end
        table.insert(data[pre],v)
    end
    return data
end
function DiHunConf:getDhTaskInfoByType()
    -- body
    local data = {}
    for k,v in pairs(self.dh_task) do
        local pre = math.floor(v.id/1000)
        if not data[pre] then
            data[pre] = {}
        end
        table.insert(data[pre],v)
    end
    return data
end
return DiHunConf