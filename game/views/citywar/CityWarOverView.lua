--
-- Author: Your Name
-- Date: 2018-05-03 11:30:08
--

local CityWarOverView = class("CityWarOverView", base.BaseView)

function CityWarOverView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function CityWarOverView:initView()
    local closeBtn = self.view:GetChild("n7")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.timeTxt = self.view:GetChild("n12")
    self.listView = self.view:GetChild("n8")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.winTxt = self.view:GetChild("n10")
end

function CityWarOverView:onTimer()
    if self.count > 0 then
        self.count = self.count - 1
        self.timeTxt.text = string.format(language.fuben11,self.count)
    else
        self:onClickClose()
    end
end

function CityWarOverView:celldata(index,obj)
    local data = self.failData[index+1]
    if data then
        local nameTxt = obj:GetChild("n0")
        local imgIcon = obj:GetChild("n1")
        nameTxt.text = data.gangName
        imgIcon.url = UIPackage.GetItemURL("citywar" , "chengzhan_013")
    end
end

function CityWarOverView:initData(data)
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil 
    end
    self.count = 9
    self.timeTxt.text = string.format(language.fuben11,self.count)
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
    local winData = {}
    self.failData = {}
    for k,v in pairs(data) do
        if v.result == 1 then 
            winData = v
        else
            table.insert(self.failData,v)
        end
    end
    self.winTxt.text = winData.gangName
    self.listView.numItems = #self.failData
end

function CityWarOverView:onClickClose()
    mgr.FubenMgr:quitFuben()
    self:closeView()
end

return CityWarOverView