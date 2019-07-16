--
-- Author: 
-- Date: 2018-10-23 14:12:07
-- 已投列表

local BetedPanel = class("BetedPanel", base.BaseView)

function BetedPanel:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function BetedPanel:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.bettedList = self.view:GetChild("n4")
    self.bettedList.itemRenderer = function (index,obj)
        self:setListData(index,obj)
    end
    self.bettedList.numItems = 0
    self.bettedList:SetVirtual()
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    self.btnList = {}
    for i=6,10 do
        local btn = self.view:GetChild("n"..i)
        table.insert(self.btnList,btn)
    end
end

function BetedPanel:initData(data)
    self.data = data
    -- printt(self.myBallInfo)
    local actDay = conf.ActivityConf:getActiveById(1175) -- 活动天数
    local day = actDay.endDay
    for k,v in pairs(self.btnList) do
        if k <= day then
            self.btnList[k].visible = true
        else
            self.btnList[k].visible = false
        end
    end

    self.c1.selectedIndex = data.stage - 1 
    self:onController()
    -- self.data = self.myBallInfo[1]
    -- if self.data then
    --     self.bettedList.numItems = #self.data
    -- end
end

function BetedPanel:onController()
    --
    --获取轮数据
    --print(self.data.stage,"stage")
    self.balldata = self.data.myBallInfo[self.c1.selectedIndex+1]
    --print(self.balldata,#self.balldata.ballInfos)
    self.bettedList.numItems = self.balldata and #self.balldata.ballInfos or 0

    -- local btn = self.btnList[self.c1.selectedIndex+1]
    -- if btn.visible and self.myBallInfo[self.c1.selectedIndex+1] then
    --     self.data = self.myBallInfo[self.c1.selectedIndex+1]
    -- end
    -- -- printt(self.data)
    -- if self.data then
    --     self.bettedList.numItems = #self.data
    -- end
end

function BetedPanel:setListData(index,obj)
    if not self.data then return end
    local data = self.balldata.ballInfos[index + 1]

    local ballList = obj:GetChild("n1")
    ballList.itemRenderer = function (_index,_obj) 
        _obj:GetChild("title").text = data.redBall[_index+1]
    end
    ballList.numItems = #data.redBall

    obj:GetChild("n3").title = data.buleBall

    local zhuText = obj:GetChild("n2")
    zhuText.text = data.num .. "注"
end

return BetedPanel