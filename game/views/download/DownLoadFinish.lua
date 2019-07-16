--
-- Author: 
-- Date: 2017-06-07 17:09:40
--
--下载完成
local DownLoadFinish = class("DownLoadFinish", base.BaseView)

local Time = 10

function DownLoadFinish:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
end

function DownLoadFinish:initData(data)
    self:setData(data)
end

function DownLoadFinish:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self:setCloseBtn(self.view:GetChild("n1"))
    self:setCloseBtn(self.blackView)
    self.view:GetChild("n4").text = language.download02
    self.view:GetChild("n6").text = language.download03
    self.listView = self.view:GetChild("n7")--下载描述列表
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end
    self.timeText = self.view:GetChild("n8")
end

function DownLoadFinish:setData(data)
    self.mData = data
    self.listView.numItems = #data.items
    self.time = Time
    self:onTimer()
    self:addTimer(1, -1, handler(self, self.onTimer))
end

function DownLoadFinish:onTimer()
    self.timeText.text = string.format(language.fuben11, self.time)
    if self.time <= 0 then
        self:closeView()
        return
    end
    self.time = self.time - 1
end

function DownLoadFinish:cellAwardsData(index,cell)
    local data = self.mData.items[index + 1]
    local itemData = {mid = data.mid,amount = data.amount, bind = data.bind, index = data.index}
    GSetItemData(cell, itemData, true)
end

return DownLoadFinish