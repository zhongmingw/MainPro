--
-- Author: 
-- Date: 2018-01-24 17:43:29
--春节活动 登录豪礼

local LoginAward = class("LoginAward",import("game.base.Ref"))

function LoginAward:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId or 1201
    self:initPanel()
end

function LoginAward:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(self.moduleId)

    self.dec1 = panelObj:GetChild("n1")
    self.dec1.text = "" --mgr.TextMgr:getTextByTable(language.chunjie01) 

    local dec1 = panelObj:GetChild("n2")
    dec1.text = mgr.TextMgr:getTextByTable(language.chunjie04)

    self.listView = panelObj:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

end

function LoginAward:celldata( index, obj )
    -- body
    local data = self.data.itemGotDatas[index+1]
    local _layday = obj:GetChild("n9")
    local c1 = obj:GetController("c1")
    local btn = obj:GetChild("n7")
    btn.data = data
    btn.onClick:Add(self.onget,self)

    local confdata = conf.ActivityConf:getLoginAwardById(data.cid)
    local listView = obj:GetChild("n8")
    listView.itemRenderer = function(_index,_obj)
        local _t = confdata.awards[_index+1]
        local pp = {mid = _t[1],amount = _t[2],bind = _t[3]}
        GSetItemData(_obj,pp,true)
    end
    listView.numItems = confdata and #confdata.awards or 0


    local temp = os.date("*t", data.time)

    _layday.text = temp.month .. language.gonggong79 ..temp.day .. language.gonggong80 

    if 0 == data.gotStatus then
        --不可领取
        c1.selectedIndex = 0
    elseif 1 == data.gotStatus then
        --已领取
        c1.selectedIndex = 2
    elseif 2 == data.gotStatus then
        --错过
        c1.selectedIndex = 3
    elseif 3 == data.gotStatus then
        --可领取
        c1.selectedIndex = 1
    end
end

function LoginAward:sendMsg()
    -- body
    local param = {}
    param.actId = 3047
    param.reqType = 1
    param.cid = 0
    proxy.ActivityProxy:sendMsg(1030175,param)
end

function LoginAward:onget( context )
    -- body
    local sender = context.sender
    local data = sender.data
    if data.gotStatus == 3 then
        local param = {}
        param.actId = 3047
        param.reqType = 2
        param.cid = data.cid
        --printt("sendMsg 1030175",param)
        proxy.ActivityProxy:sendMsg(1030175,param)
    end
end

function LoginAward:setData(data)
    -- body
    if data.msgId ~= 5030175 then
        return
    end
    self.data = data
    if data.reqType == 2 then
        GOpenAlert3(data.items)
    end
    table.sort(self.data.itemGotDatas,function(a,b)
        -- body
        return a.time < b.time
    end)

    self.listView.numItems = #self.data.itemGotDatas

    local str = mgr.ActivityMgr:formatTimeStr(data.actStartTime,data.actEndTime)
    self.dec1.text = mgr.TextMgr:getTextByTable(str)

    --红点检测
    local flag = false
    for k ,v in pairs(data.itemGotDatas) do
        if v.gotStatus == 3 then
            flag = true
            break
        end
    end
    if not flag then
        mgr.GuiMgr:redpointByVar(attConst.A20162,0,1)
    end
end


return LoginAward