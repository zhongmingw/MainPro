--
-- Author: 
-- Date: 2018-08-06 15:35:27
--

local XianTongXTSure = class("XianTongXTSure", base.BaseView)

function XianTongXTSure:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianTongXTSure:initView()
    local btn = self.view:GetChild("n2")
    self:setCloseBtn(btn)

    local btn1 = self.view:GetChild("n3")
    btn1.onClick:Add(self.onBtnBack,self)

    local btn1 = self.view:GetChild("n4")
    btn1.onClick:Add(self.onBtnBack,self)

    local dec1 = self.view:GetChild("n8") 
    dec1.text = language.xiantong09
end

function XianTongXTSure:initData(data)
    -- body
    self.data = data
end

function XianTongXTSure:onBtnBack(context)
    local btn = context.sender
    local name = btn.name
    local param = {}
    param.awardId = cache.MarryCache:getAwardId()
    if name == "n3" then
        --坚持
        param.reqType = self.data[2]
        param.mid = self.data[1]
    else
        --同意
        param.reqType = self.data[2] == 3 and 2 or 0
        if self.otherChoose == PackMid.xiantong_nan then
            param.mid = PackMid.xiantong_nv
        else
            param.mid = PackMid.xiantong_nan
        end
    end
    print("XianTongXTSure param.mid",param.mid)
    proxy.MarryProxy:sendMsg(1390502,param)
    self:closeView()
end

return XianTongXTSure