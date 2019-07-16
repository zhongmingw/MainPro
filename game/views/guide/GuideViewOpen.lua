--
-- Author: 
-- Date: 2017-04-24 17:57:46
--

local GuideViewOpen = class("GuideViewOpen", base.BaseView)

function GuideViewOpen:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level4
end

function GuideViewOpen:initData(data)
    -- body
    self.data = data
    for i = 0 , self.view.numChildren-1 do 
        local var = self.view:GetChildAt(i)
        if var then
            var.visible = true
        end
    end

    

    self.touchable = false
    self.moveTime = 0.4
    self.stopTime = 2.0
    for i = 0 , self.view.numChildren-1 do 
        local var = self.view:GetChildAt(i)
        if var then
            var.visible = true
        end
    end
    --self.icon.xy = Vector2.New(529,206)
    self:setData()
    mgr.SoundMgr:playSound(Audios[4])
end

function GuideViewOpen:initView()
    self.icon = self.view:GetChild("n2")
    self.effect = self.view:GetChild("n6")
    --self.iconpos = self.icon.xy
    self.t0 = self.view:GetTransition("t1")
    self.view.onClick:Add(self.onViewCall,self)

    self.n0 = self.view:GetChild("n0")
    self.x = self.n0.width/2+self.n0.x
end

function GuideViewOpen:addByid(id,tag)
    -- body
    local effect,durition = self:addEffect(id,self.effect)
    effect.LocalPosition = Vector3.New(self.effect.width/2,-self.effect.height/2,tag or 500)

    return durition
end

function GuideViewOpen:setData()
    -- for i = 0 , self.view.numChildren-1 do 
    --     local var = self.view:GetChildAt(i)
    --     if var and var.name~="n2" and var.name~="n3" then
    --         --plog(var.name)
    --         var.visible = false
    --     end
    -- end
    self:addByid(4020112)
    self.icon.url = UIPackage.GetItemURL("guide" , self.data.data.param) 
    --
    self.icon.x = self.x - self.icon.width/2
    self.icon.y = self.n0.y - self.icon.height

    self.t0:Play()

    self:addTimer(0.4, 1,function()
        -- body
        self.touchable = true
         --多久之后执行滑动
        -- for i = 0 , self.view.numChildren-1 do 
        --     local var = self.view:GetChildAt(i)
        --     if var then
        --         var.visible = true
        --     end
        -- end
        self:addTimer(self.stopTime, 1, handler(self,self.move))
    end)

   
end

function GuideViewOpen:move()
    -- body
    for i = 0 , self.view.numChildren-1 do 
        local var = self.view:GetChildAt(i)
        if var and var.name~="n3" and var.name~="n2" and var.name ~= "n6" then
            var.visible = false
        end
    end
    -- local topos = self.data.topos
    -- topos.x = topos.x + self.icon.width/2
    -- topos.y = topos.y + self.icon.height/2
    self.icon:TweenMove(self.data.topos,self.moveTime)
    self:addTimer(self.moveTime, 1,function()
        -- body
        local durition = self:addByid(4020106,-50)
        self:addTimer(durition, 1, function( )
            -- body
            self:onCloseView()
        end)
        --self:onCloseView()
    end)
end

function GuideViewOpen:onViewCall()
    -- body
    if self.touchable then
        --self.moveTime = 0.1 
        self:move()
    end
end

function GuideViewOpen:onCloseView()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if self.data.task_id then
        
        local id = self.data.data.id 
        if id == 1053 or id == 1054 or 1057 == id or 1060 == id or 1055 == id then
            if view then 
                view.TopActive:checkActive()
            end
        else
            if view then
                view:chenkOpenById(self.data.task_id)
            end
        end
    elseif self.data.data.id == 1094 then
        if view then 
            view.TopActive:initBtn()
        end

    end

    if self.data.btn then
        if self.data.btn.name == "marry" then
            self.data.btn:SetScale(1,1)
        end
        self.data.btn.visible = true
        if view then 
            view:initEffect(true)
        end
    end

    local nextid = self.data.data.nextguideid 
    if nextid then 
        local condata = conf.XinShouConf:getOpenModule(nextid)
        mgr.XinShouMgr:checkXinshou(condata) 
        return
    end

    if not g_ios_test then
        GgoToMainTask()
    end
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        if mgr.FubenMgr:checkScene() then
            view.c4.selectedIndex = 1
        end
    end
    self:closeView()
end

return GuideViewOpen