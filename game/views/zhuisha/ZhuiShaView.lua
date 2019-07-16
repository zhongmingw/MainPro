--
-- Author: Your Name
-- Date: 2018-07-12 17:49:41
--

local ZhuiShaView = class("ZhuiShaView", base.BaseView)

function ZhuiShaView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ZhuiShaView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)

    self.listView = self.view:GetChild("n1")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()

    --追杀按钮
    self.zhuishaBtn = self.view:GetChild("n9")
    self.zhuishaBtn.onClick:Add(self.onClickZhuiSha,self)
    --搜索按钮
    self.searchBtn = self.view:GetChild("n5")
    self.searchBtn.onClick:Add(self.onClickSearch,self)

    self.dec1 = self.view:GetChild("n15")
    self.dec1.text = language.friend60
    self.dec2 = self.view:GetChild("n16")
    self.dec2.text = language.friend59
end

function ZhuiShaView:onClickSearch()
    local text = self.view:GetChild("n4").text
    print("搜索>>>>>>>>>",text)
    if text == "" then
        self.listdata = {}
        self.totalSum = 1
        self.page = 1
        self.selectedData = nil
        self.dec1.visible = true
        self.dec2.visible = false
        self.listView.numItems = #self.listdata
        self.c1.selectedIndex = 2
    else
        proxy.FriendProxy:sendMsg(1070102,{roleName = text})
    end
end

function ZhuiShaView:onController()
    if self.c1.selectedIndex == 0 then
        self.page = 1
        self.totalSum = 1
        self.listdata = {}
        self.selectedData = nil
        proxy.FriendProxy:sendMsg(1070101,{page =  self.page})
    elseif self.c1.selectedIndex == 1 then
        self.page = 1
        self.totalSum = 1
        self.listdata = {}
        self.selectedData = nil
        proxy.FriendProxy:sendMsg(1070203,{page =  self.page})
    end
end

function ZhuiShaView:initData(data)
    self.page = 1
    self.totalSum = 1
    self.listdata = {}
    self.selectedData = nil
    if self.c1.selectedIndex ~= 1 then
        self.c1.selectedIndex = 1
    else
        self:onController()
    end
end

function ZhuiShaView:celldata(index,obj)
    if index + 1 >= self.listView.numItems then
        if not self.data then
            return 
        end 
        if self.totalSum == self.page then 
            --没有下一页了
            --return
        else
            if self.c1.selectedIndex == 0 then
                proxy.FriendProxy:sendMsg(1070101,{page = self.page + 1})
            elseif self.c1.selectedIndex == 1 then
                proxy.FriendProxy:sendMsg(1070203,{page = self.page + 1})
            end
        end
    end
    local data = self.listdata[index + 1]
    if data then
        local nameTxt = obj:GetChild("n0")
        -- print("mingzi>>>>>>>>>",data.name,self.msgId)
        if self.msgId == 5070101 or self.msgId == 5070102 then
            nameTxt.text = data.name
        elseif self.msgId == 5070203 then
            nameTxt.text = data.roleName
        end
        local powerTxt = obj:GetChild("n1")
        powerTxt.text = data.power
        local stateTxt = obj:GetChild("n2")
        if data.offLineTime > 0 then
            stateTxt.text = mgr.TextMgr:getTextColorStr(GChangeToHMS(data.offLineTime),6)
        else
            stateTxt.text = mgr.TextMgr:getTextColorStr(GChangeToHMS(data.offLineTime),7)
        end
        obj.data = {name = nameTxt.text,roleId = data.roleId,power = data.power,offLineTime = data.offLineTime}
        obj.onClick:Add(self.onClickSelect,self)
    end
end

function ZhuiShaView:setData(data)
    self.data = data
    self.page = data.page
    self.totalSum = data.totalSum
    self.msgId = data.msgId
    -- print("当前页数>>>>>>>>>>>>",self.page)
    self.dec1.visible = false
    self.dec2.visible = false
    if data.msgId == 5070101 then--好友列表
        for k,v in pairs(data.friendList) do
            table.insert(self.listdata,v)
        end
        if #self.listdata <= 0 then
            self.dec2.visible = true
            self.dec1.visible = false
        end
    elseif data.msgId == 5070203 then--仇人列表
        for k,v in pairs(data.enemyList) do
            table.insert(self.listdata,v)
        end
        if #self.listdata <= 0 then
            self.dec2.visible = true
            self.dec1.visible = false
        end
    elseif data.msgId == 5070102 then--搜索
        self.c1.selectedIndex = 2
        self.listdata = {}
        self.totalSum = 1
        self.page = 1
        -- printt(">>>>>>>>>>",data)
        if #data.list > 0 then
            for k,v in pairs(data.list) do
                table.insert(self.listdata,v)
            end
        else
            self.dec1.visible = true
            self.dec2.visible = false
        end
    end
    self.listView.numItems = #self.listdata
    if self.page == 1 and #self.listdata > 0 then
        self.listView:AddSelection(0,true)
        self.selectedData = self.listdata[1]
        if self.msgId == 5070101 or self.msgId == 5070102 then
            self.selectedData.name = self.listdata[1].name
        elseif self.msgId == 5070203 then
            self.selectedData.name = self.listdata[1].roleName
        end
    end
end

function ZhuiShaView:onClickSelect(context)
    local data = context.sender.data
    self.selectedData = data
end

function ZhuiShaView:onClickZhuiSha()
    if self.selectedData then
        if self.selectedData.offLineTime and self.selectedData.offLineTime > 0 then
            GComAlter(language.friend58)
        else
            mgr.ViewMgr:openView2(ViewName.ZhuiShaTipsView,self.selectedData)
        end
    else
        GComAlter(language.friend61)
    end
end

return ZhuiShaView