--
-- Author: wx
-- Date: 2018-01-12 14:55:06
--
local PetConf = class("PetConf",base.BaseConf)

function PetConf:init()
    self:addConf("pet_global")
    self:addConf("pet")
    self:addConf("pet_level_up")
    self:addConf("pet_skill")
    self:addConf("pet_equip_up")
    self:addConf("pet_reback_color")

    self:addConf("pos_open_cost")
    self:addConf("support_pet_attr")
    self:addConf("pet_pos_condi")
end

function PetConf:getValue(id)
    -- body
    return self.pet_global[tostring(id)]
end

function PetConf:getAllPetItem()
    -- body
    return table.values(self.pet)
end

function PetConf:getPetItem(id)
    -- body
    return self.pet[tostring(id)] 
end

function PetConf:getLevelUp(type,id)
    -- body
    local index = string.format("1%02d%03d",type,id)
    return self.pet_level_up[index] 
end

--获取当前类型最大等级属性
function PetConf:getMaxLeveUp(type)
    local data = {}
    for k,v in pairs(self.pet_level_up) do
        if (math.floor(v.id/1000)-100) == type then
            table.insert(data,v)
        end
    end
    if #data > 0 then
        table.sort(data,function(a,b)
            if a.id ~= b.id then
                return a.id < b.id
            end
        end)
        return data[#data]
    end
end

function PetConf:getAllSkill()
    -- body
    return table.values(self.pet_skill)
end

function PetConf:getPetSkillById(id)
    -- body
    return self.pet_skill[tostring(id)]
end

function PetConf:getEquipLevelUp(data)
    -- body
    local condata = conf.ItemConf:getItem(data.mid)

    local index = string.format("1%02d%02d%03d",condata.color,condata.part,data.level)
    --print("index",index)
    -- if not self.pet_equip_up[tostring(index)] then
    --     print("pet_equip_up表 缺少id=",index,"颜色",condata.color,"部位",condata.part,"等级",data.level)
    --     print(debug.traceback())
    -- end
    return self.pet_equip_up[tostring(index)]
end

function PetConf:getReturnByColor(id)
    -- body
    return self.pet_reback_color[tostring(id)]
    
end

function PetConf:getOpenCost(id)
    -- body
    return self.pos_open_cost[tostring(id)]
end

function PetConf:getSupportPetAttr(id)
    -- body
    local t = table.values(self.support_pet_attr)
    table.sort( t,function(a,b)
        -- body
        return a.id < b.id
    end )

    return t 
end

function PetConf:getPetPosCondi(id)
    -- body
    return self.pet_pos_condi[tostring(id)]
    
end

return PetConf