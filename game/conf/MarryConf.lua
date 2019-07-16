--
-- Author: wx
-- Date: 2017-07-19 14:30:54
-- 结婚系统 
local MarryConf = class("MarryConf",base.BaseConf)
local pairs = pairs
function MarryConf:init()
    -- J-结婚
    self:addConf("marry_global") 
    self:addConf("marry_grade")
    self:addConf("marry_grade_gh")
    self:addConf("marry_ring")
    self:addConf("marry_ring_show")
    self:addConf("marry_qingyuan")
    self:addConf("marry_tree")
    self:addConf("marry_shop")
    self:addConf("marry_flower_award")
    self:addConf("marry_ranking_awards")
    self:addConf("marry_tree_status")
    self:addConf("benediction_list")
    self:addConf("marry_wedding_feeding_cost")
    self:addConf("marry_wedding_feeding_cost_gh")
    --仙童
    self:addConf("xt_global")
    self:addConf("df_award_pool")
    self:addConf("xt_item")
    self:addConf("xt_lev")
    self:addConf("xt_equip_lev")
    self:addConf("xt_talent")
    self:addConf("xt_skill_lev")
    self:addConf("xt_equip")
    self:addConf("xt_talent_lev")
    self:addConf("xt_help_hole")--仙童助战孔
    self:addConf("xt_help_zw")--仙童助战阵位
end

function MarryConf:getAllSkill()
    -- body
    return table.values(self.xt_skill_lev)
end

function MarryConf:getEquipByLev(id,lv)
    -- body
    local index = id * 1000 + lv
    return self.xt_equip_lev[tostring(index)]
end

function MarryConf:getXTlev(lv)
    -- body
    return self.xt_lev[tostring(lv)]
end

function MarryConf:getPetSkillById(id)
    -- body
    return self.xt_skill_lev[tostring(id)]
end

function MarryConf:getTalentBy(id)
    -- body
    return self.xt_talent[tostring(id)]
end

function MarryConf:getTalent()
    -- body
    local t = table.values(self.xt_talent)
    table.sort(t,function(a,b)
        -- body
        return a.id < b.id
    end)
    return t 
end

function MarryConf:getEquip()
    -- body
    local t = table.values(self.xt_equip)
    table.sort(t,function(a,b)
        -- body
        return a.id < b.id
    end)
    return t 
end

function MarryConf:getPetItem( id )
    -- body
    return self.xt_item[tostring(id)]
end

function MarryConf:getXTValue( id )
    -- body
    return self.xt_global[tostring(id)]
end

function MarryConf:getXTRewardPool(id)
    -- body
    return self.df_award_pool[tostring(id)]
end

function MarryConf:getXTRewardPoolByType(id)
    -- body
    local t = {}
    for k ,v in pairs(self.df_award_pool) do
        if math.floor(v.id/1000) == id then
            for i , j in pairs(v.awards) do
                t[j[1]] = j
            end
        end
    end

    local r = table.values(t)

    return r
end

function MarryConf:getValue(id)
    -- body
    return self.marry_global[tostring(id)]
end

function MarryConf:getGradeItem(id)
    -- body
    local var = cache.PlayerCache:getRedPointById(10327)
    if G_IsGongHuiID(var) then
        return self.marry_grade_gh[tostring(id)]
    else
        return self.marry_grade[tostring(id)]
    end
end

function MarryConf:getRingItem(id)
    -- body
    return self.marry_ring[tostring(id)]
end
function MarryConf:getRingItemByJie(id)
    -- body
    return self.marry_ring_show[tostring(id)]
end

function MarryConf:getQingyuanItem(id)
    -- body
    return self.marry_qingyuan[tostring(id)]
end

function MarryConf:getTreeItem(id)
    -- body
    return self.marry_tree[tostring(id)]
end
--求累计的属性
function MarryConf:getTreeAtti(lv)
    local attiData = {}
    for _,values in pairs(self.marry_tree) do
        if values.id <= lv then
            for k,v in pairs(values) do
                if string.find(k,"att_") then
                    if not attiData[k] then
                        attiData[k] = 0
                    end
                    attiData[k] = attiData[k] + v
                elseif k == "power" then
                    if not attiData[k] then
                        attiData[k] = 0
                    end
                    attiData[k] = attiData[k] + v
                end
            end
        end
    end
    return attiData
end

function MarryConf:getMarryshop()
    -- body
    return self.marry_shop[tostring(id)]
end

function MarryConf:getMarryAllShop()
    -- body
    local t = table.values(self.marry_shop)
    table.sort(t, function(a,b)
        -- body
        return a.id < b.id
    end)

    return t 
end

function MarryConf:getMarryfloweraward(id)
    -- body
    return self.marry_flower_award[tostring(id)]
end

function MarryConf:getRankReward()
    -- body
    local t = table.values(self.marry_ranking_awards) 
    table.sort( t,function(a,b)
        -- body
        return a.id < b.id 
    end)

    return t 
end

function MarryConf:getRankRewardById( id )
    -- body
    return self.marry_ranking_awards[tostring(id)]
end

function MarryConf:getMarryTreeStatus(id)
    return self.marry_tree_status[tostring(id)]
end

function MarryConf:getMarryWishData()
    local data = {}
    for k,v in pairs(self.benediction_list) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end 
    end)
    return data
end

function MarryConf:getMarryCostById(id)
    local data = {}
    local var = cache.PlayerCache:getRedPointById(10327)
    local confData = self.marry_wedding_feeding_cost
    if G_IsGongHuiID(var) then
        confData = self.marry_wedding_feeding_cost_gh
    end
    for k,v in pairs(confData) do
        if v.id == id then
            data = v
        end
    end
    return data
end

--当前阵位含有的助战孔
function MarryConf:getZhuZhanKongByZW(zw_id)
    local kongId = {}
    for k,v in pairs(self.xt_help_hole) do
        if v.zw_type == zw_id then
            table.insert(kongId,v.id)
        end
    end
    table.sort( kongId, function(a,b)
        return a < b
    end )
    return kongId
end

--仙童助战孔
function MarryConf:getXianTongZhuZhanById(id)
    return self.xt_help_hole[tostring(id)]
end

--仙童助战阵位
function MarryConf:getXianTongZhenWeiById(id)
    return self.xt_help_zw[tostring(id)]
end

return MarryConf