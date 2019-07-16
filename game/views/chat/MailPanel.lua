--
-- Author: 
-- Date: 2017-01-18 20:04:04
--
--邮件panel
local MailPanel = class("MailPanel",import("game.base.Ref"))

function MailPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
    self.oldItemNum = 0--记录原来的邮件数量
end

function MailPanel:initPanel()
    self.listView = self.mParent.view:GetChild("n48")--表情列表
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellMailData(index, obj)
    end
    self.listView.onClickItem:Add(self.onMailClickCall,self)
end
--刷新数据
function MailPanel:setData(data)
    self.unReadNum = 0
    self.readNum = 0--已读的邮件
    local page = data.page
    if self.mData and page and page > 1 then
        if data and self.mData.page < page and data.mails then
            self.mData.page = page
            self.mData.maxPage = data.maxPage
            for _,v in pairs(data.mails) do
                table.insert(self.mData.mails, v)
            end
        end
    else
        self.mData = {}
        self.mData.page = data.page
        self.mData.maxPage = data.maxPage
        self.mData.mails = data.mails
    end
    local numItems = #self.mData.mails
    self.listView.numItems = numItems
    if page == 1 and numItems > 0 then
        self.listView:ScrollToView(0,false,true)
    end
end
--领取邮件--1:领取,2一键领取附件邮件,3删除单个,4一键删除已读
function MailPanel:receiveMail(data)
    self.unReadNum = 0
    local reqType = data.reqType
    local indexList = {}--记录要一键删除的邮件
    if not self.mData then return end
    for k,v in pairs(self.mData.mails) do
        --1:领取,2一键领取附件邮件,3删除单个,4一键删除已读
        if reqType == 1 then
            if v.mailId == data.mailId then
                self.mData.mails[k].mState = 1
            end
        elseif reqType == 2 then
            self.mData.mails[k].mState = 1
        elseif reqType == 3 then
            if v.mailId == data.mailId then
                table.remove(self.mData.mails,k)
                break
            end
        elseif reqType == 4 then
            if self.mData.mails[k].mState == 1 then
                table.insert(indexList,k)
            end
        end
    end
    --从后面删除
    if reqType == 4 then
        table.sort(indexList,function(a,b)
            return a>b
        end)
        for _,v in pairs(indexList) do
            table.remove(self.mData.mails,v)
        end
    end
    --刷新
    local numItems = #self.mData.mails
    self.listView.numItems = numItems
end

function MailPanel:cellMailData(index,cell)
    if index + 1 >= self.listView.numItems then
        if not self.mData.mails then
            return
        end
        if self.mData.page < self.mData.maxPage then 
           proxy.ChatProxy:send(1080101,{page = self.mData.page + 1})
        end
    end
    local data = self.mData.mails[index + 1]
    self:setCellData(data,cell)
end

function MailPanel:getPage()
    return self.mData and self.mData.page or 0
end
--设置item数据
function MailPanel:setCellData(data,cell)
    cell.data = data
    local icon = cell:GetChild("n3")
    local enclosure = cell:GetChild("n1")--附件
    local enclosureText = cell:GetChild("n5")--附件描述
    local mState = data.mState--状态(已读,未读)
    enclosure.visible = false
    if mState == 0 then
        icon.url = UIItemRes.mailType[1]
        enclosureText.text = language.gonggong04
        self.unReadNum = self.unReadNum + 1
        if data.items and #data.items > 0 then
            enclosure.visible = true
            enclosureText.text = language.mailEnclosure
        end
    else
        self.readNum = self.readNum + 1
        icon.url = UIItemRes.mailType[2]
        enclosureText.text = language.gonggong03
    end
    local titleText = cell:GetChild("n4")
    titleText.text = data.titleStr
    local timeText = cell:GetChild("n2")

    local time = GGetTimeData(data.lastTime).day
    timeText.text = string.format(language.mailMailDec, time)
end

function MailPanel:onMailClickCall(context)
    local cell = context.data
    local data = cell.data
    if data.items and #data.items <= 0 or not data.items then
        proxy.ChatProxy:send(1080102,{reqType = 1,mailId = data.mailId})
    end
    mgr.ViewMgr:openView(ViewName.MailView,nil,data)
end
--邮件数量
function MailPanel:getMailNum()
    return self.listView.numItems
end
--未读邮件数量
function MailPanel:getUnreadNum()
    return self.unReadNum
end
--已读邮件数量
function MailPanel:getReadNum()
    return self.readNum
end

return MailPanel