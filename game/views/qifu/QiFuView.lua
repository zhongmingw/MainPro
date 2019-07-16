--
-- Author: 
-- Date: 2018-09-03 20:05:01
--
local pairs = pairs

local QiFuView = class("QiFuView", base.BaseView)

function QiFuView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
    self.openTween = ViewOpenTween.scale
    self.isBlack = true 
end

function QiFuView:initView()
    local btn = self.view:GetChild("n22")
    self:setCloseBtn(btn)

    local btn0 = self.view:GetChild("n20")
    btn0.onClick:Add(self.onBtnCallBack,self)
    local btn1 = self.view:GetChild("n12")
    btn1.title = string.format(language.qflq01,1)
    btn1.data = 1
    btn1.onClick:Add(self.onBtnCallBack,self)
    local btn2 = self.view:GetChild("n16")
    btn2.title = string.format(language.qflq01,10)
    btn2.data = 2
    btn2.onClick:Add(self.onBtnCallBack,self)

    local dec1 = self.view:GetChild("n31")
    dec1.text = language.qflq04
    self.btnbox = {}
    for i = 24 , 29 do 
        local btn = self.view:GetChild("n"..i)
        btn.visible = false
        btn.onClick:Add(self.onBtnCallBack,self)
        table.insert(self.btnbox,btn)
    end

    local dec1 = self.view:GetChild("n13")
    dec1.text = language.qflq02 
    local dec1 = self.view:GetChild("n19")
    dec1.text = language.qflq02 
    self.cost1 = self.view:GetChild("n15")
    self.cost2 = self.view:GetChild("n19")

    local dec1 = self.view:GetChild("n30")
    dec1.text = language.qflq03 
    self.bar = self.view:GetChild("n8")
    self.curlab = self.bar:GetChild("n4")

    local dec1 = self.view:GetChild("n32")
    dec1.text = language.qflq05 
    self.money = self.view:GetChild("n38")

    self.dec1 = self.view:GetChild("n33")
    --self.dec1.text = string.format(language.qflq06,20)
    self.labtime = self.view:GetChild("n34")
    self.labcount = self.view:GetChild("n35")

    self.listView = self.view:GetChild("n21")
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    self.listView.numItems = 0
end

function QiFuView:initData(data)
    -- body
    if data then
        self:addMsgCallBack(data)
    end
    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"QiFuView")
end

function QiFuView:onTimer()
    -- body
    if not self.data then
        return
    end
    self.data.actLeftSec = self.data.actLeftSec - 1
    self.data.actLeftSec = math.max(self.data.actLeftSec,0)
    if self.data.actLeftSec <= 0 then
        self:closeView()
        return
    end
    self.labtime.text = string.format(language.qflq07,GGetTimeData2(self.data.actLeftSec))
end

function QiFuView:cellBaseData( index, obj )
    -- body
    local data = self.condata.awards[index+1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3] or 0

    GSetItemData(obj, t, true)
end

function QiFuView:addMsgCallBack( data )
    -- body
    GOpenAlert3(data.items)
    self.data = data 
    --祈福消耗
    local confcost = conf.ActivityConf:getlqqfCost(data.mulActiveId)
    print("多开活动 id data.mulActiveId = ",data.mulActiveId)
    for k,v in pairs(confcost) do
        local lab = self["cost"..k]
        if lab then
            lab.text = v.cost[2]
        end
    end
    --进度
    local _ = conf.ActivityConf:getMulActById(data.mulActiveId)
    self.boxcondata = conf.ActivityConf:getlqqf(_.award_pre,2)
    local max = 0
    local number = 0

    table.sort(self.boxcondata,function(a,b)
        -- body
        return a.qf_count < b.qf_count
    end)
    self.valuelist = {}
    for k , v in pairs(self.boxcondata) do
        max = math.max(v.qf_count,max) 
        self.btnbox[k].data = v
        self.btnbox[k].visible = true
        self.btnbox[k]:GetChild("n4").text = string.format(language.qflq10,v.qf_count)
        self.btnbox[k]:GetChild("n2").text = v.vip_lev
        local flag = v.vip_lev <= cache.PlayerCache:getVipLv() and v.qf_count <= data.qfSum
        self.btnbox[k]:GetChild("n3").visible = not flag
        local c1 = self.btnbox[k]:GetController("c1")
        if self.data.qfGotSigns[v.id] then
            c1.selectedIndex = 0
        else
            c1.selectedIndex = 1
            if flag then
                number = 1
            end
        end

        table.insert(self.valuelist,v.qf_count)
    end 

    self.bar.value = max 
    for k ,v in pairs(self.valuelist) do
        if v >= data.qfSum then
            local dis = v -  (self.valuelist[k-1] or 0)
            local last = data.qfSum - (self.valuelist[k-1] or 0)
            self.bar.value = 1/6*max*(k-1) +  1/6*max * last/dis
            break
        end
    end

    --self.bar.value = data.qfSum --
    self.bar.max = max
    self.curlab.text = string.format(language.qflq09,data.qfSum)
   
    --祈福次数
    self.labcount.text = string.format(language.qflq08,data.qfSum)
    
    --祈福奖励
    self.condata = conf.ActivityConf:getMulactiveshow(data.mulActiveId)
    self.listView.numItems = (self.condata and self.condata.awards) and  #self.condata.awards or 0

    --累计元宝
    self.money.text = data.poolMoney

    self.dec1.text = string.format(language.qflq06,20)

    mgr.GuiMgr:redpointByVar(30179,number,1)
end

function QiFuView:onBtnCallBack(context)
    local btn = context.sender
    local data = btn.data 

    if "n20" == btn.name then
        GOpenRuleView(1136)
    elseif "n12" == btn.name or "n16" == btn.name then
        local param = {}
        param.reqType = data 
        param.cfgId = 0
        proxy.ActivityProxy:sendMsg(1030520,param)
    else
        if self.data.qfGotSigns[data.id] then
            GComAlter(language.yqs08)
            return
        end
        if self.data.qfSum < data.qf_count or cache.PlayerCache:getVipLv()< data.vip_lev then
            local seetable = {c1 = 1,item = data.item}
            mgr.ViewMgr:openView2(ViewName.RewardView,seetable)
            return
        end
        local param = {}
        param.reqType = 3
        param.cfgId = data.id
        proxy.ActivityProxy:sendMsg(1030520,param)
    end
end

return QiFuView