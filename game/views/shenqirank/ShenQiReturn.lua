--
-- Author: 
-- Date: 2018-07-02 11:42:56
--

local ShenQiReturn = class("ShenQiReturn",import("game.base.Ref"))

function ShenQiReturn:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId
    self:initPanel()
end
function ShenQiReturn:initPanel()
    local panelObj = self.mParent:getPanelObj(self.moduleId)
    local decTxt = panelObj:GetChild("n6")
    decTxt.text = language.shenqirank01
    
    self.lastTime = panelObj:GetChild("n7")

    self.listView = panelObj:GetChild("n2")
    self.listView.numItems = 0
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
   
end

function ShenQiReturn:setData(data)
    self.data = data
    printt("神器返还",data)
    self.time = data and data.actLeftTime
    if data.msgId == 5030413 then
        self.confData = conf. ActivityConf:getSQXBBack()
    elseif  data.msgId == 5030415 then
        self.confData = conf. ActivityConf:getXunBaoAwardbyactID(1187)
    end
    for k,v in pairs(self.confData) do
        if self.data.gotSigns[v.id] then 
            if self.data.gotSigns[v.id] == 1 then 
                self.confData[k].sort = 2--已领取
            end
        else
            if self.data.xbCount >= tonumber(v.con) then 
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


function ShenQiReturn:cellData(index,obj)
    local data = self.confData[index+1]
    if data then 
        local awardList = obj:GetChild("n9")
        if self.data.msgId == 5030413 then
            GSetAwards(awardList, data.item)
        elseif self.data.msgId == 5030415 then
            GSetAwards(awardList, data.awards)
        end
        local dec = obj:GetChild("n4")
        dec.text = language.shenqirank02
        local costTxt = obj:GetChild("n6")
        local color = tonumber(self.data.xbCount) < tonumber(data.con) and 14 or 7
        local textData = {
                {text = tostring(self.data.xbCount),color = color},
                {text = "/",color = 7},
                {text = tostring(data.con),color = 7},
            }
        costTxt.text = mgr.TextMgr:getTextByTable(textData)
      
        local c1 = obj:GetController("c1")
        if self.data.gotSigns[data.id] then 
            if self.data.gotSigns[data.id] == 1 then 
                c1.selectedIndex = 2--已领取
            end
        else
            if self.data.xbCount >= tonumber(data.con) then 
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


function ShenQiReturn:getAwards(context)
    local data = context.sender.data
    local activeData = cache.ActivityCache:get5030111()
    if activeData.acts and activeData.acts[1106] and activeData.acts[1106] == 1 then
        proxy.ActivityProxy:sendMsg(1030413,{reqType = 1,cfgId = data.id})
    elseif activeData.acts and activeData.acts[1187] and activeData.acts[1187] == 1 then
        proxy.ActivityProxy:sendMsg(1030415,{reqType = 1,cfgId = data.id})
    end
end


function ShenQiReturn:onTimer()
    if self.time then 
        if tonumber(self.time) > 86400 then 
            self.lastTime.text = GTotimeString7(self.time)
        else
            self.lastTime.text = GTotimeString(self.time)
        end
        if self.time <= 0 then
                -- proxy.ActivityProxy:sendMsg(1030407,{reqType = 0,cfgId = 0})
                self.mParent:onBtnClose()
            return
        end
        self.time = self.time - 1
    end
end

return ShenQiReturn