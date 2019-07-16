local Zq1006 = class("Zq1006",import("game.base.Ref"))

function Zq1006:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Zq1006:onTimer()
    -- body
    if not self.data then return end
end
function Zq1006:addMsgCallBack(data)
   if data.msgId == 5030608 then
        self.rednum = 0
        self.data = data 
        self.dec1.text = "活动时间："..GToTimeString11(self.data.actStartTime).."~"..GToTimeString11(self.data.actEndTime)
        printt(self.data)
        self.confdataitem = {}
        for k,v in pairs(self.confdata) do
           if v.day == self.data.curDay then
                table.insert(self.confdataitem, v)
            end
        end
        table.sort(self.confdataitem,function(a,b)
            return a.id < b.id 
        end)
        self.dec7.text = string.format(language.zq08,self.confdataitem[2].quota)
        self.listView1.numItems = #self.confdataitem[1].items
        self.listView2.numItems = #self.confdataitem[2].items
        self.dec4.text = tostring(data.czSums)
        self.dec5.text = tostring(self.confdataitem[2].quota or 0 )
        if  data.firstRechargeSign == 1 then --首充领取
            self.btn1:GetController("c1").selectedIndex = 1
            self.btn1.title = "已领取"
        else
            if data.czSums > 0 then
                self.btn1:GetController("c1").selectedIndex = 0
                self.btn1.title = "领取"
                self.btn1:GetChild("red").visible = true
                self.rednum = self.rednum +1
            else
                self.btn1:GetController("c1").selectedIndex = 1
                self.btn1.title = "领取"
            end
        end
        if  data.accumulateRecharge == 1 then --累充领取
            self.btn2:GetController("c1").selectedIndex = 1
            self.btn2.title = "已领取"
        else
            if data.czSums >= self.confdataitem[2].quota then
                self.btn2:GetController("c1").selectedIndex = 0
                self.btn2.title = "领取"
                self.btn2:GetChild("red").visible = true
                self.rednum = self.rednum +1
            else
                self.btn2:GetController("c1").selectedIndex = 1
                self.btn2.title = "领取"
            end
        end
        mgr.GuiMgr:redpointByVar(30208,self.rednum,1)
    end
end

function Zq1006:initView()
    local c1 = self.view:GetController("c1")
    c1.selectedIndex = 1 
    self.dec1 = self.view:GetChild("n3")

    self.dec7 = self.view:GetChild("n4")

    self.confdata = conf.ZhongQiuConf:getChongZhiHaoLi()
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

    self.dec4 = self.view:GetChild("n28")
    self.dec5 = self.view:GetChild("n24")
end

function Zq1006:onGet1(context)
    if self.btn1:GetController("c1").selectedIndex == 0 then
       proxy.ZhongqiuProxy:sendMsg(1030608,{reqType = 1})
    elseif self.btn1:GetController("c1").selectedIndex == 1 then
        if self.data.czSums > 0 then
            GComAlter("无法重复领取奖励") 
        else
             GComAlter("条件不足，无法领取") 
        end
    end
end

function Zq1006:onGet2(context)
    local data = context.sender.data
    if self.btn2:GetController("c1").selectedIndex == 0 then
        proxy.ZhongqiuProxy:sendMsg(1030608,{reqType = 2})
    elseif self.btn2:GetController("c1").selectedIndex == 1 then
        if self.data.czSums >= self.confdataitem[2].quota then
            GComAlter("无法重复领取奖励") 
        else
            GComAlter("条件不足，无法领取") 
        end
       
    end
end

function Zq1006:cellData1(index ,obj)
    local data = self.confdataitem[1].items[index + 1] 
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj, itemData, true)
end

function Zq1006:cellData2(index ,obj)
    local data = self.confdataitem[2].items[index + 1] 
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj, itemData, true)
end
return Zq1006