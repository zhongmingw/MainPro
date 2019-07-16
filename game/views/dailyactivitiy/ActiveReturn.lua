--
-- Author: 
-- Date: 2018-06-25 17:31:28
--
--超值返还
local ActiveReturn = class("ActiveReturn",import("game.base.Ref"))

function ActiveReturn:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId
    self:initPanel()
end

function ActiveReturn:initPanel()
    local panelObj = self.mParent:getPanelObj(self.moduleId)
    local decTxt = panelObj:GetChild("n6")
    decTxt.text = language.dailyactive01
    
    self.lastTime = panelObj:GetChild("n7")
    local consumeBtn = panelObj:GetChild("n5")
    consumeBtn.onClick:Add(self.onConsume,self)

    self.listView = panelObj:GetChild("n2")
    self.listView.numItems = 0
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
   
end

function ActiveReturn:setData(data)
    self.data = data
    printt("返还~~~~",data)
    self.time = data and data.actLeftSec
    if self.moduleId  == 1235 then  
        self.typeData = conf.ActivityConf:getczfhTypeData(data.curId)
        local type = self.typeData.type
        self.confData = conf.ActivityConf:getczfhInfoByType(type)
    elseif self.moduleId == 1243 then 
        self.typeData = conf.ActivityConf:getczfhTypeData2(data.curId)
        local type2 = self.typeData.type
        self.confData = conf.ActivityConf:getczfhInfoByType2(type2)
    end
    for k,v in pairs(self.confData) do
        if self.data.gotSigns[v.id] then 
            if self.data.gotSigns[v.id] == 1 then 
                self.confData[k].sort = 2--已领取
            end
        else
            if self.data.costNum >= tonumber(v.cost_con) then 
                self.confData[k].sort = 0 --可领取
            else
                self.confData[k].sort = 1 --未达成
            end
        end
    end
    table.sort(self.confData,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        elseif a.id ~= b.id then
            return a.id < b.id
        end
    end)
    self.listView.numItems = #self.confData
end

function ActiveReturn:cellData(index,obj)
    local data = self.confData[index+1]
    if data then 
        local awardList = obj:GetChild("n9")
        GSetAwards(awardList, data.item)

        local dec = obj:GetChild("n4")
        local costName = conf.ItemConf:getName(self.typeData.cost_id[1])
        dec.text = string.format(language.dailyactive03,costName)
        local icon = obj:GetChild("n8")
        local iconUrl = UIPackage.GetItemURL("_icons2" , self.typeData.icon)
        if not iconUrl then
            iconUrl = UIPackage.GetItemURL("_icons" , self.typeData.icon)
        end
        icon.url = iconUrl

        local costTxt = obj:GetChild("n6")
        local color = tonumber(self.data.costNum) < tonumber(data.cost_con) and 14 or 7

        local textData = {
                {text = tostring(self.data.costNum),color = color},
                {text = "/",color = 7},
                {text = tostring(data.cost_con),color = 7},
            }

        costTxt.text = mgr.TextMgr:getTextByTable(textData)
      
        local c1 = obj:GetController("c1")
        if self.data.gotSigns[data.id] then 
            if self.data.gotSigns[data.id] == 1 then 
                c1.selectedIndex = 2--已领取
            end
        else
            if self.data.costNum >= tonumber(data.cost_con) then 
                c1.selectedIndex = 1--可领取
            else
                c1.selectedIndex = 0
            end

        end

        local getBtn = obj:GetChild("n3")
        getBtn.data = data
        getBtn.onClick:Add(self.getAwards,self)

    end
end


function ActiveReturn:getAwards(context)
    local data = context.sender.data
    if self.moduleId  == 1235 then  
        proxy.ActivityProxy:sendMsg(1030405,{reqType = 1,cfgId = data.id})
    elseif self.moduleId == 1243 then 
        proxy.ActivityProxy:sendMsg(1030407,{reqType = 1,cfgId = data.id})
    end
end


function ActiveReturn:onTimer()
    if self.time then 
        if tonumber(self.time) > 86400 then 
            self.lastTime.text = GTotimeString7(self.time)
        else
            self.lastTime.text = GTotimeString(self.time)
        end
        if self.time <= 0 then
            if self.moduleId  == 1235 then  
                proxy.ActivityProxy:sendMsg(1030405,{reqType = 0,cfgId = 0})
            elseif self.moduleId == 1243 then 
                proxy.ActivityProxy:sendMsg(1030407,{reqType = 0,cfgId = 0})
            end
            return
        end
        self.time = self.time - 1
    end
end

function ActiveReturn:onConsume()
    local param = {id = self.typeData.turnId}
    GOpenView(param)
end


return ActiveReturn