--
-- Author: 
-- Date: 2017-04-22 16:52:48
--

local GuideZuoqi = class("GuideZuoqi", base.BaseView)

function GuideZuoqi:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level4
end

function GuideZuoqi:initData(data)
    -- body
    if not data.index then --去当前模型
        self.data = data
        self.c1.selectedIndex = 10
    else
        self.data = data 
        self.c1.selectedIndex = data.index
    end
    if data.isXianzun then
        self.isXianzun = true
    else
        self.isXianzun = false        
    end
    if data.isQitian then
        self.isQitian = true
    else
        self.isQitian = false
    end
    self.t0:Stop()
    self:setData()
    --gRole:idleBehaviour()
end

function GuideZuoqi:initView()
    self.btnGet = self.view:GetChild("n5")
    self.btnGet.onClick:Add(self.onCloseView,self)

    self.effect = self.view:GetChild("n7") 

    self.c1 = self.view:GetController("c1")

    self.t0 = self.view:GetTransition("t0")

    self.model = self.view:GetChild("n2")

    self.image = self.view:GetChild("n9")
end

function GuideZuoqi:setData()
    local effect = self:addEffect(4020114,self.effect)
    effect.LocalPosition = Vector3.New(self.effect.width/2,-self.effect.height/2,500)

    local condata 
    if self.c1.selectedIndex == 0 then --坐骑
        condata = conf.ZuoQiConf:getSkinsByIndex(self.data.id,0)
    elseif self.c1.selectedIndex == 1 then --神兵
        condata = conf.ZuoQiConf:getSkinsByIndex(self.data.id,1)
    elseif self.c1.selectedIndex == 2 then--法宝
        condata = conf.ZuoQiConf:getSkinsByIndex(self.data.id,2)
    elseif self.c1.selectedIndex == 3 then--仙羽
        condata = conf.ZuoQiConf:getSkinsByIndex(self.data.id,3)
    elseif self.c1.selectedIndex == 4 then--仙器
        condata = conf.ZuoQiConf:getSkinsByIndex(self.data.id,4)
    elseif self.c1.selectedIndex == 5 then--伙伴
        condata = conf.HuobanConf:getSkinsByIndex(self.data.id,0)
    elseif self.c1.selectedIndex == 6 then--伙伴神兵开启
        condata = conf.HuobanConf:getSkinsByIndex(self.data.id,2)
    elseif self.c1.selectedIndex == 7 then--伙伴仙羽开启
        condata = conf.HuobanConf:getSkinsByIndex(self.data.id,1)
    elseif self.c1.selectedIndex == 8 then--伙伴仙器开启
        condata = conf.HuobanConf:getSkinsByIndex(self.data.id,4)
    elseif self.c1.selectedIndex == 9 then--伙伴法宝开启
        condata = conf.HuobanConf:getSkinsByIndex(self.data.id,3)
    end

    if self.isXianzun or self.isQitian then
        self.view:GetChild("n3").visible = false
    else
        self.view:GetChild("n3").visible = true
    end
    if self.c1.selectedIndex == 0 
    or self.c1.selectedIndex == 3 
    or self.c1.selectedIndex == 5 
    or self.c1.selectedIndex == 7 then
        local obj = self:addModel(condata.modle_id,self.model)
        if self.c1.selectedIndex == 0 then
            obj:setScale(SkinsScale[Skins.zuoqi])
            obj:setRotationXYZ(0,130,0)--180
            obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-200,500)
        elseif self.c1.selectedIndex == 3 then
            obj:setSkins(GuDingmodel[1],nil,condata.modle_id)
            obj:setScale(160)
            obj:setRotationXYZ(0,330,0)--180
            obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-200,500)
        elseif self.c1.selectedIndex == 5 then
            obj:setScale(SkinsScale[Skins.huoban])
            obj:setRotationXYZ(0,180,0)--180
            obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-200,500)
        elseif self.c1.selectedIndex == 7 then
            obj:setRotationXYZ(0,135,180)
            obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-80,500)
        end
    elseif self.c1.selectedIndex == 2
    or self.c1.selectedIndex == 4 
    or self.c1.selectedIndex == 8 
    or self.c1.selectedIndex == 9 then
        local effect = self:addEffect(condata.modle_id,self.model)
        if self.c1.selectedIndex == 2 then
            self.t0:Play() --EVE
            effect.Scale = Vector3.New(300,300,300)
            effect.LocalPosition = Vector3(self.model.actualWidth/2+10,-self.model.actualHeight-150,500)
        elseif self.c1.selectedIndex == 4 then
            effect.LocalPosition = Vector3(self.model.actualWidth/2,-self.model.actualHeight-100,500)
        elseif self.c1.selectedIndex == 8 then
            self.t0:Play() --EVE
            effect.LocalPosition = Vector3(self.model.actualWidth/2+10,-self.model.actualHeight-100,500)
        elseif self.c1.selectedIndex == 9 then
            self.t0:Play() --EVE
            effect.Scale = Vector3.New(300,300,300)
            effect.LocalPosition = Vector3(self.model.actualWidth/2,-self.model.actualHeight,500)
        end
    elseif self.c1.selectedIndex == 1 then
        self.t0:Play() --EVE
        local id = cache.PlayerCache:getSkins(Skins.wuqi)
        if id == 0 then
            id = GuDingmodel[3]
        end
        local obj = self:addModel(id,self.model)
        obj:setRotationXYZ(30,90,90)
        obj:setPosition(self.model.actualWidth/2+60,-self.model.actualHeight/2-100,500)
        obj:addModelEct(condata.modle_id.."_ui")
    elseif self.c1.selectedIndex == 6 then
        local id = GuDingmodel[2]  
        -- cache.PlayerCache:getSkins(Skins.huoban)
        -- if id == 0 then 
        --     id = GuDingmodel[4]
        -- end
        local obj = self:addModel(id,self.model)
        obj:setRotationXYZ(0,180,0)--180
        obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-200,500)
        obj:addWeaponEct(condata.modle_id.."_ui")
    elseif self.c1.selectedIndex == 10 then 
        local data = cache.PlayerCache:getData()
        local skins = data.skins
        local id = self.data.param[cache.PlayerCache:getSex()] or self.data.param[1]
        local obj = self:addModel(id,self.model)
        obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-200,500)
        obj:setRotation(180)
        obj:setScale(150)
        obj:setSkins(id,skins[2],skins[3])
    elseif self.c1.selectedIndex == 11 then --剑神
        local roleIcon = cache.PlayerCache:getRoleIcon()
        local sex = GGetMsgByRoleIcon(roleIcon).sex
        local model = self.data.model or cache.PlayerCache:getSkins(Skins.clothes)
        local obj = self:addModel(model[1],self.model)
        obj:setSkins(nil,model[2],model[3])
        obj:setPosition(self.model.actualWidth/2,-350,0)
        obj:setRotation(RoleSexModel[sex].angle)
        obj:setScale(120)
    elseif self.c1.selectedIndex == 12 then --套装
        local sex = cache.PlayerCache:getSex()
        local obj = nil
        local modelId = self.data.id
        if self.isQitian then
            obj = self:addModel(modelId,self.model)
        else
            if sex == 1 then
                obj = self:addModel(modelId[1][1],self.model)
                obj:setSkins(nil,modelId[1][2])
            else
                obj = self:addModel(modelId[2][1],self.model)
                obj:setSkins(nil,modelId[2][2])
            end
        end
        obj:setRotation(RoleSexModel[sex].angle)
        obj:setPosition(self.model.actualWidth/2,-350,0)
        if self.isXianzun or self.isQitian then--钻石仙尊套装
            obj:setScale(160)
        else
            obj:setScale(100)
        end
    elseif self.c1.selectedIndex == 13 then
        --self.t0:Play()
        if self.isXianzun then--黄金仙尊展示武器
            local conf = conf.RoleConf:getFashData(self.data.id)
            self.t0:Play()
            obj = self:addModel(conf.model,self.model)
            obj:setPosition(219.6,-88.2,0)
            obj:setScale(200)
            obj:setRotationXYZ(30,90,90)
        elseif self.isQitian then --七天登陆
            local conf = conf.RoleConf:getFashData(self.data.id)
            self.t0:Play()
            obj = self:addModel(conf.model,self.model)
            obj:setPosition(250,-100,100)
            obj:setScale(200)
            obj:setRotationXYZ(30,90,90)
            -- print("武器展示")
        else--引导展示
            local effect = self:addEffect(4020201,self.model)
            effect.Scale = Vector3.New(80,80,80)
            effect.LocalPosition = Vector3(self.model.actualWidth/2,-145,500)
        end
        -- local wuqi = GuDingmodel[3]
        -- if self.isXianzun then
            -- local conf = conf.RoleConf:getFashData(self.data.id)
            -- wuqi = conf.model
        -- end
        -- self.t0:Play()
        -- obj = self:addModel(wuqi,self.model)
        -- obj:setPosition(219.6,-88.2,0)
        -- obj:setScale(200)
        -- obj:setRotationXYZ(30,90,90)
    elseif self.c1.selectedIndex == 14 then
        local confData = conf.RoleConf:getTitleData(self.data.id)
        self.image.url = UIPackage.GetItemURL("head" ,confData.scr)
    elseif self.c1.selectedIndex == 15 then
        --宠物蛋使用专用
        local confData = conf.PetConf:getPetItem(self.data.petId)

        local obj = self:addModel(confData.model,self.model)
        obj:setScale(SkinsScale[Skins.newpet])
        obj:setRotationXYZ(0,143.7,0)--180
        obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-200,500)

        self.view:GetChild("n10").text =  confData.name

        -- if confData.nameurl then
        --     self.view:GetChild("n3").url = UIPackage.GetItemURL("guide" ,confData.nameurl)
        -- end
    elseif self.c1.selectedIndex == 16 then
        --仙童
        local mid = self.data.mid
        local condata = conf.MarryConf:getPetItem(conf.ItemConf:getItemExt(mid))

        local obj = self:addModel(condata.model,self.model)
        obj:setScale(SkinsScale[Skins.newpet])
        obj:setRotationXYZ(0,180,0)--180
        obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-200,500)

        self.view:GetChild("n10").text = condata.name
    end
    mgr.SoundMgr:playSound(Audios[1])
end

function GuideZuoqi:onCloseView()
    if self.c1.selectedIndex == 16 then
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view  then
            view:goToById(1304)
        end
        local view = mgr.ViewMgr:get(ViewName.XianTongtfhz)
        if view then
            view:closeView()
        end
        self:closeView()
        return
    end
    if self.data.func then
        self.data.func()
    end
    self.data.func = nil
    if not self.isXianzun and not self.isQitian then
        local view = mgr.ViewMgr:get(ViewName.mainView)
        if view then
            if self.data and self.data.taskid then
                view:chenkOpenById(self.data.taskId)
            end
        end
        if self.data and self.data.nextguideid and self.data.nextguideid~=0 then
            local condata = conf.XinShouConf:getOpenModule(self.data.nextguideid)
            mgr.XinShouMgr:checkXinshou(condata) 
        -- elseif self.c1.selectedIndex == 1 then
        --     local condata = conf.XinShouConf:getOpenModule(1111)
        --     mgr.XinShouMgr:checkXinshou(condata)
        elseif self.c1.selectedIndex == 13 then
            if self.data.callback then 
                self.data.callback()
            end

            -- gRole:baseAttack()
            -- --GgoToMainTask()
            -- mgr.TimerMgr:addTimer(0.8, 1, function( ... )
            --     -- body
            --     GgoToMainTask()
            -- end)
        else
            --传递来的参数有任务ID 才继续任务
            local view = mgr.ViewMgr:get(ViewName.XinShouView)
            if view then
                if self.c1.selectedIndex <= 10 then
                    --任务信息检测预告
                    self:closeView()
                    GgoToMainTask()
                    --关闭的
                    mgr.XinShouMgr:checkModuleOpen()
                    return
                end
            else
                mgr.XinShouMgr:checkModuleOpen()
            end
            
        end
    end
    self:closeView()
    
end

return GuideZuoqi