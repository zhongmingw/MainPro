--
-- Author: 
-- Date: 2017-09-07 16:17:52
--

local GuideDialog2 = class("GuideDialog2", base.BaseView)

function GuideDialog2:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level4
end

function GuideDialog2:initData(data)
    -- body
    self.id  = data.id
    self.data = data
    self.icon1.url = nil 
    self.icon2.url = nil 
    if not data then
        self:onCloseView()
        return
    end

    self.delay = 0

    self:setData()
    self:addTimer(1, -1, handler(self,self.onTimer))
end

function GuideDialog2:initView()
    self.c1 = self.view:GetController("c1")

    self.t0 = self.view:GetTransition("t0")
    self.t1 = self.view:GetTransition("t1")

    self.icon1 = self.view:GetChild("n1")
    self.icon2 = self.view:GetChild("n2")

    self.roleName = self.view:GetChild("n3")
    self.words = self.view:GetChild("n4")

    local dec = self.view:GetChild("n5")
    dec.text = language.guide01

    self.view.onClick:Add(self.nextDialog,self)
end

function GuideDialog2:setIcon( condata,icon)
    -- body
    if not condata then
        icon.url = nil 
        return
    end 

    if condata.Npc == 1 then
        if cache.PlayerCache:getSex() == 1 then
            icon.url = "ui://guide/xinshouyingdao_111"
        else
            icon.url = "ui://guide/xinshouyingdao_112"
        end
    else
        icon.url = "ui://guide/"..condata.icon
    end
end

function GuideDialog2:onTimer()
    -- body
    self.delay = self.delay + 1 
    if self.delay >= 5 then
        self:nextDialog()
    end
end

function GuideDialog2:setData(data_)
    --对话信息
    local condata = conf.DialogConf:getDataById(self.id)
    local nexcondata = conf.DialogConf:getDataById(condata.nextid)
    self.id = condata.nextid
    --
    if condata.side == 1 then
        self.t0:Play()
        self.t1:Stop()
        self.c1.selectedIndex = 0
        self:setIcon(condata,self.icon1)
        self:setIcon(nexcondata,self.icon2)
    else
        self.t0:Stop()
        self.t1:Play()
        self.c1.selectedIndex = 1
        self:setIcon(condata,self.icon2)
        self:setIcon(nexcondata,self.icon1)
    end

    self.roleName.text = condata.name
    self.words.text = condata.value
end

function GuideDialog2:nextDialog()
    -- body
    if not self.id then
        self:onCloseView()
        return
    end
    local condata = conf.DialogConf:getDataById(self.id)
    if not condata then
        self:onCloseView()
        return
    end
    self.delay = 0

    self.id = condata.nextid
    if condata.side == 1 then
        self.t0:Play()
        self.t1:Stop()
        self.c1.selectedIndex = 0
    else
        self.t0:Stop()
        self.t1:Play()
        self.c1.selectedIndex = 1
    end
    self.roleName.text = condata.name
    self.words.text = condata.value


end

function GuideDialog2:onCloseView( )
    -- body
    if self.data.callback then
        self.data.callback()
    end
    self:closeView()
end
return GuideDialog2