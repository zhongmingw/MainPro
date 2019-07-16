--
-- Author: 
-- Date: 2018-08-17 10:32:28
--

local XianLvPKRewardView = class("XianLvPKRewardView", base.BaseView)

function XianLvPKRewardView:ctor()
    XianLvPKRewardView.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianLvPKRewardView:initView()
    local btnClose = self.view:GetChild("n1")
    self:setCloseBtn(btnClose)

    self.listView = self.view:GetChild("n5")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function XianLvPKRewardView:initData(data)
    self.data = data 

    self.listView.numItems = #self.data 
end

function XianLvPKRewardView:celldata(index, obj)
    -- body
    local data = self.data[index + 1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3]
    -- t.isquan = true

    GSetItemData(obj, t, true)
end


return XianLvPKRewardView