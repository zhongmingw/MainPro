--
-- Author: 
-- Date: 2017-02-25 14:50:09
--
local HuobanConf = class("HuobanConf",base.BaseConf)

function HuobanConf:init()

    
    self:addConf("partner_global") --H-伙伴配置
    self:addConf("partner_lev") --H-伙伴配置
    self:addConf("partner_skill")--H-伙伴配置
    self:addConf("partner_equip")--H-伙伴配置
    self:addConf("partner_skin")--H-伙伴配置
    self:addConf("partner_equip_name")--H-伙伴配置
    self:addConf("partner_skill_name")--H-伙伴配置

    self:addConf("partner_xianyu_global") --H-伙伴仙羽配置
    self:addConf("partner_xianyu_lev")--H-伙伴仙羽配置
    self:addConf("partner_xianyu_equip_lev")--H-伙伴仙羽配置
    self:addConf("partner_xianyu_skill_lev")--H-伙伴仙羽配置
    self:addConf("partner_xianyu_skill")--H-伙伴仙羽配置
    self:addConf("partner_xianyu_equip")--H-伙伴仙羽配置
    self:addConf("partner_xianyu_skin")--H-伙伴仙羽配置


    self:addConf("partner_shenbing_global") --H-伙伴神兵配置
    self:addConf("partner_shenbing_lev")--H-伙伴神兵配置
    self:addConf("partner_shenbing_equip_lev")--H-H-伙伴神兵配置
    self:addConf("partner_shenbing_skill_lev")--H-H-伙伴神兵配置
    self:addConf("partner_shenbing_skill")--H-H-伙伴神兵配置
    self:addConf("partner_shenbing_equip")--H-H-伙伴神兵配置
    self:addConf("partner_shenbing_skin")--H-H-伙伴神兵配置

    self:addConf("partner_fabao_global") --H-伙伴神兵配置
    self:addConf("partner_fabao_lev")--H-伙伴神兵配置
    self:addConf("partner_fabao_equip_lev")--H-H-伙伴神兵配置
    self:addConf("partner_fabao_skill_lev")--H-H-伙伴神兵配置
    self:addConf("partner_fabao_skill")--H-H-伙伴神兵配置
    self:addConf("partner_fabao_equip")--H-H-伙伴神兵配置
    self:addConf("partner_fabao_skin")--H-H-伙伴神兵配置


    self:addConf("partner_xianqi_global") --H-伙伴神兵配置
    self:addConf("partner_xianqi_lev")--H-伙伴神兵配置
    self:addConf("partner_xianqi_equip_lev")--H-H-伙伴神兵配置
    self:addConf("partner_xianqi_skill_lev")--H-H-伙伴神兵配置
    self:addConf("partner_xianqi_skill")--H-H-伙伴神兵配置
    self:addConf("partner_xianqi_equip")--H-H-伙伴神兵配置
    self:addConf("partner_xianqi_skin")--H-H-伙伴神兵配置
	
	 --灵童随机说话
    self:addConf("partnerspeak")
    self:addConf("partnerword")
end

function HuobanConf:getwordListByRoleLv()
    -- body
    local lv = cache.PlayerCache:getRoleLevel()

    for k ,v in pairs(self.partnerspeak) do
        if v.lv_begin and v.lv_end then
            if v.lv_begin <= lv and lv <= v.lv_end then
                return clone(v) 
            end
        end
    end
    return 
end

function HuobanConf:getHuobanWord(id)
    -- body
    return self.partnerword[tostring(id)]
end

function HuobanConf:getValue(id,index)
    -- body
     local condata 
    if index == 0 then
        condata = self.partner_global
    elseif index == 1 then
        condata = self.partner_xianyu_global
    elseif index == 2 then
        condata = self.partner_shenbing_global
    elseif index == 3 then
        condata = self.partner_fabao_global
    elseif index == 4 then
        condata = self.partner_xianqi_global
    end

    return condata[id..""]
end

function HuobanConf:getSkinsByModel( id,index )
    -- body
    local condata 
    if index == 0 then
        condata = self.partner_skin
    elseif index == 1 then
        condata = self.partner_xianyu_skin
    elseif index == 2 then
        condata = self.partner_shenbing_skin
    elseif index == 3 then
        condata = self.partner_fabao_skin
    elseif index == 4 then
        condata = self.partner_xianqi_skin
    end

    for k ,v in pairs(condata) do
        if v.modle_id == id then
            return v
        end
    end
end

function HuobanConf:getSkinsData(id)
    return self.partner_skin[tostring(id)]
end

function HuobanConf:getXianyuSkinsData(id)
    return self.partner_xianyu_skin[tostring(id)]
end

--获取技能或者伙伴
function HuobanConf:getLeftData(index)
    -- body
    if index == 0 then
        local t = {}
        for k ,v in pairs(self.partner_skin) do
            if v.istshu == 1 then
                table.insert(t,v)
            end
        end

        return t
    elseif index == 1 then
        return table.values(self.partner_xianyu_skill)
    elseif index == 2 then
        return table.values(self.partner_shenbing_skill) 
    elseif index == 3 then
        return table.values(self.partner_fabao_skill)
    elseif index == 4 then
        return table.values(self.partner_xianqi_skill)
    end
end
--获取装备
function HuobanConf:getRightData(index)
    -- body
    if index == 0 then
        return table.values(self.partner_equip_name)
    elseif index == 1 then
        return table.values(self.partner_xianyu_equip)
    elseif index == 2 then
        return table.values(self.partner_shenbing_equip) 
    elseif index == 3 then
        return table.values(self.partner_fabao_equip)
    elseif index == 4 then
        return table.values(self.partner_xianqi_equip)
    end
end
--按分页 和 等级获取信息
function HuobanConf:getDataByLv( lv,index )
    -- body
    -- plog(lv,index)
    local id = 100101000 + lv
    if index == 0 then
        id = 1001000 + lv
        return self.partner_lev[id..""]
    elseif index == 1 then
        return self.partner_xianyu_lev[id..""]
    elseif index == 2 then
        return self.partner_shenbing_lev[id..""]
    elseif index == 3 then
        return self.partner_fabao_lev[id..""]
    elseif index == 4 then
        return self.partner_xianqi_lev[id..""]
    end
end
--获取皮肤按阶
function HuobanConf:getSkinsByJie( id,index )
    -- body
    local condata 

    if index == 0 then
        condata = self.partner_skin
    elseif index == 1 then
        condata = self.partner_xianyu_skin
    elseif index == 2 then
        condata = self.partner_shenbing_skin
    elseif index == 3 then
        condata = self.partner_fabao_skin
    elseif index == 4 then
        condata = self.partner_xianqi_skin
    end

    if index == 0 then
        return self.partner_skin[id..""]
    else
        for k ,v in pairs(condata) do
            if v.grow_cons and v.grow_cons == id then
                return v
            end
        end

        for k ,v in pairs(condata) do
            if v.grow_cons and v.grow_cons == 1 then
                return v
            end
        end
    end
end
--按ID获取皮肤
function HuobanConf:getSkinsByIndex(id,index)
    -- body
    if not id then
        return nil
    end



    local condata 
    if index == 0 then
        condata = self.partner_skin
    elseif index == 1 then
        condata = self.partner_xianyu_skin
    elseif index == 2 then
        condata = self.partner_shenbing_skin
    elseif index == 3 then
        condata = self.partner_fabao_skin
    elseif index == 4 then
        condata = self.partner_xianqi_skin
    end
    
    return condata[checkint(id)..""]
end
---获得技能等级信息
function HuobanConf:getSkillLevData( k,v,index )
    -- body
    local condata
    if index == 0 then
        condata = self.partner_skill
    elseif index == 1 then
        condata = self.partner_xianyu_skill_lev
    elseif index == 2 then
        condata = self.partner_shenbing_skill_lev
    elseif index == 3 then
        condata = self.partner_fabao_skill_lev
    elseif index == 4 then
        condata = self.partner_xianqi_skill_lev
    end
    local id = k * 1000 + v 
    return condata[id..""]
end

function HuobanConf:getSkillLevDataByid(v,index)
    -- body
    local condata
    if index == 0 then
        condata = self.partner_skill
    elseif index == 1 then
        condata = self.partner_xianyu_skill_lev
    elseif index == 2 then
        condata = self.partner_shenbing_skill_lev
    elseif index == 3 then
        condata = self.partner_fabao_skill_lev
    elseif index == 4 then
        condata = self.partner_xianqi_skill_lev
    end
    return condata[v..""]
end
function HuobanConf:getHuobanSkill()
    -- body
    local t = table.values(self.partner_skill_name)
    table.sort(t,function(a,b)
        -- body
        return a.id < b.id
    end)

    return t
end

function HuobanConf:getSkillById(id,index)
    -- body
    local condata
    if index == 0 then
        condata = self.partner_skill_name
    elseif index == 1 then
        condata = self.partner_xianyu_skill
    elseif index == 2 then
        condata = self.partner_shenbing_skill
    elseif index == 3 then
        condata = self.partner_fabao_skill
    elseif index == 4 then
        condata = self.partner_xianqi_skill
    end

    return condata[id..""]
end

---获得装备等级信息
function HuobanConf:getEquipLevData( k,v,index )
    -- body
    local condata
    if index == 0 then
        condata = self.partner_equip
    elseif index == 1 then
        condata = self.partner_xianyu_equip_lev
    elseif index == 2 then
        condata = self.partner_shenbing_equip_lev
    elseif index == 3 then
        condata = self.partner_fabao_equip_lev
    elseif index == 4 then
        condata = self.partner_xianqi_equip_lev
    end
    local id = k * 1000 + v 
    return condata[id..""]
end

function HuobanConf:getEquipById(id,index)
    -- body
    local condata
    if index == 0 then
        condata = self.partner_equip_name
    elseif index == 1 then
        condata = self.partner_xianyu_equip
    elseif index == 2 then
        condata = self.partner_shenbing_equip
    elseif index == 3 then
        condata = self.partner_fabao_equip
    elseif index == 4 then
        condata = self.partner_xianqi_equip
    end

    return condata[id..""]
end
--获取其他特殊皮肤
--
function HuobanConf:getAllOtherSkin(index)
    -- body
    local condata
    if index == 0 then
        condata = self.partner_skin
    elseif index == 1 then
        condata = self.partner_xianyu_skin
    elseif index == 2 then
        condata = self.partner_shenbing_skin
    elseif index == 3 then
        condata = self.partner_fabao_skin
    elseif index == 4 then
        condata = self.partner_xianqi_skin
    end
    local t = {}
    local maxTo = self:getValue("endmaxjie",index)
    if index == 0 then
        for k ,v in pairs(condata) do
            if v.istshu == 2 and v.isShow == 1 then
                table.insert(t,v)
            end
        end
    else
        for k ,v in pairs(condata) do
            if (not v.grow_cons or ( v.grow_cons > maxTo or v.grow_cons<1 )) and v.isShow == 1 then
                table.insert(t,v)
            end 
        end
    end

    table.sort(t,function( a,b )
        -- body
        return a.id<b.id
    end)

    return t 
end

function HuobanConf:getSkinsByModle( id,index )
    -- body
    local condata 
    if index == 0 then
        condata = self.partner_skin
    elseif index == 1 then
        condata = self.partner_xianyu_skin
    elseif index == 2 then
        condata = self.partner_shenbing_skin
    elseif index == 3 then
        condata = self.partner_fabao_skin
    elseif index == 4 then
        condata = self.partner_xianqi_skin
    end

    for k ,v in pairs(condata) do
        if tonumber(v.modle_id) == tonumber(id) then
            return v
        end
    end

    return nil 
end

return HuobanConf