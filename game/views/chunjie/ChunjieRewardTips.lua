--
-- Author: 
-- Date: 2018-01-29 16:49:30
--

local ChunjieRewardTips = class("ChunjieRewardTips", base.BaseView)

function ChunjieRewardTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end


function ChunjieRewardTips:initData(data)
    -- body
    self.data = data
    self:setData()
end

function ChunjieRewardTips:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    self.listView = self.view:GetChild("n1")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
end


function ChunjieRewardTips:celldata( index, obj )
    -- body
    local data = self.data.awards[index+1]
    local t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj,t,true)
end

function ChunjieRewardTips:setData(data_)
    self.listView.numItems = #self.data.awards
end

return ChunjieRewardTips