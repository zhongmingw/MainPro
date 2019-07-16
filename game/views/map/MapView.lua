local MapView = class("MapView", base.BaseView)

function MapView:ctor()
    self.super.ctor(self)
end

function MapView:initParams()
    self.uiLevel = UILevel.level2           --窗口层级
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function MapView:setData()

end

function MapView:initData()
  
    self:initControlC2() --EVE 初始化当前地图在世界地图中的显示
    
    --初始化都是打开当前地图
    local sId = cache.PlayerCache:getSId()
    self.mapId = cache.PlayerCache:getMapModelId()
    self:updateCurMap(sId)
    --设置玩家当前坐标
    local rolePos = gRole:getPosition()

    self.xLabel.text = math.ceil(rolePos.x)
    self.yLabel.text = math.ceil(rolePos.z)
    --设置头像
    local sex = cache.PlayerCache:getSex()
    local touxiang = self.head:GetChild("n1")
    if sex==1 then
        touxiang.url=UIPackage.GetItemURL("map", "ditu_017")
    else
        touxiang.url=UIPackage.GetItemURL("map", "ditu_018")
    end
    if not self.mapTimer then
        self.mapTimer = self:addTimer(0.5,-1,handler(self, self.updateTimer))
    end
    self.quickBtn.visible = false


end 

function MapView:initView()
    self.lineList = {} --线列表
    self.mapNpcs = {}--地图npc
    self.mapTrans = {} --地图传送阵
    self.mapMons = {} --地图怪物点
    self.warRefTime = 0--记录战斗地图刷新时间
    self.listData = {} --右侧列表信息
    local window4 = self.view:GetChild("n0")
    local closeBtn = window4:GetChild("n2")
    self:setCloseBtn(closeBtn) 
    --closeBtn.onClick:Add(self.onCloseBtn,self) --EVE 自定义的关闭函数

    self.control = self.view:GetController("c1")
    self.control.onChanged:Add(self.onControlChange,self)

    --世界地图
    self.worldMap = self.view:GetChild("n15")
    --EVE 添加世界大地图
    self.controlC2 = self.worldMap:GetController("c2")
    self.controlC2.onChanged:Add(self.onControlChangeScene,self)

    self:initMapNameAndMapGrade(self.worldMap) --初始化地图名称和等级
    --EVE end

    --当前地图
    self.detilMap = self.view:GetChild("n16")
    self.detilMap.onTouchBegin:Add(self.onTouchCurMap,self)
    --当前地图标题按钮
    local detilMapBtn = self.view:GetChild("n3")
    -- detilMapBtn.onClick:Add(self.onTouchRefresh,self)
    --加速(小飞鞋)
    self.quickBtn = self.detilMap:GetChild("n24")
    self.quickBtn.onClick:Add(self.onQuickClick,self)

    
    self.head = self.detilMap:GetChild("n22")
    self.mapName = self.detilMap:GetChild("n21")
    self.curMap = self.detilMap:GetChild("n25")
    --怪物/npc/传送阵列表
    self.tList = self.view:GetChild("n5")
    self.tList:SetVirtual()
    self.tList.itemRenderer = function(index,obj)
        self:itemRenderer(index, obj)
    end
    self.tList.numItems = 0
    self.tList.onClickItem:Add(self.onItemClickEvent,self)
    --前往按钮
    local btnForward=self.view:GetChild("n8")
    btnForward.onClick:Add(self.onForwardClick,self)
    --坐标
    self.xLabel=self.view:GetChild("n10")
    self.yLabel=self.view:GetChild("n12")

    if g_is_banshu then
        self.view:GetChild("n9").text = "横轴"
        self.view:GetChild("n11").text = "纵轴"
        self.quickBtn:SetScale(0,0)
    end

    --默认值
    local sConf = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    if sConf and sConf["size"] then
        --放大比例
        self.scaleX = sConf["size"][1] / 620
        self.scaleY = sConf["size"][2] / 468
    else
        plog("@当前地图没有配置SID",cache.PlayerCache:getSId())
    end
    self:initDec()
end

function MapView:initDec()
    --仙盟争霸
    self.xmzOurPlayers = {}--我方人员
    self.xmzOtherPlayers = {}--敌方人员
    self.crystalStatues = {}--水晶
    self.camps = {}--阵营
end

function MapView:onForwardClick(context)
    self:onTouchCurMap(nil, {x=tonumber(self.xLabel.text), y=tonumber(self.yLabel.text)})
end
function MapView:onTouchRefresh(context)
    -- body
    self:initControlC2()
end

function MapView:itemRenderer(index, obj)
    local data = self.listData[index + 1]
    local ctrl = obj:GetController("c1")
    local title = obj:GetChild("n3")
    if data.type == -1 or data.type == -2 or data.type == -3 then
        ctrl.selectedIndex = 0
        title.text = data.title
        obj.data = data.type
    elseif data.type == 1 or data.type == 2 or data.type == 3 then
        if data.root == true then
            ctrl.selectedIndex = 1
            title.text = data.title
            obj.data = data.type
        else
            ctrl.selectedIndex = 2
            obj:GetChild("n39").onClick:Add(self.onQuickClick,self)
            if cache.PlayerCache:VipIsActivate(1) and not mgr.FubenMgr:checkScene() then --激活白银仙尊才显示小飞鞋
                obj:GetChild("n39").visible = true
            else
                if cache.PlayerCache:getAttribute(10310) == -1 and not mgr.FubenMgr:checkScene() then
                    obj:GetChild("n39").visible = true
                else
                    obj:GetChild("n39").visible = false
                end
            end
            obj.data = data.id
            if data.type == 1 then
                local mc = conf.MonsterConf:getInfoById(data.id)
                title.text = mc["name"]
            elseif data.type == 2 then
                local nc = conf.NpcConf:getNpcById(data.id)
                title.text = nc["name"]
            elseif data.type == 3 then
                title.text = data.title
            end
        end
    end
end

function MapView:onItemClickEvent(context)
    local t = context.data.data
    if t==1 or t==2 or t==3 then
        self:createListData(0)
    elseif t==-1 or t==-2 or t==-3 then
        self:createListData(-t)
    else
        local config = conf.MonsterConf:getInfoById(t)
        if not config then
            config = conf.NpcConf:getNpcById(t)
        end
        if config then
            self:onTouchCurMap(nil, {x=config.pos[1], y=config.pos[2]})
        end
    end
end

--小飞鞋
function MapView:onQuickClick()
    if g_is_banshu then
        return
    end

    if cache.PlayerCache:VipIsActivate(1) then --小飞鞋显隐控制
    else
        if cache.PlayerCache:getAttribute(10310) == -1 then
            if cache.PlayerCache:getAttribute(10309) > 0 then
            elseif cache.PackCache:getPackDataById(PackMid.feixie).amount > 0 then
            else
                GComAlter(language.gonggong11)
                return
            end
        else
            return
        end
    end
    -- if gRole:getStateID() ~= 5 or gRole.isChangeBody then
    --     if gRole.isChangeBody then
    --         GComAlter(language.gonggong54) 
    --         return
    --     end
    --     --移动过程中才能使用小飞鞋 避免一些地图切换错误
    --     return
    -- end
    if gRole:getStateID() ~= 5 then
        return
    end

    
    
    proxy.ThingProxy:sXiaoFeiXie(self.finalSId, self.finalPos.x, self.finalPos.y)
    self:closeView()
end

--更新当前地图
function MapView:updateCurMap(sId)
    self.finalSId = sId
    local curSId = cache.PlayerCache:getSId()  
    local sConf = conf.SceneConf:getSceneById(sId)
    plog("当前地图ID为：",sId) --EVE 当前地图ID
    local passId = cache.FubenCache:getCurrPass(sId)
    if passId > 0 then
        if mgr.FubenMgr:isJinjie(sId) or mgr.FubenMgr:isVipFuben(sId) or 
           mgr.FubenMgr:isExpFuben(sId) or mgr.FubenMgr:isPlotFuben(sId) or 
           mgr.FubenMgr:isJuqingFuben(sId) or mgr.FubenMgr:isTower(sId) or
           mgr.FubenMgr:isGangFuben(sId) or mgr.FubenMgr:isKuaFuTeamFuben(sId) then--经验、vip、进阶、剧情、爬塔、帮派副本
            sConf = conf.FubenConf:getPassDatabyId(passId)
        end
    end
    -- print("当前地图场景id",sId,curSId,sConf,sConf["map_id"],passId)
    if not sConf then return  end
    if not sConf["size"] then return end
    --放大比例
    self.scaleX = sConf["size"][1] / 620
    self.scaleY = sConf["size"][2] / 468
    if curSId == sId then
        local rolePos = gRole:getPosition()
        self.head.x = rolePos.x / self.scaleX
        self.head.y = rolePos.z / self.scaleY
        self.head.visible=true
    else
        self.head.visible=false
    end
    --地图
    self.curMap.url = "res/maps/s"..sConf["map_id"].."/s"..sConf["map_id"].."_s"
    self.mapName.text = sConf["name"]

    --plog("当前地图名称：",self.mapName.text)   --EVE 当前地图名称

    local index = 1
    --npc
    for i=1,#self.mapNpcs do
        self.mapNpcs[i].visible = false
    end
    if sConf.npc then
        for k,v in pairs(sConf.npc) do
            local npcConf=conf.NpcConf:getNpcById(v)
            if npcConf then
                local npcObj = self.mapNpcs[index]
                if not npcObj then
                    npcObj = UIPackage.CreateObject("map", "npc")
                    table.insert(self.mapNpcs, npcObj)
                    self.detilMap:AddChildAt(npcObj,self.detilMap.numChildren)
                end
                npcObj.visible = true
                npcObj.x=npcConf.pos[1]/self.scaleX
                npcObj.y=npcConf.pos[2]/self.scaleY
                index = index + 1
            end
        end
    end
    --传送 地点
    index = 1
    for i=1,#self.mapTrans do
        self.mapTrans[i].visible = false
    end
    if sConf.transfer then
        for k,v in pairs(sConf.transfer) do
            local npcConf = conf.NpcConf:getNpcById(v)
            if npcConf then
                local doorObj = self.mapTrans[index]
                if not doorObj then
                    doorObj = UIPackage.CreateObject("map", "door")
                    table.insert(self.mapTrans, doorObj)
                    self.detilMap:AddChildAt(doorObj,self.detilMap.numChildren)
                end
                local name = doorObj:GetChild("n2")
                name.text = npcConf.name
                local doorSid = npcConf.to_pos[1]
                local mapGrade = doorObj:GetChild("n1")
                local doorSconf = conf.SceneConf:getSceneById(doorSid)
                mapGrade.text = doorSconf.map_grade
                doorObj.visible = true
                doorObj.x=npcConf.pos[1]/self.scaleX
                doorObj.y=npcConf.pos[2]/self.scaleY
                index = index + 1
            end
        end
    end
    --怪物
    index = 1
    for i=1,#self.mapMons do
        self.mapMons[i].visible = false
    end
    if sConf.monsters then
        local t = clone(sConf.monsters) 
        if mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) then
            --插入青龙白虎。。。boss
            local _ssjtconf = conf.FubenConf:getSSJTref(sId)
            table.insert(t,{
                1,
                _ssjtconf.big_boss_ref[1][1],

            })
        end


        for k,v in pairs(t) do
            local monster = conf.MonsterConf:getInfoById(v[2])
            if monster then
                local monObj = self.mapMons[index]
                if not monObj then
                    monObj = UIPackage.CreateObject("map", "MonsterPanel")
                    local name = monObj:GetChild("n3")
                    name.text = monster.name
                    local lvText = monObj:GetChild("n2")
                    local lv = monster.level or 1
                    local sId = cache.PlayerCache:getSId()
                    if mgr.FubenMgr:isKuafuCityWar(sId) then
                        lvText.text = ""
                    else
                        lvText.text = language.gonggong56..lv
                    end
                    table.insert(self.mapMons, monObj)
                    self.detilMap:AddChildAt(monObj,self.detilMap.numChildren)
                end
                monObj.visible = true
                local name = monObj:GetChild("n3")
                name.text = monster.name
                local lvText = monObj:GetChild("n2")
                local lv = monster.level or 1
                if mgr.FubenMgr:isKuafuCityWar(sId) then
                     lvText.text = ""
                else
                    lvText.text = language.gonggong56..lv
                end
                if monster.pos then
                    monObj.x = monster.pos[1]/self.scaleX
                    monObj.y = monster.pos[2]/self.scaleY
                else
                    print("@策划：怪物配置pos字段没有配")
                end
            end
            index = index + 1
        end
    end

    self:createListData(0)

    self:updateWarMap()
end

--更新世界地图
function MapView:updateWorldMap()
    self.worlddata={}
    local idx=1
    local worldMapConfig=conf.SceneConf:getSceneConf()
    for k,v in pairs(worldMapConfig) do
        if v.map_detail_id then
            local confData=conf.MapConf:getWorldDataById(v.map_detail_id)
            local itemObj = UIPackage.CreateObject("map", "item")
            itemObj.x=confData.pos[1]
            itemObj.y=confData.pos[2]
            self.worldMap:AddChildAt(itemObj,idx)
            itemObj.data={}
            itemObj.data.index=idx
            itemObj.onClick:Add(self.onWorldClick,self)
            self.worlddata[idx]=v
            idx=idx+1
        end
    end
end

--点击小地图寻路
function MapView:onTouchCurMap(context, evt)
    local lpos
    CClearPickView()
    GCancelPick()
    if context then
        evt = context.data
        lpos = self.detilMap:GlobalToLocal(Vector2(evt.x, evt.y))
        self.finalPos = {x = lpos.x*self.scaleX, y = lpos.y*self.scaleY}
        plog(self.finalPos.x,self.finalPos.y)
    else
        self.finalPos = Vector2(evt.x, evt.y)--目标点
        lpos = Vector2(evt.x/self.scaleX, evt.y/self.scaleY)
    end
    local point = Vector3.New(self.finalPos.x, gRolePoz, self.finalPos.y)
    local mId = self.mapId or self.finalSId
    local initSId = 204001
    if mId == initSId and cache.PlayerCache:getSId() ~= initSId then--如果在别的地图选择古剑门
        GComAlter(language.map08)
        return
    end
    local check = UnityMap:CheckCanWalkByMapId(mId,point)--检测目标点是否可走

    if check then
        --local starpos  
        local id = 9002
        local condata = conf.TaskConf:getTaskById(id)
        condata.mapid = self.finalSId
        if self.finalSId == cache.PlayerCache:getSId() then   --self.finalSId是鼠标选中的地图
            ----检测是同一个地图
            --starpos = 
            local path = GameUtil.FindPath(gRole:getPosition(), point) --获取拐点(EVE: 参数1：玩家位置 参数2：终点位置)
            
            --城战特殊处理
            local sConf = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
            local kind = sConf and sConf.kind or 0
            if kind == SceneKind.citywar then
                local gridValue = UnityMap:GetGridValue(point)
                local myGridValue = UnityMap:GetGridValue(gRole:getPosition())
                -- print("地图块类型值",myGridValue,gridValue)
                if myGridValue == 8 and (gridValue == 5 or gridValue == 7) then--城外往城里走
                    local cityStateData = cache.CityWarCache:getCityDoorState()--城门状态
                    if cityStateData == 1 then--已破
                        local dt = 9999
                        for k,v in pairs(sConf.transfer) do
                            local monsterData = cache.CityWarCache:getCityWarTrackData()
                            local transferData = conf.CityWarConf:getTransferData(v)
                            local mData = {}
                            for _,monster in pairs(monsterData) do
                                mData[monster.attris[601]] = true
                            end
                            if not mData[transferData.monsterId] then
                                -- print("怪物ID",transferData.monsterId,v)
                                local confData = conf.NpcConf:getNpcById(v)
                                -- local confData = conf.MonsterConf:getInfoById(transferData.monsterId)
                                if confData then
                                    local pos = Vector3.New(confData.pos[1], gRolePoz, confData.pos[2])
                                    local distance = GMath.distance(gRole:getPosition(), pos)
                                    if distance <= dt then
                                        point = pos
                                        dt = distance
                                        -- print("当前路线",pos,distance)
                                    end
                                end
                            end
                        end
                        path = GameUtil.FindPath(gRole:getPosition(), point)
                    else
                        local dt = 9999
                        for k,v in pairs(sConf.transfer) do
                            local npcData = conf.NpcConf:getNpcById(v)
                            if npcData.type == 10 then
                                --4029 3150   2258 3922  5605 2344
                                -- print("寻找传送阵",npcData.pos[1],npcData.pos[2])
                                pos = Vector3.New(npcData.pos[1], gRolePoz, npcData.pos[2])
                                local distance = GMath.distance(gRole:getPosition(), pos)
                                if distance <= dt then
                                    point = pos
                                    path = GameUtil.FindPath(gRole:getPosition(), point)
                                end
                            end
                        end
                    end
                elseif (myGridValue == 5 or myGridValue == 7) and gridValue == 8 then--城里往城外走
                    local dt = 9999
                    for k,v in pairs(sConf.transfer) do
                        local npcData = conf.NpcConf:getNpcById(v)
                        if npcData.type == 2 then
                            pos = Vector3.New(npcData.pos[1], gRolePoz, npcData.pos[2])
                            local distance = GMath.distance(gRole:getPosition(),pos)
                            if distance <= dt then
                                point = pos
                                dt = distance
                            end
                        end
                    end
                    path = GameUtil.FindPath(gRole:getPosition(), point)
                end
            end

            if path then
                -- print("小地图寻路：", point.x, point.z)                
                self:drawMoveLine(path)
                --便于小飞鞋
                condata.monster_pos = {{point.x,point.z}}
                condata.path = path
                --mgr.JumpMgr:moveByPath(point, path, nil, nil)
            else
                condata.monster_pos = nil
                condata.path = nil
            end
        else
            condata.monster_pos = {{self.finalPos.x,self.finalPos.y}}
        end
        
        if condata.monster_pos then
            mgr.TaskMgr:setCurTaskId(id)
            mgr.TaskMgr.mState = 2 --设置任务标识
            mgr.TaskMgr:resumeTask()
        end

        self.quickBtn.x = lpos.x
        self.quickBtn.y = lpos.y
        if cache.PlayerCache:VipIsActivate(1) then --激活白银仙尊才显示小飞鞋
            self.quickBtn.visible = true
        else
            if cache.PlayerCache:getAttribute(10310) == -1 then
                self.quickBtn.visible = true
            else
                self.quickBtn.visible = false
            end
        end
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:checkScene() then
            if not mgr.FubenMgr:isKuaFuWar(sId) then
                --灵界夺宝，可以用小飞鞋 2018/3/13
                self.quickBtn.visible = false
            end 
            
        end
        self.detilMap:SetChildIndex(self.quickBtn, self.detilMap.numChildren)
      
        -- print("当前目标点可走~~~~~~~~~~~~~~~~~~~")
        if cache.PlayerCache:getSId() == 230001 then
            mgr.TaskMgr:goTaskBy(230001,point) --仙盟驻地寻路
        end
    else
        GComAlter(language.map01)
    end
end

--画移动路径
function MapView:drawMoveLine(path)
    for i=1,#self.lineList do
        self.lineList[i].visible = false
    end
    local sPoint = gRole:getPosition()
    local function line(ax,ay,bx,by,index)
        local line
        if self.lineList[index] then
            line = self.lineList[index]
            line.visible = true
        else
            line = UIPackage.CreateObject("map" , "ditu_line_022")--创建线
            table.insert(self.lineList, line)
        end
        self.detilMap:AddChildAt(line,1)
        local x = bx - ax  
        local y = by - ay
        local angle = math.atan2(y,x)*180/math.pi 
        local distance = math.sqrt(math.pow(y,2)+math.pow(x,2))
        line.width = distance
        line.x = ax
        line.y = ay
        line.rotation = angle
    end
    line(sPoint.x/self.scaleX, sPoint.z/self.scaleY, path[0].x/self.scaleX, path[0].y/self.scaleY,1)
    if path.Count > 1 then
        for i=1, path.Count-1 do
            line(path[i-1].x/self.scaleX, path[i-1].y/self.scaleY,path[i].x/self.scaleX,path[i].y/self.scaleY,i+1)
        end
    end
end

function MapView:updateTimer()
    local rolePos = gRole:getPosition()
    self.head.x = math.floor(rolePos.x) / self.scaleX   --EVE 地图坐标优化为为向下取整
    self.head.y = math.floor(rolePos.z) / self.scaleY

    --EVE 如果角色到达目的地，则清除寻路路线和小飞鞋(玩家状态：没有跑并且没有跳时，判定为到达目的地)
    if gRole:getStateID() ~= 5 and gRole:getStateID() ~= 6 then
        self:setLine(false)
    end
    
    self:updateWarMapInfo()
end
--刷新战斗小地图
function MapView:updateWarMapInfo()
    local refTime = 1
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isGangWar(sId) then
        refTime = conf.XmhdConf:getValue("map_ref_time")
    end
    if (self.warRefTime == 0 or Time.getTime() - self.warRefTime >= refTime) and self.mapSendFunc then
        self.mapSendFunc()
        self.warRefTime = Time.getTime()
    end
end

--t=0收起来，1怪物， 2npc，3传送阵
function MapView:createListData(t)
    self.listData = {}
    local sConf = conf.SceneConf:getSceneById(self.finalSId)
    if t == 0 then
        self.listData[1] = {title="怪物", type=-1, root=true, id=0}
        self.listData[2] = {title="NPC", type=-2, root=true, id=0}
        if g_is_banshu then
            self.listData[2].title = "非玩家角色"
        end
        self.listData[3] = {title="传送阵", type=-3, root=true, id=0}
    elseif t == 1 then
        table.insert(self.listData, {title="怪物", type=1, root=true, id=0})

        if mgr.FubenMgr:getJudeWarScene(self.finalSId,SceneKind.shenshoushengyu) then
            --插入青龙白虎。。。boss
            local _ssjtconf = conf.FubenConf:getSSJTref(self.finalSId)
            table.insert(self.listData, {title="怪物", type=1, root=false, id=_ssjtconf.big_boss_ref[1][1]})
        end


        if sConf.monsters then
            for k,v in pairs(sConf.monsters) do
                table.insert(self.listData, {title="怪物", type=1, root=false, id=v[2]})
            end
        end
        table.insert(self.listData, {title="NPC", type=-2, root=true, id=0})
        table.insert(self.listData, {title="传送阵", type=-3, root=true, id=0})
    elseif t == 2 then
        table.insert(self.listData, {title="怪物", type=-1, root=true, id=0})
        table.insert(self.listData, {title="NPC", type=2, root=true, id=0})
        if sConf.npc then  
            for k,v in pairs(sConf.npc) do 
                if conf.NpcConf:getNpcById(v).name then  --EVE 过滤没名字的NPC       
                    table.insert(self.listData, {title="NPC", type=2, root=false, id=v})
                end 
            end
        end
        table.insert(self.listData, {title="传送阵", type=-3, root=true, id=0})
    elseif t == 3 then
        table.insert(self.listData, {title="怪物", type=-1, root=true, id=0})
        table.insert(self.listData, {title="NPC", type=-2, root=true, id=0})
        table.insert(self.listData, {title="传送阵", type=3, root=true, id=0})
        if sConf.transfer then
            for k,v in pairs(sConf.transfer) do
                table.insert(self.listData, {title="传送阵", type=2, root=false, id=v})
            end
        end
    end
    self.tList.numItems = #self.listData

    -- plog("当前地图列表：")
    -- printt(self.listData)
end

function MapView:dispose(clear)
    self.mapTimer = nil
    for i=1,#self.lineList do
        self.lineList[i].visible = false
    end
    self.quickBtn.visible = false
    self.super.dispose(self, clear)
end

--EVE 世界大地图逻辑
--读取地图配置表
function MapView:getConfData()
    local tempList = conf.SceneConf:getSceneIdAll()
    return tempList
end
--根据地图id获取地图的最低进入等级
function MapView:getEnterMapMinGradeByMapId(mapId)
    local tempTable =self:getConfData()
    local tempTablelength = #tempTable

    for i = 1,tempTablelength do
        local tempGradeList = string.split(tempTable[i].map_grade, "-")
        local tempMapId = tempTable[i].map_id
        if mapId == tempMapId then
            return tempGradeList[1]
        end
    end
end
--世界地图中选择小地图
function MapView:onControlChangeScene()
    local tempCurSceneId = cache.PlayerCache:getSId()       --EVE 当前场景Id缓存
    local tableScenesId = self:getConfData()                --获得地图id
    local playerLevel = cache.PlayerCache:getRoleLevel()    --获得玩家等级

    for k,v in pairs(tableScenesId) do
        if self.controlC2.selectedIndex == k - 1 and v.map_id ~= tempCurSceneId then
            local minMapGrade = self:getEnterMapMinGradeByMapId(v.map_id)
            if playerLevel < tonumber(minMapGrade) then
                GComAlter(language.map04)
                return
            end
            self.control.selectedIndex = 0   
            self:updateCurMap(v.map_id)
            self.mapId = v.map_id
            UnityMap:LoadMapData(tonumber(v.map_id)) --加载地图数据

            if self.finalSId ~= tempCurSceneId then
                -- 切换到其他地图时，清除寻路路线
                self:setLine(false)
            else
                -- 切换回本地图，重新绘线
                self:setLine(true)
            end             
        end
    end
end
--当位于副本中时，提示无法使用世界地图
function MapView:onControlChange()
    local isCanUse = mgr.FubenMgr:checkScene()  --是副本时，checkScene()返回true
    if isCanUse then
        if self.control.selectedIndex == 1 then
            self.control.selectedIndex = 0
            GComAlter(language.map05)
        end
    else
        if self.control.selectedIndex == 0 then
            if self.finalSId ~= cache.PlayerCache:getSId() then
                self.finalSId = cache.PlayerCache:getSId()
                self:updateCurMap(self.finalSId)
                self.mapId = self.finalSId
            end
        else
            self:initControlC2()
        end
    end
end
--设置寻路路线和小飞鞋的显示/隐藏
function MapView:setLine(isShow)
    for i=1,#self.lineList do
        self.lineList[i].visible = isShow
    end
    self.quickBtn.visible = isShow
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:checkScene() then
        self.quickBtn.visible = false
    end
end
--世界地图控制器初始化指向当前地图
function MapView:initControlC2()
    local temptable = self:getConfData()
    local curSceneId = cache.PlayerCache:getSId()   --获得地图id
    for k,v in pairs(temptable) do
        if curSceneId == tonumber(v.map_id) then
            self.controlC2.selectedIndex = k - 1
        end
    end
end
--世界地图界面，初始化地图名称和等级区间
function MapView:initMapNameAndMapGrade(tempPanel) 
    local getNameAndGrade = self:getConfData()
    
    local counter = 1 
    for i=1, 14 do
        local mapData = getNameAndGrade[counter]  --EVE 注意这种写法：做判断时，a[x]和a[x].b使用的区别！

        local iconMapName = 15 + i
        local mapName = tempPanel:GetChild("n".. iconMapName)
        if mapData and mapData.name_icon then
            mapName.url = UIPackage.GetItemURL("map", mapData.name_icon)
        end

        local numMapGrade = 299 + i
        self.mapGrade = tempPanel:GetChild("n".. numMapGrade)
        self.mapGrade.onClick:Add(self.btnMapClickEvent,self)
        if mapData and mapData.map_grade then
            self.mapGrade.text = mapData.map_grade      
        end

        counter = counter + 1  
    end
end

--部分战斗地图需要实时知道信息的
function MapView:updateWarMap()
    local sId = cache.PlayerCache:getSId()
    self.mapSendFunc = nil--请求的方法
    local sConf = conf.SceneConf:getSceneById(sId)
    if mgr.FubenMgr:isGangWar(sId) or mgr.FubenMgr:isPlayoffPaiWeiSai(sId) 
    or mgr.FubenMgr:isTeamPaiWeiSai(sId) or mgr.FubenMgr:isPaiWeiSai(sId) then--仙盟战和排位赛季后赛
        local campBorn = sConf and sConf.born or {}
        if campBorn then
            local warData = cache.XmzbCache:getTrackData()
            local campType = warData and warData.campType or 1--我方阵营位置下标
            local OURCAME,OTHERCAME = 1,2--记录自己的阵营位置下标
            if campType == 1 then
                OURCAME,OTHERCAME = 1,2
            else
                OURCAME,OTHERCAME = 2,1
            end
            local OUR,OTHER = 1,2--记录自己阵营对象

            if not self.camps[OUR] then--我方阵营
                self.camps[OUR] = self:createObj()
                self.detilMap:AddChildAt(self.camps[OUR],self.detilMap.numChildren)
            end
            self.camps[OUR].icon = UIItemRes.xmhd04[1]
            local pos = campBorn[OURCAME]
            self.camps[OUR].x = pos[1] / self.scaleX
            self.camps[OUR].y = pos[2] / self.scaleY

            if not self.camps[OTHER] then--敌方阵营
                self.camps[OTHER] = self:createObj()
                self.detilMap:AddChildAt(self.camps[OTHER],self.detilMap.numChildren)
            end
            self.camps[OTHER].icon = UIItemRes.xmhd04[2]
            local pos = campBorn[OTHERCAME]
            self.camps[OTHER].x = pos[1] / self.scaleX
            self.camps[OTHER].y = pos[2] / self.scaleY
            if sConf.pendant then
                for k,v in pairs(sConf.pendant) do
                    local pendantId = v[1]
                    local crystalStatue = self.crystalStatues[pendantId]
                    if not crystalStatue then
                        crystalStatue = self:createObj()
                        crystalStatue.icon = ""
                        self.crystalStatues[pendantId] = crystalStatue
                        self.detilMap:AddChildAt(crystalStatue,self.detilMap.numChildren)
                    end
                    crystalStatue.x = v[2] / self.scaleX
                    crystalStatue.y = v[3] / self.scaleY
                end
            end
            if not mgr.FubenMgr:isGangWar(sId) then
                self.camps[OUR].visible = false
                self.camps[OTHER].visible = false
            end
        end
        self.mapSendFunc = function()
            if mgr.FubenMgr:isGangWar(sId) then
                proxy.XmhdProxy:send(1360205)
            elseif mgr.FubenMgr:isPlayoffPaiWeiSai(sId) then
                proxy.QualifierProxy:sendMsg(1480304)
            elseif mgr.FubenMgr:isTeamPaiWeiSai(sId) then
                proxy.QualifierProxy:sendMsg(1480214)
            elseif mgr.FubenMgr:isPaiWeiSai(sId) then
                proxy.QualifierProxy:sendMsg(1480108)
            elseif mgr.FubenMgr:isXianLvPKhxs(sId) or mgr.FubenMgr:isXianLvPKzbs(sId) then
                proxy.XianLvProxy:sendMsg(1540110)
            elseif mgr.FubenMgr:isXianLvPKhxs_2(sId) or mgr.FubenMgr:isXianLvPKzbs_2(sId) then
                proxy.XianLvProxy:sendMsg(1540210)
            end
        end
    else
        for i=1,#self.xmzOurPlayers do
            self.xmzOurPlayers[i].visible = false
        end
        for i=1,#self.xmzOtherPlayers do
            self.xmzOtherPlayers[i].visible = false
        end
        for k,v in pairs(self.crystalStatues) do
            v.visible = false
        end
        for i=1,#self.camps do
            self.camps[i].visible = false
        end
    end
end

--更新仙盟争霸地图
function MapView:updateXmzbMap(data)
    --我方人员
    for k,v in pairs(self.xmzOurPlayers) do
        v.visible = false
    end
    for k,v in pairs(data.ourPos) do
        local player = self.xmzOurPlayers[k]
        if not player then
            player = self:createObj()
            player.icon = UIItemRes.xmhd05[1]
            table.insert(self.xmzOurPlayers, player)
            self.detilMap:AddChildAt(player,self.detilMap.numChildren)
        end
        player.visible = true
        player.x = v.pox / self.scaleX
        player.y = v.poy / self.scaleY
    end
    --敌方人员
    for k,v in pairs(self.xmzOtherPlayers) do
        v.visible = false
    end
    for k,v in pairs(data.otherPos) do
        local player = self.xmzOtherPlayers[k]
        if not player then
            player = self:createObj()
            player.icon = UIItemRes.xmhd05[2]
            table.insert(self.xmzOtherPlayers, player)
            self.detilMap:AddChildAt(player,self.detilMap.numChildren)
        end
        player.visible = true
        player.x = v.pox / self.scaleX
        player.y = v.poy / self.scaleY
    end
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isGangWar(sId)  then
        local trackData = cache.XmzbCache:getTrackData()
        for k,v in pairs(self.crystalStatues) do
            local state = trackData.crystalStatusMap[k] or 0
            v.icon = UIItemRes.xmhd03[state]
        end
    end
end

function MapView:createObj()
    return UIPackage.CreateObject("map", "ThingObj")
end
--修复BUG：1)第二次点击世界地图时，无法自动切换到当前地图
--         2)重复点击不可进入的地图，不会再次弹出提示窗
function MapView:btnMapClickEvent()
    self:onControlChangeScene()
end
--EVE END

return MapView