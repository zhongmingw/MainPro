local Zq1005 = class("Zq1005",import("game.base.Ref"))

function Zq1005:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Zq1005:onTimer()
    -- body
    if not self.data then return end
end
function Zq1005:addMsgCallBack(data)
    if data.msgId == 5030609 then
        printt(data)
        GOpenAlert3(data.items)
        self.data = data 
        self.dec1.text = "活动时间："..GToTimeString11(self.data.actStartTime).."~"..GToTimeString11(self.data.actEndTime)
        print(self.data.actStartTime,self.data.actEndTime)
        self.confdataitem = {}
        for k,v in pairs(self.confdata) do
           if v.day == self.data.curDay then
            table.insert(self.confdataitem, v)
            end
        end
        table.sort(self.confdataitem,function(a,b)
        return a.id < b.id 
        end)
        self.listView1.numItems = #self.confdataitem[1].items 
        self.listView2.numItems = #self.confdataitem[2].items 
        self.btn1.title = "领取"
        self.btn2.title = "领取"
        if self.data.normalAwardSign == 1 then --普通领取
            self.btn1:GetController("c1").selectedIndex = 1 
            self.btn1.title = "已领取"
        else
            self.btn1:GetController("c1").selectedIndex = 0
            self.btn1:GetChild("red").visible = true
        end

        if self.data.vipAwardSign == 1 then --vip领取
             self.btn2:GetController("c1").selectedIndex = 1 
             self.btn2.title = "已领取"
        else
            if (cache.PlayerCache:getVipLv() >= 3) and (self.data.vipAwardSign == 0)then
                self.btn2:GetController("c1").selectedIndex = 0 
                self.btn2:GetChild("red").visible = true
            else
                self.btn2:GetController("c1").selectedIndex = 1 
            end  
        end
    end
end

function Zq1005:initView()
    self.dec1 = self.view:GetChild("n3")
    local dec2 = self.view:GetChild("n4")
    dec2.text = language.zq01
    self.confdata = conf.ZhongQiuConf:getLoginAward()
    table.sort(self.confdata,function(a,b)
        return a.id < b.id 
    end)

    self.listView1 = self.view:GetChild("n9")
    self.listView1.itemRenderer = function(index,obj)
        self:cellData1(index, obj)
    end
   
    self.listView2 = self.view:GetChild("n16")
    self.listView2.itemRenderer = function(index,obj)
        self:cellData2(index, obj)
    end
    
    self.btn1 = self.view:GetChild("n10")
    self.btn1.title = "领取"
    self.btn1.onClick:Add(self.onGet1,self)

    self.btn2 = self.view:GetChild("n17")
    self.btn2.title = "领取"
    self.btn2.onClick:Add(self.onGet2,self)
end

function Zq1005:onGet1(context)
    if self.btn1:GetController("c1").selectedIndex == 0 then
       proxy.ZhongqiuProxy:sendMsg(1030609,{reqType = 1})
    else
        GComAlter("无法重复领取") 
    end
end

function Zq1005:onGet2(context)
    local data = context.sender.data
    if self.btn2:GetController("c1").selectedIndex == 0 then
       proxy.ZhongqiuProxy:sendMsg(1030609,{reqType = 2})
    elseif self.btn2:GetController("c1").selectedIndex == 1 then
        if self.data.vipAwardSign == 1 then
            GComAlter("无法重复领取") 
        else
            GComAlter("条件不足，无法领取") 
        end
    end
end

function Zq1005:cellData1(index ,obj)
    local data = self.confdataitem[1].items[index + 1] 
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj, itemData, true)
end

function Zq1005:cellData2(index ,obj)
    local data = self.confdataitem[2].items[index + 1] 
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj, itemData, true)
end

return Zq1005