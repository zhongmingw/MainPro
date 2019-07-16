--
-- Author: ohf
-- Date: 2017-03-09 19:22:36
--
--副本关卡配置
local FubenConf = class("FubenConf",base.BaseConf)

local expNum = FuebenLevelNum.exp
local plotNum = FuebenLevelNum.plot
local towerNum = FuebenLevelNum.tower
local advanedNum = FuebenLevelNum.advaned

function FubenConf:init()
    self:addConf("fuben_global")
    self:addConf("fuben_pass_config")--F-副本关卡配置
    self:addConf("boss_dialog")--boss对话
    self:addConf("boss_global")
    self:addConf("elite_rank_award")--精英boss预览奖励
    self:addConf("elite_award")--精英boss奖励
    self:addConf("world_award")--世界boss对应奖励
    self:addConf("boss_home_layer")--boss之家进入条件
    self:addConf("boss_xianzhun_layer")--仙尊boss进入条件
    self:addConf("boss_home_award")--boss之家奖励
    self:addConf("xyjd_award")--仙域禁地奖励
    self:addConf("kf_xyjd_award")--跨服仙域禁地奖励
    self:addConf("xyjd_hide_boss")--跨服仙域禁地隐藏BOSS
    self:addConf("sgsj_award")--上古神迹奖励
    self:addConf("wxsd_award")--剑神台奖励
    self:addConf("fszd_award")--剑神台奖励
    self:addConf("guide_npc_config")--剧情npc
    self:addConf("fuben_sweep_cost")--副本扫荡卷
    --塔防配置
    self:addConf("xylt_ref") 
    self:addConf("tafang_global")

    self:addConf("daily_task_fuben_ref")

    self:addConf("cross_world_ref")
    self:addConf("cross_world_award")--跨服世界boss对应奖励

    self:addConf("dk_global")--天晶洞窟配置
    self:addConf("fszd_layer") --飞升进入条件
    self:addConf("ssd_award") --神兽岛奖励

    self:addConf("ssjt_ref")

    self:addConf("tgxj_award")

    self:addConf("sxsl_fuben_pass")--生肖试炼
    self:addConf("sxsl_fuben_open")
end

function FubenConf:getSSJTref( sId )
    -- body
    return self.ssjt_ref[tostring(sId)]
end

function FubenConf:getFszdlayer(id)
    -- body
    return self.fszd_layer[tostring(id)]
end

function FubenConf:getFszdMaxId()
    -- body
    local max = 0
    for k ,v in pairs(self.fszd_layer) do
        max = math.max(v.id,max)
    end
    return max 
end

function FubenConf:getTjdkValue(id)
    return self.dk_global[tostring(id)]
end

function FubenConf:getdailyFubenRed(id)
    -- body
    return self.daily_task_fuben_ref[tostring(id)]
end

function FubenConf:getXyltref(id)
    -- body
    return self.xylt_ref[tostring(id)]
end

function FubenConf:getTaFangValue(id)
    -- body
    return self.tafang_global[tostring(id)] 
end

function FubenConf:getGuideNpc(id)
    return self.guide_npc_config[tostring(id)]
end

function FubenConf:getValue(id)
    -- body
    return self.fuben_global[tostring(id)]
end

function FubenConf:getBossValue(id)
    -- body
    return self.boss_global[tostring(id)]
end

function FubenConf:getPassData(sceneId,lv)
    local id = sceneId..string.format("%03d", lv)
    return self.fuben_pass_config[id..""]
end

function FubenConf:getMubiaoData( sceneId , maxlv)
    -- body
    local t = {}
    for i = 1 , maxlv do 
        local id = sceneId..string.format("%03d", i)
        --plog(id)
        local var = self.fuben_pass_config[id..""].target_pass_num
        if var and var > 0 then
            table.insert(t,self.fuben_pass_config[id..""])
        end
    end

    table.sort(t,function(a,b)
        -- body
        return a.id < b.id
    end)

    return t 
end

function FubenConf:getPassDatabyId(passId)
    return self.fuben_pass_config[tostring(passId)]
end
--进阶副本
function FubenConf:getPassAdvanced()
    local lists = {}
    for k,v in pairs(self.fuben_pass_config) do
        local pex = tonumber(string.sub(v.id,1,6))
        if mgr.FubenMgr:isJinjie(pex) then
            table.insert(lists, v)
        end
    end
    table.sort(lists, function(a,b)
        return a.sort < b.sort
    end)
    return lists
end
--返回进阶副本的首通奖励
function FubenConf:getAdvancedFirstAwards(passId)
    local list = self:getPassAdvanced()
    for k,data in pairs(list) do
        for _,v in pairs(data) do
            if passId == v.id then
                return v
            end
        end
    end
end
--vip副本
function FubenConf:getPassVip()
    local lists = {}
    for k,v in pairs(self.fuben_pass_config) do
        local pex = tonumber(string.sub(v.id,1,6))
        if mgr.FubenMgr:isVipFuben(pex) then
            table.insert(lists, v)
        end
    end
    table.sort(lists, function(a,b)
        return a.id < b.id
    end)
    return lists
end
--返回vip副本的首通奖励
function FubenConf:getVipFirstAwards(passId)
    local list = self:getPassVip()
    for k,data in pairs(list) do
        if passId == data.id then
            return data
        end
    end
end
--经验副本
function FubenConf:getPassExp()
    local lists = {}
    for k,v in pairs(self.fuben_pass_config) do
        local pex = string.sub(v.id,1,6)
        if pex == tostring(Fuben.exp) then
            table.insert(lists, v)
        end
    end
    table.sort(lists, function(a,b)
        return a.id < b.id
    end)
    return self:getChapterData(lists,expNum),lists[#lists]
end
--返回经验副本的首通奖励
function FubenConf:getExpFirstAwards(passId)
    local list = self:getPassExp()
    for k,data in pairs(list) do
        for _,v in pairs(data) do
            if passId == v.id then
                return data[expNum]
            end
        end
    end
end
--剧情副本
function FubenConf:getPassPlot()
    local lists = {}
    for k,v in pairs(self.fuben_pass_config) do
        local pex = tonumber(string.sub(v.id,1,6))
        if mgr.FubenMgr:isPlotFuben(pex) then
            table.insert(lists, v)
        end
    end
    table.sort(lists, function(a,b)
        return a.id < b.id
    end)
    return self:getChapterData(lists,plotNum)
end
--返回剧情副本的首通奖励
function FubenConf:getPlotFirstAwards(passId)
    local list = self:getPassPlot()
    for k,data in pairs(list) do
        for _,v in pairs(data) do
            if passId == v.id then
                return v
            end
        end
    end
end
--爬塔副本
function FubenConf:getPassTower()
    local lists = {}
    for k,v in pairs(self.fuben_pass_config) do
        local pex = string.sub(v.id,1,6)
        if pex == tostring(Fuben.tower) then
            table.insert(lists, v)
        end
    end
    table.sort(lists, function(a,b)
        return a.id < b.id
    end)
    return self:getChapterData(lists,towerNum),lists[#lists]
end
--返回爬塔副本的首通奖励
function FubenConf:getTowerFirstAwards(passId)
    local list = self:getPassTower()
    for k,data in pairs(list) do
        for _,v in pairs(data) do
            if passId == v.id then
                return v
            end
        end
    end
end
--分章节
function FubenConf:getChapterData(lists,levelNum)
    local index = 1
    local data = {}
    for k,v in pairs(lists) do
        if data[index] then
            if #data[index] >= levelNum then
                index = index + 1
                data[index] = {}
            end
            table.insert(data[index], v)
        else
            data[index] = {}
            table.insert(data[index], v)
        end
    end
    return data
end
--剧情boss对话
function FubenConf:getBossDialog(type)
    local data = self.boss_dialog[type..""]
    if data then
        return data.dialog
    end
end

--个人boss
function FubenConf:getPersonalData()
    local lists = {}
    for k,v in pairs(self.fuben_pass_config) do
        local sId = tonumber(string.sub(v.id,1,6))
        if mgr.FubenMgr:isBossFuben(sId) then
            table.insert(lists, v)
        end
    end
    table.sort(lists, function(a,b)
        return a.id < b.id
    end)
    return lists
end
--根据排名找boss奖励
function FubenConf:getEliteAward(sceneId,rank)
    local lists = {}
    local id = tonumber(string.sub(sceneId,4,6))
    for k,v in pairs(self.elite_award) do
        local pex = math.floor(v.id / 1000)
        if v.type == 1 and id == pex then
            table.insert(list, v)
            if rank >= v.rank_begin and rank <= v.rank_end then
                return v
            end
        end
    end
    return list[#list]
end
--根据bossid找boss奖励
function FubenConf:getEliteRankAward(sceneId)
    local lists = {}
    for k,v in pairs(self.elite_rank_award) do
        if v.bossid == sceneId then
            table.insert(lists, v)
        end
    end
    table.sort(lists,function(a, b)
        return a.id < b.id
    end)
    return lists
end
--[[1:仇恨归属奖励
2:击杀奖励(最后一刀奖励)
3:boss血量低至50时参与奖励
4:boss死亡时参与奖励
]]
function FubenConf:getWorldAward(sceneId,type)
    local pex = tonumber(string.sub(sceneId,4,6)) * 1000
    local id = pex + type
    return self.world_award[tostring(id)]
end

function FubenConf:getBossHomeLayer(sceneId)
    local id = tonumber(string.sub(sceneId,4,6))
    return self.boss_home_layer[tostring(id)]
end

function FubenConf:getBossXianzhunLayer(sceneId)
    local id = tonumber(string.sub(sceneId,4,6))
    return self.boss_xianzhun_layer[tostring(id)]
end
--仙域禁地奖励
function FubenConf:getWorldBossAward(monsterId)
    for k,v in pairs(self.world_award) do
        if v.monster_id == monsterId then
            return v
        end
    end
end
--boss之家奖励
function FubenConf:getBossHomeAward(monsterId)
    for k,v in pairs(self.boss_home_award) do
        if v.monster_id == monsterId then
            return v
        end
    end
end
--仙域禁地奖励
function FubenConf:getXyjdAward(monsterId)
    for k,v in pairs(self.xyjd_award) do
        if v.monster_id == monsterId then
            return v
        end
    end
end
--跨服仙域禁地奖励
function FubenConf:getKfXyjdAward(monsterId)
    for k,v in pairs(self.kf_xyjd_award) do
        if v.monster_id == monsterId then
            return v
        end
    end
end

--跨服仙域禁地隐藏BOSS
function FubenConf:getKfXyjdHideAward()
    local data = {}
    for k,v in pairs(self.xyjd_hide_boss) do
        for k,v in pairs(v.monsters_id) do
           table.insert(data, v)
        end
    end
    return data
end

--跨服仙域禁地隐藏BOSS2
function FubenConf:getKfXyjdHideBoss()
    local data = {}
    for k,v in pairs(self.xyjd_hide_boss) do
        for k,v in pairs(v.monster_conf) do
           table.insert(data, {item = v,sign = 1})
        end
    end
    return data
end

--上古神迹奖励
function FubenConf:getSgsjAward(monsterId)
    for k,v in pairs(self.sgsj_award) do
        if v.monster_id == monsterId then
            return v
        end
    end
    return nil
end
--剑神台奖励
function FubenConf:getWxsdAward(monsterId)
    for k,v in pairs(self.wxsd_award) do
        if v.monster_id == monsterId then
            return v
        end
    end
    return nil
end
--飞升之地
function FubenConf:getfszdAward( monsterId )
    -- body
    
    for k,v in pairs(self.fszd_award) do
        if v.monster_id == monsterId then
            return v
        end
    end
    return nil
end

function FubenConf:getFubenSweepCost(id)
    return self.fuben_sweep_cost[tostring(id)]
end
--跨服世界boss奖励
function FubenConf:getKuafuWorldAward(monsterId)
    for k,v in pairs(self.cross_world_award) do
        if v.monster_id == monsterId then
            return v
        end
    end
end

--神兽到奖励
function FubenConf:getShenShouAward(monsterId)
    for k,v in pairs(self.ssd_award) do
        if v.monster_id == monsterId then
            return v
        end
    end
    return nil
end

--神兽到奖励2
function FubenConf:getShenShouAwardByScene(monsterId,sceneId)
    for k,v in pairs(self.ssd_award) do
        if v.monster_id == monsterId and v.scene_id == sceneId then
            return v
        end
    end
    return nil
end

--太古玄境奖励
function FubenConf:getTaiGuXuanJingAward(monsterId)
    for k,v in pairs(self.tgxj_award) do
        if v.monster_id == monsterId then
            return v
        end
    end
end

--生肖试炼关卡
function FubenConf:getSxslPassById(id)
    local data = {}
    for k,v in pairs(self.sxsl_fuben_pass) do
        if math.floor(v.id/1000) == id then
            table.insert(data,v)
        end
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end

--生肖关卡数据
function FubenConf:getSxslPassDataById( id )
    return self.sxsl_fuben_pass[tostring(id)]
end

--生肖试炼副本类型
function FubenConf:getSxslFuBenData()
    local data = {}
    for k,v in pairs(self.sxsl_fuben_open) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end
--生肖试炼副本信息
function FubenConf:getSxslFubenDataById( id )
    return self.sxsl_fuben_open[tostring(id)]
end

return FubenConf