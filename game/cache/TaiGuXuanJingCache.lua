--
-- Author: 
-- Date: 2018-10-29 16:03:14
--

local TaiGuXuanJingCache = class("TaiGuXuanJingCache",base.BaseCache)

function TaiGuXuanJingCache:init()
    self.leftTired = 0
    self.bossIndex = 0
    self.monsterId = 0
    self.agentServerId  = 0
    self.modular = 0
end

--缓存当前剩余疲劳
function TaiGuXuanJingCache:setLTValue(value)
    self.leftTired = value
end

function TaiGuXuanJingCache:getLTValue()
    return self.leftTired
end

--当前选择缓存
function  TaiGuXuanJingCache:setChooseIndex(index)
    self.bossIndex = index
end

function  TaiGuXuanJingCache:getChooseIndex()
    return self.bossIndex or 0
end

--缓存当前bossid
function  TaiGuXuanJingCache:setChooseBossId( mosterId )
     self.monsterId = mosterId
end

function  TaiGuXuanJingCache:getChooseBossId(  )
    return  self.monsterId 
end

--缓存当前服务器id
function  TaiGuXuanJingCache:setagentServerId( agentServerId )
     self.agentServerId = agentServerId
end

function  TaiGuXuanJingCache:getagentServerId( )
    return  self.agentServerId 
end

--缓存副本模块
function TaiGuXuanJingCache:setFubenModular(modular)
    self.modular = modular
end

function TaiGuXuanJingCache:getFubenModular()
    return self.modular
end

--缓存太古boss场景数据
function TaiGuXuanJingCache:setTaiGuData(data)
    self.TaiGuData = data
end

function TaiGuXuanJingCache:updateTaiGuData(data)
    if self.TaiGuData then
        local bossList = data.bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris[601]
            for k2,v2 in pairs(self.TaiGuData.bossList) do
                local mMonsterId = v2.attris[601]
                if monsterId == mMonsterId then
                    self.TaiGuData.bossList[k2] = v1
                end
            end
        end
    end
end

function TaiGuXuanJingCache:getTaiGuData()
    return self.TaiGuData
end

function TaiGuXuanJingCache:getTaiGuTime()
    return self.TaiGuData and self.TaiGuData.leftPlayTime or 0
end

return TaiGuXuanJingCache