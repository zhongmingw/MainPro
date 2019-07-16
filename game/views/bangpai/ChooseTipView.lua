--
-- Author: 
-- Date: 2017-11-28 19:48:23
--
--选择仙盟成员分配
local ChooseTipView = class("ChooseTipView", base.BaseView)

function ChooseTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function ChooseTipView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
end

function ChooseTipView:initData(data)
    self.mData = data
    proxy.XmhdProxy:send(1250103)
end

function ChooseTipView:setData(data)
    self.members = data.members
    self.listView.numItems = #self.members
end

function ChooseTipView:cellData(index, obj)
    local data = self.members[index + 1]
    obj:GetChild("n1").text = data.roleName
    obj.data = data
end

function ChooseTipView:onClickItem(context)
    local func = self.mData and self.mData.func
    if func then
        local data = context.data.data
        local roleId = data.roleId
        func(roleId)
    end
    self:closeView()
end

return ChooseTipView