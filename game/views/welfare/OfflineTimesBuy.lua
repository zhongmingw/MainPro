--
-- Author: Your Name
-- Date: 2017-05-26 21:16:58
--

local OfflineTimesBuy = class("OfflineTimesBuy", base.BaseView)

function OfflineTimesBuy:ctor()
    self.super.ctor(self)
    self.isBlack = true
    -- self.uiLevel = UILevel.level3 
end

function OfflineTimesBuy:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n7")
    closeBtn.onClick:Add(self.onClickClose,self)
    --钻石vip充值跳转
    local chargeBtn = self.view:GetChild("n8")
    chargeBtn.data = 1050
    chargeBtn.onClick:Add(self.onClickGoto,self)
    --仙盟任务
    local xianmengBtn = self.view:GetChild("n10")
    xianmengBtn.onClick:Add(self.onClickGoto,self)
    xianmengBtn.visible = false
    self.view:GetChild("n5").visible = false
    --修仙跳转
    local xiuxianBtn = self.view:GetChild("n11")
    xiuxianBtn.data = 1067
    xiuxianBtn.onClick:Add(self.onClickGoto,self)
    --商城跳转
    local storeBtn = self.view:GetChild("n12")
    storeBtn.data = 1043
    storeBtn.onClick:Add(self.onClickGoto,self)    

    self.view:GetChild("n4").text = language.welfare34
end

function OfflineTimesBuy:initData()
    -- body
    local chargeBtn = self.view:GetChild("n8")
    if cache.PlayerCache:VipIsActivate(3) then
        chargeBtn.visible = false
        self.view:GetChild("n13").visible = true
    else
        chargeBtn.visible = false  --EVE 屏蔽仙尊卡增加离线挂机时间入口
        self.view:GetChild("n13").visible = false
    end
end

--跳转按钮
function OfflineTimesBuy:onClickGoto( context )
    -- body
    local cell = context.sender
    local Id = cell.data
    if Id then
        GOpenView({id = Id})
    else
        mgr.ViewMgr:closeAllView2()
    end
end

function OfflineTimesBuy:onClickClose()
    -- body
    self:closeView()
end

return OfflineTimesBuy