--
-- Author: 
-- Date: 2018-08-28 14:55:47
--

local XianShiLiBaoView = class("XianShiLiBaoView", base.BaseView)

function XianShiLiBaoView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianShiLiBaoView:initView()
    local btn = self.view:GetChild("n8")
    self:setCloseBtn(btn)

    self.titleicon = self.view:GetChild("n2")

    self.c1 = self.view:GetController("c1")

    local dec1 = self.view:GetChild("n8")
    dec1.text = language.buff02 
    self.labtime = self.view:GetChild("n5")

    self.labneedcz = self.view:GetChild("n6")
    self.dec1 = self.view:GetChild("n7")

    local btn = self.view:GetChild("n13")
    btn.onClick:Add(self.onBtnCallBack,self)

    self.listView = self.view:GetChild("n9")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    
    self.view:GetChild("n12").text = language.xslb02
end

function XianShiLiBaoView:celldata(index, obj)
    local data = self.condata.awards[index+1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3]
    GSetItemData(obj, t, true)
end

function XianShiLiBaoView:initData(data)
    if data then
        self:addMsgCallBack(data)
    end

    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"XianShiLiBaoView")
end

function XianShiLiBaoView:onTimer()
    -- body
    if not self.data then
        return 
    end
    if self.data.lastTime <= 0 then
        GComAlter(language.kuafu106)
        self:closeView()
        return
    end
    self.data.lastTime = self.data.lastTime - 1
    self.data.lastTime = math.max(self.data.lastTime,0)
    self.labtime.text = GGetTimeData4(self.data.lastTime)
end

function XianShiLiBaoView:onBtnCallBack(context)
    -- body
    local btn = context.sender
    local data = data 

    if self.c1.selectedIndex == 2 then
        return
    end

    if self.c1.selectedIndex == 0 then
        GOpenView({id = 1042})
    else
        proxy.ActivityProxy:sendMsg(1030515,{reqType = 1})
    end
end

function XianShiLiBaoView:addMsgCallBack( data )
    -- body
    GOpenAlert3(data.items)
    self.data = data 
    
    --多开活动id读取奖励
    self.condata = conf.ActivityConf:getMulXslb(data.id)
    --print("data.id",data.id)
    if not self.condata then
        print("协议5030515 返回的id",data.id,"在表mul_xslb 找不到")
    end
    

    self.labneedcz.text = math.floor(self.condata.quota / 10 )
    if data.flag == 1 then
        self.c1.selectedIndex = 2

        mgr.GuiMgr:redpointByVar(20203,0,1)
    else
        if self.condata.quota <= data.rechargeMoney then
            self.c1.selectedIndex = 1
            mgr.GuiMgr:redpointByVar(20203,1,1)
        else
            self.c1.selectedIndex = 0
        end
    end
    self.dec1.text = string.format(language.xslb01,self.condata.quota,self.condata.money)

    self.listView.numItems = #self.condata.awards

    local condata = conf.ActivityConf:getMulActById(data.mulActId)
    self.titleicon.url = "ui://xianshilibao/"..condata.title_icon
end

return XianShiLiBaoView