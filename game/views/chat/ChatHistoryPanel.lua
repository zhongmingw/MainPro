--
-- Author: ohf
-- Date: 2017-01-17 14:20:28
--
--输入历史
local ChatHistoryPanel = class("ChatHistoryPanel",import("game.base.Ref"))

function ChatHistoryPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ChatHistoryPanel:initPanel()
    self.listView = self.mParent.view:GetChild("n42")--表情列表
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellHistoryData(index, obj)
    end
end

function ChatHistoryPanel:setData()
    self.mData = cache.ChatCache:getHistoryData()
    --数据列表
    self.listView.numItems = #self.mData
    self.listView.onClickItem:Add(self.onHistoryClickCall,self)
end

function ChatHistoryPanel:cellHistoryData(index, cell)
    local str = self.mData[index + 1] or ""
    cell.data = str
    local msgText = cell:GetChild("n3")
    msgText.text = mgr.ChatMgr:getSendText(str)
end

function ChatHistoryPanel:onHistoryClickCall(context)
    local cell = context.data
    local str = cell.data
    self.mParent:setHistory(str)
end

return ChatHistoryPanel