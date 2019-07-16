--
-- Author: 
-- Date: 2018-09-10 16:21:12
--
local ShuangShiErConf = class("ShuangShiErConf",base.BaseConf)

function ShuangShiErConf:init()
  
    self:addConf("dt_recharge_gift")
    self:addConf("dt_global")
    self:addConf("dt_thmj")
    self:addConf("dt_showlist")
    self:addConf("dt_login_award")
    

    


end

function ShuangShiErConf:getGlobal(id)
    return self.dt_global[tostring(id)]
end

function ShuangShiErConf:getTeHuiAwardByDay(curday)
     local  data = {}
    for k,v in pairs(self.dt_thmj) do
        if v.day == curday  then
            table.insert(data, v)
        end
    end
    table.sort( data, function(a,b)
        -- body
        return a.id < b.id 
    end )
    return data

  
end

function ShuangShiErConf:getShowList()
    -- body
    return table.values(self.dt_showlist)
end


function ShuangShiErConf:getLoginAwardById(id)
    -- body
     return self.dt_login_award[tostring(id)]
end

function ShuangShiErConf:getDanbiAwardById(index)
     local  data = {}
    for k,v in pairs(self.dt_recharge_gift) do
        if math.floor(v.id/1000)  == index  then
            table.insert(data, v)
        end
    end
    table.sort( data, function(a,b)
        -- body
        return a.id < b.id 
    end )
    return data
 
end

return ShuangShiErConf