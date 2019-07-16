--
-- Author: Your Name
-- Date: 2018-09-18 14:32:34
--登录有礼
local Dz1001 = class("Dz1001",import("game.base.Ref"))

function Dz1001:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Dz1001:onTimer()
    -- body
    if not self.data then return end

end

-- 变量名：reqType 说明：0：显示 1：领取普通奖励 2：领取vip奖励
-- 变量名：normalAwardSign 说明：普通奖励领取标识
-- 变量名：vipAwardSign    说明：vip奖励领取标识
-- array<SimpleItemInfo>   变量名：items   说明：奖励
-- 变量名：curDay  说明：当前第几天 从1开始
-- 变量名：actStartTime    说明：活动开始时间
-- 变量名：actEndTime  说明：活动结束时间
function Dz1001:addMsgCallBack(data)
    -- body
    printt("登录有礼",data)
    self.curDay = data.curDay
    self.normallId = 10000+self.curDay
    local normallData = conf.DongZhiConf:getLoginAwardById(self.normallId)
    if normallData then
        self.normallAwards = normallData.items
        self.listView1.numItems = #self.normallAwards
    end
    self.czId = 20000+self.curDay
    local czData = conf.DongZhiConf:getLoginAwardById(self.czId)
    if czData then
        self.czAwards = czData.items
        self.listView2.numItems = #self.czAwards
    end

    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)

    local btn1State = self.getBtn1:GetController("c1")
    local btn2State = self.getBtn2:GetController("c1")
    if data.loginSign == 0 then--可领取
        btn1State.selectedIndex = 0
        self.getBtn1.title = language.friend22
        self.getBtn1:GetChild("red").visible = true
    else--已领取
        btn1State.selectedIndex = 2
        self.getBtn1.title = language.yqs08
    end

    if data.rechargeSign == 0 then--未领取
        self.getBtn2.title = language.kaifu14
        if data.rechargeSum <= 0 then--不可领取
            btn2State.selectedIndex = 1
        else--可领取
            btn2State.selectedIndex = 0
            self.getBtn2.title = language.friend22
            self.getBtn2:GetChild("red").visible = true
        end
    else--已领取
        btn2State.selectedIndex = 2
        self.getBtn2.title = language.yqs08
    end

    self.getBtn1.data = {state = btn1State.selectedIndex,reqType = 1}
    self.getBtn2.data = {state = btn2State.selectedIndex,reqType = 2}
    self.getBtn1.onClick:Add(self.onClickGet,self)
    self.getBtn2.onClick:Add(self.onClickGet,self)

end

function Dz1001:onClickGet(context)
    local data = context.sender.data
    local state = data.state
    local reqType = data.reqType
    if state == 1 then
         GGoVipTequan(0) 
         self.parent:closeView()
        -- GComAlter(language.sse13)
        return
    elseif state == 2 then
        GComAlter(language.czccl07)
    end
    proxy.GuoQingProxy:sendMsg(1030663,{reqType = reqType})
end

function Dz1001:initView()
    -- body

    

    self.timeTxt = self.view:GetChild("n3")
    self.decTxt = self.view:GetChild("n4")
    self.decTxt.text = language.dz01
    --今日登录奖励列表
    self.listView1 = self.view:GetChild("n9")
    self.listView1.numItems = 0
    self.listView1.itemRenderer = function (index,obj)
        self:cell1data(index, obj)
    end
    self.listView1:SetVirtual()
    self.getBtn1 = self.view:GetChild("n10")

    --V3登录奖励列表
    self.listView2 = self.view:GetChild("n16")
    self.listView2.numItems = 0
    self.listView2.itemRenderer = function (index,obj)
        self:cell2data(index, obj)
    end
    self.listView2:SetVirtual()
    self.getBtn2 = self.view:GetChild("n17")

end

function Dz1001:cell1data( index,obj )
    local data = self.normallAwards[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,itemInfo,true)
    end
end

function Dz1001:cell2data( index,obj )
    local data = self.czAwards[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,itemInfo,true)
    end
end

return Dz1001