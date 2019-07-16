--
-- Author: 
-- Date: 2018-09-04 21:29:31
--

local HeFuLianChong = class("HeFuLianChong", base.BaseView)

function HeFuLianChong:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function HeFuLianChong:initView()
   local closeBtn = self.view:GetChild("n0"):GetChild("n7")
   self:setCloseBtn(closeBtn)
   self.c1 = self.view:GetController("c1")
   self.list1 = self.view:GetChild("n23")
   self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
   self.list1:SetVirtual()
   self.list1.numItems = 0
   self.btnList = {}
   for i=4,10 do
       table.insert(self.btnList,self.view:GetChild("n"..i))
   end
end

function HeFuLianChong:setData(data)
    printt(data)
    self.data = data
    GOpenAlert3(data.items)
    self.HeFuLianChong = conf.ActivityConf:getHeFuLianChong(data.curDay)
    self.c1.selectedIndex = data.curDay - 1
    for k,v in ipairs(self.btnList) do
        v.touchable =false
        if data.curDay == k then
            v.touchable =true
        end
    end
    self.list1.numItems =  #self.HeFuLianChong
    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"HeFuLianChong")
end

function HeFuLianChong:onTimer( data )
    -- d
    if not self.data then return end 
    self.data.leftTime = math.max(self.data.leftTime - 1,0)
    if self.data.leftTime <= 0 then
        self:closeView()
        return
    end
end

function HeFuLianChong:celldata( index, obj )
    local data = self.HeFuLianChong[index + 1]
    local list = obj:GetChild("n17")
    GSetAwards(list,data.item)
    obj:GetChild("n15").text = string.format(language.hflc01,data.quota)
    obj:GetChild("n16").text = string.format(language.hflc02,self.data.dayRechargeNum[self.data.curDay]or 0,data.quota)
    local c1 = obj:GetController("c1")
    local btn = obj:GetChild("n19")
    if self.data.gotSigns[data.id] then
        c1.selectedIndex = 1
    else
        if not self.data.dayRechargeNum[self.data.curDay] then
           c1.selectedIndex = 2
           data.c1 = c1.selectedIndex 
           btn.data = data
           btn.onClick:Add(self.btnClick,self)
           return
        end 
        if self.data.dayRechargeNum[self.data.curDay] >= data.quota then
            c1.selectedIndex = 0
            data.c1 = c1.selectedIndex 
        else
            c1.selectedIndex = 2
            data.c1 = c1.selectedIndex 
        end
    end
    btn.data = data
    btn.onClick:Add(self.btnClick,self)
end

function HeFuLianChong:btnClick(context)
    local data = context.sender.data
    if data.c1 == 0 then
         proxy.ActivityProxy:sendMsg(1030521,{reqType = 1, cfgId = data.id})
    elseif data.c1 == 2 then
        GGoVipTequan(0)
        self:closeView()
    end
end
return HeFuLianChong