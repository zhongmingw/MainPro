--
-- Author: 
-- Date: 2018-08-01 21:44:37
--

local YaoQianView = class("YaoQianView", base.BaseView)

function YaoQianView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function YaoQianView:initView()
    self.titleIcon = self.view:GetChild("n1")
    local btnclose = self.view:GetChild("n0"):GetChild("n6")
    self:setCloseBtn(btnclose)

    local btnGuize = self.view:GetChild("n38")
    btnGuize.onClick:Add(self.onGuize,self)

    local btn1 = self.view:GetChild("n22")
    btn1.data = 1
    btn1.onClick:Add(self.onQiFuCall,self)

    local btn2 = self.view:GetChild("n24")
    btn2.data = 2
    btn2.onClick:Add(self.onQiFuCall,self)

    self.boxlist = {}
    for i = 42 , 47 do
        local btn = self.view:GetChild("n"..i)
        btn.onClick:Add(self.onBoxCall,self)
        table.insert(self.boxlist,btn)
    end

    self.listView = self.view:GetChild("n32")
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0

    local dec1 = self.view:GetChild("n33")
    dec1.text = language.yqs01

    local dec2 = self.view:GetChild("n35")
    dec2.text = language.yqs02 

    

    

    local dec4 = self.view:GetChild("n40")
    dec4.text =  language.yqs04

    self.labtime = self.view:GetChild("n34")
    self.labyuanbao = self.view:GetChild("n36")
    self.labcount = self.view:GetChild("n41")

    self.labcost1 = self.view:GetChild("n30")
    self.labcost2 = self.view:GetChild("n31")

    self.bar = self.view:GetChild("n5") 

end

function YaoQianView:celldata( index, obj )
    -- body
    local data = self.condata[index+1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3] or 0
    --t.isquan = true
    GSetItemData(obj, t, true)
end

function YaoQianView:initData( data )
    -- body
    if data then
        self:addMsgCallBack(data)
    end
    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"YaoQianView")
end

function YaoQianView:onTimer()
    -- body
    if not self.data then
        return
    end

    self.data.actLeftSec = math.max(self.data.actLeftSec - 1,0)
    if self.data.actLeftSec <= 0 then
        GComAlter(language.kuafu106)
        self:closeView()
        return 
    end
    self.labtime.text = GGetTimeData2(self.data.actLeftSec)
end

function YaoQianView:onGuize()
    -- body
    GOpenRuleView(1118)
end

function YaoQianView:onQiFuCall(context)
    -- body --祈福点击
    local data = context.sender.data 
    if not data then
        return
    end
    if not self.data then
        return
    end

    local param = {}
    param.reqType = data
    param.cfgId = 0
    --printt(param)    
    proxy.ActivityProxy:sendMsg(1030509,param)
end

function YaoQianView:onBoxCall( context )
    -- body --箱子点击
    local data = context.sender.data 
    if not data then
        return
    end
    if not self.data then
        return
    end
    if self.data.qfGotSigns[data.id] then
        GComAlter(language.yqs08)
        return
    end
    if self.data.qfSum < data.qf_count or cache.PlayerCache:getVipLv()< data.vip_lev then
        mgr.ViewMgr:openView2(ViewName.RewardView,data.item)
        return
    end

    -- if self.data.qfSum < data.qf_count then
    --     GComAlter(language.yqs05)
    --     return
    -- end
    -- if cache.PlayerCache:getVipLv()< data.vip_lev then
    --     GComAlter(language.yqs06)
    --     return
    -- end

    local param = {}
    param.reqType = 3
    param.cfgId = data.id
    proxy.ActivityProxy:sendMsg(1030509,param)

end

function YaoQianView:addMsgCallBack(data)
    -- body
    self.data = data 
    --print("多开id",self.data.mulActiveId)
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActiveId)
    local titleIconStr = self.mulConfData.title_icon or "yaoqian_001"
    self.titleIcon.url = UIPackage.GetItemURL("yaoqianshu" , titleIconStr)
    --前缀
    local pre = self.mulConfData.award_pre
    local dec3 = self.view:GetChild("n39")
    local tempID1 = tonumber(tostring(pre).."009")
    local tempID2 = tonumber(tostring(pre).."010")
    local condata1 = conf.ActivityConf:getMoneytreeById(tonumber(tempID1))
    local condata2 = conf.ActivityConf:getMoneytreeById(tonumber(tempID2))
    if condata1 and condata2 then
        local str = clone(language.yqs03)
        str[2].text = string.format(str[2].text,condata1.money_per,condata2.money_per)
        dec3.text =  mgr.TextMgr:getTextByTable(str) 
    else
        dec3.text = ""
    end

    self:setData()
    --调整箱子
    local number = 0
    local _v = 0
    for k , v in pairs(self.boxlist) do
        v:GetChild("n6").visible = false
        if not self.data.qfGotSigns[v.data.id] then
            v:GetController("c1").selectedIndex = 1
            if v.data.vip_lev <= cache.PlayerCache:getVipLv() and v.data.qf_count <= data.qfSum then
                number = 1
                v:GetChild("n6").visible = true
            end
        else
            v:GetController("c1").selectedIndex = 2
            
        end
    end
    --全服次数
    self.labcount.text = data.qfSum

    self.bar.value = self.max 
    for k ,v in pairs(self.valuelist) do
        if v >= data.qfSum then
            local dis = v -  (self.valuelist[k-1] or 0)
            local last = data.qfSum - (self.valuelist[k-1] or 0)
            self.bar.value = 1/6*self.max*(k-1) +  1/6*self.max * last/dis
            break
        end
    end

    

    self.labyuanbao.text = data.poolMoney

    GOpenAlert3(data.items)

    --刷新红点
    mgr.GuiMgr:redpointByVar(30166,number,1)

end


function YaoQianView:setData()
    --前缀
    local pre = self.mulConfData.award_pre
    --消耗展示
    self.labcost1.text = conf.ActivityConf:getValue("money_tree_one_cost")[2]
    self.labcost2.text = conf.ActivityConf:getValue("money_tree_ten_cost")[2]
    --箱子位置调整
    self.boxdata = conf.ActivityConf:getMoneytree(pre,2)
    table.sort( self.boxdata, function(a,b)
        -- body
        return a.qf_count < b.qf_count
    end )
    self.max = 0
    self.valuelist = {}
    for k ,v in pairs(self.boxdata) do
        self.max = self.max + v.qf_count
        table.insert(self.valuelist,v.qf_count)

        local btn = self.boxlist[k]
        btn.data = v 
        btn:GetController("c1").selectedIndex = 0
        btn:GetChild("n4").text = v.qf_count
        btn:GetChild("n3").text = string.format(language.yqs07,v.vip_lev)
    end
    self.bar.max = self.max
    --local number = 0
    -- for k ,v in pairs(self.boxdata) do
    --     local btn = self.boxlist[k]
    --     number = number + v.qf_count
    --     local x = self.bar.width * number / self.max + self.bar.x
    --     --print(x,k)
    --     btn.x = x 
    -- end
    --奖励显示
    local mulStr = "money_tree_show_"..tostring(self.data.mulActiveId)
    self.condata = conf.ActivityConf:getValue(mulStr)
    self.listView.numItems = #self.condata
end


return YaoQianView