--
-- Author: 
-- Date: 2017-03-03 16:55:17
--
local BangPaiConf = class("BangPaiConf",base.BaseConf)

function BangPaiConf:init()
    self:addConf("gang_global")
    self:addConf("gang_lev")
    self:addConf("gang_sign")
    self:addConf("gang_shop")
    self:addConf("gang_skill")
    self:addConf("gang_skill_lev")
    self:addConf("gang_store_item")
    self:addConf("gang_box")
    self:addConf("gang_boss_lvl")
    self:addConf("gang_flame_award")
    self:addConf("gang_question_pool")--仙盟答题
    self:addConf("gang_act_exp")--仙盟圣火添柴获得贡献和经验
    self:addConf("gang_actives")

    --仙盟科技使用
    self:addConf("gang_tech")
    self:addConf("gang_tech_study")
    self:addConf("gang_qianduan")
    self:addConf("gang_tech_info")
end

function BangPaiConf:getValue(id)
    -- body
    return self.gang_global[id..""]
end

function BangPaiConf:getBangLev(id,type)
    -- body
    local index = (type+1)*1000 + id
    return self.gang_lev[index..""]
end

function BangPaiConf:getAllGanglev()
    -- body
    local t = table.values(self.gang_lev)
    table.sort(t,function(a,b)
        -- body
        return a.id < b.id
    end)

    return t
end

function BangPaiConf:getSign()
    -- body
    local t = table.values(self.gang_sign)
    table.sort(t,function(a,b)
        -- body
        return a.id < b.id 
    end)

    return t
end

function BangPaiConf:getShopItem(id)
    -- body
    return self.gang_shop[id..""]
end

function BangPaiConf:getShopByGanglv( lv)
    -- body
    local t = {}
    for k ,v in pairs(self.gang_shop) do
        if v.gang_lev == lv then
            table.insert(t,v)
        end
    end

    table.sort(t,function(a,b)
        -- body
        return a.id < b.id
    end)

    return t
end

function BangPaiConf:getAllSkill()
    -- body
    local t = table.values(self.gang_skill)
    table.sort(t,function(a,b)
        -- body
        return a.id < b.id 
    end)

    return t
end

function BangPaiConf:getSkillById(id)
    -- body
    return self.gang_skill[id..""]
end

function BangPaiConf:getSkillLev( id ,lv)
    -- body\]
    local index = id * 1000 +  lv 
    return self.gang_skill_lev[index..""]
end

function BangPaiConf:getStoreItem(id)
    -- body
    return self.gang_store_item[id..""]
end

function BangPaiConf:getBoxItem(id)
    -- body
    return self.gang_box[id..""]
end

--喂养BOSS 根据ID(等级获得升级所需经验和奖励)
function BangPaiConf:getExpAndRewardById(id)
    return self.gang_boss_lvl[id..""]
end

function BangPaiConf:getFlameAward()
    return self.gang_flame_award.flame_award
end

--仙盟答题
function BangPaiConf:getQuestionData(id)
    return self.gang_question_pool[id..""]
end
--
function BangPaiConf:getGangActExpByLv(lv)
    local data = self.gang_act_exp[tostring(lv)]
    if data then
        return data.ext_exp
    end
    return 0
end
function BangPaiConf:getGangActAddExpByLv(lv)
    local data = self.gang_act_exp[tostring(lv)]
    if data then
        return data.exp
    end
    return 0
end

function BangPaiConf:getGangActives()
    local actives = {}
    for k,v in pairs(self.gang_actives) do
        table.insert(actives, v)
    end
    table.sort(actives, function(a, b)
        return a.sort < b.sort
    end)
    return actives
end

function BangPaiConf:getGangActive(id)
    return self.gang_actives[tostring(id)]
end

function BangPaiConf:getBangKejiSkilllist(id)
    -- body
    return self.gang_qianduan[tostring(id)]
end
function BangPaiConf:getBangKejiinfo(id)
    -- body
    return self.gang_tech_info[tostring(id)]
end
function BangPaiConf:getBangKejiselfinfo(id)
    -- body
    return self.gang_tech[tostring(id)]
end
function BangPaiConf:getBangTechStudy(id)
    -- body
    return self.gang_tech_study[tostring(id)]
end

function BangPaiConf:getAllkeji()
    -- body
    return table.values(self.gang_qianduan)
end
return BangPaiConf