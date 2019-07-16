--
-- Author: 
-- Date: 2017-02-27 19:47:48
--
local HuobanCache = class("HuobanCache",base.BaseCache)
--[[

--]]
function HuobanCache:init()
    self.data = {}
    --祝福时间
    self.isZhuFu = {false,false,false,false}
    --自动购买
    self.isTips = {false,false,false,false} --本次登录不在提示
     --自动购买选择的状态
    self.select = {false,false,false,false}
     --消耗元宝2次提示
    self.moneycost = {false,false,false,false}
    
    self.jiemoney = {}
    self.radioequip = false

end

function HuobanCache:setCurPass(jie,index,var)
    -- body
    if not jie or not index then
        return
    end

    if not self.jiemoney[index] then
        self.jiemoney[index] = {}
    end
    self.jiemoney[index][jie] = var
end

function HuobanCache:getCurPass( jie,index )
    -- body
    if self.jiemoney[index] then
        return  self.jiemoney[index][jie]
    end
    return false
end

function HuobanCache:getCostMoney( key )
    -- body
    return self.moneycost[key]
end

function HuobanCache:setCostMoney(key,var)
    -- body
    self.moneycost[key] = var
end

function HuobanCache:setIsTips(key,var)
    -- body
    self.isTips[key] = var
end

function HuobanCache:getIsTips(key)
    -- body
    return self.isTips[key]
end

function HuobanCache:setIsZhuFu(key,var)
    -- body
    self.isZhuFu[key] = var
end

function HuobanCache:getIsZhuFu(key)
    -- body
    return self.isZhuFu[key]
end

function HuobanCache:getSelectByIndex(index)
    -- body
    return self.select[index]
end

function HuobanCache:setSelectByIndex(k,v )
    -- body
    self.select[k] = v 
end

function HuobanCache:setData(data)
    -- body
    self.data = data
end

function HuobanCache:getData()
    -- body
    return self.data
end

function HuobanCache:setName(id,name)
    -- body
    if not self.data then
        return
    end
    if not self.data.skins then
        return
    end
    for k , v in pairs(self.data.skins) do
        if v.skinId == id then
            v.name = name
            break
        end
    end
end

function HuobanCache:getName(id)
    -- body
    if not self.data then
        return ""
    end
    if not self.data.skins then
        return "" 
    end
    for k , v in pairs(self.data.skins) do
        if v.skinId == id then
            return v.name
        end
    end
end

function HuobanCache:setLevelData(data)
    -- body
    if not self.data then
        return
    end
    self.data.lev = data.lev
end

function HuobanCache:getLevelData()
    -- body
    if not self.data then
        return 0
    end
    return self.data.lev
end

--记录装备是否升级10次
function HuobanCache:setEquipRadio(var)
    -- body
    self.radioequip =  var
end

function HuobanCache:getEquipRadio(id,index)
    -- body
    return self.radioequip
end

--灵童吞噬装备一星装备选择状态
function HuobanCache:setSelectState(flag)
    self.selectState = flag
end

function HuobanCache:getSelectState()
    return self.selectState
end
--灵童吞噬装备品阶选择状态
function HuobanCache:setJieText(var)
    self.jieState = var
end
function HuobanCache:getJieText()
    return self.jieState
end
function HuobanCache:setSelfJie(var)
    self.jie = var
end
function HuobanCache:getSelfJie()
    return self.jie
end

--灵童吞噬装备品质颜色选择状态
function HuobanCache:setcolorText(var)
    self.colorState = var
end
function HuobanCache:getcolorText()
    return self.colorState
end
function HuobanCache:setSelfColor(var)
    self.color = var
end
function HuobanCache:getSelfColor()
    return self.color
end

return HuobanCache