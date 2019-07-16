--
-- Author: 
-- Date: 2017-03-10 14:53:15
--
local ItemBoxList = import(".ItemBoxList")
local ItemHelpList = import(".ItemHelpList")
local ItemRecordList = import(".ItemRecordList")
local PanelBox = class("PanelBox",import("game.base.Ref"))


function PanelBox:ctor(param)
    self.parent = param
    self.view = self.parent.view:GetChild("n29") 
    self:initView()
end

function PanelBox:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onbtnController,self)

    self.listView = self.view:GetChild("n19")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 3
    self.listView.onClickItem:Add(self.onItemCallBack,self)

    local model = self.view:GetChild("n119")
    local effect = self.parent:addEffect(4020110,model)
    --effect.Scale = Vector3.New(50,50,50)
    effect.LocalPosition = Vector3(model.actualWidth/2,-model.actualHeight/2,0)
end

function PanelBox:celldata(index,obj)
    -- body
    local data = language.bangpai84[index+1]
    local labelText = obj:GetChild("title")
    labelText.text = data
    obj.data = index

    if index == 0 then --宝箱
        local param = {}
        param.panel = obj:GetChild("n5")
        param.ids = {10223}
        mgr.GuiMgr:registerRedPonintPanel(param,"bangpai.BangPaiMain.2")
    end
end

function PanelBox:onItemCallBack(context)
    -- body
    local index = context.data.data
    self.c1.selectedIndex = index
end

function PanelBox:setData()
    -- body
    self:onbtnController()
end

function PanelBox:onbtnController()
    if self.c1.selectedIndex == 0 then 
        if not self.ItemBoxList then
            self.ItemBoxList = ItemBoxList.new(self.view:GetChild("n103"))
        end
        self.ItemBoxList:setData()
    elseif self.c1.selectedIndex == 1 then
        if not self.ItemHelpList then
            self.ItemHelpList = ItemHelpList.new(self.view:GetChild("n116"))
        end
        proxy.BangPaiProxy:sendMsg(1250311)
    elseif self.c1.selectedIndex == 2 then
        if not self.ItemRecordList then
            self.ItemRecordList = ItemRecordList.new(self.view:GetChild("n118"))
        end
        proxy.BangPaiProxy:sendMsg(1250314)
    end
    self.listView:AddSelection(self.c1.selectedIndex,false)
end

function PanelBox:onTimer()
    -- body
    if self.c1.selectedIndex == 0 then 
        if self.ItemBoxList then
            self.ItemBoxList:onTimer()
        end
    end
end

function PanelBox:add5250312(data)
    -- body
    if self.c1.selectedIndex == 1 then 
        if self.ItemHelpList then
            self.ItemHelpList:add5250312(data)
        end
    end
end

function PanelBox:add5250311( data )
    -- body
    if self.c1.selectedIndex == 1 then 
        if self.ItemHelpList then
            self.ItemHelpList:setData(data)
        end
    end
end

function PanelBox:add5250314( data)
    -- body
    --plog("add5250314",self.c1.selectedIndex)
     if self.c1.selectedIndex == 2 then 
        if self.ItemRecordList then
            self.ItemRecordList:setData(data)
        end
    end
end


return PanelBox