--
-- Author: 
-- Date: 2018-01-10 14:23:34
-- 活跃腊八

local ActiveHylb = class("ActiveHylb", import("game.base.Ref"))

function ActiveHylb:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end

function ActiveHylb:initPanel()
    local panelObj
    if self.modelId == 1212 then
        panelObj = self.mParent:getChoosePanelObj(self.modelId)
    else
        panelObj = self.mParent:getPanelObj(self.modelId)
    end
    self.timeText = panelObj:GetChild("n4")
    self.actTxt = panelObj:GetChild("n8") --活跃值
    local decTxt = panelObj:GetChild("n5")
    decTxt.text = language.labaHy01

    self.awardList = panelObj:GetChild("n1")
    self.taskList = panelObj:GetChild("n7")

    self:initAwardList()
    self:initTaskList()
end
    
function ActiveHylb:initAwardList()
    self.awardList.numItems = 0
    self.awardList:SetVirtual()
    self.awardList.itemRenderer = function(index,obj)
        self:cellAwardData(index,obj)
    end
end

function ActiveHylb:initTaskList()
    self.taskList.numItems = 0
    self.taskList:SetVirtual()
    self.taskList.itemRenderer = function(index,obj)
        self:cellTaskData(index,obj)
    end
end

function ActiveHylb:cellAwardData(index, obj)
    local data = self.confData[index+1]
    if data then 
        local actVar = obj:GetChild("n1")
        actVar.text = data.active
        local awardList = obj:GetChild("n2")
        GSetAwards(awardList, data.awards)
        local getBtn = obj:GetChild("n3")
        getBtn.data = data
        getBtn:GetChild("red").visible = false
        getBtn.touchable = true
        getBtn.onClick:Add(self.getAwards,self)
        local c1 = obj:GetController("c1")
        if data.sign then 
            if data.sign == 1 then 
                getBtn:GetChild("red").visible = true
                c1.selectedIndex = 0 --可领取
            elseif data.sign == 2 then 
                c1.selectedIndex = 2 --未达成
                getBtn.touchable = false
            elseif data.sign == 3 then 
                c1.selectedIndex = 1 --已领取
            end
        end
    end
end
function ActiveHylb:getAwards(context)
    local data = context.sender.data
    if not self.gots[data.id] then 
        if self.modelId == 1181 then --腊八 
            proxy.ActivityProxy:sendMsg(1030305, {reqType = 1,cid = data.id})
        elseif self.modelId == 1206 then --情人节
            proxy.ActivityProxy:sendMsg(1030314, {reqType = 1,cid = data.id})
        elseif self.modelId == 1212 then --活跃元宵
            proxy.ActivityProxy:sendMsg(1030317, {reqType = 1,cid = data.id})
        end
    end
end

function ActiveHylb:cellTaskData(index, obj)
    local data = self.taskData[index+1]
    if data then 
        local title = obj:GetChild("n0")
        local icon = obj:GetChild("n2")
        local times = obj:GetChild("n3")
        local gotoBtn = obj:GetChild("n4")
        gotoBtn.data = data.skipId or 0
        if not data.skipId then 
            print("@策划配skipId")
        end
        gotoBtn.onClick:Add(self.goActive,self)
        local name = data.name or "@策划配名字"
        local max = data.max or 0
        local timesNum = self.data.join[data.id] or 0
        title.text = string.format(language.labaHy02,name,data.active)
        if data.img then
            local iconUrl = UIPackage.GetItemURL("_icons2" , data.img)
            if not iconUrl then
                iconUrl = UIPackage.GetItemURL("_icons" , data.img)
            end
            icon.url = iconUrl
        end
        times.text = timesNum.. "/" .. max

    end

end

function ActiveHylb:goActive(context)
    local skipId = context.sender.data
    -- print("跳转id",skipId)
    if skipId then
        GOpenView({id = skipId})
    end
end


function ActiveHylb:setData(data)
    self.data = data
    -- printt("###",data)
    self.timeText.text = GToTimeString8(data.actStartTime).."—"..GToTimeString8(data.actEndTime)

    self.actTxt.text = string.format(language.labaHy03,data.active)
    local awardData
    if self.modelId == 1181 then --腊八
        awardData = conf.ActivityConf:getLabaActiveAward()
        self.taskData = conf.ActivityConf:getActiveTask()
    elseif self.modelId == 1206 then --情人节
        awardData = conf.ActivityConf:getValentineActiveAward()
        self.taskData = conf.ActivityConf:getValentineActiveTask()
    elseif self.modelId == 1212 then --活跃元宵
        awardData = conf.ActivityConf:getLanternActiveAward()
        self.taskData = conf.ActivityConf:getLanternActiveTask()
    end

    self.confData = clone(awardData)
    self.gots = {}
    for k,v in pairs(data.gots) do
        self.gots[v] = 1
    end
    for k,v in pairs(self.confData) do
        if self.gots[v.id] and self.gots[v.id] == 1 then 
            self.confData[k].sign = 3 --已领取
        elseif data.active >= v.active then 
            self.confData[k].sign = 1 --可领取
        else 
            self.confData[k].sign = 2 --未达成
        end
    end

    table.sort(self.confData,function (a,b)
        if a.sign ~= b.sign then 
            return a.sign < b.sign
        elseif a.active ~= b.active then 
            return a.active < b.active
        end 
    end)

    self.awardList.numItems = #self.confData

    
    for k,v in pairs(self.taskData) do
        if data.join[v.id] == v.max then
            self.taskData[k].sort = 2
        else
            self.taskData[k].sort = 1
        end
    end
    table.sort( self.taskData,function (a,b)
        if a.sort ~= b.sort then 
            return a.sort < b.sort 
        else
            return a.id < b.id 
        end
    end )

    self.taskList.numItems = #self.taskData
    self.awardList:ScrollToView(0,false)
    self.taskList:ScrollToView(0,false)
end

return ActiveHylb