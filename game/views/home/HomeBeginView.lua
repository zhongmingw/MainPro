--
-- Author: wx
-- Date: 2017-11-16 14:18:32
-- 进入家园的界面

local HomeBeginView = class("HomeBeginView", base.BaseView)

function HomeBeginView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function HomeBeginView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)
    --btnClose.onClick:Add(self.onCloseView,self)

    self.bgurl = self.view:GetChild("n1")

    local btnInto = self.view:GetChild("n6")
    btnInto.onClick:Add(self.onEnterHome,self)
end

function HomeBeginView:initData()
    self:setLoaderUrl(self.bgurl, UIItemRes.home.."jiayuan_041")
end

function HomeBeginView:setData(data_)

end

function HomeBeginView:onEnterHome()
    if mgr.FubenMgr:checkScen3() then
        proxy.HomeProxy:sendMsg(1460110,{reqType = 0})
    else
        GComAlter(language.gonggong41)
    end
end

return HomeBeginView