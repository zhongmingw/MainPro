--
-- Author: 
-- Date: 2019-01-08 11:20:57
--
--登陆领奖
local Bx1003 = class("Bx1003",import("game.base.Ref"))

function Bx1003:ctor(parent,id)
    self.moduleId = id
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Bx1003:onTimer()
    -- body

    if not self.data then return end
    local severTime =  mgr.NetMgr:getServerTime()

    if severTime >= self.data.actEndTime then
        local  view = mgr.ViewMgr:get(ViewName.BingXueMainView)
        if view then
            view:closeView()
        end
    end
end

function Bx1003:addMsgCallBack( data )
    self.data = data
    self.curDay = data.curDay
    --普通用户每一天的奖励id
    self.normalId =10000+self.curDay
    print("当前天数:"..self.curDay)
    local normalData = conf.BingXueConf:getLoginAwardById(self.normalId)
    if normalData then
        self.normalAwards = normalData.items
        self.listView1.numItems = #self.normalAwards
    end

    --多充每一天的奖励id
    self.otherId = 20000+self.curDay
    local otherData = conf.BingXueConf:getLoginAwardById(self.otherId)
    if otherData then
        self.otherAwards = otherData.items
        self.listView2.numItems = #self.otherAwards
    end

    self.timeText.text = GToTimeString12(data.actStartTime).."-"..GToTimeString12(data.actEndTime)

    local btn1State = self.getBtn1:GetController("c1")
    local btn2State = self.getBtn2:GetController("c1")
    --普通奖励获得按钮只有可领取和已领取两种状态
    if data.loginSign == 0 then --可领取
        btn1State.selectedIndex=0
        self.getBtn1.title = language.friend22
        self.getBtn1:GetChild("red").visible = true
    else--已领取
        btn1State.selectedIndex= 2
        self.getBtn1:GetChild("red").visible = false
        --self.getBtn1.title = language.yqs08
    end

    --多充奖励获得按钮
    if data.rechargeSign == 0 then--未领取
        local czSum = self.data.rechargeSum or 0
        self.getBtn2.title = language.friend22
        if czSum == 0 then--不可领取
            btn2State.selectedIndex = 0
            self.getBtn2.title = "充值"
            self.getBtn2:GetChild("red").visible = false
        else--可领取
            btn2State.selectedIndex = 0
            self.getBtn2.title = language.friend22
            self.getBtn2:GetChild("red").visible = true
        end
    else--已领取
        self.getBtn1:GetChild("red").visible = false
        btn2State.selectedIndex = 2
        --self.getBtn2.title = language.yqs08
    end

    self.getBtn1.data = {state = btn1State.selectedIndex,reqType = 1,title =self.getBtn1.title}
    self.getBtn2.data = {state = btn2State.selectedIndex,reqType = 2,title =self.getBtn2.title}
    if btn1State.selectedIndex == 0 then
        self.getBtn1.onClick:Add(self.onClickGet,self)
    else
        self.getBtn1:RemoveEventListeners()
    end

    if btn2State.selectedIndex == 0 then
        self.getBtn2.onClick:Add(self.onClickGet,self)
    else
        self.getBtn2:RemoveEventListeners()
    end
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self.parent:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function Bx1003:onClickGet( context )
    local data = context.sender.data
    local reqType = data.reqType
    if data.title == "充值" then
        GGoVipTequan(0)  --充值
        local  view = mgr.ViewMgr:get(ViewName.BingXueMainView)
        if view then
            view:closeView()
        end
    else
        proxy.BingXueProxy:sendMsg(1030698,{reqType = reqType})
    end
    
    

end

function Bx1003:initView()
    -- body
    self.panel = self.view:GetChild("n8")
    self.timeText = self.view:GetChild("n4")
    self.decText = self.view:GetChild("n2")
    self.decText.text = language.bxDllj01
    -- --今日登陆奖励列表
    self.listView1 = self.panel:GetChild("n9")

    self.listView1.numItems = 0
    self.listView1.itemRenderer = function (index, obj)
        self:cell1data(index, obj)
    end
    self.listView1:SetVirtual()
    self.getBtn1 = self.panel:GetChild("n10")

    --多充奖励列表
    self.listView2 = self.panel:GetChild("n16")
    self.listView2.numItems = 0
    self.listView2.itemRenderer = function (index,obj)
        self:cell2data(index, obj)
    end
    self.listView2:SetVirtual()
    self.getBtn2 = self.panel:GetChild("n17")

end

function Bx1003:cell1data( index,obj )
    -- body
    local data =self.normalAwards[index+1]
    if data then
        local itemInfo = {mid =data[1],amount =data[2],bind =data[3]}
        GSetItemData(obj, itemInfo, true)
    end
end

function Bx1003:cell2data(index, obj)
    local data = self.otherAwards[index+1]
    if data then
        local itemInfo = {mid =data[1],amount =data[2],bind =data[3]}
        GSetItemData(obj, itemInfo, true)
    end
end

return Bx1003