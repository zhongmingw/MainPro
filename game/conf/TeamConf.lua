--
-- Author: 
-- Date: 2017-11-02 16:37:02
--
local TeamConf = class("TeamConf",base.BaseConf)

function TeamConf:init()
    self:addConf("team_config")
end

function TeamConf:getTeamConfig(sceneId)
    return self.team_config[tostring(sceneId)]
end

function TeamConf:getTeamConfigs()
    local list = {}
    for k,v in pairs(self.team_config) do
        local lvlSection = v.lv_section or {}
        local lv1 = lvlSection[1] or 1
        local lv2 = lvlSection[2] or 500
        if cache.PlayerCache:getRoleLevel() >= lv1 and cache.PlayerCache:getRoleLevel() <= lv2 then
            table.insert(list, v)
        end
    end
    table.sort(list,function(a,b)
        return a.sort < b.sort
    end)
    return list
end


return TeamConf