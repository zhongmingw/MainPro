--
-- Author: 
-- Date: 2018-02-22 14:22:57
--
--符文系统
local RuneConf = class("RuneConf",base.BaseConf)

function RuneConf:init()
    self:addConf("fuwen_global")
    self:addConf("fuwen_level_up")--符文升级
    self:addConf("fuwen_hole")--符文开启
    self:addConf("fuwen_explain_reback")--符文奖励
    self:addConf("fuwen_shop")--符文兑换
    self:addConf("fuwen_finding")
    self:addConf("fuwen_finding_pool")
    self:addConf("fuwen_finding_cost")
    self:addConf("fuwen_color_types")--符文品质类型
    self:addConf("fuwen_compose")--符文合成
    self:addConf("fuwen_items")--符文总览
    self:addConf("fuwen_over_title")--符文总览描述
    self:addConf("fuwen_line_link")--符文链接线
end

function RuneConf:getFuwenGlobal(id)
    return self.fuwen_global[tostring(id)]
end
--符文属性
function RuneConf:getFuwenlevelup(id)
    return self.fuwen_level_up[tostring(id)]
end
--符文孔
function RuneConf:getFuwenHole(id)
    return self.fuwen_hole[tostring(id)]
end

--符文孔
function RuneConf:getFuwenHoleByFloor(floor)
    local data = {}
    for k,v in pairs(self.fuwen_hole) do
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end)
    for k,v in pairs(data) do
        if v.open_floor > floor then
            return v
        end 
    end
    return nil
end
--符文兑换
function RuneConf:getFuwenShops()
    local data = {}
    for k,v in pairs(self.fuwen_shop) do
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.fw_tower < b.fw_tower
    end)
    return data
end

function RuneConf:getFuwenColorTypes()
    local data = {}
    for k,v in pairs(self.fuwen_color_types) do
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.sort < b.sort
    end)
    return data
end
--符文合成
function RuneConf:getFuwenComposes()
    return self.fuwen_compose
end

function RuneConf:getFuwenComposesByColor(color)
    local data = {}
    for k,v in pairs(self.fuwen_compose) do
        if v.color == color then
            table.insert(data, v)
        end
    end
    table.sort(data,function(a,b)
        return a.tower_lv < b.tower_lv
    end)
    return data
end

function RuneConf:getFuwenOverItems()
    return self.fuwen_items
end

function RuneConf:getFuwenOverItem(id)
    return self.fuwen_items[tostring(id)]
end
--符文总览标题
function RuneConf:getFuwenOverTitle(id)
    return self.fuwen_over_title[tostring(id)]
end
--符文连接线
function RuneConf:getFuwenLine(id)
    return self.fuwen_line_link[tostring(id)]
end

return RuneConf