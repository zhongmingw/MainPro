--
-- Author: 
-- Date: 2018-12-03 12:01:37
--
local MianJuCache = class("MianJuCache",base.BaseCache)
--[[

--]]
function MianJuCache:init()
    self.mianjuData = {}--面具信息
end

function MianJuCache:getRed()
    if  self.mianjuData.maskInfos then
        local num1 = self:getMianJuCanActRed()--激活红点
        local num2 = self:getMianJuUpLevRed()--升级红点
        local num3 = self:getMianJuUpStarRed()--升星红点
        local num4 = self:getMianJuFumoRed()--附魔红点
        local num5 = self:getMianJuCzdRed()--成长丹红点
        local rednum = num1 + num2 + num3 + num4 + num5
        return rednum
    else
        -- print("打开界面速度比服务器返回消息快")
    end
    return 0
end 

function MianJuCache:setData(data)
    self.mianjuData = data
    printt("面具信息>>>>>>",data)
end 

function MianJuCache:refreshMianJuData(maskInfo)
    for k,maskInfos in pairs(self.mianjuData.maskInfos) do
        for i,j in pairs(maskInfos.maskSunInfos) do
            if j.id == maskInfo.id then
                self.mianjuData.maskInfos[k][i] = maskInfo
                print("更新缓存>>>>>>>")
                break
            end
        end
    end
end

function MianJuCache:refreshMianJuLvData(data)
    for k,maskInfos in pairs(self.mianjuData.maskInfos) do
        if data.maskType == maskInfos.maskType then
            self.mianjuData.maskInfos[k].level = data.level
            self.mianjuData.maskInfos[k].exp = data.exp
            self.mianjuData.maskInfos[k].power = data.power
            break
        end
    end
end

function MianJuCache:refreshGrowInfo(data)
    self.mianjuData.maskInfos[data.maskType].growInfo = data.growInfo
end

function MianJuCache:getData()
     return self.mianjuData 
end 

function MianJuCache:setMianJuChooseData(data)
    self.mianjuChooseData = data
end 

function MianJuCache:getMianJuChooseData()
     return self.mianjuChooseData or {}
end 

--当前背包是否有可激活面具红点
function MianJuCache:getMianJuCanActRed()
    local confData = conf.MianJuConf:getMianJuConfData()
    local redNum = 0
    for k,v in pairs(confData) do
        local itemId = v.itemId
        local itemData = cache.PackCache:getPackDataById(itemId)
        if itemData.amount > 0 and not self:isHasMianJu(v.id) then
            redNum = redNum + 1
        end
    end
    return redNum
end
--当前是否拥有此面具
function MianJuCache:isHasMianJu(id)
    local flag = false
    for k,v in pairs(self.mianjuData.maskInfos) do
        if v.maskSunInfos then
            for _,info in pairs(v.maskSunInfos) do
                if id == info.id then
                    flag = true
                    break
                end
            end
        end
    end
    return flag
end
--面具升级红点
function MianJuCache:getMianJuUpLevRed()
    local redNum = 0
    for k,v in pairs(self.mianjuData.maskInfos) do
        local cfgId = (1000+v.maskType)*1000 + v.level
        local confData = conf.MianJuConf:getMianJuLevConfData(cfgId)
        local nextConf = conf.MianJuConf:getMianJuLevConfData(cfgId+1)--下一等级
        if nextConf then
            local costItemData = conf.MianJuConf:getMianComsumeItem(v.maskType)
            for _,item in pairs(costItemData) do
                local mid = item[1]
                local itemData = cache.PackCache:getPackDataById(mid)
                if itemData.amount > 0 then
                    redNum = redNum + 1
                    return redNum
                end
            end
        end
    end
    return redNum
end
--成长丹红点
function MianJuCache:getMianJuCzdRed()
    local redNum = 0
    for k,v in pairs(self.mianjuData.maskInfos) do
        local growInfo = v.growInfo
        local growConf = conf.MianJuConf:getGrownNum(v.level,k)
        local midData = conf.MianJuConf:getGlobal("mask_grow_item")[k]
        for i,mid in pairs(midData) do
            local hasNum = cache.PackCache:getPackDataById(mid).amount
            local usenum = growInfo[mid] or 0
            -- print("usenum>>>>>>>>>>>",usenum,growConf[i][2],hasNum)
            if usenum < growConf[i][2] and hasNum > 0 then
                redNum = redNum + 1
                return redNum
            end
        end
    end
    return redNum
end
--面具升星红点
function MianJuCache:getMianJuUpStarRed()
    local redNum = 0
    for k,v in pairs(self.mianjuData.maskInfos) do
        if v.maskSunInfos then
            for _,info in pairs(v.maskSunInfos) do
                local confData = conf.MianJuConf:getMianjuStartData(info.id,info.starNum or 0)
                if confData and confData.item then
                    local flag = true
                    for i,item in pairs(confData.item) do
                        local mid = item[1]
                        local itemData = cache.PackCache:getPackDataById(mid)
                        if itemData.amount < item[2] then
                            flag = false
                        end
                    end
                    if flag then
                        redNum = redNum + 1
                        return redNum
                    end
                else
                    -- print("没有配置>>>>>>",info.id,info.starNum,confData)
                end
            end
        end
    end
    return redNum
end
--面具附魔红点
function MianJuCache:getMianJuFumoRed()
    local redNum = 0
    for k,v in pairs(self.mianjuData.maskInfos) do
        if v.maskSunInfos then
            for _,info in pairs(v.maskSunInfos) do
                local confData = conf.MianJuConf:getMianJuFuMo(info.id,info.fmLevel)
                local nextConf = conf.MianJuConf:getMianJuFuMo(info.id,info.fmLevel+1)
                if nextConf and confData.items then
                    local flag = true
                    for i,item in pairs(confData.items) do
                        local mid = item[1]
                        local itemData = cache.PackCache:getPackDataById(mid)
                        -- print("附魔道具>>>>>>",mid,itemData.amount)
                        if itemData.amount < item[2] then
                            flag = false
                        end
                    end
                    if flag then
                        redNum = redNum + 1
                        return redNum
                    end
                end
            end
        end
    end
    -- print("附魔红点》》》》",redNum)
    return redNum
end

return MianJuCache