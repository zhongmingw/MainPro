--活动预告

local ActivityShowConf = class("ActivityShowConf", base.BaseConf)

function ActivityShowConf:ctor()
    self:addConf("act_show")
end

function ActivityShowConf:getactData()
    local data = {}
    for k,v in pairs(self.act_show) do
        table.insert(data,v)
    end
    return data
end

function ActivityShowConf:getActDataById(modelId)
    for k,v in pairs(self.act_show) do
        if modelId == v.module_id then
            return v
        end
    end
end

return ActivityShowConf