--
-- Author: 
-- Date: 2017-04-27 21:00:19
--

local GuideActive = class("GuideActive", base.BaseView)

function GuideActive:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level4 
    self.drawcall = false
end
function GuideActive:initData(data)
    -- body
    self.data = data

    if self.model.data then
        self:removeModel(self.model.data)
        self.model.data = nil 
    end
    self.icon.url = nil 
    self.power.text = 0
    self.img:SetScale(-1,1)

    self:setData()

    -- --10秒消失
    -- self:addTimer(10, 1, function()
    --     -- body
    --     self:onCloseView()
    -- end)
end
function GuideActive:initView()
    local btnClose = self.view:GetChild("n7")
    btnClose.onClick:Add(self.onCloseView,self)

    local btnCZ = self.view:GetChild("n6")
    btnCZ.onClick:Add(self.onbtnCz,self)

    self.c1 = self.view:GetController("c1")

    --模型
    self.model = self.view:GetChild("n2")
    --图片
    self.icon = self.view:GetChild("n11")
    --战力
    self.power = self.view:GetChild("n9")

    self.groud = self.view:GetChild("n10")
    self.img = self.view:GetChild("n0")
end

function GuideActive:setData(data_)
    local confData = {}
    if self.data.id == 1058 then --百倍礼包
        self.c1.selectedIndex = 0

        confData = conf.ActivityConf:getBaibeiGiftData(self.data.param+1)
        
        self.view:GetChild("n12").url = UIPackage.GetItemURL("guide" , "xinshouyingdao_062")
        self.power.text = 15522--power

        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            local pairs = pairs
            local topos
            for k ,v in pairs(view.TopActive.btnlist) do
                for i , j in pairs(v) do
                    if j.data and j.data.id == 1058 then
                        topos = j.xy + j.parent.xy
                        break
                    end
                end
            end
            if topos then
                self.groud.xy = topos
                self.groud.x = self.groud.x - 50
                self.groud.y = self.groud.y + 50 
            end
        end
    elseif self.data.id == 1114 then --百倍礼包
        self.c1.selectedIndex = 0

        --confData = conf.ActivityConf:getBaibeiGiftData(self.data.param+1)
        
        self.view:GetChild("n12").url = UIPackage.GetItemURL("guide" , "xinshouyingdao_062")
        self.power.text = 15522--power

        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            local pairs = pairs
            local topos
            for k ,v in pairs(view.TopActive.btnlist) do
                for i , j in pairs(v) do
                    if j.data and j.data.id == 1114 then
                        topos = j.xy + j.parent.xy
                        break
                    end
                end
            end
            if topos then
                self.groud.xy = topos
                self.groud.x = self.groud.x - 50
                self.groud.y = self.groud.y + 50 
            end
        end
    elseif self.data.id == 1063 then
        self.c1.selectedIndex = 1
        confData = conf.VipChargeConf:getAffectDataById(self.data.param+1)
        self.view:GetChild("n12").url = UIPackage.GetItemURL("guide" , "xinshouyingdao_061")
        self.power.text = 44351

        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            local topo = view.view:GetChild("n5041")
            self.groud.xy = topo.xy
            self.groud.x = self.groud.x - 50
            self.groud.y = self.groud.y + 30 
        end
    elseif self.data.id == 1059 then
        self.c1.selectedIndex = 2
        self.icon.visible = true
        self.icon.url = UIPackage.GetItemURL("guide" , "xinshouyingdao_117")
        self.view:GetChild("n12").url = UIPackage.GetItemURL("guide" , "xinshouyingdao_105")
        --self.icon.url 
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            local pairs = pairs
            local topos
            for k ,v in pairs(view.TopActive.btnlist) do
                for i , j in pairs(v) do
                    if j.data and j.data.id == 1059 then
                        topos = j.xy + j.parent.xy
                        break
                    end
                end
            end
            if topos then
                self.groud.xy = topos
                self.groud.x = self.groud.x - 50
                self.groud.y = self.groud.y + 50 
            end
        end
    elseif self.data.id == 1111 then--夏日抽奖活动推送
        self.c1.selectedIndex = 3
        self.icon.visible = false
        local sex = cache.PlayerCache:getSex()
        local shizhuangConf = conf.ActivityConf:getSummerAwardsById(1)
        local wuqiConf = conf.ActivityConf:getSummerAwardsById(3)
        local shizhuangMid = shizhuangConf[1][1]
        local wuqiMid = wuqiConf[1][1]
        if sex == 2 then
            shizhuangMid = shizhuangConf[2][1]
            wuqiMid = wuqiConf[2][1]
        end

        local skinId1 = conf.ItemConf:getItemExt(shizhuangMid)
        local skinId2 = conf.ItemConf:getItemExt(wuqiMid)
        local confData1 = conf.RoleConf:getFashData(skinId1)
        local confData2 = conf.RoleConf:getFashData(skinId2)

        --confData = conf.RoleConf:getFashData(skinId)
        confData.model_id = {
            {confData1.model,confData2.model},
            {confData1.model,confData2.model}
        }
        confData.pos = {0,-100,100}
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            local pairs = pairs
            local topos
            for k ,v in pairs(view.TopActive.btnlist) do
                for i , j in pairs(v) do
                    if j.data and j.data.id == 1111 then
                        topos = j.xy + j.parent.xy
                        break
                    end
                end
            end
            if topos then
                self.groud.xy = topos
                self.groud.x = self.groud.x - 50
                self.groud.y = self.groud.y + 50 
            end
            cache.PlayerCache:setAttribute(attConst.A10322,0)
        end
    elseif self.data.id == 1054 then
        self.c1.selectedIndex = 1
        self.icon.visible = false
        self.view:GetChild("n12").url = UIPackage.GetItemURL("guide" , "xinshouyingdao_019")
        self.view:GetChild("n13").url = UIPackage.GetItemURL("guide" , "xinshouyingdao_020")
        --local _confdata = conf.ActivityConf:getReward(1)
        self.effect = self:addEffect(4020209,self.model)
        self.effect.Scale = Vector3.New(40,40,40)
        self.effect.LocalPosition = Vector3(-12,23,500)
        local item = conf.ItemConf:getItem(112999969)
        self.power.text = item.power

        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            local pairs = pairs
            local topos
            for k ,v in pairs(view.TopActive.btnlist) do
                for i , j in pairs(v) do
                    if j.data and j.data.id == 1054 then
                        topos = j.xy + j.parent.xy
                        break
                    end
                end
            end
            if topos then
                self.groud.xy = topos
                self.groud.x = self.groud.x - 50
                self.groud.y = self.groud.y + 50 
            end
        end
    end
    --模型图片展示
    local modelId = confData.model_id
    plog("modelId",modelId,type(modelId))
    if modelId then
        if type(modelId) == "number" or type(modelId) == "table" then
            if self.effect then
                self:removeUIEffect(self.effect)
                self.effect = nil
            end
            local pos = confData.pos or {0,-500,1100}
            local xyz = confData.xyz or {0,160,0}
            self.modelObj = nil
            if type(modelId) == "table" then
                local sex = cache.PlayerCache:getSex()
                if sex == 1 then
                    self.modelObj = self:addModel(modelId[1][1],self.model)
                    self.modelObj:setSkins(nil,modelId[1][2])
                else
                    self.modelObj = self:addModel(modelId[2][1],self.model)
                    self.modelObj:setSkins(nil,modelId[2][2])
                end
            else
                self.modelObj = self:addModel(modelId,self.model)
            end
            self.modelObj:setRotationXYZ(xyz[1],xyz[2],xyz[3])
            local scale = confData.scale or 100
            self.modelObj:setScale(scale)
            local offy = 0
            if self.data.id == 1058 then
                offy = -30
                self.modelObj:setScale(100)
            elseif self.data.id == 1063 then
                offy = 40
            end
            if self.data.id == 1111 then
                self.modelObj:setPosition(pos[1], pos[2]+offy,pos[3])
            else
                self.modelObj:setPosition(pos[1], pos[2]+offy,0)
            end

            

            self.icon.visible = false
        elseif type(modelId) == "string" then
            self.icon.visible = true
            if self.modelObj then
                self:removeModel(self.modelObj)
                self.modelObj = nil
            end
            self.icon.url = UIPackage.GetItemURL("guide" , modelId)
            self.icon.visible = true
        end
    end
end

function GuideActive:onbtnCz()
    -- body
    --GGoVipTequan(0)
    if self.c1.selectedIndex == 1 then
        if self.data.id == 1054 then
            GOpenView({id = 1054})
        else
            GGoVipTequan(2)
        end
    elseif self.c1.selectedIndex == 0 then
        GOpenView({id = self.data.id})
    elseif self.c1.selectedIndex == 2 then
        GOpenView({id = 1059})
    elseif self.c1.selectedIndex == 3 then
        GOpenView({id = 1111})
    end
    self:onCloseView()
end

function GuideActive:onCloseView()
    -- body
    self.effect = nil
    self.modelObj = nil
    self:closeView()
end

return GuideActive