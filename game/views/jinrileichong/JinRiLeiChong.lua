--
-- Author: 
-- Date: 2018-08-20 15:58:20
--

local JinRiLeiChong = class("JinRiLeiChong", base.BaseView)

function JinRiLeiChong:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function JinRiLeiChong:initView()
    local closeBtn = self.view:GetChild("n4")
    self:setCloseBtn(closeBtn)
    self.timeText = self.view:GetChild("n8")
    self.ybText = self.view:GetChild("n11")
    self.btn = self.view:GetChild("n15")
    self.btn.onClick:Add(self.onGo,self)
    self.controller = self.view:GetController("c1")
    self.numText = self.view:GetChild("n21")
    self.listView = self.view:GetChild("n17")
    self.listView.itemRenderer = function(index, obj)
      self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
    self.listView1 = self.view:GetChild("n16")
    self.listView1.itemRenderer = function(index, obj)
      self:btnData(index,obj)
    end
   -- self.listView1:SetVirtual()
    self.listView1.numItems = 0
end

function JinRiLeiChong:setData(data)
    self.data = data 
    self.isFind = false
    self.isGoCharge = true
    if #self.data.items > 0 then
        GOpenAlert3(data.items,true)
    end
    self.Reward = conf.ActivityConf:getLeiChongAwardById(self.data.mulActId,self.data.actDay)
    if self.data.awardId == 0 then
        self.itemIdReward = conf.ActivityConf:getLeiChongAwardById1(self.Reward[1].id)
        self.numText.text = tostring(self.Reward[1].quota)
    else
        self.itemIdReward = conf.ActivityConf:getLeiChongAwardById1(self.data.awardId)
        self.numText.text = tostring( self.itemIdReward.quota)
    end
    self.ybText.text = tostring(self.data.lcYb)
    self.time = self.data.lastTime
    self:releaseTimer()
    if not self.actTimer then
        self.actTimer = self:addTimer(1,-1,handler(self,self.onTimer))
    end
    self.isGot = {}
    for k,v in pairs(self.data.gotData) do
        self.isGot[v] = 1
    end
    self.listView.numItems = #self.itemIdReward.awards
    self.listView1.numItems = #self.Reward
end

function JinRiLeiChong:releaseTimer()
    if self.actTimer then
        self.removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function JinRiLeiChong:cellData(index,obj)
    local  data = self.itemIdReward.awards[index+1]
    local t ={}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3]
    GSetItemData(obj, t, true) 
end
function JinRiLeiChong:btnData(index,obj)
    local data = self.Reward[index+1]
    obj.selected = false
    obj:GetChild("n4").text = tostring(data.quota)
    obj.data = data
    obj.onClick:Add(self.onWhich,self)
    if self.data.lcYb >= data.quota then  
        if not self.isGot[data.quota] and not self.isFind then
            obj.selected = true
            obj.onClick:Call()
            self.isFind = true
        elseif self.isGot[data.quota] and (#self.data.gotData == #self.Reward) then
            obj.onClick:Call()
        end
    else
        if not self.isFind and self.isGoCharge then
            obj.selected = true
            obj.onClick:Call()
            self.isGoCharge = false
        end
    end
end

function JinRiLeiChong:onWhich(context)
    local data = context.sender.data
    self.itemIdReward = data
    self.listView.numItems = #data.awards
    self.numText.text = tostring( self.itemIdReward.quota)
    --充值额度
    local quota = data.quota 
    local awardId = data.id
    if self.data.lcYb < quota then
        self.btn.icon = UIItemRes.jinrileichong[2]
        self.btn.data = {reqType = 2,id = awardId}
        self.controller.selectedIndex = 0
    else
        if self.isGot and self.isGot[quota] == 1 then
            self.controller.selectedIndex = 1--已领取
        else
            self.controller.selectedIndex = 0
            self.btn.icon = UIItemRes.jinrileichong[1]
            self.btn.data = {reqType = 1 ,id = awardId}
        end
    end
end

function JinRiLeiChong:onGo(context)
    local data = context.sender.data
    if not data then
        GComAlter("请选择档位")
        return
    end
    local reqType = data.reqType
    if reqType == 1 then
        proxy.ActivityProxy:sendMsg(1030240,{reqType = 1, awardId = data.id})
        local var = cache.PlayerCache:getRedPointById(30170)
                      cache.PlayerCache:setRedpoint(30170,var-1)
                      local mainview = mgr.ViewMgr:get(ViewName.MainView)
                      if mainview then
                          mainview:refreshRed()
                      end
    elseif reqType == 2 then
        GGoVipTequan(0)
        self:closeView()
    end
end


function JinRiLeiChong:onTimer()   
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

return JinRiLeiChong