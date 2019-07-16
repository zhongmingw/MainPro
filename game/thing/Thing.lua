--[[--
  事物基类
]]

local Thing = class("Thing")
local language_pos = {
    language.bangpai47,
    language.bangpai04,
    language.bangpai03,
    language.bangpai02,
    language.bangpai01,
}
function Thing:ctor()
    self.tID = 0
    self.tType = ThingType.thing
    self.character = nil   --角色
    --头顶panel
    self.headRes = "HeadView"
    self.headBar = nil
    self.bloodBar = nil
    self.headHeight = StaticVector3.playerHeadH
    --角色数据
    self.titleName = ""
    self.sex = -1
    self.hp = 0
    self.maxHp = 0
    self.deadTime = 0
    self.skins = nil
    self.data = nil
    self.isChangeBody = false
    self.isVisibleChenghao = true
    self.pkState = PKState.peace
    self.fixState = 0
    self.practice = 0 --双修状态
    self.pEffect = nil--双修特效
    self.bodyLoaded = false
end
--获取角色当前AI  0-待机 1-战斗 2-死亡 3-打坐 4-采集 5-移动 6-跳跃
function Thing:getStateID()
    return self.character.CurStateID
end
--注册模型加载完成回调
function Thing:regisCallBack()
    if self.character then
        self.character:OnRegisterLuaFunc(function ()
            self:bodyLoadComplete()
        end)
    end
end
--注册坐骑上下事件回调
function Thing:regisMountEvent()
    if not self.character then return end
    self.character:OnRegisterMountFunc(function(state)
        if state == 1 then
            self:onSitMount()
        elseif state == 2 then
            self:onDownMount()
        end
    end)
end

function Thing:refreshScore(attris)
    -- body
end
--初始化数据
function Thing:setBaseData(data)
    -- print(debug.traceback())
    -- printt("Thing初始化数据",data)
    self.mountType = "mount"
    self.data = data
    --玩家信息
    self:setID(data.roleId)
    self.skins = data.skins
    self.wearTitle = data.wearTitle

    self:setSkins(self.skins[1], self.skins[2], self.skins[3])
    --法宝 仙器
    if data.skins and data.skins[Skins.fabao] and data.skins[Skins.fabao]~=0 then
        self:addFaBao(data.skins[Skins.fabao])
    end
    if data.skins and data.skins[Skins.xianqi] and  data.skins[Skins.xianqi]~=0 then
        self:addXianQi(data.skins[Skins.xianqi])
    end




    self:setPosition(data.pox, data.poy)
    self:setTitleName(data.roleName)

    self:setGangName(data.gangName)
    self:setCoupleName(data)
    if data.roleIcon then
        self.sex = math.floor(data.roleIcon / 100000000)
    else
        self.sex = 0
    end
    self:updateAttris(data.attris)
    self:setChenghao()
    self:judeStatue()
    if data.practice then
        self:setMajorState(data.practice)
    end
    if self.data.roleId == "1" or self.data.roleId == "2" then  --竞技场强制不隐藏-神坑
        self:ignoreHide(true)
    end
end

-- 是否隐藏投影黑点
function Thing:hideShadow()
    if g_var.gameFrameworkVersion > 14 then
        if self.character then
            self.character.isShadow = false
        end
    end
end

--设置双修状态
function Thing:setMajorState( practice, func )
    -- print("双修状态",practice)
    if practice > 0 then
        self.practice = practice
        self:sit(func,"sit2")
        if practice == 1 then
            self:setDirection(90)
            if not self.pEffect then
                -- print("添加")
                self.pEffect = mgr.EffectMgr:playCommonEffect(4040113, self:getRoot())
                self.pEffect.LocalPosition = Vector3.New(0.7,0,0)
                self.pEffect.LocalRotation = Vector3.New(180,0,0)
                self.pEffect.Scale = Vector3.New(1,1,1)
            end
        else
            if self.pEffect then
                -- print("移除")
                mgr.EffectMgr:removeEffect(self.pEffect)
                self.pEffect = nil
            end
            self:setDirection(270)
        end
        self:setHeadBarPos()
    else
        if self.pEffect then
                -- print("移除")
            mgr.EffectMgr:removeEffect(self.pEffect)
            self.pEffect = nil
        end
        self.practice = 0
        if self.character then
            if self:isSit() then
                self:cancelSit()
            end
        end
    end
end

-- 设置红名
function Thing:setHongMing(state)
    local color = TextColors[5]
    if state then
        local var = cache.PlayerCache:getAttribute(613)
        local confData = conf.SysConf:getRedDataByValue(var)
        -- print(">>>>>>>>>>>>>",var)
        color = confData.name_color or TextColors[14]
        local sceneId = cache.PlayerCache:getSId()
        local sceneData = conf.SysConf:getValue("red_name_limit_scene")
        for k,v in pairs(sceneData) do
            if sceneId == v then
                color = TextColors[5]
                break
            end
        end
    end
    if self.headBar then
        local label = self.headBar:GetChild("name")
        local name = mgr.TextMgr:getTextColorStrByRGB(self.titleName,color)
        -- label.color = TextColors[14]
        label.text = name
        -- print("redName>>>>>>>>>>",label.text,color)
    end
end

--是否是双修
function Thing:isMajor()
    if self.practice and self.practice > 0 then
        return true
    end
    return false
end
--判断是不是雕像
function Thing:judeStatue()
    local kind = self.data and self.data.kind or 0
    if kind == PlayerKind.statue then--雕像
        self:setCanSelect(false)
        self.pkState = PKState.invalid
        self.bloodBar.visible = false
        -- self:setModelLocalRotation(StaticVector3.diaoxiangRole)
    else
        self:setCanSelect(true)
    end
end

function Thing:updateAttris(attris)
    if not attris then return end
    for k ,v in pairs(attris) do
        if k == 512 then      --0下坐骑，1上坐骑

            if v == 0 then
                --plog("玩家属性下马")
                self:downMount()
                self:onDownMount()
            elseif v == 1 then
                --plog("玩家属性上马")
                self:sitMount()
            end
        elseif k == 112 then  --速度
            self.data.attris[112] = v
            self:setSpeed(v)
        elseif k == 104 then  --血量
            self.data.attris[104] = v
            self:setMaxHp(attris[105] or 100)
            self:setHp(v or 0)
        elseif k == 511 then  --玩家PK状态
            self.pkState = attris[511] or 0
        elseif k == 502 then  --设置玩家等級
            self.lv = v or 1
        elseif k == 513 then
            mgr.HurtMgr:thingHurt(self, self:getID() , v)
        end
    end
end

function Thing:bodyLoadComplete()
    self.bodyLoaded = true
    self:bodyLoad()
end
function Thing:bodyLoad()
    --TODO 模型加载完毕
end
function Thing:addThingEct(key, bone, resId)
    self.character:AddBodyEffect(key,bone, ResPath.effectRes(resId))
end

function Thing:isDeadState()
    return false
end

--设置速度
function Thing:setSpeed(value)
    self.character.Speed = value
end
function Thing:getSpeed()
    return self.character.Speed
end

--对象是否可以被选中攻击
function Thing:canBeSelect()
    return self.character and self.character.CanSelected
end
function Thing:setCanSelect(b)
    self.character.CanSelected = b
end
--对象是否忽略隐藏
function Thing:ignoreHide(b)
    self.ignoreHideVar = b
    self.character.IgnoreHide = b
end


--麒麟臂
function Thing:addBodyEct(id)
    if not self.bodyLoaded then
        return
    end

    if self:isSee() == false then
        return
    end
    if not self.character then
        return
    end
    if not self.character.mBody then
        return
    end

    if self.bodyEct then
        mgr.EffectMgr:removeEffect(self.bodyEct)
    end

    local bodyTransform = self.character.mBody:BoneNode("tuowei1")

    --print(bodyTransform:Equals(nil),"3333")
    if bodyTransform then
        self.bodyEct = mgr.EffectMgr:playCommonEffect(id, bodyTransform, nil, nil, true)
        self.bodyEct.LocalRotation = Vector3.zero
        self.bodyEct.Scale = Vector3.one
    end
end

--添加武器效果
function Thing:addWeaponEct(id)
    if self.weaponEct then
        mgr.EffectMgr:removeEffect(self.weaponEct)
    end
    local wParent = self.character:WeaponGuadian()
    self.weaponEct = mgr.EffectMgr:playCommonEffect(id, wParent)
end
--添加仙器
function Thing:addXianQi(id)
    self.xianQiId = id
    if self:isSee() == false then
        return
    end
    if self.xianQiEct then
        mgr.EffectMgr:removeEffect(self.xianQiEct)
    end
    local bodyTransform = self.character.mRoot.mTransform
    self.xianQiEct = mgr.EffectMgr:playCommonEffect(id, bodyTransform)
    self.xianQiEct.LocalRotation = StaticVector3.vector3Z180
    self.xianQiEct.Scale = Vector3.one
    self.xianQiEct:AutoRotation(self:getID(), self.tType)
    local roleId = self.data and self.data.roleId or 0
    if mgr.QualityMgr:getAllFaQi() == false and cache.PlayerCache:getRoleId() ~= roleId and self.tType == ThingType.player then
        self.xianQiEct.Visible = false
    end
    local sId = cache.PlayerCache:getSId()
    --bxp 九重天显示玩家仙器，法宝，神兵都打开 陈烘需求 2018/7/13
    if mgr.FubenMgr:isWenDing(sId) --[[and roleId ~= cache.PlayerCache:getRoleId()]] and self.tType == ThingType.player then
        self.xianQiEct.Visible = true
    end
    if mgr.FubenMgr:isXianMoWar(sId) or mgr.FubenMgr:isXdzzWar(sId) or mgr.FubenMgr:isCdmhWar(sId) then
        self.xianQiEct.Visible = false
    end
end
--添加法宝add
function Thing:addFaBao(id)
    self.faBaoId = id
    if self:isSee() == false then
        return
    end
    if self.faBaoEct then
        mgr.EffectMgr:removeEffect(self.faBaoEct)
    end
    local bodyTransform = self.character.mJump.mTransform
    self.faBaoEct = mgr.EffectMgr:playCommonEffect(id, bodyTransform)
    self.faBaoEct.LocalRotation = StaticVector3.vector3Z180
    self.faBaoEct.Scale = Vector3.one
    local roleId = self.data and self.data.roleId or 0
    if mgr.QualityMgr:getAllFaQi() == false and cache.PlayerCache:getRoleId() ~= roleId and self.tType == ThingType.player then
        self.faBaoEct.Visible = false
    end
    local sId = cache.PlayerCache:getSId()
    --bxp 九重天显示玩家仙器，法宝，神兵都打开 陈烘需求 2018/7/13

    if mgr.FubenMgr:isWenDing(sId) --[[and roleId ~= cache.PlayerCache:getRoleId()]] and self.tType == ThingType.player then
        self.faBaoEct.Visible = true
    end
    if mgr.FubenMgr:isXianMoWar(sId) or mgr.FubenMgr:isXdzzWar(sId) or mgr.FubenMgr:isCdmhWar(sId) then
        self.faBaoEct.Visible = false
    end
end
--神兵
function Thing:addShenBing(id)
    if self:isSee() == false then
        return
    end

    if self.shenBingEct then
        mgr.EffectMgr:removeEffect(self.shenBingEct)
    end
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isXdzzWar(sId) or mgr.FubenMgr:isCdmhWar(sId) then--雪地改变
        return
    end
    local bodyTransform = self.character:WeaponGuadian()
    if bodyTransform then
        self.shenBingEct = mgr.EffectMgr:playCommonEffect(id, bodyTransform, nil, nil, true)
        self.shenBingEct.LocalRotation = Vector3.zero
        self.shenBingEct.Scale = Vector3.one
    end
end

--光环
function Thing:addHaloEct(id)
    if self:isSee() == false then
        return
    end

    if self.haloEct then
        mgr.EffectMgr:removeEffect(self.haloEct)
    end

    local bodyTransform = self.character.mRoot.mTransform
    if bodyTransform and id ~=0 then
        -- print("光环佩戴id>>>>>>>>>>>>",id)
        local haloData = conf.RoleConf:getHaloData(id)
        self.haloEct = mgr.EffectMgr:playCommonEffect(haloData.effect_id, bodyTransform, nil, nil, true)
        self.haloEct.LocalRotation = Vector3.New(0,0,180)
        self.haloEct.Scale = Vector3.one
    end
end

--头饰
function Thing:addHeadEct(id)
	 if not self.bodyLoaded then
        return
    end

    if self:isSee() == false then
        return
    end

    if self.headEct then
        mgr.EffectMgr:removeEffect(self.headEct)
    end
    local bodyTransform = self.character.mBody:BoneNode("Bip001 Head")
    -- print("头饰>>>>>>>>>>>>>>>>>>>",bodyTransform)
    if bodyTransform and id ~= 0 then
        local headData = conf.RoleConf:getHeadData(id)
        local effect_id = headData.effect_id
        self.headEct = mgr.EffectMgr:playCommonEffect(effect_id, bodyTransform, nil, nil, true)
        self.headEct.LocalRotation = Vector3.New(0,0,0)
        self.headEct.Scale = Vector3.one
    end
end

--面具
function Thing:addMianJuEct(id)
     if not self.bodyLoaded then
        return
    end

    if self:isSee() == false then
        return
    end

    if self.mianjuEct then
        mgr.EffectMgr:removeEffect(self.mianjuEct)
    end
    local bodyTransform = self.character.mBody:BoneNode("Bip001 Head")
    if bodyTransform and id ~= 0 then
        local mainjuData = conf.MianJuConf:getMianJuData(id)
        local effect_id = mainjuData.effect_id
        self.mianjuEct = mgr.EffectMgr:playCommonEffect(effect_id, bodyTransform, nil, nil, true)
        self.mianjuEct.LocalRotation = Vector3.New(0,0,0)
        self.mianjuEct.Scale = Vector3.one
    end
end

-- 奇兵
function Thing:addQiBingEct(id)
     if not self.bodyLoaded then
        return
    end

    if self:isSee() == false then
        return
    end

    if self.qibingEct then
        mgr.EffectMgr:removeEffect(self.qibingEct)
    end
    local bodyTransform = self.character.mBody:BoneNode("Bip001 Spine")
    if bodyTransform and id ~= 0 then
        local config = conf.QiBingConf:getQiBingDataById(id)
        local effect_id = config.modelId
        self.qibingEct = mgr.EffectMgr:playCommonEffect(effect_id, bodyTransform, nil, nil, true)
        self.qibingEct.LocalRotation = Vector3.New(0,0,0)
        self.qibingEct.Scale = Vector3.one
    end
end


function Thing:setHeadBarPos()
    if self.isChangeBody then
        self.headBar.position =  Vector3.New (0, -210, 0)
    else
        if self:getStateID() == 3 then
            self.headBar.position = Vector3.New (0, -80, 0)
        else
            self.headBar.position = self.headHeight
        end
    end
end

--上下坐骑事件
function Thing:onSitMount()
    if self.mountType == "mount" then
        self.headBar.position = Vector3.New (0, -135, 0)
        if self.faBaoEct then
            self.faBaoEct.LocalPosition = Vector3.zero
        end
    else
        self.headBar.position = Vector3.New (0, -185, 0)
        if self.faBaoEct then
            self.faBaoEct.LocalPosition = Vector3.New(0,-1.6,0)
        end
    end
end

function Thing:onDownMount()
    if self.faBaoEct then
        self.faBaoEct.LocalPosition = Vector3.zero
    end
    self.headBar.position = self.headHeight
end
--头顶信息
function Thing:createHeadBar()
    if not self.headBar then
        self.headBar = self.character:AddHeadBar("head", self.headRes)
        self.bloodBar = self.headBar:GetChild("blood")
        self.headBar.position = self.headHeight
        self.headBar:SetScale(0.7, 0.75)
        self.headBar.visible = true
    end
end
--头顶添加prefab
function Thing:addHeadObject()

end
--设置称号
function Thing:setChenghao(data)

    local listview = self.headBar:GetChild("n30")
    if not listview then
        return
    end
    local  c1 = self.headBar:GetController("c1") --婚戒显示
    -- local name1 = self.headBar:GetChild("n21") -- 仙盟显示
    -- local ishunjie = self.headBar:GetChild("n28")

    local labelname = self.headBar:GetChild("name")
    local label = self.headBar:GetChild("name1")
    if label and label.text ~="" then
        listview.y = label.y - listview.height*listview.scaleY
    else
        listview.y = labelname.y - listview.height*listview.scaleY
    end
    if self.headRes ==  "HeadView" then
         listview.y = listview.y - 10
    end

    -- if c1.selectedIndex == 3 then
    --     if self.headRes ==  "HeadView4" then
    --         if ishunjie.url then
    --             listview.y = - 700
    --         else
    --             if name1.url then
    --                 listview.y = - 700
    --             else
    --                 listview.y = - 669
    --             end
    --         end
    --     elseif self.headRes ==  "HeadView" then
    --         if ishunjie.url then
    --             listview.y = - 709
    --         else
    --             if name1.url then
    --                 listview.y = - 700
    --             else
    --                 listview.y = - 675
    --             end
    --         end
    --     end
    -- else
    --     if self.headRes ==  "HeadView4" then
    --         listview.y = - 730
    --     elseif self.headRes ==  "HeadView" then
    --          listview.y = - 707
    --     end
    -- end


     -- print(self.headRes,listview.y )
     -- print(listview.y )
    listview.numItems = 0
    if  self:isSee() == false or g_ios_test  then
        return
    end
    local wearTitle = {}
    if data then
        wearTitle = data
    else
        wearTitle = self.wearTitle
    end
    local data1 ={}
    data1 = reverseTable(wearTitle)
    for k,v in pairs(data1) do
        local url = UIPackage.GetItemURL("head" , "chenghaoItem")
        local obj = listview:AddItemFromPool(url)
        self:cellTitleData1(v,obj)
    end
    -- print("$$$$$$$$$$$$$$",debug.traceback())
    -- self.chengHaoId = id
    -- if self:isSee() == false then
    --     if self.headBar then
    --         local title = self.headBar:GetChild("sign")
    --         title.url = nil
    --         local effect = self.headBar:GetChild("effect")
    --         effect.url = url
    --         effect.visible = false
    --     end
    --     return
    -- end
    -- if g_ios_test then    --EVE 屏蔽称号~！ 6666
    --     return
    -- end
    -- local url = ""
    -- local scale = 1
    -- if id and id > 0 then
    --     local data = conf.RoleConf:getTitleData(id)
    --     if data then
    --         url = ResPath.titleRes(data.scr)
    --         scale = data.scale or 1
    --     end
    -- end
    -- local title = self.headBar:GetChild("sign")
    -- title.data = id
    -- title.url = url
    -- title.visible = true
    -- local labelname = self.headBar:GetChild("name")
    -- local label = self.headBar:GetChild("name1")
    -- if label and label.text ~="" then
    --     title.y = label.y - title.height*title.scaleY
    -- else
    --     title.y = labelname.y - title.height*title.scaleY
    -- end
    -- local url = nil
    -- local effect = self.headBar:GetChild("effect")
    -- if id == 1005002 then--仙盟盟主
    --     url = UIPackage.GetItemURL("_movie" , "MovieChenghao1")
    -- end
    -- if id == 1004001 then--战力至尊
    --     url = UIPackage.GetItemURL("_movie" , "MovieChenghao2")
    -- end
    -- if id == 1006015 then--三生三世
    --     url = UIPackage.GetItemURL("_movie" , "MovieChenghao3")

    -- end
    -- if url then
    --     effect.visible = true
    -- else
    --     effect.visible = false
    -- end

    local roleId = self.data and self.data.roleId or 0
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isWenDing(sId) then--问鼎
        listview.numItems = 0
        if cache.WenDingCache:getflagHoldRoleId() == roleId then
            self:updateRoleTitle()
        end
    elseif mgr.FubenMgr:isXianMoWar(sId) or mgr.FubenMgr:isXdzzWar(sId) or mgr.FubenMgr:isCdmhWar(sId) then--仙魔 雪地
        listview.numItems = 0
    end

end

function  Thing:cellTitleData1( id,cell )
    local  effecticon = cell:GetChild("effect")
    effecticon.visible =true
    local  imageicon = cell:GetChild("image")
    if not id then
        imageicon.url = ResPath.titleRes(UIItemRes.wending02)
    else
        local data = conf.RoleConf:getTitleData(id)
        imageicon.url = ResPath.titleRes(data.scr)
    end
    --处理有特效的
    if id == 1005002 then--仙盟盟主
        effecticon.url = UIPackage.GetItemURL("_movie" , "MovieChenghao1")
    elseif id == 1004001 then--战力至尊
        effecticon.url = UIPackage.GetItemURL("_movie" , "MovieChenghao2")
    elseif id == 1006015 then--三生三世
        effecticon.url = UIPackage.GetItemURL("_movie" , "MovieChenghao3")
    else
        effecticon.visible =false
    end

end


--外部修改称号
function Thing:updateRoleTitle(url)
    local listview = self.headBar:GetChild("n30")
    if not listview then
        return
    end
    listview.numItems = 0
    local _url = UIPackage.GetItemURL("head" , "chenghaoItem")
    local obj = listview:AddItemFromPool(_url)
    self:cellTitleData1(nil,obj)
    -- local title = self.headBar:GetChild("sign")
    -- title.visible = true
    -- title.url = url
    -- -- title.x = -(title.width * title.scaleX - self.headBar.width)/2
    -- local labelname = self.headBar:GetChild("name")
    -- local label = self.headBar:GetChild("name1")
    -- if label and label.text ~="" then
    --     title.y = label.y - title.height * title.scaleY
    -- else
    --     title.y = labelname.y - title.height * title.scaleY
    -- end
end
--屏蔽别人称号
function Thing:hitChenghao(isVisible)
    -- local title = self.headBar:GetChild("sign")
    -- title.visible = isVisible
    -- local effect = self.headBar:GetChild("effect")
    -- if effect then
    --     if title.data == 1005002 or title.data == 1004001 then
    --         if isVisible then
    --             effect.visible = true
    --         else
    --             effect.visible = false
    --         end
    --     else
    --         effect.visible = false
    --     end
    -- end
    local listview = self.headBar:GetChild("n30")
    -- print("屏蔽别人称号",isVisible)
    if not isVisible then
        listview.numItems = 0
    else
        local labelname = self.headBar:GetChild("name")
        local label = self.headBar:GetChild("name1")
        if label and label.text ~="" then
            listview.y = label.y - listview.height*listview.scaleY
        else
            listview.y = labelname.y - listview.height*listview.scaleY
        end
        if self.headRes ==  "HeadView" then
             listview.y = listview.y - 10
        end

        listview.numItems = 0
        -- if  self:isSee() == false or g_ios_test  then
        --     return
        -- end
        local data1 ={}
        data1 = reverseTable(self.wearTitle)
        for k,v in pairs(data1) do
            local url = UIPackage.GetItemURL("head" , "chenghaoItem")
            local obj = listview:AddItemFromPool(url)
            self:cellTitleData1(v,obj)
        end
    end
end
--设置聊天
function Thing:setChatData(str)
    local t0 = self.headBar:GetTransition("t0")
    t0:Play()
    local bubble = self.headBar:GetChild("n13")
    local chatText1 = self.headBar:GetChild("n14")
    chatText1.text = str
    local chatText2 = self.headBar:GetChild("n15")
    chatText2.text = str
    local num = 40
    if chatText2.width >= chatText1.width then--换行的时候
        chatText1.visible = true
        chatText2.visible = false
        local t1 = self.headBar:GetTransition("t1")
        t1:Play()
        bubble.width = chatText1.width + num
    else
        chatText1.visible = false
        chatText2.visible = true
        local t2 = self.headBar:GetTransition("t2")
        t2:Play()
        bubble.width = chatText2.width + num
    end
    local height = chatText1.height + 20
    bubble.height = height--设置气泡的高度
end
--设置玩家姓名
function Thing:setTitleName(name)
    self.titleName = name
    if self.headBar then
        local label = self.headBar:GetChild("name")--..
        local xiuxianIcon = self.headBar:GetChild("n21")
        if self.skins then--活跃称号
            local activeLv = self.skins[14] or 0
            local var = cache.PlayerCache:getAttribute(20139)
            -- print("称号状态",var,activeLv)
            if var == 0 and activeLv > 1 and activeLv%30 == 0 then
                self.activeTitle = conf.ImmortalityConf:getAttrDataByLv(activeLv-1)
            else
                self.activeTitle = conf.ImmortalityConf:getAttrDataByLv(activeLv)
            end
        end
        local sId = cache.PlayerCache:getSId()
        if (mgr.FubenMgr:isWenDing(sId) or mgr.FubenMgr:isXdzzWar(sId)) or mgr.FubenMgr:isCdmhWar(sId) and self.data.roleId ~= cache.PlayerCache:getRoleId() then
            if xiuxianIcon then
                xiuxianIcon.visible = false
            end
        else
            if self.activeTitle and self.activeTitle.name then
                -- str = mgr.TextMgr:getImg("["..self.activeTitle.name.."]",self.activeTitle.color)
                if xiuxianIcon then
                    local url = UIPackage.GetItemURL("head" , self.activeTitle.name_img)
                    -- print(".....9999999",self.activeTitle.name_img)
                    xiuxianIcon.url = url
                    xiuxianIcon.visible = true
                    self.activeTitle = nil
                end
                -- str = mgr.TextMgr:getImg(url,73,43)
            else
                if xiuxianIcon then
                    xiuxianIcon.visible = false
                end
            end
        end

        if self.data and self.data.skins and self.data.skins[Skins.fsz] and self.data.skins[Skins.fsz] ~= 0 then
            --print("self.data.skins[Skins.fsz]",self.data.skins[Skins.fsz])
            xiuxianIcon.visible = true
            xiuxianIcon.url =  "ui://head/feisheng_" .. string.format("%03d",44 + self.data.skins[Skins.fsz] )
        end

        local myName = cache.PlayerCache:getRoleName()--玩家名字
        if mgr.FubenMgr:isWenDing(cache.PlayerCache:getSId()) and name ~= myName then
            -- label.text = language.wending06[1]
            label.text = name--bxp 九重天显示玩家名字 陈烘需求 2018/7/13

        else
            label.text = name
            if self.data and mgr.BuffMgr:isHongMing(self.data.roleId) then
                self:setHongMing(true)
            end
        end
    end
end
--
function Thing:setHunJie()
    -- body
    if not self.headBar then
        return
    end
    if not self.data.skins[Skins.hunjie] and self.data.skins[Skins.hunjie] == 0 then
        return
    end
    if not self.data.coupleName or self.data.coupleName == "" then
        return
    end
    local c1 = self.headBar:GetController("c1")
    c1.selectedIndex = 3
    local condata = conf.MarryConf:getRingItem(self.data.skins[Skins.hunjie])
    local _confata_ = conf.MarryConf:getRingItemByJie(condata.step)
    local iconjh = self.headBar:GetChild("n28")
    print("結婚",debug.traceback())
    local effpanel = self.headBar:GetChild("n29")
    if iconjh then
        iconjh.url = "ui://head/".._confata_.icon1


        if self.hunjiecomponent then
            self.hunjiecomponent:Dispose()
            self.hunjiecomponent = nil
        end
        --添加特效 ---序列帧效果
        local component = UIPackage.CreateObject("_movie" , "MovieClipHj"..condata.step)
        --print(component.blendMode,"component.blendMode")
        component.x = -75
        component.y = iconjh.y - 19
        component:AddRelation(iconjh,RelationType.Center_Center )
        component:AddRelation(iconjh,RelationType.Bottom_Top)
        self.hunjiecomponent = component
        self.headBar:AddChild(self.hunjiecomponent)
    end
end


function Thing:setCoupleName(data)
    -- body
    if self.headBar then
        local labelname = self.headBar:GetChild("name")
        local title = self.headBar:GetChild("sign")
        local c1 = self.headBar:GetController("c1")
        c1.selectedIndex = 3
        local iconjh = self.headBar:GetChild("n28")
        local effpanel = self.headBar:GetChild("n29")
        if self.hjeffect then
            mgr.EffectMgr:removeUIEffect(self.hjeffect)
            self.hjeffect = nil
        end
        if iconjh then
            iconjh.url = nil
        end

        local label = self.headBar:GetChild("name1")
        if label then
            local grade = data.grade or 1
            grade = math.max(grade,1)
            --printt("data",data)

            if data.coupleName~="" then
                if self.data.skins[Skins.hunjie] and self.data.skins[Skins.hunjie] ~= 0 then
                    c1.selectedIndex = 3
                    self:setHunJie()
                else
                    c1.selectedIndex = grade - 1
                end
                local t = GGetMsgByRoleIcon(data.roleIcon)

                local ss = string.split(data.coupleName,".")
                local var = ""
                if #ss == 2 then
                    var = string.format(language.kuafu78[grade][t.sex],ss[2])
                else
                    var = string.format(language.kuafu78[grade][t.sex],data.coupleName)
                end

                label.text = var
            else
                c1.selectedIndex = 3
                label.text = ""
                 if self.hunjiecomponent then
                    self.hunjiecomponent:Dispose()
                    self.hunjiecomponent = nil
                end
            end
            local sId = cache.PlayerCache:getSId()
            if (mgr.FubenMgr:isWenDing(sId) or mgr.FubenMgr:isXdzzWar(sId) or mgr.FubenMgr:isCdmhWar(sId)) and self.data.roleId ~= cache.PlayerCache:getRoleId() then
                c1.selectedIndex = 3
                label.text = ""
                title.y = labelname.y - title.height*title.scaleX
                --title:AddRelation(labelname,RelationType.Center_Center )
                --title:AddRelation(labelname,RelationType.Bottom_Top)
            else
                if labelname and title then
                    if label.text ~= "" then
                        title.y = label.y - title.height*title.scaleX
                        --title:AddRelation(label,RelationType.Center_Center )
                        --title:AddRelation(label,RelationType.Bottom_Top)
                    else
                        title.y = labelname.y - title.height*title.scaleX
                        --title:AddRelation(labelname,RelationType.Center_Center )
                        --title:AddRelation(labelname,RelationType.Bottom_Top)
                    end
                end
            end
        end
        self:setChenghao()
    end
end

--外部改变玩家名字（如问鼎之战）
function Thing:updateRoleName(name)
    if self.headBar then
        local label = self.headBar:GetChild("name")--..
        label.text = name
    end
end

function Thing:setHeadBarVisible(v)
    if self.headBar then
        self.headBar.visible = v
    end
end

--设置玩家活跃称号
function Thing:setActiveTitle(activeLv)
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(activeLv)
    local titleTxt = attrConf.name
    local color = attrConf.color
    self.activeTitle = attrConf
    self:setTitleName(self.titleName)
end
--仙盟
function Thing:setGangName(gangName)
    if self.headBar then
        local label = self.headBar:GetChild("n16")--..
        local name = ""--仙盟
        if gangName and gangName ~= "" then
            --plog("self.data.gangJob",self.data.gangJob)
            if self.data.gangJob and self.data.gangJob>0 then

                local var = gangName.."·"..language_pos[self.data.gangJob+1]
                name = mgr.TextMgr:getTextColorStr("["..var.."]",10)
            else
                name = mgr.TextMgr:getTextColorStr("["..gangName.."]",10)
            end
        end
        label.text = name
        local title = self.headBar:GetChild("sign")--..
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isWenDing(sId) and self.data.roleId ~= cache.PlayerCache:getRoleId() or  mgr.FubenMgr:isXdzzWar(sId) or mgr.FubenMgr:isCdmhWar(sId) then
            label.visible = false
        else
            label.visible = true
        end
        -- if name == "" then
        --     sign.y = -11
        -- else
        --     sign.y = -32
        -- end
        local rolename = self.headBar:GetChild("name")
        --动态调整位置
        if label.visible and name~="" then
            label.y = 62
            rolename.y = 36
        else
            rolename.y = 62
        end
        --根据仙盟的是否退出或者加入调整位置
        if rolename and title then
            local name1 = self.headBar:GetChild("name1")
            if name1.text ~= "" then
                title.y = name1.y - title.height*title.scaleX
            else
                title.y = rolename.y - title.height*title.scaleX
            end
        end
    end
end

function Thing:checkCanBeAttack()
    -- 子类player重写
end

--设置玩家最高血量
function Thing:setMaxHp(hp)
    if not hp then
        print("@总血量血量设置为空：", debug.traceback())
        return
    end
    self.maxHp = hp
    if self.data and self.data.attris[105] then
        self.data.attris[105] = hp
    end
end
--设置玩家血量
function Thing:setHp(hp)
    if not hp then
        print("@当前血量设置为空：", debug.traceback())
        return
    end
    local maxHp = self.maxHp or 0
    if hp < 0 then
        self.hp = 0
    elseif hp > maxHp then
        self.hp = maxHp
    else
        self.hp = hp
    end
    --TODO 更新玩家血量
    self.bloodBar.asProgress.value = self.hp/self.maxHp * 100
    local roleId = cache.PlayerCache:getRoleId()
    local playerRoleId = self.data and self.data.roleId or 0
    --如果玩家满血的都隐藏血量
    if (self.hp == self.maxHp and roleId ~= playerRoleId) then
        self.bloodBar.visible = false
    else
        self.bloodBar.visible = true
    end
    if self.data and self.data.attris[104] then
        self.data.attris[104] = self.hp
    end

    local view = mgr.ViewMgr:get(ViewName.NearPlayer)
    if view then
        view:refreshHp(self.data)
    end
end
--获取事物血量
function Thing:getHp()
    return self.hp or 0
end
--玩家扣血
function Thing:updateHp(value)
    self:setHp(self.hp - value)
    --[[if self.hp == 0 then
        self:dead()
    end]]
end
-- 死亡处理[player 和 npc、monster 都重写了次方法]
function Thing:dead(killId)
    if self.bloodBar then
        self.bloodBar.visible = false
    end
    mgr.ThingMgr:removeObj(self:getType(), self:getID())
    if self.data then
        mgr.BuffMgr:removeThingBuff({roleId = self.data.roleId})
    end
    self:deadFly(killId, true)
end
--击飞效果
function Thing:deadFly(killId, fly)
    local kind = self:getKind()
    if kind == MonsterKind.tcollection or kind == MonsterKind.crystal then
        mgr.PickMgr:removeCollection(self:getID())
        self:dispose()
        return
    end
    if fly == 0 then  --有击飞效果
        if not self.character then return end
        self.character:PlayAnimationByName("dead")
        local killObj = mgr.ThingMgr:getObj(ThingType.player, killId)
        if not killObj then
            killObj = gRole
        end
        local p = GMath.dirDistanceB(killObj:getPosition(), self:getPosition(), 200)
        local endPos = Vector2.New(p.x, p.z)
        UTransition.TweenDead(self.character, endPos, 0.4 , function()
            mgr.TimerMgr:addTimer(1, 1, function()
                self:playDeadEct()
                self:dispose()
            end)
        end)
    elseif fly == 1 then --直接移除没有任何表现效果
        self:dispose()
    elseif fly == 2 then --有死亡动作不击飞
        if not self.character then return end
        self:playDeadEct()
        self.character:PlayAnimationByName("dead")
        mgr.TimerMgr:addTimer(1, 1, function()
            self:dispose()
        end,"DeadFly")
    end
end

function Thing:playDeadEct()
    local effect = 4040111
    if self.tType == ThingType.monster then--怪物死亡特效
        local mConf = conf.MonsterConf:getInfoById(self.data.mId)
        effect = mConf and mConf["dead_effect"] or 4040111
    end
    local parent = UnitySceneMgr.pStateTransform
    local e = mgr.EffectMgr:playCommonEffect(effect, parent)
    if e then
        e.LocalPosition = self:getPosition()
    end
end

--设置玩家性别
function Thing:setSex(sex)
    self.sex = sex
end

--C#相关接口
function Thing:setID(id)
    self.tID = tostring(id)
    self.character.ID = id
end
function Thing:getID()
    return self.tID
end
function Thing:getType()
    return self.tType
    --return self.character.ObjType
end

function Thing:getMId()
    return self.data and self.data.mId or 0
end

--返回事物物类型
function Thing:getKind()
    return self.data and self.data.kind or 0
end
--设置坐标
function Thing:setPosition(x, y)
    self.character.MapPosition = Vector3.New(x,gRolePoz,y)
end

--重置玩家坐标
function Thing:restPosition()
    local oldPos = self.character.MapPosition
    local x = oldPos.x
    local y = oldPos.z
    local vx = x - x%30 + 15
    local vy = y - y%30 + 15
    local vec = Vector3.New(vx,gRolePoz,vy)
    if UnityMap:CheckCanWalk(vec) then
        self.character.MapPosition = vec
        print("@角色重置坐标~~~", vx, vy)
    end
end

function Thing:getDistance()
    return self.character.Distance
end

--获取坐标
function Thing:getPosition()
    return self.character.MapPosition
end
function Thing:setDepth(z)
    self.character.PositionZ = z
end

--设置外部
function Thing:setSkins(body, weapon, wing)
    self.bodySrc = body
    self.weaponSrc = weapon
    self.wingSrc = wing
    --print(debug.traceback(""))
    --print("Thing:appear()>>>>", self.canSee, self.waitAppear,body)
    if self:isSee() == false then
        --print("isSee")
        return
    end
    if body then
        self.bodyLoaded = false
        if self:getKind() == PlayerKind.statue then--雕像
            self.character.BodyID = ResPath.npcRes(body)
        elseif self:getKind() == PlayerKind.statue_new then--雕像
            self:setHeadBarVisible(false)
            self.character.BodyID = ResPath.npcRes(body)
        else
            local bId = ResPath.playerRes(body)
            if self.character.BodyID ~= bId then
                --神兵特效
                if self.shenBingEct then
                    mgr.EffectMgr:removeEffect(self.shenBingEct)
                    self.shenBingEct = nil
                end
            end
            self.character.BodyID = bId
        end
    end
    if weapon then
        if weapon == 0 then
            self.character.WeaponID = "0"
        else
            self.character.WeaponID = ResPath.weaponRes(weapon)
        end

    end
    if wing then
        if wing == 0 then
            self.character.WingID = "0"
        else
            self.character.WingID = ResPath.wingRes(wing)
        end
    end
end

--visible
function Thing:setVisible(b)
    self.character.Visible = b
end
--跳跃
function Thing:jump(t, arr, func)
    return self.character:StartJumpLua(t, arr, func)
end
--设置模型的旋转角度
function Thing:setModelLocalRotation(rotation)
    self.character.mModel.LocalRotation = rotation
end

--获取模型的旋转角度
function Thing:getModelLocalRotation()
    return self.character and self.character.mModel.LocalRotation
end
--获取模型的全局角度
function Thing:getBodyRotation()
    return self.character.mTop.Rotation
end
--获取模型的方向
function Thing:getDirection()
    return self.character.Direction
end
--获取角色跳跃的世界坐标
function Thing:getJumpWorldPos()
    return self.character.mJump.Position
end
--角色移动| point-目标点， reachDis-与目标点距离多少停止， func-抵达回调
function Thing:moveToPoint(point, reachDis, completeFunc, stopFunc)
    return self.character:MoveToPathToLua(point, reachDis, function(args)
        if args == 1 then
            if completeFunc then completeFunc() end
        elseif args == 2 then
            if stopFunc then stopFunc() end
        end
    end)
end
--移动
function Thing:moveToPath(path, reachDis, completeFunc, stopFunc)
    self.character:MoveToPathToLua2(path, reachDis or 0, function(args)
        if args == 1 then
            if completeFunc then completeFunc() end
        elseif args == 2 then
            if stopFunc then stopFunc() end
        end
    end)
end
--角色瞬移到点
function Thing:flashToPoint(point, reachDis, time, action, func)
    self.character:FlashLua(point, reachDis, time, action, func)
end
--坐骑
function Thing:handlerMount()

end
function Thing:sitMount()
    if self:isSee() == false then
        return
    end
    if self.data and self.data.skins and self.data.skins[Skins.zuoqi]
    and self.data.skins[Skins.zuoqi]~=0 then
        local resId = self.data.skins[Skins.zuoqi]--3040201

        local action = conf.ZuoQiConf:getHorseAction(resId) or "mount"
        self.mountType = action
        local res = ResPath.mountRes(resId)
        self.character:SitMount(res, action)
        self:onSitMount()
    end
end
--下坐骑
function Thing:downMount()
    self.mountType = "mount"
    self.character:DownMount()
end
--是否在坐骑上
function Thing:isMount()
    return self.character.IsOnMount
end

--播放动作
function Thing:playAnimation(s)
    self.character:PlayAnimation(s)
end
function Thing:playAnimationByName(s)
    self.character:PlayAnimationByName(s)
end
--受击
function Thing:beHurt()
    if self:getStateID() == RoleAI.produce or self:getStateID() == RoleAI.idle then
        local sId =cache.PlayerCache:getSId()
        if mgr.FubenMgr:isKuaFuWar(sId) then --三界争霸
            return --
        end
    end
    if self:getStateID() == 0 then
        self.character:BeHurt()
    end
end
--打坐
function Thing:sit(stopSitFunc, action)
    if not self:isSit() then
        if g_var.gameFrameworkVersion >=2 then
            self.character:Sit(action or "sit", stopSitFunc or nil)
        else
            self.character:Sit(stopSitFunc or nil)
        end
    else
        if g_var.gameFrameworkVersion >=2 then
            if self:isMajor() and action then
                self.character:Sit(action, nil)
                self.character:Sit(action, stopSitFunc or nil)
            end
        end
    end
end
function Thing:cancelSit()
    if self:isSit() then
        if g_var.gameFrameworkVersion >=2 then
            self.character:Sit("sit", stopSitFunc or nil)
        else
            self.character:Sit(stopSitFunc or nil)
        end
    end
end
function Thing:isSit()
    return self.character:IsSit()
end

function Thing:isFixed()
    local state = self.fixState or 0
    return state > 0
end
--定身
function Thing:fixed()
    if not self.fixState then self.fixState = 0 end
    self.fixState = self.fixState + 1
    return self.character:Fixed()
end
function Thing:removeFixed()
    if not self.fixState then self.fixState = 1 end
    self.fixState = self.fixState - 1
    if self.fixState <= 0 then
        return self.character:RemoveFixed()
    end
end
--采集func=回调。  参数返回1=开始采集，2=停止采集
function Thing:collect(func)
    self.character:Collect(function(statue)
        if statue == 2 then  --退出采集
            func(2)
        end
    end)
    if self:getStateID() == 4 then
        func(1)
    end
    --[传入C#函数最好只负责一个功能。否则容易出现函数里面调函数的循环]
end
--停止ai
function Thing:stopAI()
    self.character:StopMove()
end
--重置休闲动作
function Thing:idleBehaviour()
    self.character:IdleBehaviour()
end
--事物出现 目前仅仅针对玩家和宠物
function Thing:appear()

    if self.waitAppear then
        self.waitAppear = false
        if self.bodySrc then
            self:setSkins(self.bodySrc, self.weaponSrc, self.wingSrc)
        end
        if self.xianQiId then
            self:addXianQi(self.xianQiId)
        end
        if self.faBaoId then
            self:addFaBao(self.faBaoId)
        end
        -- if self.chengHaoId then
        --     self:setChenghao(self.chengHaoId)
        -- end
    end
end

--隐藏角色
function Thing:hitThing(b)
    self.character:HidThing(b)
end
--隐藏头部
function Thing:hitHeadBar(b)
    if self.headBar then
        self.headBar.visible = b
    end
end
--隐藏法器
function Thing:hitFaQi(b)
    if self.xianQiEct then
        self.xianQiEct.Visible = b
    end
    if self.faBaoEct then
        self.faBaoEct.Visible = b
    end
end
--隐藏仙羽
function Thing:hitWing(b)
    if b then
        self:setSkins(self.skins[1], self.skins[2], self.skins[3])
    else
        self:setSkins(self.skins[1], self.skins[2], 0)
    end
end
--隐藏宠物
function Thing:hitPet(b)
    local pet = mgr.ThingMgr:getObj(ThingType.pet, self:getID())
    if pet then
        pet:hitThing(b)
    end
end

--movie劇情 | info-跳跃信息。npc配置表中
function Thing:gameMovie(info, func)
    return self.character:GameMovie(info.action, info.jump_pos, info.done_time, func)
end

function Thing:otherGameMovie(info, del)
    local suc = self.character:GameMovie(info.action, info.jump_pos, info.done_time, function()
        --需要转移到场景的特效
        if info.trans_ect then
            if self.character then
                self.character.Visible = true
            end
            --self:delMovieEct()
        end
        --触发下次剧情或完成
        if info.next then
            local config = conf.NpcConf:getNpcById(info.next)
            local suc2 = self:otherGameMovie(config, del)
            if not suc2 then
                print("========剧情跳跃清理对象2========")
                self:setHeadBarVisible(true)
                if del then
                    self:dispose()
                end
            end
        else
            self:setHeadBarVisible(true)
            if del then
                self:dispose()
            end
        end
    end)

    if suc then
        if info.rotation then
            self:setDirection(info.rotation)
        end
        --需要转移到场景的特效
        if info.trans_ect then
            self.character.Visible = false
            --self:addMovieEct(info.trans_ect)
        end
        --隐藏头顶信息
        self:setHeadBarVisible(false)
    else
        print("========剧情跳跃清理对象1========")
        if del then
            self:dispose()
        end
    end
end

--設置朝向
function Thing:setDirection(value)
    self.character.DirectionAngle = value
end

function Thing:getRoot()
    return self.character.mRoot.mTransform
end
function Thing:getBody()
    if self.character.mBody then
        return self.character.mBody.mTransform
    end
end
function Thing:getModel()
    return self.character.mModel.mTransform
end
function Thing:getTop()
    return self.character.mTop.mTransform
end
function Thing:getGuaDian(name)
    if self.character.mBody then
        return self.character.mBody:BoneNode(name)
    end
end
function Thing:getGridValue()
    if g_var.gameFrameworkVersion >= 3 then
        return self.character.GridValue
    end
    return 5
end
--获取角色身上的特效层
function Thing:getEffectTransform()
    if not self.effectTransform then
        self.effectTransform = self.character.mTopEffect.mTransform
    end
    return self.effectTransform
end
--缩放
function Thing:scaleTo(d,s,t)
    self.character:ThingScaleTo(d, s, t)
end

--self.canSee 目前仅玩家和宠物有该变量
--针对玩家是否渲染模型而存在
function Thing:isSee()
    if self.ignoreHideVar == true then
        return true
    end
    if self.canSee == false or self.waitAppear == true then
        return false
    end
    return true
end

--事物buff
function Thing:addBuffEct(eId)
    if not self.buffEcts then self.buffEcts = {} end
    --print("添加buff", eId)
    if self.buffEcts[eId] then
        print("BUFF 已存在")
    else
        local parent
        local ectConf = conf.EffectConf:getEffectById(eId)
        if ectConf then
            if ectConf["layer"] == 5 then --玩家身上
                parent = self:getModel()
            elseif ectConf["layer"] == 6 then  --头顶
                parent = self:getTop()
            else
                parent = self:getRoot()
            end
            local ect = mgr.EffectMgr:playCommonEffect(eId, parent)
            self.buffEcts[eId] = ect
        else
            print("@策划：buff处理的表现没有配在效果配置表中"..eId)
        end
    end
end

function Thing:removeBuffEct(eId)
    if self.buffEcts and self.buffEcts[eId] then
        mgr.EffectMgr:removeEffect(self.buffEcts[eId])
        self.buffEcts[eId] = nil
    end
end

function Thing:isDispose()
    if self.character then
        return false
    end
    return true
end

--清理
function Thing:dispose()
    self:disposeExtend()
end

function Thing:disposeExtend()
    if self.buffEcts then
        for k, v in pairs(self.buffEcts) do
            mgr.EffectMgr:removeEffect(v)
        end
        self.buffEcts = nil
    end
    if self.bodyEct then
        mgr.EffectMgr:removeEffect(self.bodyEct)
        self.bodyEct = nil
    end
    if self.weaponEct then
        mgr.EffectMgr:removeEffect(self.weaponEct)
        self.weaponEct = nil
    end
    if self.faBaoEct then
        mgr.EffectMgr:removeEffect(self.faBaoEct)
        self.faBaoEct = nil
    end
    if self.xianQiEct then
        mgr.EffectMgr:removeEffect(self.xianQiEct)
        self.xianQiEct = nil
    end
    if self.pEffect then
        mgr.EffectMgr:removeEffect(self.pEffect)
        self.pEffect = nil
    end
    if self.shenBingEct then
        mgr.EffectMgr:removeEffect(self.shenBingEct)
        self.shenBingEct = nil
    end
    if self.haloEct then
        mgr.EffectMgr:removeEffect(self.haloEct)
        self.haloEct = nil
    end
    if self.headEct then
        mgr.EffectMgr:removeEffect(self.headEct)
        self.headEct = nil
    end
     if self.mianjuEct then
        mgr.EffectMgr:removeEffect(self.mianjuEct)
        self.mianjuEct = nil
    end
    if nil ~= self.qibingEct then
        mgr.EffectMgr:removeEffect(self.qibingEct)
        self.qibingEct = nil
    end
     if self.hjeffect then
        mgr.EffectMgr:removeUIEffect(self.hjeffect)
        self.hjeffect = nil
    end
    if self.qibingEct then
        mgr.EffectMgr:removeEffect(self.qibingEct)
        self.qibingEct = nil
    end
    if self.character then
        self.character:Destroy()
        self.character = nil
    end
    if self.hunjiecomponent then
        self.hunjiecomponent:Dispose()
        self.hunjiecomponent = nil
    end

    self.headBar = nil
    self.bloodBar = nil
end



return Thing