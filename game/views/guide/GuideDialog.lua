--
-- Author: 
-- Date: 2017-04-21 21:21:40
--

local GuideDialog = class("GuideDialog", base.BaseView)

function GuideDialog:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level4
end

function GuideDialog:initData(data)
    -- body
    self.id  = data.id
    self.data = data
    if not data then
        self:closeView()
        return
    end
    self.ground1.x = self.ground1.data
    self.ground2.x = self.ground2.data

    self:setData()
end

function GuideDialog:initView()
    self.icon1 = self.view:GetChild("n3")
    self.name1 = self.view:GetChild("n9")
    self.text1 = self.view:GetChild("n5")
    self.t1 = self.view:GetTransition("t0")
    self.ground1 = self.view:GetChild("n11")
    self.ground1.data = self.ground1.x

    self.icon2 = self.view:GetChild("n6")
    self.name2 = self.view:GetChild("n10")
    self.text2 = self.view:GetChild("n8")
    self.t2 = self.view:GetTransition("t1")
    self.ground2 = self.view:GetChild("n12")
    self.ground2.data = self.ground1.x
end

function GuideDialog:setIcon( condata,icon)
    -- body
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

function GuideDialog:setData()
    local condata = conf.DialogConf:getDataById(self.id)
    if condata.side == 1 then
        
        self.name1.text = condata.name
        self.text1.text = condata.value
        self.t1:Play()

        self:setIcon(condata,self.icon1)
    else
        self:setIcon(condata,self.icon2)

        self.name2.text = condata.name
        self.text2.text = condata.value
        self.t2:Play()
    end
    if condata.nextid then
        if condata.calltime then
            self:addTimer(condata.calltime, 1, function()
                -- body
                self.id = condata.nextid 
                self:setData()
            end)
        else
            self.id = condata.nextid 
            self:setData()
        end
    else
        self:addTimer(2, 1, function()
            -- body
            if self.data.callback then
                self.data.callback()
            end
            self:closeView()
        end)
    end
end

return GuideDialog