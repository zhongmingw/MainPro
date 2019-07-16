--
-- Author: ohf
-- Date: 2017-03-14 16:21:21
--
local FubenCache = class("FubenCache",base.BaseCache)
--[[
副本缓存
--]]
function FubenCache:init()
    self.passLists = {}
    self.firstData = {}--首通奖励 （{} = 关卡id,value）
    self:cleanMonsters()
    self.checkItems = {}--副本获得的道具
    self.checkEquips = {}--副本获得的装备
    self.notTipFubens = {}
    self.fubenCanList = {}
    self.guideNpcs = {}--缓存剧情npc
    self.firstTowers = {}--缓存刚刚打过的通天塔
    self.chooseBossId = 0--选中的世界bossId

    self.chooseMonsterId = 0--选中的怪物id

    self.sceneTaskMsg = {} --场景任务追踪信息

    self.DayKey = {}
    self.DayBo = {}
end

function FubenCache:setChooseMonsterId(monsterId)
    self.chooseMonsterId = monsterId
end

function FubenCache:getChooseMonsterId()
    return self.chooseMonsterId
end

function FubenCache:setsceneTaskMsg(module_id,data)
    -- body
    self.sceneTaskMsg[module_id] = data
end

function FubenCache:getsceneTaskMsg( module_id )
    -- body
    return self.sceneTaskMsg[module_id]
end

function FubenCache:setCopperLastTime(time)
    self.copperLastTime = time
end

function FubenCache:getCopperLastTime()
    return self.copperLastTime
end
--清理怪物
function FubenCache:cleanMonsters()
    self.expMonsters = {}
end

function FubenCache:setCurrPass(sId,passId)
    self.passLists[sId] = tonumber(passId)
end

function FubenCache:getDayKey(sId)
    return self.DayKey[sId] or 0
end

function FubenCache:setDayKey(sId,passId)
    self.DayKey[sId] = tonumber(passId)
end

function FubenCache:getCurBo(sId)
    return self.DayBo[sId] or 0
end

function FubenCache:setCurBo(sId,passId)
    self.DayBo[sId] = tonumber(passId)
end



function FubenCache:getCurrPass(sId)
    return self.passLists[sId] or 0
end
--经验副本怪物击杀数量
function FubenCache:setExpMonsters(conMap)
    self.expMonsters = conMap
end

function FubenCache:getExpMonsters(monsterId)
    return self.expMonsters[monsterId] or 0
end

function FubenCache:getAllMonsters()
    return self.expMonsters
end
--设置首通奖励
function FubenCache:setFirstData(passId,value)
    passId = tonumber(passId)
    local isNotUpdate = true
    for k,v in pairs(self.firstData) do
        if v and v.passId == passId then
            self.firstData[k].value = value
            isNotUpdate = nil
        end
    end
    if isNotUpdate then
        table.insert(self.firstData, {passId = passId,value = value})
    end
end
--返回最小的首通奖励
function FubenCache:getMinFirstPass(sId,curId)
    local passId = tonumber(curId)
    table.sort( self.firstData, function(a,b)
        return a.passId < b.passId
    end)
    for k,v in pairs(self.firstData) do
        local pex = tonumber(string.sub(v.passId,1,6))
        if v.passId <= passId and pex == sId then
            if v.value == 1 then
                return v.passId
            end
        end
    end
    return tonumber(passId)
end

function FubenCache:getFirstData(curId)
    for k,v in pairs(self.firstData) do
        if v.passId == curId then
            return v
        end
    end
end

function FubenCache:setFirstTime(time)
    self.firstTime = time
end

function FubenCache:getFirstTime()
    return self.firstTime or 0
end
--缓存副本模块
function FubenCache:setFubenModular(modular)
    self.modular = modular
end

function FubenCache:getFubenModular()
    return self.modular
end
--记录剧情副本第几页
function FubenCache:setPlotIndex(index)
    self.plotIndex = index
end

function FubenCache:getPlotIndex()
    return self.plotIndex
end
--记录进阶副本第几页
function FubenCache:setAdvIndex(index)
    self.advIndex = index
end

function FubenCache:getAdvIndex()
    return self.advIndex or 0
end
--是否第一次进入副本
function FubenCache:setIsFrist(isFrist)
    self.isFrist = isFrist
end

function FubenCache:getIsFrist()
    return self.isFrist
end
--练级谷场景信息
function FubenCache:setLevelData(data)
    self.levelData = data
end
--练级谷时间
function FubenCache:setLevelLeftTime(leftTime)
    if self.levelData then
        self.levelData.leftTime = leftTime
    end
end
--练级谷时间
function FubenCache:getLevelLeftTime()
    return self.levelData and self.levelData.leftTime or 0
end
--练级谷加成时间
function FubenCache:setExpPlusLeftTime(leftTime)
    self.levelData.expPlusLeftTime = leftTime
end

function FubenCache:getLevelData()
    return self.levelData
end
--精英boss场景数据
function FubenCache:setEliteData(data)
    self.eliteData = data
end

function FubenCache:getEliteData()
    return self.eliteData or {}
end
--精英boss剩余挑战时间
function FubenCache:setEliteTime(leftTime)
    if self.eliteData then
        self.eliteData.leftPlayTime = leftTime
    end
end

function FubenCache:getEliteTime()
     return self.eliteData and self.eliteData.leftPlayTime
end
--精英boss排行榜刷新广播
function FubenCache:setEliteRank(data)
    if self.eliteData then
        self.eliteData.rankList = data.rankList
    end
end
--精英boss攻击伤害广播
function FubenCache:setEliteHurt(data)
    if self.eliteData then
        self.eliteData.myHurtMul = data.myHurtMul
        self.eliteData.myHurtMod = data.myHurtMod
    end
end
--精英boss血条变化广播
function FubenCache:setEliteHp(data)
    if self.eliteData then
        self.eliteData.curHpPercent = data.curHpPercent
    end
end

--世界boss场景数据
function FubenCache:setWorldData(data)
    self.worldData = data
end

function FubenCache:updateWorldData(data)
    if self.worldData then
        local bossList = data.bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris[601]
            for k2,v2 in pairs(self.worldData.bossList) do
                local mMonsterId = v2.attris[601]
                if monsterId == mMonsterId then
                    self.worldData.bossList[k2] = v1
                end
            end
        end
    end
end

function FubenCache:getWorldData()
    return self.worldData
end
--世界boss剩余挑战时间
function FubenCache:setWorldTime(leftTime)
    if self.worldData then
        self.worldData.leftPlayTime = leftTime
    end
end

function FubenCache:getWorldTime()
     return self.worldData and self.worldData.leftPlayTime or  0
end
--世界boss血条变化广播
function FubenCache:setWorldHp(data)
    if self.worldData then
        self.worldData.curHpPercent = data.curHpPercent
    end
end
--世界boss选择标记
function FubenCache:setWordIndex(index)
    self.worldIndex = index
end

function FubenCache:getWordIndex()
    return self.worldIndex or 0
end

--剑神殿boss选择标记
function FubenCache:setAwakenWarIndex(index)
    self.awakenWarIndex = index
end

function FubenCache:getAwakenWarIndex()
    return self.awakenWarIndex or 0
end

function FubenCache:setWorldHateName(hateRoleName)
    self.hateRoleName = hateRoleName
end

function FubenCache:getWorldHateName()
    return self.hateRoleName
end
--缓存出现的怪物
function FubenCache:setAppearMonsters(monsters)
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isFuben(sId) or mgr.FubenMgr:isBossFuben(sId) or mgr.FubenMgr:isEliteBoss(sId) or mgr.FubenMgr:isWorldBoss(sId)
        or mgr.FubenMgr:isLevel(sId) then
        self.appearMonsters = clone(monsters)
    else
        self.appearMonsters = {}
    end
end

function FubenCache:getAppearMonsters()
    return self.appearMonsters
end
--世界boss坐标
function FubenCache:setWordBossPos(pos)
    self.worldBoss = pos
end

function FubenCache:getWordBossPos()
    return self.worldBoss
end
--记录副本里获得的一些快捷使用道具
function FubenCache:setChangeItems(item)
    table.insert(self.checkItems, item)
end

function FubenCache:getChangeItems()
    return self.checkItems
end

function FubenCache:cleanChangeItems()
    self.checkItems = {}
end

--记录副本里获得的装备
function FubenCache:setChangeEquips(item)
    local isFind = false
    for k,v in pairs(self.checkEquips) do
        if v.mid == item.mid then
            self.checkEquips[k] = item
            isFind = true
        end
    end
    if not isFind then
        table.insert(self.checkEquips, item)
    end
end

function FubenCache:getChangeEquips()
    return self.checkEquips
end

function FubenCache:cleanChangeEquips()
    self.checkEquips = {}
end
--宝箱出现
function FubenCache:setBossChest(ishave)
    self.haveChest = ishave
end

function FubenCache:getBossChest()
    return self.haveChest
end
--緩存战斗场景获得的外观
function FubenCache:setObtainSkins(skins)
    if not self.skins then
        self.skins = {}
    end
    for k,v in pairs(skins) do
        local data = {k,v}
        table.insert(self.skins, data)
    end
end

function FubenCache:cleanObtainSkins()
    self.skins = nil
end

function FubenCache:getObtainSkins()
    return self.skins
end
--登录记录一下可以攻打的副本
function FubenCache:setFubenCanList(fubenCanList)
    local list = {}
    if fubenCanList then
        for k1,v1 in pairs(fubenCanList) do
            local isFind = false
            for k2,v2 in pairs(self.fubenCanList) do
                if v1 == v2 then
                    isFind = true
                end
            end
            if not isFind then
                table.insert(list, v1)
            end
        end
        for k,v in pairs(list) do
            table.insert(self.fubenCanList, v)
        end
    end
    self.fubenCanList = list
end

function FubenCache:cleanFubenCanList()
    self.fubenCanList = {}
end

function FubenCache:getFubenCanList()
    return self.fubenCanList
end
--记录以后都不弹的副本
function FubenCache:setNotTipFubens(sceneId)
    self.notTipFubens[sceneId] = 1
end

function FubenCache:getNotTipFubens()
    return self.notTipFubens
end
--缓存npc
function FubenCache:addGuideNpc(roleId)
    table.insert(self.guideNpcs, roleId)
end

function FubenCache:clearGuideNpcs()
    self.guideNpcs = {}
end

function FubenCache:getGuideNpcs()
    return self.guideNpcs
end

function FubenCache:setTowerChest(chest)
    self.chest = chest
end

function FubenCache:getTowerChest()
    return self.chest
end
--缓存刚刚通关的通天塔关卡
function FubenCache:setTowerFirst(passId)
    table.insert(self.firstTowers, passId)
end

function FubenCache:cleanTowerFirst()
    self.firstTowers = {}
end

function FubenCache:getTowerFirst()
    return self.firstTowers or {}
end

function FubenCache:setChooseBossId(mosterId)
    self.chooseBossId = mosterId
end

function FubenCache:getChooseBossId()
    return self.chooseBossId
end
--仙尊boss场景信息
function FubenCache:setXianzunBossData(data)
    self.xianzunBossData = data
end
--仙尊boss剩余时间
function FubenCache:getXianzunBossTime()
    return self.xianzunBossData and self.xianzunBossData.leftTime or 0
end
--仙尊boss怪物标签
function FubenCache:setXzBossIndex(index)
    self.xzBossIndex = index
end

function FubenCache:getXzBossIndex()
    return self.xzBossIndex or 0
end

--boss之家
function FubenCache:setBossHomeData(data)
    self.bossHomeData = data
end

function FubenCache:getBossHomeData()
    return self.bossHomeData
end

function FubenCache:getBossHomeTime()
    return self.bossHomeData and self.bossHomeData.leftPlayTime or 0
end
--boss之家怪物跳转标签
function FubenCache:setBossHomeIndex(index)
    self.bossHomeIndex = index
end

function FubenCache:getBossHomeIndex()
    return self.bossHomeIndex or 0
end

function FubenCache:updateHomeData(data)
    if self.bossHomeData then
        local bossList = data.bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris[601]
            for k2,v2 in pairs(self.bossHomeData.bossList) do
                local mMonsterId = v2.attris[601]
                if monsterId == mMonsterId then
                    self.bossHomeData.bossList[k2] = v1
                end
            end
        end
    end
end

--秘境修炼
function FubenCache:setMjxlData(data)
    self.mjxlData = data
end

function FubenCache:setMjxlCurBo(curBo)
    if self.mjxlData then
        self.mjxlData.curBo = curBo
    end
end

function FubenCache:setMjxlExp(exp)
    if self.mjxlData then
        self.mjxlData.exp = exp
    end
end

function FubenCache:setMjxlAtkAdd(atkAdd)
    if self.mjxlData then
        self.mjxlData.atkAdd = atkAdd
    end
end

function FubenCache:setMjxlExpDrup(expDrup)
    if self.mjxlData then
        self.mjxlData.expDrup = expDrup
    end
end

function FubenCache:getMjxlData()
    return self.mjxlData
end
-- --缓存买秘境修炼的用时
-- function FubenCache:setMjxlTime(time)
--     self.mjxlTime = time
-- end

-- function FubenCache:getMjxlTime()
--     return self.mjxlTime or 0
-- end

--幻境镇妖
function FubenCache:setHjzyData(data)
    self.hjzyData = data
end

function FubenCache:setHjzyCurBo(curBo)
    if self.hjzyData then
        self.hjzyData.curBo = curBo
    end
end

function FubenCache:setHjzyExp(exp)
    if self.hjzyData then
        self.hjzyData.exp = exp
    end
end

function FubenCache:setHjzyAtkAdd(atkAdd)
    if self.hjzyData then
        self.hjzyData.atkAdd = atkAdd
    end
end

function FubenCache:setHjzyExpDrup(expDrup)
    if self.hjzyData then
        self.hjzyData.expDrup = expDrup
    end
end

function FubenCache:getHjzyData()
    return self.hjzyData
end
--缓存买秘境修炼的用时
function FubenCache:setHjzyTime(time)
    self.hjzyTime = time
end

function FubenCache:getHjzyTime()
    return self.hjzyTime or 0
end
--刷波杀怪数量
function FubenCache:setMjDieNum(dieNum)
    self.dieNum = dieNum
end

function FubenCache:getMjDieNum()
    return self.dieNum or 0
end

--仙域禁地和跨服仙域禁地
function FubenCache:setXianYuJinDiData(data)
    self.XianYuBossData = data
end
function FubenCache:getXianYuJinDiData()
    return self.XianYuBossData
end
function FubenCache:getXianYuBossTime()
    return self.XianYuBossData and self.XianYuBossData.leftPlayTime or 0
end
--仙域禁地怪物跳转标签
function FubenCache:setXianYuBossIndex(index)
    self.XianYuBossIndex = index
end

function FubenCache:getXianYuBossIndex()
    return self.XianYuBossIndex or 0
end

--飞升跳转
function FubenCache:setFSBossIndex(index)
    self.fsBossIndex = index
end

function FubenCache:getFSBossIndex()
    return self.fsBossIndex or 0
end

function FubenCache:updateXianYuBossData(data)
    if self.XianYuBossData then
        local bossList = data.bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris[601]
            for k2,v2 in pairs(self.XianYuBossData.bossList) do
                local mMonsterId = v2.attris[601]
                if monsterId == mMonsterId then
                    self.XianYuBossData.bossList[k2] = v1
                end
            end
        end
         --新增仙域禁地隐藏BOSS数据
         local conf = conf.FubenConf:getKfXyjdHideBoss()
         local data1  = {}
         for k,v in pairs(conf) do
             data1[v.item[1]] = 1
         end
        local data2  = {}
         for k,v in pairs(self.XianYuBossData.bossList) do
            v.index = k
             data2[v.attris[601]] = v
         end
         local view1 = mgr.ViewMgr:get(ViewName.TrackView)
         for k,v in pairs(bossList) do
             if data1[v.attris[601]]  then
                if  not data2[v.attris[601]] then
                    local data = v
                    data.hide = true
                
                    table.insert(self.XianYuBossData.bossList,data)
                    if view1 and view1.bossTrack.ishide then
                        view1.bossTrack.ishide = true
                    end
                else
                    self.XianYuBossData.bossList[data2[v.attris[601]].index].hide = true
                end
                
             end
         end
         -- for k,v in pairs(self.XianYuBossData.bossList) do
         --     data1[v.roleId] = v 
         --     print("data1[v.roleId]",v.roleId)
         -- end
         -- for i,j in ipairs(bossList) do
         --     if not data1[j.roleId] then
         --     print("data1[j.roleId]",j.roleId)
         --        local data = j
         --        data.hide = true
         --        print("插入隐藏BOSS")
         --        table.insert(self.XianYuBossData.bossList,data)
         --     end
         -- end
    end
end
--上古神迹
function FubenCache:setShangGuData(data)
    self.ShangGuBossData = data
end
function FubenCache:getShangGuData()
    return self.ShangGuBossData
end
function FubenCache:getShangGuBossTime()
    return self.ShangGuBossData and self.ShangGuBossData.leftPlayTime or 0
end
--上古神迹怪物跳转标签
function FubenCache:setShangGuBossIndex(index)
    self.ShangGuBossIndex = index
end

function FubenCache:getShangGuBossIndex()
    return self.ShangGuBossIndex or 0
end

function FubenCache:updateShangGuBossData(data)
    if self.ShangGuBossData then
        local bossList = data.bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris[601]
            for k2,v2 in pairs(self.ShangGuBossData.bossList) do
                local mMonsterId = v2.attris[601]
                if monsterId == mMonsterId then
                    self.ShangGuBossData.bossList[k2] = v1
                end
            end
        end
    end
end

--剑神台
function FubenCache:setWuXingData(data)
    self.WuXingBossData = data
end
function FubenCache:getWuXingData()
    return self.WuXingBossData
end
function FubenCache:getWuXingBossTime()
    return self.WuXingBossData and self.WuXingBossData.leftPlayTime or 0
end
--剑神台跳转标签
function FubenCache:setWuXingIndex(index)
    self.wuXingIndex = index
end
function FubenCache:getWuXingIndex()
    return self.wuXingIndex or 0
end
function FubenCache:updateWuXingBossData(data)
    if self.WuXingBossData then
        local bossList = data.bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris[601]
            for k2,v2 in pairs(self.WuXingBossData.bossList) do
                local mMonsterId = v2.attris[601]
                if monsterId == mMonsterId then
                    self.WuXingBossData.bossList[k2] = v1
                end
            end
        end
    end
end

--飞神殿
function FubenCache:setFSData(data)
    self.fsBossData = data
end
function FubenCache:getFSData()
    return self.fsBossData
end
function FubenCache:getFSBossTime()
    return self.fsBossData and self.fsBossData.leftPlayTime or 0
end

function FubenCache:updateFsBossData(data)
    if self.fsBossData then
        local bossList = data.bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris[601]
            for k2,v2 in pairs(self.fsBossData.bossList) do
                local mMonsterId = v2.attris[601]
                if monsterId == mMonsterId then
                    self.fsBossData.bossList[k2] = v1
                end
            end
        end
    end
end

--跨服boss
function FubenCache:setKuafuBossData(data)
    self.kuafuBossData = data
end

function FubenCache:getKuafuBossData()
    return self.kuafuBossData
end

function FubenCache:getKuafuBossTime()
    return self.kuafuBossData and self.kuafuBossData.leftPlayTime or 0
end

--跨服boss怪物跳转标签
function FubenCache:setKuafuBossIndex(index)
    self.kuafuBossIndex = index
end

function FubenCache:getKuafuBossIndex()
    return self.kuafuBossIndex or 0
end

function FubenCache:updateKuafuBoss(data)
    if self.kuafuBossData then
        local bossList = data.bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris[601]
            for k2,v2 in pairs(self.kuafuBossData.bossList) do
                local mMonsterId = v2.attris[601]
                if monsterId == mMonsterId then
                    self.kuafuBossData.bossList[k2] = v1
                end
            end
        end
    end
end
--跨服boss提示
function FubenCache:setKuafuBossNotTip(isNotTip)
    self.kuafuBossNotTip = isNotTip
end

function FubenCache:getKuafuBossNotTip()
    return self.kuafuBossNotTip
end
--跨服boss疲劳
function FubenCache:setKuafuBossTired(tired)
    self.kuafuBossTired = math.max(tired, 0)
end

function FubenCache:getKuafuBossTired()
    return self.kuafuBossTired or 0
end
--缓存仙域灵塔属于哪种进入副本（1.扫荡）
function FubenCache:setXyltReqtype(type)
    self.xyltReqtype = type
end

function FubenCache:getXyltReqtype()
    return self.xyltReqtype or 0
end

--缓存仙域灵塔扫荡的奖励
function FubenCache:setAwardsData(data)
    self.xyltAwardsData = data     
end

function FubenCache:getAwardsData()
    return self.xyltAwardsData    
end
--缓存秘境修炼是否双倍奖励
function FubenCache:setMjxlDouble(data)
    self.mjxlDouble = data 
end
function FubenCache:getMjxlDouble()
    return self.mjxlDouble
end

--神兽岛
function FubenCache:setShenShouData(data)
    self.shenShouData = data
end
function FubenCache:getShenShouData()
    return self.shenShouData 
end
function FubenCache:getShenShouTime()
    return self.shenShouData and self.shenShouData.leftPlayTime or 0
end
function FubenCache:updateShenShowData(data)
    if self.shenShouData then
        local bossList = data.bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris and v1.attris[601]
            for k2,v2 in pairs(self.shenShouData.bossList) do
                local mMonsterId = v2.attris and v2.attris[601]
                if monsterId == mMonsterId then
                    self.shenShouData.bossList[k2] = v1
                end
            end
        end
    end
end
function FubenCache:updateShenShowOtherData(mId)
    if self.shenShouData then
        -- local otherInfo = data.otherInfo 
        -- local lhjpId = conf.FubenConf:getBossValue("ssd_lhjp")--龙魂精魄配置id
        -- local ljswId = conf.FubenConf:getBossValue("ssd_ljsw")--龙景守卫配置id
        -- self.otherInfos = {}
        -- local lhjpInfo = {
        --     mapNum = otherInfo.lhjpMapNum,--龙魂晶魄地图数量
        --     nextRefreshTime = otherInfo.lhjpNextRefTime,--龙魂晶魄下次刷新时间
        --     sceneId = otherInfo.sceneId,
        --     monsterId = lhjpId,
        --     type = 1,
        -- }
        -- local ljswInfo = {
        --     mapNum = otherInfo.ljswMapNum,--龙晶守卫地图数量
        --     nextRefreshTime = otherInfo.ljswNextRefTime,--龙晶守卫下次刷新时间
        --     sceneId = otherInfo.sceneId,
        --     monsterId = ljswId,
        --     type = 1,
        -- }
        -- table.insert(self.otherInfos,lhjpInfo)
        -- table.insert(self.otherInfos,ljswInfo)
        -- for k,v in pairs(self.otherInfos) do
        --     local monsterId = v.monsterId
        --     for k2,v2 in pairs(self.shenShouData.bossList) do
        --         if v.type == v2.type and v2.type == 1 then--type == 1 是特殊的龙晶类型
        --             local mMonsterId = v2.monsterId
        --             if monsterId == mMonsterId then
        --                 self.shenShouData.bossList[k2] = v
        --             end
        --         end
        --     end
        -- end
        for k,v in pairs(self.shenShouData.bossList) do
            if v.monsterId == mId then
                if v.mapNum then
                    v.mapNum = v.mapNum - 1
                    if v.mapNum <= 0 then
                        v.mapNum = 0
                    end
                end
            end
        end
    end
end

--神兽岛跳转
function FubenCache:setShenShouBossIndex(index)
    self.shenShouBossIndex = index
end

function FubenCache:getShenShouBossIndex()
    return self.shenShouBossIndex or 0
end

function FubenCache:setSSdata(data)
    -- body
    self.ssdata = data 
end

function FubenCache:getSSdata()
    -- body
    return self.ssdata
end

function FubenCache:getSSTime( ... )
    -- body
     return self.ssdata and self.ssdata.leftPlayTime or 0
end

function FubenCache:updateSSSYData(data)
    if self.ssdata then
        local bossList = data.bossList
        for k1,v1 in pairs(bossList) do
            local monsterId = v1.attris[601]
            for k2,v2 in pairs(self.ssdata.bossList) do
                local mMonsterId = v2.attris[601]
                if monsterId == mMonsterId then
                    self.ssdata.bossList[k2] = v1
                end
            end
        end
    end
end

function FubenCache:setXycmBossData(data)
    self.xycmBossData = data
end
function FubenCache:getXycmBossData()
    return self.xycmBossData or {}
end
return FubenCache