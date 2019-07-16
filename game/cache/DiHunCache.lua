--
-- Author: 
-- Date: 2018-11-27 11:48:44
--
local DiHunCache = class("DiHunCache",base.BaseCache)
--[[

--]]
function DiHunCache:init()
    self.colorScore = {}
    for i=3,6 do
        self.colorScore[i] = 0
    end
end


function DiHunCache:setData(data)
    self.diHunInfo = {}
    for k,v in pairs(data.infos) do
        self.diHunInfo[v.type] = v
    end
    for k,v in pairs(self.colorScore) do
        local score = data.colorScore[k] or 0
        self.colorScore[k] = score
    end
end

function DiHunCache:upDateDhInfo(data)
    self.diHunInfo[data.DhType] = data.info
end

function DiHunCache:getDiHunInfoByType(_type)
    return self.diHunInfo and self.diHunInfo[_type]
end

function DiHunCache:getScoreByColor(color)
    return self.colorScore[color]
end
--获取部位装备信息
function DiHunCache:getPartInfoByTypeAndPart(_type,part)
    local partInfo = self.diHunInfo[_type].partInfo
    for k,v in pairs(partInfo) do
        if part == v.part and v.item.mid ~= 0 then
            return v.item
        end
    end
end

function DiHunCache:getScore()
    return self.colorScore
end

function DiHunCache:upDateScore(data)
    for k,v in pairs(self.colorScore) do
        self.colorScore[k] = data[k] or 0
    end
end

function DiHunCache:setScoreByMoneyType(moneyType,score)
    local quality = {
        [MoneyType.dh1] = 3,
        [MoneyType.dh2] = 4,
        [MoneyType.dh3] = 5,
        [MoneyType.dh4] = 6,
    }
    self.colorScore[quality[moneyType]] = score
end

function DiHunCache:setDiHunTaskFinish(flag)
    self.dihunTask = flag
end

function DiHunCache:getDiHunTaskFinish()
    return self.dihunTask
end



function DiHunCache:getRed()
    local function GetMaxLvByMid(mid)
        local color = conf.ItemConf:getQuality(mid)
        local maxLvByColor = conf.DiHunConf:getValue("dh_stren_max_color")
        for k,v in pairs(maxLvByColor) do
            if v[1] == color then
                return v[2]
            end
        end
        return 0
    end
    local redNum = 0
    if self.diHunInfo then
        for k,v in pairs(self.diHunInfo) do
            if v.point == 8 and v.star ~= 5 then--可激活或升星
                redNum = redNum  +1 
            end
            if v.point < 8 then--小于8个点的时候才考虑解锁红点
                local confData = conf.DiHunConf:getDhAttById(v.type,v.star,v.point)
                local needMid = confData.items[1]
                local packData = cache.PackCache:getPackDataById(needMid)
                redNum = redNum + math.floor(packData.amount/confData.items[2])--可解锁圆点
            end
            if v.star > -1 then--已激活的
                for _,j in pairs(v.partInfo) do
                    local diHunPack = cache.PackCache:getDiHunPackDataBySubTypeAndPart(v.type,j.part)
                    if j.item.mid == 0 then--有空位置
                        if table.nums(diHunPack) > 0 then--有可装备的魂饰
                            redNum = redNum + 1
                            -- break
                        end
                    else
                        --可强化红点
                        local strengData = conf.DiHunConf:getDhStengById(v.type,j.part,j.strenLevel)
                        if strengData and  strengData.need_cost then
                            local maxLv = GetMaxLvByMid(j.item.mid)
                            --强化材料的品质
                            local quality = conf.ItemConf:getQuality(strengData.need_cost[1][1])
                            local haveScore = cache.DiHunCache:getScoreByColor(quality)
                            if tonumber(haveScore) >= tonumber(strengData.need_cost[1][2]) and j.strenLevel < maxLv  then
                                redNum = redNum + 1
                            end
                        end
                    end
                end
            end
        end
    end
    return redNum
end

return DiHunCache