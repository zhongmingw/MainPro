--
-- Author: 
-- Date: 2019-01-02 15:19:50
--
--登陆有礼
local Lb1001 = class("Lb1001",import("game.base.Ref"))

function Lb1001:ctor(parent,id)
    self.moduleId = id
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Lb1001:onTimer()
    -- body

    if not self.data then return end
    local severTime =  mgr.NetMgr:getServerTime()

    if severTime >= self.data.actEndTime then
        local  view = mgr.ViewMgr:get(ViewName.LaBaView2019)
        if view then
            view:closeView()
        end
    end
end

function Lb1001:addMsgCallBack( data )
    self.data = data
    self.curDay = data.curDay
    --普通用户每一天的奖励id
    self.normalId =10000+self.curDay
    local normalData = conf.LaBaConf2019:getLoginAwardById(self.normalId)
    if normalData then
        self.normalAwards = normalData.items
        self.listView1.numItems = #self.normalAwards
    end

    --Vip用户每一天的奖励id
    self.vipId = 20000+self.curDay
    local vipData = conf.LaBaConf2019:getLoginAwardById(self.vipId)
    if vipData then
        self.vipAwards = vipData.items
        self.listView2.numItems = #self.vipAwards
    end

    self.timeText.text = GToTimeString12(data.actStartTime).."-"..GToTimeString12(data.actEndTime)

    local btn1State = self.getBtn1:GetController("c1")
    local btn2State = self.getBtn2:GetController("c1")
    --普通奖励获得按钮只有可领取和已领取两种状态
    if data.normalAwardSign == 0 then --可领取
        btn1State.selectedIndex=0
        self.getBtn1.title = language.friend22
    else--已领取
        btn1State.selectedIndex= 2
        self.getBtn1.title = language.yqs08
    end

    --vip奖励获得按钮
    if data.vipAwardSign == 0 then--未领取
        local vipLv =cache.PlayerCache:getVipLv()
        local needVipLv = conf.LaBaConf2019:getValue("lb_login_award_vip_level")
        self.getBtn2.title = language.friend22
        if needVipLv>vipLv then--不可领取
            btn2State.selectedIndex=1
        else--可领取
            btn2State.selectedIndex=0
        end
    else--已领取
        btn2State.selectedIndex = 2
        self.getBtn2.title = language.yqs08
    end

    self.getBtn1.data = {state = btn1State.selectedIndex,reqType = 1}
    self.getBtn2.data = {state = btn2State.selectedIndex,reqType = 2}
    self.getBtn1.onClick:Add(self.onClickGet,self)
    self.getBtn2.onClick:Add(self.onClickGet,self)
     if not self.actTimer then
        self:onTimer()
        self.actTimer = self.parent:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function Lb1001:initView()
    -- body
    self.panel = self.view:GetChild("n7")
    self.timeText = self.view:GetChild("n4")
    self.decText = self.view:GetChild("n6")
    self.decText.text = language.labaDlhl2019_01
    -- --今日登陆奖励列表
    self.listView1 = self.panel:GetChild("n15")

    self.listView1.numItems = 0
    self.listView1.itemRenderer = function (index, obj)
        self:cell1data(index, obj)
    end
    self.listView1:SetVirtual()
    self.getBtn1 = self.panel:GetChild("n13")

    --Vip3登陆奖励列表
    self.listView2 = self.panel:GetChild("n22")
    self.listView2.numItems = 0
    self.listView2.itemRenderer = function (index,obj)
        self:cell2data(index, obj)
    end
    self.listView2:SetVirtual()
    self.getBtn2 = self.panel:GetChild("n21")
end

function Lb1001:onClickGet( context )
    local data = context.sender.data
    local reqType = data.reqType
    proxy.GuoQingProxy:sendMsg(1030688,{reqType = reqType})

end

function Lb1001:cell1data( index,obj )
    -- body
    local data =self.normalAwards[index+1]
    if data then
        local itemInfo = {mid =data[1],amount =data[2],bind =data[3]}
        GSetItemData(obj, itemInfo, true)
    end
end

function Lb1001:cell2data(index, obj)
    local data = self.vipAwards[index+1]
    if data then
        local itemInfo = {mid =data[1],amount =data[2],bind =data[3]}
        GSetItemData(obj, itemInfo, true)
    end
end

return Lb1001