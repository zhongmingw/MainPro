--
-- Author: 
-- Date: 2017-07-21 17:39:06
--

local MarryLihunTips = class("MarryLihunTips", base.BaseView)

function MarryLihunTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function MarryLihunTips:initView()

    local btnClose = self.view:GetChild("n16")--:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.c1 = self.view:GetController("c1")

    local btn1 = self.view:GetChild("n3")
    btn1.onClick:Add(self.onMoney,self)


    local btn2 = self.view:GetChild("n4")
    btn2.onClick:Add(self.onAsk,self)

    local btn3 = self.view:GetChild("n5")
    btn3.onClick:Add(self.onAsk,self)

    local dec1 = self.view:GetChild("n7")
    dec1.text = language.kuafu40

    self.dec1 = self.view:GetChild("n8")
    self.dec2 = self.view:GetChild("n9")

    local cost = self.view:GetChild("n10")
    cost.text = conf.MarryConf:getValue("force_divorce_cost")[1]
end

function MarryLihunTips:setData(data_)

end

function MarryLihunTips:onMoney()
    -- body
    local param = {}
    param.reqType = 2
    proxy.MarryProxy:sendMsg(1390104, param)
end

function MarryLihunTips:onAsk()
    -- body
     local param = {}
    param.reqType = 1
    proxy.MarryProxy:sendMsg(1390104, param)
end

function MarryLihunTips:onBtnClose()
    -- body
    self:closeView()
end

function MarryLihunTips:initData( data )
    -- body
    if data.isOutline == 1 then
        self.c1.selectedIndex = 1
        self.dec1.text = language.kuafu41
        self.dec2.text = language.kuafu42
    else
        self.c1.selectedIndex = 0
        self.dec1.text = language.kuafu43
        self.dec2.text = language.kuafu44
    end
end

return MarryLihunTips