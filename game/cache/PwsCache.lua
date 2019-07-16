--跨服排位赛缓存
local PwsCache = class("PwsCache",base.BaseCache)

function PwsCache:init()
    self.data = {}
    self.soloOverData = {}
    self.teamOverData = {}
    self.teamId = 0
    self.teamList = {} --当前队伍成员信息
    self.teamInfo = {} --当前队伍信息
    self.canjoin = 0 --是否有资格加入战队
    self.isSoloBuy = false --是否提示购买单人排位次数false为提示
    self.isTeamBuy = false --是否提示购买组队排位次数false为提示
    self.pwsType = 1 --1、单排 2、组排 3、季后赛
    self.myHp = 1 --用于记录玩家当前组队排位赛或者季后赛的血量
end

function PwsCache:setTeamId(teamId)
    self.teamId = teamId
end
function PwsCache:getTeamId()
    return self.teamId
end
function PwsCache:setMyHp(hp)
    self.myHp = hp
end

function PwsCache:getMyHp()
    return self.myHp
end

function PwsCache:setCanJoin(sign)
    self.canjoin = sign
end

function PwsCache:getCanJoin()
    return self.canjoin
end

function PwsCache:setIsSoloBuy(flag)
    self.isSoloBuy = flag
end
function PwsCache:getIsSoloBuy()
    return self.isSoloBuy
end
function PwsCache:setIsTeamBuy(flag)
    self.isTeamBuy = flag
end
function PwsCache:getIsTeamBuy()
    return self.isTeamBuy
end

--单人排位赛结算广播信息缓存
function PwsCache:setSoloOverData(data)
    self.soloOverData = data
end
--获取单人排位赛结算缓存
function PwsCache:getSoloOverData()
    return self.soloOverData
end
--组排结算广播信息缓存
function PwsCache:setTeamOverData(data)
    self.teamOverData = data
end
function PwsCache:getTeamOverData(data)
    return self.teamOverData
end
--当前排位类型
function PwsCache:setPwsType(pwsType)
    self.pwsType = pwsType
end
function PwsCache:getPwsType()
    return self.pwsType
end
--队伍成员信息
function PwsCache:setTeamList(data)
    self.teamList = data
end

function PwsCache:getTeamList()
    return self.teamList
end
--当前队伍信息
function PwsCache:setTeamInfo(data)
    self.teamInfo = data
end
function PwsCache:getTeamInfo()
    return self.teamInfo
end

--是否是队长
function PwsCache:isCaptain(roleId)
    if roleId == self.teamInfo.captainRoleId then
        return true
    end
    return false
end
return PwsCache