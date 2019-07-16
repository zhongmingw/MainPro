--
-- Author: 
-- Date: 2017-02-24 17:03:45
--
local ZuoQiCache = class("ZuoQiCache",base.BaseCache)
--[[

--]]
function ZuoQiCache:init()
    self.data = {}
    --祝福时间
    self.isZhuFu = {false,false,false,false,false}
    --自动购买
    self.isTips = {false,false,false,false,false} --本次登录不在提示
    --自动购买选择的状态
    self.select = {false,false,false,false,false}
    --消耗元宝2次提示
    self.moneycost = {false,false,false,false,false}
    self.jiemoney = {}
    self.radioequip = false
end

function ZuoQiCache:setCurPass(jie,index,var)
    -- body
    if not jie or not index then
        return
    end

    if not self.jiemoney[index] then
        self.jiemoney[index] = {}
    end
    self.jiemoney[index][jie] = var
end

function ZuoQiCache:getCurPass( jie,index )
    -- body
    if self.jiemoney[index] then
        return  self.jiemoney[index][jie]
    end
    return false
end

function ZuoQiCache:getCostMoney( key )
    -- body
    return self.moneycost[key]
end

function ZuoQiCache:setCostMoney(key,var)
    -- body
    self.moneycost[key] = var
end

function ZuoQiCache:setIsTips(key,var)
    -- body
    self.isTips[key] = var
end

function ZuoQiCache:getIsTips(key)
    -- body
    return self.isTips[key]
end

function ZuoQiCache:setIsZhuFu(key,var)
    -- body
    self.isZhuFu[key] = var
end

function ZuoQiCache:getIsZhuFu(key)
    -- body
    return self.isZhuFu[key]
end

function ZuoQiCache:getSelectByIndex(index)
    -- body
    return self.select[index]
end

function ZuoQiCache:setSelectByIndex(k,v )
    -- body
    self.select[k] = v 
end
--祝福值提示数据
function ZuoQiCache:setBlessTipData(data)
    self.blessTipData = data
end

function ZuoQiCache:getBlessTipData()
    return self.blessTipData
end
--记录坐骑提示过的等级
function ZuoQiCache:setZuoqiCurLv(lv)
    self.zuoqiTipLv = lv
end

function ZuoQiCache:getZuoqiCurLv()
    return self.zuoqiTipLv or 0
end
--记录坐骑有没有提示过
function ZuoQiCache:setZuoqiIsTip(isZuoqiTip)
    self.isZuoqiTip = isZuoqiTip
end

function ZuoQiCache:getZuoqiIsTip()
    return self.isZuoqiTip
end
--记录装备是否升级10次
function ZuoQiCache:setEquipRadio(var)
    -- body
    self.radioequip = var

    -- if not self.radioequip[index] then
    --     self.radioequip[index]  = {}
    -- end

    -- self.radioequip[index][id] = var
end

function ZuoQiCache:getEquipRadio(id,index)
    -- body
    return self.radioequip
    -- if self.radioequip[index] then
    --     return self.radioequip[index][id]
    -- end
    -- return false
end

return ZuoQiCache