--
-- Author: 
-- Date: 2018-01-11 16:07:33
--

local ActiveFbsb = class("ActiveFbsb",import("game.base.Ref"))

function ActiveFbsb:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end
function ActiveFbsb:initPanel()
    local panelObj = self.mParent:getPanelObj(1185)

    self.timeText = panelObj:GetChild("n4")
    
    local decTxt = panelObj:GetChild("n5")
    decTxt.text = language.labaFbsb01

    self.listView = panelObj:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function ActiveFbsb:cellData(index,obj)
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
function ActiveFbsb:onClickGoto(context)
    local btn = context.sender
    local moduleData = btn.data
    local moduleId = moduleData.id
    GOpenView({id = moduleId})
end
function ActiveFbsb:setData(data)
    self.data = data

    self.timeText.text = GToTimeString8(data.actStartTime).."—"..GToTimeString8(data.actEndTime)
    
    self.confData = {}

    for k,v in pairs(data.doubleModuleList) do
        local confData = conf.ActivityConf:getLabaFbsbBymoduleId(v)
        table.insert(self.confData, confData)
    end
    -- printt("后端返回双倍列表",data.doubleModuleList)
    -- printt("副本双倍",self.confData)
    self.listView.numItems = #self.confData
end


return ActiveFbsb