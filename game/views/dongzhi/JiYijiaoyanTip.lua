--
-- Author: 
-- Date: 2018-12-13 15:52:06
--

local JiYijiaoyanTip = class("JiYijiaoyanTip", base.BaseView)

function JiYijiaoyanTip:ctor()
    self.super.ctor(self)
    self.isBlack = true 
    self.uiLevel = UILevel.level3 
end

function JiYijiaoyanTip:initView()
     self.view:GetChild("n1").text = language.dz11
        self.blackView.onClick:Add(self.onCloseView,self)
end

function JiYijiaoyanTip:setData(data_)

end


function JiYijiaoyanTip:onCloseView()
    self:closeView()
end

return JiYijiaoyanTip