--
-- Author: ohf
-- Date: 2017-02-07 15:35:44
--
local ForgingConf = class("ForgingConf",base.BaseConf)

function ForgingConf:init()
    self:addConf("duanzao_global")
    self:addConf("stage_duanzao_effect")
    self:addConf("equip_stren")--强化
    self:addConf("equip_star")--升星
    self:addConf("equip_suit")--套装
    self:addConf("equip_forge")--打造
    self:addConf("equip_gem_hole")--宝石
    self:addConf("equip_suit_effect")--套装特效
    self:addConf("equip_init_effect")--套装初始特效
    self:addConf("equip_star_effect")--升星套装
    self:addConf("equip_gem_effect")--宝石套装
    self:addConf("item_compose")--合成道具
    self:addConf("equip_split")--分解配置
    self:addConf("equip_compose")--合成消耗配置
    self:addConf("equip_suit_forge")--套装锻造
    self:addConf("compose_global")
    self:addConf("equip_show")
    self:addConf("equip_jinjie")
    self:addConf("equip_star02")
    self:addConf("equip_juexing")--觉醒
    self:addConf("equip_dress_star_suit")--装备星级属性
    self:addConf("xian_equip_compose")--装备星级属性
    self:addConf("god_equip_compose")--神(粉)装合成配置
    self:addConf("equip_gem_polish")--宝石抛光

end

function ForgingConf:getXianEquipCompose(id)
    -- body
    return self.xian_equip_compose[tostring(id)]
end

function ForgingConf:getGodEquipCompose(id)
    return self.god_equip_compose[tostring(id)]
end
--品质和阶相同的1~8部位
function ForgingConf:getGodEquipCompose2(id)
    local data = {}
    for k,v in pairs(self.god_equip_compose) do
        local part =v.id%100000%10000%100
        if part <= 8 then
            if math.floor(v.id/100) == id and #v.cost_item == 1 then
                table.insert(data,v)
            end
        end
    end
    return data
end

function ForgingConf:getJingjieById(id)
    -- body
    return self.equip_jinjie[tostring(id)]
end

function ForgingConf:getZhuxinById(id)
    -- body
    return self.equip_star02[tostring(id)]
end

function ForgingConf:getDataByType(index)
    -- body
    local _t = {}
    for k ,v in pairs(self.equip_show) do
        if v.type == index then
            table.insert(_t,v)
        end
    end
    return _t 
end

function ForgingConf:getComposeValue(id)
    -- body
    return self.compose_global[tostring(id)]
end

function ForgingConf:getValue(id)
    return self.duanzao_global[tostring(id)]
end

function ForgingConf:getStageDuanzao(id)
    return self.stage_duanzao_effect[tostring(id)]
end
--强化的累加属性
function ForgingConf:getStrenAtt(strenLev,attId)
    local att = 0
    for i=1,10 do
        local id = self:getForgingPart(i) * 1000 + strenLev

        local data = self.equip_stren[tostring(id)]
        if data and data.id.."" == id then
            if attId then--属性
                local num = data[""..attId] or 0
                att = att + num
            else--战斗力
                local num = data.power or 0
                att = att + num
            end
            
        end
    end
    return att
end

function ForgingConf:getEquipStren(id)
    return self.equip_stren[tostring(id)]
end
--强化的属性
function ForgingConf:getStrenAttData(strenLev,part)
    local id = self:getForgingPart(part) * 1000 + strenLev
    local data = self.equip_stren[tostring(id)]
    return data
end
--强化的金钱
function ForgingConf:getStrenMoney(strenLev,isOne)
    local playLv = cache.PlayerCache:getRoleLevel()
    local constMoney = 0
    if isOne then--单次强化的所需的金钱
        for i=1,10 do
            local id = self:getForgingPart(i) * 1000 + strenLev
            local data = self.equip_stren[tostring(id)]
            local lv = tonumber(string.sub(data.id, 4, 6))
            if data and data.id.."" == id and lv <= playLv then
                constMoney = constMoney + data.cost_money
            end
        end
    else--一键强化所需的金钱
        -- local t1 = Time.getTime()
        local money1 = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
        local data = cache.PackCache:getForgData()
        for i,forg in pairs(data) do
            local money = 0
            local maxLv = playLv
            if maxLv >= self:getStrengMaxLv() then
                maxLv = self:getStrengMaxLv()
            end
            for i=strenLev,maxLv do
                local id = self:getForgingPart(forg.part) * 1000 + i
                local strenData = self.equip_stren[tostring(id)]
                local const = strenData and strenData.cost_money or 0
                money = money + const
            end
            constMoney = constMoney + money
        end
        -- local t2 = Time.getTime()
        -- plog("消耗时间",t2 - t1)
    end
    return constMoney
end
--强化的最大级别
function ForgingConf:getStrengMaxLv()
    if self.stenLv then 
        return self.stenLv 
    end
    local pex = self:getForgingPart(1)
    local num = 0
    for k,v in pairs(self.equip_stren) do
        local id = tonumber(string.sub(v.id, 1, 3))
        if pex == id then
            num = num + 1
        end
    end
    local stenLv = num - 1
    self.stenLv = stenLv
    return stenLv
end
--根据部位和星级获取对应升星属性
function ForgingConf:getStarData(part,starlv)
    local id = self:getForgingPart(part) * 1000 + starlv
    local data = clone(self.equip_star[tostring(id)])
    -- if not data then 
    --     self:error(id)
    --     return nil
    -- end
    return data
end
--升星的最大级别
function ForgingConf:getStarMaxLv(part)
    local pex = self:getForgingPart(part)
    local num = 0
    for k,v in pairs(self.equip_star) do
        local id = tonumber(string.sub(v.id, 1, 3))
        if pex == id then
            num = num + 1
        end
    end
    return num - 1
end
--强化或者升星部位转化
function ForgingConf:getForgingPart(part)
    return 100 + part
end
--强化或者升星等级转化
function ForgingConf:getForginglev(forglv)
    local lv = ""
    if forglv < 10 then
        lv = "00"..forglv
    elseif forglv >= 10 and forglv < 100 then
        lv = "0"..forglv
    elseif forglv >= 100 and forglv < 1000 then
        lv = forglv
    end
    return lv
end
--套装
function ForgingConf:getAllSuit(id)
    local data = {}
    for k,v in pairs(self.equip_suit) do
        if not id then
            local isShow = v.isShow or 0
            if (v.type == 1 or v.type == 2) and isShow == 1 then
                local t = clone(v)
                t["open"] = 0
                t["redNum"] = 0
                table.insert(data, t)
            end
        elseif id == v.type then
            local t = clone(v)
            t["open"] = 0
            t["redNum"] = 0
            table.insert(data, t)
        end
    end
    table.sort(data,function(a,b)
        return a.sort < b.sort
    end)
    data[1].open = 1
    return data
end

function ForgingConf:getEquipSuit(id)
    return self.equip_suit[tostring(id)]
end
--打造
function ForgingConf:getMakeData(mid)
    local data = self.equip_forge[mid..""]
    if not data then 
        -- self:error(mid)
        return nil
    end
    return data
end
--该套装的打造数量
function ForgingConf:getMakeNum(equip_ids)
    local num = 0
    for k,id in pairs(equip_ids) do
        if self:getMakeData(id) then
            num = num + 1
        end
    end
    return num
end
--套装初始效果
function ForgingConf:getSuitInitEffect(id)
    return self.equip_init_effect[tostring(id)]
end
--返回对应的套装效果 id--穿戴的套装，num对应的数量
function ForgingConf:getSuitEffect(id,num,isLeijia)
    local effectId = id
    local data = {}
    if num then--如果有数量则返回对应效果
        for _,v in pairs(self.equip_suit_effect) do
            local mid = tonumber(string.sub(v.id, 1, 4))
            local equip_num = v.equip_num
            if mid == effectId and isLeijia and num >= equip_num then--求累加属性
                for k,value in pairs(v) do
                    if not data[k] then
                        data[k] = 0
                    end
                    if k ~= "level" and  k ~= "name" then
                        data[k] = data[k] + v[k]
                    else
                        data[k] = v[k]
                    end
                end
            elseif mid == effectId then
                if num == equip_num then
                    data = v
                end
            end
        end
        data["id"] = effectId
        -- local effectData = self:getSuitInitEffect(effectId)
        -- for k1,v1 in pairs(data) do
        --     for k2,v2 in pairs(effectData) do
        --         if not data[k2] then
        --             data[k2] = v2
        --         end
        --     end
        -- end
    else--返回该套装的对应数量
        for k,v in pairs(self.equip_suit_effect) do
            local mid = tonumber(string.sub(v.id, 1, 4))
            if mid == effectId then
                table.insert(data, v)
            end
        end
        table.sort(data,function (a,b)
            return a.id < b.id
        end)
    end
    
    return data
end
--返回对应的觉醒套装
function ForgingConf:getAwakenSuitEffect(id)
    local list = {}
    for k,v in pairs(self.equip_suit_effect) do
        if id == v.id or id + 1000 == v.id then
            table.insert(list, v)
        end
    end
    table.sort(list,function(a,b)
        return a.id < b.id
    end)
    return list
end

function ForgingConf:getSuitEffectById(id)
    return self.equip_suit_effect[id..""]
end
--根据部位选取宝石
function ForgingConf:getCamobyPart(part,hole)
    local id = self:getForgingPart(part).."0"..hole
    return self.equip_gem_hole[id]
end
--对应的升星套装属性
function ForgingConf:getStarEffect(id)
    local data = self.equip_star_effect[tostring(id)]
    if not data then return end
    local starData = {}
    for k,v1 in pairs(self.equip_star_effect) do
        if v1.id <= id then
            for k,v2 in pairs(v1) do
                if string.find(k,"att_") then
                    if not starData[tostring(k)] then
                        starData[tostring(k)] = 0
                    end
                    starData[tostring(k)] = starData[tostring(k)] + v2
                end
            end
            if not starData["power"] then
                starData["power"] = 0
            end
            starData["power"] = starData["power"] + v1.power
        end
    end
    starData["star"] = data.star
    return starData
end

function ForgingConf:getAllStarEffect()
    local data = {}
    for k,v in pairs(self.equip_star_effect) do
        table.insert(data, v)
    end
    return data
end
--对应的宝石套装属性
function ForgingConf:getCameoEffect(id)
    local data = self.equip_gem_effect[tostring(id)]
    if not data then return end
    local gemsData = {}
    for k,v1 in pairs(self.equip_gem_effect) do
        if v1.id <= id then
            for k,v2 in pairs(v1) do
                if string.find(k,"att_") then
                    if not gemsData[tostring(k)] then
                        gemsData[tostring(k)] = 0
                    end
                    gemsData[tostring(k)] = gemsData[tostring(k)] + v2
                end
            end
            if not gemsData["power"] then
                gemsData["power"] = 0
            end
            gemsData["power"] = gemsData["power"] + v1.power
        end
    end
    gemsData["gem_lev"] = data.gem_lev
    return gemsData
end

function ForgingConf:getAllCamoEffect()
    local data = {}
    for k,v in pairs(self.equip_gem_effect) do
        table.insert(data, v)
    end
    return data
end
--合成套装
function ForgingConf:getSuitFuse()
    local type = -1
    local data = {}
    for k,v in pairs(self.item_compose) do
        table.insert(data, v)
    end
    table.sort(data,function(a,b)
        return a.type < b.type
    end)
    local suit = {}
    for k,v in pairs(data) do
        --print("v",v.type)
        if v.type > type then
            type = v.type
            local i = #suit + 1
            local suitData = self:getSuitFuseData(type)
            local len = #suitData
            local t = {type = v.type, open = 0,suitData = suitData, redNum = 0,
            openlv = v.openlv,fslv = v.fslv or 0}
            --print("iiii",i,t,len,v.type)
            suit[i] = t
        end
    end
    -- suit[1].open = 1
    -- print("#suit",#suit)
    return suit
end

function ForgingConf:getSuitFuseData(type)
    local data = {}
    for k,v in pairs(self.item_compose) do
        if type == v.type then
            local sex = cache.PlayerCache:getSex()
            if v.sex then
                if v.sex == sex then
                    table.insert(data, v)
                end
            else
                table.insert(data, v)
            end
        end
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end

function ForgingConf:getItemCompose(id)
    return self.item_compose[tostring(id)]
end


function ForgingConf:getEquipSplit(id)
    local data = self.equip_split[id..""]
    return data
end

function ForgingConf:getEquipCompose(id)
    -- body
    return self.equip_compose[tostring(id)]
end

function ForgingConf:getEquipSuitForge(id)
    return self.equip_suit_forge[tostring(id)]
end

function ForgingConf:getEquipSuitForges(iType)
    local list = {}
    local temp = 10000000
    for k,v in pairs(self.equip_suit_forge) do
        local id = v.id
        local type = (id - id % temp) / temp
        if type == iType then
            table.insert(list, v)
        end
    end
    table.sort(list,function(a,b)
        return a.id < b.id
    end)
    return list
end

function ForgingConf:getEquipJuexing(id)
    return self.equip_juexing[tostring(id)]
end

function ForgingConf:getEquipStarAttr(starsNum)
    local data = {}
    for k,v in pairs(self.equip_dress_star_suit) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    local num = 0
    for i=1,#data do
        if data[i].star > starsNum then
            break
        end
        num = i
    end
    local presentData = data[num]
    local nextData = data[num+1]
    return presentData,nextData
end

function ForgingConf:getXianGodNeedPart()
    local data = {}
    for k,v in pairs(self.item_compose) do
        if v.type == 25 then
            if not data[v.part] then
                data[v.part] = v.need_part
            end
        end
    end
    return data
end

function ForgingConf:getComposeOpenLvByType(_type)
    local data = {}
    for k,v in pairs(self.item_compose) do
        if not data[v.type] then
            data[v.type] = v.openlv
        end
    end
    return data[_type] or 1
end

function ForgingConf:getGemPolishById(id)
    -- body
    return self.equip_gem_polish[tostring(id)]
end

function ForgingConf:getGemInfoByTypeAndPolish(_type,polish)
    for k,v in pairs(self.equip_gem_polish) do
        if v.type == _type and  v.polish == polish then
            return v
        end
    end
end
return ForgingConf