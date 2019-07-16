local VipChargeConf = class("VipChargeConf",base.BaseConf)

function VipChargeConf:init()
    self:addConf("charge_dc")  --充值界面配表
    self:addConf("vip_affect") --特权配表
    self:addConf("vip_attr")   --vip成长配表
    self:addConf("vip_awards") --礼包奖励配表
    self:addConf("affect_list")--特权
    self:addConf("charge_skip")--充值跳转
    self:addConf("vip_zklb")   --折扣礼包
end

function VipChargeConf:getChargeListData(id)
    -- body
    return self.charge_dc[tostring(id)]
end
--特权配表
function VipChargeConf:getAffectDataById(id)
    -- body
    return self.vip_affect[tostring(id)]
end
--不同等级VIP对应的特权ID数组
function VipChargeConf:getAffectID( vipType )
    -- vipType 1.白银 2.黄金 3.钻石
    if self.vip_affect[tostring(vipType)] then
        return self.vip_affect[tostring(vipType)].vip_affect
    end
    return nil
end

function VipChargeConf:getVipAttrData()
    local data = {}
    for k,v in pairs(self.vip_attr) do
        table.insert(data,v)
    end
    return data
end

function VipChargeConf:getVipAttrDataById(id)
    -- body
    return self.vip_attr[tostring(id)]
end

--获取特权图标
function VipChargeConf:getAffectImgById( id )
    -- body
    if self.affect_list[tostring(id)] then
        return self.affect_list[tostring(id)].img
    end
    return nil
end
--获取特权描述
function VipChargeConf:getAffectDecById( id )
    -- body
    if self.affect_list[tostring(id)] then
        return self.affect_list[tostring(id)].dec
    end
    return nil
end

--获取vip奖励列表
function VipChargeConf:getVipAwardsConf()
    -- body
    return self.vip_awards
end

--获取当前VIP对应的副本图标
function VipChargeConf:getVipAwardById( id )
    -- body
    if self.vip_awards[tostring(id)] then
        return self.vip_awards[tostring(id)]
    end
    return nil
end

--获取当前VIP对应的副本图标
function VipChargeConf:getFbImgById( id )
    -- body
    if self.vip_awards[tostring(id)] then
        return self.vip_awards[tostring(id)].fb_img
    end
    return nil
end

--获取当前VIP对应的每日礼包图标
function VipChargeConf:getDailyAwardsImg( id )
    -- body
    if self.vip_awards[tostring(id)] then
        return self.vip_awards[tostring(id)].daily_img
    end
    return nil
end

--获取当前VIP对应的每周礼包图标
function VipChargeConf:GetWeekAwardsImg( id )
    -- body
    if self.vip_awards[tostring(id)] then
        return self.vip_awards[tostring(id)].week_img
    end
    return nil
end

--获取当前VIP最大重置次数
function VipChargeConf:getVipAwardsReset( id )
    local data = self.vip_awards[tostring(id)]
    if data.vip_tequan then
        for k,v in pairs(data.vip_tequan) do
            if v[1] == 40101 then
                return v[2]
            end
        end
    end
    return 0
end
--充值跳转配表
function VipChargeConf:getDataById(id)
    -- body
    local data = self.charge_skip[tostring(id)]
    return data
end

--幸运云购可购买次数
function VipChargeConf:getVipAwardsReset( id )
    local data = self.vip_awards[tostring(id)]
    if data.vip_tequan then
        for k,v in pairs(data.vip_tequan) do
            if v[1] == 40103 then
                return v[2]
            end
        end
    end
    return 0
end

function VipChargeConf:getDiscountedPacksConf()
    local data = {}
    for k,v in pairs(self.vip_zklb) do
        table.insert(data, v)
    end
    table.sort(data,function (a,b)
        return a.id < b.id
    end)
    return data
end

--世界bossVIP可购买次数
function VipChargeConf:getWorldBossRest( id )
    local data = self.vip_awards[tostring(id)]
    if data.vip_tequan then
        for k,v in pairs(data.vip_tequan) do
            if v[1] == 40106 then
                return v[2]
            end
        end
    end
    return 0
end
--宠物岛VIP可购买次数
function VipChargeConf:getPetBossReset( id )
    local data = self.vip_awards[tostring(id)]
    if data.vip_tequan then
        for k,v in pairs(data.vip_tequan) do
            if v[1] == 40107 then
                return v[2]
            end
        end
    end
    return 0
end

--vip称号佩戴上限
function VipChargeConf:getVipNum(vipId)
    local data = self.vip_awards[""..vipId].vip_tequan
    local currentNum = 0 
    for k,v in pairs(data) do
        if v[1] == 40111 then
            currentNum = v[2]
        end
    end
    local data1 = {}
    for k,v in pairs(self.vip_awards) do
        for i,j in pairs(v.vip_tequan) do
             if j[1] == 40111 then
                table.insert(data1, {vip_level = v.vip_level,num = j[2]})
             end
        end
    end
    table.sort(data1,function(a,b)
        if a.vip_level ~= b.vip_level then
            return a.vip_level < b.vip_level
        end
    end)

    for k,v in pairs(data1) do
        if currentNum < v.num then
            return data1[k]
        end
    end
end

--vip最大上限
function VipChargeConf:getVipMAxNum()
    local num = 0
    for k,v in pairs(self.vip_awards) do
       num = num+1
    end
    local data = self.vip_awards[""..num-1].vip_tequan
    for k,v in pairs(data) do
        if v[1] == 40111 then
            return v[2]
        end
    end
end

--vip称号对应可持有数量
function VipChargeConf:getVipAccordNum(vipId)
    local data = self.vip_awards[""..vipId].vip_tequan
    for k,v in pairs(data) do
        if v[1] == 40111 then
            return v[2]
        end
    end
end

--神兽岛VIP可购买次数
function VipChargeConf:getShenShouReset( id )
    local data = self.vip_awards[tostring(id)]
    if data.vip_tequan then
        for k,v in pairs(data.vip_tequan) do
            if v[1] == 40108 then
                return v[2]
            end
        end
    end
    return 0
end
--飞升bossVIP可购买次数
function VipChargeConf:getFsBossRest( id )
    local data = self.vip_awards[tostring(id)]
    if data.vip_tequan then
        for k,v in pairs(data.vip_tequan) do
            if v[1] == 40110 then
                return v[2]
            end
        end
    end
    return 0
end

--遗迹探索可购买次数
function VipChargeConf:getYiJiTanSuoBuyTimes(id)
    local data = self.vip_awards[tostring(id)]
    if data.vip_tequan then
        for k,v in pairs(data.vip_tequan) do
            if v[1] == 40112 then
                return v[2]
            end
        end
    end
    return 0
end

--遗迹掠夺可购买次数
function VipChargeConf:getYiJiLueDuoBuyTimes(id)
    local data = self.vip_awards[tostring(id)]
    if data.vip_tequan then
        for k,v in pairs(data.vip_tequan) do
            if v[1] == 40113 then
                return v[2]
            end
        end
    end
    return 0
end

--生肖试炼可购买次数
function VipChargeConf:getShengXiaoBuyCount( id )
    local data = self.vip_awards[tostring(id)]
    if data.vip_tequan then
        for k,v in pairs(data.vip_tequan) do
            if v[1] == 40114 then
                return v[2]
            end
        end
    end
    return 0
end

--获取最高VIP等级
function VipChargeConf:getAllVIPAwards()
    local data = {}
    for k,v in pairs(self.vip_awards) do
        table.insert(data,v)
    end
    table.sort(data,function (a,b)
        return a.vip_level < b.vip_level
    end)
    return data
end
return VipChargeConf