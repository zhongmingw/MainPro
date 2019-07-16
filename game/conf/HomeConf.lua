--
-- Author: 
-- Date: 2017-11-14 19:20:20
--
local HomeConf = class("HomeConf",base.BaseConf)

function HomeConf:init()
    --家园配置
    self:addConf("home_btnlist")
    self:addConf("home_btn_info")
    self:addConf("home_global")
    self:addConf("home_thing")
    self:addConf("home_lev")
    self:addConf("home_skin")
    self:addConf("home_seed")
    self:addConf("home_boss_lev")

end

function HomeConf:getBossLev(id)
    -- body
    return self.home_boss_lev[tostring(id)]
end

function HomeConf:getSkins(id)
    -- body
    return self.home_skin[tostring(id)]
end
--获取特殊皮肤
function HomeConf:getTebieSkins()
    -- body
    local _t = {}
    for k ,v in pairs(self.home_skin) do
        if v.skin_type and v.skin_type == 1 then
            table.insert(_t,v)
        end
    end
    return _t
end

function HomeConf:getHomeLev( _id , lev )
    -- body
    local id = _id * 1000 +lev
    return self.home_lev[tostring(id)]
end

function HomeConf:getHomeThing(id)
    -- body
    return self.home_thing[tostring(id)]
end

function HomeConf:getSeedKey()
    -- body
    local t = {}
    for k ,v in pairs(self.home_seed) do
        table.insert(t,v.id)
    end
    return t 
end

function HomeConf:getSeedByid(id)
    -- body
    return self.home_seed[tostring(id)]
end

function HomeConf:getSeedByLevel(lv)
    -- body
    for k ,v in pairs(self.home_seed) do
        if v.level == lv then
            return v 
        end
    end
    return nil
end

function HomeConf:getValue(id)
    -- body
    return self.home_global[tostring(id)]
end

function HomeConf:getScenesInfo()
    -- body
    local _t = table.values(self.home_btnlist)
    table.sort(_t,function(a,b)
        -- body
        return a.id < b.id
    end)
    return _t
end

function HomeConf:getScenesInfoById(id)
    -- body
    return self.home_btnlist[tostring(id)]
end

function HomeConf:getBtnInfo(id)
    -- body
    return self.home_btn_info[tostring(id)]
end
return HomeConf