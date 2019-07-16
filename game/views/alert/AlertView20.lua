--
-- Author: 
-- Date: 2018-01-24 19:51:56
--

local AlertView20 = class("AlertView20", base.BaseView)

function AlertView20:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function AlertView20:initView()
    local btnClose = self.view:GetChild("n6")
    self:setCloseBtn(btnClose)

    self.richtext = self.view:GetChild("n5")
    self.richtext.text = ""

    self.btncancel = self.view:GetChild("n2")
    self.btncancel.onClick:Add(self.onCancel,self)

    self.btnsure = self.view:GetChild("n3")
    self.btnsure.onClick:Add(self.onSure,self)

    self.listView = self.view:GetChild("n4")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function( index,obj )
        -- body
        self:celldata(index,obj)
    end
    self.listView.numItems = 0

end

function AlertView20:initData(data)
    -- body
    self.data = data

    self:setData()
end

function AlertView20:celldata( index,obj )
    -- body
    local t = self.data.items[index+1]
    GSetItemData(obj,t,true)
end

function AlertView20:setData(data_)
    self.richtext.text = self.data.richtext or ""

    if self.data.items then
        self.listView.numItems = #self.data.items 
    else
        self.listView.numItems = 0 
    end
end

function AlertView20:onCancel()
    -- body
    if self.data.cancel then 
        self.data.cancel()
    end
    self:closeView()
end

function AlertView20:onSure()
    -- body
     if self.data.sure then 
        self.data.sure()
    end
    self:closeView()
end

return AlertView20