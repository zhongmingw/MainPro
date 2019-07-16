--
-- Author: ohf
-- Date: 2017-01-13 14:45:48
--表情区域

local ChatPhizPanel = class("ChatPhizPanel",import("game.base.Ref"))

function ChatPhizPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ChatPhizPanel:initPanel()
    self.listView = self.mParent.view:GetChild("n40")--表情列表
    self.listView.itemRenderer = function(index,obj)
        self:cellPhizData(index, obj)
    end
end

function ChatPhizPanel:setData()
    --数据列表
    self.listView.numItems = ChatType.phizNum
    self.listView.onClickItem:Add(self.onPhizClickCall,self)
end

function ChatPhizPanel:cellPhizData(index,cell)
    local phizId = index + 1
    if phizId < 10 then
        cell.data = "0"..phizId
    else
        cell.data = phizId
    end
    local imgObj = cell:GetChild("n0")
    imgObj.url = ResPath.phizRes(cell.data)
end

function ChatPhizPanel:onPhizClickCall(context)
    local cell = context.data
    local index = cell.data
    self.mParent:setInputText(mgr.TextMgr:getPhiz(index),index)
end

return ChatPhizPanel