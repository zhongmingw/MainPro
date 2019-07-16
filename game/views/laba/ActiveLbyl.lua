--
-- Author: 
-- Date: 2018-01-10 21:10:42
-- 腊八有礼

local ActiveLbyl = class("ActiveLbyl" ,import("game.base.Ref"))

function ActiveLbyl:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end
function ActiveLbyl:initPanel()
    local panelObj = self.mParent:getPanelObj(1183)
    self.timeText = panelObj:GetChild("n3")
    
    local decTxt = panelObj:GetChild("n4")
    decTxt.text = language.labaYl01

    self.listView = panelObj:GetChild("n6")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
    
end
function ActiveLbyl:cellData(index,obj)
    local data = self.confData[index +1]
    if data then 
        local awardList = obj:GetChild("n7")
        GSetAwards(awardList, data.awards)

        local getBtn = obj:GetChild("n3")
        getBtn.data = data
        getBtn:GetChild("red").visible = false
        getBtn.touchable = true
        getBtn.onClick:Add(self.getAwards,self)
        local setColor = 7
        local c1 = obj:GetController("c1")
        if self.gots[data.id] and self.gots[data.id] == 1 then 
            c1.selectedIndex = 2
        elseif self.data.count < data.cond then 
            c1.selectedIndex = 0 
            getBtn.touchable = false
            setColor = 14
        else
            c1.selectedIndex = 1
        end
        local condTxt = obj:GetChild("n11")
        local textData = {
        {text = self.data.count.."",color = setColor},
        {text = "/",color = 7},
        {text = data.cond.."",color = 7},
        }
        condTxt.text = mgr.TextMgr:getTextByTable(textData)
    end
end

function ActiveLbyl:getAwards(context)
    local data = context.sender.data
    if not self.gots[data.id] then 
        proxy.ActivityProxy:sendMsg(1030307,{reqType = 1,cid = data.id})
    end
end


function ActiveLbyl:setData(data)
    self.data = data

    self.confData = conf.ActivityConf:getLabaGift()
    
    self.timeText.text = GToTimeString8(data.actStartTime).."—"..GToTimeString8(data.actEndTime)
    
    self.gots = {}
    for k,v in pairs(data.gots) do
        self.gots[v] = 1
    end
    self.listView.numItems = #self.confData

    self.listView:ScrollToView(0,false)

end


return ActiveLbyl