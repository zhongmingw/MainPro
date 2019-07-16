--
-- Author: 
-- Date: 2017-03-03 16:56:19
--
local BangPaiCache = class("BangPaiCache",base.BaseCache)
--[[

--]]
function BangPaiCache:init()
    self.data = {}
    self.member = {}
    self.boxdata = {}
end

function BangPaiCache:setGuide(var)
    -- body
    self.isGuide = var
end

function BangPaiCache:getGuide()
    -- body
    return self.isGuide
end

function BangPaiCache:setTaskReset(var)
    -- body
    self.taskreset = var
end
function BangPaiCache:getTaskReset(var)
    -- body
    return self.taskreset
end
---帮会信息
function BangPaiCache:setData(data)
    -- body
    self.data = data
end

function BangPaiCache:getData()
    -- body
    return self.data
end
--公告
function BangPaiCache:setNotice( data )
    -- bodydata
    self.data.gangNotice = data
end

function BangPaiCache:getNotice()
    -- body
    return self.data.gangNotice
end

function BangPaiCache:getmemberNum()
    -- body
    return self.data.memberNum
end

function BangPaiCache:getgangJob()
    -- body
    return self.data.gangJob
end

function BangPaiCache:getBangLev()
    -- body
    return self.data.gangLevel
end

function BangPaiCache:getBangType()
    -- body
    return self.data.gangType
end
--------------
---成员列表
function BangPaiCache:setMember( data )
    -- body
    self.member = data.members
end

function BangPaiCache:getMember()
    -- body
    return self.member
end

function BangPaiCache:getMemberById(id)
    -- body
    for k , v in pairs(self.member) do
        if v.roleId == id then
            return v 
        end
    end
end

function BangPaiCache:deleteMember(data)
    -- body
    if not self.member then
        return 
    end

    for k ,v in pairs(self.member) do
        if v.roleId == data.roleId then
            table.remove(self.member,k)
            break
        end
    end

    --plog(#self.member,"删除之后")
end
--让位帮主
function BangPaiCache:updateMember( data )
    -- body
    if not self.member then
        return 
    end

    for k ,v in pairs(self.member) do
        if v.roleId == data.roleId then
            v.job = 4 --帮主
        elseif v.roleId == cache.PlayerCache:getRoleId() then
            v.job = 0 --成员
        end
    end
end
--job 0成员 4帮主 3副帮主 2长老 1 精英
function BangPaiCache:setMemberJob(id,job)
    -- body
    for k ,v in pairs(self.member) do
        if v.roleId == id then
            v.job = job
            break
        end
    end
end

function BangPaiCache:getMemberJob(id)
    -- body
    for k ,v in pairs(self.member) do
        if v.roleId == id then
            return v.job
        end
    end
end

function BangPaiCache:getNumberByJob(id)
    -- body
    local count = 0
    for k ,v in pairs(self.member) do
        if v.job == id then
            count  = count + 1
        end
    end

    return count
end


--世界喊
function BangPaiCache:setTime(var)
    -- body
    self.time = var or 0
end

function BangPaiCache:getTime()
    -- body
    return self.time or 0
end
--宝箱协助
function BangPaiCache:setTime2(key ,var )
    -- body
    if not self.helptime then
        self.helptime = {}
    end
    self.helptime[key] = var or 0
end

function BangPaiCache:getTime2(key)
    -- body
    if not self.helptime then
        return 0
    end
    return self.helptime[key] or 0
end
---
function BangPaiCache:setBoxData(data)
    -- body
    self.boxdata = data
end

function BangPaiCache:getBoxData()
    -- body
    return self.boxdata
end

function BangPaiCache:updateBoxData( data )
    -- body
    if data.boxList then
        self.boxdata.boxList = data.boxList
    end
    if data.dayBoxOpenCount then
        self.boxdata.dayBoxOpenCount = data.dayBoxOpenCount
    end
end

function BangPaiCache:updateBoxColor( data )
    -- body
    self.boxdata.boxColor = data.boxColor
    self.boxdata.dayBoxColorCount = data.dayBoxColorCount
end

function BangPaiCache:updateXieZu( data )
    -- body
    self.boxdata.dayBoxAssistCount = data.dayBoxAssistCount
end

function BangPaiCache:getdayBoxAssistCount()
    -- body
    return self.boxdata.dayBoxAssistCount or 0
end
--是否可以参加圣火活动
function BangPaiCache:setCanJoinFire(flag)
    self.canJoinFire = flag
end
function BangPaiCache:getCanJoinFire()
    return self.canJoinFire
end
--仙盟合并倒计时限制
function BangPaiCache:setCombineTime(time)
    self.comBineTime = time
end
function BangPaiCache:getCombineTime()
    return self.comBineTime or 0
end
return BangPaiCache