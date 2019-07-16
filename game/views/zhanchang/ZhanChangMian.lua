--
-- Author: 
-- Date: 2017-04-07 17:40:45
--
local Arena = import(".Arena")
local Huangling = import(".HuangLingPanel")
local WenDingPanel = import(".WenDingPanel")
-- local GangPanel = import(".GangPanel")
local PanelXmzb = import(".PanelXmzb")
local XianMoWarPanel = import(".XianMoWarPanel")
local PanelWar = import("game.views.kuafu.PanelWar")--三界争霸
local PanelRanking = import(".PanelRanking") --跨服排位赛
local CityWarPanel = import(".CityWarPanel") --跨服城战
local ShenShouZC = import(".ShenShouZC") --神兽神域
local ZhanChangMian = class("ZhanChangMian", base.BaseView)
local opent = {1046,1078,1079,1353,1117,1094,1169,1224}
function ZhanChangMian:ctor()
    self.super.ctor(self)
    self.sharePackage = {"paiwei","citywar"}

    self.uiLevel = UILevel.level2
end

function ZhanChangMian:initData(data)
    --货币管理
    GSetMoneyPanel(self.window,self:viewName())
    if self.Arena then --模型移除
        for k ,v in pairs(self.Arena.playerlist) do
            local panel = v:GetChild("n1")
            panel.data = nil 
        end
        self.Arena.timer = nil 
    end
    --红点注册
    if g_is_banshu then
    else
        local t = {[1] = {50109},[4] = {attConst.A50133},
                    [7] = {attConst.A50121,attConst.A50122,attConst.A50123,attConst.A50124,attConst.A50125,attConst.A50126,attConst.A50127},
                    [8] = {attConst.A20168,attConst.A20169,attConst.A20204,attConst.A20205}}
        for k ,v in pairs(t) do
            local btn = self.btnlist[k]
            if not btn then
                break
            end
            local redImg = btn:GetChild("n4")
            local param = {panel = redImg,ids = v}
            mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
        end
        self:setHLRedPoint()
        self:setWendingRedPoint()
        self:setGangWarRedPoint()
        self:setXianMoRedPoint()
    end
    self.childIndex = data.childIndex or 0
    self.c1.selectedIndex = data.index or 0
    self:onController1()

    self:addTimer(1, -1,handler(self,self.onTimer))

    self.super.initData()
    if cache.GuideCache:getGuide() then
        cache.GuideCache:setGuide(nil)
    end
    mgr.ModuleMgr:setModuleVisible(opent,self.btnlist,self.btnPos)
end

function ZhanChangMian:onTimer()
    if self.c1.selectedIndex == 6 then
        if self.PanelRanking then
            self.PanelRanking:onTimer()
        end
    end
end

--皇陵红点
function ZhanChangMian:setHLRedPoint()
    -- body
    if cache.HuanglingCache:getHuanglingRedPoint() == 1 then
        self.btnlist[2]:GetChild("n4").visible = true
    else
        self.btnlist[2]:GetChild("n4").visible = false
    end
end
--问鼎战红点
function ZhanChangMian:setWendingRedPoint()
    if cache.WenDingCache:getWendingRedPoint() > 0 then
        self.btnlist[3]:GetChild("n4").visible = true
    else
        self.btnlist[3]:GetChild("n4").visible = false
    end-- body
end
--仙盟战红点
function ZhanChangMian:setGangWarRedPoint()
    -- if cache.GangWarCache:getGangWarRedPoint() > 0 then
    --     self.btnlist[4]:GetChild("n4").visible = true
    -- else
    --     self.btnlist[4]:GetChild("n4").visible = false
    -- end-- body
end
--仙魔战红点
function ZhanChangMian:setXianMoRedPoint()
    if cache.XianMoCache:getXianMoRedPoint() > 0 then
        self.btnlist[5]:GetChild("n4").visible = true
    else
        self.btnlist[5]:GetChild("n4").visible = false
    end-- body
end
--城战城池宣战情况返回
function ZhanChangMian:setCityDeclareInfo(data)
    self.CityWarPanel:setCityDeclareInfo(data)
end

function ZhanChangMian:initView()
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    self.window = self.view:GetChild("n0")
    self.windowC1 = self.window:GetController("c1")

    local btnClose = self.window:GetChild("btn_close")
    btnClose.onClick:Add(self.onClickClose,self)

    self.btnlist = {}
    self.btnPos = {}
    for i = 1 , 9 do
        local btn = self.view:GetChild("n"..i)
        btn.title = language.zhangchang01[i]
        if g_is_banshu then
            if i > 1 then
                btn.visible = false
            end
        end
        table.insert(self.btnlist,btn)
        table.insert(self.btnPos,btn.y)
    end

    
end

function ZhanChangMian:onController1()
    -- body
    if not mgr.ModuleMgr:CheckView({id = opent[self.c1.selectedIndex+1],falg = true} ) then
        if self.oldselect then
            self.c1.selectedIndex = self.oldselect
        else
            self.c1.selectedIndex = 0
        end
        return
    end
    self.oldselect = self.c1.selectedIndex

    if self.panelXmzb then
        self.panelXmzb:clear()
    end
    if self.c1.selectedIndex == 0 then --竞技场
        self.windowC1.selectedIndex = 1
        if not self.Arena then
            self.Arena = Arena.new(self)
        end
        proxy.ArenaProxy:send(1310101)
    elseif self.c1.selectedIndex == 1 then --皇陵
        self.windowC1.selectedIndex = 0
        if not self.Huangling then
            self.Huangling = Huangling.new(self)
        end
        proxy.HuanglingProxy:sendMsg(1340101)
    elseif  self.c1.selectedIndex == 2 then --问鼎
        self.windowC1.selectedIndex = 0
        if not self.wenDingPanel then
            self.wenDingPanel = WenDingPanel.new(self)
        end
        proxy.WenDingProxy:send(1350101)
    elseif  self.c1.selectedIndex == 3 then --仙盟
        if not self.panelXmzb then
            self.panelXmzb = PanelXmzb.new(self)
        end
        self.panelXmzb:setData()
    elseif  self.c1.selectedIndex == 4 then --仙魔战
        if not self.xianMoWarPanel then
            self.xianMoWarPanel = XianMoWarPanel.new(self)
        end
        proxy.XianMoProxy:send(1420105)
        self.xianMoWarPanel:setData()
    elseif self.c1.selectedIndex == 5 then --三界争霸
        self.windowC1.selectedIndex = 0
        if not self.PanelWar then
            self.PanelWar = PanelWar.new(self.view:GetChild("n58"))
        end
        --设置背景图
        self.PanelWar:setBg()
        proxy.KuaFuProxy:sendMsg(1410101)
    elseif self.c1.selectedIndex == 6 then --排位赛
        self.windowC1.selectedIndex = 0
        if not self.PanelRanking then
            local rankingPanel = UIPackage.CreateObject("paiwei" ,"PanelRanking")
            local container = self.view:GetChild("n61")
            container:AddChild(rankingPanel)
            self.PanelRanking = PanelRanking.new(self,rankingPanel)
        end
        self.PanelRanking:setIndex(self.childIndex)
        self.PanelRanking:onController()
        --请求设置竞猜红点
        proxy.QualifierProxy:sendMsg(1480212,{reqType = 0,stakeSId = 0})
        proxy.QualifierProxy:sendMsg(1480303,{reqType = 0,stakeTeamId = 0})
    elseif self.c1.selectedIndex == 7 then --跨服城战
        self.windowC1.selectedIndex = 0
        if not self.CityWarPanel then
            local cityWarPanel = UIPackage.CreateObject("citywar","CityWarPanel")
            local container = self.view:GetChild("n63")
            container:AddChild(cityWarPanel)
            self.CityWarPanel = CityWarPanel.new(self,cityWarPanel)
        end
        proxy.CityWarProxy:sendMsg(1510101,{awardGot = 0})
    elseif self.c1.selectedIndex == 8 then --神兽圣域
        self.windowC1.selectedIndex = 0
        if not self.ShenShouZC then
            self.ShenShouZC = ShenShouZC.new(self)
        end
        proxy.FubenProxy:send(1331401)
    end
end

function ZhanChangMian:setData(data_)

end

function ZhanChangMian:addMsgCallBack(data)
    -- body
    if self.c1.selectedIndex == 0 then
        if not self.Arena then
            return
        end
        if 5310101 == data.msgId then
            self.Arena:add5310101(data)
        elseif 5310102 == data.msgId then
            self.Arena:add5310102(data)
        elseif 5310201 ==  data.msgId then
            self.Arena:add5310201(data)
        elseif 5310202 ==  data.msgId then
            self.Arena:add5310202(data)
        end
    elseif self.c1.selectedIndex == 1 then
        if not self.Huangling then
            return
        end
        --print("皇陵之战返回",data.open)
        self.Huangling:setData(data)
    elseif self.c1.selectedIndex == 2 then --问鼎
        if self.wenDingPanel then
            self.wenDingPanel:setData(data)
        end
    elseif self.c1.selectedIndex == 3 then --仙盟
        -- if self.gangPanel then
        --     self.gangPanel:setData(data)
        -- end
    elseif self.c1.selectedIndex == 5 then --仙盟
        if not self.PanelWar then
            return
        end
        self.PanelWar:addMsgCallBack(data)
    elseif self.c1.selectedIndex == 6 then
        if self.PanelRanking then
            if 5480101 ==  data.msgId then--单人排位
                self.PanelRanking:setSoloData(data)
            elseif 5480201 == data.msgId then--组队排位
                self.PanelRanking:setTeamData(data)
            elseif 5480301 == data.msgId then--季后赛
                self.PanelRanking:setPayoffData(data)
            end
        end
    elseif self.c1.selectedIndex == 7 then --跨服城战
        if self.CityWarPanel then
            self.CityWarPanel:setData(data)
        end
    elseif self.c1.selectedIndex == 8 then --神兽神域
        if self.ShenShouZC then
            self.ShenShouZC:addMsgCallBack(data)
        end
    end
end

function ZhanChangMian:update24()
    -- body
    self:onController1()
end

function ZhanChangMian:clear()
    if g_var.gameFrameworkVersion >= 2 then
        UnityResMgr:ForceDelAssetBundle(UIItemRes.zhanchang.."jingjichang_019")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.zhanchang.."huanglingzhizhan_009")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.zhanchang.."wendingzhizhan_001")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.zhanchang.."xianmengzhan_004")
    end
    if self.Arena then
        self.Arena:clear()
    end
    if self.Huangling then
       self.Huangling:clear()
    end
    if self.wenDingPanel then
        self.wenDingPanel:clear()
    end
    if self.panelXmzb then
        self.panelXmzb:clear()
    end
    if self.xianMoWarPanel then
        self.xianMoWarPanel:clear()
    end
    if self.PanelRanking then
        self.PanelRanking:clear()
    end
end

function ZhanChangMian:onClickClose()
    
    self:closeView()
end

function ZhanChangMian:dispose(clear)
    self:clear()
    self.super.dispose(self, clear)
end

return ZhanChangMian