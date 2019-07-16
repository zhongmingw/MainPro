local Dz1004 = class("Dz1004",import("game.base.Ref"))

function Dz1004:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Dz1004:onTimer()
    -- body
    if not self.data then return end

end


function Dz1004:addMsgCallBack(data)
    -- body
    printt("兑换",data)
    if data.items then
        GOpenAlert3(data.items,true)
    end
    self.timeTxt.text = "活动时间："..GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)
     self.listView1.numItems = #self.confData
end

function Dz1004:onClickGet(context)
    self.parent:closeView()
    GOpenView({id = 1049})
end

function Dz1004:initView()
    -- body
 
    

    self.timeTxt = self.view:GetChild("n3")
    self.decTxt = self.view:GetChild("n4")
    self.decTxt.text = language.dz02

    --列表
    self.listView1 = self.view:GetChild("n34")
    self.listView1.numItems = 0
    self.listView1.itemRenderer = function (index,obj)
        self:cell1data(index, obj)
    end
    self.listView1:SetVirtual()
    self.confData = conf.DongZhiConf:getDuiHuanData()
end

function Dz1004:cell1data( index,obj )
    local data = self.confData[index+1]
    local item1 = obj:GetChild("n25")
    local item2 = obj:GetChild("n31")
    local item3 = obj:GetChild("n32")
    local item4 = obj:GetChild("n33")
    local btn = obj:GetChild("n29")
    local num = #data.cost
 
 
     local itemInfo4 = {mid = data.items[1][1],amount = data.items[1][2],bind = 1}
    GSetItemData(item4:GetChild("n25"),itemInfo4,true)
    local c1 = obj:GetController("c1")
    if num == 1 then
        c1.selectedIndex = 0

             --材料
            local itemInfo1 = {mid = data.cost[1][1],amount = 1,bind = 1}
            GSetItemData(item1:GetChild("n25"),itemInfo1,true)
          
            local num1,num2 = 0,0
            num2 = data.cost[1][2]
          

            local Packdata = cache.PackCache:getPackData()
            for k,v in pairs(Packdata) do
                if v.mid == data.cost[1][1] then
                    num1 = v.amount
                end
             
            end 
            item1:GetChild("n30").text = num1 >= num2 and mgr.TextMgr:getTextColorStr(num1.."/"..num2,10) or mgr.TextMgr:getTextColorStr(num1.."/"..num2,14)

            local controller = btn:GetController("c1")
            if num1>= num2 then
                controller.selectedIndex = 0
            else
                controller.selectedIndex = 1
            end
            if controller.selectedIndex == 0 then
                btn:GetChild("red").visible = true
            end
            btn.data = {state = controller.selectedIndex,cid = data.id}
            btn.onClick:Add(self.onClickGet,self)
        
       
    elseif num == 2 then
         c1.selectedIndex = 1
           --材料
        local itemInfo1 = {mid = data.cost[1][1],amount = 1,bind = 1}
        GSetItemData(item1:GetChild("n25"),itemInfo1,true)
        local itemInfo2 = {mid = data.cost[2][1],amount = 1,bind = 1}
        GSetItemData(item2:GetChild("n25"),itemInfo2,true)
     
        local num1,num2,num3,num4 = 0,0,0,0,0,0
        num2 = data.cost[1][2]
        num4 = data.cost[2][2]
   

        local Packdata = cache.PackCache:getPackData()
        for k,v in pairs(Packdata) do
            if v.mid == data.cost[1][1] then
                num1 = v.amount
            end
            if v.mid == data.cost[2][1] then
                num3 = v.amount
            end
     
        end 
        item1:GetChild("n30").text = num1 >= num2 and mgr.TextMgr:getTextColorStr(num1.."/"..num2,10) or mgr.TextMgr:getTextColorStr(num1.."/"..num2,14)
        item2:GetChild("n30").text = num3 >= num4 and mgr.TextMgr:getTextColorStr(num3.."/"..num4,10) or mgr.TextMgr:getTextColorStr(num3.."/"..num4,14)
  
        local controller = btn:GetController("c1")
        if num1>= num2 and num3 >= num4  then
            controller.selectedIndex = 0
        else
            controller.selectedIndex = 1
        end
          if controller.selectedIndex == 0 then
                btn:GetChild("red").visible = true
            end
        btn.data = {state = controller.selectedIndex,cid = data.id}
        btn.onClick:Add(self.onClickGet,self)
    elseif num == 3 then
         c1.selectedIndex = 2

           --材料
        local itemInfo1 = {mid = data.cost[1][1],amount = 1,bind = 1}
        GSetItemData(item1:GetChild("n25"),itemInfo1,true)
        local itemInfo2 = {mid = data.cost[2][1],amount = 1,bind = 1}
        GSetItemData(item2:GetChild("n25"),itemInfo2,true)
        local itemInfo3 = {mid = data.cost[3][1],amount = 1,bind = 1}
        GSetItemData(item3:GetChild("n25"),itemInfo3,true)

        local num1,num2,num3,num4,num5,num6 = 0,0,0,0,0,0
        num2 = data.cost[1][2]
        num4 = data.cost[2][2]
         num6 = data.cost[3][2]

        local Packdata = cache.PackCache:getPackData()
        for k,v in pairs(Packdata) do
            if v.mid == data.cost[1][1] then
                num1 = v.amount
            end
            if v.mid == data.cost[2][1] then
                num3 = v.amount
            end
             if v.mid == data.cost[3][1] then
                num5 = v.amount
            end
     
        end 
        item1:GetChild("n30").text = num1 >= num2 and mgr.TextMgr:getTextColorStr(num1.."/"..num2,10) or mgr.TextMgr:getTextColorStr(num1.."/"..num2,14)
        item2:GetChild("n30").text = num3 >= num4 and mgr.TextMgr:getTextColorStr(num3.."/"..num4,10) or mgr.TextMgr:getTextColorStr(num3.."/"..num4,14)
         item3:GetChild("n30").text = num5 >= num6 and mgr.TextMgr:getTextColorStr(num5.."/"..num6,10) or mgr.TextMgr:getTextColorStr(num5.."/"..num6,14)
        local controller = btn:GetController("c1")
        if num1>= num2 and num3 >= num4 and num5 >= num6  then
            controller.selectedIndex = 0
        else
            controller.selectedIndex = 1
        end
          if controller.selectedIndex == 0 then
                btn:GetChild("red").visible = true
            end
        btn.data = {state = controller.selectedIndex,cid = data.id}
        btn.onClick:Add(self.onClickGet,self)
    end
    
end

function Dz1004:onClickGet(context)
    local data = context.sender.data
    if data.state == 1 then
        GComAlter(language.dz03)
    else
        print(data.cid)
        proxy.DongZhiProxy:send(1030665,{reqType=1 ,cid = data.cid})
    end
end

return Dz1004