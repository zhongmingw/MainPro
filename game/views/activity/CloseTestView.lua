--
-- Author: bxp
-- Date: 2017-11-29 10:06:22
--

local CloseTestView = class("CloseTestView", base.BaseView)

function CloseTestView:ctor()
    CloseTestView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function CloseTestView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n7")
    btnClose.onClick:Add(self.onClickClose,self)
    local chargeBtn = self.view:GetChild("n10")  --充值按钮
    chargeBtn.onClick:Add(self.onClickCharge,self)
    self.chargeText = self.view:GetChild("n4")  --已冲钱数
    self.ybList = self.view:GetChild("n17") --元宝列表
    self:initYbList()

end

function CloseTestView:setData(data_)
    if not data_ then return end
    self.money = 0
    if data_.czMap then 
        for k,v in pairs(data_.czMap) do
            self.money = self.money + k*v
        end
    end
    self.chargeText.text = self.money/10
    self.ybList.numItems = 1
end

function CloseTestView:initData()
    for i=1, 8 do
        local example = self.view:GetChild("n10"..i)
        example.text = language.fengce01[i].text
    end
end

function CloseTestView:initYbList()
    self.ybList.numItems = 0
    self.ybList.itemRenderer = function (index ,obj)
        self:cellYbListData(index, obj)
    end
    self.ybList:SetVirtual()
end

function CloseTestView:cellYbListData(index, obj)
    local award = obj:GetChild("n0")
    local ybNumTxt = obj:GetChild("n1")
    local ybNum = self.money*2
    ybNumTxt.text = string.format(language.fengce02,ybNum)
    local itemData = {mid = PackMid.gold,amount = ybNum ,bind = 0}
    GSetItemData(award, itemData)
end


function CloseTestView:onClickCharge()
    GGoVipTequan(0)  --充值
    self:closeView()
end

function CloseTestView:onClickClose()
    self:closeView()
end

return CloseTestView
