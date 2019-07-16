--
-- Author: 
-- Date: 2018-09-03 11:55:08
--

local DongFangRank = class("DongFangRank", base.BaseView)

function DongFangRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function DongFangRank:initView()
   local closeBtn = self.view:GetChild("n1"):GetChild("n7")
   self:setCloseBtn(closeBtn)
   self.lastTime = self.view:GetChild("n15")
   self.c1 = self.view:GetController("c1")
   self.getBtn = self.view:GetChild("n11") --领取btn
   self.getBtn.onClick:Add(self.btnClick1,self)
   self.rankBtn = self.view:GetChild("n24") --排行btn
   self.rankBtn.onClick:Add(self.btnClick2,self)
   self.list1 = self.view:GetChild("n10")
   self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
   self.list2 = self.view:GetChild("n20")
   self.list2.itemRenderer = function(index,obj)
        self:cellrank(index, obj)
   end
   self.dec1 = self.view:GetChild("n8") --文本
   self.dec2 = self.view:GetChild("n9") 
   self.dec3 = self.view:GetChild("n13") 
   self.dec4 = self.view:GetChild("n14") 

   self.model1 = self.view:GetChild("n5") --模型
   self.model2 = self.view:GetChild("n6") 

   self.DongFangWholeAward = conf.ActivityConf:getDongFangWholeAward()
   self.DongFangRankAward = conf.ActivityConf:getDongRankFangAward()
   --奖励展示
   self.DongFangRankAwardPanel =  self.view:GetChild("n26")
   self.closeBtn = self.DongFangRankAwardPanel:GetChild("n10")
   self.closeBtn.onClick:Add(self.btnClick3,self)
   self.list3 = self.DongFangRankAwardPanel:GetChild("n6")
   self.list3.itemRenderer = function(index,obj)
        self:cellshowrank(index, obj)
   end
   self.list3.numItems = 4
   self.DongFangRankAwardPanel.visible = false
   self.controller = self.view:GetController("c1")
end

function DongFangRank:setData(data)
    self.data = data
    printt(self.data)
    self.time = data.lastTime
    self:releaseTimer()
    self:setModel()
    if #data.items > 0 then
       GOpenAlert3(data.items)
    end
    self.isget = {}
    for k ,v in pairs(data.gotData) do
        self.isget[v] = true
    end
    local max = #self.DongFangWholeAward
    self.index = max
    for k ,v in pairs(self.DongFangWholeAward) do
        if not self.isget[v.id] then
            self.index = k
            break
        end
    end
    self.curdata = self.DongFangWholeAward[self.index]
    if self.isget[self.curdata.id] then
        self.controller.selectedIndex = 2
    else
        if data.holeDfTimes >= self.curdata.count then
            self.controller.selectedIndex = 0
        else
            self.controller.selectedIndex = 1
        end
    end
    self.DongFangWholeAwardById = conf.ActivityConf:getDongFangWholeAwardById(self.index)
    self.list1.numItems = #self.DongFangWholeAwardById.awards
    if data.reqType == 0 then
        self.list2.numItems = math.max(#self.data.dfRankInfo,10)
    end
    if #data.gotData == 0 then
        self.dec1.text = string.format(language.dfr01,1,#self.DongFangWholeAward)
    else
        self.dec1.text = string.format(language.dfr01,#data.gotData+1,#self.DongFangWholeAward)
        if #data.gotData == #self.DongFangWholeAward then
            self.dec1.text = string.format(language.dfr01,#self.DongFangWholeAward,#self.DongFangWholeAward)
        end
    end

    self.dec2.text = string.format(language.dfr02,data.holeDfTimes,self.DongFangWholeAwardById.count)
    self.dec3.text = string.format(language.dfr03,conf.ActivityConf:getHolidayGlobal("dongfang_rank_min_times") )
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function DongFangRank:setModel()
    local modelId = conf.ActivityConf:getHolidayGlobal("df_model")
    local model1 = self:addModel(modelId[1],self.model1)
    model1:setPosition(72,-298,600)
    model1:setRotationXYZ(0,179.6,0)
    model1:setScale(167,167,167)
    local model2 = self:addModel(modelId[2],self.model2)
    model2:setPosition(57,-364,801)
    model2:setRotationXYZ(0,178,0)
    model2:setScale(167,167,167)
end

function DongFangRank:onTimer()
    if not self.data then return end 
    self.data.lastTime = math.max(self.data.lastTime - 1,0)
    if self.data.lastTime <= 0 then
        self:closeView()
        return
    end
    self.dec4.text = string.format(language.xbpa02,GGetTimeData2(self.data.lastTime))  
end


function DongFangRank:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function DongFangRank:celldata( index, obj )
    local data = self.DongFangWholeAwardById.awards[index + 1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3]
    GSetItemData(obj,t,true)
end

function DongFangRank:cellrank( index, obj )
    local data = self.data.dfRankInfo[index + 1]
    local controller = obj:GetController("c1")
    if data then
        obj:GetChild("n1").text = data.rank
        obj:GetChild("n2").text = data.roleName
        obj:GetChild("n7").text = data.coupleName
        if data.rank <= 3 then
            obj:GetChild("n8").visible = true
            controller.selectedIndex = data.rank - 1
        else
            controller.selectedIndex = 3
        end
        obj:GetChild("n3").text = data.dfTimes
    else
        obj:GetChild("n1").text = index + 1
        obj:GetController("c1").selectedIndex = 3
        if index <= 3 then
            controller.selectedIndex = index
            obj:GetChild("n8").visible = false
        else
            controller.selectedIndex = 3
        end
    end
end

function DongFangRank:cellshowrank( index, obj )
    local data = self.DongFangRankAward[index + 1]
    local list = obj:GetChild("n3")
    obj:GetController("c1").selectedIndex = index 
    list.itemRenderer = function(index,obj)
        self:cellshowdata(index, obj)
    end
    if index == 0 then
        obj:GetChild("n1").text = "1"
    elseif index == 1 then
        obj:GetChild("n1").text = data.rank[1].."~"..data.rank[2]
    elseif index == 2 then
        obj:GetChild("n1").text = data.rank[1].."~"..data.rank[2]    
    end
    GSetAwards(list,data.awards)
end

function DongFangRank:btnClick1(context)
   if  self.controller.selectedIndex == 1 then
         GComAlter(language.dfr04)
         return
   elseif self.controller.selectedIndex == 0 then
        local param = {}
        param.reqType = 1
        param.cid = self.index
        if self.index >  #self.DongFangWholeAward then
            print("已领取到最高")
            return
        end
        proxy.ActivityProxy:sendMsg(1030245,param)
        local var = cache.PlayerCache:getRedPointById(20206)
                      cache.PlayerCache:setRedpoint(20206,var-1)
                      local mainview = mgr.ViewMgr:get(ViewName.MainView)
                      if mainview then
                          mainview:refreshRed()
                      end
   end

end

function DongFangRank:btnClick2(context)
    self.DongFangRankAwardPanel.visible = true
end

function DongFangRank:btnClick3(context)
    self.DongFangRankAwardPanel.visible = false
end


return DongFangRank