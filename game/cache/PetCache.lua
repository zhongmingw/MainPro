--
-- Author: wx
-- Date: 2018-01-12 14:53:49
--
local PetCache = class("PetCache",base.BaseCache)
--[[

--]]
function PetCache:init()
    self.data = {}
end

function PetCache:setData(data)
    -- body
    self.data = data
end

function PetCache:getData()
    -- body
    return self.data 
end

function PetCache:setCurpetRoleId(data)
    -- body
    self.petRoleId = data
end

function PetCache:getCurpetRoleId( ... )
    -- body
    return self.petRoleId 
end

function PetCache:updateLevel(data)
    -- body
    for k  , v in pairs(self.data) do
        if v.petRoleId == data.petRoleId then
            self.data[k].level = data.level
            self.data[k].exp = data.exp
            return
        end
    end
end

function PetCache:updateEquip( data )
    -- body
    for k  , v in pairs(self.data) do
        if v.petRoleId == data.petRoleId then
            v.equipInfos = data.equipInfos
            return
        end
    end
end

function PetCache:updateEquipLevel(data)
    -- body
    local euip = nil
    for k  , v in pairs(self.data) do
        if tonumber(v.petRoleId) == tonumber(data.petRoleId) then
            euip = v.equipInfos
            break 
        end
    end
    if not euip then
        return
    end
    for k,v in pairs(euip) do
        local condata = conf.ItemConf:getItem(v.mid)
        if data.part == condata.part then
            euip[k].exp = data.exp
            euip[k].level = data.level
            break
        end
    end
end

function PetCache:updateSkill( data )
    -- body
    for k  , v in pairs(self.data) do
        if v.petRoleId == data.petRoleId then
            v.skillDatas = data.skillDatas
            return
        end
    end
end

function PetCache:updateZZ( data )
    -- body
    for k  , v in pairs(self.data) do
        if v.petRoleId == data.petRoleId then
            v.growValue = data.growValue
            return
        end
    end
end

function PetCache:getPetData(id)
    -- body
    for k  , v in pairs(self.data) do
        if v.petRoleId == id then
            return v 
        end
    end
    return nil
end

function PetCache:deletePet(data)
    -- body
    for k  , v in pairs(self.data) do
        if v.petRoleId == data.petRoleId then
            table.remove(self.data,k)
            return
        end
    end
end

function PetCache:updatePetId( data )
    -- body
    for k  , v in pairs(self.data) do
        if v.petRoleId == data.petRoleId then
            local condata = conf.PetConf:getPetItem(v.petId)
            self.data[k].petId = condata.next_stage
            self.data[k].name = data.name
            return
        end
    end
end

function PetCache:updatePetName( data )
    -- body
    for k  , v in pairs(self.data) do
        if v.petRoleId == data.petRoleId then
            self.data[k].name = data.name
            return
        end
    end
end


return PetCache