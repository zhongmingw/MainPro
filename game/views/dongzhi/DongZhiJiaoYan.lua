--
-- Author: 
-- Date: 2018-12-12 21:04:18
--

local DongZhiJiaoYan = class("DongZhiJiaoYan", base.BaseView)

function DongZhiJiaoYan:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function DongZhiJiaoYan:initView()
     local closeBtn = self.view:GetChild("n0"):GetChild("n6")
    self:setCloseBtn(closeBtn)
     self.lastTime = self.view:GetChild("n8")
     self.descTex = self.view:GetChild("n16")

    self.listview = self.view:GetChild("n12") 
    self.listview.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    local num1 = conf.DongZhiConf:getGlobal("ws_one_cost")[2]
    local num2 = conf.DongZhiConf:getGlobal("ws_ten_cost")[2]
    local num3 = conf.DongZhiConf:getGlobal("ws_fifty_cost")[2]
    local  btn = self.view:GetChild("n45")
    btn:GetChild("n4").text = num1
    btn.data = {state = 1 ,num = num1}
    btn.onClick:Add(self.ChouJiang,self)
    local  btn1 = self.view:GetChild("n46")
    btn1:GetChild("n4").text = num2
    btn1.data = {state = 2 ,num = num2}
    btn1.onClick:Add(self.ChouJiang,self)
    local  btn2 = self.view:GetChild("n47")
    btn2:GetChild("n4").text = num3
    btn2.data = {state = 3 ,num = num3}
    btn2.onClick:Add(self.ChouJiang,self)

    self.progress = self.view:GetChild("n20")
    self.baoxiangList = {}
    self.confdata = conf.DongZhiConf:getDongZhiCHouJiang(2)
     self.valuelist = {}
      self.max = 0
    for i = 29,32 do 
        local btn = self.view:GetChild("n"..i)
        btn:GetChild("n5").text = "[/color][color=#444034]"..self.confdata[i-28].nums.."只[/color]"
        self.max = self.max + self.confdata[i-28].nums
        self.progress.max = self.progress.max + self.confdata[i-28].nums
        btn.data = {index = i - 28,cid = self.confdata[i-28].id,num =self.confdata[i-28].nums }
        table.insert(self.valuelist,self.confdata[i-28].nums)
        btn.onClick:Add(self.onGet,self)
        table.insert(self.baoxiangList,{obj = btn,index = i - 28,num = self.confdata[i-28].nums,cid = self.confdata[i-28].items[1][1] })
    end
     table.sort(self.valuelist)
    self.showData = conf.DongZhiConf:getDongZhiCHouJiangShow()
  
    self.listview.numItems = #self.showData
end

function DongZhiJiaoYan:onGet(context)
    local data = context.sender.data
    printt(data)

    if  self.sign[data.num] then
        GComAlter(language.bangpai43)
    else
        --判断是否可以领取
        if self.data.lotteryCount >= self.baoxiangList[data.index].num then

            proxy.DongZhiProxy:send(1030666,{reqType = 4, cid = data.cid})
        else
            GComAlter(language.dz07)
        end
    end
end

function DongZhiJiaoYan:ChouJiang(context)
    local data = context.sender.data
    local money = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    print(data.num , money,data.state)
    if data.state == 1 and data.num <= money then
        proxy.DongZhiProxy:send(1030666,{reqType =1, cid = 0})
    elseif data.state == 2 and data.num <= money then
        proxy.DongZhiProxy:send(1030666,{reqType =2, cid = 0})
    elseif data.state == 3 and data.num <= money then
        proxy.DongZhiProxy:send(1030666,{reqType =3, cid = 0})
    else
        GComAlter("当前元宝不足")
    end
end

function DongZhiJiaoYan:setData(data)
    printt(data)
    self.data = data
    if data.items then
        GOpenAlert3(data.items,true)
    end
    self.sign = {}
    for k,v in pairs(data.gotSign) do
         self.sign[v] = 1
     end 
   
    for k,v in pairs(self.baoxiangList) do
        if self.sign[v.num] or (v.num >  self.data.lotteryCount) then
            v.obj:GetChild("icon").grayed = true
             v.obj:GetController("c1").selectedIndex = 0
        else
            v.obj:GetChild("icon").grayed = false
              v.obj:GetController("c1").selectedIndex = 1
        end

    end
    -- self.progress.value = data.lotteryCount <= self.confdata[1].nums and 0 or data.lotteryCount
    local isMax = false
      for k ,v in pairs(self.valuelist) do
        if v >= self.data.lotteryCount then
            isMax = true
            local dis = v -  (self.valuelist[k-1] or 0)
            local last = self.data.lotteryCount - (self.valuelist[k-1] or 0)
           
            self.progress.value = 1/4*self.max*(k-1) +  1/4*self.max * last/dis
            break   
        end
    end
    if not  isMax  then
         self.progress.value = self.max
    end
    self.progress.max = self.max

    self.descTex.text =  string.format(language.dz06,data.lotteryCount) 
    self:releaseTimer()
    local severTime = mgr.NetMgr:getServerTime()
    self.time = self.data.actEndTime -severTime
     if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function DongZhiJiaoYan:onTimer()
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

function DongZhiJiaoYan:cellData(index, obj)
   local data  = self.showData[index + 1].items[1]
   local itemData  =  {mid = data[1],amount = data[2],bind = data [3]}
   GSetItemData(obj, itemData, true)

end


function DongZhiJiaoYan:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

return DongZhiJiaoYan