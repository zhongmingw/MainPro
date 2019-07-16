--
-- Author: 
-- Date: 2017-02-06 17:22:29
--
local SkillConf = class("SkillConf",base.BaseConf)

function SkillConf:init()
    self:addConf("skill_career") --J-技能
    self:addConf("skill_affect")--J-技能作用
    self:addConf("skill_config")--J-技能作用
    self:addConf("xf_skill")
end

function SkillConf:getSkillConfByid(id)
    -- body
    return self.skill_config[id..""]
end

function SkillConf:getSkillopen_lvl(id)
    -- body
    local data = self.skill_career[id..""]
    if data then
        return data.open_lvl
    end

    return 0
end

function SkillConf:getSkillByCareer(id)
    -- body
    local t = {}
    for k , v in pairs(self.skill_career) do
        if (v.career == id or v.stype == 4) and v.stype ~= 6 then
            table.insert(t,v)
        end
    end

    table.sort( t,function(a,b)
        -- body
        return a.id < b.id 
    end)

    return t 
end
--获取技能icon
function SkillConf:getSkillIcon(id)
    -- body
    local data = self.skill_career[id..""]
    if data then
        return data.icon
    end
    return nil 
end
--获取技能名字
function SkillConf:getSkillName(id)
    -- body
    local data = self.skill_career[id..""]
    if data then
        return data.name
    end
    return ""
end

function SkillConf:getSkillXianFa()
    -- body
    
    local t = table.values(self.xf_skill)
    table.sort( t,function(a,b)
        -- body
        return a.id < b.id 
    end)

    return t 
end


function SkillConf:getSkillByIdAndLevel(id,level)
    -- body

    local var = id .. string.format("%03d",level)
    return self.skill_affect[var]
end

function SkillConf:getSkillByIndex( id )
    -- body
    return self.skill_affect[tostring(id)]
end

function SkillConf:getSkiilCareerById(id)
    return self.skill_career[tostring(id)]
end

return SkillConf