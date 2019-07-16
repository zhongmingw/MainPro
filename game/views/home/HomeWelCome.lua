--
-- Author: 
-- Date: 2017-11-21 14:22:46
--

local HomeWelCome = class("HomeWelCome", base.BaseView)

function HomeWelCome:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function HomeWelCome:initView()
    local btnClose = self.view:GetChild("n3"):GetChild("n1")
    self:setCloseBtn(btnClose)
    local btnClose1 = self.view:GetChild("n25")
    self:setCloseBtn(btnClose1)

    self.btnlist = {}
    for i = 1 , 8 do
        local icon =  self.view:GetChild("icon"..i)
        local title = self.view:GetChild("name"..i)
        icon.url = UIItemRes.home1[i]
        title.text = language.home42[i]
        icon.data = i 
        title.data = i 
        icon.onClick:Add(self.onGoToCall,self)
        title.onClick:Add(self.onGoToCall,self)
    end

    self.dec1 = self.view:GetChild("n7")
    self.dec1.text = language.home43


    self.dec2 = self.view:GetChild("n6")
    self.dec2.text = language.home44

    self.c1 = self.view:GetController("c1")
    for i = 1 , 4 do
        local icon =  self.view:GetChild("icon2"..i)
        local title = self.view:GetChild("name2"..i)
        icon.url = UIItemRes.home3[i]
        title.text = language.home122[i]
        icon.data = i 
        title.data = i 
        icon.onClick:Add(self.onGoToOtherCall,self)
        title.onClick:Add(self.onGoToOtherCall,self)
    end

    self.panel = self.view:GetChild("n36")
end

function HomeWelCome:initModel(id)
    -- body
    local mConf = conf.NpcConf:getNpcById(id) --conf.MonsterConf:getInfoById(id)
    local bodySrc = mConf["body_id"]
    if not self.model then
        self.model = self:addModel(bodySrc, self.panel)
    else
        self.model:setSkins(bodySrc)
    end
    self.model:setScale(120)
    self.model:setRotation(180)
    self.model:setPosition(18,-self.panel.actualHeight-200,500)
end


function HomeWelCome:initData(data)
    -- body
    self.model = nil 
    self:setData()
end

function HomeWelCome:setData(data_)
    self.data  = cache.HomeCache:getData()
    self.isSelf = cache.HomeCache:getisSelfHome()
    local id 
    if self.isSelf then
        local cc = conf.HomeConf:getValue("welcom_self")
        self.dec1.text = cc[3]
        self.dec2.text = cc[2]
        self.c1.selectedIndex = 0
        id = cc[1]
    else
        local cc = conf.HomeConf:getValue("welcom_other")
        self.dec1.text = cc[3]
        self.dec2.text = cc[2]
        self.c1.selectedIndex = 1
        id = cc[1]
    end
    self:initModel(id)
end

function HomeWelCome:goPosition( id )
    -- body
    mgr.HomeMgr:goPosition(id)
end

function HomeWelCome:onGoToOtherCall( context )
    -- body
    if not self.data then
        return
    end
    local data = context.sender.data
    if tonumber(data) == 1 then
        --灵田
        mgr.HomeMgr:goPosition(2)
    elseif tonumber(data) == 2 then
        --灵兽
        mgr.HomeMgr:goPosition(3)
    elseif tonumber(data) == 3 then
        mgr.HomeMgr:goPosition(4)
    elseif tonumber(data) == 4 then
        mgr.ViewMgr:openView2(ViewName.HomeSeeOther)
    end

end

function HomeWelCome:onGoToCall(context)
    -- body
    if not self.data then
        return
    end
    local data = context.sender.data
    if tonumber(data) == 1 then
        --设置装饰
        if not self.isSelf then
            GComAlter(language.home45)
            return
        end
        mgr.ViewMgr:openView2(ViewName.HomeSet)
    elseif tonumber(data) == 2 then
        --升级宅邸
        if not self.isSelf then
            GComAlter(language.home45)
            return
        end
        mgr.ViewMgr:openView2(ViewName.HomeHouse)
    elseif tonumber(data) == 3 then
        --种植灵田
        --跑到指定位置
        self:goPosition(2)
    elseif tonumber(data) == 4 then
        --饲养灵兽
        self:goPosition(3)
    elseif tonumber(data) == 5 then
        --升级围墙
        if not self.isSelf then
            GComAlter(language.home45)
            return
        end
        mgr.ViewMgr:openView2(ViewName.HomeWeiQiang)
    elseif tonumber(data) == 6 then
        --泡温泉
        --跑到指定位置
        self:goPosition(4)
    elseif tonumber(data) == 7 then
        --拜访记录
        if not self.isSelf then
            GComAlter(language.home45)
            return
        end
        mgr.ViewMgr:openView2(ViewName.HomeRecord)
    elseif tonumber(data) == 8 then
        --拜访他人
        mgr.ViewMgr:openView2(ViewName.HomeSeeOther)
    end
end

return HomeWelCome