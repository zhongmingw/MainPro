--
-- Author: 
-- Date: 2017-11-28 19:47:45
--
--仙盟争霸
local XmzbPanel = class("XmzbPanel", import("game.base.Ref"))

function XmzbPanel:ctor(panelObj)
    self:initPanel(panelObj)
end

function XmzbPanel:initPanel(panelObj)
    self.bg = panelObj:GetChild("n0")
    self.c1 = panelObj:GetController("c1")--控制器
    self.listView = panelObj:GetChild("n4")--赛事区域
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end

    self.jxzTitle = panelObj:GetChild("n16")--进行中标题

    local warBtn = panelObj:GetChild("n12")
    self.warBtn = warBtn
    warBtn.onClick:Add(self.onClickWar,self)
    local decideFaneBtn = panelObj:GetChild("n13")
    decideFaneBtn.onClick:Add(self.onClickdecide,self)

    panelObj:GetChild("n14").text = mgr.TextMgr:getTextByTable(language.xmhd12)
    self.timeTitle = panelObj:GetChild("n15")

    local xmzbItem3 = panelObj:GetChild("n8")--
    self.xmzbItem3 = xmzbItem3

    local ruleBtn = panelObj:GetChild("n5")
    ruleBtn.onClick:Add(self.onClickRule,self)
end

function XmzbPanel:setData(data)
    self.bg.url = UIItemRes.bangpai04
    self.curZoneId = data and data.curZoneId or 1
    self.fightType = data and data.fightType or 0
    self.isTodayWar = data and data.isTodayWar or 1
    self.curWeek = data and data.curWeek or 0
    self.battleZoneInfo = {}--战区信息整合
    local zoneCount = 0
    local isFlag = false
    local result = 0
    for k,v in pairs(data.battleZoneInfo) do
        if not self.battleZoneInfo[v.zoneId] then
            zoneCount = zoneCount + 1
            self.battleZoneInfo[v.zoneId] = {zoneId = v.zoneId}
        end
        self.battleZoneInfo[v.zoneId][v.rank] = v
        if tostring(cache.PlayerCache:getGangId()) == tostring(v.gangId) then--如果我的仙盟在里面
            isFlag = true
            if v.result > 0 then
                mgr.GuiMgr:redpointByVar(attConst.A20133,0)--清理红点
            end
        end
    end
    self.isWarZg = isFlag
    local defaultItem = ""
    if self.fightType > 0 then--是否进行中
        local strTab = clone(language.xmhd22)
        strTab[2].text = string.format(strTab[2].text, language.xmhd21[self.fightType])
        self.jxzTitle.text = mgr.TextMgr:getTextByTable(strTab)
        defaultItem = UIPackage.GetItemURL("bangpai" , "XmzbItem2")
        self.c1.selectedIndex = 1
    else
        defaultItem = UIPackage.GetItemURL("bangpai" , "XmzbItem1")
        self.c1.selectedIndex = 0
    end
    self.listView.defaultItem = defaultItem

    self.redNum = cache.PlayerCache:getRedPointById(attConst.A20133)
    if self.redNum > 0 and isFlag then
        self.warBtn.enabled = true
    else
        self.warBtn.enabled = false
        mgr.GuiMgr:redpointByVar(attConst.A20133,0)--清理红点
    end
    self:setXmzbInfo()
    self.xmZones = conf.XmhdConf:getValue("xianmeng_war_zones")--赛区列表
    for k,v in pairs(self.xmZones) do
        if not self.battleZoneInfo[k] then
            zoneCount = zoneCount + 1
            self.battleZoneInfo[k] = {zoneId = k}
        end
    end
    table.sort(self.battleZoneInfo, function(a, b)
        return a.zoneId < b.zoneId
    end)
    self.listView.numItems = zoneCount
    self.listView:ScrollToView(0)
end

function XmzbPanel:setXmzbInfo()
    local str1 = clone(language.xmhd18)
    local str2 = clone(language.xmhd19)
    local str3 = clone(language.xmhd20)
    local desc = ""
    local timeTab = os.date("*t",mgr.NetMgr:getServerTime())
    local wDay = timeTab.wday - 1--解析服务器时间
    if wDay == 0 then wDay = 7 end--周末
    local tStr = {}
    if self.curWeek == 0 then
        tStr = language.xmhd27
    else
        tStr = language.xmhd31
    end
    local weekDesc = tStr[self.isTodayWar]
    local desc = string.format(language.xmhd26, weekDesc)
    str1[2].text = string.format(str1[2].text, desc)

    local stepTime = conf.XmhdConf:getValue("begin_time")--各阶段的开启时间
    local weekDays = conf.XmhdConf:getValue("normal_week_days")
    local strTab = clone(language.xmhd17)
    if self.fightType == 1 then
        str2[2].color = 4
    elseif self.fightType == 2 then
        str3[2].color = 4
    end
    strTab[2].text = string.format(strTab[2].text, weekDesc..GTotimeString4(stepTime))
    self.timeTitle.text = mgr.TextMgr:getTextByTable(strTab)--截止时间描述

    if self.redNum <= 0 then
        str2[2].color = 5
        str3[2].color = 5
        self.isRefRed = false
    end
    self.xmzbItem3:GetChild("n1").text = mgr.TextMgr:getTextByTable(str1)
    self.xmzbItem3:GetChild("n2").text = mgr.TextMgr:getTextByTable(str2)
    self.xmzbItem3:GetChild("n3").text = mgr.TextMgr:getTextByTable(str3)
end

function XmzbPanel:onTimer()
    local redObj = self.warBtn:GetChild("red")
    if self.isWarZg and cache.PlayerCache:getRedPointById(attConst.A20133) > 0 then
        if not self.isRefRed then
            proxy.XmhdProxy:send(1360201)
            self.isRefRed = true
        end
        redObj.visible = true
        self.warBtn.enabled = true
    else
        self.warBtn.enabled = false
        redObj.visible = false
    end
end

function XmzbPanel:cellData(index, obj)
    local data = self.battleZoneInfo[index + 1]
    if not data then
        printt("搞事情",self.battleZoneInfo)
        return
    end
    local confData = self.xmZones[data.zoneId]
    if self.fightType > 0 then
        self:cellJxzData(obj,data,confData)
    else
        self:cellKxzData(index,obj,data,confData)
    end
end
--进行中
function XmzbPanel:cellJxzData(obj,data,confData)
    local url = ""
    local name = ""
    if confData then
        name = confData[1] or ""
        local img = confData[2] or ""
        url = UIPackage.GetItemURL("bangpai" , img)
    end
    obj:GetChild("n1").url = url
    obj:GetChild("n3").text = name
    local battlesMap = {}
    -- printt("进行中",data)
    for k,v in pairs(data) do
        if type(v) == "table" then
            local battleType = v.battleType
            if not battlesMap[battleType] then
                battlesMap[battleType] = {}
            end
            local campType = v.campType or 0
            local t = {gangName = v.gangName or "",result = v.result or 0,campType = campType}
            battlesMap[battleType][campType] = t
        end
    end
    --设置对持的双方谁是攻守
    local function getCampData(campData1,campData2)
        local camp1,camp2 = {},{}--左右
        local campType = campData1.campType
        local flag = false
        if campType then--先判断一方
            if campType == 1 then--攻
                flag = true
            else--守
                flag = false
            end
        else--一方没有再判断二方
            campType = campData2.campType or 0
            if campType == 1 then--攻
                flag = false
            else--守
                flag = true
            end
        end
        if flag then
            camp1 = {url = UIItemRes.xmhd01[campData1.result or 0],campName = campData1.gangName or language.xmhd24}
            camp2 = {url = UIItemRes.xmhd01[campData2.result or 0],campName = campData2.gangName or language.xmhd24}
        else
            camp1 = {url = UIItemRes.xmhd01[campData2.result or 0],campName = campData2.gangName or language.xmhd24}
            camp2 = {url = UIItemRes.xmhd01[campData1.result or 0],campName = campData1.gangName or language.xmhd24}
        end
        return camp1,camp2
    end

    local battle1 = battlesMap[1] or {}
    local camp1,camp2 = getCampData(battle1[1] or {},battle1[2] or {})
    obj:GetChild("n7").url = camp1.url
    obj:GetChild("n8").url = camp2.url
    obj:GetChild("n9").text = camp1.campName
    obj:GetChild("n10").text = camp2.campName

    local battle2 = battlesMap[2] or {}
    local camp1,camp2 = getCampData(battle2[1] or {},battle2[2] or {})
    obj:GetChild("n12").url = camp1.url
    obj:GetChild("n13").url = camp2.url
    obj:GetChild("n14").text = camp1.campName
    obj:GetChild("n15").text = camp2.campName
    battlesMap = nil
end
--空闲中
function XmzbPanel:cellKxzData(index,obj,data,confData)
    local name = confData and confData[1] or language.xmhd24
    local color = confData and confData[3] or 1
    if index == 0 then
        obj:GetChild("n0").visible = false
    else
        obj:GetChild("n0").visible = true
    end
    local c1 = obj:GetController("c1")
    if data.zoneId == 5 and not data[1] then--人级赛区
        c1.selectedIndex = 1
    else
        c1.selectedIndex = 0
    end
    -- printt("空闲中",data)
    obj:GetChild("n1").text = mgr.TextMgr:getTextColorStr(name, color)
    obj:GetChild("n2").text = data[1] and data[1].gangName or language.xmhd24
    obj:GetChild("n3").text = data[2] and data[2].gangName or language.xmhd24
    obj:GetChild("n4").text = data[3] and data[3].gangName or language.xmhd24
    obj:GetChild("n5").text = data[4] and data[4].gangName or language.xmhd24
    obj:GetChild("n6").text = language.xmhd25
    obj:GetChild("n7").visible = false
    obj:GetChild("n8").visible = false
    obj:GetChild("n9").visible = false
    obj:GetChild("n10").visible = false
    if data[1] then
        local gangId1 = data[1].gangId
        local uId1 = string.sub(gangId1,1,3)
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId1) and tonumber(gangId1) > 10000 then
           obj:GetChild("n7").visible = true
        end
    end
    if data[2] then
        local gangId2 = data[2].gangId
        local uId2 = string.sub(gangId2,1,3)
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId2) and tonumber(gangId2) > 10000 then
           obj:GetChild("n8").visible = true
        end
    end
    if data[3] then
        local gangId3 = data[3].gangId
        local uId3 = string.sub(gangId3,1,3)
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId3) and tonumber(gangId3) > 10000 then
           obj:GetChild("n9").visible = true
        end
    end
    if data[4] then
        local gangId4 = data[4].gangId
        local uId4 = string.sub(gangId4,1,3)
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId4) and tonumber(gangId4) > 10000 then
           obj:GetChild("n10").visible = true
        end
    end
end

function XmzbPanel:onClickWar()
    if not self.curZoneId then return end
    if self.fightType == 0 then
        GComAlter(language.xmhd23)
        return
    end
    mgr.FubenMgr:gotoFubenWar(GangWarScene + self.curZoneId)
end

function XmzbPanel:onClickdecide()
    local id = 1140
    local actConf = conf.BangPaiConf:getGangActive(id)
    local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
    if view and view.panelActivity then
        view.panelActivity:nextStep(3)
        -- view:initData({index = language.bangpai186[id],childIndex = actConf and actConf.sort or 1})
    end
end

function XmzbPanel:onClickRule()
    GOpenRuleView(1066)
end

function XmzbPanel:clear()
    self.bg.url = ""
end

return XmzbPanel