--
-- Author: 
-- Date: 2017-07-15 11:01:34
--

local BossTrack = class("BossTrack",import("game.base.Ref"))

function BossTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function BossTrack:initPanel()
    self.nameText = self.mParent.nameText
    
end

function BossTrack:setBossTrack()
    self.sId = cache.PlayerCache:getSId()
    self.curId = cache.FubenCache:getCurrPass(self.sId)--当前副本关卡id
    cache.FubenCache:setBossChest(false)
    mgr.HookMgr:setPickState(false)
    if not (mgr.FubenMgr:isWorldBoss(self.sId) or mgr.FubenMgr:isBossHome(self.sId) 
        or mgr.FubenMgr:isXianyuJinDi(self.sId) or mgr.FubenMgr:isKuafuXianyu(self.sId) 
        or mgr.FubenMgr:isKuafuWorld(self.sId) or mgr.FubenMgr:isShangGuShenJi(self.sId)
        or mgr.FubenMgr:isWuXingShenDian(self.sId) or mgr.FubenMgr:isFsFuben(self.sId)
        or mgr.FubenMgr:isShenShou(self.sId) or mgr.FubenMgr:getJudeWarScene(self.sId,SceneKind.shenshoushengyu)
        or  mgr.FubenMgr:isTaiGuXuanJing(self.sId))  then
        local view = mgr.ViewMgr:get(ViewName.BossHpView)
        if not view then
            mgr.ViewMgr:openView2(ViewName.BossHpView, {})
        end
    end
    self:setItemUrl(self.sId)
    self.ishide = false
    self:setBossData()
end

function BossTrack:setItemUrl(sId)
    self.listView.numItems = 0
    local url1 = UIPackage.GetItemURL("track" , "BossTrack1")
    if mgr.FubenMgr:isBossFuben(sId) then --个人boss
        self.fubenObj1 = self.listView:AddItemFromPool(url1)
        self.timeText = self.fubenObj1:GetChild("n2")
        self.firstTime = cache.FubenCache:getFirstTime()
        local url2 = UIPackage.GetItemURL("track" , "TrackItem2")
        local url3 = UIPackage.GetItemURL("track" , "TrackItem3")
        self.fubenObj2 = self.listView:AddItemFromPool(url2)
        self:setPersonalData()
    elseif mgr.FubenMgr:isEliteBoss(sId) or mgr.FubenMgr:isKuaFuBoss(sId) then--精英boss
        self.fubenObj1 = self.listView:AddItemFromPool(url1)
        self.timeText = self.fubenObj1:GetChild("n2")
        local url2 = UIPackage.GetItemURL("track" , "BossTrack2")
        local url3 = UIPackage.GetItemURL("track" , "BossTrack3")
        local url4 = UIPackage.GetItemURL("track" , "BossTrack4")
        self.fubenObj2 = self.listView:AddItemFromPool(url2)
        self.fubenObj3 = self.listView:AddItemFromPool(url3)
        self.listView3 = self.fubenObj3:GetChild("n1")
        self.listView3:SetVirtual()
        self.listView3.itemRenderer = function(index,obj)
            self:cellRankData(index, obj)
        end
        self.isStop = false
        self.fubenObj4 = self.listView:AddItemFromPool(url4)
        self.firstTime = cache.FubenCache:getEliteTime()
        if mgr.FubenMgr:isKuaFuBoss(sId) then
            self.firstTime = cache.KuaFuCache:getEliteTime()
            self:setKuaFuEliteData()
        else
            self:setEliteData()
        end
        
    elseif mgr.FubenMgr:isWorldBoss(sId) 
    or mgr.FubenMgr:isBossHome(sId) 
    or mgr.FubenMgr:isXianyuJinDi(sId) 
    or mgr.FubenMgr:isKuafuXianyu(sId) 
    or mgr.FubenMgr:isKuafuWorld(sId) 
    or mgr.FubenMgr:isShangGuShenJi(sId) 
    or mgr.FubenMgr:isWuXingShenDian(sId) 
    or mgr.FubenMgr:isFsFuben(sId)   
    or mgr.FubenMgr:isShenShou(sId)
    or mgr.FubenMgr:isTaiGuXuanJing(sId)
    or mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) then--世界boss boss之家 跨服boss
        self.firstTime = cache.FubenCache:getWorldTime()--世界boss
        if mgr.FubenMgr:isBossHome(sId) then--boss之家 
            self.firstTime = cache.FubenCache:getBossHomeTime()
        elseif mgr.FubenMgr:isXianyuJinDi(sId) or mgr.FubenMgr:isKuafuXianyu(sId) then
            self.firstTime = cache.FubenCache:getXianYuBossTime()
        elseif mgr.FubenMgr:isKuafuWorld(sId) then--跨服boss
            self.firstTime = cache.FubenCache:getKuafuBossTime()
        elseif mgr.FubenMgr:isShangGuShenJi(sId) then--上古boss
            self.firstTime = cache.FubenCache:getShangGuBossTime()
        elseif mgr.FubenMgr:isWuXingShenDian(sId) then--五行神殿
            self.firstTime = cache.FubenCache:getWuXingBossTime()
        elseif mgr.FubenMgr:isFsFuben(sId) then
            self.firstTime = cache.FubenCache:getFSBossTime()
        elseif mgr.FubenMgr:isShenShou(sId) then
            self.firstTime = cache.FubenCache:getShenShouTime()
        elseif mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) then 
            self.firstTime = cache.FubenCache:getSSTime()
        elseif mgr.FubenMgr:isTaiGuXuanJing(sId) then
            self.firstTime = cache.TaiGuXuanJingCache:getTaiGuTime()    
        end
        -- local url2 = UIPackage.GetItemURL("track" , "BossTrack5")
        local url = UIPackage.GetItemURL("track" , "WorldBossTrack1")
        self.fubenObj2 = self.listView:AddItemFromPool(url)
        -- self.bossHate = self.fubenObj2:GetChild("n12")
        self.worldRankList = self.fubenObj2:GetChild("n0")
        -- self.worldRankList:SetVirtual()
        self.worldRankList.itemRenderer = function(index,obj)
            self:cellWorldRankData(index, obj)
        end
        self.worldRankList.numItems = 0
        self.worldRankList.onClickItem:Add(self.onClickWorldItem,self)
        local sceneData = conf.SceneConf:getSceneById(sId)
        print("boss刷新信息>>>>>>>>>>>>>>",sceneData.name,sId)
        local name = sceneData and sceneData.name or ""
        self:setBossName(name)
    elseif mgr.FubenMgr:isXianzunBoss(sId) then--仙尊boss
        self.firstTime = cache.FubenCache:getXianzunBossTime()
        self.fubenObj1 = self.listView:AddItemFromPool(url1)
        self.timeText = self.fubenObj1:GetChild("n2")
        local url = UIPackage.GetItemURL("track" , "XianzunBossTrack")
        self.fubenObj2 = self.listView:AddItemFromPool(url)
        self.fubenObj2:GetChild("n1").text = language.fuben118
    end
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
    end
end
--boss名字
function BossTrack:setBossName(name)
    self.nameText.text = name
end

function BossTrack:setWorldBossHate(hateRoleName)
    -- if mgr.FubenMgr:isWorldBoss(cache.PlayerCache:getSId()) then
    --     self.bossHate.text = language.fuben98..hateRoleName
    -- end
end

function BossTrack:endBoss()
    self.sId = nil
    mgr.HookMgr:setPickState(false)
    self:releaseTimer()
    local view = mgr.ViewMgr:get(ViewName.BossHpView)
    if view then
        cache.FubenCache:setWorldHateName("")
        view:close()
    end
end

function BossTrack:setBossData()

    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isBossFuben(sId) then --个人boss
        self:setPersonalData()
    elseif mgr.FubenMgr:isEliteBoss(sId) then--精英boss
        self:setEliteData()
    elseif mgr.FubenMgr:isWorldBoss(sId) then--世界boss
        self:setWorldData()
    elseif mgr.FubenMgr:isKuaFuBoss(sId) then --跨服精英boss
        self:setKuaFuEliteData()
    elseif mgr.FubenMgr:isXianzunBoss(sId) then--仙尊boss
    elseif mgr.FubenMgr:isBossHome(sId) then--boss之家 借用世界boss的结构
        self:setWorldData()
    elseif mgr.FubenMgr:isXianyuJinDi(sId) or mgr.FubenMgr:isKuafuXianyu(sId) then--仙域禁地
        self:setWorldData()
    elseif mgr.FubenMgr:isKuafuWorld(sId) then--跨服世界boss
        self:setWorldData()
    elseif mgr.FubenMgr:isShangGuShenJi(sId) then--上古神迹boss
        self:setWorldData()
    elseif mgr.FubenMgr:isWuXingShenDian(sId) then--五行神殿boss
        self:setWorldData()
    elseif  mgr.FubenMgr:isFsFuben(sId) then --飞升
        self:setWorldData()
    elseif  mgr.FubenMgr:isShenShou(sId) then --神兽岛
        self:setWorldData()
    elseif  mgr.FubenMgr:isTaiGuXuanJing(sId) then --太古
        self:setWorldData()   
    elseif mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) then
        self:setWorldData()
                 
    end
end
--个人boss通关条件
function BossTrack:setPersonalData()
    if self.curId and self.curId > 0 then
        local data = conf.FubenConf:getPassDatabyId(self.curId)
        local monsters = data and data.pass_con
        for i=1,3 do
            local monsterText = self.fubenObj2:GetChild("n"..i)
            local monster = monsters and monsters[i]
            if monster then
                monsterText.visible = true
                local id = monster[1]
                local name = conf.MonsterConf:getInfoById(id).name
                self:setBossName(name)
                local monsterNum = cache.FubenCache:getExpMonsters(id)
                monsterText.text = i.."."..language.fuben09..mgr.TextMgr:getTextColorStr(name, 10).."（"..monsterNum.."/"..monster[2].."）"
            else
                monsterText.visible = false
            end
        end
    end
end
--个人boss通关奖励
function BossTrack:setAwardsData()
    local itemlist = self.fubenObj3:GetChild("n6")
    local awardsData = conf.FubenConf:getPassDatabyId(self.curId)--返回有首通的关卡数据
    local awards = awardsData and awardsData.normal_drop
    if awards then
        itemlist.itemRenderer = function(index,obj)
            local data = awards[index + 1]
            local itemData = {mid = data[1],amount = data[2],bind = data[3]}
            GSetItemData(obj, itemData, true)
        end
        itemlist.numItems = #awards
    end
    self.fubenObj3:GetChild("n5").visible = false
    self.fubenObj3:GetChild("n3").text = language.fuben35
end

function BossTrack:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function BossTrack:onTimer()
    --怒气值满后倒计时
    local rateTime = self.mParent:getXianYuBossQuitTime()
    if rateTime > 0 then
        self.mParent:setTimeTxt(rateTime)
        self.mParent:setXianYuBossQuitTime(rateTime - 1)
    end
    local severTime = mgr.NetMgr:getServerTime()
    local data = conf.SceneConf:getSceneById(self.sId) 
    local overTime = data.over_time or 0
    if mgr.FubenMgr:isEliteBoss(self.sId) or mgr.FubenMgr:isWorldBoss(self.sId) or 
    mgr.FubenMgr:isKuaFuBoss(self.sId) or mgr.FubenMgr:isXianzunBoss(self.sId) or 
    mgr.FubenMgr:isBossHome(self.sId) or mgr.FubenMgr:isXianyuJinDi(self.sId) or 
    mgr.FubenMgr:isKuafuWorld(self.sId) or mgr.FubenMgr:isKuafuXianyu(self.sId) or
    mgr.FubenMgr:isShangGuShenJi(self.sId) or mgr.FubenMgr:isWuXingShenDian(self.sId)
    or mgr.FubenMgr:isFsFuben(self.sId) or mgr.FubenMgr:isShenShou(self.sId)
    or  mgr.FubenMgr:isTaiGuXuanJing(self.sId) 
    or mgr.FubenMgr:getJudeWarScene(self.sId,SceneKind.shenshoushengyu)  then
        self.firstTime = self.firstTime - 1
        self.time = self.firstTime
    else
        self.time = overTime / 1000 + self.firstTime - severTime
    end
    if mgr.FubenMgr:isEliteBoss(self.sId) or  mgr.FubenMgr:isKuaFuBoss(self.sId) then
        local allMonster = mgr.ThingMgr:objsByType(ThingType.monster)--所有的怪物
        local isFind = false
        for k,v in pairs(allMonster) do
            if v then isFind = true end
        end
        if not isFind and gRole and not self.isStop then
            gRole:stopAI()
            self.isStop = true
        end
    end
    -- if mgr.FubenMgr:isWorldBoss(self.sId) then
    --     self:pickUpBossAwards()
    -- end
    if self.time <= 0 then
        if not mgr.FubenMgr:isWorldBoss(self.sId) then
            self:releaseTimer()
        end
        return
    end
    if mgr.FubenMgr:isWorldBoss(self.sId) or 
        mgr.FubenMgr:isBossHome(self.sId) or 
        mgr.FubenMgr:isXianyuJinDi(self.sId) or
        mgr.FubenMgr:isKuafuXianyu(self.sId) or 
        mgr.FubenMgr:isKuafuWorld(self.sId) or 
        mgr.FubenMgr:isShangGuShenJi(self.sId) or 
        mgr.FubenMgr:isWuXingShenDian(self.sId) or
        mgr.FubenMgr:isFsFuben(self.sId)  or
        mgr.FubenMgr:isShenShou(self.sId)  or
        mgr.FubenMgr:isTaiGuXuanJing(self.sId)  or
        mgr.FubenMgr:getJudeWarScene(self.sId,SceneKind.shenshoushengyu) then

        self:updateBossHp()
    else
        self.timeText.text = language.fuben20.." "..mgr.TextMgr:getTextColorStr(GTotimeString(self.time), 10)
    end
end
--精英boss
function BossTrack:setEliteData()
    if self.sId then
        local sceneData = conf.SceneConf:getSceneById(self.sId)
        local bossData = sceneData and sceneData.order_monsters
        local name = conf.MonsterConf:getInfoById(bossData[1][2]).name
        self:setBossName(name)
        local eliteData = cache.FubenCache:getEliteData()
        if eliteData then
            local hpPercent = eliteData.curHpPercent or 0
            local myHurtMul = eliteData.myHurtMul
            self.rankList = eliteData.rankList
            local max = 100
            if self.fubenObj2 then
                self.fubenObj2.value = hpPercent / max--血量
                self.fubenObj2.max = max
            end
            if self.listView3 then
                self.listView3.numItems = #self.rankList
            end
            if self.fubenObj4 then
                self.fubenObj4:GetChild("n1").text = language.fuben56..(myHurtMul / max).."%"
            end
        end
    end
end
--跨服精英boss
function BossTrack:setKuaFuEliteData()
    if self.sId then
        local sceneData = conf.SceneConf:getSceneById(self.sId)
        local bossData = sceneData and sceneData.order_monsters
        local name = conf.MonsterConf:getInfoById(bossData[1][2]).name
        self:setBossName(name)
        local eliteData = cache.KuaFuCache:getEliteData()
        if eliteData then
            local hpPercent = eliteData.curHpPercent or 0
            local myHurtMul = eliteData.myHurtMul
            self.rankList = eliteData.rankList
            local max = 100
            if self.fubenObj2 then
                self.fubenObj2.value = hpPercent / max--血量
                self.fubenObj2.max = max
            end
            if self.listView3 then
                self.listView3.numItems = #self.rankList
            end
            if self.fubenObj4 then
                self.fubenObj4:GetChild("n1").text = language.fuben56..(myHurtMul / max).."%"
            end
        end
    end
end
--boss排名数据
function BossTrack:cellRankData(index,cell)
    local data = self.rankList[index + 1]
    local roleId = data.roleId
    cell:GetChild("n1").text = data.rank
    cell:GetChild("n2").text = data.roleName
    cell:GetChild("n3").text = string.format("%.1f", (data.hurtPercent / 100)).."%"
end

--世界boss排名数据
function BossTrack:cellWorldRankData(index,cell)
    local data = self.data1[index+ 1]
    -- if self.ishide then
    -- else
    --     data = self.rankWorldList[index + 1]
    -- end
    cell.data = data
    local monsterId = data.attris and data.attris[601]
    local time = data.nextRefreshTime  - mgr.NetMgr:getServerTime()
    -- print("time<>>>>>>>>>>>>",time,data.nextRefreshTime,mgr.NetMgr:getServerTime())
    local timeStr = mgr.TextMgr:getTextColorStr(language.gonggong39, 4)
    if time > 0 then
        timeStr = mgr.TextMgr:getTextColorStr(GTotimeString(time),14) --倒计时
    else
        if mgr.FubenMgr:getJudeWarScene( cache.PlayerCache:getSId(),SceneKind.shenshoushengyu)  then
            if tonumber(data.curHpPercent) <= 0 then
                timeStr = mgr.TextMgr:getTextColorStr(language.gonggong133, 14) -- 死亡
            end
        end
    end

    

    cell:GetChild("n2").text = timeStr
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isShenShou(sId) then --神兽岛
        if data.type == 1 then
            monsterId = data.monsterId
        end
        local mConf = conf.MonsterConf:getInfoById(monsterId)
        local name = ""
        local lv = 1
        if not mConf then
            name = conf.NpcConf:getNpcById(monsterId).name or ""
        else
            name = mConf and mConf.name or ""
            lv = mConf and mConf.level or 1
        end
        cell:GetChild("n0").text = name
        if data.type == 1 then--龙晶
            cell:GetChild("n1").text = data.mapNum
        else
            cell:GetChild("n1").text = "Lv"..lv
        end
    else
        local mConf = conf.MonsterConf:getInfoById(monsterId)
        local name = mConf and mConf.name or ""
        cell:GetChild("n0").text = name
        local lv = mConf and mConf.level or 1
        cell:GetChild("n1").text = "Lv"..lv
    end
end

function BossTrack:onClickWorldItem(context)
    local data = context.data.data
    if data then
        -- plog("下次刷新时间",data.nextRefreshTime,"服务器时间",mgr.NetMgr:getServerTime(),"计算后",data.nextRefreshTime - mgr.NetMgr:getServerTime())
        -- printt("寻找boss",data)
        if gRole then
            gRole:stopAI()
            mgr.HookMgr:cancelHook()
        end
        --若在采集，点击boss寻路关闭采集信息
        local view = mgr.ViewMgr:get(ViewName.PickAwardsView)
        if view then
            CClearPickView()
            GCancelPick()
        end        
        if not data.attris then--神兽岛的龙晶没有属性
            GComAlter(language.fuben232)
            return
        else
            local mosterId = data.attris[601]
            local mConf = conf.MonsterConf:getInfoById(mosterId)
            local p = mConf and mConf.pos or {1,1}
            local pos = {x = p[1],y = p[2]}
            local sId = cache.PlayerCache:getSId()
            if mgr.FubenMgr:isTaiGuXuanJing(sId) then
                cache.TaiGuXuanJingCache:setChooseBossId(mosterId)
            else
                cache.FubenCache:setChooseBossId(mosterId)
            end
            mgr.HookMgr:enterHook({point = pos})
        end
    else
        GComAlter(language.gangwar18)
    end
end
--世界boss(原来的逻辑)
function BossTrack:setWorldData()
    local sId = cache.PlayerCache:getSId()
    local data = cache.FubenCache:getWorldData()
    if mgr.FubenMgr:isBossHome(sId) then
        data = cache.FubenCache:getBossHomeData()
    elseif mgr.FubenMgr:isXianyuJinDi(sId) or mgr.FubenMgr:isKuafuXianyu(sId) then
        data = cache.FubenCache:getXianYuJinDiData()
    elseif mgr.FubenMgr:isKuafuWorld(sId) then
        data = cache.FubenCache:getKuafuBossData()
    elseif mgr.FubenMgr:isShangGuShenJi(sId) then
        data = cache.FubenCache:getShangGuData()
    elseif mgr.FubenMgr:isWuXingShenDian(sId) then
        data = cache.FubenCache:getWuXingData()
    elseif mgr.FubenMgr:isFsFuben(sId) then 
        data = cache.FubenCache:getFSData()
    elseif mgr.FubenMgr:isShenShou(sId) then 
        data = cache.FubenCache:getShenShouData()
    elseif mgr.FubenMgr:isTaiGuXuanJing(sId) then 
        data = cache.TaiGuXuanJingCache:getTaiGuData()
    elseif mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) then
        data = cache.FubenCache:getSSdata()

        --检测是否有青龙白虎朱雀的boss，没有就加一个假的进去
        local sConf = conf.FubenConf:getSSJTref(sId)
        local flag = false
        for k,v in pairs(data.bossList) do
            if sConf.big_boss_ref[1][1] == v.attris[601] then
                --存在
                flag = true
                break
            end
        end
        if not flag then
            --模拟一条
            local temp = os.date("*t",mgr.NetMgr:getServerTime())
            local ssjt_join_max_sec = conf.FubenConf:getBossValue("ssjt_join_max_sec")
            local temp1 = GGetTimeData(ssjt_join_max_sec)
            temp.hour = temp1.hour
            temp.min = temp1.min
            temp.sec = temp1.sec

            local t = {}
            t.roleId = 0
            t.nextRefreshTime = os.time(temp)
            t.hateRoleName = ""
            t.pox = sConf.big_boss_ref[1][3]
            t.poy = sConf.big_boss_ref[1][4]
            t.attris = {}
            t.attris[601] = sConf.big_boss_ref[1][1]
            t.sceneId = sId
            t.curHpPercent = 0

            table.insert(data.bossList,1,t)
        end
    end
    self.rankWorldList = data and data.bossList or {}

    --导航不出现隐藏BOSS
    self.data1 = {}
    for k,v in pairs(self.rankWorldList) do
        if not v.hide then
            table.insert(self.data1, v)
        end
    end

    -- printt("self.rankWorldList",self.rankWorldList)
     if mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) then
        table.sort(self.rankWorldList,function(a,b)
            local aMonsterId = a.attris and a.attris[601]
            local bMonsterId = b.attris and b.attris[601]
            local aConf = conf.MonsterConf:getInfoById(aMonsterId)
            local bConf = conf.MonsterConf:getInfoById(bMonsterId)
            local alvl = aConf and aConf.level or 0
            local blvl = bConf and bConf.level or 0
            alvl = alvl > 0 and alvl or 999 
            blvl = blvl > 0 and blvl or 999 

            local asort = aConf.sortboss or 999
            local bsort = bConf.sortboss or 999
            if asort == bsort then
                if alvl == blvl then
                    return aMonsterId < bMonsterId
                else
                    return alvl > blvl
                end
            else
                return asort<bsort
            end  
        end)
        

    else
        
        table.sort(self.rankWorldList,function(a,b)
            local aMonsterId = a.attris and a.attris[601]
            local bMonsterId = b.attris and b.attris[601]
            local aConf = conf.MonsterConf:getInfoById(aMonsterId)
            local bConf = conf.MonsterConf:getInfoById(bMonsterId)
            local alvl = aConf and aConf.level or 0
            local blvl = bConf and bConf.level or 0
            return alvl < blvl
        end)
    end
    --仙域禁地处理排序
    if mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) then
        table.sort(self.data1,function(a,b)
            local aMonsterId = a.attris and a.attris[601]
            local bMonsterId = b.attris and b.attris[601]
            local aConf = conf.MonsterConf:getInfoById(aMonsterId)
            local bConf = conf.MonsterConf:getInfoById(bMonsterId)
            local alvl = aConf and aConf.level or 0
            local blvl = bConf and bConf.level or 0
            alvl = alvl > 0 and alvl or 999 
            blvl = blvl > 0 and blvl or 999 

            local asort = aConf.sortboss or 999
            local bsort = bConf.sortboss or 999
            if asort == bsort then
                if alvl == blvl then
                    return aMonsterId < bMonsterId
                else
                    return alvl > blvl
                end
            else
                return asort<bsort
            end  
        end)


    else
        
        table.sort(self.data1,function(a,b)
            local aMonsterId = a.attris and a.attris[601]
            local bMonsterId = b.attris and b.attris[601]
            local aConf = conf.MonsterConf:getInfoById(aMonsterId)
            local bConf = conf.MonsterConf:getInfoById(bMonsterId)
            local alvl = aConf and aConf.level or 0
            local blvl = bConf and bConf.level or 0
            return alvl < blvl
        end)
    end


    -- print("世界BOSS數據~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    -- for k,v in pairs(self.rankWorldList) do
    --     printt(k,v)
    -- end

   
    if self.worldRankList then
        self.worldRankList.numItems = #self.data1
    end
end



--世界boss和boss之家
function BossTrack:updateBossHp()
    -- self.data1 self.rankWorldList
    if not  self.rankWorldList then return end
    local bossList = self.rankWorldList
    local disList = {}
    if not mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) then
        for k,v in pairs(bossList) do
            if v.pox and v.poy and v.pox > 0 and v.poy > 0 then
                local pos = Vector3.New(v.pox,gRolePoz,v.poy)
                local distance = GMath.distance(gRole:getPosition(), pos)
                local data = {data = v,distance = distance}
                table.insert(disList, data)
            end
        end
        local bossData = nil
        if #disList > 0 then
            local distance = disList[1].distance
            for k,v in pairs(disList) do
                if v.distance <= distance then 
                    distance = v.distance
                    bossData = v.data 
                end
            end
        end
        local isFind = false
        if bossData then--离我最近的boss
        
            local boss = mgr.ThingMgr:getObj(ThingType.monster, bossData.roleId)
            if boss then
                local distance = GMath.distance(gRole:getPosition(), boss:getPosition())
                if distance <= 1000 then
                    
                    -- printt( "self.rankWorldList",self.rankWorldList)
                    -- print("zhaodaoboSSS~~~~~~~~~~")
                    local view = mgr.ViewMgr:get(ViewName.BossHpView)
                    if view then
                        view:setBossRoleId(bossData.roleId)
                        view:setData(boss.data)
                        view:setHateRoleName(bossData.hateRoleName)
                        view:setAttisData(bossData.attris)
                    else

                        mgr.ViewMgr:openView(ViewName.BossHpView, function(view)
                            view:setBossRoleId(bossData.roleId)
                            view:setHateRoleName(bossData.hateRoleName)
                            view:setAttisData(bossData.attris)
                        end,boss.data)
                    end
                    isFind = true
                end
            end
        end
    end
    -- if not isFind then
    --     GCloseBossHpView()
    -- end
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isShenShou(sId) then
        self:updateShenShouTime()
    elseif mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) then
        self:updateSSSYTime()
    else
        self:updateBossTime()
    end
end

function BossTrack:updateBossTime()

    for k = 1,self.worldRankList.numItems do
        local cell = self.worldRankList:GetChildAt(k - 1)
        if cell then
            -- local data = self.rankWorldList[k]
            local data = self.data1[k]
            local timeText = cell:GetChild("n2")--刷新时间
            local time = data.nextRefreshTime  - mgr.NetMgr:getServerTime()
            if time > 0 then
                timeText.text = GTotimeString(time)
            else
                timeText.text = mgr.TextMgr:getTextColorStr(language.gonggong39, 4)
            end
        end
    end
end
--神兽岛更新时间
function BossTrack:updateShenShouTime()
    for k = 1,self.worldRankList.numItems do
        local cell = self.worldRankList:GetChildAt(k - 1)
        if cell then
            local data = self.rankWorldList[k]
            local timeText = cell:GetChild("n2")--刷新时间
            local time = data.nextRefreshTime - mgr.NetMgr:getServerTime()
            if time > 0 then
                timeText.text = GTotimeString(time)
            else
                timeText.text = mgr.TextMgr:getTextColorStr(language.gonggong39, 4)
                if data.type == 1 then
                    proxy.FubenProxy:send(1331203)--请求神兽岛场景信息
                end
            end
        end
    end
end

function BossTrack:updateSSSYTime()
    -- body
     for k = 1,self.worldRankList.numItems do
        local cell = self.worldRankList:GetChildAt(k - 1)
        if cell then
            local data = self.rankWorldList[k]
            local timeText = cell:GetChild("n2")--刷新时间
            --local monster =
            local mConf =  conf.MonsterConf:getInfoById( data.attris[601])

            local time = data.nextRefreshTime - mgr.NetMgr:getServerTime()
            
            if mConf.kind == 11 or mConf.kind == 12 then
                --print(data.attris[601],mConf.kind,"mConf.kind",data.nextRefreshTime ,time,data.curHpPercent)
                if time > 0 then
                    timeText.text = GTotimeString(time)
                else
                    if tonumber(data.curHpPercent) <= 0 then
                        timeText.text = mgr.TextMgr:getTextColorStr(language.gonggong133, 14)
                    else
                        timeText.text = mgr.TextMgr:getTextColorStr(language.gonggong39, 4)
                    end
                end
            else
                if time > 0 then
                    timeText.text = GTotimeString(time)
                else
                    timeText.text = mgr.TextMgr:getTextColorStr(language.gonggong39, 4)
                end
            end
        end
    end


    
end

--拾取世界boss宝箱
-- function BossTrack:pickUpBossAwards()
--     local isFindBoss = false
--     if not mgr.HookMgr:getPickState() then--还没有开启拾取状态
--         local allMonster = mgr.ThingMgr:objsByType(ThingType.monster)--所有的怪物
--         for k,v in pairs(allMonster) do
--             local kind = v.data.kind
--             if kind ~= MonsterKind.chest then
--                 isFindBoss = true--找到了boss说明还没有掉落宝箱
--                 -- cache.FubenCache:setWordBossPos(v:getPosition())
--                 break
--             end
--         end
--     end
--     if not isFindBoss and (mgr.HookMgr.isHook or mgr.ViewMgr:get(ViewName.AutoFindView)) then
--         mgr.HookMgr:setPickState(true)--开启拾取状态
--     end
--     --检查是否有遥感操作
--     if UJoystick.IsJoystick then
--         CClearPickView()
--         mgr.HookMgr:stopHook()--停止挂机
--         return
--     end
--     local view = mgr.ViewMgr:get(ViewName.PickAwardsView)
--     if mgr.HookMgr:getPickState() and not view and cache.FubenCache:getBossChest() then
--         local allMonster = mgr.ThingMgr:objsByType(ThingType.monster)--所有的怪物
--         local awards = nil
--         local minDistance = 0
--         local num = 0
--         for k,v in pairs(allMonster) do
--             local kind = v.data.kind
--             if kind == MonsterKind.chest then
--                 num = num + 1
--                 local distance = GMath.distance(gRole:getPosition(), v:getPosition())
--                 if minDistance > 0 then
--                     if distance <= minDistance then
--                         awards = v  
--                         minDistance = distance
--                     end
--                 else
--                     minDistance = distance
--                     awards = v
--                 end
--             end
--         end
--         if awards then
--             local p = Vector3.New(awards.data.pox, gRolePoz, awards.data.poy)
--             gRole:moveToPoint(p, PickDistance, function()
--                 gRole:collect(function(state)
--                 end)
--                 if not mgr.ViewMgr:get(ViewName.PickAwardsView) then
--                     local data = {monsterData = awards.data,func = function( ... )
--                         proxy.FubenProxy:send(1810301,{tarPox = awards.data.pox,tarPoy = awards.data.poy})--拾取
--                         gRole:idleBehaviour()
--                     end}
--                     mgr.ViewMgr:openView2(ViewName.PickAwardsView, data)
--                 end
--             end)
--         else
--             cache.FubenCache:setBossChest(false)
--             mgr.HookMgr:setPickState(false)
--             if gRole then
--                 gRole:stopAI()
--             end
--         end
--     end
-- end

return BossTrack