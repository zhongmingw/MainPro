--
-- Author: ohf
-- Date: 2017-02-20 14:54:18
--
local PackConf = class("PackConf",base.BaseConf)

function PackConf:init()
    self:addConf("pack_grid_open")--背包格子
    self:addConf("house_grid_open")--仓库格子
end

function PackConf:getPackGird(id)
    local gird = self.pack_grid_open[id..""]
    if not gird then 
        self:error(id)
        return nil
    end
    return gird
end

function PackConf:getPackAllGird()
    return self.pack_grid_open
end

function PackConf:getWareGird(id)
    local gird = self.house_grid_open[id..""]
    if not gird then 
        self:error(id)
        return nil
    end
    return gird
end

return PackConf