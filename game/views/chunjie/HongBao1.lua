--
-- Author: 
-- Date: 2018-01-24 17:45:18
--天降红包 

local HongBao1 = class("HongBao1",import("game.base.Ref"))

local currencyUrl = {
    [1] = "ui://zacz9sn2woxld5",--元宝
    [2] = "ui://zacz9sn2woxld6",--绑元
    [3] = "ui://zacz9sn2woxld7",--铜钱
    [4] = "ui://zacz9sn2woxld8",--绑定铜钱
}

function HongBao1:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId or 1202
    self:initPanel()
end

function HongBao1:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(self.moduleId)

    self.dec1 = panelObj:GetChild("n1")
    self.dec1.text = ""--language.chunjie01

    local dec1 = panelObj:GetChild("n2")
    dec1.text = mgr.TextMgr:getTextByTable(language.chunjie02)
    

    self.listView = panelObj:GetChild("n5")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBack,self)

    self._img = panelObj:GetChild("n6")
end

function HongBao1:celldata(index, obj)
    -- body
    if index + 1 >= self.listView.numItems then
        if self.data.page < self.data.sumPage then
            self:sendMsg(self.data.page+1)
            return
        end
    end

    local data = self.data.redBagInfos[index+1]
    local c1 = obj:GetController("c1")
    local name = obj:GetChild("n6") 
    local money = obj:GetChild("n7")
    local btn = obj:GetChild("n4")
    local icon = obj:GetChild("n8")
    local confdata = conf.ItemConf:getArgsItem(data.redBagMid)
    icon.url = currencyUrl[confdata[1][1]]
    btn.data = data
    btn.onClick:Clear()
    btn.onClick:Add(self.onget,self)

    if data.redBagStatus == 0 then
        --不可抢
        c1.selectedIndex = 1
    elseif data.redBagStatus == 1 then
        --可抢
        c1.selectedIndex = 0
    end

    local confdata = conf.ItemConf:getArgsItem(data.redBagMid)

    if confdata and #confdata > 0 then
        money.text = confdata[1][3]
    else
        money.text = ""
    end

    local str = string.split(data.name ,".")
    if #str == 2 then
        name.text = str[2]
    else
        name.text =  data.name
    end 

    obj.data = data
end

function HongBao1:onget(context)
    -- body
    context:StopPropagation()
    if not self.data then
        return
    end

    local sender = context.sender
    local data = sender.data 
    local param = {}
    param.redBagId = data.redBagId
    param.reqType = 1
    param.page = 1

    proxy.ActivityProxy:sendMsg(1030178,param)
end

function HongBao1:onCallBack(context)
    -- body
    if not self.data then
        return
    end

    local sender = context.data
    local data = sender.data 
    local param = {}
    param.redBagId = data.redBagId
    param.reqType = 1
    param.page = 1
    proxy.ActivityProxy:sendMsg(1030178,param)
end

function HongBao1:sendMsg(page)
    -- body
    local param = {}
    param.page = page or 1
    proxy.ActivityProxy:sendMsg(1030177,param)
end

function HongBao1:setData(data)
    -- body
    local str = mgr.ActivityMgr:formatTimeStr(data.actStartTime,data.actEndTime)
    self.dec1.text = mgr.TextMgr:getTextByTable(str)
    if data.msgId == 5030177 then
        if data.page == 0 then
            return
        end

        if data.page == 1 then
            self.data = {}
            self.data.page = data.page
            self.data.sumPage = data.sumPage
            self.data.actStartTime = data.actStartTime
            self.data.actEndTime = data.actEndTime
            self.data.redBagInfos = data.redBagInfos
        else
            self.data.page = data.page
            self.data.sumPage = data.sumPage
            self.data.actStartTime = data.actStartTime
            self.data.actEndTime = data.actEndTime
            for k ,v in pairs(data.redBagInfos) do
                table.insert(self.data.redBagInfos,v)
            end
        end

        self.listView.numItems = #self.data.redBagInfos
    elseif data.msgId == 5030178 then
        for k ,v in pairs(self.data.redBagInfos) do
            if v.redBagId == data.redBagInfo.redBagId then
                self.data.redBagInfos[k] = data.redBagInfo
                break
            end
        end
        self.listView:RefreshVirtualList()

        mgr.ViewMgr:openView2(ViewName.ReceiveAwardView, data)
    end

    --self._img.visible = false
    if self.listView.numItems > 0 then
        self._img.visible = false
    else
        self._img.visible = true
    end
end


return HongBao1