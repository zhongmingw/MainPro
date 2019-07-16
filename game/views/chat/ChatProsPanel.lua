--
-- Author: ohf
-- Date: 2017-01-16 12:03:02
--
--聊天道具区域
local ChatProsPanel = class("ChatProsPanel",import("game.base.Ref"))

function ChatProsPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ChatProsPanel:initPanel()
    self.listView = self.mParent.view:GetChild("n41")--表情列表
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellPhizData(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onProClickCall,self)
end

function ChatProsPanel:setData()
    self.mData = cache.PackCache:getItems()
    --数据列表
    
    self.listView.numItems = #self.mData
end

function ChatProsPanel:cellPhizData(index,cell)
    cell.data = self.mData[index + 1]
    local itemObj = cell:GetChild("n2")
    GSetItemData(itemObj,cell.data,false,true)
end

function ChatProsPanel:onProClickCall(context)
    local cell = context.data
    local data = cell.data
    self.mParent:setInputPros(data)
end

return ChatProsPanel