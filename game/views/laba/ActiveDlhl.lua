--
-- Author: 
-- Date: 2018-01-10 11:35:59
--腊八活动登录豪礼

local ActiveDlhl = class("ActiveDlhl",import("game.base.Ref"))

function ActiveDlhl:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function ActiveDlhl:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)

    self.timeText = panelObj:GetChild("n4")
    
    local decTxt = panelObj:GetChild("n5")
    decTxt.text = language.labaDlhl01

    self.listView = panelObj:GetChild("n1")
    self:initListView()
end

function ActiveDlhl:initListView()
    self.listView.numItems = 0
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
end

function ActiveDlhl:cellData(index,obj)
    local data = self.confData[index+1]
    if data then 
        local dateTxt = obj:GetChild("n4")
        
        local awardList = obj:GetChild("n7")
        GSetAwards(awardList, data.awards)
        local c1 = obj:GetController("c1")
        local getBtn = obj:GetChild("n3")
        data.sort = index+1
        getBtn.data = data
        getBtn.touchable = true
        getBtn:GetChild("red").visible = false
        getBtn.onClick:Add(self.getAwards,self)

        local dateTime = 0
        if self.modelId == 1180 then --腊八登录
            if data.date then 
                dateTime = data.date
            end
            if self.data.gots[data.id] then
                if self.data.gots[data.id] == 1 then
                    c1.selectedIndex = 2 --已领取
                elseif self.data.gots[data.id] == 2 then
                    c1.selectedIndex = 3 --已过期
                end
            else
                if dateTab.day == self.currentDay then
                    getBtn:GetChild("red").visible = true
                    c1.selectedIndex = 1 --可领取
                else
                    getBtn.touchable = false
                    c1.selectedIndex = 0 --未达成
                end
            end
        elseif self.modelId == 1205 then --情人节登录
            local itemGotData = self:getItemGotData(index+1)
            if itemGotData then 
                dateTime = itemGotData.time
                if itemGotData.gotStatus == 0 then
                    c1.selectedIndex = 0 --未达成
                    getBtn.touchable = false
                elseif itemGotData.gotStatus == 1 then
                    c1.selectedIndex = 2 --已领取
                elseif itemGotData.gotStatus == 2 then 
                    c1.selectedIndex = 3 --已过期
                elseif itemGotData.gotStatus == 3 then
                    c1.selectedIndex = 1 --可领取
                    getBtn:GetChild("red").visible = true
                end
            end
        end
        local dateTab = os.date("*t",dateTime)
        dateTxt.text = (dateTab.month) .. language.gonggong79 .. (dateTab.day) .. language.gonggong80
    end
end
--情人节奖励领取状态
function ActiveDlhl:getItemGotData(index)
    self:sort()
    for k,v in pairs(self.data.itemGotDatas) do
        if k == index then
            return v
        end
    end
end
function ActiveDlhl:sort()
    table.sort(self.data.itemGotDatas,function(a,b)
        return a.cid < b.cid
    end) 
end

function ActiveDlhl:getAwards(context)
    local data = context.sender.data
    if self.modelId == 1180 then 
        if not self.data.gots[data.id] then
            proxy.ActivityProxy:sendMsg(1030304, {reqType = 2,cid = data.id})
        end
    elseif self.modelId == 1205 then 
        local itemGotData = self:getItemGotData(data.sort)
        if itemGotData and itemGotData.gotStatus == 3 then--可领取
            proxy.ActivityProxy:sendMsg(1030175, {actId = 3046,reqType = 2,cid = data.id})
        end    
    end
end

function ActiveDlhl:setData(data)
    self.data = data

    self.currentDay = os.date("*t",mgr.NetMgr:getServerTime()).day

    if self.modelId == 1180 then --腊八奖励
        self.confData = conf.ActivityConf:getLabaLoginAward()
    elseif self.modelId == 1205 then --情人节
        self.confData = conf.ActivityConf:getLoginAwardPublic(3046)
    end

    self.timeText.text = GToTimeString8(data.actStartTime).."—"..GToTimeString8(data.actEndTime)

    self.listView.numItems = #self.confData

end
return ActiveDlhl