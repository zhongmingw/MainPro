local ActivityHallConf = class("ActivityHallConf", base.BaseConf)

function ActivityHallConf:ctor()
    self:addConf("activity_hall")
    self:addConf("treble_monster")--三倍刷怪对应等级跳转配置
end

function ActivityHallConf:getactData()
    local data = {}
    for k,v in pairs(self.activity_hall) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

function ActivityHallConf:getConfBtId( id )
    return self.activity_hall[tostring(id)]
end

function ActivityHallConf:getTrebleDataByLv(lv)
    local data = {}
    for k,v in pairs(self.treble_monster) do
        if v.lev_range[1] <= lv and v.lev_range[2] >= lv then
            data = v
            break
        end
    end
    return data
end

return ActivityHallConf