--
-- Author: 
-- Date: 2017-12-26 16:05:25
--
local ActivityWarCache = class("ActivityWarCache",base.BaseCache)
--[[
活动玩法缓存
--]]
function ActivityWarCache:init()

end

function ActivityWarCache:setXdzzData(data)
    self.xdzzData = data
end

function ActivityWarCache:getXdzzData()
    return self.xdzzData
end

function ActivityWarCache:setXdzzBoss(bossList)
    self.bossList = bossList
end

function ActivityWarCache:updateXdzzBoss(bossList)
    if self.bossList then
        local bossList = bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris[601]
            for k2,v2 in pairs(self.bossList) do
                local mMonsterId = v2.attris[601]
                if monsterId == mMonsterId then
                    self.bossList[k2] = v1
                end
            end
        end
    end
end

function ActivityWarCache:getXdzzBoss()
    return self.bossList
end

function ActivityWarCache:setCdmhData(data)
    self.cdmhData = data
end

function ActivityWarCache:getCdmhData()
    return self.cdmhData
end

function ActivityWarCache:updateCdmhData(data)
    if self.cdmhData then
        self.cdmhData.curQuestionNum = data.curQuestionNum
        self.cdmhData.myScore = data.myScore
        self.cdmhData.ranking = data.ranking
    end
end

function ActivityWarCache:updateRankData(data)
    if self.cdmhData then
        self.cdmhData.scoreRankings = data.scoreRankings
    end
end


return ActivityWarCache