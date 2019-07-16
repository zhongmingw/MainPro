--
-- Author: 
-- Date: 2018-10-22 15:02:42
--

local WSJ1004 = class("WSJ1004",import("game.base.Ref"))

function WSJ1004:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function WSJ1004:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)

    self.timeTxt = panelObj:GetChild("n4")
    self.timeTxt.text = ""
    
    local decTxt = panelObj:GetChild("n5")
    decTxt.text = language.wsj04

    self.c1 = panelObj:GetController("c1")

    self.listView = panelObj:GetChild("n19")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

    self.nextOpenTime = panelObj:GetChild("n21")
    self.goBtn = panelObj:GetChild("n22")
    self.goBtn.onClick:Add(self.onGoFuben,self)

    self.leftTimeTxt = panelObj:GetChild("n23")

end


function WSJ1004:setData(data)
    -- printt("降妖除魔",data)
    self.data = data
    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)
    self.nextStartTime = data.nextStartTime
    if data.nextStartTime == 0 then--正在进行
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
        local netTime = mgr.NetMgr:getServerTime()
        self.nextOpenTime.text = GTotimeString(self.nextStartTime-netTime)
    end

    self.confData = conf.WSJConf:getWSJFloorAward()
    self.listView.numItems = #self.confData

    local severTime = mgr.NetMgr:getServerTime()
    self.leftTime = data.actEndTime - severTime
    self.leftTimeTxt.text = language.kaifu15 .. GGetTimeData2(self.leftTime)

end

function WSJ1004:onTimer()
    if not self.data then return end
    local netTime = mgr.NetMgr:getServerTime()
    self.nextOpenTime.text = GTotimeString(self.nextStartTime-netTime)
    if (self.nextStartTime-netTime) <= 0 then
        self.c1.selectedIndex = 1
    end
    if self.leftTime then
        self.leftTime = self.leftTime - 1
        self.leftTimeTxt.text = language.kaifu15 .. GGetTimeData2(self.leftTime)
        if self.leftTime <= 0 then
            self.mParent:closeView()
        end
    end
end

function WSJ1004:cellData(index,obj)
    local data = self.confData[index+1]
    local floor = obj:GetChild("n15")
    local leftList = obj:GetChild("n16")    
    local rightList = obj:GetChild("n17")   
    local c1 = obj:GetController("c1") 
    if data then
        floor.text = string.format(language.wsj08,data.id%100)
        if data.fly_awards then
            c1.selectedIndex = 1
            GSetAwards(leftList,data.fly_awards)
        else
            c1.selectedIndex = 0
        end
        if data.boss_drop then
            GSetAwards(rightList,data.boss_drop)
        end
    end
end

function WSJ1004:onGoFuben()
    mgr.ViewMgr:openView2(ViewName.AlertWSJView)
end


return WSJ1004