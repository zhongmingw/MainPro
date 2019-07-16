--
-- Author: 
-- Date: 2018-01-09 11:21:36
--
--副本双倍
local FubenDouble = class("FubenDouble")

function FubenDouble:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function FubenDouble:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1171)

    self.listView = panelObj:GetChild("n1")

    panelObj:GetChild("n2").text = language.weekend01
    panelObj:GetChild("n3").text = language.weekend02
    self.timeTxt = panelObj:GetChild("n4")
    panelObj:GetChild("n5").text = language.weekend03
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function FubenDouble:cellData(index,obj)
    local data = self.confData[index + 1]
    obj:GetChild("n4").icon = ResPath.iconRes(data.icon)
    obj:GetChild("n7").text = data.name
    local moduleId = data.module_id
    local moduleData = conf.SysConf:getModuleById(moduleId)
    local lvl = moduleData and moduleData.open_lev or 1
    obj:GetChild("n9").text = string.format(language.weekend04, lvl)
    local btn = obj:GetChild("n3")
    btn.data = moduleData
    btn.onClick:Add(self.onClickGoto,self)
end

function FubenDouble:setData(data)
    self.data = data
    --真实时间
    local temp1 = os.date("*t",mgr.NetMgr:getServerTime())
    self.currentDay = temp1.day
    -- print("今天",self.currentDay)
    local confData = conf.ActivityConf:getweekFubenDouble(3036)
    self.confData = {}
    for k,v in pairs(confData) do
        if cache.ActivityCache:get5030168(v.module_id) then
            table.insert(self.confData, v)
        end
    end
    local startTab = os.date("*t",data.actStartTime)
    local endTab = os.date("*t",data.actEndTime)
    local startTxt = self:getTime(startTab)
    local endTxt = self:getTime(endTab)
    self.startDay = startTab.day
    self.timeTxt.text = startTxt .. "-" .. endTxt
    
    self.listView.numItems = #self.confData
end

function FubenDouble:getTime(timeTab)
    if not timeTab then return end
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

function FubenDouble:onClickGoto(context)
    local btn = context.sender
    local moduleData = btn.data
    local moduleId = moduleData.id
    GOpenView({id = moduleId})
end

return FubenDouble