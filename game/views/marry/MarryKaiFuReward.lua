--
-- Author: 
-- Date: 2017-07-25 11:32:30
--

local MarryKaiFuReward = class("MarryKaiFuReward", base.BaseView)

function MarryKaiFuReward:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function MarryKaiFuReward:initData()
    -- body
    if self.listView.numItems ~= 0 then
        return
    end

    self.confData = conf.MarryConf:getRankReward()
    self:setData()
end

function MarryKaiFuReward:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.listView = self.view:GetChild("n4")
    self.listView.numItems = 0
end

function MarryKaiFuReward:setData(data_)
    for k ,v in pairs(self.confData) do
        local list 
        if v.id == 1 then
            local var = UIPackage.GetItemURL("marry" , "Component4")
            local _compent1 = self.listView:AddItemFromPool(var)

            local icon1 = _compent1:GetChild("n0"):GetChild("n2")
            local icon2 = _compent1:GetChild("n2"):GetChild("n2")

            icon2.url = ResPath.iconRes(tostring(1)..string.format("%02d",1))
            icon1.url = ResPath.iconRes(tostring(2)..string.format("%02d",1))

            local lab = _compent1:GetChild("n5")
            lab.text = v.title

            list = _compent1:GetChild("n4")

        else
            local var = UIPackage.GetItemURL("marry" , "Component5")
            local _compent1 = self.listView:AddItemFromPool(var)

            local lab = _compent1:GetChild("n1")
            lab.text = v.title

            list = _compent1:GetChild("n0")
        end

        list.itemRenderer = function(index,obj)
            local data = v.awards[index+1]
            local t = {mid = data[1],amount = data[2],bind = data[3]}
            GSetItemData(obj,t,true)
        end
        list.numItems = #v.awards
    end
end

function MarryKaiFuReward:onBtnClose()
    -- body
    self:closeView()
end

return MarryKaiFuReward