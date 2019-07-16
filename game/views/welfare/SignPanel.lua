--
-- Author: ohf
-- Date: 2017-03-27 12:03:22
--
--签到区域
local SignPanel = class("SignPanel",import("game.base.Ref"))

function SignPanel:ctor(mParent,panelObj)
    self.panelObj = panelObj
    self.mParent = mParent
    self:initPanel()
end

function SignPanel:initPanel()
    self.confSumSign = conf.ActivityConf:getSumSignAward()--本月签到累计
    self.confSign = conf.ActivityConf:getSignAward()--每天签到奖励
    self.iconList = {}
    for i=8,12 do--icon
        local icon = self.panelObj:GetChild("n"..i)
        icon.onClick:Add(self.onClickGet,self)
        table.insert(self.iconList, icon)
    end

    self.arleayImgList = {}
    for i=20,24 do
        local arleay = self.panelObj:GetChild("n"..i)
        arleay.visible = false
        table.insert(self.arleayImgList, arleay)
    end

    self.redImgList = {}
    for i=26,30 do
        local red = self.panelObj:GetChild("n"..i)
        table.insert(self.redImgList, red)
    end

    self.signText = self.panelObj:GetChild("n25")
    self.signText.text = ""

    self.listView = self.panelObj:GetChild("n19")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    -- self.listView.onClickItem:Add(self.onClickItem,self)
end

function SignPanel:sendMsg()
    self.listView.numItems = 0
    proxy.ActivityProxy:send(1030103,{reqType = 0,awardId = 0})
end

function SignPanel:setData(data)
    self.mData = data
    local signTimes = data and data.signTimes or 0
    self.signText.text = signTimes
    for k,v in pairs(self.confSumSign) do
        local id = v.id
        self.iconList[id].url = UIPackage.GetItemURL("_others" , v.icon)
        self.iconList[id].data = v
        local isGet = self:isDayAwardGot(id)
        self.redImgList[id].visible = false
        if isGet then
            self.iconList[id].grayed = true
        else
            self.iconList[id].grayed = false
            if signTimes >= v.sign_day then
                self.redImgList[id].visible = true
            end
        end
        self.arleayImgList[id].visible = isGet
    end
    local index = 1
    for k,v in pairs(self.confSign) do
        local dayCzFlag = self.mData and self.mData.dayCzFlag or 0
        local curSignDay = self.mData and self.mData.curSignDay or 0
        if v.id >= curSignDay then
            index = v.id
            break
        end
    end
    local temp = index % 5
    if temp == 0 then
        index = index - 1
    end
    index = index - (index % 5) - 1
    if index <= 0 then
        index = 0
    end
    self.listView.numItems = #self.confSign
    self.listView:ScrollToView(index)
end

function SignPanel:cellData(index,cell)
    local data = self.confSign[index + 1]
    cell.data = {data = data,index = 0}
    local text = cell:GetChild("n2")
    local id = data.id
    text.text = id.."天"
    local arleayPanel = cell:GetChild("n3")
    local arleayImg = cell:GetChild("n4")
    local redBtn = cell:GetChild("n5")
    local panel1 = cell:GetChild("n0")
    local panel2 = cell:GetChild("n6")

    panel1.visible = true
    panel2.visible = false
    redBtn.visible = false
    redBtn.data = {data = data,index = 0}
    redBtn.onClick:Add(self.onClickBlSign,self)
    local redTitle = redBtn:GetChild("title")
    local itemObj = cell:GetChild("n1")

    local lightCirclesControl = itemObj:GetController("c1")
    -- lightCirclesControl.selectedIndex = 0 

    local awards = data.awards
    local itemData = {mid = awards[1][1],amount = awards[1][2],bind = awards[1][3]}
    local dayCzFlag = self.mData and self.mData.dayCzFlag or 0
    local curSignDay = self.mData and self.mData.curSignDay or 0
    if self:isAwardGot(id) then 
        arleayPanel.visible = true
        arleayImg.visible = true
        if dayCzFlag == 0 and id == curSignDay then--未充值
            redBtn.visible = true
            redBtn.data.index = 3--充值再领
            redTitle.text = language.gonggong33 
            GSetItemData(itemObj, itemData)
            lightCirclesControl.selectedIndex = 0
        elseif dayCzFlag == 2 and id == curSignDay then
            redBtn.visible = true
            redBtn.data.index = 3--充值再领
            redTitle.text = language.welfare04 --可领取
            GSetItemData(itemObj, itemData)
            lightCirclesControl.selectedIndex = 1
        else
            GSetItemData(itemObj, itemData)
            lightCirclesControl.selectedIndex = 0
        end
        -- GSetItemData(itemObj, itemData)
        -- lightCirclesControl.selectedIndex = 0
    else
        arleayPanel.visible = false
        arleayImg.visible = false
        if id < curSignDay then
            arleayPanel.visible = true
            redBtn.visible = true
            redBtn.data.index = 4--补领
            redTitle.text = language.gonggong34
            GSetItemData(itemObj, itemData)
            lightCirclesControl.selectedIndex = 0
        else
            if id == curSignDay then
                panel2.visible = true             
                cell.data.index = 1
                GSetItemData(itemObj, itemData)
                lightCirclesControl.selectedIndex = 1
            else
                cell.data.index = 0
                panel1.visible = true
                panel2.visible = false             
                GSetItemData(itemObj, itemData, true)
                lightCirclesControl.selectedIndex = 0
            end
        end
    end

    cell.onClick:Add(self.onClickItem,self)
end

function SignPanel:onClickItem(context)
    local cell = context.sender
    local data = cell.data.data
    local index = cell.data.index
    if not self:isAwardGot(data.id) and index == 1 then
        proxy.ActivityProxy:send(1030103,{reqType = 1,awardId = data.id})
        cell.data.index = 0
    end
end
--本月已签到列表
function SignPanel:isAwardGot(id)
    local signAwardList = self.mData and self.mData.signAwardList or {}
    for k,v in pairs(signAwardList) do
        if v and v == id then
            return true
        end
    end
end
--本月已签到总数奖励已领取列表
function SignPanel:isDayAwardGot(id)
    local signDayAwardList = self.mData and self.mData.signDayAwardList or {}
    for k,v in pairs(signDayAwardList) do
        if v and v == id then
            return true
        end
    end
end

function SignPanel:setVisible(visible)
    self.panelObj.visible = visible
    self.visible = visible
end

function SignPanel:onClickGet(context)
    local cell = context.sender
    local data = cell.data
    if not data then return end
    if not self:isDayAwardGot(data.id) then
        local signTimes = self.mData and self.mData.signTimes or 0
        if signTimes < data.sign_day then
            GComAlter({type = 11,awards = data.awards})
        else
            proxy.ActivityProxy:send(1030103,{reqType = 2,awardId = data.id})
        end
    else
        GComAlter(language.welfare08)
    end
end
--充值再领 or 补领
function SignPanel:onClickBlSign(context)
    local cell = context.sender
    local data = cell.data
    local reqType = data.index
    local money = conf.SysConf:getValue("fill_in_sign_cost")
    if reqType == 4 then
        local text = string.format(language.welfare09, money)
        local param = {type = 9,richtext = mgr.TextMgr:getTextColorStr(text, 11),sure = function()
            proxy.ActivityProxy:send(1030103,{reqType = reqType,awardId = data.data.id})
        end}
        GComAlter(param)
    else
        proxy.ActivityProxy:send(1030103,{reqType = reqType,awardId = data.data.id})
    end
end

return SignPanel