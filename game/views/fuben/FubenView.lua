--
-- Author: ohf
-- Date: 2017-03-06 20:29:07
-- Remarks: EVE 屏蔽练级谷
--副本界面
local FubenView = class("FubenView", base.BaseView)

local AdvancedPanel = import(".AdvancedPanel")--进阶

local VipPanel = import(".VipPanel")--vip副本

local CopperPanel = import(".CopperPanel")--铜钱副本

local ExpPanel = import(".ExpPanel")--经验副本

local PlotPanel = import(".PlotPanel")--剧情副本

local TowerPanel = import(".TowerPanel")--爬塔副本
-- 
local LevelPanel = import(".LevelPanel")--练级谷

local TeamFuben = import("game.views.kuafu.TeamFuben")--组队副本
    
local PanelSingle = import(".PanelSingle")--单人守塔 

local PanelMany = import(".PanelMany")--组队守塔 

local RuneTower = import(".RuneTower")

local ShengXiaoShiLian = import(".ShengXiaoShiLian")--生肖试炼

local sortList = {
    [1019] = 2,--进阶
    [1020] = 4,--Vip
    [1021] = 9,--铜钱
    [1022] = 8,--剧情
    [1023] = 10,--经验
    [1024] = 12,--爬塔
    [1025] = 11,--练级谷
    [1093] = 7,--跨服组队副本
    [1130] = 3,--单人守塔
    [1131] = 5,--组队守塔
    [1132] = 1,--秘境修炼
    [1133] = 6,--幻境镇妖
    [1218] = 13,--幻境镇妖
    [1448] = 14,--生肖试炼
}
--模块组件名字
local PanelName = {
    [1019] = "AdvancedPanel",
    [1020] = "VipPanel",
    [1021] = "CopperPanel",
    [1023] = "ExpPanel",
    [1024] = "TowerPanel",
    [1025] = "LevelPanel",--练级谷 
    [1093] = "TeamFuben",
    [1130] = "PanelSingle",--单人守塔
    [1131] = "PanelMany",--组队守塔
    [1218] = "RuneTower",--组队守塔
    [1448] = "ShengXiaoShiLian",--生肖试炼
}
--可能开启的模块
local openList = {
    1019,--进阶
    1020,--Vip
    1021,--铜钱
    1023,--经验
    1024,--爬塔
    1025,--练级谷
    1093,--跨服组队副本
    1130,--单人守塔
    1131,--组队守塔
    1132,--秘境修炼
    1133,--幻境镇妖
    1218,--符文塔
    1448,--生肖试炼
}
--红点键值
local redList = {
    [1019] = attConst.A50101,
    [1020] = attConst.A50102,
    [1021] = attConst.A50103,
    [1023] = attConst.A50105,
    [1024] = attConst.A50106,
    [1025] = attConst.A10316,--练级谷 
    [1132] = attConst.A50113,
    [1133] = attConst.A50114,
    [1130] = attConst.A50115,
    [1131] = attConst.A50116, 
    [1093] = attConst.A50117,
    [1448] = attConst.A50135,
}


function FubenView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheForever
    --self.drawcall = false
end

function FubenView:initData(data)
    GSetMoneyPanel(self.window,self:viewName())
    self.childIndex = data.childIndex
    self:setModuleOpens()
    self.listView.numItems = #self.openLists
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil  
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
    local gotoModelId = data.index or 1019
    self:nextStep(gotoModelId)--跳转
    self.super.initData()
end

function FubenView:initView()
    self.showObj = {}
    self.classObj = {}
    self.window = self.view:GetChild("n0")
    self.bgImg = self.window:GetChild("n6")
    local closeBtn = self.window:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.listView = self.view:GetChild("n20")
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.frame1 = self.view:GetChild("n16")--两块遮挡板
    self.frame2 = self.view:GetChild("n17")
    self.container = self.view:GetChild("n22")

    self.listView.sortingOrder = 2
    self.frame2.sortingOrder = 1
    self.frame1.sortingOrder = 1
    self.container.sortingOrder = 0
end

function FubenView:cellData(index,btn)
    local modelId = self.openLists[index + 1]
    btn.title = language.fuben67[modelId]
    btn.data = {modelId = modelId} 
    btn.onClick:Add(self.onClickBtn,self)
    local redPanel = btn:GetChild("n4")
    local redText = btn:GetChild("n5")
    --系统开启才注册红点2018/3/26 
    --单人守塔，没开启就有红点问题
    if mgr.ModuleMgr:CheckView(modelId) then
        local param = {panel = redPanel,text = redText, ids = {redList[modelId]},notnumber = true}
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    end

    local param = {obj = btn:GetChild("n7"),moduleId = modelId}
    mgr.GuiMgr:registerDoubleFuben(param,self:viewName())
end

--设置已经开启的模块
function FubenView:setModuleOpens()
    self.openLists = {}
    local _t = {}
    for k ,v in pairs(openList) do
        if mgr.ModuleMgr:CheckSeeView(v) then 
            table.insert(_t, {id = v ,sort = sortList[v] })
        end
    end

    table.sort(_t,function(a,b)
        -- body
        return a.sort < b.sort
    end)

    for k ,v in pairs(_t) do
        table.insert(self.openLists,v.id)
    end
end

function FubenView:onTimer()
    if self.modelId == 1093 then
        if self.teamFuben then
            self.teamFuben:onTimer()
        end
    elseif self.modelId == 1132 then
        if self.panelSingle then
            self.panelSingle:onTimer()
        end
    elseif self.modelId == 1448 then
        if self.ShengXiaoShiLian then
            self.ShengXiaoShiLian:onTimer()
        end
    end    
end

function FubenView:setData(data)
    local msgId = data.msgId
    if  msgId == 5024401 then--进阶
        self:updateAdvaned(data)
    elseif msgId == 5024311 then--vip
        self:updateVip(data)
    elseif msgId == 5023101 then--铜钱
        self:updateCopper(data)
    elseif msgId == 5024201 then--剧情
        self:updatePlot(data)
    elseif msgId == 5024101 then--经验
        self:updateExp(data)
    elseif msgId == 5024301 then--爬塔
        self:updateTower(data)
    elseif msgId == 5025101 then--练级谷
        self:updateLevel(data)
    elseif msgId == 5380101 or msgId == 5380102 
    or msgId == 5380103 or msgId == 5380104 or msgId == 5380105 
    or msgId == 8150101 or 8010101 == msgId then --组队副本
        if self.teamFuben then
            self.teamFuben:addMsgCallBack(data)
        end
    elseif msgId == 5027201 
    or msgId == 5027202 
    or msgId == 5027301 
    or msgId == 5027302
    or msgId == 5027306
    or msgId == 5027307
    or msgId == 5027308
    or msgId == 5027309 
    or msgId == 5027205 then --单人守塔
        if self.panelSingle then
            self.panelSingle:addMsgCallBack(data)
        end
    elseif msgId == 5027401 or msgId == 5027403  then --组队守塔
        if self.PanelMany then
            self.PanelMany:addMsgCallBack(data)
        end
    elseif msgId == 5024320 then
        self:updateRuneTower(data)
    elseif msgId == 5028301 or msgId == 5028302 then
        if self.ShengXiaoShiLian then
            self.ShengXiaoShiLian:addMsgCallBack(data)
        end
    end
    self.childIndex = nil
end

function FubenView:onClickBtn(context)
    local btn = context.sender
    local data = btn.data
    local modelId = data.modelId
    if modelId == 1218 then--符文塔
        local confData = conf.SysConf:getModuleById(modelId)
        local data = cache.ActivityCache:get5030111() or {}
        local openDay = data.openDay or 0
        if openDay < confData.openday then
            GComAlter(string.format(language.rune33, confData.openday))
            return
        end
    end
    if mgr.ModuleMgr:CheckView({id = modelId,falg = true}) then
        --开启了
        self.oldselect = btn
    else
        btn.selected = false
        if self.oldselect then
            self.oldselect.selected = true
        end 
        return
    end

    self:sendFubenMsg(modelId)
    self:refresh()
end
--当前选中的panel
function FubenView:getChoosePanelObj(id)
    return self.showObj[id]
end
--创建副本组件
function FubenView:createObj(modelId)
    if modelId == 1132 or modelId == 1133 then--用单人守塔的组件
        modelId = 1130
    end
    if not self.showObj[modelId] then --用来缓存
        local var = PanelName[modelId]
        self.showObj[modelId] = UIPackage.CreateObject("fuben" ,var)
        self.container:AddChildAt(self.showObj[modelId],0)--添加新的
    end
    for k,v in pairs(self.showObj) do
        if k == modelId then
            v.visible = true
        else
            v.visible = false
        end
    end
    
    --
    if modelId == 1024 or modelId == 1131  then--爬塔
        self.frame1.visible = true
        self.frame2.visible = true
    else
        self.frame1.visible = false
        self.frame2.visible = false
    end
end

function FubenView:sendFubenMsg(modelId)
    self.modelId = modelId
    self:clearPanel()
    self:createObj(modelId)
    if modelId ~= 1022 then--剧情
        cache.FubenCache:setPlotIndex(nil)
    end
    if modelId == 1019 then--进阶
        if self.childIndex then
            cache.FubenCache:setAdvIndex(self.childIndex - 1)
        end
        if not self.advancedPanel then
            self.advancedPanel = AdvancedPanel.new(self)
        end
        self.advancedPanel:setData()
    elseif modelId == 1020 then--vip
        if not self.vipPanel then
            self.vipPanel = VipPanel.new(self)
        end
        proxy.FubenProxy:send(1024311)
    elseif modelId == 1021 then--铜钱
        if not self.copperPanel then
            self.copperPanel = CopperPanel.new(self)
        end
        proxy.FubenProxy:send(1023101,{sceneId = Fuben.copper})
    elseif modelId == 1022 then--剧情
        if not self.plotPanel then
            self.plotPanel = PlotPanel.new(self)
        end
        proxy.FubenProxy:send(1024201)
    elseif modelId == 1023 then--经验
        if not self.expPanel then
            self.expPanel = ExpPanel.new(self)--经验副本
        end
        proxy.FubenProxy:send(1024101,{sceneId = Fuben.exp})
    elseif modelId == 1024 then--爬塔
        if not self.towerPanel then
            self.towerPanel = TowerPanel.new(self)--爬塔副本
        end
        proxy.FubenProxy:send(1024301)
    elseif modelId == 1025 then--练级谷
        if not self.levelPanel then
            self.levelPanel = LevelPanel.new(self)
        end
        proxy.FubenProxy:send(1025101)
    elseif modelId == 1093 then --跨服组队副本
        proxy.KuaFuProxy:sendMsg(1400101,{},0) --请求跨服活动列表信息
    elseif modelId == 1130 then --单人守塔
        if not self.panelSingle then
            self.panelSingle = PanelSingle.new(self)
        end
        self.panelSingle:setModelId(modelId)
        proxy.FubenProxy:send(1027201)
    elseif modelId == 1131 then --组队守塔
        if not self.PanelMany then
            self.PanelMany = PanelMany.new(self)
        end
        self.PanelMany:setData()
        proxy.FubenProxy:send(1027401)
    elseif modelId == 1132 then--秘境修炼
        if not self.panelSingle then
            self.panelSingle = PanelSingle.new(self)
        end
        self.panelSingle:setModelId(modelId)
		
        proxy.FubenProxy:send(1027301)
		
		mgr.XinShouMgr:MijingGuilde()
    elseif modelId == 1133 then--幻境镇妖
        if not self.panelSingle then
            self.panelSingle = PanelSingle.new(self)
        end
        self.panelSingle:setModelId(modelId)
        proxy.FubenProxy:send(1027309)
    elseif modelId == 1218 then--幻境镇妖
        if not self.runeTower then
            self.runeTower = RuneTower.new(self)
        end
        proxy.FubenProxy:send(1024320)
    elseif modelId == 1448 then--生肖试炼
        if not self.ShengXiaoShiLian then
            self.ShengXiaoShiLian = ShengXiaoShiLian.new(self)
        else
            self.ShengXiaoShiLian:initList()
        end
        proxy.FubenProxy:send(1028301)
    end
end
--返回跨服活动列表（跨服组队副本）
function FubenView:add5400101(data)
    if not self.teamFuben then
        self.teamFuben = TeamFuben.new(self:getChoosePanelObj(1093))
    end
    if cache.KuaFuCache:isWillOpenByid(2) then
        if self.teamFuben then --列表
            self.teamFuben:setWillOpen()
        end
    else
        proxy.KuaFuProxy:sendMsg(1380101,{teamId=0})--请求消息
    end
end
--刷新当前副本
function FubenView:refresh()
    self:sendFubenMsg(self.modelId)
end
--铜钱
function FubenView:updateCopper(data)
    if self.copperPanel then self.copperPanel:setData(data) end
end
--经验
function FubenView:updateExp(data)
    if self.expPanel then self.expPanel:setData(data) end
end
--领取经验首通奖励
function FubenView:setFirstData(data)
    if self.expPanel then self.expPanel:setFirstData(data) end
end
--剧情副本
function FubenView:updatePlot(data)
    if self.plotPanel then self.plotPanel:setData(data) end
end
--爬塔副本
function FubenView:updateTower(data)
    if self.towerPanel then self.towerPanel:setData(data) end
end
--vip副本
function FubenView:updateVip(data)
    if self.vipPanel then self.vipPanel:setData(data) end
end
--进阶副本
function FubenView:updateAdvaned(data)
    if self.advancedPanel then self.advancedPanel:updateFuben(data) end
end
--重置
function FubenView:resetAdvanced(data)
    if self.advancedPanel then self.advancedPanel:resetFuben(data) end
end

function FubenView:updateLevel(data)
    if self.levelPanel then self.levelPanel:setData(data) end
end
--更新符文塔信息
function FubenView:updateRuneTower(data)
    if self.runeTower then self.runeTower:setData(data) end
end
--刷新生肖试炼挑战次数
function FubenView:refreshShengXiao(data)
    if self.ShengXiaoShiLian then
        self.ShengXiaoShiLian:refreshBuyTimes(data)
    end
end
--跳转到指定的模块id
function FubenView:nextStep(id)
    for i=1,self.listView.numItems do
        local btn = self.listView:GetChildAt(i - 1)
        local data = btn.data
        local modelId = data.modelId
        if modelId == id then
            self.listView:ScrollToView(i - 1)
            btn.onClick:Call()
            break
        end
    end
end

function FubenView:onClickClose()
    self:clearPanel()
    if not mgr.FubenMgr:isTower(cache.PlayerCache:getSId()) then
        cache.FubenCache:cleanTowerFirst()
    end
    cache.FubenCache:setAdvIndex(nil)
    cache.FubenCache:setPlotIndex(nil)
    self:closeView()
end

function FubenView:clearPanel()
    if self.advancedPanel then self.advancedPanel:clear() end
    if self.vipPanel then self.vipPanel:clear() end
    if self.copperPanel then self.copperPanel:clear() end
    if self.expPanel then self.expPanel:clear() end
    if self.plotPanel then self.plotPanel:clear() end
    if self.towerPanel then self.towerPanel:clear() end
    if self.levelPanel then self.levelPanel:clear() end
    if self.panelSingle then self.panelSingle:clear() end
    if self.runeTower then self.runeTower:clear() end
end

function FubenView:refreshAdv()
    if self.advancedPanel then self.advancedPanel:refreshFuben() end
end

function FubenView:dispose(clear)
    if g_var.gameFrameworkVersion >= 2 then
        UnityResMgr:ForceDelAssetBundle(UIItemRes.levelFuben01)
        UnityResMgr:ForceDelAssetBundle(UIItemRes.copperFuben01)
        UnityResMgr:ForceDelAssetBundle(UIItemRes.towerFuben02)

        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_022")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_023")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_024")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_054")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_055")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."juqingfuben_056")
        UnityResMgr:ForceDelAssetBundle(UIItemRes.fuebenImg.."xianyulingta_002")
        
        UnityResMgr:ForceDelAssetBundle(UIItemRes.mjxlBg)
        UnityResMgr:ForceDelAssetBundle(UIItemRes.hjzyBg)
    end
    self.super.dispose(self, clear)
end

return FubenView