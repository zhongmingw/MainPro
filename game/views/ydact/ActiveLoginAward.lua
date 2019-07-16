--
-- Author: 
-- Date: 2017-12-26 11:10:04
--
--登录豪礼
local ActiveLoginAward = class("ActiveLoginAward",import("game.base.Ref"))

function ActiveLoginAward:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId or 1164
    self:initPanel()
end

function ActiveLoginAward:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(self.moduleId)

    self.listView = panelObj:GetChild("n1")

    local timeTitle = panelObj:GetChild("n2")
    timeTitle.text = language.ydact01
    local decTitle = panelObj:GetChild("n3")
    decTitle.text = language.ydact02
    self.timeTxt = panelObj:GetChild("n4")
    local decTxt = panelObj:GetChild("n5")
    decTxt.text = language.activeLogin01
    self:initListView()

end

function ActiveLoginAward:initListView()
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0

end

function ActiveLoginAward:isTyLoginAct()
    local t = {1170,1208}
    for k,v in pairs(t) do
        if self.moduleId == v then
            return true
        end
    end
    return false
end

function ActiveLoginAward:cellData(index,obj)
    local data = self.confData[index+1]
    if data then 
        local itemList = obj:GetChild("n7")
        GSetAwards(itemList,data.awards)
        local c1 = obj:GetController("c1")
        local getBtn = obj:GetChild("n3")
        getBtn.data = data
        getBtn.touchable = true
        getBtn:GetChild("red").visible = false
        getBtn.onClick:Add(self.onClickGet,self)
        local isDay = false
        local dateTime = 0
        if self:isTyLoginAct() then--周末的登录豪礼
            local itemGotData = self:getItemGotData(data.id)
            if itemGotData then
                dateTime = itemGotData.time
                if itemGotData.gotStatus == 0 then
                    c1.selectedIndex = 0 --不可领取
                elseif itemGotData.gotStatus == 1 then
                    c1.selectedIndex = 2 --已领取
                elseif itemGotData.gotStatus == 2 then 
                    c1.selectedIndex = 3 --已错过
                elseif itemGotData.gotStatus == 3 then
                    c1.selectedIndex = 1 --可领取
                end
            else
                c1.selectedIndex = 0 --不可领取
            end
        elseif self.moduleId == 1164 then--元旦的登录豪礼
            if self.data.gots[data.id] then 
                dateTime = data.date
                if self.data.gots[data.id] == 1 then
                    c1.selectedIndex = 2 --已领取
                elseif self.data.gots[data.id] == 2 then 
                    c1.selectedIndex = 3 --已错过
                end
            else
                local day = self.startDay + index
                if day > 31 then --这个月有31号
                    day = day - 31 
                end
                if day == self.currentDay then
                    getBtn:GetChild("red").visible = true
                    c1.selectedIndex = 1 --可领取
                else
                    getBtn.touchable = false
                    c1.selectedIndex = 0 --未达成
                end
            end
        end

        local dateTxt = obj:GetChild("n4")
        local dateTab = os.date("*t",dateTime)
        dateTxt.text = (dateTab.month) .. language.gonggong79 .. (dateTab.day) .. language.gonggong80
    end
end

function ActiveLoginAward:getItemGotData(cid)
    for k,v in pairs(self.data.itemGotDatas) do
        if v.cid == cid then
            return v
        end
    end
end

function ActiveLoginAward:onClickGet(context)
    local data = context.sender.data
    if self.moduleId == 1170 then--周末的登录豪礼
        local itemGotData = self:getItemGotData(data.id)
        if itemGotData and itemGotData.gotStatus == 3 then--可领取
            proxy.ActivityProxy:sendMsg(1030166, {reqType = 2,cid = data.id})
        end
    elseif self.moduleId == 1164 then--元旦的登录豪礼
        if not self.data.gots[data.id] then
            proxy.ActivityProxy:sendMsg(1030302, {reqType = 2,cid = data.id})
        end
    else
        local itemGotData = self:getItemGotData(data.id)
        if itemGotData and itemGotData.gotStatus == 3 then--可领取
            proxy.ActivityProxy:sendMsg(1030175, {actId = self.data.actId,reqType = 2,cid = data.id})
        end
    end
end

function ActiveLoginAward:setData(data)
    self.data = data
    --真实时间
    local temp1 = os.date("*t",mgr.NetMgr:getServerTime())
    self.currentDay = temp1.day
    -- print("今天",self.currentDay)
    if self.moduleId == 1164 then
        self.confData = conf.ActivityConf:getNewyearSignedAward()
    elseif self.moduleId == 1170 then
        self.confData = conf.ActivityConf:getWeekLoginAward()
    else
        self.confData = conf.ActivityConf:getLoginAwardPublic(self.data.actId)
    end

    local startTab = os.date("*t",data.actStartTime)
    local endTab = os.date("*t",data.actEndTime)
    local startTxt = self:getTime(startTab)
    local endTxt = self:getTime(endTab)
    self.startDay = startTab.day
    self.timeTxt.text = startTxt .. "—" .. endTxt
    
    self.listView.numItems = #self.confData
end

function ActiveLoginAward:getTime(timeTab)
    if not timeTab then return end
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

return ActiveLoginAward