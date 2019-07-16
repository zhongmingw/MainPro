--投资计划
local InvestView = class("InvestView",base.BaseView)
local KaifuInvest = import(".KaifuInvest")
local LevelInvest = import(".LevelInvest")
local GoodsInvest = import(".GoodsInvest")
function InvestView:ctor()
    -- body
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function InvestView:initData( data )
    -- body
    local btnClose = self.view:GetChild("n0"):GetChild("n3")
    btnClose.onClick:Add(self.onClickClose,self)
    self.controllerC = self.view:GetController("c1")
    self.controllerC.onChanged:Add(self.onController,self)
    self.controllerC.selectedIndex = data.index or 0
    self:refreshRed()
    -- self:onController()
end

--按钮红点设置
function InvestView:refreshRed()
    local btn1 = self.view:GetChild("n6")
    local btn2 = self.view:GetChild("n7")
    local btn3 = self.view:GetChild("n10")
    local var1 = cache.PlayerCache:getRedPointById(attConst.A20118)
    local var2 = cache.PlayerCache:getRedPointById(attConst.A20119)
    local var3 = cache.PlayerCache:getRedPointById(attConst.A20187)
    if var1 > 0 then
        btn1:GetChild("n7").visible = true
    else
        btn1:GetChild("n7").visible = false
    end
    if var2 > 0 then
        btn2:GetChild("n7").visible = true
    else
        btn2:GetChild("n7").visible = false
    end
    if var3 > 0 then
        btn3:GetChild("n7").visible = true
    else
        btn3:GetChild("n7").visible = false
    end
end

function InvestView:onController()
    -- body
    if 0 == self.controllerC.selectedIndex then --开服投资
        -- print("开服投资")
        if not self.KaifuInvest then
            self.KaifuInvest = KaifuInvest.new(self)
        end
        self.view:GetChild("n8").visible = true
        self.view:GetChild("n9").visible = false
        proxy.ActivityProxy:sendMsg(1030118,{reqType = 0})
    elseif 1 == self.controllerC.selectedIndex then --等级投资
        -- print("等级投资")
        if not self.LevelInvest then
            self.LevelInvest = LevelInvest.new(self)
        end
        self.LevelInvest:setTab(true)
        self.view:GetChild("n9").visible = true
        self.view:GetChild("n8").visible = false
        proxy.ActivityProxy:sendMsg(1030119,{reqType = 0,invType = 1})
    elseif 2 == self.controllerC.selectedIndex then
        if not self.GoodsInvest then
            self.GoodsInvest = GoodsInvest.new(self)
        end
        proxy.ActivityProxy:sendMsg(1030214,{reqType = 0})
    end
end

--时间到了隐藏开服投资
function InvestView:hideOpenInvest()
    -- body
    self.view:GetChild("n6").visible = false
    self.view:GetChild("n8").visible = false
    self.view:GetChild("n10").visible = false
    self.controllerC.selectedIndex = 1
    self.view:GetChild("n10").y = self.view:GetChild("n7").y
    self.view:GetChild("n7").y = self.view:GetChild("n6").y
    self.view:GetChild("n4").height = 347
end

--时间到了隐藏物品投资
function InvestView:hideGoodsInvest()
    -- body
    self.view:GetChild("n10").visible = false
    self.controllerC.selectedIndex = 1
    self.view:GetChild("n7").y = self.view:GetChild("n6").y
    self.view:GetChild("n4").height = 197
end

function InvestView:onClickClose()
    -- body
    self:closeView()
end

return InvestView