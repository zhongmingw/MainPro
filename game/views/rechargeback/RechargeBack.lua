--
-- Author: 
-- Date: 2018-07-19 15:02:33
--

local RechargeBack = class("RechargeBack", base.BaseView)

function RechargeBack:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function RechargeBack:initView()
    local btnclose = self.view:GetChild("n0"):GetChild("n6")
    self:setCloseBtn(btnclose)

    local btnGoCz = self.view:GetChild("n3")
    btnGoCz.onClick:Add(self.onBtnChongzhi,self)

    self.listView = self.view:GetChild("n8")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()

    self.lab = self.view:GetChild("n9")
    self.lab.text = ""
end
function RechargeBack:initData(data)
    -- body
    self.confdata = conf.ActivityConf:getCzhkItem()
    self.data = data

    self:setData()
    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"RechargeBack")
end

function RechargeBack:onTimer()
    -- body
    if not self.data then
        return 0
    end
    if cache.PlayerCache:getRedPointById(30159) - mgr.NetMgr:getServerTime() <= 0 then
        --
        GComAlter(language.kuafu106)
        self:closeView()
        return
    end
    self.data.actLeftTime = self.data.actLeftTime - 1
    self.data.actLeftTime = math.max(self.data.actLeftTime,0)
    self.lab.text = language.czhk02 .. mgr.TextMgr:getTextColorStr( GGetTimeData2(self.data.actLeftTime), 7)
end

function RechargeBack:setData(data_)
    table.sort(self.confdata,function(a,b)
        -- body
        local a_get = self.data.gotSigns[a.id] or 0
        local b_get = self.data.gotSigns[b.id] or 0

        if a_get == b_get then
            return a.id < b.id
        else
            return a_get < b_get
        end
    end)

    self.listView.numItems = #self.confdata
end


function RechargeBack:celldata( index, obj )
    -- body
    local data = self.confdata[index+1]
    --local isget = self.data.gotSigns[data.id] 
    --print("isget",isget,data.id)
    
	local isget = 1
    local txt_dec = obj:GetChild("n2")
    local str = string.format(language.czhk01,data.quota)
    str = str .."\n("
    if data.quota > self.data.czSum then
        --isget = 1
        str = str .. mgr.TextMgr:getTextColorStr(self.data.czSum, 14)
    else
        isget = 0 --可领取
        str = str .. mgr.TextMgr:getTextColorStr(self.data.czSum, 7)
    end
    str = str .. "/" .. mgr.TextMgr:getTextColorStr(data.quota, 14) .. ")"
    txt_dec.text =  str

    local listview = obj:GetChild("n4")
    listview.itemRenderer = function (_index,_obj)
        local _t = data.item[_index+1]
        local info = {}
        info.mid = _t[1]
        info.amount = _t[2]
        info.index = 0
        GSetItemData(_obj, info,true)
    end
    listview.numItems = #data.item
	
	--print("self.data.gotSigns[data.id]",self.data.gotSigns[data.id])
	if self.data.gotSigns[data.id] and self.data.gotSigns[data.id] == 1 then
        isget = 2
    end
    local c1 = obj:GetController("c1")
    c1.selectedIndex = isget

    local btnget = obj:GetChild("n5")
    btnget.data = {isget,data}  
    btnget.onClick:Add(self.ongetClick,self)
end


function RechargeBack:ongetClick(context)
    -- body
    local btn = context.sender
    local data = btn.data 
    if not data then
        return
    end
    if data[1] == 1 then
        --local str = string.format(language.czhk03,data[2].quota-self.data.czSum)
        GComAlter(language.czhk03)
        return
    end
    local param = {}
    param.reqType = 1
    param.cfgId = data[2].id
    proxy.ActivityProxy:sendMsg(1030505,param)
end

function RechargeBack:onBtnChongzhi( ... )
    -- body
    GOpenView({id = 1042})
end

function RechargeBack:addMsgCallBack(data)
    -- body

    GOpenAlert3(data.items)
    self.data.gotSigns = data.gotSigns
    self.data.actLeftTime = data.actLeftTime
    self:setData()
end

return RechargeBack