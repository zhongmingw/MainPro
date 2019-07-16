--
-- Author: 
-- Date: 2018-07-23 16:51:13
--

local XianTongOpenPos = class("XianTongOpenPos", base.BaseView)

function XianTongOpenPos:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianTongOpenPos:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    self.dec1 = self.view:GetChild("n3")
    self.dec1.text = ""

    local dec1 = self.view:GetChild("n4") 
    dec1.text = language.pet52

    local btnplus = self.view:GetChild("n7")
    btnplus.onClick:Add(self.onPlus,self)

    self.icon = self.view:GetChild("n11")
    self.costlab = self.view:GetChild("n10")

    local btnSure = self.view:GetChild("n2")
    btnSure.onClick:Add(self.onSure,self)

    local btnSure = self.view:GetChild("n1")
    btnSure.onClick:Add(self.onCancel,self)

end

function XianTongOpenPos:initData(data)
    self.data = data
    self.confData = conf.MarryConf:getXianTongZhuZhanById(data.id)
    self.dec1.text = language.xiantong36 .. self.confData.zw_name
    local mid = self.confData.cost_item[1][1]
    self.needNum = self.confData.cost_item[1][2]
    self.myNum = cache.PackCache:getPackDataById(mid).amount
    -- print("道具数量>>>>>>>>>>>>mid",mid,self.myNum)
    local src = conf.ItemConf:getSrc(mid)
    local iconUrl = ResPath.iconRes(tostring(src))
    self.icon.url = iconUrl

    local str = ""
    if self.needNum > self.myNum then
        str = str .. mgr.TextMgr:getTextColorStr(self.myNum, 14)
    else
        str = str .. self.myNum
    end
    str = str.."/"..self.needNum
    self.costlab.text = str
end

function XianTongOpenPos:onPlus()
    -- body
    if not self.data then
        return
    end
    local t = {
        mid =  self.confData.cost_item[1][1]
    }
    GSeeLocalItem(t)
end

function XianTongOpenPos:onSure()
    -- body
    if not self.data then
        return
    end
    if self.myNum >= self.needNum then
        proxy.MarryProxy:sendMsg(1390611,{pos = self.data.id})
    else
        GComAlter("道具不足，无法开启")
    end
    self:closeView()
end

function XianTongOpenPos:onCancel()
    -- body
    self:closeView()
end

return XianTongOpenPos