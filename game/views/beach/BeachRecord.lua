--
-- Author: 
-- Date: 2018-01-03 17:44:10
--

local BeachRecord = class("BeachRecord", base.BaseView)

function BeachRecord:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function BeachRecord:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    local btn1 = self.view:GetChild("n9")
    btn1.title = language.beach23
    local btn1 = self.view:GetChild("n10")
    btn1.title = language.beach24

    local dec1 = self.view:GetChild("n11")
    dec1.text = language.beach10
    self.dec2 = self.view:GetChild("n12")
    self.dec2.text = language.beach25
    local dec1 = self.view:GetChild("n13")
    dec1.text = language.beach26

    self.listView = self.view:GetChild("n4")
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0

    self.dec1 = self.view:GetChild("n5")
    self.dec1.text = ""

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
end

function BeachRecord:initData()
    -- body
    self.c1.selectedIndex = 0
    self:onController1()
end

function BeachRecord:cellData(index, obj)
    -- body
    local data 
    if self.c1.selectedIndex == 0 then
        data = self.data.recvGiftRecords[index+1]
    else
        data = self.data.presentGiftRecords[index+1]
    end

    local _name = obj:GetChild("n1")
    local _count = obj:GetChild("n2")
    _name.text = data.name
    _count.text = data.count

    local btnSong = obj:GetChild("n3")
    btnSong.data = data
    btnSong.onClick:Clear()
    btnSong.onClick:Add(self.onCaozuo,self)
end

function BeachRecord:onCaozuo(context)
    -- body
    if not self.data then
        return
    end
    if self.data.leftPresentCount <= 0 then
        GComAlter(language.beach28)
        return
    end 
    local data = context.sender.data
    if not data then
        return
    end
    if data.roleId == cache.PlayerCache:getRoleId() then
        GComAlter(language.beach29)
        return
    end

    mgr.ViewMgr:openView2(ViewName.BeachSong, data)
end

function BeachRecord:onController1()
    -- body
    local param = {}
    param.roleId = 0
    param.cid = 0
    if self.c1.selectedIndex == 0 then
        param.reqType = 3
    else
        param.reqType = 2
    end
    proxy.BeachProxy:sendMsg(1020423,param)
end

function BeachRecord:setData(data_)

end

function BeachRecord:addMsgCallBack(data)
    -- body
    if data.msgId == 5020423 then
        self.data = data
        if self.c1.selectedIndex == 0 then
            self.listView.numItems = #self.data.recvGiftRecords
            self.dec2.text = language.beach32
        else
            self.listView.numItems = #self.data.presentGiftRecords
            self.dec2.text = language.beach25
        end

        local str = clone(language.beach27)
        str[2].text = string.format( str[2].text,self.data.leftPresentCount)
        --self.dec1.text = mgr.TextMgr:getTextByTable(str)
        
    end
end

return BeachRecord