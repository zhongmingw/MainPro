--
-- Author: 
-- Date: 2017-11-15 16:32:37
--

local FubenSweepView = class("FubenSweepView", base.BaseView)

function FubenSweepView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function FubenSweepView:initView()
    self.ids = {}--要扫荡的id数组
    self.selectlist = {}--选择的id字典
    self.price = 0--价格
    self.haveCostNum, self.costNum = 0,0--拥有的扫荡卷数量，消耗的数量
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    local cancelBtn = self.view:GetChild("n6")
    self:setCloseBtn(cancelBtn)

    local sweepBtn = self.view:GetChild("n7")
    sweepBtn.onClick:Add(self.onClickSweep,self)

    self.costIcon = self.view:GetChild("n4")--扫荡卷的图标
    self.costCount = self.view:GetChild("n5")

    self.listView = self.view:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellSweepData(index, obj)
    end
end

function FubenSweepView:initData(data)
    self.data = data
    local mId = 1
    for k,v in pairs(self.data.list) do--默认选中可扫荡的
        local passId = v.id
        local confData = conf.FubenConf:getFubenSweepCost(passId)
        local cost = confData and confData.cost
        if cost then
            mId = cost[1][1]
        end
        if v.red == 1 then
            self.selectlist[passId] = 1
            table.insert(self.ids, passId)
        end
    end
    self.listView.numItems = #self.data.list
    if #self.data.list > 0 then
        self.listView:ScrollToView(0)
    end
    self.costIcon.url = mgr.ItemMgr:getItemIconUrlByMid(mId)
    local packData = cache.PackCache:getPackDataById(mId)
    self.haveCostNum = packData.amount
    self:setCostItemCount()
end
--设置消耗数量
function FubenSweepView:setCostItemCount()
    local color = 7
    local count = 0
    for k,v in pairs(self.ids) do
        local confData = conf.FubenConf:getFubenSweepCost(v)
        local cost = confData and confData.cost
        if cost then
            count = count + cost[1][2]
        end
    end
    self.costNum = count
    if self.haveCostNum == 0 or self.haveCostNum < self.costNum then
        color = 14
    end
    self.costCount.text = mgr.TextMgr:getTextColorStr(self.haveCostNum, color).."/"..self.costNum
end

function FubenSweepView:cellSweepData(index,obj)
    local key = index + 1
    local data = self.data.list[key]
    local fubenId = data.id
    local confData = conf.FubenConf:getPassDatabyId(fubenId)
    obj:GetChild("n1").text = confData and confData.name or ""

    local radioBtn = obj:GetChild("n0")
    radioBtn.data = data
    radioBtn.onClick:Clear()
    if self.selectlist[data.id] then
        radioBtn.selected = true
    else
        radioBtn.selected = false
    end
    radioBtn.onClick:Add(self.onChooseSelect,self)
end
--选择
function FubenSweepView:onChooseSelect(context)
    local radioBtn = context.sender
    local data = radioBtn.data
    if data.red == 0 then
        radioBtn.selected = false
        GComAlter(language.fuben188)
        return
    end
    if radioBtn.selected then
        table.insert(self.ids, data.id)
        self.selectlist[data.id] = 1
    else
        local k = table.keyof(self.ids, data.id)
        if k then
            table.remove(self.ids,k)
        end
        self.selectlist[data.id] = nil
    end
    self:setCostItemCount()
end

--扫荡
function FubenSweepView:onClickSweep()
    if self.data and self.data.func then
        if #self.ids <= 0 then
            GComAlter(language.fuben186)
            return
        elseif self.haveCostNum < self.costNum then
            GComAlter(language.fuben185)
            return
        else
            self.data.func(self.ids)
        end
    end
    self:closeView()
end

function FubenSweepView:closeView()
    self.ids = {}--要扫荡的id数组
    self.selectlist = {}--选择的id字典
    self.haveCostNum, self.costNum = 0,0--拥有的扫荡卷数量，消耗的数量
    self.data = nil
    self.super.closeView(self)
end

return FubenSweepView