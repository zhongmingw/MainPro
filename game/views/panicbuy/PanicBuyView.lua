--
-- Author: 
-- Date: 2017-07-27 19:58:06
--
--特惠抢购
local PanicBuyView = class("PanicBuyView", base.BaseView)

local PanicBuyPanel = import(".PanicBuyPanel")--限时抢购

local OddsGiftPanel = import(".OddsGiftPanel")--特惠礼包

local VipWorkPanel = import(".VipWorkPanel")--vip礼包

local GradeSale = import(".GradeSale")--等级特卖

local Active1021 = import(".Active1021")--战骑技能书

local Active3009 = import(".Active3009")--伙伴技能书
local pack = "panicbuy"

local PanelName = {
    [1035] = "PanicBuyPanel",
    [1026] = "OddsGiftPanel",
    [1032] = "OddsGiftPanel",
    [1039] = "GradeSale",
    [1034] = "VipWorkPanel",
    [1021] = "SkillShop",
    [3009] = "SkillShop",
}
local PanelClass = {
    [1035] = PanicBuyPanel,
    [1026] = OddsGiftPanel,
    [1032] = OddsGiftPanel,
    [1039] = GradeSale,
    [1034] = VipWorkPanel,
    [1021] = Active1021,
    [3009] = Active3009,
}

function PanicBuyView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function PanicBuyView:initView()
    self.showObj = {}
    self.classObj = {}
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n5")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.listView = self.view:GetChild("n4")
    -- listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    self.container = self.view:GetChild("n5")
end

function PanicBuyView:initData(data)
    self.data = nil
    local confData = conf.ActivityConf:getActiveByActPos(4)
    self.childIndex = data and data.childIndex or 0
    local actData = cache.ActivityCache:get5030111()
    self.confData = {}
    for k ,v in pairs(confData) do
        if actData and actData.acts[v.id] == 1 and v.id ~= 1021 and v.id ~= 3009 then --这个活动开启了 屏蔽技能特卖
            if v.id == 1039 then
                if cache.PlayerCache:getRedPointById(attConst.A20128) <= 100 then
                    table.insert(self.confData,v)
                end
            else
                table.insert(self.confData,v)
            end
        end
    end
    self.nextId = self.mId or self.confData[1] and self.confData[1].id
    self:nextStep(data.index)

    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil 
    end

    self.timer = self:addTimer(1,-1,handler(self,self.onTimer))
end

function PanicBuyView:updatePanic(data)
    self.classObj[1035]:setData(data)
end

function PanicBuyView:updateOddsGift(data)
    if self.classObj[1026] then
        self.classObj[1026]:setData(data)
    else
        self.classObj[1032]:setData(data)
    end
end
--等级特卖
function PanicBuyView:updatelvBuy(data)
    self.classObj[1039]:setData(data)
end
--vip
function PanicBuyView:updateVip(data)
    self.classObj[1034]:setData(data)
end

function PanicBuyView:nextStep(id)
    if id then
        self.nextId = id
    end
    self.listView.numItems = #self.confData
    -- self.listView:ScrollToView(self.nextId - 1)
    for k,v in pairs(self.confData) do
        local cell = self.listView:GetChildAt(k - 1)
        local cellData = cell and cell.data or nil
        if cellData and cellData.data.id == id then
            self.listView:ScrollToView(cellData.index)
            break
        end
    end
    self.nextId = nil
end

function PanicBuyView:cellData(index, cell)
    local data = self.confData[index + 1]
    cell.data = {data = data,index = index}
    cell.icon = UIPackage.GetItemURL(pack , data.iconup)
    cell.selectedIcon = UIPackage.GetItemURL(pack , data.icondown)
    if data.id == self.nextId then 
        cell.selected = true
        local context = {data = cell}
        self:onClickItem(context)
    else
        cell.selected = false
    end
    local redimg = cell:GetChild("n4")
    local redText = cell:GetChild("n5") 
    if data.redid then
        local param = {}
        param.panel = redimg
        param.text = redText
        param.ids = {data.redid}
        param.notnumber = true
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    else
        redimg.visible = false
        redText.visible = false
    end
end

function PanicBuyView:onClickItem(context)
    local cell = context.data
    local data = cell.data
    self.data = data.data
    -- if self.data.id ~= 1021 or self.data.id ~= 3009 then
        self:setPanelData(self.data.id)
    -- end
end

function PanicBuyView:onTimer()
    -- body
    if not self.mId then
        return
    end
    if not self.classObj then
        return
    end
    if not self.classObj[self.mId] then
        return
    end
    self.classObj[self.mId]:onTimer() 
end

function PanicBuyView:setPanelData(id)
    local falg = false
    if not self.showObj[id] then --用来缓存
        local var = PanelName[id]
        self.showObj[id] = UIPackage.CreateObject(pack ,var)
        --添加新的
        self.container:AddChild(self.showObj[id])
        falg = true
    end

    for k,v in pairs(PanelName) do
        if k == id then
            if falg then
                self.classObj[id] = PanelClass[id].new(self,self.showObj[id])   
            end
            self.classObj[id]:setVisible(true)
            self.classObj[id]:sendMsg(id)
        else
            if self.classObj[k] then
                self.classObj[k]:setVisible(false)
            end
        end
    end
    self.mId = id
end

function PanicBuyView:onClickClose()
    -- for k,v in pairs(self.classObj) do
    --     v:clear()
    -- end
    self.mId = nil
    self:removeTimer(self.timer)
    self:closeView()
end

function PanicBuyView:addMsgCallBack( data )
    -- body
    if data.msgId == 5030142 then
        if self.mId == 1021  and self.classObj[self.mId] then
            self.classObj[self.mId]:add5030142(data)
        end
    elseif data.msgId == 5030143 then
        if self.mId == 3009 and self.classObj[self.mId] then
            self.classObj[self.mId]:add5030142(data)
        end
    end
end

return PanicBuyView