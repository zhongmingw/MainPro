--
-- Author: bxp
-- Date: 2018-11-21 17:01:39
--合成缓存
local ComposeCache = class("ComposeCache",base.BaseCache)
--[[

--]]
function ComposeCache:init()

end

function ComposeCache:getXianGodData()
    local xianGod = {}
    local xiandata = cache.PackCache:getPackDataByType(Pack.xianzhuang)
    local _xian = conf.ForgingConf:getComposeValue("compose_god_xian")
    for k,v in pairs(xiandata) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata.color >= _xian[1] and mgr.ItemMgr:getColorBNum(v) == _xian[2] and condata.stage_lvl >= _xian[3] then
            if not xianGod[condata.part] then
                xianGod[condata.part] = {}
            end
            if not xianGod[condata.part][condata.color] then
                xianGod[condata.part][condata.color] = {}
            end
            if not xianGod[condata.part][condata.color][condata.stage_lvl] then
                xianGod[condata.part][condata.color][condata.stage_lvl] = {}
            end
            table.insert(xianGod[condata.part][condata.color][condata.stage_lvl],v)
        end
    end
    return xianGod
end

return ComposeCache