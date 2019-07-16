--
-- Author: 
-- Date: 2018-09-10 16:21:12
--
local GanEnConf = class("GanEnConf",base.BaseConf)

function GanEnConf:init()
  
    self:addConf("ge_login_award")
    self:addConf("ge_marry")
    self:addConf("ge_gift")
    self:addConf("ge_showlist")

    


end

function GanEnConf:getShowList()
    -- body
    return table.values(self.ge_showlist)
end

-- function GanEnConf:getChongZhiHaoLi()
--     -- body
--     return table.values(self.zq_czhl)
-- end

function GanEnConf:getLoginAwardById(id)
    -- body
     return self.ge_login_award[tostring(id)]
end

function GanEnConf:getMarry(id)
    -- body
    return self.ge_marry[tostring(id)]
end

function GanEnConf:getmyGift()
    -- body
    local  data1 = {}
    for k,v in pairs( self.ge_gift) do
        if v.sub_type == 1 then
            table.insert(data1,v)
        end
    end
    table.sort(data1,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
 
    return data1
end

function GanEnConf:getbanlvGift()
     local  data2 = {}
    for k,v in pairs( self.ge_gift) do
        if v.sub_type == 2 then
            table.insert(data2,v)
        end
    end 
    table.sort(data2,function(a,b)
       if a.id ~= b.id then
            return a.id < b.id
        end
    end)
  
    return data2
end
return GanEnConf