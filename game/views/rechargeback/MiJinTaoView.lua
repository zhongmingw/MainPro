--
-- Author: 
-- Date: 2018-08-14 20:06:19
--

local MiJinTaoView = class("MiJinTaoView", base.BaseView)

function MiJinTaoView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function MiJinTaoView:initView()
    local btn = self.view:GetChild("n0"):GetChild("n6")
    self:setCloseBtn(btn)

    local btnguize = self.view:GetChild("n42")
    btnguize.onClick:Add(self.onBtnCallBack,self)

    local btn1 = self.view:GetChild("n12")
    btn1.data = 1
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn2 = self.view:GetChild("n18")
    btn2.data = 10
    btn2.onClick:Add(self.onBtnCallBack,self)

    local btn3 = self.view:GetChild("n23")
    btn3.data = 50
    btn3.onClick:Add(self.onBtnCallBack,self)

    self.labtimer = self.view:GetChild("n8")
    self.labtimer.text = ""

    self.labtimer1 = self.view:GetChild("n32")
    self.labtimer1.text = ""

    self.listView = self.view:GetChild("n9")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()

    self.itemlist = {}
    for i = 33 , 41 do
        local btn = self.view:GetChild("n"..i)
        GSetItemData(btn,{})
        table.insert(self.itemlist,btn)
    end

    self.costlist = {}
    for i = 1 , 3 do
        local lab = self.view:GetChild("cost"..i)
        lab.text = ""
        table.insert(self.costlist,lab)
    end

    self.lastlab = self.view:GetChild("n31")
    self.lastlab.text = ""

    --self:setData()
end

function MiJinTaoView:setData(id)
    -- body

    --设置奖励
    local condata = conf.ActivityConf:getMulactiveshow(id)
    if condata and condata.awards then
        for k ,v in pairs(condata.awards) do
            local btn = self.itemlist[k]
            if not btn then
                break
            end
            local t = {}
            t.mid = v[1]
            t.amount = v[2]
            t.bind = v[3]
            GSetItemData(btn,t,true)
        end
    else
        print("多开活动id = ",id,"找不到奖励配置 mul_active_show")
    end
end

function MiJinTaoView:initData(data)
    if data then
        self:addMsgCallBack(data)
    end

    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"MiJinTaoView")
end

function MiJinTaoView:onTimer()
    -- body
    if not self.data then
        return 
    end
    if self.data.lastTime <= 0 then
        self.labtimer1.text = ""
        self.labtimer.text = ""
        GComAlter(language.kuafu106)
        self:closeView()
        return
    end
    self.data.lastTime = self.data.lastTime - 1
    self.data.lastTime = math.max(self.data.lastTime,0)
    self.labtimer.text = language.czhk02 .. mgr.TextMgr:getTextColorStr( GGetTimeData2(self.data.lastTime), 10)

    if self.data.leftFreeTimes > 0 then
        self.costlist[1].text = language.mjxb03
        self.labtimer1.text = ""--string.format(language.mjxb03,self.data.leftFreeTimes)
    else
        local passtime = mgr.NetMgr:getServerTime() - self.data.lastUpdateTime
        local needtime = conf.ActivityConf:getHolidayGlobal("mjxb_free_time_refresh")[2] -  passtime

        if needtime <= 0 then
            self.labtimer1.text = ""

            if not self.requst then
                self.requst = true
                --print("ActivityProxy 1030239")
                proxy.ActivityProxy:sendMsg(1030239,{reqType = 0,times = 0})
            end
        else
            self.labtimer1.text = GTotimeString(needtime) .. language.mjxb01 
        end
    end
end

function MiJinTaoView:celldata(index, obj)
    -- body
    local data = self.data.records[index+1]
    local lab1 = obj:GetChild("n1")

    local liststr = string.split(data,"|")
    local str = mgr.TextMgr:getTextColorStr(liststr[1], 4) .. language.mjxb02
    --print("liststr[3]",liststr[3])
    str = str ..mgr.TextMgr:getColorNameByMid(liststr[2]).. mgr.TextMgr:getQualityStr1("x"..(liststr[3] or 1),conf.ItemConf:getQuality(liststr[2])) 

    lab1.text = str 
end

function MiJinTaoView:onBtnCallBack(context)
    -- body
    if not self.data then return end
    local btn = context.sender
    if "n42" == btn.name then
        GOpenRuleView(1129)--规则
    elseif "n12" == btn.name or "n18" == btn.name or "n23" == btn.name then
        local param = {}
        param.reqType = 1
        param.times = btn.data 
        --printt("1030239 ",param)
        proxy.ActivityProxy:sendMsg(1030239,param)
    end 
end

function MiJinTaoView:addMsgCallBack( data )
    -- body
    self.requst = nil 
    self.data = data 
    self.listView.numItems = #data.records
    self.lastlab.text = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    GOpenAlert3(data.items)

    self:setData(data.mulActId)
    

    --设置消耗
    --print("data.mulActId",data.mulActId)
    local confcost = conf.ActivityConf:getMjxbCost(data.mulActId)
    for k , v in pairs(confcost) do
        local lab = self.costlist[k]
        if lab then
            lab.text = v.cost[2]
        end
    end
    if self.data.leftFreeTimes > 0 then
        self.costlist[1].text = language.mjxb03
    end
    --红点刷新
    mgr.GuiMgr:redpointByVar(20190,data.leftFreeTimes,1)
end

return MiJinTaoView