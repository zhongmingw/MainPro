--
-- Author: 
-- Date: 2018-07-16 20:55:52
--

local XunBaoReturn = class("XunBaoReturn",import("game.base.Ref"))

function XunBaoReturn:ctor(mParent)
    self.mParent = mParent
    self:initPanel()

end

function XunBaoReturn:initPanel()
    self.view = self.mParent.view:GetChild("n5")
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

function XunBaoReturn:setData(data)
    self.data = data
    printt("剑灵寻宝返还",data)
    -- local actData = cache.ActivityCache:get5030111()
    if data.msgId == 5030216 then
        self.confData = conf.ActivityConf:getJianLingReturnAward()
        self.view:GetChild("n5").url = UIPackage.GetItemURL("jianling" , "jianlingchushi_021")
    elseif  data.msgId == 5030416 then
        self.confData = conf.ActivityConf:getXunBaoAwardbyactID(1188)
          self.view:GetChild("n5").url = UIPackage.GetItemURL("jianling" , "jianlingchushi_025")
  
    end
    self.isGot = {}
    for k,v in pairs(self.data.itemGotData) do
        self.isGot[v] = 1
    end
    for k,v in pairs(self.confData) do
        if self.isGot[v.id] and self.isGot[v.id] == 1 then 
            self.confData[k].sort = 2--已领取
        else
            if self.data.findTimes >= tonumber(v.times) then 
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

function XunBaoReturn:cellData( index, obj )
    local data = self.confData[index+1]
    if data then 
        local awardList = obj:GetChild("n5")
        GSetAwards(awardList, data.awards)
        local dec = obj:GetChild("n3")
        dec.text = string.format(language.jianLingBorn04,data.times)
        local costTxt = obj:GetChild("n4")
        local color = tonumber(self.data.findTimes) < tonumber(data.times) and 14 or 7
        local textData = {
                {text = tostring(self.data.findTimes),color = color},
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


function XunBaoReturn:getAwards(context)
    local data = context.sender.data
    if data.state == 0 then--不能领
        GComAlter(language.jianLingBorn05)
        return
    else
        if self.data.msgId == 5030216 then
            proxy.ActivityProxy:sendMsg(1030216,{reqType = 1,cid = data.id})
        elseif self.data.msgId == 5030416 then
            proxy.ActivityProxy:sendMsg(1030416,{reqType = 1,cid = data.id})

        end
    end
end

function XunBaoReturn:onTimer()
    if self.data and self.data.lastTime then
        if self.data.lastTime > 86400 then 
            self.leftTime.text = GTotimeString7(self.data.lastTime)
        else
            self.leftTime.text = GTotimeString2(self.data.lastTime)
        end
        if self.data.lastTime <= 0 then
            self.mParent:onBtnClose()
        end
        self.data.lastTime = self.data.lastTime-1
    end
end



return XunBaoReturn