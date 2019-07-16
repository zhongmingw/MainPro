--
-- Author: 
-- Date: 2018-11-19 16:32:31
--

local XinYunLiJin = class("XinYunLiJin", base.BaseView)

function XinYunLiJin:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function XinYunLiJin:initView()
   local closeBtn = self.view:GetChild("n49"):GetChild("n7")
   self:setCloseBtn(closeBtn)
   local ruleBtn = self.view:GetChild("n10")
    ruleBtn.onClick:Add(self.clickRule,self)
   local costBtn1 = self.view:GetChild("n11")
   costBtn1.data = 1
    costBtn1.onClick:Add(self.cost,self)
   local costBtn2 = self.view:GetChild("n12")
   costBtn2.data = 2
   costBtn2.onClick:Add(self.cost,self)
    self.getBtn = self.view:GetChild("n34")
    self.getBtn.data = 3
     self.getBtn.onClick:Add(self.cost,self)



   self.lastTime = self.view:GetChild("n4")
   self.listView1 = self.view:GetChild("n23")
   self.listView1.itemRenderer = function(index,obj)
        self:cellData(index, obj,3)
   end

   self.listView2 = self.view:GetChild("n25")
   self.listView2.itemRenderer = function(index,obj)
        self:cellData(index, obj,2)
   end

   self.listView3 = self.view:GetChild("n26")
   self.listView3.itemRenderer = function(index,obj)
        self:cellData(index, obj,1)
   end

   self.tex1 = self.view:GetChild("n7")  --幸运儿数量
   local tex2 = self.view:GetChild("title1")  --消耗一次
   tex2.text = conf.ActivityConf:getValue("luckyKoi_one_cost")[2]
   local tex3 = self.view:GetChild("title2")  --消耗十次
   tex3.text = conf.ActivityConf:getValue("luckyKoi_ten_cost")[2]
   self.progress = self.view:GetChild("n27") 
   self.tex4 = self.view:GetChild("n36")
  


 

end

function XinYunLiJin:setData(data)
    printt("幸運錦鯉",data)
    self.data = data
    if data.items then
        GOpenAlert3(data.items,true)
    end
   self.confData = conf.ActivityConf:XinYunJinLi(self.data.curDay)

   self.listView1.numItems = #self.confData[3].items
   self.listView2.numItems = #self.confData[2].items
   self.listView3.numItems = #self.confData[1].items
    self.tex1.text =  self.data.luckyBoyNum
    local progressMax = conf.ActivityConf:getValue("luckyKoi_lucky_value")
    self.progress.max = progressMax
    self.progress.value = self.data.luckyValue or 0 

    self.tex4.text = mgr.TextMgr:getTextColorStr((self.data.luckyValue or tostring(0)).."/"..progressMax,14)  
    if data.isLuckyBoy == 0 then
        self.view:GetChild("n35").text = ""
    else
        self.view:GetChild("n35").text = string.format(language.xyjl01)
    end
    -- print(self.data.luckyBoyNum,progressMax)
     if self.data.luckyValue >= progressMax then
        self.getBtn.grayed = false
        self.getBtn:GetChild("red").visible = true
    else
        self.getBtn:GetChild("red").visible = false
        self.getBtn.grayed = true
    end

    self:releaseTimer()
    self.time = self.data.leftTime
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

end

function XinYunLiJin:cost(context)
    local data = context.sender.data
    local money =  cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if data == 1 then
        if money < conf.ActivityConf:getValue("luckyKoi_one_cost")[2] then
            GComAlter(language.sell23)
        else
                proxy.ActivityProxy:send(1030655,{reqType = 1})
        end
    elseif data == 2 then
        if money < conf.ActivityConf:getValue("luckyKoi_ten_cost")[2] then
             GComAlter(language.sell23)
        else
                proxy.ActivityProxy:send(1030655,{reqType = 2})
        end
    elseif data == 3 then
        if self.data.luckyValue >= conf.ActivityConf:getValue("luckyKoi_lucky_value")  then
                proxy.ActivityProxy:send(1030655,{reqType = 3})
        else
            GComAlter(language.gonggong76) 
        end

    end
end

function XinYunLiJin:cellData(index,obj,id)
    local data = self.confData[id].items
    local itemData = {mid = data[index+ 1][1],amount = data[index+ 1][2],bind = data[index+ 1][3]}
    GSetItemData(obj,itemData,true)  

end

function XinYunLiJin:clickRule(context)
    GOpenRuleView(1161)
end

function XinYunLiJin:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
    end
    self.time = self.time - 1
end

function XinYunLiJin:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

return XinYunLiJin