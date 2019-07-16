--
-- Author: 
-- Date: 2018-07-28 16:26:11
--

local JuHuaSuanView = class("JuHuaSuanView", base.BaseView)

function JuHuaSuanView:ctor()
    JuHuaSuanView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function JuHuaSuanView:initView()
    --关闭Button
    local  closeBtn = self.view:GetChild("n55")
    self:setCloseBtn(closeBtn)
    --closeBtn.onClick:Add(self.onBtnClose,self)
    self.view:GetChild("n23").text = mgr.TextMgr:getTextByTable(language.jhs02) 
    self.view:GetChild("n24").text = language.jhs01
    self.view:GetChild("n27").text = language.jhs03
    self.lastTime = self.view:GetChild("n26")
    self.labgettime = self.view:GetChild("n29") 
    self.titleIcon = self.view:GetChild("n59")
    --全部购买奖励
    --self.rewardlist = conf.ActivityConf:getHolidayGlobal("jhs_big_gift")
    self.listView = self.view:GetChild("n57")
    self.listView.itemRenderer = function ( index,obj)
        self:celldata(index,obj)
    end
    self.listView.numItems = 0
    --购买列表
   -- self.awardItem = conf.ActivityConf:getJuHuaSuan()--配置
    self.listView2 = self.view:GetChild("n10")
    self.listView2.itemRenderer = function ( index,obj)
        self:cellbuydata(index,obj)
    end
    self.listView2.numItems = 0
    --领取按钮
    local btn = self.view:GetChild("n50") 
    self.c1 = btn:GetController("c1")
    self.c1.selectedIndex = 1
    btn.onClick:Add(self.onAllget,self)
    --全部购买
    local btnAllbuy = self.view:GetChild("n54") 
    btnAllbuy.onClick:Add(self.onAllbuy,self)
end

function JuHuaSuanView:initData(data)
    -- body
    GOpenAlert3(data.items)
    self.data = data 
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "junhuasuan_001"
    self.titleIcon.url = UIPackage.GetItemURL("juhuasuan" , titleIconStr)
    self.awardItem = conf.ActivityConf:getJuHuaSuanAwardById(self.data.mulActId)--配置
    self.isBuylist = {}
    for k ,v in pairs(data.bugItemData) do
        self.isBuylist[v] = 1
    end
    --可领取次数
    self.labgettime.text = self.data.gotTimes
    self.rewardlist = conf.ActivityConf:getJuHuaSuanGiftAwardById(self.data.mulActId)
    if self.data.gotTimes >= 1 then
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
    end
    --可购买列表
    table.sort(self.awardItem,function(a,b)
        -- body
        local a_isBuy = self.isBuylist[a.id] or 0
        local b_isBuy = self.isBuylist[b.id] or 0
        if a_isBuy == b_isBuy then
            return a.id < b.id
        else
            return a_isBuy < b_isBuy
        end
    end)
     --全部购买价格
    local number = 0
    for k ,v in pairs(self.awardItem) do
        if not self.isBuylist[v.id] then 
            number = number + v.price
        end
    end
    self.view:GetChild("n41").text = tostring(number)
    self.listView2.numItems = #self.awardItem
    self.listView.numItems = #self.rewardlist
    if self.actTimer then
        self:removeTimer(self.actTimer)
    end
    self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    mgr.GuiMgr:redpointByVar(20196,self.data.gotTimes,1)
end


function JuHuaSuanView:onTimer()
    if not self.data then return end
    self.data.lastTime = math.max(self.data.lastTime - 1 , 0 ) 
    if self.data.lastTime <= 0 then
        self:closeView()
        return
    end
    self.lastTime.text = GGetTimeData2(self.data.lastTime)
end

function JuHuaSuanView:celldata( index,obj )
    -- body 
    local data = self.rewardlist[index + 1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3]
    GSetItemData(obj,t,true)
end

function JuHuaSuanView:cellbuydata( index,obj )
    -- body
    local data = self.awardItem[index + 1] 
    local t = {}
    t.mid = data.item[1]
    t.amount = data.item[2]
    t.bind = data.item[3] 
    local itemObj = obj:GetChild("n16")
    GSetItemData(itemObj,t,true)
    -- local c1 = obj:GetController("c1")
    -- c1.selectedIndex = data.buy_type - 1
    local lab = obj:GetChild("n2") 
    lab.text = mgr.TextMgr:getQualityStr1(conf.ItemConf:getName(t.mid),conf.ItemConf:getQuality(t.mid))..
    mgr.TextMgr:getQualityStr1("*",conf.ItemConf:getQuality(t.mid))..
    mgr.TextMgr:getQualityStr1(t.amount,conf.ItemConf:getQuality(t.mid))
    local money = obj:GetChild("n11")
    money.text = data.price
    local btn = obj:GetChild("n23") 
    btn.data = data
    btn.onClick:Add(self.onbuyCall,self)
    local c2 = obj:GetController("c2")
    if self.isBuylist[data.id] then
        c2.selectedIndex = 1
    else
        c2.selectedIndex = 0
    end
end


function JuHuaSuanView:onbuyCall( context )
    -- body
    if not self.data then
        return
    end
    local data = context.sender.data 
    if not data then
        return
    end
    local param = {}
    param.reqType = 1
    param.cid = data.id 
    proxy.ActivityProxy:sendMsg(1030228,param)
end

function JuHuaSuanView:onAllget()
    -- bod
    if not self.data then
        return
    end
    if self.data.gotTimes == 0 then
        return GComAlter(language.jhs04)
    end
    local param = {}
    param.reqType = 2
    param.cid = 0
    proxy.ActivityProxy:sendMsg(1030228,param)
end


function JuHuaSuanView:onAllbuy()
    -- body
    local param = {}
    param.reqType = 3
    param.cid = 0
    proxy.ActivityProxy:sendMsg(1030228,param)
end


return JuHuaSuanView