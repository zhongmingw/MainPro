--
-- Author: 
-- Date: 2018-01-17 15:24:03
--
--邀请码
local InviteCodePanel = class("InviteCodePanel",import("game.base.Ref"))

function InviteCodePanel:ctor(mParent,panelObj)
    self.mParent = mParent
    self.panelObj = panelObj
    self:initPanel()
end

function InviteCodePanel:initPanel()
    self.panelObj:GetChild("n5").text = language.welfare38
    self.panelObj:GetChild("n13").text = language.welfare41
    self.panelObj:GetChild("n14").text = language.welfare42

    self.inputText = self.panelObj:GetChild("n10")--绑定邀请码

    self.panelObj:GetChild("n8").text = language.welfare39
    self.inviteText = self.panelObj:GetChild("n15")--我的邀请码
    -- self.inviteText.onChanged:Add(self.onChangeInput,self)
    self.inviteText.editable = false

    self.lvListView = self.panelObj:GetChild("n11")--等级奖励
    self.lvListView:SetVirtual()
    self.lvListView.itemRenderer = function(index,obj)
        self:cellLvData(index, obj)
    end

    self.czListView = self.panelObj:GetChild("n12")--等级奖励
    self.czListView:SetVirtual()
    self.czListView.itemRenderer = function(index,obj)
        self:cellCzData(index, obj)
    end

    self.panelObj:GetChild("n21").text = language.welfare49
    self.panelObj:GetChild("n23").text = language.welfare51

    self.panelObj:GetChild("n16").text = language.welfare52
    self.panelObj:GetChild("n17").text = language.welfare53
    self.panelObj:GetChild("n18").text = language.welfare54
    self.panelObj:GetChild("n19").text = language.welfare55
    self.panelObj:GetChild("n20").text = language.welfare56
    
    self.friendFlagText = self.panelObj:GetChild("n29")--成为好友
    self.friendFlagText.text = "0/1"
    self.levFlagText = self.panelObj:GetChild("n30")--好友达到100级
    self.levFlagText.text = "0/1"
    self.zdmjFlagText = self.panelObj:GetChild("n31")--完成x次组队秘境
    self.zdmjFlagText.text = "0/1"

    local confData = conf.ActivityConf:getInviteKey(5001)
    local item = confData.item[1]
    local strTab = {
        {url = UIItemRes.moneyIcons[MoneyPro[item[1]]],width = 20,height = 18},
        {text = item[2],color = 7},
    }
    self.panelObj:GetChild("n32").text = mgr.TextMgr:getTextByTable(strTab)
    local btn = self.panelObj:GetChild("n6")
    btn.onClick:Add(self.onClickBind,self)
end

function InviteCodePanel:sendMsg()
    self.isInit = true
    proxy.ActivityProxy:send(1030311,{reqType = 1,bindInviteKey = "",page = 1})
end

function InviteCodePanel:setVisible(visible)
    self.panelObj.visible = visible
end

function InviteCodePanel:setData(data)
    local count = conf.ActivityConf:getWelfareGlobal("invite_task_cout")
    self.panelObj:GetChild("n22").text = language.welfare50..mgr.TextMgr:getTextColorStr(string.format("（%d/%d）", data.finishCount,count), 7)
    if self.isInit then
        self.friendFlagText.text = "0/1"
        self.levFlagText.text = "0/1"
        self.zdmjFlagText.text = "0/1"
    end
    if data.reqType == 2 then
        GComAlter(language.welfare46)
    end
    self.inviteKey = data.inviteKey
    self.levCount = data and data.levCount or 0
    self.inviteText.text = self.inviteKey
    self.bindInviteKey = data.bindInviteKey
    self.inputText.text = data.bindInviteKey
    self.lvConfList = conf.ActivityConf:getInviteKey(2)
    local page = data.page
    if self.mData and page and page > 1 then--分页请求玩家信息
        if data and self.mData.page < page and data.roleInfos then
            self.mData.page = page
            self.mData.pageSum = data.pageSum
            for _,v in pairs(data.roleInfos) do
                table.insert(self.mData.roleInfos, v)
            end
        end
    else
        self.mData = {}
        self.mData.page = data.page
        self.mData.pageSum = data.pageSum
        self.mData.roleInfos = data.roleInfos
    end

    local numItems = #self.mData.roleInfos
    self.lvListView.numItems = numItems
    if page == 1 and numItems > 0 then
        self.lvListView:ScrollToView(0,false,true)
    end
    self.czQuotas = {}
    for k,v in pairs(data.czQuotas) do
        table.insert(self.czQuotas, {name = k,value = v})
    end
    self.czListView.numItems = #self.czQuotas
    self.isInit = false
end

function InviteCodePanel:onChangeInput()
    if not self.inviteKey then return end
    self.inviteText.text = self.inviteKey
end
--玩家信息
function InviteCodePanel:cellLvData(index, obj)
    if index + 1 >= self.lvListView.numItems then--分页请求玩家信息
        if not self.mData.roleInfos then
            return
        end
        if self.mData.page < self.mData.pageSum then 
           proxy.ActivityProxy:send(1030311,{reqType = 1,bindInviteKey = "",page = self.mData.page + 1})
        end
    end
    local data = self.mData.roleInfos[index + 1]
    local n0 = obj:GetChild("n0")
    if index == 0 then
        n0.visible = false
    else
        n0.visible = true
    end
    obj:GetChild("n1").text = data.roleName
    obj.data = data
    obj.onClick:Add(self.onClickPlayer,self)
    if  self.isInit then
        if index == 0 then
            obj.selected = true
            self:onClickPlayer({sender = obj})
        else
            obj.selected = false
        end
    end
end
--充值奖励
function InviteCodePanel:cellCzData(index, obj)
    local n0 = obj:GetChild("n0")
    if index == 0 then
        n0.visible = false
    else
        n0.visible = true
    end
    local data = self.czQuotas[index + 1]
    if data then
        obj:GetChild("n1").text = data.name
        obj:GetChild("n2").text = language.welfare44
        obj:GetChild("n4").text = GTransFormNum(data.value)
        obj:GetChild("n5").text = language.welfare45
        obj:GetChild("n7").text = GTransFormNum(data.value * 0.3)
    end
end
--选中玩家信息
function InviteCodePanel:onClickPlayer(context)
    local sender = context.sender
    local data = sender.data
    local count = 1
    local color = 7
    local strText = "%d/%d"
    self.friendFlagText.text = mgr.TextMgr:getTextColorStr(string.format(strText, data.friendFlag,count), color)

    local color = 7
    self.levFlagText.text = mgr.TextMgr:getTextColorStr(string.format(strText, data.levFlag,count), color)

    local color = 7
    self.zdmjFlagText.text = mgr.TextMgr:getTextColorStr(string.format(strText, data.zdmjFlag,count), color)
end

function InviteCodePanel:onClickBind()
    if string.trim(self.inputText.text) == "" then
        GComAlter(language.welfare47)
        return
    end
    if self.bindInviteKey == self.inputText.text then
        GComAlter(language.welfare48)
        return
    end
    proxy.ActivityProxy:send(1030311,{reqType = 2,bindInviteKey = self.inputText.text,page = 1})
end

return InviteCodePanel