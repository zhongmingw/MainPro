--
-- Author: 
-- Date: 2018-08-01 14:47:32
--

local ConsumeChange = class("ConsumeChange", base.BaseView)

function ConsumeChange:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ConsumeChange:initView()
   local closeBtn = self.view:GetChild("n0"):GetChild("n7")
   self:setCloseBtn(closeBtn)
   self.lastTime = self.view:GetChild("n3")
   self.awardItem = conf.ActivityConf:getConsume()
   self.listView = self.view:GetChild("n20")
   self.listView.itemRenderer = function (index,obj)
      self:cellData(index,obj)
   end
   self.listView.numItems = #self.awardItem
   self.costYb = self.view:GetChild("n9")
   self.score = self.view:GetChild("n6")
   self.textRule = self.view:GetChild("n10")
end

function ConsumeChange:cellData(index,obj)
    local data = self.awardItem[index + 1]
    local t = {}
    t.mid = data.item[1]
    t.amount = data.item[2]
    t.bind = data.item[3]
    local itemObj = obj:GetChild("n14")
    GSetItemData(itemObj, t, true) 
    local name = obj:GetChild("n13")
    name.text = conf.ItemConf:getName(t.mid)
    local needScoreText = obj:GetChild("n17")
    needScoreText.text = data.score[2]
    local scoreText = obj:GetChild("n18")
    scoreText.text = string.format(language.xhdh02, data.score[1])
    data.needScore = data.score[2]
    if self.data then 
        if self.data.exchangeTimes[data.id] then
            local times = self.data.exchangeTimes[data.id]
            local bei = math.ceil((times+1)/data.score[1])--倍数
            needScoreText.text = data.score[2]*math.pow(2,(bei - 1))
            data.needScore = tonumber(needScoreText.text)
            local laterNum = data.score[1] - times%data.score[1]
            scoreText.text = string.format(language.xhdh02,laterNum)
        end
    end  
    local btn = obj:GetChild("n19")
    btn.data = data 
    btn.onClick:Add(self.onBuyCall,self)
   
end


function ConsumeChange:setData(data)
    self.data = data
    -- self.time = data.lastTime
    self.textRule.text = language.xhdh03
    if data and #data.items >0 then
       GOpenAlert3(data.items,true)
    end     
    self.costYb.text = data.costYb
    self.score.text = data.score  
    self.listView.numItems = #self.awardItem
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function ConsumeChange:onBuyCall(context)

    if not self.data then
        return
    end
    local data = context.sender.data
    if data.needScore <= self.data.score then 
          local param = {}
          param.reqType = 1
          param.cid = data.id
          proxy.ActivityProxy:sendMsg(1030229,param)
    else    
        GComAlter(language.xhdh01)
    end
end

function ConsumeChange:onTimer()
    if not self.data then
     return
    end
    self.data.lastTime = math.max(self.data.lastTime - 1 , 0 ) 
    if self.data.lastTime <= 0 then
        self:closeView()
        self:releaseTimer()
        return
    end
    self.lastTime.text = GGetTimeData2(self.data.lastTime)
end

function ConsumeChange:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

return ConsumeChange