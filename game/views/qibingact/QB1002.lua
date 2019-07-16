--
-- Author: 
-- Date: 2018-12-27 16:07:47
--

local QB1002 = class("QB1002")

function QB1002:ctor(mParent)
    self.mParent = mParent
    self:initPanel()

end

function QB1002:initPanel()
    self.view = self.mParent.view:GetChild("n8")
    self.leftTime = self.view:GetChild("n4")  --倒计时
    self.leftTime.text = ""

    --奖励列表
    self.listView = self.view:GetChild("n2")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
end

function QB1002:setData(data)
    self.data = data
    printt("奇兵寻宝返还",data)
    self.confData = conf.ActivityConf:getQiBingReturnAward()
    self.isGot = {}
    for k,v in pairs(self.data.gotSigns) do
        self.isGot[v] = 1
    end
    for k,v in pairs(self.confData) do
        if self.isGot[v.id] and self.isGot[v.id] == 1 then 
            self.confData[k].sort = 2--已领取
        else
            if self.data.times >= tonumber(v.times) then 
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

function QB1002:cellData( index, obj )
    local data = self.confData[index+1]
    if data then 
        local awardList = obj:GetChild("n5")
        GSetAwards(awardList, data.awards)
        local dec = obj:GetChild("n3")
        dec.text = string.format(language.qbjl01,data.times)
        local costTxt = obj:GetChild("n4")
        local color = tonumber(self.data.times) < tonumber(data.times) and 14 or 7
        local textData = {
                {text = tostring(self.data.times),color = color},
                {text = "/",color = 7},
                {text = tostring(data.times),color = 7},
            }
        costTxt.text = "("..mgr.TextMgr:getTextByTable(textData)..")"
        local getBtn = obj:GetChild("n6")
        getBtn.data = data
      
        local c1 = obj:GetController("c1")
        if data.sort == 2 then
            c1.selectedIndex = 2--已领取
        elseif data.sort == 1 then
            c1.selectedIndex = 0
            getBtn.data.state = 0
        else
            c1.selectedIndex = 1--可领取
            getBtn.data.state = 1
        end
        getBtn.onClick:Add(self.getAwards,self)
    end
end


function QB1002:getAwards(context)
    local data = context.sender.data
    if data.state == 0 then--不能领
        GComAlter(language.jianLingBorn05)
        return
    else
        proxy.ActivityProxy:sendMsg(1030686,{reqType = 1,cid = data.id})
    end
end

function QB1002:onTimer()
    if self.data and self.data.leftTime then
        if self.data.leftTime > 86400 then 
            self.leftTime.text = GTotimeString7(self.data.leftTime)
        else
            self.leftTime.text = GTotimeString(self.data.leftTime)
        end
        if self.data.leftTime <= 0 then
            self.mParent:onBtnClose()
        end
        self.data.leftTime = self.data.leftTime-1
    end
end


return QB1002