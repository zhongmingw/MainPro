--
-- Author: 
-- Date: 2017-02-07 15:28:30
--
local MapConf = class("MapConf",base.BaseConf)

function MapConf:init()
    self:addConf("world_map_config")-- 世界地图

    self:addConf("map_details_config")-- 详细地图

    self:addConf("map_monster_place")-- 详细地图
end

function MapConf:getWorldData()
    -- body
    return self.world_map_config
end

function MapConf:getWorldDataById(id)
    -- body
    return self.world_map_config[id..""]
end

function MapConf:getDetailsData()
    -- body
    return self.map_details_config
end

function MapConf:getMonsterPlaceById(id)
    -- body
    return self.map_monster_place[id..""]
end

return MapConf