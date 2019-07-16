--
-- Author: Your Name
-- Date: 2017-11-25 14:21:17
--

local MarryAppointment = class("MarryAppointment", base.BaseView)

function MarryAppointment:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function MarryAppointment:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(btnClose)
    --婚礼档次
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    self.needYbTxt = self.view:GetChild("n24")
    self.listView = self.view:GetChild("n5")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBack,self)
    self.listView.scrollPane.onScroll:Add(self.onClickCloseItem, self)
    self.leftNumsTxt = self.view:GetChild("n16")
    self.btn = self.view:GetChild("n8")
    self.btn.onClick:Add(self.onClickYuYue,self)
    local btnGuize = self.view:GetChild("n13")
    btnGuize.onClick:Add(self.onGuize,self)
    self.awardsList = self.view:GetChild("n18")
    self.awardsList:SetVirtual()
    self.awardsList.itemRenderer = function(index,obj)
        self:awardsCell(index, obj)
    end
    self.awardsList.numItems = 0
    --已预约信息
    self.weddingMsgPanel = self.view:GetChild("n26")
    self.weddingMsgPanel.onClick:Add(self.onClickCloseItem,self)
    self.view:GetChild("n0").onClick:Add(self.onClickCloseItem,self)
end

function MarryAppointment:onController1()
    local costData = conf.MarryConf:getMarryCostById(self.c1.selectedIndex+1)
    self.needYbTxt.text = costData.cost
    self.awardsData = costData.awards
    self.awardsList.numItems = #self.awardsData
    for i=23,25 do
        self.view:GetChild("n"..i).visible = true
    end
    self.leftNumsTxt.visible = false
    if self.c1.selectedIndex == 0 then
        if self.data.leftCount > 0 then
            self.leftNumsTxt.text = string.format(language.marryiage27,self.data.leftCount)
            self.leftNumsTxt.visible = true
            for i=23,25 do
                self.view:GetChild("n"..i).visible = false
            end
        end
    end
end

function MarryAppointment:onGuize()
    GOpenRuleView(1065)
end

function MarryAppointment:awardsCell( index,obj )
    local data = self.awardsData[index+1]
    if data then
        local mid = data[1]
        local amount = data[2]
        local bind = data[3]
        local itemData = {mid = mid ,amount = amount ,bind = bind}
        GSetItemData(obj, itemData, true)
    end
end

function MarryAppointment:celldata(index,obj)
    local data = self.confData[index+1]
    if data then
        obj.data = index+1
        -- local timeTxt = obj:GetChild("n1")
        local hour1 = GGetTimeData(data[1]).hour
        local min1 = GGetTimeData(data[1]).min
        local hour2 = GGetTimeData(data[2]).hour
        local min2 = GGetTimeData(data[2]).min
        local timeTxt = obj:GetChild("n1")
        local textDec1 = obj:GetChild("n2")
        local textDec2 = obj:GetChild("n9")
        local checkBtn = obj:GetChild("n8")
        textDec1.visible = true
        textDec2.visible = false
        checkBtn.visible = false
        checkBtn.onClick:Add(self.onClickCheckInfo,self)
        timeTxt.text = string.format("%02d",hour1)..":" .. string.format("%02d",min1) .. "--" .. string.format("%02d",hour2)..":" .. string.format("%02d",min2)
        if self.sign == index+1 then
            obj:GetChild("n3").visible = true
        else
            obj:GetChild("n3").visible = false
        end   

        local flag = false
        local info = {}
        for k,v in pairs(self.data.weddingPreData) do
            if v.timeField == index+1 then
                flag = true
                info = v
                break
            end
        end

        local curTime = GGetSecondBySeverTime(mgr.NetMgr:getServerTime())
        if data[1] > curTime then
            if flag then
                textDec1.visible = false
                textDec2.visible = true
                checkBtn.visible = true
                checkBtn.data = {obj = obj,info = info}
                local roleName = cache.PlayerCache:getRoleName()
                local coupleName = cache.PlayerCache:getCoupleName()
                if roleName == info.coupleName then--伴侣预约
                    textDec2.text = language.marryiage33_2
                elseif roleName == info.roleName then--自己预约
                    textDec2.text = language.marryiage33_1
                else--别人预约
                    textDec2.text = language.marryiage33
                end
            else
                textDec2.visible = false
                checkBtn.visible = false
                textDec1.text = language.marryiage34
            end
        else
            textDec2.visible = false
            checkBtn.visible = false
            textDec1.text = language.marryiage35
        end
    end
end

function MarryAppointment:onClickCheckInfo(context)
    local data = context.sender.data
    if data then
        local obj = data.obj
        local info = data.info
        local pos = obj:LocalToRoot(Vector2(obj.x,obj.z),GRoot.inst)
        local name1 = self.weddingMsgPanel:GetChild("n0")
        local name2 = self.weddingMsgPanel:GetChild("n1")
        name1.text = info.roleName
        name2.text = info.coupleName
        self.weddingMsgPanel.visible = true
        -- printt("obj.x,obj.y>>>>>>>>>>>>>>>>>",pos)
        self.weddingMsgPanel.x = pos.x-4
        self.weddingMsgPanel.y = pos.y+40
    end
end

function MarryAppointment:onClickCloseItem()
    self.weddingMsgPanel.visible = false
end

function MarryAppointment:onCallBack(context)
    local data = context.data.data
    local obj = context.data
    obj:GetChild("n3").visible = true
    self.sign = data

    self.listView:RefreshVirtualList()
end

function MarryAppointment:onClickYuYue()
    if self.sign == 0 then
        GComAlter(language.marryiage36)
    else
        local flag = false
        for k,v in pairs(self.data.weddingPreData) do
            if v.timeField == self.sign then
                flag = true
                break
            end
        end
        local data = self.confData[self.sign]
        
        local curTime = GGetSecondBySeverTime(mgr.NetMgr:getServerTime())
        if data[1] > curTime then
            if flag then
                GComAlter(language.marryiage33)
            else
                if self.data.leftCount > 0 and self.c1.selectedIndex == 0 then
                    proxy.MarryProxy:sendMsg(1390302,{reqType = 1,time = self.sign,weddingDc = self.c1.selectedIndex+1})
                else
                    local costData = conf.MarryConf:getMarryCostById(self.c1.selectedIndex+1)
                    local param = {}
                    param.type = 2
                    local textData = clone(language.marryiage60)
                    textData[2].text = string.format(textData[2].text,costData.cost)
                    textData[3].text = string.format(textData[3].text,language.marryiage61[self.c1.selectedIndex+1])
                    param.richtext = mgr.TextMgr:getTextByTable(textData)
                    param.sure = function()
                        proxy.MarryProxy:sendMsg(1390302,{reqType = 1,time = self.sign,weddingDc = self.c1.selectedIndex+1})
                    end
                    param.cancel = function()
                        
                    end
                    GComAlter(param)
                end
            end
        else
            GComAlter(language.marryiage35)
        end
    end
end

-- 变量名：reqType 说明：0显示1预约
-- 变量名：leftCount   说明：剩余预约次数
-- 变量名：invited 说明：已被预约的时间段
-- 变量名：mine    说明：自己和伴侣预约的时间段
-- 变量名：weddingDc   说明：婚宴档次
-- array<SimpleItemInfo>   变量名：items   说明：婚宴奖励
--weddingPreData
function MarryAppointment:initData(data)
    self.data = data
    self.sign = 0--默认选择为空
    if not data.weddingDc or data.weddingDc == 0 then
        self.c1.selectedIndex = 2
    else
        self.c1.selectedIndex = data.weddingDc - 1
        
    end
    -- print("当前免费次数>>>>>>>>>",self.data.leftCount)
    self:onController1()

    -- printt("0000000000000",data)
    self.confData = conf.MarryConf:getValue("wedding_banquet_time")
    self.listView.numItems = #self.confData
    self:setNames()
end

function MarryAppointment:setNames()
    local nameTxt1 = self.view:GetChild("n10")
    local nameTxt2 = self.view:GetChild("n11")
    local roleName = cache.PlayerCache:getRoleName()
    local coupleName = cache.PlayerCache:getCoupleName()
    nameTxt1.text = roleName
    nameTxt2.text = coupleName
end

return MarryAppointment