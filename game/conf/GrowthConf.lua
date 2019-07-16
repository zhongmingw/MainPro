--
-- Author: 
-- Date: 2017-02-07 15:28:30
--
local GrowthConf = class("GrowthConf",base.BaseConf)

function GrowthConf:init()
    self:addConf("power")

    self:addConf("growth_other")

    self:addConf("growth_desc")

    self:addConf("growth_tips") --变强提示
end

function GrowthConf:getGrowthByLevel(level)
    -- body
    return self.power[level..""]
end

function GrowthConf:getGrowthDescById(id)
    -- body
    return self.growth_desc[id..""]
end

function GrowthConf:getGrowthOtherByType(Tid)
    -- body
    local conf={}
    for k,v in pairs(self.growth_other) do
        if v.type==Tid then
            table.insert(conf,v)
        end
    end
    table.sort(conf,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return conf
end

--变强提示
function GrowthConf:getGrowthTipsConf()
    -- body
    local OpenModuleConf = self:getIsShowRedPointByConf()

    local tempConf = {}
    for k,v in pairs(self.growth_tips) do
        if OpenModuleConf[v.moduleId] then 
            table.insert(tempConf,v)
        end 
    end

    table.sort(tempConf,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)

    return tempConf
end
--变强提示2 （用于红点设置）
function GrowthConf:getIsShowRedPointByConf()
    -- body
    local curRoleLv = cache.PlayerCache:getRoleLevel()
    local tempConf = {}

    -- print("宠物红点 10255",cache.PlayerCache:getRedPointById(10255))

    for _, v in pairs(self.growth_tips) do
        if v.redPoint then 
            if v.openLv then
                if v.openLv <= curRoleLv then
                    for _, j in pairs(v.redPoint) do
                        local redPointVar = cache.PlayerCache:getRedPointById(j)

                        if redPointVar > 0 and not tempConf[v.moduleId] then 
                            -- print("当前加入的红点值：",redPointVar,"模块为：",moduleId)
                            table.insert(tempConf,v.moduleId,true)
                        end
                    end
                end
            else
                for _, j in pairs(v.redPoint) do
                    local redPointVar = cache.PlayerCache:getRedPointById(j)

                    if redPointVar > 0 and not tempConf[v.moduleId] then 
                        -- print("当前加入的红点值：",redPointVar,"模块为：",moduleId)
                        table.insert(tempConf,v.moduleId,true)
                    end
                end 
            end           
        end 
    end

    return tempConf
end

return GrowthConf