--
-- Author: Your Name
-- Date: 2018-09-10 17:21:18
--神兽缓存
local ShenShouCache = class("ShenShouCache", base.BaseCache)

function ShenShouCache:init()
    self.shenshouData = nil--神兽信息
    self.zzShenShou = {}   --助战神兽信息
    self.holeCount = 0     --当前上阵位数量
end

function ShenShouCache:setShenShouCache(data)
    self.shenshouData = data
end

function ShenShouCache:setHoleCount(count)
    self.holeCount = count
end

--获取神兽当前上阵位数量
function ShenShouCache:getHoleCount()
    return self.holeCount
end

--获取助战神兽的装备信息
function ShenShouCache:getInWarShenShou()
    if self.shenshouData then
        self.zzShenShou = {}
        for k,v in pairs(self.shenshouData) do
            if v.inWar == 1 then
                table.insert(self.zzShenShou,v)
            end
        end
    end
    return self.zzShenShou
end

--计算神兽装备属性
function ShenShouCache:getEquipPro(data)
    -- body
    if not data then
        return {}
    end
    local t = {}
    if data.level > 0 then
        t = GConfDataSort(conf.ShenShouConf:getEquipLevelUp(data))
    end
    
    local t1 = GConfDataSort(conf.ItemArriConf:getItemAtt(data.mid))
    G_composeData(t,t1)
    return t
end

--神兽基础评分
function ShenShouCache:getBaseScor(info)
    -- body
    if not info then
        return 0
    end
    local t = self:getEquipPro(info)
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

--神兽装备对比 然后判断箭头
function ShenShouCache:conTrastScore(itemObj,data1,data2)
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

--获取神兽装备 按部位
function ShenShouCache:getEquipDataByPart( data,part )
    -- body
    if not data or not part then
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

--所有助战神兽装备是否有提升空间
function ShenShouCache:isCanPromote()
    local ssData = self:getInWarShenShou()
    local equipData = cache.PackCache:getPackDataByType(Pack.shenshouEquipType)
    local flag = false
    if ssData and #ssData > 0 then
        for k,v in pairs(ssData) do
            local shenshou = conf.ShenShouConf:getShenShouDataById(v.ssId)
            for _,eq in pairs(equipData) do
                local condata = conf.ItemConf:getItem(eq.mid)
                local info = self:getEquipDataByPart(v,condata.part)
                local color = shenshou.active_conf[condata.part][2]
                local score1 = self:getBaseScor(info)
                local score2 = self:getBaseScor(eq)
                if score2 > score1 and condata.color >= color then
                    flag = true
                    break
                end
            end
        end
    end
    return flag
end

--当前助战神兽装备是否有提升空间
function ShenShouCache:presentPromote(data)
    local equipData = cache.PackCache:getPackDataByType(Pack.shenshouEquipType)
    local shenshou = conf.ShenShouConf:getShenShouDataById(data.ssId)
    local flag = false
    for _,eq in pairs(equipData) do
        local condata = conf.ItemConf:getItem(eq.mid)
        local info = self:getEquipDataByPart(data,condata.part)
        local color = shenshou.active_conf[condata.part][2]
        local score1 = self:getBaseScor(info)
        local score2 = self:getBaseScor(eq)
        if score2 > score1 and condata.color >= color then
            flag = true
            break
        end
    end
    return flag
end

return ShenShouCache