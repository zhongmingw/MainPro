--
-- Author:wx 
-- Date: 2017-01-12 19:24:45
--
local FriendPanel = import(".FriendPanel")
local FriendMeili = import(".FriendMeili")

local FriendView = class("FriendView", base.BaseView)

function FriendView:ctor()
    self.super.ctor(self)
    self.uiClear = UICacheType.cacheTime
    self.uiLevel = UILevel.level2 
end

function FriendView:initData( data )
    GSetMoneyPanel(self.window2,self:viewName())
    --注册红点
    local redImg = self.btnFriend:GetChild("n4")
    local param = {panel = redImg,ids = {10227,10234}}
    mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())

    --注册红点
    local redImg = self.btnMeiHuo:GetChild("n4")
    local param = {panel = redImg,ids = {10228}}
    --plog(...)
    mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())

    self.controllerC1.selectedIndex = 0
    self:onController1()
end

function FriendView:initView()
    --好友还是魅惑
    self.window2 = self.view:GetChild("n0")

    local closeBtn = self.window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.controllerC1 = self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onController1,self)

    local btnFriend = self.view:GetChild("n1")
    btnFriend:GetChild("title").text = language.friend01
    self.btnFriend = btnFriend

    

    local btnMeiHuo = self.view:GetChild("n2")
    btnMeiHuo:GetChild("title").text = language.friend02
    self.btnMeiHuo = btnMeiHuo

    --self:onController1()
end

function FriendView:setData(data_)
     
end

function FriendView:friendMsgCallBack(data_,param)
    -- body
    if not self.friendInfo then
        return
    end

    self.friendInfo:setData(data_,param)
end

function FriendView:MeiliMsgCallBack( data_,param )
    -- body
    if not self.FriendMeili then
        return
    end
    self.FriendMeili:setData(data_,param)
end

function FriendView:onController1()
    -- body
    if 0 == self.controllerC1.selectedIndex then  --好友信息 
        if not self.friendInfo then
            self.friendInfo = FriendPanel.new(self.view:GetChild("n5"))
        end
        self.friendInfo:AutoClick(0)
    elseif 1 == self.controllerC1.selectedIndex then --魅惑信息
        if not self.FriendMeili then
            self.FriendMeili = FriendMeili.new(self.view:GetChild("n7"))
        end
        self.FriendMeili:send()
    end
end

function FriendView:onClickClose()
    self:closeView()
end

return FriendView