--
-- Author: Your Name
-- Date: 2018-06-28 16:43:16
--
local ShenQiConf = class("ShenQiConf", base.BaseConf)

function ShenQiConf:ctor()
    self:addConf("shenqi_type")--神器种类
    self:addConf("shenqi_qh_lev")--神器强化等级
    self:addConf("shenqi_fl_lev")--神器附灵等级
    self:addConf("shenqi_sx_lev")--神器升星等级
    self:addConf("shenqi_fenjie")--神器材料分解
end

function ShenQiConf:getShenQiDataById(id)
    local data = {}
    for k,v in pairs(self.shenqi_type) do
        if tonumber(v.id) == tonumber(id) then
            data = v
            break
        end
    end
    return data
end

--根据id和强化等级获取当前对应强化属性
function ShenQiConf:getQhDataByLv(lv,id)
    local data = nil
    for k,v in pairs(self.shenqi_qh_lev) do
        if (v.id%1000) == lv and math.floor(v.id/1000) == id then
            data = v
            break
        end
    end
    return data
end

--根据id和附灵等级获取当前对应附灵属性
function ShenQiConf:getFlDataByLv(lv,id)
    local data = nil
    for k,v in pairs(self.shenqi_fl_lev) do
        if (v.id%1000) == lv and math.floor(v.id/1000) == id then
            data = v
            break
        end
    end
    return data
end

--根据id获取附灵信息
function ShenQiConf:getFlDataById(id)
    for k,v in pairs(self.shenqi_fl_lev) do
        if v.id == id then
            return v
        end
    end
end

--根据id和升星等级获取当前对应升星属性
function ShenQiConf:getSxDataByLv(lv,id)
    local data = nil
    for k,v in pairs(self.shenqi_sx_lev) do
        if (v.id%1000) == lv and math.floor(v.id/1000) == id then
            data = v
            break
        end
    end
    return data
end

--根据道具id获得分解信息
function ShenQiConf:getFenjieDataById(id)
    local data = {}
    for k,v in pairs(self.shenqi_fenjie) do
        if tonumber(v.id) == tonumber(id) then
            data = v
            break
        end
    end
    return data
end

return ShenQiConf