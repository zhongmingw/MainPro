--
-- Author: Your Name
-- Date: 2018-04-25 16:08:12
--

local CityWarTrack = class("CityWarTrack",import("game.base.Ref"))

function CityWarTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function CityWarTrack:initPanel()
    self.nameTxt = self.mParent.nameText
end

function CityWarTrack:setCityWarTrack()
    self.nameTxt.text = language.citywar12
    self:setItemUrl()
end

function CityWarTrack:setItemUrl()
    self.listView.numItems = 0
    self.cityData = cache.CityWarCache:getCityData()

    local attackBtn = self.mParent.view:GetChild("n28")
    attackBtn.onClick:Add(self.onClickAttack,self)
    local defendBtn = self.mParent.view:GetChild("n29")
    defendBtn.onClick:Add(self.onClickDefend,self)
    local gangId = cache.PlayerCache:getGangId()
    local warSid = cache.PlayerCache:getSId()
    local sId = nil
    for k,v in pairs(self.cityData) do
        if v.gangId == gangId then
            sId = v.sceneId
            break
        end
    end
    if sId then
        if sId ~= warSid then
            defendBtn.visible = true
            attackBtn.visible = false
        elseif sId ~= language.citywar01[3] then
            defendBtn.visible = false
            attackBtn.visible = true
        else
            defendBtn.visible = false
            attackBtn.visible = false
        end
    else
        attackBtn.visible = false
        defendBtn.visible = false
    end

    local url = UIPackage.GetItemURL("track" , "CityWarItem1")
    local url2 = UIPackage.GetItemURL("track" , "CityWarItem2")
    local url3 = UIPackage.GetItemURL("track" , "CityWarItem3")
    self.endTime = cache.PlayerCache:getRedPointById(attConst.A20168)
    local cell = self.listView:AddItemFromPool(url3)
    local netTime = mgr.NetMgr:getServerTime()
    self.timeTxt = cell:GetChild("n0")
    self.timeTxt.text = language.citywar19 .. GTotimeString3(self.endTime - netTime)

    local cityDoorState = cache.CityWarCache:getCityDoorState()
    local bossData = cache.CityWarCache:getCityBossData()
    local doorData = cache.CityWarCache:getCityDoorData()

    table.sort(bossData,function(a,b)
        return a.attris[601] < b.attris[601]
    end)
    -- printt("boss信息",doorData)
    table.sort(doorData,function(a,b)
        return a.attris[601] < b.attris[601]
    end)
    if cityDoorState == 1 then
        for k,v in pairs(bossData) do
            local obj = self.listView:AddItemFromPool(url2)
            obj.data = v
            obj.onClick:Add(self.onClickGoTask,self)
            local decTxt = obj:GetChild("n0")
            -- decTxt.underline = true
            local confData = conf.MonsterConf:getInfoById(v.attris[601])
            if v.hateRoleName and v.hateRoleName ~= "" then
                local textData = {
                                    {text = confData.name ,color = 5},
                                    {text = "  "..language.huangling14 .. "：",color = 5},
                                    {text = v.hateRoleName,color = 4},
                                }
                decTxt.text = mgr.TextMgr:getTextByTable(textData)
            else
                local textData = {
                                    {text = confData.name .. " " .. language.citywar17,color = 5},
                                    {text =  v.curHpPercent/100 .. "%",color = 4},
                                }
                decTxt.text = mgr.TextMgr:getTextByTable(textData)
            end
        end
        local obj = self.listView:AddItemFromPool(url3)
        local decTxt = obj:GetChild("n0")
        decTxt.text = language.citywar18
    else
        for k,v in pairs(doorData) do
            local obj = self.listView:AddItemFromPool(url)
            obj.data = v
            obj.onClick:Add(self.onClickGoTask,self)
            local hpBar = obj:GetChild("n1")
            local nameImg = obj:GetChild("n2")
            local hpTxt = obj:GetChild("n3")
            nameImg.url = UIPackage.GetItemURL("track" , UIItemRes.cityWarDoors[v.attris[601]])
            hpBar.value = v.curHpPercent/100
            hpTxt.text = v.curHpPercent/100 .. "%"
        end
    end
    -- print("self.timer>>>>>>>>>>>",self.timer)
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil 
    end
    self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
end

function CityWarTrack:releaseTimer()
    print("CityWarTrack:releaseTimer>>>>>>>>>>",debug.traceback())
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil 
    end
    self.timeTxt.text = language.citywar20 .. GTotimeString3(0)
end

function CityWarTrack:onClickGoTask(context)
    local data = context.sender.data
    local pos = Vector3.New(data.pox, gRolePoz, data.poy)
    local monsterConf = conf.MonsterConf:getInfoById(data.attris[601])
    local gridValue = UnityMap:GetGridValue(gRole:getPosition())
    mgr.HookMgr:cancelHook()
    local sId = cache.PlayerCache:getSId()
    local sConf = conf.SceneConf:getSceneById(sId)
    print("挂机寻路",gridValue,monsterConf.kind)
    if gridValue == 8 and monsterConf.kind == 8 then--城外到城内找怪物先走传送点
        print("城外到城内")
        local dt = 9999
        local point = nil
        for k,v in pairs(sConf.transfer) do
            local monsterData = cache.CityWarCache:getCityWarTrackData()
            local transferData = conf.CityWarConf:getTransferData(v)
            local mData = {}
            for _,monster in pairs(monsterData) do
                mData[monster.attris[601]] = true
            end
            if not mData[transferData.monsterId] then--找到最近的已破城门传送点
                local confData = conf.NpcConf:getNpcById(v)
                if confData and confData.type == 10 then
                    local transferPos = Vector3.New(confData.pos[1], gRolePoz, confData.pos[2])
                    local distance = GMath.distance(gRole:getPosition(), transferPos)
                    if distance <= dt then
                        dt = distance
                        point = transferPos
                    end
                end
            end
        end
        if point then
            printt("已破城门点",point)
            cache.CityWarCache:setCityWarTaskCache(data)
            gRole:moveToPoint(point, 70, function()
                -- gRole:moveToPoint(pos, 50, function()
                --     mgr.HookMgr:enterHook()
                -- end)
            end)
        end
    elseif (gridValue == 5 or gridValue == 7) and monsterConf.kind == 9 then
        local dt = 9999
        local point = nil
        for k,v in pairs(sConf.transfer) do
            local npcData = conf.NpcConf:getNpcById(v)
            if npcData.type == 2 then
                pos = Vector3.New(npcData.pos[1], gRolePoz, npcData.pos[2])
                local distance = GMath.distance(gRole:getPosition(), pos)
                if distance <= dt then
                    dt = distance
                    point = pos
                end 
            end
        end
        if monsterConf.kind == 9 and monsterConf.id == 3077602 then--右城门特殊处理
            data.pox = 5475
            data.poy = 2248
        end
        if point then
            cache.CityWarCache:setCityWarTaskCache(data)
            gRole:moveToPoint(point, 50, function()

            end)
        end
    else
        if monsterConf.kind == 9 and monsterConf.id == 3077602 then--右城门特殊处理(地图问题)
            pos = Vector3.New(5475, gRolePoz, 2248)
        end
        gRole:moveToPoint(pos, 70, function()
            mgr.HookMgr:enterHook()
        end)
    end
end

--己方是否有城池
function CityWarTrack:hasCitySid()
    local gangId = cache.PlayerCache:getGangId()
    local sId = nil
    for k,v in pairs(self.cityData) do
        if v.gangId == gangId then
            sId = v.sceneId
            break
        end
    end
    return sId
end

function CityWarTrack:onClickAttack()
    local warSid = cache.CityWarCache:getWarSceneId()
    print("前往进攻")
    local sId = cache.PlayerCache:getSId()
    if self:hasCitySid() then
        if sId == language.citywar01[3] then
            GComAlter(language.citywar13)
        else
            proxy.ThingProxy:send(1020101,{sceneId = language.citywar01[3],type = 3})
        end
    else
        if sId == warSid then
            GComAlter(language.citywar13)
        else
            proxy.ThingProxy:send(1020101,{sceneId = warSid,type = 3})
        end
    end
end

function CityWarTrack:onClickDefend()
    local gangId = cache.PlayerCache:getGangId()
    local sId = self:hasCitySid()
    local sceneId = cache.PlayerCache:getSId()
    if sId then
        if sId == sceneId then
            GComAlter(language.citywar13)
        else
            proxy.ThingProxy:send(1020101,{sceneId = sId,type = 3})
        end
    end
end

function CityWarTrack:onTimer()
    self:updateBossHp()
    --612
    if self.timeTxt then
        local netTime = mgr.NetMgr:getServerTime()
        self.endTime = cache.PlayerCache:getRedPointById(attConst.A20168)
        if self:isDefendTime() then
            self.startTime = self:getDefenTime()
            local time = 300-(netTime - self.startTime)
            -- print("倒计时",time,self.startTime,self.endTime,netTime)
            --:倒计时    299    1525791364    1525791355    1525791365
            if time > 0 then
                if time > self.endTime - netTime then
                    time = self.endTime - netTime
                end
                self.timeTxt.text = language.citywar20 .. GTotimeString3(time)
            else
                self.timeTxt.text = language.citywar20 .. GTotimeString3(0)
            end
        else
            -- print("倒计时",time,self.startTime,self.endTime,netTime)
            --:倒计时    nil    nil    1525711672    1525711231
            if self.endTime > 0 then
                self.timeTxt.text = language.citywar19 .. GTotimeString3(self.endTime - netTime)
            else
                self.timeTxt.text = language.citywar19 .. GTotimeString3(0)
            end
        end
    end
end

function CityWarTrack:isDefendTime()
    local bossData = cache.CityWarCache:getCityBossData()
    local cityData = cache.CityWarCache:getCityData()
    local sceneId = cache.PlayerCache:getSId()
    local gangId = 0
    for k,v in pairs(cityData) do--当前城池的占领仙盟id
        if v.sceneId == sceneId then
            gangId = v.gangId
            break
        end
    end
    local gangIdData = {}
    for k,v in pairs(bossData) do
        table.insert(gangIdData,v.gangId)
    end
    local flag = false
    if gangIdData[1] and gangIdData[2] and gangIdData[3] then
        if gangIdData[1] == gangIdData[2] and gangIdData[2] == gangIdData[3] then
            if gangId ~= gangIdData[1] then
                flag = true
            end
        end
    end
    return flag    
end

function CityWarTrack:getDefenTime()
    local bossData = cache.CityWarCache:getCityBossData()
    local timeData = {}
    for k,v in pairs(bossData) do
        table.insert(timeData,v.attris[612])
    end
    table.sort(timeData,function(a,b)
        return a > b
    end)
    return timeData[1]
end

function CityWarTrack:updateBossHp()
    local monsterData = cache.CityWarCache:getCityWarTrackData()
    if not monsterData then return end
    local bossList = monsterData
    local disList = {}
    for k,v in pairs(bossList) do
        if v.pox > 0 and v.poy > 0 then
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
    if bossData then--离我最近的boss
        local boss = mgr.ThingMgr:getObj(ThingType.monster, bossData.roleId)
        if boss then
            local distance = GMath.distance(gRole:getPosition(), boss:getPosition())
            if distance <= 1000 then
                local view = mgr.ViewMgr:get(ViewName.BossHpView)
                if view then
                    view:setBossRoleId(bossData.roleId)
                    view:setData(boss.data)
                    -- view:setHateRoleName(bossData.hateRoleName)
                    view:setAttisData(bossData.attris)
                else
                    mgr.ViewMgr:openView(ViewName.BossHpView, function(view)
                        view:setBossRoleId(bossData.roleId)
                        -- view:setHateRoleName(bossData.hateRoleName)
                        view:setAttisData(bossData.attris)
                    end,boss.data)
                end
            end
        end
    end
end

return CityWarTrack