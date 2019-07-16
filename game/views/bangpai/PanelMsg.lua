--
-- Author: 
-- Date: 2017-03-06 20:19:38
--
local ItemMsg = import(".ItemMsg")
local ItemSign = import(".ItemSign") 
local ItemMember = import(".ItemMember")
local ItemShop = import(".ItemShop")
local ItemRecord = import(".ItemRecord")

local PanelMsg = class("PanelMsg",import("game.base.Ref"))

function PanelMsg:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n17")
    self:initView()
end

function PanelMsg:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onbtnController,self)


    self.listView = self.view:GetChild("n19")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end

    
    
    self.listView.onClickItem:Add(self.onItemCallBack,self)
end

function PanelMsg:celldata(index,obj)
    -- body
    if index == 3 then
        obj.visible = false
        obj.height = 0
        return
    end
    obj.visible = true
    obj.height = 65 --编辑器尺寸 
    local data = language.bangpai19[index+1]
    local labelText = obj:GetChild("title")
    labelText.text = data
    obj.data = index

    if index == 1 then --签到
        local param = {}
        param.panel = obj:GetChild("n5")
        param.ids = {10221}
        mgr.GuiMgr:registerRedPonintPanel(param,self.parent:viewName()..".1") 
    elseif index == 0 then --申请
        local param = {}
        param.panel = obj:GetChild("n5")
        param.ids = {10313}
        mgr.GuiMgr:registerRedPonintPanel(param,self.parent:viewName()..".1") 
    end
end

function PanelMsg:onItemCallBack(context)
    -- body
    local index = context.data.data
    self.c1.selectedIndex = index
end

function PanelMsg:setData()
    -- body
    self:onbtnController()
end

function PanelMsg:nextStep(id)
    -- body
    self.listView.numItems = 5
    
    if id == self.c1.selectedIndex then
        self:onbtnController()
    else
        self.c1.selectedIndex = id
    end
    self.listView:AddSelection(id,false)
end

function PanelMsg:onbtnController()
    -- body

    if self.c1.selectedIndex == 0 then --信息
        if not self.ItemMsg then
            self.ItemMsg = ItemMsg.new(self.view:GetChild("n34"))
        end
        self.ItemMsg:setParent(self.parent)
        self.ItemMsg:setData()
    elseif self.c1.selectedIndex == 1 then --签到
        if not self.ItemSign then
            self.ItemSign = ItemSign.new(self.view:GetChild("n53"))
        end
        proxy.BangPaiProxy:sendMsg(1250301, {reqType = 1})
    elseif self.c1.selectedIndex == 2 then --成员
        if not self.ItemMember then
            self.ItemMember = ItemMember.new(self.view:GetChild("n75"))
        end
        proxy.BangPaiProxy:sendMsg(1250103)
    elseif self.c1.selectedIndex == 3 then --商店
        if not self.ItemShop then
            self.ItemShop = ItemShop.new(self.view:GetChild("n66"))
        end
        self.ItemShop:setSelect(0)
    elseif self.c1.selectedIndex == 4 then --记录
        if not self.ItemRecord then
            self.ItemRecord = ItemRecord.new(self.view:GetChild("n74"))
        end
        self.ItemRecord:setSelect(0)
        --proxy.BangPaiProxy:sendMsg(1250103)
    end
end



function PanelMsg:add5250301(data)
    -- body
    if self.ItemSign and self.c1.selectedIndex == 1 then
        self.ItemSign:setData(data)
    end
end
function PanelMsg:add5250103(data)
    -- body
    if self.ItemMember and self.c1.selectedIndex == 2 then
        self.ItemMember:setData()
    end
end
function PanelMsg:add5250302(data)
    -- body
    if self.ItemShop then
        self.ItemShop:setData(data)
    end
end
function PanelMsg:add5250106(data)
    -- body
    if self.ItemRecord then
        self.ItemRecord:add5250106(data)
    end
end
function PanelMsg:add5250108(data)
    -- body
     if self.ItemRecord then
        self.ItemRecord:add5250108(data)
    end
end


return PanelMsg