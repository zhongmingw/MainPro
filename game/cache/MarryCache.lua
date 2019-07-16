--
-- Author: wx
-- Date: 2017-07-19 14:54:59
--
local MarryCache = class("MarryCache",base.BaseCache)
--[[

--]]
function MarryCache:init()
    self.data = {}
    --好友数据
    self.fiend = nil 
    --求婚列表
    self.respons = {}
    self.fubenCTime = mgr.NetMgr:getServerTime()

    self.awardId = nil 

    self.xiantongdata = {}

end

function MarryCache:setJHdata( data )
    -- body
    self.jhdata = data 
end

function MarryCache:getJHdata()
    -- body
    return self.jhdata
end

function MarryCache:setData(data)
    -- body
    self.data = data
end

function MarryCache:getData()
    -- body
    return self.data
end
--
function MarryCache:setFriendData(data)
    -- body
    self.fiend = data
end

function MarryCache:getFriendData()
    -- body
    return self.fiend
end

function MarryCache:insertData(data)
    -- body
    for k,v in pairs(self.respons) do
        if v.reqRoleId == data.reqRoleId then
            self.respons[k].grade = data.grade
            return
        end
    end
    table.insert(self.respons,data)
end

function MarryCache:deleteData()
    -- body
    table.remove(self.respons,1)
end

function MarryCache:clearRespons()
    -- body
    self.respons = {}
end

function MarryCache:getFirstResponsData()
    -- body
    return self.respons[1]
end
--情缘副本任务追踪信息
function MarryCache:setFubenData(data)
    self.fubenData = data
end

function MarryCache:getFubenData()
    return self.fubenData
end

function MarryCache:setFubenCTime(time)
    self.fubenCTime = time
end

function MarryCache:getFubenCTime()
    return self.fubenCTime
end

function MarryCache:setAppointmentData(data)
    self.yuyueData = data
end

function MarryCache:getAppointmentData()
    return self.yuyueData
end

--仙童
function MarryCache:setAwardId( var )
    -- body
    self.awardId = var
end

function MarryCache:getAwardId( ... )
    -- body
    return self.awardId
end


function MarryCache:setXTData(data)
    -- body
    self.xiantongdata = data
end
function MarryCache:getXTData()
    -- body
    --print(#self.xiantongdata.xtDatas,"self.xiantongdata.xtDatas")
    return self.xiantongdata.xtDatas
end
function MarryCache:getCurpetRoleId()
    -- body
    return self.xiantongdata.curWarRoleId
end
function MarryCache:getgetXTDataByRoleId(var)
    -- body
    for k , v in pairs(self.xiantongdata.xtDatas) do
        if v.xtRoleId == var then
            return v 
        end
    end
end

function MarryCache:setCurpetRoleId(var)
    -- body
    self.xiantongdata.curWarRoleId = var
end
function MarryCache:setXTlevel( data )
    -- body
    for k , v in pairs(self.xiantongdata.xtDatas) do
        if v.xtRoleId == data.xtRoleId then
            self.xiantongdata.xtDatas[k].level = data.level
            break
        end
    end
end
function MarryCache:setXTEquip( data )
    -- body
    for k , v in pairs(self.xiantongdata.xtDatas) do
        if v.xtRoleId == data.xtRoleId then
            self.xiantongdata.xtDatas[k].equipInfo[data.equipId] = data.lev
            break
        end
    end
end
function MarryCache:setXTgrowValue( data )
    -- body
    for k , v in pairs(self.xiantongdata.xtDatas) do
        if v.xtRoleId == data.xtRoleId then
            self.xiantongdata.xtDatas[k].growValue = data.growValue
            break
        end
    end
end
function MarryCache:setXTName( data )
    -- body
    for k , v in pairs(self.xiantongdata.xtDatas) do
        if v.xtRoleId == data.xtRoleId then
            self.xiantongdata.xtDatas[k].name = data.name
            break
        end
    end
end
function MarryCache:setXTskill( data )
    -- body
    for k , v in pairs(self.xiantongdata.xtDatas) do
        if v.xtRoleId == data.xtRoleId then
            self.xiantongdata.xtDatas[k].skillInfo = data.skillInfo
            break
        end
    end
end
function MarryCache:deleteXT( data )
    -- body
    for k , v in pairs(self.xiantongdata.xtDatas) do
        if v.xtRoleId == data.xtRoleId then
            table.remove(self.xiantongdata.xtDatas,k)
            break
        end
    end
end
function MarryCache:setXTTianfu( data )
    -- body
    for k , v in pairs(self.xiantongdata.xtDatas) do
        if v.xtRoleId == data.xtRoleId then
             self.xiantongdata.xtDatas[k].talentInfo = data.talentInfo
            break
        end
    end
end
function MarryCache:setXTPower( data )
    -- body
    if not self.xiantongdata or not self.xiantongdata.xtDatas then
        return
    end
    for k , v in pairs(self.xiantongdata.xtDatas) do
        if data.power[v.xtRoleId] then
            self.xiantongdata.xtDatas[k].power = data.power[v.xtRoleId]
        end
    end
end

----婚戒 -----------------
function MarryCache:getIsNext()
    -- body
    if not self.jhdata then
        return false
    end
    local condata = conf.MarryConf:getRingItem(self.jhdata.ringLev)
    local nextcondata = conf.MarryConf:getRingItem(self.jhdata.ringLev+1)
    return condata.step < conf.MarryConf:getValue("endjie") and nextcondata
end
function MarryCache:setJHlv(data)
    -- body
    if self.jhdata then return end
    self.jhdata.ringLev = data.ringLev
    --self.jhdata.power = data.power
end

return MarryCache