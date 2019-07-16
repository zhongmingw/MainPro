--
-- Author: 
-- Date: 2018-07-24 17:16:37
--仙侣PK
local XianLvCache = class("XianLvCache",base.BaseCache)
--[[

--]]
function XianLvCache:init()
    self.targetAwardSigns = {}--目标已领取奖励
    self.stakeInfo = {}--押注信息
    self.vsInfo = {}--对决信息
    self.myHp = 1

end
--目标已领取奖励(海选阶段)
function XianLvCache:setTargetAwardSigns(data)
    self.targetAwardSigns = data
end

function XianLvCache:getTargetAwardSigns()
    return self.targetAwardSigns
end
--设置押注缓存
function XianLvCache:setStakeInfo(data)
    self.stakeInfo = data
end

function XianLvCache:getStakeInfo()
    return self.stakeInfo
end
--对决缓存
function XianLvCache:setVsInfo(data)
    self.vsInfo = data
end
function XianLvCache:getVsInfo()
    return self.vsInfo
end

function XianLvCache:setMyHp(hp)
    self.myHp = hp
end
function XianLvCache:getMyHp()
    return self.myHp
end

function XianLvCache:setTeamId(teamId)
    self.teamId = teamId
end
function XianLvCache:getTeamId()
    return self.teamId
end
--多开id
function XianLvCache:setMulActiveId(mulActiveId)
    self.mulActiveId = mulActiveId
end

function XianLvCache:getMulActiveId()
    return self.mulActiveId
end


return XianLvCache