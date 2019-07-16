--
-- Author: Your Name
-- Date: 2018-04-23 16:03:13
--

local CityWarConf = class("CityWarConf",base.BaseConf)

function CityWarConf:init()
    self:addConf("city_end_award")
    self:addConf("city_global")
    self:addConf("city_transfer")
    self:addConf("city_more_award")
end

function CityWarConf:getValue(id)
    return self.city_global[id..""]
end

--战果奖励展示
function CityWarConf:getAwardsData()
    local data = {}
    for _,awards in pairs(self.city_end_award) do
        if awards.type then
            for k,v in pairs(awards) do
                if awards.type == 1 then
                    if language.citywar09[k] then
                        local desc = language.citywar09[k]
                        table.insert(data,{v,["desc"] = desc})
                    end
                else
                    if language.citywar10[k] then
                        local desc = language.citywar10[k]
                        table.insert(data,{v,["desc"] = desc})
                    end
                end
            end
        end
    end
    return data
end

--连胜和终结奖励
function CityWarConf:getWinOrEndAwards()
    local data = {}
    for k,v in pairs(self.city_more_award) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--每日奖励
function CityWarConf:getDayAwardsDataById(id)
    local data = {}
    if self.city_end_award[id..""] then
        data = self.city_end_award[id..""].daily_awards
    end
    return data
end

--传送点对应数据
function CityWarConf:getTransferData(id)
    local data = {}
    if self.city_transfer[id..""] then
        data = self.city_transfer[id..""]
    end
    return data
end

return CityWarConf

-- {
--     1={700,都城个人胜利奖励},
--     2={1={1={221042064,10,1},2={221051006,1000,1}},都城仙盟胜利奖励},
--     3={350,都城个人失败奖励},
--     4={1={1={221042064,5,1},2={221051006,800,1}},都城仙盟失败奖励},
--     5={500,卫城个人胜利奖励},
--     6={1={1={221042066,10,1},2={221051006,600,1}},卫城仙盟胜利奖励},
--     7={250,卫城个人失败奖励},
--     8={1={1={221042066,5,1},2={221051006,400,1}},卫城仙盟失败奖励}
-- },