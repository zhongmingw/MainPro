local MarketConf = class("MarketConf",base.BaseConf)

function MarketConf:init()
    self:addConf("mark_config")
end

function MarketConf:getMarketTitleData()
    -- body
    local data = {}
    for _,v in pairs(self.mark_config) do
        table.insert(data,v)
    end
    return data
end

function MarketConf:getNameById( id )
    -- body
    local data = self.mark_config[id..""]
    if data then
        return data.name
    end
    return nil
end

return MarketConf