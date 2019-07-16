--
-- Author: 
-- Date: 2017-04-17 21:25:02
--

local GuideLayer = class("GuideLayer", base.BaseView)

function GuideLayer:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level4
end

function GuideLayer:initData(data)
    if g_ios_test then  --EVE 屏蔽引导
        return
    end

    -- body
    self.data = data
    if data.opaque and data.opaque == 1 then--可穿透
        self.view.opaque = false
        self:addLimitGuide()
        return
    else
        self.view.opaque = true
    end
    -- if self.panel then
    --     self.panel:RemoveFromParent()
    --     self.panel = nil 
    -- end

    self.canclose = true
    if type(data) == "table" then
        --plog("1")
        if data.effect and data.tar == gRole then
            self:playGuideEff()
        elseif self.data.richang then
            local xy = data.richang.xy
            if not self.panel then
                self.panel = UIPackage.CreateObject(UICommonRes[12] , "Effect4020118")
            end
            self.panel.size = self.data.richang.size
            self.panel.xy = self.view:GlobalToLocal(self.data.richang.parent:LocalToGlobal(xy))
            self.view:AddChild(self.panel)
            local img = self.panel:GetChild("n0")
            if img.data then
                self:removeUIEffect(img.data)
                img.data = nil 
            end
            local effect = self:addEffect(4020118,img)
            effect.Scale = Vector3.New(70,70,70)
            effect.LocalPosition = Vector3.New(img.width/2,-img.height/2,0)
            img.data = effect 
        elseif self.data.btn then--
            if not self.data.btn.parent then
                self:closeView()
                return
            end
            local xy = self.data.btn.xy 
            if not self.panel then
                self.panel = UIPackage.CreateObject(UICommonRes[12] , "Effect4020118")
            end
            self.panel.size = self.data.btn.size
            self.panel.xy = self.view:GlobalToLocal(self.data.btn.parent:LocalToGlobal(xy))
            self.view:AddChild(self.panel)
            
            local img = self.panel:GetChild("n0")
            if img.data then
                self:removeUIEffect(img.data)
                img.data = nil 
            end

            
            local effect = self:addEffect(4020118,img)
            effect.Scale = Vector3.New(70,70,70)
            effect.LocalPosition = Vector3.New(img.width/2,-img.height/2,-50)
            --左右旋转
            if mgr.ModuleMgr:isInopent(self.data.btn.name) or self.data.btn.name == "btn_close" then
                if mgr.ModuleMgr:isInopent(self.data.btn.name) then
                    if self.data.btn.name == "n408" 
                        or "n402" == self.data.btn.name 
                        or self.data.btn.name == "n403"
                        or self.data.btn.name == "n404" 
                        or "n502" == self.data.btn.name then
                        effect.LocalRotation = Vector3.New(0,180,90) --特殊旋转角度
                    else
                        effect.LocalRotation = Vector3.New(0,180,0) --特殊旋转角度
                    end
                else
                    effect.LocalRotation = Vector3.New(0,180,0) --特殊旋转角度
                end
            elseif self:checkZ90(self.data.btn) then--上下旋转
                effect.LocalRotation = Vector3.New(0,180,90) --特殊旋转角度
            end  

            img.data = effect 

            if  self.data.guidedata.guideid > 3000 and self.data.guidedata.guideid<4000 then
                self:addTimer(5,1, function( ... )
                    -- body
                    self:onCloseView()
                end)
            end
        end
    end
end
--添加临时引导
function GuideLayer:addLimitGuide()
    if not self.panel then
        self.panel = UIPackage.CreateObject(UICommonRes[12] , "Effect4020118")
    end
    local pos = self.data and self.data.pos or {x = 0, y = 0}
    self.panel.x = pos.x
    self.panel.y = pos.y
    self.view:AddChild(self.panel)
    -- local img = self.panel:GetChild("n0")
    -- self:removeGuideEffect(img)
    -- local effect = self:addEffect(4020118,img)
    -- effect.Scale = Vector3.New(70,70,70)
    -- effect.LocalPosition = Vector3.New(img.width/2,-img.height/2,0)
    -- img.data = effect 
    local time = self.data and self.data.time or 1
    self:addTimer(time, 1, function()
        -- self:removeGuideEffect(img)
        local func = self.data and self.data.func
        if func then
            func()
        end
        self:closeView()
    end)
    -- local starTipText = self.data and self.data.starTipText
    -- if starTipText then
    --     GComAlter(starTipText)
    -- end
end

function GuideLayer:removeGuideEffect(img)
    if img.data then
        self:removeUIEffect(img.data)
        img.data = nil 
    end
end

function GuideLayer:checkZ90(btn)
    -- body
    local view = mgr.ViewMgr:get(ViewName.ZuoQiMain) 
    if view then
        if btn.name == "n24" or btn.name == "n77" 
            or btn.name == "n58" or  btn.name == "n59" then
            return true
        end 
    end

    local view = mgr.ViewMgr:get(ViewName.AwakenView) 
    if view then
        if btn.name == "n24" or btn.name == "n56" then
            return true
        end 
    end
end

function GuideLayer:playGuideEff()
    -- body
    self.canclose = false
    local parent = UnitySceneMgr.pStateTransform
    local e ,durition= mgr.EffectMgr:playCommonEffect(self.data.effect, parent)
    --e.Scale = Vector3.New(90,90,90)
    e.LocalPosition = gRole:getPosition()

    if durition~= -1 then
        self:addTimer(durition,1,function()
            -- body
            self.canclose = true
            self:onCloseView()
        end)
    else
        self.canclose = true
    end
end

function GuideLayer:initView()
    self.view.onClick:Add(self.onCloseView,self)
end

function GuideLayer:onCloseView()
    if mgr.ViewMgr:get(ViewName.AwakenView) then
        cache.GuideCache:setIsJsguide(true)
    end
    if type(self.data) == "table" then
        if self.data.effect then
            if self.canclose then 
                
                if self.data.nextguideid then
                    local condata = conf.XinShouConf:getOpenModule(self.data.nextguideid)
                    mgr.XinShouMgr:checkXinshou(condata) 
                else
                    --GgoToMainTask()
                end
                self:closeView()
            end
        elseif self.data.richang then
            --跑日常任务
            if not self.data.nilthing then
                GgoToDialyTask()
				local view = mgr.ViewMgr:get(ViewName.TaskGuide)
                if view then
                    view:closeView()
                end
            else
                if "tianshu" == self.data.nilthing then
                    self.data.richang.onClick:Call()
                end
            end
            self:closeView()
        elseif self.data.btn then
            local param = clone(self.data)
            if param.guidedata and param.guidedata.guideid == 1143 then
                --秘境引导的特殊性
                mgr.XinShouMgr.gomiji = true
            end
            
            param.btn.onClick:Call()
            if param.guidedata then
                if param.guidedata.guideid == 1078 then
                    --
                    local point = Vector3.New(945, gRolePoz, 570)
                    mgr.JumpMgr:findPath(point, reach or 0, function( ... )
                        -- body
                        mgr.HookMgr:startHook() --进入挂机
                    end)
                end
            end

            if param.class then --继续
                param.class:nextGuide()
            end

            -- self.data.btn.onClick:Call()
            -- if self.data.guidedata then
            --     if self.data.guidedata.guideid == 1078 then
            --         mgr.HookMgr:enterHook() --进入挂机
            --     end
            -- end

            -- if self.data.class then --继续
            --     self.data.class:nextGuide()
            -- end

            

            self:closeView()
        end
        return
    else
        
        if self.data then
            self.data.onClick:Call()
            --继续任务
            GgoToMainTask()
        end
        self:closeView()
    end 
end

return GuideLayer