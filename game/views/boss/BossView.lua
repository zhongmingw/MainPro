--
-- Author: ohf
-- Date: 2017-04-10 14:17:26
--
--boss大厅
local BossView = class("BossView", base.BaseView)

local PersonalBossPanel = import(".PersonalBossPanel")--个人boss

local EliteBossPanel = import(".EliteBossPanel")--精英boss

local WorldBossPanel = import(".WorldBossPanel")--世界boss

local XianzunBossPanel = import(".XianzunBossPanel")--仙尊boss

-- local AwakenHallPanel = import(".AwakenHallPanel")--剑神殿

local BossHomePanel = import(".BossHomePanel")--boss之家

local BossXianYuPanel = import(".BossXianYuPanel")--仙域禁地boss

local KuafuXianYuPanel = import(".BossXianYuPanel")--跨服仙域禁地boss

local ShangGuShenJiPanel = import(".BossXianYuPanel")--上古神迹boss

local DropRecordPanel = import(".DropRecordPanel")--掉落记录

local KuaFuBossPanel = import(".KuaFuBossPanel")--宠物岛

local WuXingPanel = import(".WuXingPanel")--五行神殿

local FeishengPanel = import(".BossXianYuPanel")--飞升神殿

local ShenShouPanel = import(".ShenShouPanel")--神兽岛

local WanShenDianPanel = import(".WanShenDianPanel")--万神殿

local TaiGuXuanJingPanel =  import(".TaiGuXuanJingPanel")--太古玄境


local Modules = {1047,1048,1049,1125,1128,1135,1191,1221,1242,1266,1324,1337,1348,1378,1151}
local ModuleIndex = {
    [3001] = 2,
    [1047] = 0,--个人boss
    [1048] = 1,--精英boss
    [1049] = 2,--世界boss
    [1125] = 3,--仙尊boss
    [1128] = 4,--boss之家
    [1135] = 5,--仙域禁地
    [1191] = 6,--宠物岛
    [1221] = 7,--跨服仙域禁地
    [1242] = 8,--上古神迹
    [1266] = 9,--五行神殿
    [1151] = 10,--掉落奖励
    [1324] = 11,--飞升
    [1337] = 12,--神兽岛
    [1348] = 13,--万神殿(五行圣殿)
    [1378] = 14,--太古玄境
}
function BossView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheForever
end

function BossView:initView()
    self.window = self.view:GetChild("n0")
    local closeBtn = self.window:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.controller1 = self.view:GetController("c1")--主控制器
    self.controller1.onChanged:Add(self.onController1,self)

    self.personalBossPanel = PersonalBossPanel.new(self)
    self.eliteBossPanel = EliteBossPanel.new(self)
    self.worldBossPanel = WorldBossPanel.new(self)
    self.xianzunBossPanel = XianzunBossPanel.new(self)
    -- self.awakenHallPanel = AwakenHallPanel.new(self)
    self.bossHomePanel = BossHomePanel.new(self)

    self.bossXianYuPanel = BossXianYuPanel.new(self,1135)

    self.kaufuXianYuPanel = KuafuXianYuPanel.new(self,1221)

    self.shangGuShenJiPanel = ShangGuShenJiPanel.new(self,1242)

    self.dropRecordPanel = DropRecordPanel.new(self) --掉落记录
    self.kuaFuBossPanel = KuaFuBossPanel.new(self) --宠物岛
    self.wuXingPanel = WuXingPanel.new(self)--五行神殿

    self.feishengPanel = FeishengPanel.new(self,1324) --FeishengPanel.new(self)--飞升神殿

    self.shenShouPanel = ShenShouPanel.new(self) --神兽岛

    self.WanShenDianPanel = WanShenDianPanel.new(self)--万神殿（五行圣殿）

    self.TaiGuXuanJingPanel = TaiGuXuanJingPanel.new(self)-- 太古玄境

    self.titleList = self.view:GetChild("n22")
    self.titleList.numItems = 0

    local ruleBtn = self.view:GetChild("n7")
    ruleBtn.onClick:Add(self.onClickRule,self)
    
end

function BossView:initTitleList()
    self.Modules = {}

    for k ,v in pairs(Modules) do
        if mgr.ModuleMgr:CheckSeeView(v) then
            table.insert(self.Modules,v)
        end
    end
    self.titleList.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.titleList.numItems = #self.Modules
    self.titleList.onClickItem:Add(self.onSelectCall,self)
end

function BossView:cellData(index,obj)
    local data = self.Modules[index+1]
    obj.title = language.fuben70[data]
    obj.data = data
    --print(index,data)
    local redPanel = obj:GetChild("n4")
    local redText = obj:GetChild("n5")
    local param = {panel = redPanel,text = redText, ids = {attConst.A20136},notnumber = true}
    mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())

    -- local btn = self.btnList[index + 1]
    -- if btn then
    --     obj.title = btn.title
    --     obj.data = btn.data
    --     obj.onClick:Add(self.onSelectCall,self)

    --     local redPanel = obj:GetChild("n4")
    --     local redText = obj:GetChild("n5")
    --     local param = {panel = redPanel,text = redText, ids = {attConst.A20136},notnumber = true}
    --     mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    -- end
end

function BossView:initData(data)
    self:clear()
    --self.btnList = {}
    -- self.btnPos = {}
    -- for i=1,12 do
    --     local btn = {}--self.view:GetChild("n"..i)
    --     local k = i -- 40
    --     btn.title = language.fuben70[k]
    --     -- btn.data = k 
    --     -- btn.onClick:Add(self.onSelectCall,self)
    --     --btn.selectedTitle = language.fuben70[k]
    --     if mgr.ModuleMgr:CheckSeeView(Modules[k]) then
    --         btn.data = k
    --         table.insert(self.btnList, btn)
    --         -- table.insert(self.btnPos,btn.y)
    --     end
    -- end





    GSetMoneyPanel(self.window,self:viewName())
    self:initTitleList()
    self:nextStep(data.index)
    self.childIndex = data.childIndex
    self.gotoSceneId = data.sceneId
    -- self:initRedPoint()
    -- self:initActLogo()
end

function BossView:initRedPoint()
    local btn = self.btnList[1]
    local redPanel = btn:GetChild("n4")
    local redText = btn:GetChild("n5")
    local param = {panel = redPanel,text = redText, ids = {attConst.A20136},notnumber = true}
    mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    -- mgr.ModuleMgr:setModuleVisible(Modules,self.btnList,self.btnPos)
end 

function BossView:initActLogo()
    -- for i=1,#self.btnList - 1 do
    --     local btn = self.btnList[i]
    --     if Modules[i] ~= 1191 then
    --         local param = {id = {1060,1061,1062,1063,1064,1065,1066,3053},obj = btn:GetChild("n8")}--腊八活动显示活动标志 --EVE 小年
    --         mgr.ActivityMgr:setFubenActive(param)
    --     end
    -- end
end

function BossView:onSelectCall(context)
    -- body
    local btn = context.data
    local data = btn.data
    --local t = Modules 
    --print("data",data)
    if GCheckView({ id = data , falg = true } ) then
        self:nextStep(data)
    else
        if self.btnCall then
            self.btnCall.onClick:Call()
        end
    end
end

function BossView:panelClear()
    if self.controller1.selectedIndex ~= 1 then
        self.eliteBossPanel:clear()
    end
    if self.controller1.selectedIndex ~= 2 then
        cache.FubenCache:setWordIndex(nil)
        self.worldBossPanel:clear()
    end
    -- if self.controller1.selectedIndex ~= 3 then
    --     self.awakenHallPanel:clear()
    -- end
    if self.controller1.selectedIndex ~= 4 then
        cache.FubenCache:setBossHomeIndex(nil)
        self.bossHomePanel:clear()
    end

    if self.controller1.selectedIndex ~= 5 then
        cache.FubenCache:setXianYuBossIndex(nil)
        self.bossXianYuPanel:clear()
    end

    if self.controller1.selectedIndex ~= 6 then
        cache.FubenCache:setKuafuBossIndex(nil)
        self.kuaFuBossPanel:clear()
    end

    if self.controller1.selectedIndex ~= 7 then
        cache.FubenCache:setXianYuBossIndex(nil)
        self.kaufuXianYuPanel:clear()
    end

    if self.controller1.selectedIndex ~= 9 then
        cache.FubenCache:setShangGuBossIndex(nil)
        self.shangGuShenJiPanel:clear()
    end
    if self.controller1.selectedIndex ~= 10 then
        cache.FubenCache:setWuXingIndex(nil)
        self.wuXingPanel:clear()
    end

    if self.controller1.selectedIndex ~= 11 then
        cache.FubenCache:setFSBossIndex(nil)
        self.feishengPanel:clear()
    end

    if self.controller1.selectedIndex ~= 12 then
        cache.FubenCache:setShenShouBossIndex(nil)
        self.shenShouPanel:clear()
    end

    if self.controller1.selectedIndex ~= 13 then
        self.WanShenDianPanel:clear()
    end

    if self.controller1.selectedIndex ~= 14 then
        self.TaiGuXuanJingPanel:clear()
    end


end

function BossView:onController1()
    self:panelClear()
    if self.controller1.selectedIndex == 0 then
        proxy.FubenProxy:send(1026101)
    elseif self.controller1.selectedIndex == 1 then
        proxy.FubenProxy:send(1330101)
    elseif self.controller1.selectedIndex == 2 then
        proxy.FubenProxy:send(1330201)
    elseif self.controller1.selectedIndex == 3 then
        proxy.FubenProxy:send(1440101)
    elseif self.controller1.selectedIndex == 4 then
        -- proxy.AwakenProxy:send(1430101)
        proxy.FubenProxy:send(1450101)
    elseif self.controller1.selectedIndex == 5 then
        proxy.FubenProxy:send(1330401)
    elseif self.controller1.selectedIndex == 10 then
        proxy.FubenProxy:send(1330404)--请求掉落记录
    elseif self.controller1.selectedIndex == 6 then--宠物岛
        proxy.FubenProxy:send(1330501)
    elseif self.controller1.selectedIndex == 7 then--跨服仙域禁地
        proxy.FubenProxy:send(1330601)
    elseif self.controller1.selectedIndex == 8 then--上古神迹
        proxy.FubenProxy:send(1330801)
    elseif self.controller1.selectedIndex == 9 then--五行神殿
        proxy.FubenProxy:send(1330901)
    elseif self.controller1.selectedIndex == 11 then--飞升
        --feishengPanel
        proxy.FubenProxy:send(1331101)
    elseif self.controller1.selectedIndex == 12 then--神兽
        proxy.FubenProxy:send(1331201)
    elseif self.controller1.selectedIndex == 13 then--万神殿(五行圣殿)
        proxy.WanShenDianProxy:send(1331301)
    elseif self.controller1.selectedIndex == 14 then--太古玄境   

        proxy.TaiGuXuanJingProxy:send(1331501)
    end
end
--服务端数据返回
function BossView:setData(data)
    local msgId = data.msgId
    if self.controller1.selectedIndex == 0 and msgId == 5026101 then--个人boss
        self:updatePersonal(data)
    elseif self.controller1.selectedIndex == 1 and msgId == 5330101 then--精英boss
        self.eliteBossPanel:setGotoSceneId(self.childIndex)
        self:updateElite(data)
    elseif self.controller1.selectedIndex == 2 and msgId == 5330201 then--世界boss
        self.worldBossPanel:setGotoMonsterId(self.childIndex)
        self:updateWorld(data)
    elseif self.controller1.selectedIndex == 3 and msgId == 5440101 then--仙尊boss
        self:updateXianzun(data)
    elseif self.controller1.selectedIndex == 4 and msgId == 5450101 then--boss之家
        -- self:updateAwaken(data)
        self.bossHomePanel:setGotoSceneId(self.gotoSceneId)
        self.bossHomePanel:setGotoMonsterId(self.childIndex)
        self:updateBossHome(data)
    elseif self.controller1.selectedIndex == 5 and msgId == 5330401 then--仙域禁地
        self.bossXianYuPanel:setGotoMonsterId(self.childIndex)
        self:updateBossXianYu(data)
    elseif self.controller1.selectedIndex == 10 and msgId == 5330404 then -- 掉落记录 TODO
        self:updateDropRecord(data)
    elseif self.controller1.selectedIndex == 6 and msgId == 5330501 then -- 宠物岛
        -- self.kuaFuBossPanel:setGotoSceneId(self.gotoSceneId)
        self.kuaFuBossPanel:setGotoMonsterId(self.childIndex)
        self:updateKuafuBoss(data) 
    elseif self.controller1.selectedIndex == 7 and msgId == 5330601 then -- 跨服仙域禁地
        self.kaufuXianYuPanel:setGotoMonsterId(self.childIndex)
        self:updateKaufuXianYu(data)
    elseif self.controller1.selectedIndex == 8 and msgId == 5330801 then -- 上古神迹
        self.shangGuShenJiPanel:setGotoMonsterId(self.childIndex)
        self:updateShangGuShenJi(data)
    elseif self.controller1.selectedIndex == 9 and msgId == 5330901 then -- 五行神殿
        self.wuXingPanel:setGotoMonsterId(self.childIndex)
        self:updateWuXing(data)
    elseif self.controller1.selectedIndex == 11 and msgId == 5331101 then--飞升
        self.feishengPanel:setGotoMonsterId(self.childIndex)
        self:updateFS(data)
    elseif self.controller1.selectedIndex == 12 and msgId == 5331201 then--神兽
        self.shenShouPanel:setGotoMonsterId(self.childIndex)
        self:updateShenShou(data)
    elseif self.controller1.selectedIndex == 13 and msgId == 5331301 then--万神殿（五行圣殿）
        -- self.WanShenDianPanel:setGotoMonsterId(self.childIndex)
        self:updateWanShenDian(data)
    elseif self.controller1.selectedIndex == 14 and msgId == 5331501 then--太古玄境

        self.TaiGuXuanJingPanel:setGotoMonsterId(self.childIndex)
        self:updateTaiGuXuanJing(data)
    end
    self.childIndex = nil
    self.gotoSceneId = nil
end

--世界boss，宠物岛疲劳值bxp
function BossView:setBossLeftTimes(data)
    if data.sceneKind == 9 then--世界boss
        self.worldBossPanel:setBossLeftTimes(data)
    elseif data.sceneKind == 31 then
        self.kuaFuBossPanel:setKuFuLeftTimes(data)
    elseif data.sceneKind == 47 then
        self.feishengPanel:setBossLeftTimes(data)
    end
end
--模块跳转
function BossView:nextStep(id)
    -- for k ,v in pairs(self.btnList) do
    --     v.selected = false
    -- end
    -- print("当前跳转id>>>>>>>>>>>>>>",id)
    -- self.btnList[id].selected = true
    -- self.btnCall = self.btnList[id]
    --print("id ",id)
    local index = ModuleIndex[id]
    local num = 0
    for k,v in pairs(self.Modules) do
        if v == id then
            num = k - 1
            break
        end
    end
    self.titleList:ScrollToView(num,false)
    self.titleList:AddSelection(num,false)
    if self.controller1.selectedIndex == index then
        self:onController1()
    else
        self.controller1.selectedIndex = index
    end
end
--个人boss数据
function BossView:updatePersonal(data)
    self.personalBossPanel:setData(data)
end
--精英boss数据
function BossView:updateElite(data)
    self.eliteBossPanel:setData(data)
end
--请求精英boss次数购买
function BossView:setBuyCout(data)
    self.eliteBossPanel:setBuyCout(data)
end
--请求精英boss弹窗提示设置
function BossView:setTipScene(data)
    self.eliteBossPanel:setTipScene(data)
end
--世界boss数据
function BossView:updateWorld(data)
    self.worldBossPanel:setData(data)
end
--仙尊boss数据
function BossView:updateXianzun(data)
    self.xianzunBossPanel:setData(data)
end
--仙尊boss疲劳值
function BossView:setLeftTimes(data)
    self.xianzunBossPanel:setLeftTimes(data)
end
--boss之家
function BossView:updateBossHome(data)
    self.bossHomePanel:setData(data)
end
--仙域禁地
function BossView:updateBossXianYu(data)
    self.bossXianYuPanel:setData(data)
end
--宠物岛
function BossView:updateKuafuBoss(data)
    self.kuaFuBossPanel:setData(data)
end
--跨服仙域禁地
function BossView:updateKaufuXianYu(data)
    self.kaufuXianYuPanel:setData(data)
end
--上古神迹
function BossView:updateShangGuShenJi(data)
    self.shangGuShenJiPanel:setData(data)
end
--五行神殿
function BossView:updateWuXing(data)
    self.wuXingPanel:setData(data)
end
--神殿
function BossView:updateFS(data)
    self.feishengPanel:setData(data)
end
--剑神殿数据
function BossView:updateAwaken(data)
    -- self.awakenHallPanel:setData(data)
end

--神兽数据
function BossView:updateShenShou(data)
    self.shenShouPanel:setData(data)
end

--万神殿数据
function BossView:updateWanShenDian(data)
    self.WanShenDianPanel:setData(data)
end

--太古玄境数据
function BossView:updateTaiGuXuanJing(data)

    self.TaiGuXuanJingPanel:setData(data)
end

--掉落记录更新
function BossView:updateDropRecord(data)
    self.dropRecordPanel:setData(data)
end

function BossView:onClickClose()
    cache.FubenCache:setWordIndex(nil)
    cache.FubenCache:setBossHomeIndex(nil)
    cache.FubenCache:setXianYuBossIndex(nil)
    cache.FubenCache:setKuafuBossIndex(nil)
    cache.FubenCache:setShangGuBossIndex(nil)
    cache.FubenCache:setWuXingIndex(nil)
    self:closeView()
end

function BossView:clearEvent()
    self:clear()
end

function BossView:clear()
    self.eliteBossPanel:clear()
    self.worldBossPanel:clear()
    self.xianzunBossPanel:clear()
    self.bossHomePanel:clear()
    self.bossXianYuPanel:clear()
    self.kuaFuBossPanel:clear()
    self.kaufuXianYuPanel:clear()
    self.shangGuShenJiPanel:clear()
    self.wuXingPanel:clear()
    self.feishengPanel:clear()
    self.shenShouPanel:clear()
    self.WanShenDianPanel:clear()
    self.TaiGuXuanJingPanel:clear()
    -- self.awakenHallPanel:clear()
end
--boss规则
function BossView:onClickRule()
    -- GOpenRuleView(1031)
    if self.controller1.selectedIndex == 0 then
        GOpenRuleView(1055)
    elseif self.controller1.selectedIndex == 1 then
        GOpenRuleView(1056)
    elseif self.controller1.selectedIndex == 2 then
        GOpenRuleView(1057)
    elseif self.controller1.selectedIndex == 3 then
        GOpenRuleView(1058)
    elseif self.controller1.selectedIndex == 4 then
        GOpenRuleView(1059)
    elseif self.controller1.selectedIndex == 5 then
        GOpenRuleView(1060)
    elseif self.controller1.selectedIndex == 6 then
        GOpenRuleView(1080)
    elseif self.controller1.selectedIndex == 7 then
        GOpenRuleView(1085)
    elseif self.controller1.selectedIndex == 9 then
        GOpenRuleView(1101)
    elseif self.controller1.selectedIndex == 11 then
        GOpenRuleView(1133)
    elseif self.controller1.selectedIndex == 12 then
        GOpenRuleView(1135)
    elseif self.controller1.selectedIndex == 13 then
        GOpenRuleView(1145)
    elseif self.controller1.selectedIndex == 14 then
        GOpenRuleView(1378)    
    end
end

function BossView:dispose(clear)
    if g_var.gameFrameworkVersion >= 2 then
        UnityResMgr:ForceDelAssetBundle(UIItemRes.bossWorld)
    end
    self.super.dispose(self, clear)
end

return BossView