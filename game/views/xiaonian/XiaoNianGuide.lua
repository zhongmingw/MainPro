--
-- Author: 
-- Date: 2019-01-08 15:49:16
--

local XiaoNianGuide = class("XiaoNianGuide", base.BaseView)

function XiaoNianGuide:ctor()
    self.super.ctor(self)
    self.isBlack = true 
    self.uiLevel = UILevel.lev
end

function XiaoNianGuide:initView()
    self.blackView.onClick:Add(self.onCloseView,self)
    self.listView = self.view:GetChild("n2")
    self.listView.itemRenderer = function (index, obj)
        self:celldata(index, obj)
    end
    self.confData = conf.XiaoNianConf:getValue("xn_xycc_rank_point")

    self.listView.numItems = #self.confData
end

function XiaoNianGuide:setData(data_)

end

function XiaoNianGuide:onCloseView()
    self:closeView()
end

function XiaoNianGuide:celldata( index,obj )
    local data  = self.confData[index +1]
    local txt1 = obj:GetChild("n61")
    local txt2 = obj:GetChild("n62")
    local name = conf.XiaoNianConf:SceneName(data[1]).value
    txt1.text = name
    txt2.text = "[color=#7df130]"..data[2].."[/color]".."点"

end
return XiaoNianGuide