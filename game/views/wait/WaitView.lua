--
-- Author: yr
-- Date: 2017-06-15 15:10:37
--

local WaitView = class("WaitView", base.BaseView)

function WaitView:ctor()
    self.super.ctor(self)
    self.uiClear = UICacheType.cacheTime
end

function WaitView:initView()

end

function WaitView:initData(data)

end

function WaitView:setData(data_)
    
end

return WaitView