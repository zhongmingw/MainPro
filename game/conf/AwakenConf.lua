--
-- Author: ohf
-- Date: 2017-02-22 17:07:33
--
--剑神（觉醒）配置
local AwakenConf = class("AwakenConf",base.BaseConf)

function AwakenConf:init()
    --剑神系统
    self:addConf("jianshen_image")
    self:addConf("jianshen_attr")
    self:addConf("jianshen_global")
    self:addConf("jianshen_skill")
    --剑神殿
    self:addConf("jsd_global")
    self:addConf("jsd_boss_award")
    --圣裝
    self:addConf("jianshen_suit_attr")
    self:addConf("jianshen_compose")
    -- self:addConf("jianshen_namebyid")
    

end

function AwakenConf:getEndMaxJie()
    return self.jianshen_global["endmaxjie"]
end

function AwakenConf:getOpenLv()
    return self.jianshen_global["open_level"]
end

function AwakenConf:getShengZhuangBagMax()
    return self.jianshen_global["shengzhuang_pack_max"]
end

function AwakenConf:getShengZhuangDefaultModel()
    return self.jianshen_global["jianshen_default_model"]
end
function AwakenConf:getJScompose(id)
    local data = {}
    for k,v in pairs(self.jianshen_compose) do
        if v.need_item[1] == id then
            return self.jianshen_compose[k]
        end
    end
    -- return self.jianshen_compose[tostring(id)]
end

function AwakenConf:getJScomposeInfo(id)
    -- body
    return self.jianshen_compose[tostring(id)]
end

--所有模型
function AwakenConf:getJsImage(type)
    local skinType = type or 1
    local data = {}
    for k,v in pairs(self.jianshen_image) do
        if skinType == v.skin_type then
            if v.skin_type == 1 and v.id <= self:getEndMaxJie() then
                table.insert(data, v)
            elseif v.skin_type == 2 then 
                table.insert(data, v)
            end
        end
    end
    table.sort(data,function(a,b)
        local aSort = a.sort or 0
        local bSort = b.sort or 0
        return aSort < bSort
    end)
    return data
end

--根据阶别获取剑神id
function AwakenConf:getIdByStarLv(starLv)
    local data = nil
    for k,v in pairs(self.jianshen_image) do
        if type(v.icon) == "number" and (v.icon%1000) == tonumber(starLv) then
            data = v
        end
    end
    if data then
        return data.id
    end
    return 1
end

function AwakenConf:getJsImageData(id)
    return self.jianshen_image[tostring(id)]
end
--名字
function AwakenConf:getName(id)
    local data = self.jianshen_image[id..""]
    local roleIcon = cache.PlayerCache:getRoleIcon()
    local sex = GGetMsgByRoleIcon(roleIcon).sex--性别
    if data then
        return data.name[sex]
    end
end
--技能
function AwakenConf:getSkillLv(id)
    local data = self.jianshen_image[id..""]
    if data then
        return data.skilllv
    end
end
--奖励
function AwakenConf:getAwards(id)
    local data = self.jianshen_image[id..""]
    if data then
        return data.awards
    end
end
--获取下一级技能剑神数据 curId当前阶数，curLev当前技能级别，index第几个技能
function AwakenConf:getSkillNextData(curId,curLev,index)
    local data = self:getJsImage()
    for k,v in pairs(data) do
        local skillData = v.skilllv
        local lv = skillData[index][2]
        if v.id > curId and lv > curLev then
            return v
        end
    end
end
--剑神buff
function AwakenConf:getBuffId(id)
    local data = self.jianshen_image[id..""]
    if data then
        return data.bs_buff
    end
end
--对应级别的属性
function AwakenConf:getJsAttr(lev)
    return self.jianshen_attr[lev..""]
end
--判断可以进阶到最大的等级
function AwakenConf:getUpMaxlv()
    -- local amount = 0
    -- local lv = 0
    -- local data = {}
    -- for k,v in pairs(self.jianshen_attr) do
    --     table.insert(data, v)
    -- end
    -- for k,v in pairs(data) do
    --     if v.id > curlevel then
    --         -- local cost = v.cost
    --         if cost then
    --             amount = amount + cost[1][2]
    --         end
    --         if amount > proData.amount then
    --             lv = v.id - 1
    --         else
    --            lv = v.id 
    --         end
    --     end
    -- end
    if not self.maxLv then
        self.maxLv = table.nums(self.jianshen_attr)
    end
    return self.maxLv
end

function AwakenConf:getMaxlv()
    return #self:getAllattr() - 1
end

function AwakenConf:getAllattr()
    local data = {}
    for k,v in pairs(self.jianshen_attr) do
        table.insert(data, v)
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end
--战斗力之差
function AwakenConf:getPower(starlv)
    local data = self:getAllattr()
    local power = 0
    for k,v in pairs(data) do
        if v.starlv == starlv then
            if v.star == 0 then
                if starlv == 1 then
                    power = v.power
                else 
                    return v.power
                end
            end
        end
    end
    return power
end

function AwakenConf:getAwakenSkill(id)
    return self.jianshen_skill[tostring(id)]
end

function AwakenConf:getJsdValue(id)
    return self.jsd_global[tostring(id)]
end

function AwakenConf:getJsdBossAward(id)
    return self.jsd_boss_award[tostring(id)]
end

function AwakenConf:getAllSuitAttr()
    -- body
    return table.values(self.jianshen_suit_attr)
end



function AwakenConf:getJsTaoZhuangshuxing(start)--根据星数返回套装属性列表
    local data = {}
    for k,v in pairs(self.jianshen_suit_attr) do
        local Start = string.sub(k,4,4)
        if Start == tostring(start)   then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
       if a.num ~= b.num then
            return a.num < b.num
        end
    end)
    return data
end



function AwakenConf:getJsNameByStartName(startNum)
    local data = {}                                  
    for k,v in pairs(self.jianshen_suit_attr) do
         local Start = string.sub(k,4,4)
        if Start == tostring(startNum)   then
            table.insert(data,v)       
        end
    end
    for k,v in pairs(data) do
        if v.js_name then
            return v.js_name
        end
    end
end

return AwakenConf