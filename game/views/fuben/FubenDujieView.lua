--
-- Author: Your Name
-- Date: 2017-07-25 19:31:17
--

local FubenDujieView = class("FubenDujieView", base.BaseView)

function FubenDujieView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function FubenDujieView:initView()
    local quitBtn1 = self.view:GetChild("n14")
    quitBtn1.onClick:Add(self.onClickQuit,self)
    self.c1 = self.view:GetController("c1")
    self.titleIcon = self.view:GetChild("n3")
    self.listView = self.view:GetChild("n9")
    self.timeTxt = self.view:GetChild("n16")
    self.goToBtn = self.view:GetChild("n18")
    self.goToBtn.onClick:Add(self.onClickGoto,self)
    self:initListView()
end

function FubenDujieView:onClickGoto()
    cache.FubenCache:setFubenModular(1077)
    self:onClickQuit()
end

function FubenDujieView:initData()
    self.time = 9
    self:onTimer()
    self.listView.numItems = 0
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
end

function FubenDujieView:onTimer()
    local str = string.format(language.fuben11, self.time)
    self.timeTxt.text = str
    if self.time <= 0 then
        self:removeTimer(self.timer)
        self.timer = nil
        self:onClickQuit()
    end
    self.time = self.time - 1
end

function FubenDujieView:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function FubenDujieView:celldata( index,obj )
    local itemData = self.data.items[index+1]
    local mId = itemData.mid
    local amount = itemData.amount
    local bind = itemData.bind
    local info = {mid = mId, amount = amount, bind = bind}
    GSetItemData(obj,info,true)
end

function FubenDujieView:setData(data)
    if data.state == 1 then
        self.data = data
        if data.items and #data.items > 0 then
            self.listView.numItems = #data.items
            self.view:GetChild("n19").visible = false
        elseif not data.items or #data.items <= 0 then
            self.view:GetChild("n19").visible = true
        end
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
    end
end

--退出副本
function FubenDujieView:onClickQuit()
    mgr.FubenMgr:quitFuben()
    self:closeView()
end

return FubenDujieView