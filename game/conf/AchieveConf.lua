--成就配置
local AchieveConf = class("AchieveConf",base.BaseConf)

function AchieveConf:init()
    self:addConf("achieve_attr")
    self:addConf("achieve_detail")
    self:addConf("achieve_title")
end

function AchieveConf:getAttData( id )
    -- body
    return self.achieve_attr[tostring(id)] or nil
end

--当前id对应的成就信息
function AchieveConf:getAchieveInfoById(id)
    return self.achieve_detail[tostring(id)]
end

--所有成就
function AchieveConf:getAllAchieve()
    -- body
    local data = {}
    for k,v in pairs(self.achieve_detail) do
        table.insert(data,v)
    end
    return data
end
--获取每类成就的信息
function AchieveConf:getAchieveTypeData()
    local data = {}
    for k,v in pairs(self.achieve_title) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
return AchieveConf