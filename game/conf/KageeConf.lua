--
-- Author: ohf
-- Date: 2017-02-21 14:50:35
--
--影卫配置
local KageeConf = class("KageeConf",base.BaseConf)

function KageeConf:init()
    self:addConf("yw_limit")--12生肖
    self:addConf("yw_upattr")--生肖等级属性
    self:addConf("yw_chainattr")--影卫连锁
    self:addConf("yw_fettersattr")
end

function KageeConf:getYwLimit()
    local data = {}
    local playLv = cache.PlayerCache:getRoleLevel()
    for k,v in pairs(self.yw_limit) do
        table.insert(data, v)
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end

function KageeConf:getYwLimitById(id)
    return self.yw_limit[id..""]
end
--影卫属性
function KageeConf:getUpattr(pex,lv)
    local id = self:getKegeeAttId(pex,lv)
    local data = self.yw_upattr[id]
    return data
end
--影卫总属性
function KageeConf:getAllattr(ywData)
    local data = {}
    if not ywData then return end
    for key,lv in pairs(ywData) do--已經激活的影卫和对应等级
        local ywId = tonumber(self:getKegeeAttId(key,lv)) 
        for _,atti in pairs(self.yw_upattr) do
            if atti.id == ywId then
                for k,v in pairs(atti) do
                    if string.find(k,"att_") then
                        if not data[k..""] then
                            data[k..""] = 0
                        end
                        data[k..""] = data[k..""] + v
                    end
                end
            end
        end
    end
    local atti = {att_102 = 0, att_103 = 0, att_105 = 0, att_106 = 0, att_107 = 0, att_108 = 0}
    for k1,v1 in pairs(data) do
        for k2,v2 in pairs(atti) do
            if k1 == k2 then
                atti[k1] = v1
            end
        end
    end
    return atti
end
--影卫属性id
function KageeConf:getKegeeAttId(pex,lv)
    -- local lev = ""
    -- if lv < 10 then
    --     lev = "00"..lv
    -- elseif lv >= 10 and lv < 100 then
    --     lev = "0"..lv
    -- end
    -- plog(pex..string.format("%03d",lv))
    return pex..string.format("%03d",lv)
end
--影卫连锁
function KageeConf:getChainattrById(id)
    return self.yw_chainattr[id..""]
end

function KageeConf:getChainattrByLv(lv)
    local data = {}
    for k,v in pairs(self.yw_chainattr) do
        table.insert(data, v)
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    local attData = nil
    for k,v in pairs(data) do
        if lv >= v.lvl then
            attData = v
        end
    end
    return attData
end
--仙脉攻击
function KageeConf:getFettersattrById(id)
    return self.yw_fettersattr[id..""]
end

function KageeConf:getFettersattr(mapData)
    local data = {}
    for k,v in pairs(self.yw_fettersattr) do
        table.insert(data, v)
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    local attData = nil
    for i,v in pairs(data) do
        local num = 0
        for j,lev in pairs(mapData) do
            if lev >= v.lvl then
                num = num + 1
            end
        end
        if num >= v.lvl_count then
            attData = v
        else
            break
        end
    end
    return attData
end

return KageeConf