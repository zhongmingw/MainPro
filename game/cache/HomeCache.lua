--
-- Author: wx
-- Date: 2017-11-14 19:18:43
-- 家园系统
local HomeCache = class("HomeCache",base.BaseCache)
--[[

--]]
function HomeCache:init()
    self.data = nil
    self.curPlant = nil 
end
function HomeCache:setData(data)
    -- body
    self.data = data
end
function HomeCache:getData()
    -- body
    return self.data
end

function HomeCache:updateData(data)
    -- body
    self.data.homeName = data.homeName
    self.data.houseLev = data.houseLev
    self.data.wallLev = data.wallLev
    self.data.zooLev = data.zooLev
    self.data.ownerName = data.ownerName
end

function HomeCache:getisSelfHome()
    -- body
    return self.data and self.data.roleId == cache.PlayerCache:getRoleId()
end
--家园的名字
function HomeCache:setName(name)
    -- body
    if not self.data then
        return
    end
    self.data.homeName = name
end
function HomeCache:getName()
    -- body
    return self.data and self.data.homeName or ""
end
--家园等级
function HomeCache:setHomeLv(var)
    -- body
    if not self.data then
        return
    end
    self.data.houseLev = var
end
function HomeCache:getHomeLv(var)
    -- body
    return self.data and self.data.houseLev or 0
end
--围墙等级
function HomeCache:setWallLv(var)
    -- body
    if not self.data then
        return
    end
    self.data.wallLev = var
end
function HomeCache:getWallLv(var)
    -- body
    return self.data and self.data.wallLev or 0
end
--兽园等级
function HomeCache:setZoomLv(var)
    -- body
    if not self.data then
        return
    end
    self.data.zooLev = var
end
function HomeCache:getZoomLv(var)
    -- body
    return self.data and self.data.zooLev or 0
end
--温泉等级
function HomeCache:sethotSpringLev(var)
    -- body
    if not self.data then
        return
    end
    self.data.hotSpringLev = var
end
function HomeCache:gethotSpringLev(var)
    -- body
    return self.data and self.data.hotSpringLev or 0
end
--浇水次数
function HomeCache:getWaterSelf()
    -- body
    return self.data and self.data.waterSelfCount or 0
end
function HomeCache:setWaterSelf()
    -- body
    self.data.waterSelfCount = self.data.waterSelfCount + 1
end
function HomeCache:getOtherSelf()
    -- body
    return self.data and self.data.waterOtherCount or 0
end
function HomeCache:setOtherSelf()
    -- body
    self.data.waterOtherCount = self.data.waterOtherCount + 1
end
--偷窃次数
function HomeCache:getSteal()
    -- body
    return self.data and self.data.stealCount or 0
end
function HomeCache:setSteal()
    -- body
    self.data.stealCount = self.data.stealCount + 1
end

function HomeCache:setSeedData(data)
    -- body
    self.seedData = data
end
function HomeCache:getSeedData( ... )
    -- body
    return self.seedData 
end
function HomeCache:getseedAmountById(id)
    -- body
    local condata = conf.HomeConf:getSeedByid(id)
    return  cache.PackCache:getPackDataById(condata.item_mid).amount
end
function HomeCache:reduceSeed(var)
    -- body
    if not self.seedData then
        return
    end
    if self.seedData[var] then
        self.seedData[var] = self.seedData[var] - 1
    end
end
--当前选中种植的种子
function HomeCache:setPlantChoose(var)
    -- body
    self.curPlant = var
end
function HomeCache:getPlantChoose()
    -- body
    return self.curPlant
end


function HomeCache:setOsTye(var)
    -- body
    self.os = var
end
function HomeCache:getOsTye()
    -- body
    return self.os
end

function HomeCache:setCallCount(var)
    -- body
    if self.data then
        self.data.callCount = var
    end
end

function HomeCache:getCallCount()
    -- HomeCache
    if self.data and self.data.callCount then
        return self.data.callCount
    else
        return 0
    end
    return vv
end


function HomeCache:setHomeMonster( data )
    -- body
    self.homeMonster = data

    
end

function HomeCache:getHomeMonster()
    -- body
    return self.homeMonster
end

function HomeCache:setMonsterTrack(data)
    -- body
    self.monsterdata = data
end

function HomeCache:getMonsterTrack()
    -- body
    return self.monsterdata
end


--泳装状态
function HomeCache:setHomeSpring(ff)
    -- body
    self.spring = ff
    if gRole then gRole:setHome(ff) end
    
end

function HomeCache:getHomeSpring()
    -- body
    return self.spring
end

return HomeCache