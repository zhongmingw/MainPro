--
-- Author: Your Name
-- Date: 2018-04-18 15:49:53
--

local CityWarAwards = class("CityWarAwards", base.BaseView)

function CityWarAwards:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function CityWarAwards:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.cityPanel = self.view:GetChild("n5")
    self.awardsPanel = self.view:GetChild("n6")
    self.reportPanel = self.view:GetChild("n7")
    self.winAwardPanel = self.view:GetChild("n9")
    self.endAwardPanel = self.view:GetChild("n10")
    self.sId = language.citywar01[3]
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
end

function CityWarAwards:onController1()
    if self.c1.selectedIndex == 0 then--城池
        self:setCityInfos()
    elseif self.c1.selectedIndex == 1 then--战果奖励
        self:setWarAwards()
    elseif self.c1.selectedIndex == 2 then--战报
        proxy.CityWarProxy:sendMsg(1510103)
    elseif self.c1.selectedIndex == 3 then--连胜奖励
        proxy.CityWarProxy:sendMsg(1510106,{reqType = 0})
    elseif self.c1.selectedIndex == 4 then--终结奖励
        proxy.CityWarProxy:sendMsg(1510107,{reqType = 0})
    end
end

function CityWarAwards:initData(data)
    local index = data.index or 0
    self.sId = data.sId
    if self.c1.selectedIndex ~= index then
        self.c1.selectedIndex = index
    else
        self:onController1()
    end
    self:refreshRed()
end

function CityWarAwards:refreshRed()
    if cache.PlayerCache:getRedPointById(attConst.A20169) > 0 then
        self.view:GetChild("n8").visible = true
    else
        self.view:GetChild("n8").visible = false
    end
    if cache.PlayerCache:getRedPointById(attConst.A20204) > 0 then
        self.view:GetChild("n13").visible = true
    else
        self.view:GetChild("n13").visible = false
    end
    if cache.PlayerCache:getRedPointById(attConst.A20205) > 0 then
        self.view:GetChild("n14").visible = true
    else
        self.view:GetChild("n14").visible = false
    end
end

function CityWarAwards:awardsCelldata( index,obj )
    local data = self.awardsData[index+1]
    if data then
        local dec = obj:GetChild("n3")
        dec.text = data.desc
        local items = {}
        local listView = obj:GetChild("n4")
        listView.numItems = 0
        if type(data[1]) == "number" then
            local mid = conf.CityWarConf:getValue("gang_capital")
            local amount = data[1]
            items = {{mid,amount,0}}
        elseif type(data[1]) == "table" then
            items = data[1]
        end
        for k,v in pairs(items) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local obj = listView:AddItemFromPool(url)
            local info = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(obj,info,true)
        end
    end
end

    -- 变量名：sceneId 说明：场景id(城池)
    -- 变量名：gangName    说明：占领宗门
    -- 变量名：gangAdminName   说明：占领宗主名
    -- 变量名：occupyDay   说明：占领天数
    -- 变量名：occupyType  说明：0:未开始 1:  2:可宣战
    -- 变量名：warNum  说明：宣战数量
    -- 变量名：gangId  说明：占领仙盟id
--城池信息 UIItemRes.cityWar
function CityWarAwards:setCityInfos()
    self.cityPanel:GetChild("n17").text = language.citywar22
    self.cityPanel:GetChild("n18").text = language.citywar23
    self.cityPanel:GetChild("n19").text = language.citywar24
    self.cityData = cache.CityWarCache:getCityData()
    local leftBtn = self.cityPanel:GetChild("n13")
    leftBtn.onClick:Add(self.onClickLeft,self)
    local rightBtn = self.cityPanel:GetChild("n14")
    rightBtn.onClick:Add(self.onClickRight,self)
    self.cityImg = self.cityPanel:GetChild("n11")
    self.cityImg.url = UIPackage.GetItemURL("citywar" , UIItemRes.cityWar[self.sId])
    local cityName = self.cityPanel:GetChild("n16")
    local confData = conf.SceneConf:getSceneById(self.sId)
    cityName.text = confData.name
    local gangName = self.cityPanel:GetChild("n20")
    local gangAdminName = self.cityPanel:GetChild("n21")
    local occupyDay = self.cityPanel:GetChild("n22")
    local xuanzhanBtn = self.cityPanel:GetChild("n29")
    local xuanzhanImg = self.cityPanel:GetChild("n30")
    xuanzhanImg.visible = false
    --宣战时间
    local netTime = mgr.NetMgr:getServerTime()
    local nowtime = GGetSecondBySeverTime(netTime)
    local signTime = conf.CityWarConf:getValue("sign_time")
    if nowtime < signTime[2] and nowtime > signTime[1] then
        xuanzhanBtn.visible = true
    else
        xuanzhanBtn.visible = false
    end

    local getBtn = self.cityPanel:GetChild("n32")
    getBtn.visible = false
    getBtn.onClick:Add(self.onClickGetAwards,self)
    local getRedPoint = cache.PlayerCache:getRedPointById(attConst.A20169)--领取红点
    if getRedPoint > 0 then
        getBtn:GetChild("red").visible = true
    else
        getBtn:GetChild("red").visible = false
    end
    local getImg = self.cityPanel:GetChild("n33")
    getImg.visible = false
    local crossIcon = self.cityPanel:GetChild("n34")
    crossIcon.visible = false
    local cityInfo = self.cityData[self.sId]
    if cityInfo then
        gangName.text = cityInfo.gangName or ""
        if not cityInfo.gangName or cityInfo.gangName == "" then
            gangName.text = language.citywar02
        end
        gangAdminName.text = cityInfo.gangAdminName or ""
        if not cityInfo.gangAdminName or cityInfo.gangAdminName == "" then
            gangAdminName.text = language.citywar02
        end
        if cityInfo.occupyDay == 0 then
            occupyDay.text = ""
        else
            occupyDay.text = cityInfo.occupyDay..language.gonggong82
        end
        local listView = self.cityPanel:GetChild("n24")
        listView.numItems = 0
        local items = conf.CityWarConf:getDayAwardsDataById(self.sId)
        for k,v in pairs(items) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local obj = listView:AddItemFromPool(url)
            local info = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(obj,info,true)
        end
        local warSid = cache.CityWarCache:getWarSceneId()
        local gangId = cache.PlayerCache:getGangId()
        -- print("宣战城池",warSid)
        if warSid == cityInfo.sceneId then
            xuanzhanImg.visible = true
        end
        if warSid > 0 or cityInfo.sceneId == language.citywar01[3] or self:hasCity() then
            xuanzhanBtn.visible = false
        end
        --宣战按钮
        xuanzhanBtn.data = cityInfo
        xuanzhanBtn.onClick:Add(self.onClickDeclareWar,self)
        --领取奖励按钮
        if gangId == cityInfo.gangId and tonumber(gangId) ~= 0 then
            local awardGot = cache.CityWarCache:getAwardGot()
            if awardGot == 0 then
                getBtn.visible = true
                getImg.visible = false
            else
                getBtn.visible = false
                getImg.visible = true
            end
        else
            getBtn.visible = false
            getImg.visible = false
        end
        if tonumber(cityInfo.gangId) ~= 0 then
            local chanelId = tonumber(string.sub(cityInfo.gangId,1,3))
            local myChanelId = cache.PlayerCache:getRedPointById(10327)
            if chanelId ~= myChanelId then
                crossIcon.visible = true
            end
        end
    end
end

--是否占领了城池
function CityWarAwards:hasCity()
    local gangId = cache.PlayerCache:getGangId()
    local flag = false
    for k,v in pairs(self.cityData) do
        if gangId == v.gangId and tonumber(gangId) ~= 0 then
            flag = true
            break
        end
    end
    return flag
end

function CityWarAwards:onClickGetAwards()
    proxy.CityWarProxy:sendMsg(1510105)
end

--战果奖励返回
function CityWarAwards:setWarAwards()
    self.awardsData = conf.CityWarConf:getAwardsData()
    printt(self.awardsData)
    self.awardsList = self.awardsPanel:GetChild("n2")
    self.awardsList.itemRenderer = function (index,obj)
        self:awardsCelldata(index, obj)
    end
    self.awardsList:SetVirtual()
    self.awardsList.numItems = #self.awardsData
    local awardDec = self.awardsPanel:GetChild("n6"):GetChild("n0")
    awardDec.text = language.citywar11
end

--连胜信息
function CityWarAwards:setWinAwards(data)
    self.winData = data
    self.winAwardsData = conf.CityWarConf:getWinOrEndAwards()
    self.winAwardsList = self.winAwardPanel:GetChild("n2")
    self.winAwardsList.itemRenderer = function (index,obj)
        self:winAwardsCelldata(index, obj)
    end
    self.winAwardsList:SetVirtual()
    self.winAwardsList.numItems = #self.winAwardsData
    local winTimeTxt = self.winAwardPanel:GetChild("n6")
    winTimeTxt.text = string.format(language.citywar27,self.winData.winTimes)
    local awardDec = self.winAwardPanel:GetChild("n7"):GetChild("n0")
    awardDec.text = language.citywar30
end

--终结信息
function CityWarAwards:setEndAwards(data)
    self.endData = data
    self.winAwardsData = conf.CityWarConf:getWinOrEndAwards()
    self.endAwardsList = self.endAwardPanel:GetChild("n2")
    self.endAwardsList.itemRenderer = function (index,obj)
        self:endAwardsCelldata(index, obj)
    end
    self.endAwardsList:SetVirtual()
    self.endAwardsList.numItems = #self.winAwardsData
    local winTimeTxt = self.endAwardPanel:GetChild("n6")
    winTimeTxt.text = string.format(language.citywar27_1,self.endData.winTimes)
    local awardDec = self.endAwardPanel:GetChild("n7"):GetChild("n0")
    awardDec.text = language.citywar31
end

function CityWarAwards:winAwardsCelldata(index,obj)
    local data = self.winAwardsData[index+1]
    if data then
        local dec = obj:GetChild("n3")
        dec.text = string.format(language.citywar25,data.id)
        local listView = obj:GetChild("n4")
        listView.numItems = 0

        for k,v in pairs(data.win_awards) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local obj = listView:AddItemFromPool(url)
            local info = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(obj,info,true)
        end
        local fenpeiBtn = obj:GetChild("n5")
        local myGangId = cache.PlayerCache:getGangId()
        if myGangId == self.winData.winGangId then
            fenpeiBtn.visible = true
            local fpStatus = self.winData.fpStatus
            local maxCount = self.winAwardsData[#self.winAwardsData].id
            if data.id == self.winData.winTimes or (maxCount and self.winData.winTimes > maxCount and data.id == maxCount) then
                if fpStatus and fpStatus == 1 then
                    fenpeiBtn.icon = UIItemRes.xmhd02[1]
                    fenpeiBtn.grayed = false
                elseif fpStatus and fpStatus == 2 then
                    fenpeiBtn.icon = UIItemRes.xmhd02[2]
                    fenpeiBtn.grayed = true
                elseif fpStatus and fpStatus == 3 then
                    fenpeiBtn.icon = UIItemRes.xmhd02[1]
                    fenpeiBtn.grayed = true
                end
            else
                fenpeiBtn.visible = false
            end
        else
            fenpeiBtn.visible = false
        end
        fenpeiBtn.data = {type = 1,fpStatus = self.winData.fpStatus}
        fenpeiBtn.onClick:Add(self.onClickFenPei,self)
    end
end

function CityWarAwards:endAwardsCelldata(index,obj)
    local data = self.winAwardsData[index+1]
    if data then
        local dec = obj:GetChild("n3")
        dec.text = string.format(language.citywar26,data.id)
        local listView = obj:GetChild("n4")
        listView.numItems = 0

        for k,v in pairs(data.end_awards) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local obj = listView:AddItemFromPool(url)
            local info = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(obj,info,true)
        end
        local fenpeiBtn = obj:GetChild("n5")
        fenpeiBtn.visible = true
        local myGangId = cache.PlayerCache:getGangId()
        local gangJob = cache.PlayerCache:getGangJob()
        if myGangId == self.endData.winGangId then
            local maxCount = self.winAwardsData[#self.winAwardsData].id
            if data.id == self.endData.endTimes or (maxCount and self.endData.endTimes > maxCount and data.id == maxCount) then
                if self.endData.fpStatus == 1 then
                    fenpeiBtn.icon = UIItemRes.xmhd02[1]
                    fenpeiBtn.grayed = false
                elseif self.endData.fpStatus == 2 then
                    fenpeiBtn.icon = UIItemRes.xmhd02[2]
                    fenpeiBtn.grayed = true
                elseif self.endData.fpStatus == 3 then
                    fenpeiBtn.icon = UIItemRes.xmhd02[1]
                    fenpeiBtn.grayed = true
                end
            else
                fenpeiBtn.visible = false
            end
        else
            fenpeiBtn.visible = false
        end
        fenpeiBtn.data = {type = 2,fpStatus = self.endData.fpStatus}
        fenpeiBtn.onClick:Add(self.onClickFenPei,self)
    end 
end

function CityWarAwards:onClickFenPei(context)
    local data = context.sender.data
    local msgId = 1510106
    if data.type == 1 then--连胜分配
        msgId = 1510106
    elseif data.type == 2 then--终结分配
        msgId = 1510107
    end
    if data.fpStatus == 1 then
        local gangJob = cache.PlayerCache:getGangJob()
        if gangJob == 4 then
            local t = {func = function(roleId)
                proxy.CityWarProxy:send(msgId,{reqType = 1,roleId = roleId})
            end}
            mgr.ViewMgr:openView2(ViewName.ChooseTipView, t)
        else
            GComAlter(language.citywar32)
        end
    elseif data.fpStatus == 2 then
        GComAlter(language.citywar28)
    elseif data.fpStatus == 3 then
        GComAlter(language.citywar29)
    end
end
    
-- 变量名：cityWarReports  说明：战报
    -- 变量名：gangName    说明：仙盟名
    -- 变量名：result  说明：结果：1:胜 2:败
    -- 变量名：sceneId 说明：城池
--战报
function CityWarAwards:setWarReports(data)
    self.reportData = {}
    local reports = data.cityWarReports or {}
    local t = {
        [253001] = {},
        [253002] = {},
        [253003] = {},
        [253004] = {},
    }
    for k,v in pairs(reports) do
        table.insert(t[v.sceneId],v)
    end
    for k,v in pairs(t) do
        table.insert(self.reportData,{report = v,sId = k})
    end
    table.sort(self.reportData,function(a,b)
        return a.sId < b.sId
    end)
    self.reportList = self.reportPanel:GetChild("n0")
    self.reportList.itemRenderer = function (index,obj)
        self:reportCelldata(index, obj)
    end
    self.reportList:SetVirtual()
    self.reportList.numItems = #self.reportData
end

function CityWarAwards:reportCelldata(index,obj)
    local data = self.reportData[index + 1]
    if data then
        local listView = obj:GetChild("n5")
        listView.numItems = 0
        local decTxt = obj:GetChild("n4")
        local cityName = obj:GetChild("n3")
        local sConf = conf.SceneConf:getSceneById(data.sId)
        cityName.text = sConf.name
        local cityImg = obj:GetChild("n2")
        cityImg.url = UIPackage.GetItemURL("citywar" , UIItemRes.cityWar[data.sId])
        if #data.report == 0 then
            decTxt.visible = true
        else
            decTxt.visible = false
            for k,v in pairs(data.report) do
                local url = UIPackage.GetItemURL("citywar" , "TextItem")
                local cell = listView:AddItemFromPool(url)
                local gangName = cell:GetChild("n0")
                local winImg = cell:GetChild("n1")
                gangName.text = v.gangName
                if v.result == 1 then
                    winImg.url = UIPackage.GetItemURL("citywar", "chengzhan_012")
                else
                    winImg.url = UIPackage.GetItemURL("citywar", "chengzhan_013")
                end
            end
        end
    end
end

function CityWarAwards:onClickLeft()
    local minSid = language.citywar01[3]
    if self.sId > minSid then
        self.sId = self.sId - 1
        self:setCityInfos()
    else
        self.sId = language.citywar01[4]
        self:setCityInfos()
    end
end

function CityWarAwards:onClickRight()
    local maxSid = language.citywar01[4]
    if self.sId < maxSid then
        self.sId = self.sId + 1
        self:setCityInfos()
    else
        self.sId = language.citywar01[3]
        self:setCityInfos()
    end
end

function CityWarAwards:onClickDeclareWar(context)
    local data = context.sender.data
    local isXz = cache.CityWarCache:getisXz()
    if isXz == 1 then
        proxy.CityWarProxy:sendMsg(1510102,{sceneId = data.sceneId,gangAdminName = data.gangAdminName})
    else
        GComAlter(language.citywar05)
    end
end

return CityWarAwards