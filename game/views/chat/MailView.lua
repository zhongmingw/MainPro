--
-- Author:ohf 
-- Date: 2017-01-19 14:40:55
--
--邮件界面
local MailView = class("MailView", base.BaseView)

function MailView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function MailView:initData(data)
    self:setData(data)
end

function MailView:initView()
    local text1 = self.view:GetChild("n1")
    text1.text = language.mail01

    self.playerName = self.view:GetChild("n2")

    local listView = self.view:GetChild("n18")
    self.mailListView = listView
    self.msgText = listView:GetChildAt(0):GetChild("n0")
    local listView = self.view:GetChild("n19")
    self.mailListView2 = listView
    self.msgText2 = listView:GetChildAt(0):GetChild("n0")

    self.listView = self.view:GetChild("n11")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellItemData(index, obj)
    end

    self.timeText = self.view:GetChild("n13")
    self.timeText.text = ""
    local receiveBtn = self.view:GetChild("n12")
    self.receiveBtn = receiveBtn
    receiveBtn.onClick:Add(self.onClickReceive,self)

    self.alreayImg = self.view:GetChild("n14")--已领取
    self.alreayImg.visible = false
    self.fjImg1 = self.view:GetChild("n15")
    self.fjImg1.visible = false
    self.fjImg2 = self.view:GetChild("n16")
    self.fjImg2.visible = false

    local window4 = self.view:GetChild("n0")
    local closeBtn = window4:GetChild("n2")
    self:setCloseBtn(closeBtn)
end

function MailView:setData(data)
    self.mData = data
    -- printt(data)
    self.playerName.text = data.mailFrom or ""

    self.msgText.text = data.contentStr
    self.msgText2.text = data.contentStr
    local numItems = #data.items
    self.receiveBtn.visible = true
    self.alreayImg.visible = false
    if numItems <= 0 then
        self.fjImg1.visible = false
        self.fjImg2.visible = false
        self.receiveBtn.visible = false
        self.alreayImg.visible = false
        self.view:GetChild("n9").visible = false
        self.view:GetChild("n6").visible = false
        self.view:GetChild("n7").visible = false
        self.timeText.y = 540
        self.mailListView.visible = false
        self.mailListView2.visible = true
    else
        self.fjImg1.visible = true
        self.fjImg2.visible = true
        self.timeText.y = 337
        self.mailListView2.visible = false
        self.mailListView.visible = true
    end 
    if data.mState == 1 and numItems > 0 then
        self.receiveBtn.visible = false
        self.alreayImg.visible = true
    end
    self.listView.numItems = numItems

    local timeTab = os.date("*t",data.createTime)
    local month = self:getTimeText(timeTab.month)
    local day = self:getTimeText(timeTab.day)
    local hour = self:getTimeText(timeTab.hour)
    local min = self:getTimeText(timeTab.min)
    self.timeText.text = timeTab.year.."-"..month.."-"..day.." "..hour..":"..min
end

function MailView:getTimeText(time)
    if time < 10 then
        return "0"..time
    else
        return time
    end
end
--附件
function MailView:cellItemData(index,cell)
    local data = self.mData.items[index + 1]
    local itemObj = cell:GetChild("n2")
    data.index = 0
    data.isRealMid = true
    GSetItemData(itemObj,data,true)
end

function MailView:onClickReceive()
    if self.mData.mState == 1 then
        GComAlter(language.mail05)
        return
    end
    proxy.ChatProxy:send(1080102,{reqType = 1,mailId = self.mData.mailId})
    cache.ChatCache:setLinquFujian(true)
    self:closeView()
end

return MailView