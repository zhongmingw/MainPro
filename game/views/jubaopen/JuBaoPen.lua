--
-- Author: 
-- Date: 2018-08-11 19:00:01
--

local JuBaoPen = class("JuBaoPen", base.BaseView)

local angleTimes = {0.25,0.5,0.75,1,1.25,1.5,1.75,2}

function JuBaoPen:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function JuBaoPen:initView()
    local closeBtn = self.view:GetChild("n29")
    closeBtn.onClick:Add(self.onBtnClose,self)
    -- self:setCloseBtn(closeBtn)
    self.timeText = self.view:GetChild("n4")
    self.currentRecharge = self.view:GetChild("n9")
    self.targetRecharge = self.view:GetChild("n19")
    self.iconYB =  self.view:GetChild("n20")
    self.maxText = self.view:GetChild("n57")
    self.describleText = self.view:GetChild("n22")
    self.ruleText1 = self.view:GetChild("n26")
    self.ruleText1.text = language.JuBaoPen02
    self.ruleText2 = self.view:GetChild("n27")
    self.ruleText2.text = language.JuBaoPen03
    self.ruleText3 = self.view:GetChild("n28")
    self.ruleText3.text = language.JuBaoPen04
    self.btn = self.view:GetChild("n6")
    self.btn.onClick:Add(self.onClick,self)
    self.leftTimeText = self.view:GetChild("n56")
    self.titleIcon = self.view:GetChild("n58")
    self.listView = self.view:GetChild("n24")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
    self.awardsList = {}
    for i=47,54 do
        table.insert(self.awardsList, self.view:GetChild("n"..i))
    end
    self.t1 = self.view:GetTransition("t1")
    self.tList = {}
    for i=2,9 do
        table.insert(self.tList, self.view:GetTransition("t"..i))
    end
end

function JuBaoPen:setData(data)
     self.data = data
     printt(self.data)
     self.time = data.lastTime
     self.Reward = conf.ActivityConf:getJuBaoPengaward(self.data.mulActId)
     self.numMax = #self.Reward
     self.num = self.Reward[1].quota
     self.leftTimeText.text = string.format(language.JuBaoPen08,
     mgr.TextMgr:getTextColorStr(tostring(self.data.leftTimes),20))
      --多开活动配置
     self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
     local titleIconStr = self.mulConfData.title_icon or "jubaopen_004"
     self.titleIcon.url = UIPackage.GetItemURL("jubaopen" , titleIconStr)
     self:setAwards()
     self:setInfoData()
     if self.data.reqType == 1 then
          self.btn.touchable =false 
          self:actionEffect()
     else
         self.listView.numItems = #self.data.record
     end
     self:releaseTimer()
     if not self.actTimer then
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
     end
end

function JuBaoPen:setAwards() --设置倍数信息
    local  confData
    if self.data.quota > 0 and self.data.currBuyYb > 0 then
        for k,v in pairs(self.Reward) do
            if self.data.currBuyYb == v.quota then
                confData = v.multiple
                break
            end
        end
    else
        confData = self.Reward[1].multiple
    end
    for  i=1,#self.awardsList  do
        local obj = self.awardsList[i]
        obj:GetChild("n48").text = tostring(confData[i][1]/100)  
        local itemData = {mid = PackMid.gold,amount = 0 ,bind = 1,icon = UIItemRes.ingotType[1]}
        GSetItemData(obj:GetChild("n45"), itemData)
        obj:GetChild("n45"):GetChild("icon").pivot = Vector2(0.5,0.5)
        obj:GetChild("n45"):GetChild("icon").scale = Vector2(0.7,0.7)
        obj:GetChild("n45"):GetChild("icon").y = -1
    end
end

function JuBaoPen:actionEffect()
   self.t1:Play()
   local index
   local awardIndex
   awardIndex = conf.ActivityConf:getJuBaoPengawardByQuota(self.data.currBuyYb)
   for k,v in pairs(awardIndex) do
       if v[1] == self.data.baseRate then
             index = k
       end
   end
   self:addTimer(1.8,1,function()
      self.tList[index]:Play()
      self:addTimer(angleTimes[index],1,function()
        self.listView.numItems = #self.data.record
        self.btn.touchable = true
    end)
     end)
end

function JuBaoPen:setInfoData()
    self.currentRecharge.text = tostring(self.data.quota)

    if self.data.currBuyYb == 0 then
        self.maxText.visible = false
        self.targetRecharge.visible = true
        self.targetRecharge.text = tostring(self.Reward[1].quota)
        self.describleText.text = string.format(language.JuBaoPen01,
                        mgr.TextMgr:getTextColorStr(tostring(self.Reward[1].quota),7),
                        mgr.TextMgr:getTextColorStr(tostring(self.Reward[1].quota*3),7))
    else
        for i=1,self.numMax do
            if self.Reward[i].quota == self.data.currBuyYb then
                if self.data.currBuyYb ==  self.Reward[self.numMax].quota then
                     self.targetRecharge.text = tostring(self.data.currBuyYb)
                     self.describleText.visible = false
                     self.maxText.visible = true
                     self.iconYB.visible = false
                     self.targetRecharge.visible = false
                else
                    self.targetRecharge.text = tostring(self.Reward[i+1].quota)
                    self.num = self.Reward[i].quota
                    self.describleText.text = string.format(language.JuBaoPen01,
                        mgr.TextMgr:getTextColorStr(tostring(self.Reward[i+1].quota),7),
                        mgr.TextMgr:getTextColorStr(tostring(self.Reward[i+1].quota*3),7))
                end
                return
            end
        end  
    end
    self.listView.numItems = #self.data.record
end

function JuBaoPen:onTimer()   
    if  math.floor(self.time / 86400) <= 0 then
        self.timeText.text = GGetTimeData4(self.time)
    else
        self.timeText.text = GGetTimeData2(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
        return
    end
    self.time = self.time - 1
end


function JuBaoPen:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function JuBaoPen:cellData(index,obj)
    local data = self.data.record[index+1]
    local strTab = string.split(data,"#")
    obj:GetChild("n29").text = string.format(language.JuBaoPen05,
    mgr.TextMgr:getTextColorStr(strTab[1],7),
    mgr.TextMgr:getTextColorStr(tostring(strTab[3]/100),7))
end

function JuBaoPen:onClick(context)
    if self.data then
        if self.data.quota > self.data.currBuyYb then --累充大于当前时
            local interpolationYb,nextYb
            for i=1,self.numMax do --获取需要达到x元宝才可进行下注
              if  (self.Reward[i].quota == self.data.currBuyYb) or (self.data.currBuyYb == 0) then
                  if self.data.currBuyYb >= self.Reward[self.numMax].quota then
                       GComAlter(language.JuBaoPen07)
                        return
                  else
                      nextYb = self.Reward[i+1].quota
                      interpolationYb = nextYb - self.data.currBuyYb
                      break
                  end
              end
            end
                local currentYb = self.data.quota - nextYb
                if self.data.leftTimes > 0 then
                      proxy.ActivityProxy:sendMsg(1030238,{reqType = 1}) 
                      local var = cache.PlayerCache:getRedPointById(20199)
                      cache.PlayerCache:setRedpoint(20199,var-1)
                      local mainview = mgr.ViewMgr:get(ViewName.MainView)
                      if mainview then
                          mainview:refreshRed()
                      end
                else 
                    GComAlter(language.JuBaoPen06)
                end
            else
                    GComAlter(language.JuBaoPen06)
        end
    end
end

function JuBaoPen:onBtnClose()
       self.btn.touchable =true 
       self:releaseTimer()
       self:closeView()
end
return JuBaoPen