--
-- Author: wx
-- Date: 2018-09-05 17:27:50
--
local YouXunConf = class("YouXunConf",base.BaseConf)

function YouXunConf:init()
    self:addConf("yx_global")
    self:addConf("yx_game")
    self:addConf("yx_yz_gift")
    self:addConf("yx_vip_day_gift")
    self:addConf("yx_lev_gift")
    self:addConf("yx_cz_gift")
    self:addConf("yx_cost_gift")
    self:addConf("yx_show_list")
    self:addConf("tq_list")
    self:addConf("yx_year_day_gift")
    self:addConf("yx_agent")--
end

--根据平台id获取特权类型
function YouXunConf:getTeQuanType()
    local var = cache.PlayerCache:getRedPointById(10327)--平台id
    local cfgData = self.yx_agent[tostring(var)]
    local tqType = 0
    if cfgData then
        if cfgData.package_act then
            local packId = tonumber(g_var.packId)
            for k,v in pairs(cfgData.package_act) do
                if v[1] == packId then
                    tqType = v[2]
                    break
                end
            end
            return tqType
        else
            tqType = cfgData.def_yx or 0
            return tqType
        end
    else
        return tqType
    end
end

function YouXunConf:getValue(id)
    -- body
    return self.yx_global[tostring(id)]
end
--显示列表
function YouXunConf:getShowList()
    -- body
    local data = {}
    local openModuleId = self:getOpenModule()
    for k,v in pairs(openModuleId) do
        if self.yx_show_list[tostring(v)] then
            print("开启的模块",v)
            table.insert(data,self.yx_show_list[tostring(v)])
        end
    end
    return data
end
--当前显示页签对应配置
function YouXunConf:getNowListData(tabId)
    return self.yx_show_list[tostring(tabId)]
end
--悠钻礼包
function YouXunConf:getYzGigt( )
    -- body
    local data = {}
    local tqType = self:getTeQuanType()
    for k,v in pairs(self.yx_yz_gift) do
        if not v.act_type then
            table.insert(data,v)
        else
            for _,tq in pairs(v.act_type) do
                if tqType == tq then
                    table.insert(data,v)
                    break
                end
            end
        end
    end
    return data
end
--每日礼包
function YouXunConf:getYzVipDayGift( )
    -- body
    local data = {}
    local tqType = self:getTeQuanType()
    for k,v in pairs(self.yx_vip_day_gift) do
        if not v.act_type then
            table.insert(data,v)
        else
            for _,tq in pairs(v.act_type) do
                if tqType == tq then
                    table.insert(data,v)
                    break
                end
            end
        end
    end
    return data
    
end
--等级礼包
function YouXunConf:getYzLevGift( )
    -- body
    return table.values(self.yx_lev_gift)
    
end
--充值礼包
function YouXunConf:getYzCzGift( )
    -- body
    return table.values(self.yx_cz_gift)
end
--消费礼包
function YouXunConf:getYzCostGift( ... )
    -- body
    return table.values(self.yx_cost_gift)
end
--获取当前特权开启功能
function YouXunConf:getOpenModule()
    print("悠讯特权>>>>>>>>>>>",g_var.yx_game_param,g_var.packId)
    if g_var.yx_game_param and g_var.yx_game_param ~= "" then
        if self.tq_list[tostring(g_var.packId)] then
            return self.tq_list[tostring(g_var.packId)].tab_id
        else
            return self.tq_list["1001"].tab_id
        end
    else
        return {}
    end
end
--获取当前特权对应conf
function YouXunConf:getPrivilegeConf(pid)
    if self.tq_list[tostring(pid)] then
        return self.tq_list[tostring(pid)]
    end
    return nil
end
--年费礼包
function YouXunConf:getYzYearGift()
    return table.values(self.yx_year_day_gift)
end
return YouXunConf