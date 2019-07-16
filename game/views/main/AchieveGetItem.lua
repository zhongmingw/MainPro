--
-- Author: Your Name
-- Date: 2017-06-23 15:49:20
--

local AchieveGetItem = class("AchieveGetItem", base.BaseView)

function AchieveGetItem:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
end

function AchieveGetItem:initView()
    self.t0 = self.view:GetTransition("t2")
    self.saveList = {}
    self.view:GetChild("n12").onClick:Add(self.onCloseView,self)
end

function AchieveGetItem:initData()
    self.timesNum = 5
    self.timer = self:addTimer(1, -1, function()
        self.timesNum = self.timesNum - 1
        if self.timesNum < 0 then
            self:onCloseView()
        end
    end)
end

function AchieveGetItem:setData(data)
    table.insert(self.saveList, data.id)
    -- print("成就id",data.id)
    self:refreshView()
end

function AchieveGetItem:refreshView()
    self.achieveId = self.saveList[1]
    local achieveData = conf.AchieveConf:getAchieveInfoById(self.achieveId)
    self.achieveType = achieveData.big_type
    local name = self.view:GetChild("n4")
    local dec = self.view:GetChild("n5")
    local point = self.view:GetChild("n2")
    local awardsItem = self.view:GetChild("n8")
    if achieveData then
        name.text = achieveData.name
        dec.text = achieveData.desc
        point.text = "+"..achieveData.point
        local info = {mid=achieveData.awards[1][1],amount = achieveData.awards[1][2]}
        GSetItemData(awardsItem,info,true)
    end
    self.t0:Play()
end

function AchieveGetItem:refreshIdList()
    self.saveList = {}
end

function AchieveGetItem:onCloseView()
    -- body
    local param = {achieveId = self.achieveId,achieveType = self.achieveType}
    proxy.PlayerProxy:send(1270202,param)
    table.remove(self.saveList,1)
    if #self.saveList > 0 then
        self.timesNum = 10
        self:refreshView()
    else
        mgr.TimerMgr:removeTimer(self.timer)
        self.saveList = {}
        self:closeView()
    end
end

return AchieveGetItem