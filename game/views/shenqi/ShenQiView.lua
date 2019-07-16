--
-- Author: Your Name
-- Date: 2018-06-28 11:44:55
--
local ShenQiView = class("ShenQiView", base.BaseView)
local ShenQiPanel = import(".ShenQiPanel")
local ShenShouPanel = import(".ShenShouPanel")
local DiHunPanel = import(".DiHunPanel")
local MianJuPanel = import(".MianJuPanel")



local INDEX = {
    [1238] = 0,--神器
    [1336] = 1,--神兽
    [1408] = 2,--帝魂
    [1410] = 3,--面具
}
local redId = {
    [1] = {20179,20180,20181},--神器红点
    [2] = {10265},--神兽红点
   
    -- [3] = {},--帝魂红点
}

function ShenQiView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function ShenQiView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.controllerC1 = self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onControlChange,self)
    self.shenqiBtn = self.view:GetChild("n17")
    self.shenshouBtn = self.view:GetChild("n18")
    self.diHunBtn = self.view:GetChild("n19")
    self.mianjuBtn = self.view:GetChild("n21")

    self.oldXY = {
        self.shenqiBtn.xy,
        self.shenshouBtn.xy,
        self.diHunBtn.xy,
        self.mianjuBtn.xy,

    }
end

function ShenQiView:refreshRed()
    --神器红点
    local sqVar = 0
    for k,v in pairs(redId[1]) do
        local var = cache.PlayerCache:getRedPointById(v)
        sqVar = sqVar + var
    end
    sqVar = sqVar + cache.ShenQiCache:getFenJieRed()
    if sqVar > 0 then
        self.shenqiBtn:GetChild("n5").visible = true
    else
        self.shenqiBtn:GetChild("n5").visible = false
    end
    --帝魂红点
    local diHunRed = cache.DiHunCache:getRed()
    if diHunRed > 0 then
        self.diHunBtn:GetChild("n5").visible = true
    else
        self.diHunBtn:GetChild("n5").visible = false
    end
    --面具红点
     local mianjuRed =  0

    mianjuRed = cache.MianJuCache:getRed()
    -- local mianjuRed = cache.MianJuCache:getRed() or 0
    if mianjuRed > 0 then
        self.mianjuBtn:GetChild("n5").visible = true
    else
        self.mianjuBtn:GetChild("n5").visible = false
    end
 



    --神兽红点
    -- local ssVar = 0
    -- for k,v in pairs(redId[2]) do
    --     local var = cache.PlayerCache:getRedPointById(v)
    --     ssVar = ssVar + var
    -- end
    local param = {} 
    param.panel = self.shenshouBtn:GetChild("n5")
    param.ids = redId[2]
    mgr.GuiMgr:registerRedPonintPanel(param,"shenqi.ShenQiView.1") 
    -- -- print("神兽红点>>>>>>>>>",ssVar)
    -- if ssVar > 0 then
    --     self.shenshouBtn:GetChild("n5").visible = true
    -- else
    --     self.shenshouBtn:GetChild("n5").visible = false
    -- end
end

function ShenQiView:initData(data)
    self.shenqiBtn.xy = self.oldXY[1]
    self.shenshouBtn.xy = self.oldXY[2]
    self.diHunBtn.xy = self.oldXY[3]
    self.mianjuBtn.xy = self.oldXY[4]
    if not mgr.ModuleMgr:CheckView({id = 1336}) then--神兽系统
        self.shenshouBtn.visible = false
    else
        self.shenshouBtn.visible = true
    end
    if not mgr.ModuleMgr:CheckView({id = 1408}) then--帝魂
        self.diHunBtn.visible = false
    else
        self.diHunBtn.visible = true
    end
    if not mgr.ModuleMgr:CheckView({id = 1410}) then--面具
        self.mianjuBtn.visible = false
    else
        self.mianjuBtn.visible = true
    end
    local t = {}
    table.insert(t,self.shenqiBtn)
    table.insert(t,self.shenshouBtn)
    table.insert(t,self.diHunBtn)
    table.insert(t,self.mianjuBtn)

    local number = 1
    for k ,v in pairs(t) do
        if v.visible then
            v.xy = self.oldXY[number]
            number = number + 1
        end
    end

    self.index = INDEX[data.index or 0]
    self.controllerC1.selectedIndex = self.index
    self:onControlChange()
    self:refreshRed()
end

function ShenQiView:onControlChange()
    --面具升级过程中点跳转
    if self.MianJuPanel and self.MianJuPanel.isLevel then
         --升级过程中点击时
        self.MianJuPanel.isLevel = false
        if self.MianJuPanel.isLevel then
            self.MianJuPanel.btn1.icon = UIPackage.GetItemURL("shenqi","juesexinxishuxin_014")
        else
            self.MianJuPanel.btn1.icon = UIPackage.GetItemURL("shenqi","mianju_011")
        end
    end
    if self.controllerC1.selectedIndex == 0 then
        if not self.ShenQiPanel then
            self.ShenQiPanel = ShenQiPanel.new(self)
        end
        proxy.ShenQiProxy:sendMsg(1520101)
    elseif self.controllerC1.selectedIndex == 1 then
        if not self.ShenShouPanel then
            self.ShenShouPanel = ShenShouPanel.new(self)
        end
        proxy.ShenShouProxy:sendMsg(1590101)
    elseif self.controllerC1.selectedIndex == 2 then
        if not self.DiHunPanel then
            self.DiHunPanel = DiHunPanel.new(self)
        end
        proxy.DiHunProxy:sendMsg(1620101)
    elseif self.controllerC1.selectedIndex == 3 then
        if not self.MianJuPanel then
            self.MianJuPanel = MianJuPanel.new(self)
        end
        self.MianJuPanel:onReturn()
        self.MianJuPanel:setBtnSelect()
        -- proxy.MianJuProxy:sendMsg(1630101)
    end
end

--神器信息
function ShenQiView:setShenQiData(data)
    if self.ShenQiPanel then
        self.ShenQiPanel:setData(data)
        self:refreshRed()
    end
end
--刷新神器界面强化附灵
function ShenQiView:refreshShenQiPanel(data)
    if self.ShenQiPanel then
        self.ShenQiPanel:refreshPanel(data)
        self:refreshRed()
    end
end
--刷新神器界面升星信息
function ShenQiView:refreshSx(sxLev)
    if self.ShenQiPanel then
        self.ShenQiPanel:refreshSx(sxLev)
        self:refreshRed()
    end
end
--刷新神器界面三种强化石
function ShenQiView:refreshQhsMap2(data)
    if self.ShenQiPanel then
        self.ShenQiPanel:refreshQhsMap2(data)
        self:refreshRed()
    end
end
--刷新神器界面战力
function ShenQiView:refreshPower(data)
    if self.ShenQiPanel then
        self.ShenQiPanel:refreshPower(data)
        self:refreshRed()
    end
end

--神兽信息
function ShenQiView:setShenShouData(data)
    if self.ShenShouPanel then
        self.ShenShouPanel:setData(data)
    end
end

--刷新神兽信息
function ShenQiView:refreshShenShou()
    if self.ShenShouPanel then
        proxy.ShenShouProxy:sendMsg(1590101)
    end
end

--打开神兽强化界面
function ShenQiView:openShenShouQhView()
    if self.ShenShouPanel then
        self.ShenShouPanel:onClickStrength()
    end
end

--帝魂信息
function ShenQiView:setDiHunData(data)
    if self.DiHunPanel then
        self.DiHunPanel:addMsgCallBack(data)
        self:refreshRed()
    end
end

--面具信息
function ShenQiView:setMianJuData(data)
    if self.MianJuPanel then
        self.MianJuPanel:addMsgCallBack(data)
        self:refreshRed()
    end
end


return ShenQiView