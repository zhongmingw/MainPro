--
-- Author: 
-- Date: 2018-01-24 17:46:17
--全服红包


local HongBao2 = class("HongBao2",import("game.base.Ref"))

function HongBao2:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId or 1201
    self:initPanel()
end

function HongBao2:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(self.moduleId)

    self.dec1 = panelObj:GetChild("n5")
    self.dec1.text = ""--language.chunjie01

    local dec1 = panelObj:GetChild("n6")
    dec1.text = mgr.TextMgr:getTextByTable(language.chunjie03) 

    self.count = panelObj:GetChild("n3")

    self.listView = panelObj:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0


end

function HongBao2:celldata(index, obj)
    -- body
    local data = self.condata[index+1]
    local c1 = obj:GetController("c1")

    local btn = obj:GetChild("n9")
    btn.data = data
    btn.onClick:Clear()
    btn.onClick:Add(self.onSee,self)

    local lab = obj:GetChild("n6")
    lab.text = data.redbag_count

    local btn = obj:GetChild("n2")
    btn.data = data
    btn.onClick:Clear()
    btn.onClick:Add(self.onGet,self)

    local statue = self.data.redBadStatus[data.id]
    if not statue then
        statue = 0
    end
    if 0 == statue then
        --未达标 
        c1.selectedIndex = 0
    elseif 1 == statue then
        --可领取 
        c1.selectedIndex = 1
    elseif 2 == statue then
        --已领取
        c1.selectedIndex = 2
    end

end

function HongBao2:onSee( context )
    -- body
    local sender = context.sender
    local data = sender.data 
    mgr.ViewMgr:openView2(ViewName.ChunjieRewardTips, data)
end

function HongBao2:onGet( context )
    -- body
    local sender = context.sender
    local data = sender.data 

    local param = {}
    param.reqType = 2
    param.cid = data.id
    proxy.ActivityProxy:sendMsg(1030176,param)
end

function HongBao2:sendMsg()
    -- body
    local param = {}
    param.reqType = 1
    param.cid = 0
    proxy.ActivityProxy:sendMsg(1030176,param)
end

function HongBao2:setData(data)
    -- body
    if data.msgId ~= 5030176 then
        return
    end
    local str = mgr.ActivityMgr:formatTimeStr(data.actStartTime,data.actEndTime)
    self.dec1.text = mgr.TextMgr:getTextByTable(str)

    self.data = data
    if data.reqType == 2 then
        GOpenAlert3(data.items)
        self.listView:RefreshVirtualList()
    end

    self.count.text = data.curRedBagCount

    self.condata = conf.ActivityConf:getChunjieAllRed()
    self.listView.numItems = #self.condata

    --红点检测
    local flag = false
    for k ,v in pairs(data.redBadStatus) do
        if v == 1 then
            flag = true
            break
        end
    end
    if not flag then
        mgr.GuiMgr:redpointByVar(attConst.A20164,0,1)
    end
end


return HongBao2