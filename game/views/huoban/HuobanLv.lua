--
-- Author: 
-- Date: 2017-02-28 12:24:05
--

local HuobanLv = class("HuobanLv", base.BaseView)

function HuobanLv:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function HuobanLv:initData(data)
    -- body
    self.data = data
    self:addTimer(1,-1,handler(self,self.onTimer))
end

function HuobanLv:initView()
    local window4 = self.view:GetChild("n1")
    local btnClose = window4:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)


    self:initDec()
    self.value1 = self.view:GetChild("n14")

    self.list1 = self.view:GetChild("n9")
    self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list1.numItems = 0


    self.list2 = self.view:GetChild("n11")
    self.list2.itemRenderer = function(index,obj)
        self:celldata2(index, obj)
    end
    self.list2.numItems = 0

    self.xin = self.view:GetChild("n5"):GetController("c1")
    self.bar = self.view:GetChild("n3")

    self.btn = self.view:GetChild("n6")
    self.btn.onClick:Add(self.onBtnCall,self)

    self.c1 = self.view:GetController("c1")

    
end

function HuobanLv:onTimer()
    -- body
    if not self.data or not self.confData.jie_cost_sec then
        return
    end
    local var = self.confData.jie_cost_sec - (mgr.NetMgr:getServerTime() - self.data.lastUpTime+ self.data.onlineSecs)
    --local var = mgr.NetMgr:getServerTime() - self.data.lastUpTime + self.data.onlineSecs
    if var <= 0 then
        self.isUp = true
    else
        self.isUp = false
    end
end

function HuobanLv:initDec( ... )
    -- body
    local dec1 = self.view:GetChild("n7")
    dec1.text = language.huoban20

    local dec2 = self.view:GetChild("n8")
    dec2.text = language.huoban21

    local dec3 = self.view:GetChild("n10")
    dec3.text = language.huoban22

    local dec4 = self.view:GetChild("n12")
    dec4.text = language.huoban23
end

function HuobanLv:celldata(index,obj)
    -- body
    local data = self.t1[index+1]
    local lab = obj:GetChild("n1")
    lab.text = conf.RedPointConf:getProName(data[1]).." "..data[2]
end

function HuobanLv:celldata2(index,obj)
    -- body
     local data = self.t2[index+1]
    local lab = obj:GetChild("n1")
    lab.text = conf.RedPointConf:getProName(data[1]).." "..data[2]
end

function HuobanLv:setData()
    local confData = conf.HuobanConf:getDataByLv(self.data.lev,0)
    --printt(confData)

    self.t1 = GConfDataSort(confData)
    self.list1.numItems = #self.t1

    local nextconf = conf.HuobanConf:getDataByLv(self.data.lev+1,0)
    --plog("9999999999999999")
    --printt(nextconf)
    if nextconf then
        self.t2 = GConfDataSort(nextconf)
        self.list2.numItems = #self.t2
    else
        self.list2.numItems = 0
    end

    self.value1.text = string.format(language.huoban24,language.gonggong21[confData.jie] )
    self.xin.selectedIndex = confData.xing

    self.bar.value = self.data.exp
    self.bar.max = confData.cost_exp or self.data.exp

    self.confData = confData
    --plog("confData.cost_exp",confData.cost_exp,self.data.lev)
    if not nextconf then
        self.c1.selectedIndex = 1
        
    else
        if self.xin.selectedIndex == 10 then
            self.c1.selectedIndex = 2
        else
            self.c1.selectedIndex = 0
        end
       
    end
end

function HuobanLv:onBtnCall()
    -- body
    if not self.data then
        return
    end

    if self.bar.value < self.bar.max then
        GComAlter(language.huoban30)
        return
    end

    local function callback(falg)
        -- body
        proxy.HuobanProxy:send(1200102,{reqType = falg})
    end
    if self.isUp then
        callback(0)
        return
    end
    if self.confData.jie_cost_gold and self.confData.xing == 10 then
        local param = {}
        param.type = 5
        param.richtext = string.format(language.huoban25,self.confData.jie_cost_gold) 
        param.sure = function( ... )
            -- body
            callback(1)
        end
        GComAlter(param)
    else
        callback(0)
    end
end

function HuobanLv:update(data)
    -- body
    self.data = data
    self:setData()
end

function HuobanLv:onBtnClose( ... )
    -- body
    self:closeView()
end

return HuobanLv