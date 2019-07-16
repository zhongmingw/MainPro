--
-- Author: 
-- Date: 2017-02-08 20:15:29
--
local SysConf = class("SysConf",base.BaseConf)

function SysConf:init()
    self:addConf("sys_conf")

    self:addConf("module_conf")

    self:addConf("loading_conf")--等级区间
    --战骑 灵童 特惠礼拜 仙尊礼包跳转限制
    self:addConf("hwbsb_conf")--
    self:addConf("loading_title")--加载场景提示
    self:addConf("loading_txt")--加载提示内容
    self:addConf("red_level_buff")--红名配置

    self:addConf("boss_tip")--s 世界boss配置
end

function SysConf:getBossTips()
    -- body
    local t = table.values(self.boss_tip)
    table.sort(t,function(a,b)
        -- body
        return a.id < b.id
    end)

    return t
end

function SysConf:getHwbSBItem(id)
    -- body
    return self.hwbsb_conf[tostring(id)]
end

function SysConf:getValue( id )
    -- body
    return self.sys_conf[id..""]
end

function SysConf:getModuleById(id)
    -- body
    
    -- if type(id) == number then 
    --     plog("值为number类型时：",id,type(id))
    -- else
    --     plog("值为table类型时：")
    --     printt(id)
    -- end

    return self.module_conf[id..""]

end

--意见反馈
function SysConf:getFirstReward()
    local confList = {}  
    table.insert(confList, self.sys_conf.idea_feedback_items)
    return confList
end

--隐藏任务奖励
function SysConf:getHiddenTasksReward()
    local confList = {}
    for k,v in pairs(self.sys_conf.hidden_task) do
        table.insert(confList, v)
    end
    return confList
end

--组队Tips显示
function SysConf:getPlus()
    -- body
    -- local confList = {}
    -- table.insert(confList, self.sys_conf.team_exp_coef)
    -- table.insert(confList, self.sys_conf.team_tq_coef)
    -- return confList

    return self.sys_conf.team_exp_coef
end

function SysConf:getLoadingConfById(id)
    return self.loading_conf[tostring(id)]
end

function SysConf:getLoadingConf()
    return self.loading_conf
end
--加载场景提示
function SysConf:getLoadingTitle()
    local data = {}
    for k,v in pairs(self.loading_title) do
        table.insert(data, v)
    end
    return data
end
--加载提示内容
function SysConf:getLoadingTxtByid(id)
    return self.loading_txt[tostring(id)]
end

--根据红名值获取
function SysConf:getRedDataByValue(value)
    local data = {}
    for k,v in pairs(self.red_level_buff) do
        if value >= v.red_value[1] and value <= v.red_value[2] then
            data = v
            break
        end
    end
    return data
end

--判断是否红名
function SysConf:isHongMing(value)
    local flag = false
    for k,v in pairs(self.red_level_buff) do
        if value >= v.red_value[1] and value <= v.red_value[2] then
            flag = true
            break
        end
    end
    return flag
end

return SysConf