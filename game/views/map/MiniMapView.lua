--
-- Author: 
-- Date: 2017-12-12 14:33:41
--

local MiniMapView = class("MiniMapView", base.BaseView)

local scale1 = 0.245
local scale2 = 0.5
local X1 = 983
local X2 = 825

function MiniMapView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level0 
    self.lineList = {} --线列表
    --仙盟争霸
    self.xmzOurPlayers = {}--我方人员
    self.xmzOtherPlayers = {}--敌方人员
    self.crystalStatues = {}--水晶
    self.camps = {}--阵营
    self.warRefTime = 0--记录战斗地图刷新时间
end

function MiniMapView:initView()
    self.detilMap = self.view:GetChild("n0")
    self.detilMap.onTouchBegin:Add(self.onTouchCurMap,self)
    self.curMapBg = self.detilMap:GetChild("n0")
    self.head = self.detilMap:GetChild("n1")
    local scaleBtn = self.view:GetChild("n1")
    self.scaleBtn = scaleBtn
    scaleBtn.onClick:Add(self.onClickScale,self)
    self:setDetilMapScale(scale1,X1)
end

function MiniMapView:initData()
    self.finalSId = cache.PlayerCache:getSId() 
    self.mapId = cache.PlayerCache:getMapModelId() 
    local sConf = conf.SceneConf:getSceneById(self.finalSId)
    local map_id = sConf["map_id"] or 0
    self.curMapBg.url = "res/maps/s"..map_id.."/s"..map_id.."_s"
    if sConf and sConf["size"] then--放大比例
        self.scaleX = sConf["size"][1] / 620
        self.scaleY = sConf["size"][2] / 468
    else
        plog("@当前地图没有配置SID",cache.PlayerCache:getSId())
    end
    self:updateWarMap()
    self:updateTimer()
    self.head.visible = true
    self:addTimer(0.5,-1,handler(self, self.updateTimer))
end

function MiniMapView:updateTimer()
    local rolePos = gRole:getPosition()
    self.head.x = math.floor(rolePos.x) / self.scaleX
    self.head.y = math.floor(rolePos.z) / self.scaleY

    if gRole:getStateID() ~= 5 and gRole:getStateID() ~= 6 then
        self:setLine(false)
    end
    --刷新战斗小地图
    local refTime = 1
    if mgr.FubenMgr:isGangWar(self.finalSId) then
        refTime = conf.XmhdConf:getValue("map_ref_time")
    end
    if (self.warRefTime == 0 or Time.getTime() - self.warRefTime >= refTime) and self.mapSendFunc then
        self.mapSendFunc()
        self.warRefTime = Time.getTime()
    end
end

function MiniMapView:setLine(isShow)
    for i=1,#self.lineList do
        self.lineList[i].visible = isShow
    end
end

--部分战斗地图需要实时知道信息的
function MiniMapView:updateWarMap()
    local sId = self.finalSId
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

--点击小地图寻路
function MiniMapView:onTouchCurMap(context)
    local lpos
    CClearPickView()
    GCancelPick()
    local finalPos = {}
    local evt = context.data
    lpos = self.detilMap:GlobalToLocal(Vector2(evt.x, evt.y))
    finalPos = {x = lpos.x * self.scaleX, y = lpos.y * self.scaleY}
    local point = Vector3.New(finalPos.x, gRolePoz, finalPos.y)
    local check = UnityMap:CheckCanWalkByMapId(self.mapId,point)--检测目标点是否可走
    if check then 
        local id = 9002
        local confData = conf.TaskConf:getTaskById(id)
        confData.mapid = self.finalSId
        local path = GameUtil.FindPath(gRole:getPosition(), point) 
        if path then
            -- print("小地图寻路：", point.x, point.z)                
            self:drawMoveLine(path)
            --便于小飞鞋
            confData.monster_pos = {{point.x,point.z}}
            confData.path = path
            --mgr.JumpMgr:moveByPath(point, path, nil, nil)
        else
            confData.monster_pos = nil
            confData.path = nil
        end

        if confData.monster_pos then
            mgr.TaskMgr:setCurTaskId(id)
            mgr.TaskMgr.mState = 2 --设置任务标识
            mgr.TaskMgr:resumeTask()
        end
    else
        GComAlter(language.map01)
    end
end

--画移动路径
function MiniMapView:drawMoveLine(path)
    self:setLine(false)
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
        self.detilMap:AddChildAt(line,2)
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

--更新仙盟争霸地图
function MiniMapView:updateXmzbMap(data)
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

function MiniMapView:setDetilMapScale(scale,x)
    self.detilMap.scaleX = scale
    self.detilMap.scaleY = scale
    self.detilMap.x = x
    self.mapScale = scale
    if scale == scale1 then
        self.scaleBtn.icon = UIItemRes.map01[1]
    else
        self.scaleBtn.icon = UIItemRes.map01[2]
    end
end

function MiniMapView:onClickScale()
    if self.mapScale == scale1 then
        self:setDetilMapScale(scale2,X2)
    else
        self:setDetilMapScale(scale1,X1)
    end
end

function MiniMapView:createObj()
    return UIPackage.CreateObject("bangpai", "ThingObj")
end

function MiniMapView:dispose(clear)
    self:setDetilMapScale(scale1,X1)
    self:setLine(false)
    self.super.dispose(self, clear)
end

return MiniMapView