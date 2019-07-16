--
-- Author: 
-- Date: 2017-03-16 11:27:25
--

local BtnFight = class("BtnFight",import("game.base.Ref"))

local jsSkill = 5050201
function BtnFight:ctor(param)
    self.testSkillIds = {
        {5010201, 5020201},
        {5010301, 5020301},
        {5010401, 5020401}
    }

    self.twoskill = {5120101, 5120201}
    self.eleSkill = {
        [5200101] = true,
        [5200201] = true,
        [5200301] = true,
        [5200401] = true,
        [5200501] = true,
        [5200601] = true,
        [5200701] = true,
        [5200801] = true,
    }

    self.part = {
        [5120101] = 11,
        [5120201] = 12
    }

    local sex = cache.PlayerCache:getSex()
    self.needTaskId = {}
    self.skillOpenMark = {}
    for k , v in pairs(self.testSkillIds) do
        local condata = conf.SkillConf:getSkillopen_lvl(math.floor(v[sex]/100))
        if k == 1 then
            self.needTaskId["n305"] = condata
        elseif k == 2 then
            self.needTaskId["n306"] = condata
        else
            self.needTaskId["n307"] = condata
        end
    end
    --元素技能冷却
    self.coolDataEle = {}
    self.coolDataTwo = {}
    self.coolData = {}

    self.coolBianshen = {}

    self.coolTimer = {}

    self.parent = param
    self:initView()
end

function BtnFight:checkTwoBtn()
    -- body
    for i = 1 , 2 do
        local key = self.twoskill[i]
        local btn = self.coolDataTwo[key]
        local imglock = btn:GetChild("iconloack")
        local data = conf.SkillConf:getSkillConfByid(key)
        local preid = data and data.s_pre
        local id = conf.SkillConf:getSkillIcon(preid)
        btn.icon = ResPath.iconRes(id)
        local equip = cache.PackCache:getEquipDataByPart(self.part[key])
        if equip then
            local condata = conf.ItemConf:getItem(equip.mid)
            if not condata.skill_affect_id then
                imglock.visible = true
            else
                imglock.visible = false
            end
        else
            imglock.visible = true
        end     
    end
end
--检测八门元素技能开启
function BtnFight:checkEleSkillAct()
    self.isOpenEleSkill = false
    local data = conf.EightGatesConf:getValue("bm_skill")
    local openSkill = clone(data)
    table.sort(openSkill,function (a,b)
        if a[1] ~= b[1] then
            return a[1] > b[1]
        else
            return a[2] > b[2]
        end
    end)
    local sex = cache.PlayerCache:getSex()
    self.eleSkillId = 0
    for k,v in pairs(openSkill) do
        if cache.PackCache:isOpenSkillByEleColorNum(v[1],v[2]) then
            self.eleSkillId = v[2+tonumber(sex)]
            break
        end
    end
    -- print("开启的元素技能id>>>>>>>>>>",self.eleSkillId)
    local imglock = self.eleSkillBtn:GetChild("iconloack")
    if self.eleSkillId ~= 0 then
        self.isOpenEleSkill = true
        local data = conf.SkillConf:getSkillConfByid(self.eleSkillId)
        local preid = data and data.s_pre
        local id = conf.SkillConf:getSkillIcon(preid)
        local coolTime = data and data.cool_time
        self.coolDataEle[self.eleSkillId] = {totalTime = coolTime, curTime = coolTime, btn=self.eleSkillBtn, cool=false}
        self.eleSkillBtn.icon = ResPath.iconRes(id)
        imglock.visible = false
    else
        imglock.visible = true
    end

end

function BtnFight:initView()
    -- body
    --技能栏
    self.btnlist = {}
    local sex = cache.PlayerCache:getSex()

    for i = 1 , 2 do
        local sId = self.twoskill[i]
        local key = "skill"..i
        local btn = self.parent.view:GetChild(key)
        btn.data = key
        btn.onClick:Add(self.onClickSkillEvent, self)
        local mask = btn:GetChild("n6").asImage
        mask.fillAmount = 0
        self.coolDataTwo[sId] = btn

        table.insert(self.btnlist,btn)
    end
    self:checkTwoBtn()
    --元素技能
    self.eleSkillBtn = self.parent.view:GetChild("eleskill")
    self.eleSkillBtn.data = "eleskill"
    local mask = self.eleSkillBtn:GetChild("n6").asImage
    mask.fillAmount = 0
    self.eleSkillBtn.onClick:Add(self.onClickSkillEvent, self)
    table.insert(self.btnlist,self.eleSkillBtn)
        
    self:checkEleSkillAct()

    for i=2,10 do
        if i ~= 8 then
            local key = "n3"..string.format("%02d",i)
            local btn = self.parent.view:GetChild(key)
            btn.data = key
            btn.onClick:Add(self.onClickSkillEvent, self)
            table.insert(self.btnlist,btn)

            if key == "n305" or key == "n306" or key == "n307" then
                local mask = btn:GetChild("n6").asImage
                mask.fillAmount = 0
                --btn:GetChild("title").visible = false
                local sId = self.testSkillIds[i-4][sex]
                mgr.HookMgr:updateSkills(sId, true)
                -- if cache.TaskCache:isfinish(self.needTaskId[key]) then
                --     mgr.HookMgr:updateSkills(sId, false)
                -- else
                --     mgr.HookMgr:updateSkills(sId, true)
                -- end
                local imglock = btn:GetChild("iconloack")
                local data = conf.SkillConf:getSkillConfByid(sId)
                local preid = data and data.s_pre
                local id = conf.SkillConf:getSkillIcon(preid)
                local coolTime = data and data.cool_time
                self.coolData[sId] = {totalTime = coolTime, curTime = coolTime, btn=btn, cool=false}
                if g_ios_test then
                    btn.icon = UIItemRes.iosMainIossh..id
                else
                    btn.icon = ResPath.iconRes(id) --UIPackage.GetItemURL("_icons" ,tostring(id))
                    imglock.visible = true
                end

            elseif key == "n304" then
                --默认伙伴头像
                self.btnHuoban = btn
                self:checkHuoban()
                self.btnHuoban:SetScale(0,0) --EVE 屏蔽掉，这个位置换成剑神按钮，下同
            elseif "n303" == key then--
                self.coolBianshen = btn
            elseif "n310" == key then
                self.btnHuoban310 = btn
                self.btnHuoban310:SetScale(0,0) --EVE 屏蔽掉
            elseif "n309" ==key then
                local mask = btn:GetChild("n6").asImage
                mask.fillAmount = 0
                btn.touchable = true
            end
        end
    end
    local key = "n281"
    local btn = self.parent.view:GetChild(key)
    btn.data = key
    btn.onClick:Add(self.onClickSkillEvent, self)

    local key = "n414"
    local btn = self.parent.view:GetChild(key)
    btn.data = key
    btn.onClick:Add(self.onClickSkillEvent, self)

    self:setHookState()
    self:coolDownBianshen()

    local changeTarBtn = self.parent.view:GetChild("nchangetar")
    changeTarBtn.onClick:Add(self.onChangeSelectTar, self)
end

function BtnFight:onChangeSelectTar()
    fight.SelectRule:changeSelectThing()
end

----变性之后
function BtnFight:setSkillIcon()
    -- body
    local t = {"n305","n306","n307","eleskill"}
    local sex = cache.PlayerCache:getSex()
    for k ,v in pairs(t) do
        if v == "eleskill" then
            self:checkEleSkillAct()
        else
            local btn = self.parent.view:GetChild(v)
            local sId = self.testSkillIds[k][sex]
            local data = conf.SkillConf:getSkillConfByid(sId)
            local preid = data and data.s_pre
            local id = conf.SkillConf:getSkillIcon(preid)     
            btn:GetChild("icon").url = ResPath.iconRes(id) 
            local coolTime = data and data.cool_time
            
            self.coolData[sId] = {totalTime = coolTime, curTime = coolTime, btn=btn, cool=false}
            mgr.HookMgr:updateSkills(sId, true)
        end
    end
end

--检查伙伴头像
function BtnFight:checkHuoban()
    -- body
    local id = cache.PlayerCache:getSkins(Skins.huoban)
    if not id or id == 0 then
        id = GuDingmodel[4]  
    end
    local condata = conf.HuobanConf:getSkinsByModle(id, 0)
    self.btnHuoban.icon =ResPath.iconRes(condata.icon) 

    local icon_type1 = self.btnHuoban:GetChild("n9")
    icon_type1.visible = true
    --plog("...",condata.type[1])
    local var 
    if condata.type[1] == 1 then
        var = "huoban_041"
    elseif condata.type[1] == 2 then
        var = "huoban_040"
    else
        var = "huoban_039"
    end

    icon_type1.url = ResPath.imgfontsRes(var) --UIItemRes.huoban02[condata.type[1]] 

end
--检测技能按钮
function BtnFight:checkFight()
    -- body
    for k , v in pairs(self.testSkillIds) do
        local name 
        if k == 1 then
            name = "n305"
        elseif k == 2 then 
            name = "n306"
        else
            name = "n307"
        end
        if self.needTaskId[name] and not self.skillOpenMark[name] then
            if cache.TaskCache:isfinish(self.needTaskId[name]) then
                self.skillOpenMark[name] = true
                mgr.HookMgr:updateSkills(v[cache.PlayerCache:getSex()], false)
            end
        end
    end

    if not mgr.ModuleMgr:CheckView(1006) then
        self.btnHuoban.visible = false
        self.btnHuoban310.visible  = false
    end
end
--看看任务是否开启了
function BtnFight:checkIsOk(k)
    -- body
    local name 
    if k == 1 then
        name = "n305"
    elseif k == 2 then 
        name = "n306"
    else
        name = "n307"
    end
    if cache.TaskCache:isfinish(self.needTaskId[name]) then
        return true
    end
    return false
end

function BtnFight:isSee(flag)
    -- body
    --self.flag = flag
    --plog("self.btnlist",flag)
    for k , v in pairs(self.btnlist) do
        if self.needTaskId[v.name] then
            v.visible = flag
            if flag then
                if not cache.TaskCache:isfinish(self.needTaskId[v.name]) then
                    v:GetChild("iconloack").visible = true
                else
                    v:GetChild("iconloack").visible = false
                end
            end
            -- if cache.TaskCache:isfinish(self.needTaskId[v.name]) then
            --    v.visible = flag
            -- else
            --     v.visible = false
            -- end
        else
            if v.name == "skill1" or v.name == "skill2" then 
                -- if cache.PlayerCache:getRoleLevel() < conf.SysConf:getValue("two_btn_see") then
                --     v.visible = false
                -- elseif cache.PlayerCache:getRoleLevel() < conf.SysConf:getValue("two_btn_lock") then
                --     v.visible = flag
                --     v:GetChild("iconloack").visible = false
                local key = self.twoskill[1]
                if v.name == "skill2" then
                    key = self.twoskill[2]
                end
                local equip = cache.PackCache:getEquipDataByPart(self.part[key])
                if equip then
                    local condata = conf.ItemConf:getItem(equip.mid)
                    if condata.skill_affect_id then
                        v:GetChild("iconloack").visible = false
                        v.visible = flag
                    else
                        v.visible = false
                    end
                else
                    v.visible = false
                end
            elseif v.name == "n303" then --变身看红点
                --看看是否在特殊副本里面
                if cache.PlayerCache:getSId() == Fuben.juqing then
                    v:GetChild("iconloack").visible = false
                    -- local view = mgr.ViewMgr:get(ViewName.GuideLayer)
                    -- local view1 = mgr.ViewMgr:get(ViewName.GuideDialog)
                    -- if view or view1 then
                    --     v.visible = false
                    -- else
                    --     v.visible = true
                    -- end
                else
                    v.visible = flag
                    if flag then
                        if cache.PlayerCache:getRedPointById(10205) > 0 then
                            v:GetChild("iconloack").visible = false
                        else
                            v:GetChild("iconloack").visible = true
                        end
                    end
                    -- if cache.PlayerCache:getRedPointById(10205) > 0 then
                    --     v.visible = flag
                    -- else
                    --     v.visible = false
                    -- end
                end
            elseif v.name == "n310" or v.name == "n304" then
                if mgr.ModuleMgr:CheckView(1006) then
                    v.visible = flag
                else
                    v.visible = false
                end
            elseif v.name == "eleskill" then
                if flag then
                    v.visible = self.isOpenEleSkill
                else
                    v.visible = false
                end
            else
                v.visible = flag
            end
        end
    end
end

function BtnFight:onClickSkillEvent(context)
    -- body
    local btn = context.sender
    local key = btn.data
    local sex = cache.PlayerCache:getSex()
    local sId = cache.PlayerCache:getSId()
    if "n281" == key then  --挂机
        cache.FubenCache:setChooseBossId(0)--点击挂机按钮取消选中的boss（世界boss和boss之家）
        --4、玩家在战场中不能使用飞鞋，不能使用挂机。跨服三界争霸
        if mgr.FubenMgr:isKuaFuWar(sId) then
            GComAlter(language.gonggong89)
            return
        end
        local view = mgr.ViewMgr:get(ViewName.AutoFindView)
        if mgr.HookMgr.isHook then
            mgr.HookMgr:cancelHook()
            mgr.HookMgr:setPickState(false)--开启拾取状态
        elseif view and view.c1.selectedIndex == 0 then
            mgr.TaskMgr:stopTask()
        else
            if mgr.FubenMgr:isJuqingFuben(sId) then
                mgr.HookMgr:startHook()
            else
                mgr.HookMgr:enterHook()
            end
            
            if mgr.FubenMgr:isWorldBoss(sId) and cache.FubenCache:getBossChest() then
                mgr.HookMgr:setPickState(true)--开启拾取状态
            end
        end
        CClearPickView()
        GCancelPick()
    elseif "n302" == key then --基础攻击
        gRole:baseAttack()
        CClearPickView()
        GCancelPick()
    elseif "n303" == key then --变声
        if mgr.FubenMgr:isMeiliBeach(cache.PlayerCache:getSId()) then
            GComAlter(language.gonggong122)
            return
        end
        

        if not gRole.isChangeBody and gRole:getStateID()~= 2 then
            local id = cache.PlayerCache:getSex() == 1 and 7 or 8

            if sId == Fuben.juqing then
                mgr.SoundMgr:playSound(Audios[id])
                gRole:skillAttack(5050101)
            else
                if cache.PlayerCache:getRedPointById(10205) <= 0 then
                    GComAlter(language.gonggong111)
                    return
                end
                if not self.st2 then

                    mgr.SoundMgr:playSound(Audios[id])
                    gRole:skillAttack(jsSkill)
                else
                    GComAlter(language.mian10)
                end
            end
        end
    elseif "n304" == key then --伙伴技能
        mgr.ViewMgr:openView(ViewName.HuoBanChange,function(view)
            -- body
            -- EVE 选中状态更改
            local id = 1001003

            local var = cache.PlayerCache:getSkins(Skins.huoban)
            if var~= 0 then                        
                id = conf.HuobanConf:getSkinsByModel(var,0).id
            end
            view:setData(id)
            proxy.HuobanProxy:send(1200101)
        end)
    elseif "n305" == key then --技能1
        if cache.TaskCache:isfinish(self.needTaskId[key]) then
            gRole:skillAttack(self.testSkillIds[1][sex])
        else
            GComAlter(language.gonggong111)
        end
    elseif "n306" == key then --技能2
        if cache.TaskCache:isfinish(self.needTaskId[key]) then
            gRole:skillAttack(self.testSkillIds[2][sex])
        else
            GComAlter(language.gonggong111)
        end
    elseif "n307" == key then --技能3
        if cache.TaskCache:isfinish(self.needTaskId[key]) then
            gRole:skillAttack(self.testSkillIds[3][sex])
        else
            GComAlter(language.gonggong111)
        end
    elseif "skill1" ==key then
        local index = self.twoskill[1]
        local equip = cache.PackCache:getEquipDataByPart(self.part[index])
        if not equip then
            GComAlter(language.gonggong109)
            return
        else
            local condata = conf.ItemConf:getItem(equip.mid)
            if not condata.skill_affect_id then
                return GComAlter(language.gonggong112)
            end
        end
        gRole:skillAttack(index)
    elseif "skill2" ==key then
        local index = self.twoskill[2]
        local equip = cache.PackCache:getEquipDataByPart(self.part[index])
        if not equip then
            GComAlter(language.gonggong109)
            return
        else
            local condata = conf.ItemConf:getItem(equip.mid)
            if not condata.skill_affect_id then
                return GComAlter(language.gonggong113)
            end
        end
        gRole:skillAttack(index)
    elseif "eleskill" == key then
        if self.eleSkillId == 0 then
            GComAlter(language.skill23)
            return
        else
            gRole:skillAttack(self.eleSkillId)
        end
    elseif "n308" == key then
    elseif "n309" == key then --跳的动作
        if mgr.FubenMgr:isHome(cache.PlayerCache:getSId()) then
            GComAlter(language.home135)
            return
        elseif mgr.FubenMgr:isMeiliBeach(cache.PlayerCache:getSId()) then
            GComAlter(language.gonggong121)
            return
        end

        mgr.TaskMgr.mState = 0 --设置为自动取消任务
        mgr.ModuleMgr:closeFindPath(0) --自动寻路关闭
        if not gRole:isDingShen() then
            mgr.JumpMgr:skillJump()
            if not self.timer and not self.clickTime then
                --开始CD
                self.clickTime = os.time()
                -- print("记录时间")
                self.timer = self.parent:addTimer(0.03, -1, handler(self, self.coolJum))
            end
        end
        mgr.FightMgr:removeTimer()
        CClearPickView()
        GCancelPick()
    elseif "n310" == key then--改变伙伴技能
        mgr.ViewMgr:openView(ViewName.HuoBanChange,function(view)
            -- body
            local id = 1001003

            local var = cache.PlayerCache:getSkins(Skins.huoban)
            if var~= 0 then             
                id = conf.HuobanConf:getSkinsByModel(var,0).id
            end
            view:setData(id)
            proxy.HuobanProxy:send(1200101)
        end)
    elseif "n414" == key  then 
        --附近玩家
        mgr.ViewMgr:openView2(ViewName.NearPlayer)
    end
end

--设置挂机按钮状态
function BtnFight:setHookState()
    if mgr.FubenMgr:isKuaFuWar(cache.PlayerCache:getSId()) then
        return
    end
    
    local btn = self.parent.view:GetChild("n281")
    local icon = btn:GetChild("icon")
    local urlT = UIItemRes.hook01
    if g_ios_test then
        urlT = UIItemRes.iosMainIossh04
    end
    local view = mgr.ViewMgr:get(ViewName.AutoFindView)
    if mgr.HookMgr.isHook then
        mgr.ModuleMgr:startFindPath(1)
        if mgr.HookMgr:isInterimHook() then--临时挂机
            icon.url = urlT[3]
        else
            icon.url = urlT[2]
        end
        --进入挂机的时候 检测是否能变身
        --self:AutoChange()
    elseif view and view.c1.selectedIndex == 0 then
        icon.url = urlT[2]
    else
        icon.url = urlT[1]
        mgr.ModuleMgr:closeFindPath(1)
    end
end

function BtnFight:AutoChange()
    -- body
    if cache.PlayerCache:getSId() ~= Fuben.juqing then
        if cache.PlayerCache:getRedPointById(10205) > 0 
        and not gRole.isChangeBody 
        and not self.st2 
        and mgr.HookMgr.isHook 
        and gRole:getStateID()~=2 then
            gRole:skillAttack(jsSkill)
            return true
        end
    end
    return false
end

function BtnFight:coolJum()
    -- body
    --场景判断
    local btn = self.parent.view:GetChild("n309")
    local mask = btn:GetChild("n6").asImage
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isWenDing(sId) 
        or mgr.FubenMgr:isGangWar(sId) 
        or HuangLingScene == sId 
        or mgr.FubenMgr:isXianMoWar(sId) 
        or mgr.FubenMgr:isKuaFuWar(sId)  then
    else
        local buff = mgr.BuffMgr:getBuffByid(cache.PlayerCache:getRoleId())
        local flag = false
        if buff then
            for k ,v in pairs(buff) do
                if v.modelId == BuffSysId.jump then
                    flag = true
                    break
                end
            end
        end
        --不存在这个buff
        if not flag then
            return
        end
    end
    local nowTime = os.time()

    local sign = false
    if nowTime - self.clickTime >= 1 then
        sign = true
        btn.touchable = false
        -- print("清除计时器")
        if self.timer then
            self.parent:removeTimer(self.timer)
            self.timer = nil
            self.clickTime = nil
        end
    else
        sign = false
    end
    if sign then
        -- print("技能冷却")
        sign = false
        local conddata = conf.BuffConf:getBuffConf(BuffSysId.jump)
        btn.touchable = false
        mask.fillAmount = 0
        
        local maxtime = conddata.effect_time/1000
        local times = maxtime*10
        local onetime = 0.2
        if not self.timer2 then
            self.timer2 = self.parent:addTimer(onetime,maxtime/onetime,function()
                times = times - (onetime*10)
                mask.fillAmount  =  times/(maxtime*10)

                if times <= 0 or mask.fillAmount == 0 then
                    --plog("com here")
                    btn.touchable = true
                    mask.fillAmount = 0
                    if self.timer2 then
                        self.parent:removeTimer(self.timer2)
                        self.timer2 = nil
                    end
                end
            end)
        end
    end
end

function BtnFight:coolDown(sId)
    if not sId then
        return
    end
    if self.eleSkill[sId] then
        self:coolDownEle(sId)
        return
    end

    if self.part[sId] then
        self:coolDownEquip(sId)
        return
    end

    if not self.coolData[sId] then return end
    local sex = cache.PlayerCache:getSex()
    for i=1, 3 do
        local key = self.testSkillIds[i][sex]
        local coolInfo = self.coolData[key]
        if coolInfo.cool == false and self:checkIsOk(i)  then
            local data = conf.SkillConf:getSkillConfByid(sId)
            local coolTime = data and data.cool_time
            if key == sId then
                coolInfo.totalTime = coolTime
                coolInfo.curTime = coolTime
                coolInfo.cool = true
            else
                coolInfo.totalTime = 1
                coolInfo.curTime = 1
            end
            local btn = coolInfo.btn
            btn.touchable = false
            local totalT = coolInfo.totalTime
            local cutT = coolInfo.curTime
            local mask = btn:GetChild("n6").asImage
            local shap = btn:GetChild("n9")
            mgr.HookMgr:updateSkills(key, true)
            local delay = 0.2
            mask.fillAmount = 1-(totalT - cutT) / totalT
            local coolTimer = self.parent:addTimer(delay, math.ceil(totalT/delay), function()
                self.coolData[key].curTime = self.coolData[key].curTime - delay
                local mask = btn:GetChild("n6").asImage
                mask.fillAmount = 1-(totalT - self.coolData[key].curTime) / totalT
                if self.coolData[key].curTime < 0.1 then
                    btn.touchable = true
                    self.coolData[key].curTime = self.coolData[key].totalTime
                    mgr.HookMgr:updateSkills(key, false)
                    self.coolData[key].cool = false
                    mask.fillAmount = 0

                    if key == sId then 
                        self:playEff(shap,4020106)
                        --local effect = self.parent:addEffect(4020106,)
                        --effect.LocalPosition = Vector3.New(shap.width/2,-shap/2,0)
                    end
                end
            end)
        end
        
    end
end

--八门元素技能冷却
function BtnFight:coolDownEle(sId)
    local sex = cache.PlayerCache:getSex()
    local skillconf = conf.SkillConf:getSkillConfByid(sId)
    if not skillconf then
        print("skill_config 缺少 ,",sId)
        return
    end
    local btn = self.eleSkillBtn
    local mask = btn:GetChild("n6").asImage
    local shap = btn:GetChild("n9")

    if self.coolTimer[sId] then
        self.parent:removeTimer(self.coolTimer[sId])
    end

    local delay = 0.2
    local needTime = (skillconf.cool_time or 60)
    local totalT = (skillconf.cool_time or 60)
    --print("配置的cd = ",totalT)
    self.coolTimer[sId] = self.parent:addTimer(delay, -1, function()
        -- body
        btn.touchable = false
        needTime = needTime - delay
        mask.fillAmount = needTime / totalT

        if needTime < 0.1 then
            btn.touchable = true
            mask.fillAmount = 0
            self:playEff(shap,4020106)
            self.parent:removeTimer(self.coolTimer[sId])
        end
    end)
end

function BtnFight:playEff(panel,id)
    if panel.data then
        self.parent:removeUIEffect(panel.data)
        panel.data = nil
    end
    panel.data = self.parent:addEffect(id,panel)
    panel.data.LocalPosition = Vector3.New(panel.width/2,-panel.height/2,-50)
end

function BtnFight:coolDownBianshen()
    -- body
    --检测是否在变身状态
    if not gRole then
        return
    end


    local id = (gRole and gRole.isChangeBody) and 2 or 1
    local btn = self.coolBianshen
    local icon = btn:GetChild("icon")
    local mask = btn:GetChild("n10").asImage
    local effect = btn:GetChild("n13")


    local delay = 0.2
    if cache.PlayerCache:getSId() == Fuben.juqing then
        --特殊副本处理
        btn.touchable = true
        mask.fillAmount = 0
        self.st2 = nil 
        return 
    end

    if cache.PlayerCache:getRedPointById(10205) <= 0 then
        btn.touchable = true
        mask.fillAmount = 0
        self.st2 = nil 
        return
    end 

    local buff = conf.BuffConf:getBuffConf(6010101)
    if id == 2 then
        if self.st1 then return end
        if self.st2 then
            self.parent:removeTimer(self.st2)
            self.st2 = nil 
        end
        self:playEff(effect,4020119)
        UPlayerPrefs.SetInt(g_var.accountId.."buffbs",mgr.NetMgr:getServerTime()) 
        local totalT = math.ceil(buff.effect_time / 1000)
        local curTime = 0
        local delay = 0.2
        self.st1 = self.parent:addTimer(delay,-1,function()
            curTime = curTime + delay
            mask.fillAmount = (totalT-curTime)/totalT
            if curTime >= totalT then
                btn.touchable = true
                self.parent:removeTimer(self.st1)
                self.st1 = nil
            end
        end)
    else
        if self.st2 then return end
        if self.st1 then
            self.parent:removeTimer(self.st1)
            self.st1 = nil 
        end
        if effect.data then
            self.parent:removeUIEffect(effect.data)
            effect.data = nil
        end
        --未变身的时候
        local totalT = math.ceil(buff.effect_cd / 1000) 
        local curTime = 0
        local var = UPlayerPrefs.GetInt(g_var.accountId.."buffbs")
        if var ~= 0 then
            curTime = mgr.NetMgr:getServerTime() - var - math.ceil(buff.effect_time / 1000)
        end
        if curTime < 0 then
            curTime = 0
        end

        if curTime>= totalT then --已经可以变身了
            self.parent:removeTimer(self.st2) 
            self.st2 = nil 
            self:playEff(effect,4020120)
            btn.touchable = true
            --self:AutoChange()
            return 
        end
        local index = 0
        local max = math.ceil(totalT/delay)
        self.st2 = self.parent:addTimer(delay,-1,function()
            index = index + 1 
            curTime = curTime + delay
            mask.fillAmount = curTime/totalT
            if curTime>= totalT then --已经可以变身了
                btn.touchable = true
                self.parent:removeTimer(self.st2) 
                self.st2 = nil 
                self:playEff(effect,4020120)
            elseif index >= max then
                btn.touchable = true
                mask.fillAmount = 1
                self.parent:removeTimer(self.st2)
                self.st2 = nil  
                self:playEff(effect,4020120)
            end
        end)
    end
end


function BtnFight:coolDownEquip(sId)
    -- body
    local key = sId
    local equip = cache.PackCache:getEquipDataByPart(self.part[key])
    if not equip then
        print("没有装备不该进入cd")
        return
    end
    local condata = conf.ItemConf:getItem(equip.mid)
    if not condata then
        return
    end
    if not condata.skill_affect_id then
        print("缺少装备技能作用id")
        return
    end
    local skillconf = conf.SkillConf:getSkillByIndex(condata.skill_affect_id)
    if not skillconf then
        print("skill_affect 缺少 ,",condata.skill_affect_id)
        return
    end

    local btn = self.coolDataTwo[key]
    local mask = btn:GetChild("n6").asImage
    local shap = btn:GetChild("n9")

    if self.coolTimer[sId] then
        self.parent:removeTimer(self.coolTimer[sId])
    end

    local delay = 0.2
    local needTime = (skillconf.cd_time or 5000)/1000
    local totalT = (skillconf.cd_time or 5000)/1000
    --print("配置的cd = ",totalT)
    self.coolTimer[sId] = self.parent:addTimer(delay, -1, function()
        -- body
        btn.touchable = false
        needTime = needTime - delay
        mask.fillAmount = needTime / totalT

        if needTime < 0.1 then
            btn.touchable = true
            mask.fillAmount = 0
            self:playEff(shap,4020106)
            self.parent:removeTimer(self.coolTimer[sId])
        end
    end)
end

function BtnFight:getCurCanUse()
    -- body
    --获取当前可以使用装备技能
    for k , v in pairs(self.twoskill) do
        local equip = cache.PackCache:getEquipDataByPart(self.part[v])
        if equip then
            --有装备
            local condata = conf.ItemConf:getItem(equip.mid)
            local btn = self.coolDataTwo[v]
            local mask = btn:GetChild("n6").asImage
            if btn.touchable and mask.fillAmount == 0 then
                return v 
            end
        end
    end
    return 
end

return BtnFight