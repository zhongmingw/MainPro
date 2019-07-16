--
-- Author: 
-- Date: 2017-03-29 16:16:12
--

local AlertView11 = class("AlertView11", base.BaseView)

function AlertView11:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function AlertView11:initView()
    self.blackView.onClick:Add(self.onClickClose,self)
    self.listView = self.view:GetChild("n2")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
end

function AlertView11:setData(data)
    self.mData = data
    self.listView.numItems = #data
end

function AlertView11:cellData(index,obj)
    local awardData = self.mData[index + 1]
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
    GSetItemData(obj, itemData, true)
end

function AlertView11:onClickClose()
    self:closeView()
end

return AlertView11