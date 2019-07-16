--
-- Author: 
-- Date: 2017-01-21 15:56:08
--
local RedPointConf = class("RedPointConf",base.BaseConf)

function RedPointConf:init()
    self:addConf("redpoint")
    self:addConf("sortpro")
end

function RedPointConf:getDataById(id)
    -- body
    if not id then
        self.error(" id 没有传")
    end
    return self.redpoint[id..""]
end

function RedPointConf:getProSort(id)
    -- body
    return self.sortpro[id..""] and self.sortpro[id..""].sort or 9999
end

function RedPointConf:getProName( id )
    -- body
    return self.sortpro[id..""] and self.sortpro[id..""].name or ""
end

function RedPointConf:getIsPrcent(id)
    -- body
    return self.sortpro[id..""] and self.sortpro[id..""].isprecent or 0
end

function RedPointConf:getDec( id )
    -- body
    return self.sortpro[id..""] and self.sortpro[id..""].dec or "" 
end
--极品属性评分
function RedPointConf:getScore( id )
    local score = self.sortpro[tostring(id)] and self.sortpro[tostring(id)].score or 0
    return score
end

function RedPointConf:getaddtobase( id )
    -- body
    return self.sortpro[id..""] and self.sortpro[id..""].addtobase or nil 
end

return RedPointConf