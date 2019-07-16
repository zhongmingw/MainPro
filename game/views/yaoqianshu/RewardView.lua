--
-- Author: 
-- Date: 2018-08-03 16:51:01
--

local RewardView = class("RewardView", base.BaseView)

function RewardView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function RewardView:initView()
    self.c1 = self.view:GetController("c1")

    local btnClose = self.view:GetChild("n1")
    self:setCloseBtn(btnClose)

    self.listView = self.view:GetChild("n5")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function RewardView:celldata(index, obj)
    -- body
    local data = self.data[index + 1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3]
    t.isquan = true

    GSetItemData(obj, t, true)
end

function RewardView:initData(data)
    if data.c1 then
        self.c1.selectedIndex = data.c1
        self.data = data.item
    else
        self.c1.selectedIndex = 0
        self.data = data 
    end

    self.listView.numItems = #self.data 
end

return RewardView