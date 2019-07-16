--
-- Author: 
-- Date: 2018-08-02 16:18:23
--

local RechargeSum = class("RechargeSum", base.BaseView)

function RechargeSum:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function RechargeSum:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(btnClose)

    local dec1 = self.view:GetChild("n7")
    dec1.text = language.lcth08

    local dec2 = self.view:GetChild("n8")
    dec2.text = language.lcth06

    self.labtime = self.view:GetChild("n9")
    self.labmoney = self.view:GetChild("n11")

    local btnCz = self.view:GetChild("n2")
    btnCz.onClick:Add(self.onCzCall,self)

    self.listView = self.view:GetChild("n6")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function RechargeSum:initData(data)
    -- body
    if data then
        self:addMsgCallBack(data)
    end
    if self.tiemr then
        self:removeTimer(self.tiemr)
        self.tiemr = nil 
    end
    self.tiemr = self:addTimer(1,-1,handler(self,self.onTimer))
end

function RechargeSum:onTimer( ... )
    -- body
    if not self.data then
        return
    end
    self.data.actLeftTime = math.max(self.data.actLeftTime - 1,0)
    if self.data.actLeftTime <= 0 then
        GComAlter(language.kuafu106)
        self:closeView()
        return 
    end
    
    self.labtime.text = GGetTimeData2(self.data.actLeftTime)
end

function RechargeSum:setData(data_)

end

function RechargeSum:onCzCall()
    -- body
    GOpenView({id = 1042})
end

function RechargeSum:celldata( index, obj )
    -- body
    local data = self.condata[index+1]
    local c1 = obj:GetController("c1")
    if self.data.gotSigns[data.id] then
        c1.selectedIndex = 2
    else
        if data.quota <= self.data.czSum then
            c1.selectedIndex = 1
        else
            c1.selectedIndex = 0
        end
    end
    local str = clone(language.lcth07)
    str[2].text = string.format(str[2].text,data.quota)

    local lab = obj:GetChild("n1")
    lab.text = mgr.TextMgr:getTextByTable(str)


    local listView = obj:GetChild("n2")
    listView.itemRenderer = function (_index,_obj)
        local info = data.item[_index+1]
        local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.bind = info[3]
        --t.isquan = true
        GSetItemData(_obj, t,true)
    end
    listView.numItems = #data.item

    local btnget =  obj:GetChild("n4")
    btnget.data = data 
    btnget.onClick:Add(self.onGetCall,self)
end

function RechargeSum:onGetCall(context)
    -- body
    local data = context.sender.data
    local param = {}
    param.reqType = 1
    param.cfgId = data.id
    proxy.ActivityProxy:sendMsg(1030507,param)
end

function RechargeSum:addMsgCallBack( data )
    -- body
    self.data = data 

    self.labmoney.text = data.czSum
    GOpenAlert3(data.items)


    self.condata = conf.ActivityConf:getMulLjcz(data.mulActiveId)
    table.sort( self.condata,function(a,b)
        -- body
        local a_isget = data.gotSigns[a.id] or 0
        local b_isget = data.gotSigns[b.id] or 0
        if a_isget == b_isget then
            local a_get = a.quota < data.czSum and 0 or 1
            local b_get = b.quota < data.czSum and 0 or 1

            if a_get == b_get then
                return a.id <b.id
            else
                return a_get<b_get
            end
        else
            return a_isget<b_isget
        end
    end)

    self.listView.numItems = #self.condata

    --红点清理
    local number = 0
    for k ,v in pairs(self.condata) do
        if not data.gotSigns[v.id] then
            if data.czSum>= v.quota then
                number = 1
                break
            end
        end
    end

    mgr.GuiMgr:redpointByVar(30163,number,1)
end

return RechargeSum