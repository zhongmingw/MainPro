--
-- Author: 
-- Date: 2018-12-10 20:00:32
--

local ShengDanChargeView = class("ShengDanChargeView", base.BaseView)

function ShengDanChargeView:ctor()
    ShengDanChargeView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ShengDanChargeView:initView()

end

function ShengDanChargeView:setData(data_)

end

return ShengDanChargeView