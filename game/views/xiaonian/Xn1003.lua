--
-- Author: 
-- Date: 2018-12-11 17:57:44
--

local Xn1003 = class("Xn1003",import("game.base.Ref"))

function Xn1003:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Xn1003:addMsgCallBack(data)
    -- body
    printt("小年兑换",data)
    self.data  = data
    if data.reqType == 0 then
        self:clear()
        self:setListViewData()
        if not self.btn then
            local cell = self.listView:GetChildAt(0)
            if cell then
                cell.onClick:Call()
            end
            self.listView:GetChildAt(1).onClick:Call()
        end
    elseif data.reqType == 1 then
        if self.btn then 
            self.btn.onClick:Call()
        end
         self:setListViewData()
    end
    if  data.items then
        GOpenAlert3(data.items,true)
    end  
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self.parent:addTimer(1, -1, handler(self, self.onTimer))
    end   

end

-- function Xn1003:open(context)
--     local data = context.sender.data
-- end

function Xn1003:initView()
   
    self.btn1 = self.view:GetChild("n79") --一键合成
    self.btn1.onClick:Add(self.hecheng,self)
    self.btn2 = self.view:GetChild("n80") --合成

    self.btn2.onClick:Add(self.hecheng,self)
 
    self.item = self.view:GetChild("n73")
    self.listView = self.view:GetChild("n90")


    self.hechengList = {}
    for i = 74,77 do 
        local com = self.view:GetChild("n"..i)
        table.insert(self.hechengList, com)
    end
 
    self.text01 = self.view:GetChild("n78") --合成费用
    self.text02 = self.view:GetChild("n85") --合成次数

end

function Xn1003:onChange(context)
    local data = context.sender.data
    printt(data)
    local  flag = false
    local  flag1 = false
    local canHasNum = 0
    self.listView:ClearSelection()
    -- if not self.btn then
    --     self.listView:GetChildAt(0):GetChild("n12"):GetController("button").selectedIndex = 1
    --     print("22")
    -- end
    data.objBtn.selected = true
    self.btn = data.objBtn
    local  itemData = {mid = data.info.items[1][1],amount = data.info.items[1][2],bind = 0}
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
    self.text02.text = 0
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
        table.sort(tableNum)
        canHasNum = tableNum[1] 
        self.text02.text = canHasNum..""
    end
    print(canHasNum,"canHasNum")
    if canHasNum >0 then
        self.btn1.data = {state = 2,cid = data.info.id ,times = canHasNum}
        self.btn2.data = {state = 2,cid = data.info.id ,times = 1 }
    else
        self.btn1.data = {state = 1,cid = data.info.id ,times =canHasNum }
        self.btn2.data = {state = 1,cid = data.info.id ,times = 1 }
    end 
end

function Xn1003:setListViewData()
    self.listView:ClearSelection()
    self.listView.numItems = 0
    printt(self.mSuitData)
    for k,data in pairs(self.mSuitData) do
        local url = UIPackage.GetItemURL("xiaonian" , "Button6")
        local obj = self.listView:AddItemFromPool(url)
        self:cellSuitData1(data,obj)
        if data.open == 1 then
            for k,v in pairs(data.suitData) do
                local data = v
                local url = UIPackage.GetItemURL("xiaonian" , "Button4")
                local obj = self.listView:AddItemFromPool(url)
                self:cellSuitData2(v,obj,k)
            end
        end
    end
   
end

function Xn1003:cellSuitData1(data,cell)
    cell.data = data
    cell:GetChild("red").visible = self:CalRedPoint(data.type)
    cell:GetChild("title").text = data.typename
    if data.open == 1 then
        cell:GetChild("n12").selected = true
    else
        cell:GetChild("n12").selected = false
    end
    cell.onClick:Clear()
    cell.onClick:Add(self.onClickFuseSuit,self)
end

function Xn1003:cellSuitData2(data,cell,k)
    cell.data = {info = data ,objBtn = cell}
    printt(data)
    cell:GetChild("title").text = data.name
    cell:GetChild("n6").visible = self:CalRedPointById(data.id)
    self:setRedPoint(self:CalRedPointById(data.id))
    cell.onClick:Clear()
    cell.onClick:Add(self.onChange,self)
    if k == 1 then
        cell.onClick:Call()
    end
end

function Xn1003:onClickFuseSuit(context)
    local data = context.sender.data
    if data.open == 1 then
        data.open = 0
    else
        data.open = 1
        for k,v in pairs(self.mSuitData) do
            if data.type ~= v.type then
                v.open = 0
            end
        end
    end

    self:setListViewData()
    -- if self.btn then
    --     self.btn.selected = true
    -- end
    

end



function Xn1003:hecheng(context)
    local data = context.sender.data
    if data.state == 1 then 
        GComAlter(language.labaDlhl2019_03 )
        return
    elseif data.state == 2 and data.times >0 then
        print(data.times,data.cid )
        proxy.XiaoNianProxy:send(1030705,{reqType = 1,cid = data.cid ,times = data.times})
    elseif data.state == 3 then 
        GComAlter(language.labaDlhl2019_02 )
        return
    elseif data.state == 4 then
        GComAlter(language.labaDlhl2019_04 )
    end
end

function Xn1003:onTimer()
    if not self.data then return end
    local severTime =  mgr.NetMgr:getServerTime()
    if severTime >= self.data.actEndTime then
        local  view = mgr.ViewMgr:get(ViewName.XiaoNianView)
        if view then
            view:closeView()
        end
    end
end

function Xn1003:numToStrformat(num)
    if num >= 10000 then
        return math.floor(num/10000).."万"
    else
        return num
    end
end

function Xn1003:colorText(num1,num2)

    local str = ""
    if num1 >= num2 then
   
        str = "[color=#0b8109]".. self:numToStrformat(num1).."/"..  self:numToStrformat(num2).."[/color]"
    else
        str ="[color=#da1a27]"..self:numToStrformat(num1).."[/color]".."[color=#0b8109]".."/".. self:numToStrformat(num2).."[/color]"
    end
    return str
end

function Xn1003:clear()
    self.mSuitData = {}
    self.mSuitData = conf.XiaoNianConf:getSuitFuse()
    self.btn = nil

end
function Xn1003:setRedPoint(flag)
    self.btn1:GetChild("n4").visible = flag
    self.btn2:GetChild("n4").visible = flag
end


function Xn1003:CalRedPoint(index)
    local  conf = conf.XiaoNianConf:getExchange(index)
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
        local currentmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
        if currentmoney >= v.money[2] then
            if not flag then 
                flag = false
            else
                flag = true               
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

function Xn1003:CalRedPointById(id)
    local  conf = conf.XiaoNianConf:getExchangeById(id)
    local flag = false
 
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
           
            flag = true
            return flag
        end
    else
        flag = false
        return flag
    end
 
    return flag
end
return Xn1003