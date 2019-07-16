--[[--
]]

local ThingMgr = class("ThingMgr")

function ThingMgr:ctor()
    self.mAllObjs = {}
    for i=1,ThingType.total do
        self.mAllObjs[i] = {}
    end
    self:init()
    self.selectEct = nil
    self.selectId = nil
    self.lastTime = 0
end

function ThingMgr:init()
    self.totalNpcNum = 0
    --当前场景动态生成物
    self.dynIndex = 1
    self.dynList = {}
    --传送阵
    self.transfersList = {}
    --剧情怪物
    self.movieList = {}
    --事物渲染队列
    self.mAppearList = {}
    self.pAppearList = {}
    self.tAppearList = {}
end

--更新
function ThingMgr:update()
    self.nowTime = Time.getTime()
    --场景上的动态生成物
    self:updateDynThing()
    --检查玩家是否在传送阵上
    for k, v in pairs(self.transfersList) do
        local pos = v:getPosition()
        local dis = GMath.distance(pos, gRole:getPosition())
        if v.type == 2 then  --传送阵
            if dis < 80 and self.nowTime - v.markTime > 1 then --准备切换场景
                if gRole:getStateID() ~= RoleAI.jump then
                    local info = v.nextInfo
                    local sId = cache.PlayerCache:getSId()
                    if mgr.FubenMgr:isKuafuCityWar(sId) then
                        local param = {
                            sceneId = info[1],
                            pox = info[2],
                            poy = info[3],
                            ext01 = v.id,
                        }
                        proxy.ThingProxy:crossTransfer(param)
                    else
                        local mainTaskId = cache.TaskCache:getCurMainId()
                        -- print("当前主线任务id>>>>>>>>>",mainTaskId)
                        if mainTaskId > 1014 or mainTaskId == 0 then
                            proxy.ThingProxy:sChangeScene(info[1], info[2], info[3], 1, v.id)
                        else
                            GComAlter(language.task20)
                        end
                    end
                    v.markTime = self.nowTime
                    
                    mgr.TimerMgr:addTimer(1, 1, function()
                        local info = cache.CityWarCache:getCityWarTaskCache()
                        if info then
                            local pos = Vector3.New(info.pox, gRolePoz, info.poy)
                            gRole:moveToPoint(pos, 100, function()
                                mgr.HookMgr:enterHook()
                            end)
                            cache.CityWarCache:setCityWarTaskCache(nil)
                        end
                    end)
                    -- plog("开始传送.....",info[1], info[2], info[3], 1, v.id, "当前场景:",sId)
                end
                return
            end
        elseif v.type == 4 then  --跳跃点
            --plog("检测跳跃")
            if dis < 40 and self.nowTime - v.markTime > 1 then  --开始跳跃
                mgr.JumpMgr:startJump(v.nextInfo)
                v.markTime = self.nowTime
            end
        elseif v.type == 6 then
            if dis < 40 and self.nowTime - v.markTime > 1 then  --开始跳跃
                if v.data.id == 3999991 then
                    --新手地图任务未完成不能切换
                    local id = cache.PlayerCache:getSId()
                    if tonumber(id) == 204001 then
                        if not cache.TaskCache:isfinish(1017) then
                            GComAlter(language.gonggong87)
                            GgoToMainTask()
                            return 
                        end
                    end
                end

                mgr.JumpMgr:roleMovie(v.data,function()
                    if v.data.id == 3999999 then --老鹰飞完之后
                        GOpenView({id = 1053})
                        cache.PlayerCache:setRedpoint(10308,0)
                    elseif v.data.id == 3999977 then  --末尾转场景飞鹰
                        -- TODO 切换场景后继续任务
                        mgr.TaskMgr.mState = 2
                    else
                        GgoToMainTask()
                    end
                end, true)
            end
        elseif v.type == 10 then--城战传送点
            local monsterData = cache.CityWarCache:getCityWarTrackData()
            local transferData = conf.CityWarConf:getTransferData(v.id)
            local mData = {}
            for _,monster in pairs(monsterData) do
                mData[monster.attris[601]] = true
            end
            -- print("当前传送阵对应怪物id",transferData.monsterId)
            -- for k,v in pairs(mData) do
            --     print(k,v)
            -- end
            if dis < 80 and self.nowTime - v.markTime > 1 and not mData[transferData.monsterId] then --准备切换场景
                if gRole:getStateID() ~= RoleAI.jump then
                    local info = v.nextInfo
                    local sId = cache.PlayerCache:getSId()
                    if mgr.FubenMgr:isKuafuCityWar(sId) then
                        local param = {
                            sceneId = info[1],
                            pox = info[2],
                            poy = info[3],
                            ext01 = v.id,
                        }
                        proxy.ThingProxy:crossTransfer(param)
                    else
                        proxy.ThingProxy:sChangeScene(info[1], info[2], info[3], 1, v.id)
                    end
                    v.markTime = self.nowTime
                    mgr.TimerMgr:addTimer(1, 1, function()
                        local bossinfo = cache.CityWarCache:getCityWarTaskCache()
                        if bossinfo then
                            local pos = Vector3.New(bossinfo.pox, gRolePoz, bossinfo.poy)
                            gRole:moveToPoint(pos, 100, function()
                                mgr.HookMgr:enterHook()
                            end)
                            cache.CityWarCache:setCityWarTaskCache(nil)
                        end
                    end)
                    -- plog("开始传送.....",info[1], info[2], info[3], 1, v.id, "当前场景:",sId)
                end
                return
            end
        end
    end

    --事物渲染出现
    --怪物，墓碑，姻缘树，三界争霸车，采集物
    local mLen = #self.mAppearList
    if mLen > 0 then
        local roleId = self.mAppearList[mLen]
        table.remove(self.mAppearList, mLen)
        local monster = self:getObj(ThingType.monster, roleId)
        if monster then
            monster:appear()
        end 
    end
    -- --墓碑
    -- local mLen = #self.mAppearList
    -- if mLen > 0 then
    --     local roleId = self.mAppearList[mLen]
    --     table.remove(self.mAppearList, mLen)
    --     local widgets = self:getObj(ThingType.monster, roleId)
    --     if widgets then
    --         widgets:appear()
    --     end
    -- end
    --玩家
    local mLen = #self.pAppearList
    if mLen > 0 then
        local roleId = self.pAppearList[mLen]
        table.remove(self.pAppearList, mLen)
        local player = self:getObj(ThingType.player, roleId)
        if player then
            player:appear()
        end
    end
    --宠物
    local mLen = #self.tAppearList
    if mLen > 0 then
        local roleId = self.tAppearList[mLen]
        table.remove(self.tAppearList, mLen)
        local pet = self:getObj(ThingType.pet, roleId)
        if pet then
            pet:appear()
        end
    end
end

--添加主角
function ThingMgr:addRole()
    local role = thing.Role.new()
    gRole = role
    role:setData()
    self.mAllObjs[ThingType.role][role:getID()] = role
    --添加主角的buff
    mgr.BuffMgr:addThingBuff(cache.PlayerCache:getData())
end

--添加宠物
function ThingMgr:addPet(ownerData, ownerType, see)
    local pet = self:getObj(ThingType.pet, ownerData.roleId)
    if not pet then
        pet = thing.Pet.new()
        pet.canSee = see
        pet:setData(ownerData, ownerType)
        self:addObj(ThingType.pet, ownerData.roleId, pet)
        table.insert(self.tAppearList, ownerData.roleId)
    else
        --plog("[异常]-ThingMgr:addPet>>宠物重复添加")
        pet:setData(ownerData, ownerType)
    end
    return pet
end
--添加新的宠物
function ThingMgr:addPetNew(ownerData, ownerType, see)
    local pet = self:getObj(ThingType.pet,ownerData.newpetid )
    if not pet then
        pet = thing.Pet.new()
        pet.canSee = see
        pet:setData(ownerData, ownerType,true)

        self:addObj(ThingType.pet, ownerData.newpetid, pet)
        table.insert(self.tAppearList, ownerData.newpetid)
    else
        --plog("[异常]-ThingMgr:addPet>>宠物重复添加")
        pet:setData(ownerData, ownerType,true)
    end
    return pet
end
--添加新的仙童
function ThingMgr:addXianTongNew(ownerData, ownerType, see)
    local pet = self:getObj(ThingType.pet,ownerData.xiantong_id )
    if not pet then
        pet = thing.Pet.new()
        pet.canSee = see
        pet:setData(ownerData, ownerType,nil,true)

        self:addObj(ThingType.pet, ownerData.xiantong_id, pet)
        table.insert(self.tAppearList, ownerData.xiantong_id)
    else
        --plog("[异常]-ThingMgr:addPet>>宠物重复添加")
        pet:setData(ownerData, ownerType,nil,true)
    end
    return pet
end

--添加玩家，玩家出现
function ThingMgr:addPlayer(data)
    local player = self:getObj(ThingType.player, data.roleId)
    if not player then
        player = thing.Player.new()
        player:setData(data)
        self:addObj(ThingType.player, data.roleId, player)
        --处理玩家的buff-buff有需要处理是否变身设置skins。所以在setSkin之前处理
        mgr.BuffMgr:addThingBuff(data)
        table.insert(self.pAppearList, data.roleId)
        --
              
    else
        --plog("[异常]-ThingMgr:addPlayer>>角色重复添加")
        player:setData(data)
    end
end
--添加怪物
function ThingMgr:addMonster(data)
    local monster = self:getObj(ThingType.monster, data.roleId)
    if not monster then
        monster = thing.Monster.new()
        monster:setData(data)
        self:addObj(ThingType.monster, data.roleId, monster)
        table.insert(self.mAppearList, data.roleId)
    else
        --plog("[异常]-ThingMgr:addMonster>>怪物重复添加",data.roleId)
        monster:setData(data)
    end
end

--添加墓碑
function ThingMgr:addWidget(data)
    -- body
    local widgets = self:getObj(ThingType.monster, data.roleId)
    if not widgets then
        widgets = thing.Widget.new()
        widgets:setData(data)
        self:addObj(ThingType.monster, data.roleId, widgets)
        table.insert(self.mAppearList, data.roleId)
    else
        --plog("[异常]-ThingMgr:addMonster>>墓碑重复添加",data.roleId)
        widgets:setData(data)
    end
end

function ThingMgr:widgetDead( data )
    -- body
    self:removeObj(ThingType.monster, data.roleId, true)
    -- local m = self:getObj(ThingType.monster, data.roleId)
    -- if m then
    --     m:dispose(data.killerId)
    -- end
end

--怪物死亡
function ThingMgr:monsterDead(data)
    local m = self:getObj(ThingType.monster, data.roleId)
    if m then
        m:dead(data.killerId)
    end
end
--玩家死亡
--[[
0:默认死亡躺下,飘复活窗口
1:死亡不躺下,不飘复活窗口
2:死亡躺下,不飘复活窗口
3:世界boss特殊复活类型
4:boss之家死亡复活类型
5:守塔复活
]]
function ThingMgr:playerDead(data)
    local player
    if data.roleId == gRole:getID() then
        player = gRole
        gRole:stopAI()
        --死亡停止挂机
        mgr.HookMgr:cancelHook()

        --TODO 处理弹框
        if mgr.FubenMgr:isHome(cache.PlayerCache:getSId()) then
            if not cache.HomeCache:getisSelfHome() then
                --直接离开副本
                mgr.FubenMgr:quitFuben()
                return
            end
        end

        if data.reviveType == 0 or data.reviveType == 3 then
            local sId = cache.PlayerCache:getSId()
            if mgr.FubenMgr:isFsFuben(sId) then
                local _index = sId % 1000
                local confdata = conf.FubenConf:getFszdlayer(_index)
                if confdata and confdata.vip_con and cache.PlayerCache:getVipLv() < confdata.vip_con then
                    mgr.ViewMgr:openView2(ViewName.ReviveView, data)
                else
                    mgr.ViewMgr:openView2(ViewName.DeadView, data)
                end
            elseif mgr.FubenMgr:isWSJChuMo(sId) then
                mgr.ViewMgr:openView2(ViewName.WSJDeadView, data)
            else
                mgr.ViewMgr:openView2(ViewName.DeadView, data)
            end
        end
        if data.reviveType == 4 or data.reviveType == 5 then--复活倒计时
            mgr.ViewMgr:openView2(ViewName.ReviveView, data)
        end
        print("你已经死亡，等待复活~", data.reviveType)
    else
        player = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
    end
    if player then
        player:dead()
    end
end
--玩家复活
function ThingMgr:playerRevive(data)
    local player
    if data.roleId == gRole:getID() then
        player = gRole
        --TODO 关闭界面
        mgr.ViewMgr:closeView(ViewName.DeadView)
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isEliteBoss(sId) 
            or (sId == HuangLingScene) 
            or mgr.FubenMgr:isWenDing(sId) 
            or mgr.FubenMgr:isXianMoWar(sId)
            or mgr.FubenMgr:isMjxlScene(sId)
            or mgr.FubenMgr:isHjzyScene(sId) 
            or mgr.FubenMgr:isWanShenDian(sId) then
            mgr.TimerMgr:addTimer(1, 1, function()
                mgr.HookMgr:enterHook()
            end)
        elseif mgr.FubenMgr:isWorldBoss(sId) 
            or mgr.FubenMgr:isGangWar(sId)
            or mgr.FubenMgr:isWuXingShenDian(sId) 
            or mgr.FubenMgr:isFsFuben(sId) 
            or mgr.FubenMgr:isShenShou(sId)
            or mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) 
            or mgr.FubenMgr:isTaiGuXuanJing(sId) then
            if data.reviveType == 2 then--原地复活
                cache.FubenCache:setChooseBossId(0)
                mgr.TimerMgr:addTimer(1, 1, function()
                    mgr.HookMgr:enterHook()
                end)
            else
                -- plog("复活点复活")
                mgr.HookMgr:finishPick()
                mgr.HookMgr:cancelHook()
            end
        elseif mgr.FubenMgr:isKuaFuWar(sId) then
            mgr.HookMgr:cancelHook()
        elseif mgr.FubenMgr:isXianyu(sId) or mgr.FubenMgr:isJianShengshouhu(sId)  then
            --守塔：进入后自动挂机、死亡复活后自动挂机
            mgr.TimerMgr:addTimer(1, 1, function()
                mgr.HookMgr:enterHook()
            end)
        elseif mgr.FubenMgr:isWSJChuMo(sId) then
            mgr.ViewMgr:closeView(ViewName.WSJDeadView)
        end
        --红名野外复活加飘字
        local sConf = conf.SceneConf:getSceneById(sId)
        local kind = sConf and sConf.kind or 0
        local roleId = cache.PlayerCache:getRoleId()
        if kind == SceneKind.field then--野外
            local var = cache.PlayerCache:getAttribute(613)
            if conf.SysConf:isHongMing(var) then--是红名
                local confData = conf.SysConf:getRedDataByValue(var)
                GComAlter(string.format(language.gonggong132,confData.reduce_exp/100))
            end
        end
    else
        player = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
    end
    if player then
        player:revive(data)
        --恢复玩家buff
        mgr.BuffMgr:addThingBuff(data)
    end
end

--服务端玩家出现先推送到客户端的队列中逐个显示
function ThingMgr:pushThingsQueue(data)
    if data.dUsers then--移除玩家列表
        local len = #data.dUsers
        for i=1,len do
            local id = data.dUsers[i]
            --mgr.BuffMgr:removeThingBuff({roleId = id})
            -- local player =  mgr.ThingMgr:getObj(ThingType.player, id)
            -- if player then
            --     if player.data.newpetid then
            --         mgr.ThingMgr:removeObj(ThingType.pet, player.data.newpetid)
            --     end
            -- end

            mgr.ThingMgr:removeObj(ThingType.player, id, true)
            mgr.ThingMgr:removeObj(ThingType.pet, id, true)

            --mgr.ThingMgr:removeObj(ThingType.pet, id.."1", true)
        end        
    end

    if data.dMonsters then--移除怪物列表
        local len = #data.dMonsters
        for i=1, len do
            local id = data.dMonsters[i]
            mgr.ThingMgr:removeObj(ThingType.monster, id, true)
        end
    end

    --墓碑
    if data.dWidgets then
        local len = #data.dWidgets
        for i=1, len do
            local id = data.dWidgets[i]
            self:removeObj(ThingType.monster, id, true)
            --mgr.ThingMgr:removeObj(ThingType.monster, id, true)
        end
    end

    if data.users then--玩家信息列表
        local len = #data.users
        for i=1,len do
            local info = data.users[i]
            self:pushAppearQueue(info, ThingType.player)
        end
    end

    if data.monsters then--怪物列表
        local len = #data.monsters
        for i=1, len do
            local info = data.monsters[i]
            self:pushAppearQueue(info, ThingType.monster)
        end
    end

    if data.widgets then
        local len = #data.widgets
        for i=1, len do
            local info = data.widgets[i]
            self:pushAppearQueue(info, ThingType.monster)
        end
    end
end
--移除怪物列表
function ThingMgr:monsterListDisappear(data)
    if data.dMonsters then--移除怪物列表
        local len = #data.dMonsters
        for i=1, len do
            local id = data.dMonsters[i]
            mgr.ThingMgr:removeObj(ThingType.monster, id, true)
        end
    end
end
----
function ThingMgr:pushAppearQueue(info, t)
    if t == ThingType.player then
        self:addPlayer(info)
    elseif t == ThingType.monster then
        if self:isSceneWidget(info) then
            self:addWidget(info)
        else
            if self:isSceneItem(info) then--判断是不是道具
                info = self:setItemData(info)
            end
            self:addMonster(info)   
        end
    end
end
--是不是组件
function ThingMgr:isSceneWidget(data)
    local kind = data and data.kind or 0
    --plog("kind",kind)
    if kind == WidgetKind.mb or kind == WidgetKind.tree 
    or kind == WidgetKind.home then
        return true
    end
    return false
end
--是不是场景上的道具
function ThingMgr:isSceneItem(data)
    local kind = data and data.kind or 0
    if kind == MonsterKind.chest then
        return true
    end
end
--设置场景上的道具信息
function ThingMgr:setItemData(data)
    data["itemId"] = clone(data.mId)
    local modelId = conf.ItemConf:getModel(data.mId)
    data.mId = modelId
    return data
end
--根据场景id去初始化需要动态更新的事物
function ThingMgr:initDynList(sId, mId)
    self.dynIndex = 1
    local sceneConf = conf.SceneConf:getSceneById(sId)
    --npc
    local npcs = sceneConf["npc"]
    if npcs and #npcs > 0 then
        local num = #npcs
        self.totalNpcNum = num
        for i=1,num do
            table.insert(self.dynList, {npcs[i], ThingType.npc, 0})
        end
    end
    --传送阵
    local transfers = sceneConf["transfer"]
    if transfers and #transfers > 0 then
        num = #transfers
        self.totalNpcNum = self.totalNpcNum + num
        for i=1,num do
            table.insert(self.dynList, {transfers[i], ThingType.transfer, 0})
        end
    end
    --场景特效
    if mId then
        local mapEctConf = conf.SceneConf:getMapEffect(mId)
        if mapEctConf then
            local effect = mapEctConf["map_ect"]
            if effect and #effect > 0 then
                num = #effect
                self.totalNpcNum = self.totalNpcNum + num
                for i=1,num do
                    table.insert(self.dynList, {effect[i], ThingType.produce, 0})
                end
            end
        end
    end
    --采集物
    local produces = sceneConf["produce"]
    if produces and #produces > 0 then
        num = #produces
        self.totalNpcNum = self.totalNpcNum + num
        for i=1,num do
            table.insert(self.dynList, {produces[i], ThingType.produce, 0})
        end
    end
    --跳跃点
    local jumps = sceneConf["jump"]
    if jumps and #jumps then
        num = #jumps
        self.totalNpcNum = self.totalNpcNum + num
        for i=1,num do
            table.insert(self.dynList, {jumps[i], ThingType.transfer, 0})
        end
    end
    --剧情怪
    local movies = sceneConf["movie"]
    if movies and #movies then
        num = #movies
        self.totalNpcNum = self.totalNpcNum + num
        for i=1,num do
            table.insert(self.dynList, {movies[i], ThingType.movie, 0})
        end
    end
end

--每帧检查一个需要动态处理的事物
function ThingMgr:updateDynThing()
    if self.dynList and #self.dynList>0 then
        local dynType = self.dynList[self.dynIndex][2]
        local dynId = self.dynList[self.dynIndex][1]
        local isVisible = self.dynList[self.dynIndex][3]
        local dynConf = conf.NpcConf:getNpcById(dynId)
        local pos = dynConf and dynConf["pos"]

        -- print("~~~~~~~~~~~~~~~~~~~~~~~!!~ddd~~~",GIsXianMengStation())
        if dynId == 3100211 and not GIsXianMengStation() then  --EVE 仙盟驻地非圣火活动期间不显示圣火火焰特效                     
            -- print("圣火熄灭~")
            self:removeObj(dynType, dynId, true)
            return
        end 

        if not dynConf or not pos then
            self.dynIndex = (self.dynIndex % self.totalNpcNum)+ 1
            plog("缺少事物ID：", dynId)
            return
        end
        local d = GMath.distance(Vector3.New(pos[1],gRolePoz,pos[2]), gRole:getPosition())
        --plog("ThingID:", dynId, "-距离：", d)
        if d < gScreenSize.width then
            if isVisible == 0 then
                local dynThing
                local visibled = 1
                if dynType == ThingType.npc then
                    if dynConf.taskid then --要求任务ID
                        if cache.TaskCache:CheckTaskID(dynConf.taskid) then
                            dynThing = thing.Npc.new()
                            dynThing:setData({id=dynId})
                            self:addObj(dynType, dynId, dynThing) 
                        end
                    else
                        dynThing = thing.Npc.new()
                        dynThing:setData({id=dynId})
                        self:addObj(dynType, dynId, dynThing) 
                    end
                elseif dynType == ThingType.transfer then
                    if dynConf.type == 10 then--城战城外的传送点 城门破了之后显示
                        local isShow = false
                        local monsterData = cache.CityWarCache:getCityWarTrackData()
                        if #monsterData > 0 then
                            local transferData = conf.CityWarConf:getTransferData(dynConf.id)
                            local mData = {}
                            for _,monster in pairs(monsterData) do
                                mData[monster.attris[601]] = true
                            end
                            -- print("传送阵id",dynConf.id,mData[transferData.monsterId])
                            if not mData[transferData.monsterId] then
                                -- print("当前城门id",transferData.monsterId,dynConf.id)
                                isShow = true
                            else
                                isShow = false
                            end
                        end
                        if isShow then
                            if not self.transfersList[dynId] then
                                dynThing = thing.Transfer.new()
                                dynThing:setData(dynConf)
                                self.transfersList[dynId] = dynThing
                            end
                        end
                        visibled = 0 
                    else
                        dynThing = thing.Transfer.new()
                        dynThing:setData(dynConf)
                        self.transfersList[dynId] = dynThing
                    end
                elseif dynType == ThingType.produce then
                    dynThing = thing.Transfer.new()
                    dynThing:setData(dynConf)
                    self:addObj(dynType, dynId, dynThing)
                elseif dynType == ThingType.movie then
                    dynThing = thing.Npc.new()
                    dynThing:setData({id=dynId})
                    dynThing:setParent()
                    self.movieList[dynId] = dynThing
                end
                self.dynList[self.dynIndex][3] = visibled
            end
        else
            if isVisible == 1 then  --移除
                self.dynList[self.dynIndex][3] = 0
                if dynType == ThingType.npc or dynType == ThingType.produce then
                    self:removeObj(dynType, dynId, true)
                elseif dynType == ThingType.transfer then
                    local transfer = self.transfersList[dynId]
                    if transfer then
                        transfer:dispose()
                        self.transfersList[dynId] = nil
                    end
                elseif dynType == ThingType.movie then
                    local movie = self.movieList[dynId]
                    if movie then    
                        movie:dispose()
                        self.movieList[dynId] = nil
                    end
                end
            end
        end
        self.dynIndex = (self.dynIndex % self.totalNpcNum)+ 1
    end 
end
--剧情怪物的移除
function ThingMgr:delMovieList()
    for k, v in pairs(self.movieList) do
        v:dead()
    end
    self.movieList = {}
end

--获取最近可攻击对象
function ThingMgr:getNearTar()
    local info = UnityObjMgr.nearObj
    local id = tostring(info.objId)
    if id == "0" then
        self.selectId = nil
        return nil
    end
    local t = self.mAllObjs[info.type]
    if not t then
        self.selectId = nil
        return nil
    end
    if self.selectId ~= id then
        --self:addSelectEct(info.type, id)
        --self.selectId = id
    end
    return t[id], info
end
--获取对象
function ThingMgr:objsByType(t)
    return self.mAllObjs[t]
end
--获取对象
function ThingMgr:getObj(t, id)
    local objs = self.mAllObjs[tonumber(t)]
    if objs then
        return objs[tostring(id)]
    end
    return nil
end
--移除事物
function ThingMgr:removeObj(t, id, clear)
    --清理玩家的buff
    mgr.BuffMgr:removeThingBuff({roleId = id})
    --移除玩家索引
    local tar = self:getObj(t, id)
    self.mAllObjs[t][tostring(id)] = nil
    if t ~= ThingType.produce then
        -- print("type t  id>>>>>>>>>>>>>>>>>",t,id)
        -- if id == nil then
        --     print(debug.traceback)
        -- end
        UnityObjMgr:RemoveObject(t, id)
    end
    if tar and tar.isSelected and self.selectEct then    
        self.selectEct.Parent = nil
        self.selectEct.LocalPosition = Vector3.zero
    end
    --清理玩家
    if clear and tar then
        tar:dispose()
    end 
    if t == ThingType.player then
        local view = mgr.ViewMgr:get(ViewName.PlayerHpView)
        if view then
            local data = view:getData()
            local roleId = data and data.roleId or 0
            if roleId == id then
                view:closeView()
            end
        end
        local view = mgr.ViewMgr:get(ViewName.NearPlayer)
        if view then
            view:removeData(id)
        end
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:removeData(id)
        end

        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:CheckFuJinNum()
        end
    end
    if t == ThingType.monster then
        local view = mgr.ViewMgr:get(ViewName.BossHpView)
        if view then
            local sId = cache.PlayerCache:getSId()
            local roleId = view:getBossRoleId() or 0
            if roleId == id and sId ~= HuangLingScene then
                view:close()
            end
        end
    end
end
--添加事物
function ThingMgr:addObj(t, id, thing)
    local list = self.mAllObjs[t]
    list[tostring(id)] = thing
    if thing.character then
        UnityObjMgr:AddThing(t,thing.character)
    end
    if t == ThingType.player then
        local view = mgr.ViewMgr:get(ViewName.NearPlayer)
        if view then
            view:addData(id)
        end
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:addData(id)
        end
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:CheckFuJinNum()
        end
    end
end
--给对象添加选中效果
function ThingMgr:addSelectEct(type, roleId)
    local thing = self:getObj(tonumber(type), roleId)
    if not thing then
        if self.selectEct then
            -- self.selectEct.Parent = nil
            -- self.selectEct.LocalPosition = Vector3.zero
        end
        return 
    end
    local bParent = thing.character.mRoot.mTransform
    if not self.selectEct then
        self.selectEct = mgr.EffectMgr:playCommonEffect("4040105", bParent)
    end
    self.selectEct.Parent = bParent
    self.selectEct.LocalPosition = Vector3.zero
    self.selectEct.LocalRotation = Vector3.New(0,0,180)
    thing.isSelected = true
    local kind = thing.data and thing.data.kind or 0
    if thing.tType == ThingType.player and kind ~= PlayerKind.statue then
        local view = mgr.ViewMgr:get(ViewName.PlayerHpView)
        if view then
            view:setData(thing.data)
        else
            if not thing.data["isDead"] then
                mgr.ViewMgr:openView2(ViewName.PlayerHpView, thing.data)
            end
        end
    else
        local view = mgr.ViewMgr:get(ViewName.PlayerHpView)
        if view then
            view:closeView()
        end
    end
end

---给任务NPC添加一个问号
function ThingMgr:addWenHaoToNpc(reqType)
    for k ,v in pairs(cache.TaskCache.npcTask) do
        local t = self:getObj(ThingType.npc,k)
        if t then
            if reqType  then
                t:removeWenHao()
                break
            else
                t:addWenHao()
                break
            end 
        end
    end
end

--清理所有对象
function ThingMgr:dispose(all)
    for k, v in pairs(self.movieList) do
        v:dispose()
    end
    for k, v in pairs(self.transfersList) do
        v:dispose()
    end
    for i=1,ThingType.total do
        if i ~= ThingType.role or all == true then
            for k, v in pairs(self.mAllObjs[i]) do
                self:removeObj(i, k, true)
            end
            self.mAllObjs[i] = {}
        end
    end
    mgr.PickMgr:dispose()
    self:init()
    UnityObjMgr:Dispose(all or false)
    if all then
        gRole = nil
    end
end
--剧情npc
function ThingMgr:addGuideNpc(npcId)
    local npcData = conf.FubenConf:getGuideNpc(npcId)
    local data = clone(cache.PlayerCache:getData())
    data.mId = npcId or data.mId
    data.roleId = tostring(npcData.opt)
    data.pox = gRole:getPosition().x
    data.poy = gRole:getPosition().z
    data.roleName = npcData and npcData.name
    data.pkState = cache.PlayerCache:getPKState()
    local sex = npcData and npcData.sex or 1
    data.roleIcon = 100000000*sex
    data.skins = npcData and npcData.skins or {}
    local guideNpc = self:getObj(ThingType.player, data.roleId)
    if not guideNpc then
        guideNpc = thing.GuideNpc.new()
        guideNpc:setData(data, ThingType.role)
        self:addObj(ThingType.player, data.roleId, guideNpc)
    else
        plog("[异常]-ThingMgr:addGuideNpc>>剧情npc重复添加")
        guideNpc:setData(data)
    end
    table.insert(self.pAppearList, tostring(roleId))
end

function ThingMgr:removeGuideNpc(roleId)
    local guideNpc = self:getObj(ThingType.player, roleId)
    guideNpc:stopAI()
    guideNpc:flyUp(function()
        mgr.TimerMgr:addTimer(0.5, 1, function( ... )
            self:removeObj(ThingType.player, roleId, true)
        end)
    end) 
    for k,v in pairs(self.pAppearList) do
        if v == roleId then
            table.remove(self.pAppearList,k)
            break
        end
    end
end
--test-----------------------------------------
function ThingMgr:addAIPlayer()
    if not self.testID then
        self.testID = 1
        self.aiplayers = {}
    end
    local data = clone(cache.PlayerCache:getData())
    data.roleId = self.testID..""
    data.pox = gRole:getPosition().x
    data.poy = gRole:getPosition().z
    data.roleName = "test"..self.testID
    local sex = math.floor(self.testID%2)+1
    data.roleIcon = 100000000*sex
    if sex == 1 then
        data.skins[1] = 3010101
    else
        data.skins[1] = 3010201
    end
    local player = self:getObj(ThingType.player, data.roleId)
    if not player then
        player = thing.AIPlayer.new()
        player:setData(data, ThingType.role)
        self:addObj(ThingType.player, data.roleId, player)
    else
        plog("[异常]-ThingMgr:addPlayer>>角色重复添加")
        player:setData(data)
    end
    table.insert(self.aiplayers, self.testID.."")
    self.testID = self.testID + 1
end

function ThingMgr:removeAIPlayer()
    if self.aiplayers and #self.aiplayers > 0 then
        self:removeObj(ThingType.player, self.aiplayers[1], true)
        table.remove(self.aiplayers,1)
    end
end

return ThingMgr