
local MarryNpcView = class("MarryNpcView", base.BaseView)

function MarryNpcView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function MarryNpcView:initData()
    -- body
    self.data = cache.PlayerCache:getData()
end

function MarryNpcView:initView()
    --男 女
    local btnlihun = self.view:GetChild("n5")
    btnlihun.onClick:Add(self.onLihun,self)

    local btnQiuhun = self.view:GetChild("n4")
    btnQiuhun.onClick:Add(self.onQiuhun,self)

    local btnClose = self.view:GetChild("n8")
    btnClose.onClick:Add(self.onbtnClose,self)

    local btnShop = self.view:GetChild("n9")
    btnShop.onClick:Add(self.onbtnShop,self)
    
    local btndfhz = self.view:GetChild("n10")
    btndfhz.onClick:Add(self.onbtnDongFang,self)
end

function MarryNpcView:setData(data_)

end

function MarryNpcView:onQiuhun()
    -- body
    if not self.data then
        return
    end
    -- if self.data.coupleName ~= "" then
    --     GComAlter(language.kuafu33)
    --     return
    -- end
    --条件判定
    local level = conf.MarryConf:getValue("marry_level")
    if cache.PlayerCache:getRoleLevel()< level then
        GComAlter( string.format(language.kuafu34,level) )
        return
    end

    mgr.ViewMgr:openView2(ViewName.GetMarriedView)
    self:onbtnClose()
end

function MarryNpcView:onLihun()
    -- body
    if not self.data then
        return
    end
    if self.data.coupleName == "" then
        GComAlter(language.kuafu32)
        return
    end
    local param = {}
    param.reqType = 3
    proxy.MarryProxy:sendMsg(1390104,param)
    self:onbtnClose()
    --mgr.ViewMgr:openView2(ViewName.MarryLihunTips)
end

function MarryNpcView:onbtnShop( ... )
    mgr.ViewMgr:openView2(ViewName.MarryStoreView)
end

function MarryNpcView:onbtnDongFang()
    -- body
    if not self.data then
        return
    end
    if cache.PlayerCache:getCoupleName() ~= "" then
       GOpenView({id = 1309})
    else
        GComAlter(language.xiantong10)
    end
end

function MarryNpcView:onbtnClose( ... )
     -- body
     self:closeView()
end 

return MarryNpcView