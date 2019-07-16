--
-- Author: Your Name
-- Date: 2017-11-01 11:31:41
--

local XianYuJinDiTips = class("XianYuJinDiTips", base.BaseView)

function XianYuJinDiTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
end

function XianYuJinDiTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onClickClose,self)

    local btnLeft = self.view:GetChild("n6")
    btnLeft.onClick:Add(self.onBtnLeftCallBack,self)

    local btnRight = self.view:GetChild("n7")
    btnRight.onClick:Add(self.onBtnRightCallBack,self)

    self.item = self.view:GetChild("n2")
    self.dec1 = self.view:GetChild("n3")
    self.dec2 = self.view:GetChild("n4")
    self.dec3 = self.view:GetChild("n5")
end

function XianYuJinDiTips:setData(data)
    self.data = data
    self.dec1.text = data.text1
    self.dec2.text = data.text2
    self.dec3.text = data.text3
    GSetItemData(self.item,data.itemInfo,true)
end

function XianYuJinDiTips:onBtnLeftCallBack()
    if self.data.cancel then 
        self.data.cancel()
    end
    self:closeView()
end

function XianYuJinDiTips:onBtnRightCallBack()
    if self.data.sure then 
        self.data.sure()
    end
    self:closeView()
end

function XianYuJinDiTips:onClickClose()
    self:closeView()
end

return XianYuJinDiTips