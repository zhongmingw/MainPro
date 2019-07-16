--
-- Author: 
-- Date: 2017-04-26 19:11:24
--

local GuideBianSheng = class("GuideBianSheng", base.BaseView)

function GuideBianSheng:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1 

end

function GuideBianSheng:initData(flag)
    -- body
    if g_ios_test then
        self:closeView()
        return
    end
    self.isGuide = false
    self:onTimer()
    self:addTimer(1, -1,handler(self,self.onTimer))

    if flag then
        self.image.visible = false
        self.lab.visible = false
        self.groud.xy = Vector2.New(gScreenSize.width/2-100,gScreenSize.height/4)
        self.groud:TweenMove(self.pos,2)

        self:addTimer(2,1,function()
            -- body
            self.image.visible = true
            self.lab.visible = true
        end)
    else
        self.image.visible = true
        self.lab.visible = true
    end

    local effect = self:addEffect(4020120,self.shap5)
    effect.LocalPosition = Vector3.New(self.shap5.width/2,-self.shap5.height/2,-50 )

    self.super.initData()
end

function GuideBianSheng:initView()
    self.btn = self.view:GetChild("n3")
    self.btn.onClick:Add(self.onImageCall,self)

    self.image = self.view:GetChild("n1")
    self.lab = self.view:GetChild("n5")

    self.groud = self.view:GetChild("n4")
    self.pos = self.groud.xy

    self.shap5 = self.view:GetChild("n6")
end

function GuideBianSheng:setData(data_)


end

function GuideBianSheng:onTimer()
    -- body
    local var = mgr.NetMgr:getServerTime() - cache.PlayerCache:getRedPointById(10206)
    local sys = conf.SysConf:getValue("jianshen_opentime_countdown")
    local distance = sys - var
    if  distance > 0 then
        self.isGuide = false
        self.lab.text = string.format(language.main03,GTotimeString(distance))
        self.shap5.visible = false
    else
        self.lab.text = language.main04
        self.isGuide = true

        self.shap5.visible = true
    end
end

function GuideBianSheng:onImageCall()
    -- body
    if self.isGuide then
        --先升级一次
        proxy.AwakenProxy:send(1190101,{reqType = 2})
        cache.GuideCache:setData(conf.XinShouConf:getOpenModule(1075))
        -- GOpenView({id = 1062})
        -- local view = mgr.ViewMgr:get(ViewName.AwakenView)
        -- local guiddata = 
        -- if view then
        --     view:startGuide(guiddata)
        -- else
            
        -- end
        self:closeView()
    end

end

return GuideBianSheng