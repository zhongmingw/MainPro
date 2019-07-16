--
-- Author: 
-- Date: 2018-08-22 19:39:50
--
local FeiShengCache = class("FeiShengCache",base.BaseCache)
--[[

--]]
local pairs = pairs
function FeiShengCache:init()
    self.data = {}
end

function FeiShengCache:setData(data)
    -- body
    self.data = data 
end

function FeiShengCache:getExchangeTimes( ... )
    -- body
    return self.data.exchangeTimes or 0
end

function FeiShengCache:getUseTimes()
    -- body
    return self.data.useTimes or 0
end

function FeiShengCache:getXl()
    -- body
    return self.data.xl or 0
end

function FeiShengCache:setIsSelect( data )
    -- body
    self.isselect = data.type
end

function FeiShengCache:getIsSelect( ... )
    -- body
    return self.isselect or 0
end


function FeiShengCache:setColor( color )
    -- body
    self.color = color
end

function FeiShengCache:getColor( color )
    -- body
    return self.color or 0
end

function FeiShengCache:setZuan( color )
    -- body
    self.zuan = color
end

function FeiShengCache:getZuan( color )
    -- body
    return self.zuan or 0
end

function FeiShengCache:setXing( color )
    -- body
    self.xing = color
end

function FeiShengCache:getXing( color )
    -- body
    return self.xing or 0
end



function FeiShengCache:hasNext()
    -- body
    local A541 = cache.PlayerCache:getAttribute(541)
    return conf.FeiShengConf:getLevUpItem(A541+1) 
end

--转化后的仙力等级 和 仙缘
function FeiShengCache:afterExchange()
    -- body
    local tolv = 0
    local exchangeexp = self:getXl()
      --/** 飞升等级 **/
    local A541 = cache.PlayerCache:getAttribute(541)
    local condata = conf.FeiShengConf:getXlexchangeItem(A541)
     --/** 仙力等级 **/
    local A543 = cache.PlayerCache:getAttribute(543)
    local min = conf.FeiShengConf:getValue("exchange_level")
    --print("exchangeexp,仙力值",exchangeexp)
    if A543 > condata.limit_xl_lev then
        tolv = math.max( A543 - min,condata.limit_xl_lev) 
        for i = A543 , tolv + 1,-1 do
            local confdata = conf.FeiShengConf:getXlLevUpItem(i - 1)
            exchangeexp = exchangeexp + confdata.need_xl
            --print("等级累计",i-1,exchangeexp)
        end
    else
        tolv = A543
        exchangeexp = 0
    end

    local cc = conf.FeiShengConf:getValue("xl_exchange_rate") 
    return tolv , math.floor(exchangeexp / cc[1] * cc[2])  
end
--属性计算
function FeiShengCache:getAllPro( )
    -- body
    local t = {}
    
    local data = cache.PackCache:getXianEquipData()
    if data then
        -- 装备的基础属性
        for k ,v in pairs(data) do
             --装备的附加属性
            local condata = conf.ItemArriConf:getItemAtt(v.mid)
            G_composeData(t,GConfDataSort(condata)) 

            if condata and condata.attach_att then
                --检测是否激活
                for i , j in pairs(condata.attach_att) do
                    local _c = conf.FeiShengConf:getFsAttachattr(j)
                    if _c then
                        --检测模块等级是否满足
                        if cache.PlayerCache:getDataJie(_c.module_id) >= _c.need_step then
                            G_composeData(t,GConfDataSort(_c)) 
                            --print("额外加")
                        end
                    else
                        print("道具属性表 + ",j,"但是飞升表里面没有")
                    end
                end
            end
        end
    end
    --飞升属性
    local A541 = cache.PlayerCache:getAttribute(541)
    local confdata = conf.FeiShengConf:getLevUpItem(A541)
    G_composeData(t,GConfDataSort(confdata))
    --仙力属性
    local A543 = cache.PlayerCache:getAttribute(543)
    local confdata = conf.FeiShengConf:getXlLevUpItem(A543)
    G_composeData(t,GConfDataSort(confdata))

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

function FeiShengCache:getAllBestPro()
    -- body
    local t = {}
    local pairs = pairs
    local data = cache.PackCache:getXianEquipData()
    if data then
        --装备的极品属性
        for k ,v in pairs(data) do
            if v.colorAttris then
                for i , j in pairs(v.colorAttris) do
                    --printt(j)
                    local attiData = conf.ItemConf:getEquipColorAttri(j.type)
                    if attiData.att_type then
                        G_composeData(t,{{attiData.att_type,j.value}})
                    end
                end
            end
        end
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

function FeiShengCache:isOpen()
    -- body
    local A541 = cache.PlayerCache:getAttribute(541)
    if A541 > 0 then
        return true
    end
    local condata = conf.FeiShengConf:getLevUpItem(A541)
    if condata.need_lev then
        if cache.PlayerCache:getRoleLevel() < condata.need_lev then
            return false
        end
    end

    if condata.need_xy then
        local A542 = cache.PlayerCache:getAttribute(A542)
        if A542 < condata.need_xy then
            return false
        end
    end

    return true
end

function FeiShengCache:isCanWear(data)
    -- body
    local A541 = cache.PlayerCache:getAttribute(541)
    local index = data.indexs[1]
    local info = cache.PackCache:getPackDataByIndex(index)
    local lv = conf.ItemConf:getStagelvl(info.mid)
    return A541 >= lv

end

return FeiShengCache