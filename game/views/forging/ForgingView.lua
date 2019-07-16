--
-- Author: ohf
-- Date: 2017-02-06 16:11:01
--
--锻造界面
local ForgingView = class("ForgingView", base.BaseView)

local StrengPanel = import(".StrengPanel")--强化区域

local StarPanel = import(".StarPanel")--升星区域

local CameoPanel = import(".CameoPanel")--宝石区域

local MakePanel = import(".MakePanel")--打造区域

local FusePanel = import(".FusePanel")--合成区域

local SplitResPanel = import(".SplitResPanel")--分解区域

local SuitDzPanel = import(".SuitDzPanel")--套装锻造区域

local ZhuStarPanel = import(".ZhuStarPanel")--戒指、手镯2个部位的装备进阶、铸星功能 进阶

local ZhuStarPanel = import(".ZhuStarPanel")

local PaoGuangPanel = import(".PaoGuangPanel")--宝石抛光
    
local list = {1029,1030,1031,1153,1033,1124,1134,1154,1412}

local sortList = {
    [1029] = {sort = 1,selectedIndex = 0},--强化
    [1030] = {sort = 2,selectedIndex = 1},--升星
    [1031] = {sort = 3,selectedIndex = 2},--宝石
    [1153] = {sort = 7,selectedIndex = 3},--进阶
    [1033] = {sort = 4,selectedIndex = 4},--合成
    [1124] = {sort = 5,selectedIndex = 5},--分解
    [1134] = {sort = 6,selectedIndex = 6},--装备套装
    [1154] = {sort = 8,selectedIndex = 7},--铸星
    [1412] = {sort = 9,selectedIndex = 8},--抛光
}
local redList = {
    [1029] = attConst.A10229,--1029
    [1030] = attConst.A10230,--1030
    [1031] = attConst.A10231,--1031
    [1153] = 0,--1153
    [1033] = attConst.A10233,--1033
    [1124] = 0,--1124
    [1134] = attConst.A10250,--1134
    [1154] = 0,--1154
    [1412] = 0,--1412
}
function ForgingView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheForever
    self.openTween = ViewOpenTween.scale
end

function ForgingView:initData(data)
    GSetMoneyPanel(self.window2,self:viewName())
    self.childIndex = data and data.childIndex
    self:setModuleOpens()
    self.listView.numItems = #self.openLists
    local index = data and data.index
    self:nextStep(index)
    self.super.initData()
end

function ForgingView:nextStep(id)
    local myModelId = id or self.modelId or 1029
    for i=1,self.listView.numItems do
        local btn = self.listView:GetChildAt(i - 1)
        local data = btn.data
        local modelId = data.modelId
        if modelId == myModelId then
            self.listView:ScrollToView(i - 1)
            btn.onClick:Call()
            break
        end
    end
    self.selectedIndex = sortList[myModelId].selectedIndex
    proxy.ForgingProxy:send(1100101, {part = 0,roleId = 0,svrId = 0})
end

function ForgingView:refreshRed()
    self.listView.numItems = #self.openLists
end

function ForgingView:initView()
    self.window2 = self.view:GetChild("n0")
    local closeBtn = self.window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.mainController = self.view:GetController("c1")--主控制器
    self.mainController.onChanged:Add(self.selelctPage,self)--给控制器获取点击事件

    self.listView = self.view:GetChild("n19")
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.strengPanel = StrengPanel.new(self)
    self.starPanel = StarPanel.new(self)
    self.cameoPanel = CameoPanel.new(self)--宝石区域
    --self.makePanel = MakePanel.new(self)
    self.fusePanel = FusePanel.new(self)
    self.splitResPanel = SplitResPanel.new(self)
    self.suitDzPanel = SuitDzPanel.new(self)
end

--设置已经开启的模块
function ForgingView:setModuleOpens()
    self.openLists = {}
    local _t = {}
    for k ,v in pairs(list) do
        if mgr.ModuleMgr:CheckSeeView(v) then 
            table.insert(_t, {id = v ,sort = sortList[v].sort})
        end
    end
    table.sort(_t,function(a,b)
        return a.sort < b.sort
    end)
    for k ,v in pairs(_t) do
        table.insert(self.openLists,v.id)
    end
end

function ForgingView:cellData(index,btn)
    local modelId = self.openLists[index + 1]
    btn.title = language.forging37[modelId]
    btn.data = {modelId = modelId} 
    btn.onClick:Add(self.onClickBtn,self)
    local redPanel = btn:GetChild("n4")
    local redText = btn:GetChild("n5")
    if modelId == 1153 then
        --计算进阶红点
        redText.visible = false
        if G_equip_jie() > 0 then
            redPanel.visible = true
        else
            redPanel.visible = false
        end
    elseif modelId == 1154 then
        --计算铸星红点
        redText.visible = false
        if G_equip_zhuxin() > 0 then
            redPanel.visible = true
        else
            redPanel.visible = false
        end
    elseif modelId == 1412 then--抛光红点
        redText.visible = false
        if cache.PackCache:getPaoGuangRed() > 0 then
            redPanel.visible = true
        else
            redPanel.visible = false
        end
    elseif redList[modelId] then
        local param = {panel = redPanel,text = redText, ids = {redList[modelId]},notnumber = true}
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    else
        redPanel.visible = false
        redText.visible = false
    end
end

function ForgingView:onClickBtn(context)
    local modelId = context.sender.data.modelId
    self.modelId = modelId
    self.mainController.selectedIndex = sortList[modelId].selectedIndex
end

function ForgingView:setData(isRef)
    self.isRef = isRef
    local selectedIndex = self.selectedIndex or 0
    if self.mainController.selectedIndex ~= selectedIndex then
        self.mainController.selectedIndex = selectedIndex
    else
        if selectedIndex ~= 6 then
            self:selelctPage()
        end
    end
    self:refreshRed()
end

function ForgingView:selelctPage()
    local selectedIndex = self.mainController.selectedIndex
    self.selectedIndex = selectedIndex
    -- if selectedIndex ~= 3 then
    --     self.makePanel:clear()
    -- end
    if selectedIndex ~= 4 then
        self.fusePanel:clear()
    end
    if selectedIndex ~= 2 then
        self.cameoPanel:clear()
    end
    if selectedIndex == 0 then--强化区域
        self.strengPanel:setData()
    elseif selectedIndex == 1 then--升星区域
        self.starPanel:setChildIndex(self.childIndex)
        self.starPanel:setData()
    elseif selectedIndex == 2 then--宝石区域
        self.cameoPanel:setChildIndex(self.childIndex)
        self.cameoPanel:setData()
    elseif selectedIndex == 3 then--进阶
        --
        if not self.ZhuStarPanel then
            self.ZhuStarPanel = ZhuStarPanel.new(self.view:GetChild("n17"))
        end
        self.ZhuStarPanel:setSelect(1)
        -- if not self.makeChoose then 
        --     self.makePanel:setChoose()
        --     self.makeChoose = true
        -- end
        -- self.makePanel:setChildIndex(self.childIndex)
        -- proxy.ForgingProxy:send(1100105,{itemId = 0,reqType = 2})
    elseif selectedIndex == 4 then--合成区域
        if not self.fuseChoose then
            self.fusePanel:setChoose()
            self.makeChoose = true
        end
        self.fusePanel:clear()
        self.fusePanel:clearinfo()
        self.fusePanel:getPackData()
        self.fusePanel:setData()
        --proxy.ForgingProxy:send(1100111)
    elseif selectedIndex == 5 then
        if not self.isRef then
            self.splitResPanel:setData()
        end
    elseif selectedIndex == 6 then
        proxy.ForgingProxy:send(1100116,{reqType = 0, part = 0})
    elseif selectedIndex == 7 then
        --铸星
        if not self.ZhuStarPanel then
            self.ZhuStarPanel = ZhuStarPanel.new(self.view:GetChild("n17"))
        end
        self.ZhuStarPanel:setSelect(0)
    elseif selectedIndex == 8 then
        if not self.paoGuangPanel then
            self.paoGuangPanel = PaoGuangPanel.new(self)
        end
        self.paoGuangPanel:setData()
        
    end
    self.isRef = nil
    self.childIndex = nil
end
--套装
function ForgingView:setSuitDzData(data)
    self.suitDzPanel:setData(data)
end
--套装锻造
function ForgingView:refreshSuitDz(data)
    self.suitDzPanel:refreshChoose(data)
end
--返回升星
function ForgingView:setStarSuc(starSuc)
    self.starPanel:setStarSuc(starSuc)
end
--返回打造数据
function ForgingView:updateMakeData(data)
    --self.makePanel:updateRate(data)
end

function ForgingView:setMakeData(data)
    --self.makePanel:setData(data)
end

function ForgingView:setMakeRef()
    --self.makePanel:setRef()
end

function ForgingView:setFuseData()
    self.fusePanel:setData()
end

function ForgingView:setFuseList(buildReds)
    self.fusePanel:setFuseList(buildReds)
    self.fusePanel:setData()
end
--返回宝石镶嵌
function ForgingView:setGemHole(hole)
    self.cameoPanel:setGemHole(hole)
end
--返回宝石一键镶嵌
function ForgingView:setOneKeySucc(holes)
    self.cameoPanel:setOneKeySucc(holes)
end
--设置分解的道具
function ForgingView:setSplitItem(itemData)
    self.splitResPanel:setChooseItem(itemData)
end

function ForgingView:onClickClose()
    self:closeView()
end

function ForgingView:closeView()
    self.mainController.selectedIndex = 0
    self.makeChoose = nil
    self.fuseChoose = nil
    self.strengPanel:clear()
    --self.makePanel:clear()
    self.fusePanel:clear()
    self.cameoPanel:clear()
    self.splitResPanel:clear()
    self.suitDzPanel:clear()

    local view = mgr.ViewMgr:get(ViewName.Alert3)
    if view then
        view:closeView()
    end
    self.super.closeView(self)
end

function ForgingView:addMsgCallBack( data )
    -- body
    if data.msgId == 5100112 or data.msgId == 5530105 or data.msgId == 5100301 or data.msgId == 5600106 
        or  data.msgId == 5190202 or data.msgId == 5100401 or data.msgId == 5590106 or data.msgId == 5610107  then
        --print("self.mainController.selectedIndex",self.mainController.selectedIndex)
        if self.mainController.selectedIndex == 4 then
            self.fusePanel:addMsgCallBack(data)
        end
    elseif data.msgId == 5100114 or data.msgId == 5100115  then
        if self.mainController.selectedIndex == 3 
        or self.mainController.selectedIndex == 7  then
            if self.ZhuStarPanel then
                self.ZhuStarPanel:addMsgCallBack(data)
            end
        end
    elseif data.msgId == 5100117 then--抛光
        if self.paoGuangPanel then
            self.paoGuangPanel:addMsgCallBack(data)
        end
    end
end

return ForgingView