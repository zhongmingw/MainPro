--
-- Author: 
-- Date: 2018-12-11 17:57:44
--

local Lb1003 = class("Lb1003",import("game.base.Ref"))

function Lb1003:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end


 
-- int8
-- 变量名：reqType 说明：0:显示 1:兑换  
-- int32
-- 变量名：cid 说明：配置id  
-- int32
-- 变量名：times   说明：次数
-- array<SimpleItemInfo>   变量名：items   说明：兑换的物品  
-- int32
-- 变量名：actStartTime    说明：活动开始时间  
-- int32
-- 变量名：actEndTime  说明：活动结束时间
-- map<int32,int32>
-- 变量名：timesMap    说明：已经兑换的次数（id--次数）
function Lb1003:addMsgCallBack(data)
    -- body
    printt("腊八兑换",data)
    self.data  = data
    if data.reqType == 0 then
        self:clear()
        if self.list1.numItems == 0 then
           self.itemConf = conf.LaBaConf2019:getExchange(1)
           for i,v in ipairs(self.itemConf) do
              self:RefreshList(v,self.list1)
           end
        end
        if self.list2.numItems == 0 then
           self.itemConf = conf.LaBaConf2019:getExchange(2)
           for i,v in ipairs(self.itemConf) do
              self:RefreshList(v,self.list2)
           end
        end
        if not self.btn then  
            self.list1:GetChildAt(0).onClick:Call()
        end
    elseif data.reqType == 1 then
        if self.btn then 
         
            self.btn.onClick:Call()
        end
    end
    self.btn3:GetChild("n6").visible = self:CalRedPoint(1)
    self.btn4:GetChild("n6").visible = self:CalRedPoint(2)
    -- print(self:CalRedPoint(1),self:CalRedPoint(2))
    if  data.items then
        GOpenAlert3(data.items,true)
    end  
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self.parent:addTimer(1, -1, handler(self, self.onTimer))
    end   

end

function Lb1003:open(context)
    local data = context.sender.data

    if data == 1  then --腊八粥
       self.jiantou1.scaleY = -1
       self.jiantou2.scaleY = 1
       if  self.listitem1.visible then
            self.jiantou1.scaleY =1
           self.listitem1.visible = false
           self.btn3.selected = false
           return
       end
       self.listitem1.visible = true
       self.listitem2.visible = false

        for i = 0 , self.list1.numChildren-1 do 
            local var = self.list1:GetChildAt(i)
            if var then
     
                var:GetChild("n6").visible =  self:CalRedPointById(var.data.info.id)
            end
        end
    end
    if data ==2 then --惊喜合成
       self.jiantou1.scaleY = 1
       self.jiantou2.scaleY = -1
       if  self.listitem2.visible then
            self.jiantou2.scaleY =1
           self.listitem2.visible = false
           self.btn4.selected = false
           return
       end
       self.listitem1.visible = false
       self.listitem2.visible = true
    
        for i = 0 , self.list2.numChildren-1 do 
            local var = self.list2:GetChildAt(i)
            if var then
                var:GetChild("n6").visible =  self:CalRedPointById(var.data.info.id)
            end
        end
    end


end

function Lb1003:initView()
   
    self.btn1 = self.view:GetChild("n13") --一键合成

    self.btn1.onClick:Add(self.hecheng,self)
    self.btn2 = self.view:GetChild("n14") --合成

    self.btn2.onClick:Add(self.hecheng,self)
    self.btn3 = self.view:GetChild("n32"):GetChildAt(0) --腊八粥
    self.btn3.title = language.labaDlhl2019_09[1]
    self.btn3.data = 1
    self.btn3.onClick:Add(self.open,self)
    self.jiantou1 = self.btn3:GetChild("n5")
    self.btn4 = self.view:GetChild("n32"):GetChildAt(1)--惊喜合成
    self.btn4.data = 2
    self.btn4.onClick:Add(self.open,self)
    self.btn4.title = language.labaDlhl2019_09[2]
    self.jiantou2 = self.btn4:GetChild("n5")
    
    self.item = self.view:GetChild("n5")
    self.hechengList = {}
    for i = 8,11 do 
        local com = self.view:GetChild("n"..i)
        table.insert(self.hechengList, com)
    end
 
    self.listitem1 = self.view:GetChild("n29")
    self.listitem2 = self.view:GetChild("n31")
    self.list1 =  self.listitem1:GetChild("n16")
    self.list2 =  self.listitem2:GetChild("n16")

    self.text01 = self.view:GetChild("n12") --合成费用
    self.text02 = self.view:GetChild("n15") --合成次数

end

function Lb1003:Change(context)
    local data = context.sender.data
    self.btn = data.objBtn
    self.listitem1.visible = false
    self.listitem2.visible = false
    self.btn3.selected = false
    self.btn4.selected = false
    self.jiantou1.scaleY = 1
    self.jiantou2.scaleY = 1
    self:setRedPoint(false)

    self.btn1:GetChild("n4").visible = false
    self.btn2:GetChild("n4").visible = false
    self.item.visible = true
    local canHasNum = 0 --可兑换次数
    local flag = false
    local flag1 = false
    local  itemData = {mid = data.info.items[1][1],amount = 1,bind = 0}
    GSetItemData(self.item, itemData, true)
    for k,v in pairs(self.hechengList) do
        local item,text1,lock  
        item = v:GetChild("n3")
        text1 = v:GetChild("n2")
        lock = v:GetChild("n4")
        item.visible = false
        text1.text = "无"
        lock.visible = true
        if data.info.cost[k]  then --221051004 为铜钱id 不显示
            item.visible = true
            lock.visible = false
            GSetItemData(item, {mid = data.info.cost[k][1],amount = 1,bind = 0}, true)
            local hasNum = 0 
            hasNum = cache.PackCache:getPackDataById(data.info.cost[k][1]).amount or 0
            text1.text = self:colorText(hasNum,data.info.cost[k][2])
            if hasNum >= data.info.cost[k][2] then
                flag = true
            else
                flag = false
                flag1 = true
                
            end  
        end
    end

    local currentmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
    self.text01.text = self:colorText(currentmoney,data.info.money[2])
    print(currentmoney,data.info.money[2])
    self.text02.text = self.data.timesMap[data.info.id] and  self:colorText(self.data.timesMap[data.info.id],data.info.num) or  self:colorText(0,data.info.num) 
    if currentmoney >= data.info.money[2] then
        if not flag then 
            flag = false
        else
            flag = true
        end
    else
        flag = false
        flag1 = true
    end
    if flag1 then
        self:setRedPoint(false)
    else
        self:setRedPoint(true)

    end
    if flag then -- 可合成标志
        
        --计算可合成数量:取最小值
        local tableNum = {}
        for k,v in pairs(data.info.cost) do
            local num  = math.floor(cache.PackCache:getPackDataById(v[1]).amount/v[2]) 
            table.insert(tableNum, num)
        end
        --money
        local num =  math.floor(currentmoney/data.info.money[2]) 
        table.insert(tableNum, num)
        print("33333",self.data.timesMap[data.info.id],data.info.num)
        printt(tableNum)
        table.sort(tableNum)
        if self.data.timesMap[data.info.id] and (self.data.timesMap[data.info.id] < data.info.num) then -- 已经有合成数量
            local num1 = data.info.num - self.data.timesMap[data.info.id] --还剩多少次
            if  tableNum[1] >= num1 then
                canHasNum = num1  
            else
                canHasNum = tableNum[1] 
            end  

        elseif self.data.timesMap[data.info.id] and (self.data.timesMap[data.info.id] >= data.info.num) then -- 达到合成次数
            self.btn1.data = {state = 3}
            self.btn2.data = {state = 3}
            self:setRedPoint(false)
            return
        else
            if tableNum[1] >= data.info.num then
                canHasNum =  data.info.num
            else
                canHasNum = tableNum[1]
            end
        end
    end


    if canHasNum >0 then
        self.btn1.data = {state = 2,cid = data.info.id ,times = canHasNum}
        self.btn2.data = {state = 2,cid = data.info.id ,times = 1 }
    else
        self.btn1.data = {state = 1,cid = data.info.id ,times =canHasNum }
        self.btn2.data = {state = 1,cid = data.info.id ,times = 1 }
    end
    

  
end

function Lb1003:hecheng(context)
    local data = context.sender.data
    if data.state == 1 then 
        GComAlter(language.labaDlhl2019_03 )
        return
    elseif data.state == 2 and data.times >0 then
        print(data.times,data.cid )
        proxy.LaBaProxy2019:send(1030690,{reqType = 1,cid = data.cid ,times = data.times})
    elseif data.state == 3 then 
        GComAlter(language.labaDlhl2019_02 )
        return
    elseif data.state == 4 then
        GComAlter(language.labaDlhl2019_04 )
    end
end

function Lb1003:onTimer()
    if not self.data then return end
    local severTime =  mgr.NetMgr:getServerTime()
    if severTime >= self.data.actEndTime then
        local  view = mgr.ViewMgr:get(ViewName.LaBaView2019)
        if view then
            view:closeView()
        end
    end
end

function Lb1003:numToStrformat(num)
    if num >= 10000 then
        return math.floor(num/10000).."万"
    else
        return num
    end
end

function Lb1003:colorText(num1,num2)

    local str = ""
    if num1 >= num2 then
   
        str = "[color=#0b8109]".. self:numToStrformat(num1).."/"..  self:numToStrformat(num2).."[/color]"
    else
        str ="[color=#da1a27]"..self:numToStrformat(num1).."[/color]".."[color=#0b8109]".."/".. self:numToStrformat(num2).."[/color]"
    end
    return str
end

function Lb1003:RefreshList(v,list)
   local url = UIPackage.GetItemURL("laba2019" , "Button1")
   local obj = list:AddItemFromPool(url)
   obj.data = {info = v ,objBtn = obj }
   obj:GetChild("n5").visible = false
   obj:GetChild("title").text = v.name
   obj.onClick:Add(self.Change,self)
end

function Lb1003:clear()
   self.listitem1.visible = false
   self.listitem2.visible = false
   self.btn1.data = {state = 4}
   self.btn2.data = {state = 4}
   self.item.visible = false
   self.btn1:GetChild("n4").visible = false
   self.btn2:GetChild("n4").visible = false
   self.btn3.title = language.labaDlhl2019_09[1]
   self.btn4.title = language.labaDlhl2019_09[2]
   self.text01.text = ""
   self.text02.text = ""
   for k,v in pairs(self.hechengList) do
        local item = v:GetChild("n3")
        local text1 = v:GetChild("n2")
        local lock = v:GetChild("n4")
        item.visible = false
        text1.text = "无"
        lock.visible = true
   end
    self.jiantou2.scaleY = 1
    self.jiantou1.scaleY = 1
    self.btn = nil
end
function Lb1003:setRedPoint(flag)
    self.btn1:GetChild("n4").visible = flag
    self.btn2:GetChild("n4").visible = flag
end

function Lb1003:CalRedPoint(index)
    local  conf = conf.LaBaConf2019:getExchange(index)
    local flag = false
    for k,v in pairs(conf) do
         flag = false
        local flag1 = false
        local hasNum = 0 
        for k1,v1 in pairs(v.cost) do
            hasNum = cache.PackCache:getPackDataById(v1[1]).amount or 0
            if hasNum >= v1[2] then
                flag = true
            else          
                flag = false
                flag1 = true
            end  
        end
        -- print(flag1,"@@@@@@@@@@")
        local currentmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
        if currentmoney >= v.money[2] then
            if not flag then 
                flag = false
            else
                if self.data.timesMap[v.id] and (self.data.timesMap[v.id] >= v.num) then
                    flag = false
                else
                    flag = true
                   
                end    
            end
        else
            flag = false
         
        end
        if flag1 then
            flag = false
        else
        end
        if flag then
            return flag
        end
    end
    return flag
end

function Lb1003:CalRedPointById(id)
    local  conf = conf.LaBaConf2019:getExchangeById(id)
    local flag = false
  

    print("33333333",id)
    printt(conf)
    local hasNum = 0 
    for k1,v1 in pairs(conf.cost) do
        
        hasNum = cache.PackCache:getPackDataById(v1[1]).amount or 0
        if hasNum >= v1[2] then
            flag = true
        else
            flag = false
            return false
        end  
    end
  
    local currentmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
    if currentmoney >= conf.money[2] then
        if not flag then 
            flag = false
        else
            if self.data.timesMap[conf.id] and (self.data.timesMap[conf.id] >= conf.num) then
                return false
            end
            flag = true
            return flag
        end
    else
        flag = false
        return flag
    end
 
    return flag
end

return Lb1003