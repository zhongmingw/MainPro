--
-- Author: 
-- Date: 2017-04-22 14:53:18
--

local GuideSkill = class("GuideSkill", base.BaseView)

function GuideSkill:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level4
end

function GuideSkill:initData(data)
    -- body
    self.image.x = self.posX 

    self.data = data
    self.moveTime = 0.4 --移动时间
    self.stopTime = 2.0 --停留时间
    self.touchable = false

    for i = 0 , self.view.numChildren-1 do 
        local var = self.view:GetChildAt(i)
        if var then
            var.visible = true
        end
    end
    self:setData()

    
end

function GuideSkill:initView()
    self.view.onClick:Add(self.onViewCall,self)
    self.t0 = self.view:GetTransition("t1")
    self.image = self.view:GetChild("n3")
    self.icon = self.view:GetChild("n4")
    self.name = self.view:GetChild("n5")
    self.effect = self.view:GetChild("n8")

    self.posX = self.image.x
end

function GuideSkill:addByid(id,tag)
    -- body
    local effect,durition = self:addEffect(id,self.effect)
    effect.LocalPosition = Vector3.New(self.effect.width/2,-self.effect.height/2,tag or 500)

    return durition
end

function GuideSkill:setData(data_)
    local id 
    if self.data.id then
        id = self.data.id
    else
        local data = self.data.data
        --local id = math.floor(data/100)
        local preid = conf.SkillConf:getSkillConfByid(data).s_pre
        id = conf.SkillConf:getSkillIcon(preid)
    end
    if g_ios_test then
        self.icon.url = UIItemRes.iosMainIossh..id
    else
        self.icon.url = ResPath.iconRes(id) -- UIPackage.GetItemURL("_icons" , tostring(id))
    end
    self.name.url = UIPackage.GetItemURL("guide" , tostring(id))
        

    self:addByid(4020113)
    --self.image.xy = self.pos

    self.t0:Play()
    self:addTimer(0.5, 1,function()
        -- body
        self.touchable = true
        
        
        --多久之后执行滑动
        self:addTimer(self.stopTime, 1, handler(self,self.move))
    end)

    
end

function GuideSkill:move()
    -- body
    for i = 0 , self.view.numChildren-1 do 
        local var = self.view:GetChildAt(i)
        if var and var.name~="n3" and var.name~="n4" and var.name~="n11" and var.name~="n8" and var.name~="n12" then
            --plog(var.name)
            var.visible = false
        end
    end

    
    local view = mgr.ViewMgr:get(ViewName.MainView)

    if view and self.data.id then
        if self.moveTime > 0 then
            local btn = view.view:GetChild("n403")
            --local icon = btn:GetChild("icon") 
            self.image.visible = true
            self.icon.visible = true
            self.image:TweenMove(btn.xy,self.moveTime)
            self:addTimer(self.moveTime, 1,function()
                -- body
                --self:onCloseView()
                local durition = self:addByid(4020106,-50)
                self:addTimer(durition, 1, function( )
                    -- body
                    self:onCloseView()
                end)
            end)
        else
            self:onCloseView()
        end
        return
    end
    self.flag = false
    if view and view.BtnFight and view.BtnFight.testSkillIds then
        local t = {"n305","n306","n307"}
        local info = view.BtnFight.testSkillIds
        for k ,v in pairs(info) do
            if v[cache.PlayerCache:getSex()] == self.data.data then
                self.flag = true
                mgr.HookMgr:updateSkills(v[cache.PlayerCache:getSex()], false)
                if self.moveTime > 0 then
                    local btn = view.view:GetChild(t[k])
                    local offbtn = btn:GetChild("n8")
                    local topos = btn.xy+offbtn.xy

                    print("当前屏幕尺寸：",gScreenSize.width,"X",gScreenSize.height)
                    --topos.x = topos.x  1
                    --topos.y = topos.y 
                    local icon = btn:GetChild("icon") 
                    self.image.visible = true
                    self.icon.visible = true
                    self.image:TweenMove(topos,self.moveTime)
                    self:addTimer(self.moveTime, 1,function()
                        -- body
                        --self:onCloseView()
                        local durition = self:addByid(4020106,-50)
                        self:addTimer(durition, 1, function( )
                            -- body
                            self:onCloseView()
                        end)
                    end)
                else
                    self:onCloseView()
                end
                break
            end
        end
    end
end

function GuideSkill:onViewCall()
    -- body
    --self.stopTime = 0
    if self.touchable then
        --self.moveTime = 0 
        self:move()
    end
end

function GuideSkill:onCloseView()
    -- body
    if self.flag then
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:onController3()
        end
        if not g_ios_test then
            GgoToMainTask()
        end
    end
    self:closeView()
end

return GuideSkill