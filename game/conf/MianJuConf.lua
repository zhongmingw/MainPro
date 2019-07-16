--
-- Author: 
-- Date: 2018-12-07 20:05:36
--
local MianJuConf = class("MianJuConf",base.BaseConf)

function MianJuConf:init()
     self:addConf("mask_global")
     self:addConf("mask_level_up")
      self:addConf("mask_grow_item")
     self:addConf("mask_sub_item")
      self:addConf("mask_star")
     self:addConf("mask_fm")
      self:addConf("mask_fm_hole")
      self:addConf("mask_skill")

      
   
end

function MianJuConf:getMianjuIdData(id)
    local data = {}
    for k,v in pairs(self.mask_sub_item) do
       if id == v.itemId then
            return v
       end
    end
end

function MianJuConf:getMianJuData(id)
    return self.mask_sub_item[id..""]
end

function MianJuConf:getMianJuConfData()
    return self.mask_sub_item
end

--面具更换节点（面板）
function MianJuConf:CheckisMianJu(eId)
    for k,v in pairs(self.mask_sub_item) do
    
        if eId == v.effect_id then
            return v.mianjutype
        end
    end
    -- print("找不到effect_id")
end

function MianJuConf:getMianJuEffectId(mid)
    for k,v in pairs(self.mask_sub_item) do
        if v.itemId == mid then
            return v.effect_id
        end
    end
  
end

function MianJuConf:getMianjuTypeData(typef)
    local data = {}
    for k,v in pairs(self.mask_sub_item) do
       if typef == v.maskType then
            table.insert(data, v)
       end
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end )
    
    return data
end

function MianJuConf:getGlobal(value)
 
    return self.mask_global[""..value]
end

function MianJuConf:getGrownNum(level,maskType) -- 获得成长丹数量上限
 
    local data = {}
    for k,v in pairs(self.mask_grow_item) do
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end )
    

    for k,v in pairs(data) do
        if level >= v.level[1] and level <= v.level[2] then
            return v.limitNum
        end
    end
     
end



function MianJuConf:getExp(maskType,level) -- 获取升级所需经验
    
    return self.mask_level_up[""..((1000+maskType)*1000+level)] or nil
end

function MianJuConf:getMianJuLevConfData(id)
    return self.mask_level_up[tostring(id)]
end

function MianJuConf:getMianComsumeItem(typef)
    local data = {}
    for k,v in pairs(self.mask_global["mask_item_exp"]) do
       if v[3] == typef then
            table.insert(data, v)
       end
    end
    table.sort(data, function(a,b)
        return a[1] < b[1]
    end )
    
    return data
end



function MianJuConf:getMianJuFuMo(id,chongshu)
    return self.mask_fm[""..((1000*id)+chongshu)] or nil
    
end


function MianJuConf:getMianjuStartData(id,level)
    local data = nil
    for k,v in pairs(self.mask_star) do
       if tonumber(id*1000+ level) == v.id then
            data = clone(v)
            break
       end
    end
    return data
end

function MianJuConf:getMianJuFuMoKongWei(id,chongshu,kongwei)
    return self.mask_fm_hole[""..(((100*id)+chongshu)*100+kongwei)] or nil
    
end

function MianJuConf:getSkillById(id)
    local data = {}
    for k,v in pairs(self.mask_skill) do
       if id == math.floor(v.id/1000) then
           table.insert(data, v)
       end
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end )
    return data
end

return MianJuConf