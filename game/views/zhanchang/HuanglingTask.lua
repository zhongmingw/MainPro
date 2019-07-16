--皇陵之战任务弹窗
local HuanglingTask = class("HuanglingTask", base.BaseView)

function HuanglingTask:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function HuanglingTask:initView(  )
    local closeBtn = self.view:GetChild("n7"):GetChild("n2")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.taskPanel = self.view:GetChild("n19")
    self.taskList = self.taskPanel:GetChild("n1")
    self.bossPanel = self.view:GetChild("n20")
    self.bossList = self.bossPanel:GetChild("n1")
    self.refreshTime = 0 --boss1刷新时间
    self.refreshTime2 = 0 --boss2刷新时间

    self.c1 = self.view:GetController("c1")   --EVE 
    self.c1.onChanged:Add(self.onControlChangeOfC1,self)
end

function HuanglingTask:onControlChangeOfC1()
    if self.timer then 
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end 
    self:initData({type = self.c1.selectedIndex + 1})
end

function HuanglingTask:initData(data)
    self.type = data.type
    self.delay = 0
    self.special = nil
    self.num = 1
    self.timer = self:addTimer(1, -1, handler(self,self.timeTick))
    self:initTaskList()
    self:initBossList()
    if self.type == 1 then
        local confData = conf.HuanglingConf:getAdditionalAwards()
        self:setAwards(self.taskPanel:GetChild("n15"),confData)

        self.taskPanel.visible = true
        self.bossPanel.visible = false
        self:initTaskPanel()
    else
        local confData1 = conf.HuanglingConf:getBossAwards(1001)
        self:setAwards(self.bossPanel:GetChild("n18"),confData1)

        local confData2 = conf.HuanglingConf:getBossAwards(1002)
        self:setAwards(self.bossPanel:GetChild("n21"),confData2)

        self.taskPanel.visible = false
        self.bossPanel.visible = true
        self:initBossPanel()
    end
end

function HuanglingTask:getTaskPanelVisible()
    -- body
    return self.taskPanel.visible
end

function HuanglingTask:initTaskPanel()
    -- body
    self.data = cache.HuanglingCache:getTaskCache()
    self.otherData = {} --未完成的任务
    for k,v in pairs(self.data) do
        if v.taskFlag ~= 1 then
            table.insert(self.otherData,v)
        end
    end

    local len = 0
    if self.otherData then
        len = #self.otherData
    end
    self.special = nil
    self.taskList.numItems = len
    if len > 0 then
        for i=4,11 do
            self.taskPanel:GetChild("n"..i).visible = false
        end
        self.taskList.visible = true
        self.taskPanel:GetChild("n14").visible = true
        self.taskPanel:GetChild("n14").text = language.huangling12
        self.taskPanel:GetChild("n16").visible = false
    else
        self.taskPanel:GetChild("n14").visible = false
        for i=4,11 do
            self.taskPanel:GetChild("n"..i).visible = true
        end
        local bossData = cache.HuanglingCache:getBossCache()
        local num = cache.HuanglingCache:getBossNum()
        if cache.HuanglingCache:getBossTime() <= 0 and bossData[num].curHpPercent <=0 then
            for i=8,10 do
                self.taskPanel:GetChild("n"..i).visible = false
            end
            self.taskPanel:GetChild("n12").visible = false
        end
        self.taskList.visible = false
        self.taskPanel:GetChild("n16").visible = true
    end
    local taskBar = self.taskPanel:GetChild("n3")
    taskBar.value = cache.HuanglingCache:getTaskNum()-len
    taskBar.max = cache.HuanglingCache:getTaskNum()
    self.taskPanel:GetChild("n17").text = language.huangling05
    --挂机杀怪
    self.taskPanel:GetChild("n11").data = 1 --挂机打小怪
    self.taskPanel:GetChild("n11").onClick:Add(self.onClickHook,self)
    self.taskPanel:GetChild("n12").data = 2 --挂机打BOSS
    self.taskPanel:GetChild("n12").onClick:Add(self.onClickHook,self)
end

function HuanglingTask:initBossPanel()
    -- body
    self.data = cache.HuanglingCache:getBossCache()
    -- printt(bossData)
    if self.data then
        local len = #self.data
        self.bossList.numItems = len

        local bossNum = cache.HuanglingCache:getBossNum()
    -- print("boss信息",self.data,bossNum)
    -- printt(self.data)
        
        self.refreshTime = cache.HuanglingCache:getBossTime() or 0
        self.refreshTime = self.refreshTime - mgr.NetMgr:getServerTime()
        local endtime = cache.PlayerCache:getAttribute(20132)
            -- self.bossPanel:GetChild("n3").visible = false
            -- self.bossPanel:GetChild("n4").visible = false
        if bossNum == 0 then
            self.refreshTime2 = self.refreshTime + 600
            self.bossPanel:GetChild("n3").text = GTotimeString3(self.refreshTime)..language.huangling13
            self.bossPanel:GetChild("n4").text = GTotimeString3(self.refreshTime2)..language.huangling13
            self.bossPanel:GetChild("n3").visible = true
            self.bossPanel:GetChild("n4").visible = true
        elseif bossNum == 1 then
            self.refreshTime2 = endtime - mgr.NetMgr:getServerTime() - 600
            -- print("boss2剩余刷新时间",self.refreshTime2,endtime)
            -- if self.data[bossNum].curHpPercent > 0 then
            -- else
            --     self.refreshTime2 = self.refreshTime
            -- end
            if self.refreshTime2 < 0 then
                self.refreshTime2 = 0
            end
            self.bossPanel:GetChild("n3").visible = false
            self.bossPanel:GetChild("n4").visible = true
            self.bossPanel:GetChild("n4").text = GTotimeString3(self.refreshTime2)..language.huangling13
        elseif bossNum == 2 then
            self.bossPanel:GetChild("n3").visible = false
            self.bossPanel:GetChild("n4").visible = false
        end
    end
    local sId = cache.PlayerCache:getSId()
    local confData = conf.SceneConf:getSceneById(sId)
    local bossData = confData and confData.order_monsters
    local bossId1 = bossData[1][2]
    local bossId2 = bossData[2][2]
    local mConf1 = conf.MonsterConf:getInfoById(bossId1)
    local mConf2 = conf.MonsterConf:getInfoById(bossId2)

    self.bossPanel:GetChild("n17").text = string.format(language.huangling06,mConf1.name)
    self.bossPanel:GetChild("n23").text = string.format(language.huangling06,mConf2.name)
end

function HuanglingTask:timeTick()
    -- body
    if self.refreshTime>0 then
        self.refreshTime = self.refreshTime - 1
        self.bossPanel:GetChild("n3").text = GTotimeString3(self.refreshTime)..language.huangling13
    end
    if self.refreshTime2>0 then
        self.refreshTime2 = self.refreshTime2 - 1
        self.bossPanel:GetChild("n4").text = GTotimeString3(self.refreshTime2)..language.huangling13
    else
        self.bossPanel:GetChild("n4").text = "00:00"..language.huangling13
    end
    -- print("0000",self.special)
    if self.special then
        local cell = self.taskList:GetChildAt(self.special)
        self.delay = self.delay - 1
        if self.delay > 0 then
            local textData = {
                                {text=self:TotimeString(self.delay),color = 7},
                                {text=language.huangling01,color = 8},
                                {text=language.huangling03[self.num],color = 7},
                                {text=language.huangling02,color = 8},
                            }
            cell:GetChild("n8").text = mgr.TextMgr:getTextByTable(textData)
            cell:GetChild("n2").visible = true
            cell:GetChild("n9").visible = true
            cell:GetChild("n9").text = language.huangling03[self.num] .. language.huangling02
            -- print("剩余时间1111...",self.delay)

        else
            self.special = nil
            self.taskList.numItems = #self.otherData
            -- cell:GetChild("n8").text = language.huangling04
            -- cell:GetChild("n2").visible = false
            -- cell:GetChild("n9").visible = false
        end
    end
end

function HuanglingTask:initTaskList()
    -- body
    self.taskList.numItems = 0
    self.taskList.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    -- self.taskList:SetVirtual()
end

function HuanglingTask:initBossList()
    -- body
    self.bossList.numItems = 0
    self.bossList.itemRenderer = function(index,obj)
        self:bossCelldata(index, obj)
    end
    self.bossList:SetVirtual()
end

--任务面板
function HuanglingTask:celldata( index,obj )
    -- body
    local data = self.otherData[index+1]
    -- print("任务信息",data)
    if data then
        local taskData = conf.HuanglingConf:getTaskAwardsById(data.taskId)
        local doneAward = taskData.done_award
        local specAward = taskData.spec_award
        local specTime = taskData.spec_time
        local awards = {}
        local itemList = obj:GetChild("n5")
        itemList.numItems = 0
        local num = 0 --时间段
        local time = 0
        if data.special == 1 then --有特殊奖励
            local severTime = mgr.NetMgr:getServerTime()
            local delay = severTime - data.startTime
            if delay > specTime[4] then --超过时间 普通奖励
                awards = doneAward
            else
                local specialAward = {}
                if delay > specTime[3] then
                    specialAward = specAward[4]
                    time = specTime[4]
                    num = 4
                elseif delay > specTime[2] then
                    specialAward = specAward[3]
                    time = specTime[3]
                    num = 3
                elseif delay > specTime[1] then
                    specialAward = specAward[2]
                    time = specTime[2]
                    num = 2
                else
                    specialAward = specAward[1]
                    time = specTime[1]
                    num = 1
                end
                awards = {}
                for k,v in pairs(doneAward) do
                    table.insert(awards,clone(v))
                end
                for k,v in pairs(specialAward) do
                    local bol = false
                    for k2,v2 in pairs(awards) do
                        if v[1] == v2[1] then
                            bol = true
                            -- print("增加",awards[k2][2],v[2])
                            awards[k2][2] = awards[k2][2] + v[2]
                        end
                    end
                    if not bol then
                        table.insert(awards,v)
                    end
                end
                -- awards = data
            end
            self.delay = time - delay
            self.special = index
            self.num = num
        else
            awards = doneAward
        end
        if num == 0 then
            obj:GetChild("n8").text = language.huangling04
            obj:GetChild("n2").visible = false
            obj:GetChild("n9").visible = false
        else
            -- print("剩余时间",self.delay)
            local textData = {
                            {text=self:TotimeString(self.delay),color = 7},
                            {text=language.huangling01,color = 8},
                            {text=language.huangling03[num],color = 7},
                            {text=language.huangling02,color = 8},
                        }
            obj:GetChild("n8").text = mgr.TextMgr:getTextByTable(textData)
            obj:GetChild("n2").visible = true
            obj:GetChild("n9").visible = true
            obj:GetChild("n9").text = language.huangling03[num] .. language.huangling02
        end
        local roleLv = cache.PlayerCache:getRoleLevel()
        for k,v in pairs(awards) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local obj = itemList:AddItemFromPool(url)
            local mId = v[1]
            local amount = v[2]
            local bind = v[3]
            if mId == 221061001 then--经验跟随等级加成
                local expCoef = conf.HuanglingConf:getTaskExpCoef()
                amount = amount + roleLv*expCoef
            end
            local info = {mid = mId,amount = amount,bind = bind}
            GSetItemData(obj,info,true)
        end
        -- print("当前击杀",value,taskData.tar_con[1][1])
        obj:GetChild("n6").text = taskData.name
        
        local dec = taskData.dec
        local str = string.split(dec[1],"#")
        local taskNum = taskData.tar_con[1][2]
        local value = data.conMap[taskData.tar_con[1][1]] or 0
        local name = ""
        if taskData.type == 1 then
            local target = conf.NpcConf:getNpcById(taskData.tar_con[1][1])
            name = target.name
        else
            local target = conf.MonsterConf:getInfoById(taskData.tar_con[1][1])
            name = target.name
        end
        local textData = {
                {text=str[1],color = 8},
                {text=string.format(str[2],name),color = 7},
                {text=string.format(str[3],taskNum),color = 14},
                {text="("..value .. "/" .. taskNum .. ")",color = 7},
            }

        obj:GetChild("n7").text = mgr.TextMgr:getTextByTable(textData)
        -- conf.MonsterConf:getInfoById(info.mId)
        obj.data = taskData
        obj.onClick:Add(self.onClickTask,self) --任务追踪
        
    end
end

function HuanglingTask:TotimeString(nowtime)
    local minute=math.floor((nowtime%3600)/60);

    local second=(nowtime%3600)%60;
    
    return string.format("%02d:%02d",minute,second)
end

--任务追踪
function HuanglingTask:taskTrace( data )
    -- body
    local target = nil
    local point = nil
    if data.type == 1 then
        -- target = conf.NpcConf:getNpcById(data.tar_con[1][1])
        local fbId = cache.PlayerCache:getSId()
        local fbConf = conf.SceneConf:getSceneById(fbId)
        target = fbConf["pendant"]
        --获取当前采集物的所有坐标
        local posTab = {}
        for k,v in pairs(target) do
            if v[1] == data.tar_con[1][1] then
                local pos = {v[2],v[3]}
                table.insert(posTab,pos)
            end
        end
        local len = #posTab
        if len > 0 then
            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
            point = posTab[math.random(1,#posTab)]
            -- print("采集物",point[1],point[2])
        else
            GComAlter("找不到采集物")
        end
    else
        target = conf.MonsterConf:getInfoById(data.tar_con[1][1])
        point = target["pos"]
        -- print("怪物点",point[1],point[2])
    end


    if target then
        -- local kind = target.kind
        mgr.HookMgr:stopHook()
        local p = Vector3.New(point[1], gRolePoz, point[2])
        gRole:moveToPoint(p, PickDistance, function()
            if data.type == 1 then
                gRole:idleBehaviour()
                local roleId = 0
                local objs = mgr.ThingMgr:objsByType(ThingType.monster)
                for k,v in pairs(objs) do
                    if v.data.kind == MonsterKind.collection then
                        if v:getPosition().x == point[1] and v:getPosition().z == point[2] then
                            roleId = v.data.roleId
                            break
                        end
                    end
                end
                proxy.FubenProxy:send(1810302,{roleId = roleId,reqType = 1})--拾取
            else
                mgr.HookMgr:startHook()
            end
        end)
    else
        GComAlter(language.huangling08)
    end
end

function HuanglingTask:onClickTask( context )
    -- body
    local cell = context.sender
    local data = cell.data
    mgr.HookMgr:HuanglingTaskHook(data)
end

--挂机杀怪
function HuanglingTask:killMonsterHook( hookType )
    -- body
    local taskData = conf.HuanglingConf:getAllTask()
    local monsterMap = {}
    for k,v in pairs(taskData) do
        if v.type == 2 then
            table.insert(monsterMap,v)
        end
    end

    -- local allMonster = mgr.ThingMgr:objsByType(ThingType.monster)--所有的怪物
    local target = nil
    if hookType == 1 then
        for k,v in pairs(monsterMap) do
            local mId = v.tar_con[1][1]
            local mConf = conf.MonsterConf:getInfoById(mId)
            target = mConf
        end
    else
        local fbId = cache.PlayerCache:getSId()
        local fbConf = conf.SceneConf:getSceneById(fbId)
        if fbConf and fbConf["order_monsters"] then
            local bossId = fbConf["order_monsters"][1][2]
            local mConf = conf.MonsterConf:getInfoById(bossId)
            target = mConf
        end
    end
    
    if target then
        mgr.HookMgr:stopHook()
        local p = Vector3.New(target.pos[1], gRolePoz, target.pos[2])
        gRole:moveToPoint(p, PickDistance, function()
            gRole:idleBehaviour()
            mgr.HookMgr:startHook()
        end)
    else
        GComAlter(language.huangling08)
    end
end

function HuanglingTask:onClickHook( context )
    -- body
    local cell = context.sender
    local hookType = cell.data
    mgr.HookMgr:HuanglingHook(hookType)
end

--Boss面板
function HuanglingTask:bossCelldata( index,obj )
    -- body
    local data = self.data[index+1]
    -- print("boss信息",data,self.data)
    -- printt(self.data)
    local bossNum = cache.HuanglingCache:getBossNum()
    -- if data.curHpPercent > 0 then
        local hpBar = obj:GetChild("n3")
        hpBar.value = data.curHpPercent/100
        hpBar.max = 100
        hpBar:GetChild("title").text = (data.curHpPercent/100) .. "%"
        local guishuTxt = obj:GetChild("n4")
        guishuTxt.text = language.huangling14
        local nameTxt = obj:GetChild("n5")
        nameTxt.text = data.hateRoleName

        local sId = cache.PlayerCache:getSId()
        local confData = conf.SceneConf:getSceneById(sId)
        local bossData = confData and confData.order_monsters
        self.bossId = bossData[index+1][2]
        local mConf = conf.MonsterConf:getInfoById(self.bossId)
        obj:GetChild("n7").url =  ResPath.iconRes(mConf.icon) --UIPackage.GetItemURL("_icons" , ""..mConf.icon)
        obj:GetChild("n8").data = 2 --前往抢夺BOSS
        obj:GetChild("n8").onClick:Add(self.onClickHook,self)

        obj:GetChild("n6").visible = true
        obj:GetChild("n8").visible = true
        obj:GetChild("n7").grayed = false
        if bossNum == 0 then
            hpBar.value = 100
            guishuTxt.text = mConf.name
            nameTxt.text = ""
            obj:GetChild("n6").visible = false
            obj:GetChild("n8").visible = false
        elseif bossNum == 1 then
            if index+1 > bossNum then
                hpBar.value = 100
                guishuTxt.text = mConf.name
                nameTxt.text = ""
                obj:GetChild("n6").visible = false
                obj:GetChild("n8").visible = false
            else
                if data.curHpPercent > 0 then
                    obj:GetChild("n6").visible = true
                    obj:GetChild("n8").visible = true
                else
                    obj:GetChild("n7").grayed = true
                    obj:GetChild("n6").visible = false
                    obj:GetChild("n8").visible = false
                end
            end
        elseif bossNum == 2 then
            if index == 0 then
                obj:GetChild("n7").grayed = true
                obj:GetChild("n6").visible = false
                obj:GetChild("n8").visible = false
            else
                if data.curHpPercent > 0 then
                    obj:GetChild("n6").visible = true
                    obj:GetChild("n8").visible = true
                else
                    obj:GetChild("n7").grayed = true
                    obj:GetChild("n6").visible = false
                    obj:GetChild("n8").visible = false
                end
            end
        end

    -- end
end

function HuanglingTask:setAwards(listView,confData)
    -- body
    listView.numItems = 0
    for k,v in pairs(confData) do
        local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
        local obj = listView:AddItemFromPool(url)
        local mId = v[1]
        local amount = v[2]
        local bind = v[3]
        local info = {mid = mId,amount = amount,bind = bind}
        GSetItemData(obj,info,true)
    end
end

function HuanglingTask:onClickClose(  )
    self.c1.selectedIndex = 0
    self:removeTimer(self.timer)
    self:closeView()
end

return HuanglingTask