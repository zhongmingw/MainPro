--
-- Author: 
-- Date: 2018-09-18 17:53:58
--

local qmbz1156 = class("qmbz1156",import("game.base.Ref"))

function qmbz1156:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function qmbz1156:onTimer()
    -- body
    if not self.data then return end
    self.data.leftTime = math.max(0,self.data.leftTime - 1) 

    if self.moduleId == self.parent.param.showId then
        self.parent:setTimeLab(self.data.leftTime)
        --计算当前时间是否到了刷新阶段
        local temp = os.date("*t", mgr.NetMgr:getServerTime()) 
        --
        local flag = false
        --print(temp.hour,self.data.time,self.steptime[1],self.steptime[2])
        if temp.hour < self.steptime[1] then
            --第1阶段
            flag = self.data.time ~= 1 
        elseif temp.hour < self.steptime[2] then
            --第2阶段
            flag = self.data.time ~= 2 
        elseif temp.hour < 24 then
            --第3阶段
            flag = self.data.time ~= 3 
        end
        if flag then
            --print("延迟1秒刷新一次UI")
            self.parent:addTimer(1, 1, function()
                -- body
                local param = {}
                param.reqType = 0
                param.cid = 0
                proxy.ActivityProxy:sendMsg(1030616,param)
            end)
        end
    end
end
function qmbz1156:addMsgCallBack(data)
    -- body
    if data.msgId == 5030616 then
        self.data = data 
        --print("5030616 ",data.time,data.curDay)

        GOpenAlert3(data.items)
        if data.reqType == 1 then
            self.listView:RefreshVirtualList()
        else
            self.confdata = conf.ActivityConf:getQmGiftByTime(data.time,data.curDay)
            table.sort(self.confdata , function(a,b)
                -- body
                return a.id < b.id 
            end)
            self.listView.numItems = #self.confdata
        end
    end
end

function qmbz1156:initView()
    -- body
    local vv = conf.ActivityConf:getQMValue("qm_snatch_time")

    self.steptime = {}
    local str = ""
    local number = #vv
    for k,v in pairs(vv) do
        str = str ..v .. language.qmbz11
        if k ~= number then
            str = str..","
        end

        table.insert(self.steptime,v)
    end
    local dec1 = self.view:GetChild("n2")
    dec1.text = string.format(language.qmbz10,str)

    self.listView = self.view:GetChild("n0")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function qmbz1156:cellData(index, obj)
    -- body
    local data = self.confdata[index+1]

    local itemobj = obj:GetChild("n8") 
    local t = {}
    t.mid = data.items[1][1]
    t.amount = data.items[1][2]
    t.bind = data.items[1][3]
    GSetItemData(itemobj, t, true)

    local dec1 = obj:GetChild("n9") 
    dec1.text = language.qmbz02

    local dec2 = obj:GetChild("n11") 
    dec2.text = data.cost

    local dec3 = obj:GetChild("n10")
    dec3.text = language.qmbz03

    local dec4 = obj:GetChild("n12")
    dec4.text = data.discount

    local dec5 = obj:GetChild("n16")
    dec5.text = language.qmbz12 .. mgr.TextMgr:getTextColorStr(tostring(self.data.personalNum[data.id]), 7)

    local dec6 = obj:GetChild("n17")
    if (data.surplus and data.surplus>0) then
        dec6.text = language.qmbz13 .. mgr.TextMgr:getTextColorStr(tostring(self.data.serverNum[data.id]), 7)
    else
        dec6.text = language.qmbz13 .. language.wangcai09
    end

    local btn = obj:GetChild("n15")
    btn.data = data
    btn.title = ""
    btn.onClick:Add(self.onCellCall,self)

    obj:GetChild("n19").text = language.qmbz05

    local c1 = obj:GetController("c1")
    c1.selectedIndex = 1

    local c2 = obj:GetController("c2")
    --print("秒杀id",data.id,self.data.personalNum[data.id],self.data.serverNum[data.id])
    if self.data.personalNum[data.id] <= 0 or (data.surplus and data.surplus>0 and self.data.serverNum[data.id] <= 0)   then
        c2.selectedIndex = 1
    else
        c2.selectedIndex = 0
    end
end


function qmbz1156:onCellCall( context )
    -- body
     if not self.data then return end
    local btn = context.sender
    local data = btn.data 
    --print("data",data)
    if (data.surplus and data.surplus>0) and (self.data.personalNum[data.id] <= 0 or self.data.serverNum[data.id] <= 0) then
        return GComAlter(language.qmbz14)
    elseif data.discount > cache.PlayerCache:getTypeMoney(MoneyType.gold) then
        return GComAlter(language.qmbz07)
    end
    local param = {}
    param.reqType = 1
    param.cid = data.id 
    proxy.ActivityProxy:sendMsg(1030616,param)
end

return qmbz1156