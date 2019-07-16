--[[--
 怪物
]]

local Monster = class("Monster", import(".Thing"))

function Monster:ctor()
    self.headHeight = StaticVector3.monsterHeadH
    self.headRes = "HeadView2"
    self.tType = ThingType.monster
    self.character = UnityObjMgr:CreateThing(self.tType)
    self:setCanSelect(true)
    self:createHeadBar()
    self.fly = 0
    self.bodySrc = nil
    self.isAppear = false
    self._cs = nil 
    --额外添加组件
    self.components = {}
end
-- 4010611
function Monster:setData(data)
    self.data = data
    local mConf = nil
    self.bodySrc = nil
    if data.kind == MonsterKind.collection 
    or data.kind == MonsterKind.sjchest 
    or data.kind == MonsterKind.tcollection 
    or data.kind == MonsterKind.ssjtcsm then --采集物从NPC配表读取
        mConf = conf.NpcConf:getNpcById(data.mId)
        self.bodySrc = mConf["body_id"]
    elseif data.kind == MonsterKind.crystal then--水晶
        mConf = conf.NpcConf:getNpcById(data.mId)
        self:updateCrystalSkin()
    else
        mConf = conf.MonsterConf:getInfoById(data.mId)
        self.bodySrc = mConf["src"]
    end
    self.mConf = mConf
    self:setID(data.roleId)
    self:setPosition(data.pox, data.poy)
    if data.kind == MonsterKind.skill then--boss技能
        self.bodySrc = nil
        local parent, scale, epos
        local effectId = mConf and mConf.warn_id or 0
        local effectConf = conf.EffectConf:getEffectById(effectId.."")
        if effectConf["layer"] == 7 then
            parent = UnitySceneMgr.pStateTransform
            scale = Vector3.New(80,80,80)
            epos = Vector3.New(data.pox, -1500, data.poy)
        else
            parent = self:getRoot()
            scale = Vector3.one
            epos = Vector3.zero
        end
        local effect = mgr.EffectMgr:playCommonEffect(effectId, parent)
        local rotation = data.attris[602]
        if rotation then
            effect.LocalRotation = Vector3.New(0,90 - rotation,0)
            effect.Scale = scale
            effect.LocalPosition = epos
        end
    elseif data.kind == MonsterKind.ssjtcsm then--传送门
        self.transfer = mgr.EffectMgr:playCommonEffect(tonumber(self.bodySrc), UnitySceneMgr.pStateTransform)
        local rotate = StaticVector3.vector3X60 + StaticVector3.vector3Z180
        self.transfer.LocalRotation = rotate
        self.transfer.Scale = StaticVector3.scaleXYZ80
        self.transfer.LocalPosition = Vector3.New(data.pox, -1500, data.poy)

        self.bodySrc = nil
    end
    --print("data.mId",mConf.kind)
    --是否可被攻击
    if data.kind == MonsterKind.chest 
    or data.kind == MonsterKind.collection 
    or data.kind == MonsterKind.skill  
    or data.kind == MonsterKind.sjchest 
    or data.kind == MonsterKind.sjmonster 
    or data.kind == MonsterKind.crystal
    or data.kind == MonsterKind.ssjtcsm then--宝箱和采集物
        -- if data.kind == MonsterKind.ssjtcsm then
        --     print("传送门",self.mConf.name)
        -- end

        if MonsterKind.sjchest == data.kind then
            self:setVisible(false)
        end

        self:setCanSelect(false)
        self:ignoreHide(true)
    elseif data.kind == 0 then
        if mConf.kind == 4 or  mConf.kind == 5 or mConf.kind == MonsterKind.homedog  then--防御塔
            self:setCanSelect(false)
        end
    elseif data.kind == MonsterKind.tcollection then--瞬间采集物
        self:setCanSelect(false)
        self:ignoreHide(true)
        mgr.PickMgr:addCollection(self)
    else
        self:setCanSelect(true)
    end
    --==============配置字段属性===================
    if mConf["dead_fly"] then
        self.fly = mConf["dead_fly"]
    end
    if mConf["rotation"] then
        self.fixDir = 1
    end
    --名字高度
    if mConf["height"] then
        self.headHeight = Vector3.New(0,-mConf["height"],0)
        self.headBar.position = self.headHeight
    end
    if mConf["bottom_effect"] then
        self:addBottomEffect(mConf["bottom_effect"])
    end
    --添加组件
    self:createHead()
    local name = self.headBar:GetChild("n6")
    local icon = self.headBar:GetChild("n7")
    local isVisible = mConf and mConf["display_name"] or 0
    icon.visible = false
    if isVisible == 1 then
        local typeIcon = mConf and mConf.type_icon or ""
        if typeIcon ~= "" then
            icon.visible = true
            icon.url = UIPackage.GetItemURL("head" , typeIcon)
        else
            icon.visible = false
        end
        name.visible = true
        local monsterName = mConf and mConf.name or ""
        local lvl = mConf and mConf.level or ""
        name.text = monsterName.." Lv"..lvl
        if mgr.FubenMgr:isCollectTreasure(cache.PlayerCache:getSId()) and data.kind == MonsterKind.collection then
            name.text = monsterName
        end
        if data.kind == MonsterKind.sjchest or MonsterKind.ssjtcsm then
            name.text = monsterName
        end
        if mgr.FubenMgr:isWanShenDian(cache.PlayerCache:getSId()) and data.kind == MonsterKind.collection then
            local roleName = cache.PlayerCache:getRoleName()
            if data.name and data.name ~= "" and data.name == roleName then
                name.text = mgr.TextMgr:getTextColorStr(monsterName .. language.wanshendian01, 4)
            else
                name.text = mgr.TextMgr:getTextColorStr(monsterName .. language.wanshendian02, 14)
            end
        end
        
    else
        name.visible = false
    end
    
    if data.attris then
        self:setMaxHp(data.attris[105] or 100)
        self:setHp(data.attris[104] or 100)
        if data.attris[610] then
            -- print("111111111111酒桌",data.mId)
            if data.mId then
                local collectedData = conf.NpcConf:getNpcById(data.mId)
                -- print("22222酒桌",data.attris[610],collectedData.max_collect_count)
                if collectedData.max_collect_count then
                    name.text = data.attris[610] .."/" .. collectedData.max_collect_count
                    name.visible = true
                end
            end
        end
    else
        self:setMaxHp(100)
        self:setHp(100)
    end
    self:judeCopper()
    self:bossHpView()

    if not self.timer then
        local attris603 = data.attris and data.attris[603] or 0
        if attris603 > 0 or mConf.dialog_desc or self.data.kind == MonsterKind.ssjtcsm then
            self.timer = mgr.TimerMgr:addTimer(1, -1, handler(self, self.update), "Monster")
            self.stateTime = os.time()
        end
    end 
end
--改变水晶的外观 isStie是否设置外观
function Monster:updateCrystalSkin(isSite)
    local mConf = conf.NpcConf:getNpcById(self.data.mId)
    self.bodySrc = mConf and mConf.body_id or ""
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isGangWar(sId) then
        local data = cache.XmzbCache:getTrackData()
        if data then
            local crystalSkins = conf.XmhdConf:getValue("crystal_skins")
            local index = data.crystalStatusMap[self.data.mId]
            self.bodySrc = crystalSkins[index] or self.bodySrc
        end
    end
    if isSite then
        if not self.oldBodySrc or self.oldBodySrc ~= self.bodySrc then
            self:setSkins(self.bodySrc)
        end
    end
end

function Monster:addBottomEffect(id)
    -- body
    self.bottomEffectID = id
    if self.bottomEffect then
        mgr.EffectMgr:removeEffect(self.bottomEffect)
    end
    local bodyTransform = self.character.mRoot.mTransform
    self.bottomEffect = mgr.EffectMgr:playCommonEffect(id, bodyTransform)
    self.bottomEffect.LocalRotation = StaticVector3.vector3Z180
    self.bottomEffect.Scale = Vector3.one
end

function Monster:update()
    -- body
    if self.data.kind == MonsterKind.ssjtcsm and gRole then
        --检测任务是否到了传送阵附近
        --print(GMath.distance(gRole:getPosition(),self:getPosition()))
        if GMath.distance(gRole:getPosition(),self:getPosition()) <= 100 and not self._cs then
            self._cs = true
            --print("到了传送阵附近 开始传送",self.data.roleId)

            proxy.ThingProxy:sChangeScene(self.mConf.map_id,0,0,3,cache.PlayerCache:getSId() )
        end
    end


    if self.components["speak"] then--头领讲话时间机制
        if self.mConf.dialog_keepTime then
            local var = os.time() - self.stateTime
            local ss = self.mConf.dialog_keepTime[1]+self.mConf.dialog_keepTime[2]
            local cc = var%ss
            --print(var,cc,self.mConf.dialog_keepTime[1])
            if tonumber(cc) <= tonumber(self.mConf.dialog_keepTime[1]) then
                self.components["speak"].visible = true
            else
                self.components["speak"].visible = false
            end
        else
            local time = conf.FubenConf:getValue("mj_monster_speak_time")
            if os.time() - self.stateTime >= time then
                self.components["speak"]:Dispose()
                self.components["speak"] = nil 
            end
        end 
    end
    
    if not self.data or not self.data.attris then
        return
    end
    if not self.data.attris[603] then
        return
    end

    self.data.attris[603] = self.data.attris[603] - 1

    if self.components["sjchest"] then
        local title = self.components["sjchest"]:GetChild("n0")
        if title then
            if self.data.attris[603] > 0 then
                title.text = GTotimeString(self.data.attris[603])
            else
                title.text = ""
            end
        end
    end

end

function Monster:createHead()
    -- body
    self:clearComponents()

    local kind = self.data and self.data.kind or 0
    
    if kind == MonsterKind.sjchest then--三界争霸箱子
        if not self.components["sjchest"] then
            local component = UIPackage.CreateObject("head" , "Component1")
            local title = component:GetChild("n0")
            title.text = ""

            component.x = (self.headBar.width -  component.width)/2
            component.y = self.headBar.height - component.height
        
            self.headBar:AddChild(component)
            self.components["sjchest"] = component 
        end
    elseif kind == MonsterKind.sjmonster then --三界争霸的车子
        if not self.components["sjche"] then
            local component = UIPackage.CreateObject("head" , "Component2")
            local title = component:GetChild("n1")
            
            --需要区分是否本服
            if self.data.attris[604] and self.data.attris[604] == cache.PlayerCache:getServerId() then
                title.text = self.mConf.name
            else
                --plog("self.data.attris[604]",self.data.attris[604])
                title.text = mgr.TextMgr:getTextColorStr(self.mConf.name, 14) 
            end

            component.x = (self.headBar.width -  component.width)/2
            component.y = self.headBar.height - component.height - 80
        
            self.headBar:AddChild(component)
            self.components["sjche"] = component 
        end
    elseif kind == 0 then
        if self.mConf.kind == 4 or  self.mConf.kind == 5 then--防御塔--
            if self.mConf["iconname"] then
                if not self.components["fxt"] then
                    local component = UIPackage.CreateObject("head" , "Component3")
                    local title = component:GetChild("n1")
                    title.url = ResPath.titleRes(self.mConf["iconname"]) 
                    component.x = (self.headBar.width -  component.width)/2
                    component.y = self.headBar.height - component.height - 130
                
                    self.headBar:AddChild(component)
                    self.components["fxt"] = component
                end
            end
        end
    end
    if self.mConf.dialog_desc then--怪物对话
        if not self.components["speak"] then
            local component = UIPackage.CreateObject("head" , "SpeakItem")
            component.x = self.headBar.width - 20
            component.y = self.headBar.height + 20
            component:GetChild("n1").text = self.mConf.dialog_desc
        
            self.headBar:AddChild(component)
            self.components["speak"] = component
        end
    end
end

--设置外部
function Monster:setSkins(body)
    if body then
        local resPath = ResPath.monsterRes(body)
        self.character.BodyID = resPath
        cache.ResCache:addMonsterCache(resPath)
    end
    self.oldBodySrc = self.bodySrc
    self.isAppear = true
end

--显示
function Monster:appear()
    if not self.isAppear then
        self:setSkins(self.bodySrc)
    end
end

--死亡效果
function Monster:deadFly(killId, fly)
    if self.data then
        local kind = self.data.kind
        if kind == MonsterKind.collection or kind == MonsterKind.chest 
        or kind == MonsterKind.sjchest then --宝箱和采集物 
            self.fly = 1
        elseif kind == MonsterKind.skill then--死亡爆炸
            self.fly = 1
        end
        if kind ~= MonsterKind.skill and mgr.FubenMgr:isFuben(cache.PlayerCache:getSId()) then
            GCloseBossHpView()
        end
    end

    
    self.super.deadFly(self, killId, self.fly)
end

--打开血条界面
function Monster:bossHpView()
    local data = self.data
    local mConf = conf.MonsterConf:getInfoById(self.data.mId)
    if mConf and (mConf.kind == 2 or mConf.kind == 3) then--如果是boss
        local view = mgr.ViewMgr:get(ViewName.BossHpView)
        local refFunc = function()--假显示血条
            if view then
                view:setBossRoleId(data.roleId)
                view:setHideHate()
                view:setAttisData2(data.attris,self.data.mId)
            else
                mgr.ViewMgr:openView(ViewName.BossHpView, function(view)
                    view:setBossRoleId(data.roleId)
                    view:setHideHate()
                    view:setAttisData2(data.attris,self.data.mId)
                end,data)
            end
        end
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isFuben(sId) or  
            mgr.FubenMgr:isDujieFuben(sId) or
            mgr.FubenMgr:isQingYuanFuben(sId) then--野外和副本
            if not mgr.FubenMgr:isYuanDanTanSuo(sId) then
                refFunc()
            end
        elseif mgr.FubenMgr:isKuaFuTeamFuben(sId) or mgr.FubenMgr:isKuaFuWar(sId) then --跨服三界boss--跨服组队副本
            if not view then
                mgr.ViewMgr:openView(ViewName.BossHpView, function(view)
                    view:setBossRoleId(data.roleId)
                    view:setAttisData(data.attris)
                end,data)
            end
        elseif mgr.FubenMgr:isWorldBoss(sId) 
            or mgr.FubenMgr:isBossHome(sId) 
            or mgr.FubenMgr:isXianyuJinDi(sId) 
            or mgr.FubenMgr:isKuafuWorld(sId)
            or mgr.FubenMgr:isKuafuXianyu(sId) then
            if mConf.kind == 2 then---针对精英怪
                local distance = GMath.distance(gRole:getPosition(), self:getPosition())
                if distance <= 700 then
                    refFunc()
                else
                    GCloseBossHpView()
                end
            end
        else
            if self.mConf.show_hp and self.mConf.show_hp == 1 then
                return
            end
            local sceneData = conf.SceneConf:getSceneById(sId)
            local kind = sceneData and sceneData.kind or 0
            if kind == SceneKind.mainCity 
                or kind == SceneKind.field 
                or kind == SceneKind.xinshou then
                if view then
                    view:close()
                end
            end
        end
    end
end

function Monster:getMId()
    return self.data and self.data.mId
end

function Monster:getAttris()
    return self.data and self.data.attris
end

function Monster:setHp(hp)
    self.super.setHp(self, hp)
    self.data.attris[104] = hp
    local mConf = conf.MonsterConf:getInfoById(self.data.mId)
    if self.hp == self.maxHp or (mConf and mConf.kind == 3 or mConf.kind == 7 or mConf.kind == 10 or mConf.kind == 11) then
        self.bloodBar.visible = false
        if mgr.FubenMgr:isCollectTreasure(cache.PlayerCache:getSId()) and mConf and mConf.kind == 3 then
            self.bloodBar.visible = true
        end
    else
        self.bloodBar.visible = true
    end
    self:bossHpView()
    self:checkHp()
end
--判断是不是铜钱副本
function Monster:judeCopper()
    local sId = cache.PlayerCache:getSId()
    if sId == Fuben.copper then
        self.character.mModel.LocalRotation = Vector3.New(30,0,0)
    else
        if self.data and self.data.angle then
            self.character.mModel.LocalRotation = Vector3.New(0,self.data.angle,0)
        end
    end
end

function Monster:clearComponents()
    -- body
    --移除多余添加控件
    for k ,v in pairs(self.components) do
        v:Dispose()
        self.components[k] = nil 
    end
end

function Monster:dispose()
    -- body
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
    self._cs = nil 
    if self.bottomEffect then
        mgr.EffectMgr:removeEffect(self.bottomEffect)
        self.bottomEffect = nil
    end
    if self.transfer then
        mgr.EffectMgr:removeEffect(self.transfer)
    end
    
    self:clearComponents()
    

    self:checkDispose()
    
    self.super.dispose(self)
end

--检测血条 雷士人物血条
function Monster:checkHp()
    -- body
    local view = mgr.ViewMgr:get(ViewName.KuaFuCheHpView)
    if view then
        view:checkHp(self.data)
    end
end

function Monster:checkDispose()
    -- body
    local view = mgr.ViewMgr:get(ViewName.KuaFuCheHpView)
    if view then
        view:checkDispose(self.data)
    end
end

return Monster