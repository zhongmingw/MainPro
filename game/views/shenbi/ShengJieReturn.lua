--
-- Author: 
-- Date: 2018-07-30 14:38:50
--

local ShengJieReturn = class("ShengJieReturn",import("game.base.Ref"))

function ShengJieReturn:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ShengJieReturn:initPanel()
    self.view = self.mParent.view:GetChild("n4")
    self.leftTime = self.view:GetChild("n4")  --倒计时
    self.leftTime.text = ""

    local ruleBtn = self.view:GetChild("n15")
    ruleBtn.onClick:Add(self.onClickRule,self)
    --奖励列表
    self.listView = self.view:GetChild("n2")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
end


function ShengJieReturn:setData(data)
    self.data = data
    printt("麒麟臂进阶返还",data)
    self.confData = conf.ActivityConf:getShenBiReturnAward()
    self.isGot = {}
    for k,v in pairs(self.data.itemGotData) do
        self.isGot[v] = 1
    end
    for k,v in pairs(self.confData) do
        if self.isGot[v.id] and self.isGot[v.id] == 1 then 
            self.confData[k].sort = 2--已领取
        else
            if self.data.curStep >= tonumber(v.jie) then 
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

function ShengJieReturn:cellData( index, obj )
    local data = self.confData[index+1]
    if data then 
        local awardList = obj:GetChild("n5")
        GSetAwards(awardList, data.awards)
        local dec = obj:GetChild("n3")
        dec.text = string.format(language.sbqt04,data.jie)
        local costTxt = obj:GetChild("n4")
        local color = tonumber(self.data.curStep) < tonumber(data.jie) and 14 or 7
        local textData = {
                {text = tostring(self.data.curStep),color = color},
                {text = "/",color = 7},
                {text = tostring(data.jie),color = 7},
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

function ShengJieReturn:getAwards(context)
    local data = context.sender.data
    if data.state == 0 then--不能领
        GComAlter(language.jianLingBorn05)
        return
    else
        proxy.ActivityProxy:sendMsg(1030227,{reqType = 1,cid = data.id})
    end
end

function ShengJieReturn:onTimer()
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

function ShengJieReturn:onClickRule()
    GOpenRuleView(1114)
end


return ShengJieReturn