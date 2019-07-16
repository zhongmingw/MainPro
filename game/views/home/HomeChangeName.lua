--
-- Author: wx
-- Date: 2017-11-16 14:26:08
-- 家园改名

local HomeChangeName = class("HomeChangeName", base.BaseView)

function HomeChangeName:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function HomeChangeName:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    --btnClose.onClick:Add(self.onCloseView,self)
    self:setCloseBtn(btnClose)

    self.input = self.view:GetChild("n6") 
    self.input.text = ""


    local btnSure = self.view:GetChild("n3") 
    btnSure.title = language.gonggong01
    btnSure.onClick:Add(self.onSure,self)
end

function HomeChangeName:setData(data_)

end

function HomeChangeName:onSure()
    -- body
    if self.input.text == "" then
        GComAlter(language.home01)
        return
    end
    local param = {}
    param.reqType = 1
    param.name = self.input.text
    proxy.HomeProxy:sendMsg(1460104,param)
    self:onCloseView()
end

function HomeChangeName:onCloseView()
    -- body
    self:closeView()
end

return HomeChangeName