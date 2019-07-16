--
-- Author: 
-- Date: 2018-01-12 14:58:06
--

local PetMainView = class("PetMainView", base.BaseView)
local PetPanel = import(".PetPanel")
local PetCardsPanel = import(".PetCardsPanel")
local PetFriend = import(".PetFriend")
function PetMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.uiClear = UICacheType.cacheForever
end

function PetMainView:initView()
    self.window2 = self.view:GetChild("n0")

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    local btnClose = self.window2:GetChild("btn_close")  
    self:setCloseBtn(btnClose)
    
end

function PetMainView:onController1()
    if self.c1.selectedIndex == 0 then
        if not self.PetPanel then
            self.PetPanel = PetPanel.new(self)
        end
        self.PetPanel:initData()

        local param = {}
        param.petId = 0
        param.pos = 0
        param.reqType = 0
        proxy.PetProxy:sendMsg(1490201,param)
    elseif self.c1.selectedIndex == 1 then
        if not self.PetCardsPanel then
            self.PetCardsPanel = PetCardsPanel.new(self)
        end
        self.PetCardsPanel:initData({index = self.childIndex}) --
    elseif self.c1.selectedIndex == 2 then
        if not self.PetFriend then
            self.PetFriend = PetFriend.new(self)
        end
        self.PetFriend:initData()
        local param = {}
        param.petId = 0
        param.pos = 0
        param.reqType = 0
        proxy.PetProxy:sendMsg(1490201,param)
    end
end

function PetMainView:initData(data)
    --货币窗口
    GSetMoneyPanel(self.window2,self:viewName())

    local index = data and data.index or 0
    self.childIndex = data and data.childIndex or 0
    if self.c1.selectedIndex ~= index then
        self.c1.selectedIndex = index
    else
        self:onController1()
    end
end

function PetMainView:addMsgCallBack(data)
    if self.c1.selectedIndex == 0 then
        if self.PetPanel then
            self.PetPanel:addMsgCallBack(data)
        end
    elseif self.c1.selectedIndex == 2 then
        if self.PetFriend then
            self.PetFriend:addMsgCallBack(data)
        end
    end
end

return PetMainView