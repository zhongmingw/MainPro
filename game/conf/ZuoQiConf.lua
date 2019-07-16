--
-- Author: 
-- Date: 2017-02-13 21:30:37
--
local ZuoQiConf = class("ZuoQiConf",base.BaseConf)

function ZuoQiConf:init()
    self:addConf("horse_global") -- S-神兵系统配置
    self:addConf("horse_skill") -- Z-坐骑配置
    self:addConf("horse_skill_lev")-- Z-坐骑配置
    self:addConf("horse_equip")--Z-坐骑配置
    self:addConf("horse_equip_lev")--Z-坐骑配置
    self:addConf("horse_lev")--Z-坐骑配置
    self:addConf("horse_skin")--z-坐骑配置
    self:addConf("horse_action")

    self:addConf("shenbing_global") -- S-神兵系统配置
    self:addConf("shenbing_lev")-- S-神兵系统配置
    self:addConf("shenbing_equip_lev") -- S-神兵系统配置
    self:addConf("shenbing_skill_lev")--S-神兵系统配置
    self:addConf("shenbing_skin")--S-神兵系统配置
    self:addConf("shenbing_equip")--S-神兵系统配置
    self:addConf("shenbing_skill")--S-神兵系统配置

    self:addConf("fabao_global") -- S-神兵系统配置
    self:addConf("fabao_lev")-- S-神兵系统配置
    self:addConf("fabao_equip_lev") -- S-神兵系统配置
    self:addConf("fabao_skill_lev")--S-神兵系统配置
    self:addConf("fabao_skin")--S-神兵系统配置
    self:addConf("fabao_equip")--S-神兵系统配置
    self:addConf("fabao_skill")--S-神兵系统配置


    self:addConf("xianyu_global") -- X-仙羽系统配置
    self:addConf("xianyu_lev")-- X-仙羽系统配置
    self:addConf("xianyu_skill") -- X-仙羽系统配置
    self:addConf("xianyu_equip_lev")--X-仙羽系统配置
    self:addConf("xianyu_skill_lev")--X-仙羽系统配置
    self:addConf("xianyu_skin")--X-仙羽系统配置
    self:addConf("xianyu_equip")--X-仙羽系统配置

    self:addConf("xianqi_global") -- S-神兵系统配置
    self:addConf("xianqi_lev")-- S-神兵系统配置
    self:addConf("xianqi_equip_lev") -- S-神兵系统配置
    self:addConf("xianqi_skill_lev")--S-神兵系统配置
    self:addConf("xianqi_skin")--S-神兵系统配置
    self:addConf("xianqi_equip")--S-神兵系统配置
    self:addConf("xianqi_skill")--S-神兵系统配置

    --麒麟臂
    self:addConf("qilinbi_global") -- S-神兵系统配置
    self:addConf("qilinbi_lev")-- S-神兵系统配置
    self:addConf("qilinbi_equip_lev") -- S-神兵系统配置
    self:addConf("qilinbi_skill_lev")--S-神兵系统配置
    self:addConf("qilinbi_skin")--S-神兵系统配置
    self:addConf("qilinbi_equip")--S-神兵系统配置
    self:addConf("qilinbi_skill")--S-神兵系统配置
end

function ZuoQiConf:getHorseAction(id)
    if not self.horse_action[tostring(id)] then
        plog("没有这个ID",id)
    end
    --print("id",id)
    return self.horse_action[tostring(id)]["action"]
end

function ZuoQiConf:getValue(id,index)
    -- body
    local condata 
    if index == 0 then
        condata = self.horse_global
    elseif index == 1 then
        condata = self.shenbing_global
    elseif index == 2 then
        condata = self.fabao_global
    elseif index == 3 then
        condata = self.xianyu_global
    elseif index == 4 then
        condata = self.xianqi_global
    elseif index == 5 then
        condata = self.qilinbi_global
    end

    return condata[id..""]
end

--等级细信息
function ZuoQiConf:getDataByLv(lv,index)
    -- body
    local condata 
    local id = 100101000 + lv 
    if index == 0 then
        condata = self.horse_lev
    elseif index == 1 then
        condata = self.shenbing_lev
    elseif index == 2 then
        condata = self.fabao_lev
    elseif index == 3 then
        condata = self.xianyu_lev
    elseif index == 4 then
        condata = self.xianqi_lev
    elseif index == 5 then
        id = lv
        condata = self.qilinbi_lev
    end

    return condata[id..""]
end
--所有的技能
function ZuoQiConf:getSkillData(index)
    -- body
    local condata 
    if index == 0 then
        condata = table.values(self.horse_skill)
    elseif index == 1 then
        condata = table.values(self.shenbing_skill)
    elseif index == 2 then
        condata = table.values(self.fabao_skill)
    elseif index == 3 then
        condata = table.values(self.xianyu_skill)
    elseif index == 4 then
        condata = table.values(self.xianqi_skill)
    elseif index == 5 then
        condata = table.values(self.qilinbi_skill)
    end

    return condata
end
--单一技能
function ZuoQiConf:getSkillById(id,index)
    -- body
    local condata 
    if index == 0 then
        condata = self.horse_skill
    elseif index == 1 then
        condata = self.shenbing_skill
    elseif index == 2 then
        condata = self.fabao_skill
    elseif index == 3 then
        condata = self.xianyu_skill
    elseif index == 4 then
        condata = self.xianqi_skill
    elseif index == 5 then
        condata = self.qilinbi_skill
    end

    return condata[id..""]
end
--技能等级细腻
function ZuoQiConf:getSkillByLev(k,v,index)
    -- body
    local condata 
    if index == 0 then
        condata = self.horse_skill_lev
    elseif index == 1 then
        condata = self.shenbing_skill_lev
    elseif index == 2 then
        condata = self.fabao_skill_lev
    elseif index == 3 then
        condata = self.xianyu_skill_lev
    elseif index == 4 then
        condata = self.xianqi_skill_lev
    elseif index == 5 then
        condata = self.qilinbi_skill_lev
    end

    local id = k * 1000 + v 
    return condata[id..""]
end

---获取所有装备
function ZuoQiConf:getEquipData(index)
    -- body
    local condata 
    if index == 0 then
        condata = table.values(self.horse_equip) 
    elseif index == 1 then
        condata = table.values(self.shenbing_equip)  
    elseif index == 2 then
        condata = table.values(self.fabao_equip)  
    elseif index == 3 then
        condata = table.values(self.xianyu_equip)  
    elseif index == 4 then
        condata = table.values(self.xianqi_equip) 
    elseif index == 5 then
        condata = table.values(self.qilinbi_equip) 
    end

    return condata
end

function ZuoQiConf:getEquipById(id,index)
    -- body
    local condata 
    if index == 0 then
        condata = self.horse_equip
    elseif index == 1 then
        condata = self.shenbing_equip
    elseif index == 2 then
        condata = self.fabao_equip
    elseif index == 3 then
        condata = self.xianyu_equip
    elseif index == 4 then
        condata = self.xianqi_equip
    elseif index == 5 then
        condata = self.qilinbi_equip
    end

    return condata[id..""]
end

function ZuoQiConf:getEquipByLev(k,v,index)
    -- body
    local condata 
    if index == 0 then
        condata = self.horse_equip_lev
    elseif index == 1 then
        condata = self.shenbing_equip_lev
    elseif index == 2 then
        condata = self.fabao_equip_lev
    elseif index == 3 then
        condata = self.xianyu_equip_lev
    elseif index == 4 then
        condata = self.xianqi_equip_lev
    elseif index == 5 then
        condata = self.qilinbi_equip_lev
    end

    local id = k*1000 + v 
    return condata[id..""]
end

function ZuoQiConf:getSkinsByIndex(id, index)
    -- body
    local condata 
    if index == 0 then
        condata = self.horse_skin
    elseif index == 1 then
        condata = self.shenbing_skin
    elseif index == 2 then
        condata = self.fabao_skin
    elseif index == 3 then
        condata = self.xianyu_skin
    elseif index == 4 then
        condata = self.xianqi_skin
    elseif index == 5 then
        condata = self.qilinbi_skin
    end

    return condata[""..id]
end

function ZuoQiConf:getSkinsByModle(id, index) 
    local condata 
    if index == 0 then
        condata = self.horse_skin
    elseif index == 1 then
        condata = self.shenbing_skin
    elseif index == 2 then
        condata = self.fabao_skin
    elseif index == 3 then
        condata = self.xianyu_skin
    elseif index == 4 then
        condata = self.xianqi_skin
    elseif index == 5 then
        condata = self.qilinbi_skin
    end

    for k ,v in pairs(condata) do
        if tonumber(v.modle_id) == tonumber(id) then
            return v
        end
    end

    return nil 
end


function ZuoQiConf:getSkinsByJie( id, index )
    -- body
    local condata 
    if index == 0 then
        condata = self.horse_skin
    elseif index == 1 then
        condata = self.shenbing_skin
    elseif index == 2 then
        condata = self.fabao_skin
    elseif index == 3 then
        condata = self.xianyu_skin
    elseif index == 4 then
        condata = self.xianqi_skin
    elseif index == 5 then
        condata = self.qilinbi_skin
    end

    for k ,v in pairs(condata) do
        if v.grow_cons and tonumber(v.grow_cons) == tonumber(id) then
            return v
        end
    end
end

function ZuoQiConf:getAllOtherSkin(index)
    -- body
    local condata 
    if index == 0 then
        condata = self.horse_skin
    elseif index == 1 then
        condata = self.shenbing_skin
    elseif index == 2 then
        condata = self.fabao_skin
    elseif index == 3 then
        condata = self.xianyu_skin
    elseif index == 4 then
        condata = self.xianqi_skin
    elseif index == 5 then
        condata = self.qilinbi_skin
    end

    local t = {}
    local maxTo = self:getValue("endmaxjie",index)
    for k ,v in pairs(condata) do
        if (not v.grow_cons or  (v.grow_cons < 1 and v.grow_cons>maxTo)) and v.isShow == 1 then
            table.insert(t,v)
        end
    end

    table.sort(t,function ( a,b)
        -- body
        return a.id < b.id
    end)

    return t
end

--[[
    local condata 
    if index == 0 then
        condata = 
    elseif index == 1 then
        condata = 
    elseif index == 2 then
        condata = 
    elseif index == 3 then
        condata = 
    elseif index == 4 then
        condata = 
    end
]]

return ZuoQiConf