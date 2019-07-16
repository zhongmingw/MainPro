--
-- Author: EVE
-- Date: 2017-08-29 20:54:25
--

local ActiveTreePopupView = class("ActiveTreePopupView", base.BaseView)

function ActiveTreePopupView:ctor()
    self.super.ctor(self)
    self.isBlack = true 
    self.openTween = ViewOpenTween.scale
end

function ActiveTreePopupView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n7")
    btnClose.onClick:Add(self.onCloseView, self)

    -- self.controllerC1 = self.view:GetController("c1")
    -- self.controllerC1.onChanged:Add(self.onControlChange,self)

    self.fruitList = self.view:GetChild("n5") --果子列表
    self:initFruitList()

    self.recordList = self.view:GetChild("n4") --获得记录
end

function ActiveTreePopupView:initFruitList()
    self.fruitList.numItems = 0
    self.fruitList.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.fruitList:SetVirtual()
end

function ActiveTreePopupView:itemData(index, obj)
    local data = self.fruitConfData[index+1]

    local fruitName = obj:GetChild("n1")      --果子名
    fruitName.text = language.tree02[index+1]

    local fruitRewardList = obj:GetChild("n2") --果子对应奖励
    self:setAwards(fruitRewardList,data.awards)
end

--设置奖励物品的公共函数（你真棒）
function ActiveTreePopupView:setAwards(listView,confData)
    listView.numItems = 0
    for k,v in pairs(confData) do
        local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
        local obj = listView:AddItemFromPool(url)
        local mId = v[1]
        local amount = v[2]
        local bind = v[3]
        local info = {mid = mId,amount = amount,bind = bind}
        GSetItemData(obj,info,true)
    end
end

-- function ActiveTreePopupView:onControlChange()
--     if self.controllerC1.selectedIndex == 0 then 
--         --TODO 果实奖励     
--     else
--         --TODO 获得记录
--     end 
-- end
function ActiveTreePopupView:setRecord(listView,confData)
    listView.numItems = 0
    for k,v in pairs(confData) do
        local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
        local obj = listView:AddItemFromPool(url)
        local mId = v.mid
        local amount = v.amount
        local bind = v.bind
        local info = {mid = mId,amount = amount,bind = bind}
        GSetItemData(obj,info,true)
    end
end


function ActiveTreePopupView:initData(data)
    self.data = data
    -- printt(data.itemRecord)
    -- plog("树了个苗~~~~~~~~~~~~~~")

    self.fruitConfData = conf.ActivityConf:getFruitRewardList()
    self.fruitList.numItems = #self.fruitConfData

    self:setRecord(self.recordList,self.data.itemRecord)
end

function ActiveTreePopupView:onCloseView()
    self:closeView()
end

return ActiveTreePopupView