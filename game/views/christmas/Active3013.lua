--
--圣诞活动登陆好礼
local Active3013 = class("Active3013",import("game.base.Ref"))

function Active3013:ctor(param)
    self.view = param
    self:initView()
end

function Active3013:initView()
    -- body
    self.listView = self.view:GetChild("n1")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.timeTxt = self.view:GetChild("n4")
    self.decTxt = self.view:GetChild("n5")
end

function Active3013:celldata( index,obj )
    local data = self.confData[index+1]
    if data then
        local list = obj:GetChild("n7")
        list.numItems = 0
        for k,v in pairs(data.awards) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local item = list:AddItemFromPool(url)
            local itemInfo = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(item, itemInfo, true)
        end
        local c1 = obj:GetController("c1")
        local getBtn = obj:GetChild("n3")
        getBtn.data = data
        getBtn.touchable = true
        getBtn:GetChild("red").visible = false
        getBtn.onClick:Add(self.onClickGet,self)
        if self.data.itemGotDatas[data.id] then
            if self.data.itemGotDatas[data.id] == 1 then
                c1.selectedIndex = 2
            elseif self.data.itemGotDatas[data.id] == 2 then
                c1.selectedIndex = 3
            end
        else
            if (self.startDay + index) == self.currentDay then
                getBtn:GetChild("red").visible = true
                c1.selectedIndex = 1
            else
                getBtn.touchable = false
                c1.selectedIndex = 0
            end
        end
        local dateTxt = obj:GetChild("n4")
        local dateTab = os.date("*t",data.date)
        dateTxt.text = (dateTab.month) .. "月" .. (dateTab.day) .. "号"
    end
end

function Active3013:onClickGet(context)
    local data = context.sender.data
    if not self.data.itemGotDatas[data.id] then
        proxy.ActivityProxy:sendMsg(1030162, {reqType = 2,cid = data.id})
    end
end

function Active3013:onTimer()
    -- body
end

function Active3013:setCurId(id)
    -- body
    
end

function Active3013:add5030162(data)
    -- body
    -- printt("登陆好礼",data)
    self.data = data
    self.currentDay = os.date("*t",mgr.NetMgr:getServerTime()).day
    local startTab = os.date("*t",data.actStartTime)
    local endTab = os.date("*t",data.actEndTime)
    self.startDay = startTab.day
    local startTxt = startTab.month .. language.gonggong79 .. startTab.day .. language.gonggong80 .. string.format("%02d",startTab.hour) .. ":" .. string.format("%02d",startTab.min)
    local endTxt = endTab.month .. language.gonggong79 .. endTab.day .. language.gonggong80 .. string.format("%02d",endTab.hour) .. ":" .. string.format("%02d",endTab.min)
    self.timeTxt.text = startTxt .. "-" .. endTxt
    -- print("当前日期",self.currentDay,self.startDay,startTab.month)
    self.decTxt.text = language.active41
    self.confData = conf.ActivityConf:getChristmasAwards(data.actStartTime)
    self.listView.numItems = #self.confData
end

return Active3013