--
-- Author: 
-- Date: 2018-01-17 16:34:10
--

local ChatPetPanel = class("ChatPetPanel",import("game.base.Ref"))

function ChatPetPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ChatPetPanel:initPanel()
    -- body
    self.listView = self.mParent.view:GetChild("n1000")--宠物列表
    self.listView.itemRenderer = function(index,obj)
        self:cellPhizData(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onProClickCall,self)
end

function ChatPetPanel:setData()
    -- bod
    self.data = cache.PetCache:getData()
    self.listView.numItems = #self.data
end

function ChatPetPanel:cellPhizData(index,cell)
    local data = self.data[index+1]
    local condata = conf.PetConf:getPetItem(data.petId)
    cell.data = data
    local itemObj = cell:GetChild("n2")
    local t = {isCase = true,color = condata.color,url =ResPath.iconRes( condata.src)}
    GSetItemData(itemObj,t)
end

function ChatPetPanel:onProClickCall( context)
    -- body
    local cell = context.data
    local data = cell.data
    self.mParent:setInputPet(data)
end

function ChatPetPanel:sendData()
    -- body
    self.listView.numItems = 0
    proxy.PetProxy:sendMsg(1490101)
end




return ChatPetPanel