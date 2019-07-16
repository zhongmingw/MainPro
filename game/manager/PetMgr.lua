--
-- Author: wx
-- Date: 2018-01-12 14:56:01
-- 宠物 系统的一些方法抽取

local PetMgr = class("PetMgr")

function PetMgr:ctor()
    
end

--排序
function PetMgr:sortPet(data)
    -- body
    local onwarpet = cache.PetCache:getCurpetRoleId()
    --排序按出战宠物排第一，其他宠物按 品质 战力 ID 降序排。
    table.sort(data,function(a,b)
        -- body
        local aonwar = a.petRoleId == onwarpet and 1 or 2
        local bonwar = b.petRoleId == onwarpet and 1 or 2

        if aonwar == bonwar then
            local ainfo = conf.PetConf:getPetItem(a.petId)
            local binfo = conf.PetConf:getPetItem(b.petId)
            if ainfo and binfo then
                if ainfo.color == binfo.color then
                    if a.power == b.power then
                        if a.petId == b.petId then
                            return a.petRoleId < b.petRoleId
                        else
                            return a.petId > b.petId
                        end
                    else
                        return a.power > b.power
                    end
                else
                    return ainfo.color > binfo.color
                end
            else
                if a.petId == b.a.petId then
                    return a.petRoleId < b.petRoleId
                else
                    return a.petId > b.petId
                end
                
            end
        else
            return aonwar < bonwar
        end
    end)
end
--获取宠物装备 按部位
function PetMgr:getEquipDataByPart( data,part )
    -- body
    if not data or not part then
        print("使用错误@wx")
        return nil 
    end
    if data.equipInfos then
        for k ,v in pairs(data.equipInfos) do
            local confdata = conf.ItemConf:getItem(v.mid) 
            if confdata.part == part then
                return v 
            end
        end
    end
    return nil 
end

--获取背包所有的宠物装备
function PetMgr:getPetPackEquip()
    -- body
    local info = cache.PackCache:getPackDataByType(Pack.equippetType)
    
    
    return info
end
--筛选条件 是否满足
function PetMgr:isCondition(data,color,star)
    -- body
    local condata = conf.ItemConf:getItem(data.mid)
    local number = mgr.ItemMgr:getColorBNum(data)
    local flag = false
    if condata.color <= color then
        flag = true
    else
        flag = false
    end
    if flag then
        if number <= star then
            flag = true
        else
            flag = false
        end
    end
    return flag
end
--查看技能信息信息
function PetMgr:seeSkillInfo(data)
    -- body
    --printt("data",data)
    local view = mgr.ViewMgr:get(ViewName.PetSkillMsgTips)
    if data then
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.PetSkillMsgTips,data)
        end  
    else
        if view then
            view:closeView()
        end
    end
end
--获取背包技能书
function PetMgr:getPackSkillItem()
    -- body
    local skilllist = {}
    local condata = conf.PetConf:getAllSkill()
    for k , v in pairs(condata) do
        if v.mid then
            local packdata = cache.PackCache:getPackDataById(v.mid)
            if packdata.amount > 0 then
                table.insert(skilllist,v)
            end
        end
    end

     table.sort(skilllist,function(a,b)
        -- body
        return a.mid < b.mid
    end)

    return skilllist
end


--检索宠物学习的技能
function PetMgr:getPetSkillInfoList(petid)
    -- body
    local skilllist = {}
    if not petid  then
        return skilllist
    end
    local petinfo = conf.PetConf:getPetItem(petid)
    if not petinfo then
        return skilllist
    end
    local condata = conf.PetConf:getAllSkill()
    if not condata then
        return skilllist
    end
    for k , v in pairs(condata) do
        if v.mid then 
            local packdata = cache.PackCache:getPackDataById(v.mid)
            if packdata.amount > 0 then
                for i , j in pairs(v.skill_type) do
                    if 4 == j or petinfo.type == j then
                        table.insert(skilllist,v)
                        break
                    end
                end
            end
        end
    end

    table.sort(skilllist,function(a,b)
        -- body
        return a.mid < b.mid
    end)

    return skilllist
end
--宠物是否学习过技能
function PetMgr:isHaveLearnItem(data,packdata)
    -- body
    if not data or not packdata then
        return false
    end
    local list = {}
    for k ,v in pairs(data.skillDatas) do
        --print("v",v)
        list[v] = true
    end

    local itemInfo = conf.ItemConf:getItem(packdata.mid)
    if not itemInfo then
        return false
    end
    if not itemInfo.ext01 then
        print("道具配置对应的技能缺少 ext01 ",packdata.mid)
        return false
    end
    --print("itemInfo.ext01",itemInfo.ext01)
    if list[tonumber(itemInfo.ext01)] then
        return true
    else
        return false
    end
end
--要学习的技能是否和当前已有技能互斥
function PetMgr:isSomeSkill(data,packdata)
    -- body
    if not data or not packdata then
        return false
    end
    local list = {}
    for k ,v in pairs(data.skillDatas) do
        list[v] = true
    end
    local itemInfo = conf.ItemConf:getItem(packdata.mid)
    if not itemInfo then
        return false
    end
    if not itemInfo.ext01 then
        print("道具配置对应的技能缺少 ext01 @策划",packdata.mid)
        return false
    end

    local condata = conf.PetConf:getPetSkillById(itemInfo.ext01)
    if not condata.mutex_skill then
        return false
    end
    if not condata then
        print("宠物技能缺少 @策划",itemInfo.ext01)
        return false
    end

    for k ,v in pairs(condata.mutex_skill) do
        if list[v] then
            return true , v
        end
    end

    return false
end

function PetMgr:isCanLearnItem( data,packdata )
    -- body
    if not data or not packdata then
        return false
    end
    local condata = conf.PetConf:getPetItem(data.petId)
    if not condata then
        return false
    end
    local itemInfo = conf.ItemConf:getItem(packdata.mid)
    if not itemInfo or not itemInfo.ext01 then
        return false
    end
    local skill = conf.PetConf:getPetSkillById(itemInfo.ext01)
    if not skill then
        return false
    end
    if skill.skill_type then
        for k , v in pairs(skill.skill_type) do
            if v == condata.type then
                return true
            end
        end
    end
    return false
end

--同类型技能
function PetMgr:isSomeTypeSkill(data,packdata)
    -- body
    if not data or not packdata then
        return false
    end
    local list = {}
    for k ,v in pairs(data.skillDatas) do
        local str = string.sub(v,2,4)
        list[str] = v
    end
    local itemInfo = conf.ItemConf:getItem(packdata.mid)
    if not itemInfo then
        return false
    end
    if not itemInfo.ext01 then
        print("道具配置对应的技能缺少 ext01 @策划",packdata.mid)
        return false
    end
    local idstr = string.sub(itemInfo.ext01,2,4)

    return list[idstr] 

end

--是否顶级了
function PetMgr:isPetMaxLevel(petData)
    -- body
    if not petData then
        print("使用错误@wx")
        return true
    end
    local condata = conf.PetConf:getPetItem(petData.petId)
    if petData.level >= condata.max_lvl then
        return true
    end
    if not conf.PetConf:getLevelUp(condata.type,petData.level+1) then
        return true
    end

    return false
end
--装备可以提供多少经验
function PetMgr:getEquipExp(data)
    -- body
    if not data then
        print("使用错误@wx")
        return 0
    end
    local exp = data.exp or 0
    local condata = conf.ItemConf:getItem(data.mid)
    if condata then
        exp = exp + (condata.partner_exp or 0)
    end
    if data.level then
        for i = 1 , data.level do
            local _t = clone(data)
            _t.level = i 
            local condata = conf.PetConf:getEquipLevelUp(_t)
            if condata then
                exp = exp + condata.need_exp
            end
        end
    end
    return exp
end
--计算宠物评分 flag = true --计算本地宠物评分
function PetMgr:getPetScore(data,flag)
    -- body
    if not data then
        return 0
    end
    local score = 0
    --宠物评分=宠物属性计算评分+宠物技能评分
    local petId = flag and data or data.petId
    local condata = conf.PetConf:getPetItem(petId)

    local skillDatas = {}
    skillDatas = flag and condata.init_skill or data.skillDatas

    local growValue = flag and condata.init_grow[1][1] or data.growValue

    local level = flag and 0 or data.level
    --宠物属性计算评分
    local proscore = 0
    
    local info = {}
    info.petId = petId
    info.level = level
    info.growValue = growValue
    if not flag and data.equipInfos then
        info.equipInfos = data.equipInfos
    end

    local t = self:getPetPro(info)
    for k , v in pairs(t) do
        proscore = proscore + mgr.ItemMgr:baseAttScore(v[1],v[2]*growValue/100)
    end
    --计算技能评分
    local skillscore = 0 
    for k ,v in pairs(skillDatas) do
        if v then
            local condata = conf.PetConf:getPetSkillById(v)
            if condata then
                skillscore = skillscore + (condata.skillscore or 0) 
            end
        end
    end

    return  checkint(proscore + skillscore) 
end

function PetMgr:changePercntToBase( petpro )
    -- body
    local t = {}
    local base = {}
    local precent = {}
    for k , v in pairs(petpro) do
        if conf.RedPointConf:getIsPrcent(v[1]) <= 0 then
            base[v[1]] = v[2]
        else
            precent[v[1]] = v[2]
        end
    end
    -- print("基础 start")
    -- for k ,v in pairs(base) do
    --     print(conf.RedPointConf:getProName( k ),v)
    -- end
    -- print("基础 end")

    -- print("百分比 start")
    -- for k ,v in pairs(precent) do
    --     local to = conf.RedPointConf:getaddtobase(k)
    --     if to then
    --         print(conf.RedPointConf:getProName( to ),(v/100).."%")
    --     else
    --         table.insert(t,{k,v})
    --         print(k,"不能转成固定属性")
    --     end
    -- end
    -- print("百分比 end")

    for k , v in pairs(precent) do
        local to = conf.RedPointConf:getaddtobase(k)
        if to then
            if base[to] then
                base[to] = base[to] + base[to] * v / 10000
            end
        else
            table.insert(t,{k,v})
        end
    end

    --print("计算结果")

    
    for k ,v in pairs(base) do
        table.insert(t,{k,checkint(v)})
    end

    table.sort(t,function(a,b)
        -- body 
        local asort = conf.RedPointConf:getProSort(a[1]) 
        local bsort = conf.RedPointConf:getProSort(b[1]) 
        if asort == bsort then
            return a[1]<b[1]
        else
            return asort < bsort
        end
    end)

    return t
end

--计算宠物属性
function PetMgr:getPetPro(data)
    -- body
    if not data then
        return {}
    end


    local protable = {}
    local confdata = conf.PetConf:getPetItem(data.petId)
    --宠物等级属性
    local _confdata = conf.PetConf:getLevelUp(confdata.type,data.level)
    local protable = GConfDataSort(_confdata)
    for k , v in pairs(protable) do
        protable[k][2] = v[2] * data.growValue / 100
    end

    --累计装备属性
    if data.equipInfos then
        for k ,v in pairs(data.equipInfos) do
            local _equipBase = self:getEquipPro(v)
            G_composeData(protable,_equipBase)
            for i , j in pairs(v.colorAttris) do
                local attiData = conf.ItemConf:getEquipColorAttri(j.type)
                if attiData and attiData.att_type then
                    G_composeData(protable,{{attiData.att_type,j.value}})
                end
            end 
        end
    end

    return self:changePercntToBase(protable) 
end

function PetMgr:getPetByCondition(index,petId)
    -- body
    if not index or not petId then
        return nil 
    end
    if index == 1 then
        local condata = conf.PetConf:getPetItem(petId)
        if condata and condata.next_stage then
            return conf.PetConf:getPetItem(condata.next_stage)
        end
    else
        local condata = conf.PetConf:getAllPetItem()
        for k , v in pairs(condata) do
            if v.next_stage and v.next_stage == petId then
                return v 
            end
        end
    end
    return nil 
end

function PetMgr:seeMarketInfo(data)
    -- body
    if not data then
        return 
    end
    local info =  {}
    info.petId = data.petInfo.petId
    info.skillDatas = data.petInfo.skillInfos
    info.growValue = data.petInfo.growValue
    info.name = data.name
    info.level = data.level
    info.exp = data.exp

    mgr.ViewMgr:openView2(ViewName.PetMsgView, info)
end

function PetMgr:seeLocalPet(petId)
    -- body
    if not petId then
        return
    end

    local data = {}
    data.localpetId = petId
    mgr.ViewMgr:openView2(ViewName.PetMsgView, data)
end

--市场能出售的宠物 
function PetMgr:getSelectCanSee()
    -- body
    local t = {}
    local data = cache.PetCache:getData()
    local onwarpet = cache.PetCache:getCurpetRoleId()
    for k ,v in pairs(data) do
        if onwarpet ~= v.petRoleId then
            table.insert(t,v)
        end
    end
    return t 
end
--宠物是否拥有装备
function PetMgr:isHaveEquip(data,flag)
    -- body
    if not data then
        return false
    end
    --print("0000000000000",#data.equipInfos)
    local fff = #data.equipInfos > 0
    if fff and flag then
        GComAlter(language.pet39)
    end
    return fff  
end
--计算宠物装备属性
--[[local data = {}
data.mid = data.mid
data.level = data.level or 0]]--
function PetMgr:getEquipPro(data)
    -- body
    if not data then
        return {}
    end
    local t = {}
    if data.level > 0 then
        t = GConfDataSort(conf.PetConf:getEquipLevelUp(data))
    end
    
    local t1 = GConfDataSort(conf.ItemArriConf:getItemAtt(data.mid))
    G_composeData(t,t1)
    return t
end
--[[
    local info = {}
    info.mid 
    info.level 
    info.colorAttris 
]]
function PetMgr:getBaseScor(info)
    -- body
    if not info then
        return 0
    end
    local t = mgr.PetMgr:getEquipPro(info)
    local score = 0
    for k,v in pairs(t) do
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])--计算综合战斗力
    end
    if info.colorAttris then
        for k,v in pairs(info.colorAttris) do
            score = score + mgr.ItemMgr:birthAttScore(v.type,v.value)--计算综合评分
        end
    else
        local birthAtt = conf.ItemConf:getBaseBirthAtt(data.mid)--推荐属性
        local isTuijian = true
        if not birthAtt then--固定生成的属性不走推荐
            isTuijian = false
            birthAtt = conf.ItemConf:getBirthAtt(data.mid) or {}  
        end
        for k,v in pairs(birthAtt) do
            if k % 2 == 0 then--值
                local type,value = birthAtt[k - 1],birthAtt[k]
                if not isTuijian then--如果是固定生成的
                    score = score + mgr.ItemMgr:birthAttScore(type,value)--计算综合评分
                end
            end
        end
    end
    return score
end

--对比装备评分 然后判断箭头
function PetMgr:conTrastScore(itemObj,data1,data2)
    -- body
    if not itemObj then
        return
    end
    local arrow = itemObj:GetChild("n19")
    if not arrow then
        return
    end
    if not data2 then
        arrow.visible = false
        return
    end

    local base1 = self:getBaseScor(data1)
    local base2 = self:getBaseScor(data2)

    
    if tonumber(base2) > tonumber(base1) then
        arrow.visible = true
        arrow.url = ResPath.iconRes("baoshi_018")
    elseif tonumber(base2) < tonumber(base1) then
        arrow.visible = true
        arrow.url = ResPath.iconRes("gonggongsucai_137")
    else
        arrow.visible = false
    end
end

function PetMgr:getProName(data)
    -- body
    if not data then
        return ""
    end
    local isprecent = conf.RedPointConf:getIsPrcent(data[1])
    --print(isprecent,data[1])
    if isprecent and isprecent == 1 then
        return language.pet48.. conf.RedPointConf:getProName(data[1])
    else
        return conf.RedPointConf:getProName(data[1])
    end
end

return PetMgr