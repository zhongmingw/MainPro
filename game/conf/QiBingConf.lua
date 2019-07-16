local QiBingConf = class("QiBingConf", base.BaseConf)

function QiBingConf:init()
	self:addConf("qibing_type")		--奇兵种类
    self:addConf("qibing_qh_lev")	--奇兵强化等级
    self:addConf("qibing_fl_lev")	--奇兵附灵等级
    self:addConf("qibing_sx_lev")	--奇兵升星等级
    self:addConf("qibing_fenjie")   --奇兵材料分解
end

function QiBingConf:getQiBingDataById(id)
    -- local data = {}
    -- for k,v in pairs(self.qibing_type) do
    --     if tonumber(v.id) == tonumber(id) then
    --         data = v
    --         break
    --     end
    -- end
    -- return data
    return self.qibing_type[tostring(id)]
end

--根据id和强化等级获取当前对应强化属性
function QiBingConf:getQhDataByLv(lv, id)
    -- local data = nil
    -- for k,v in pairs(self.qibing_qh_lev) do
    --     if (v.id%1000) == lv and math.floor(v.id/1000) == id then
    --         data = v
    --         break
    --     end
    -- end
    -- return data
    local tempId = id * 1000 + lv
    return self.qibing_qh_lev[tostring(tempId)]
end

--根据id和附灵等级获取当前对应附灵属性
function QiBingConf:getFlDataByLv(lv, id)
    -- local data = nil
    -- for k,v in pairs(self.qibing_fl_lev) do
    --     if (v.id%1000) == lv and math.floor(v.id/1000) == id then
    --         data = v
    --         break
    --     end
    -- end
    -- return data
    local tempId = id * 1000 + lv
    return self.qibing_fl_lev[tostring(tempId)]
end

--根据id获取附灵信息
function QiBingConf:getFlDataById(id)
    -- for k,v in pairs(self.qibing_fl_lev) do
    --     if v.id == id then
    --         return v
    --     end
    -- end
    return self.qibing_fl_lev[tostring(id)]
end

--根据id和升星等级获取当前对应升星属性
function QiBingConf:getSxDataByLv(lv, id)
    -- local data = nil
    -- for k,v in pairs(self.qibing_sx_lev) do
    --     if (v.id%1000) == lv and math.floor(v.id/1000) == id then
    --         data = v
    --         break
    --     end
    -- end
    -- return data
    local tempId = id * 1000 + lv
    return self.qibing_sx_lev[tostring(tempId)]
end

--根据道具id获得分解信息
function QiBingConf:getFenjieDataById(id)
    -- local data = {}
    -- for k,v in pairs(self.qibing_fenjie) do
    --     if tonumber(v.id) == tonumber(id) then
    --         data = v
    --         break
    --     end
    -- end
    -- return data
    return self.qibing_fenjie[tostring(id)]
end

function QiBingConf:getFenjieList()
    local list = {}
    for k, v in pairs(self.qibing_fenjie) do
        table.insert(list, v.id)
    end
    return list
end

function QiBingConf:getFlShenZhuAttr(id, flAttrLev)
    local list = {}
    local flAttrs = next(flAttrLev) and flAttrLev or {{all = 1}}
    for k, v in pairs(flAttrs) do
        local config = self:getFlDataByLv(k, id)
        if nil ~= config then
            for k2, v2 in pairs(config.attr or {}) do
                list["att_" .. v2[1]] = list["att_" .. v2[1]] or 0
                if v.all == 1 then
                    list["att_" .. v2[1]] = list["att_" .. v2[1]] + v2[2]
                elseif v.single == v2[1] then
                    list["att_" .. v2[1]] = list["att_" .. v2[1]] + v2[2]
                end
            end
        end
    end
    return list
end

function QiBingConf:getSxAttr(id)
    local level = id % 1000
    local list = {}
    for i = level, 0, -1 do
        local tempId = id - i
        local config = self:getFlDataById(tempId)
        if nil ~= config then
            for k2, v2 in pairs(config.attr or {}) do
                list["att_" .. v2[1]] = list["att_" .. v2[1]] or 0
                list["att_" .. v2[1]] = list["att_" .. v2[1]] + v2[2]
            end
        end
    end
    return list
end

return QiBingConf