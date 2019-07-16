--皇陵配置
local HuanglingConf = class("HuanglingConf",base.BaseConf)

function HuanglingConf:init()
    self:addConf("huangling_global")
    self:addConf("huangling_task")
    self:addConf("huangling_award")
end

--所有的皇陵任务
function HuanglingConf:getAllTask()
    -- body
    return self.huangling_task
end

--任务奖励
function HuanglingConf:getTaskAwardsById(id)
    -- body
    return self.huangling_task[tostring(id)]
end

--归属奖励
function HuanglingConf:getBossAwards(id)
    -- body
    if self.huangling_award[tostring(id)] then
        return self.huangling_award[tostring(id)].items
    end
end

--额外奖励
function HuanglingConf:getAdditionalAwards()
    -- body
    if self.huangling_award[tostring(2001)] then
        return self.huangling_award[tostring(2001)].items
    end
end

--预览奖励
function HuanglingConf:getPriviewAwards()
    -- body
    if self.huangling_global.preview then
        return self.huangling_global.preview
    end
end
--task_exp_coef任务经验系数
function HuanglingConf:getTaskExpCoef()
    -- body
    if self.huangling_global.task_exp_coef then
        return self.huangling_global.task_exp_coef
    end
end


return HuanglingConf