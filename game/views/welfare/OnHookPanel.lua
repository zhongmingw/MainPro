--
-- Author: Your Name
-- Date: 2017-05-22 11:51:31
--

local OnHookPanel = class("OnHookPanel",import("game.base.Ref"))

function OnHookPanel:ctor(parent,panelObj)
    self.mParent = parent
    self.panelObj = panelObj
    self:initPanel()
end

function OnHookPanel:initPanel()
    self.c1 = self.panelObj:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    self:nextStep()

    --EVE 屏蔽抢夺
    self.panelObj:GetChild("n10"):SetScale(0,0)
    self.panelObj:GetChild("n9"):SetScale(0,0)
    self.panelObj:GetChild("n8"):SetScale(0,0)
    self.panelObj:GetChild("n0"):SetScale(0,0)
end

function OnHookPanel:nextStep(childIndex)
    -- body
    if self.c1.selectedIndex == childIndex then
        self:onController()
    else
        self.c1.selectedIndex = childIndex or 0
    end
end

function OnHookPanel:refreshRed()
    local var = cache.PlayerCache:getRedPointById(attConst.A20137)
    if var > 0 then
        self.panelObj:GetChild("n10"):GetChild("n4").visible = true
    else
        self.panelObj:GetChild("n10"):GetChild("n4").visible = false
    end
end

function OnHookPanel:onController()
    -- body
    if self.c1.selectedIndex == 0 then
        proxy.ActivityProxy:send(1030130)
    elseif self.c1.selectedIndex == 1 then
        proxy.ActivityProxy:send(1030131)
    elseif self.c1.selectedIndex == 2 then
        self.page = 1
        self.roleInfo = {}
        self.execptGang = cache.PlayerCache:getExecptGangType()
        self.execptFriend = cache.PlayerCache:getExecptFriendType()
        self.reqType = cache.PlayerCache:getoffHookType()
        local LootPanel = self.panelObj:GetChild("n7")
        --两个筛选按钮
        self.TmcheckBtn = LootPanel:GetChild("n2")
        self.TmcheckBtn.onChanged:Add(self.onCheckTm,self)
        if self.execptGang == 1 then
            self.TmcheckBtn.selected = true
        else
            self.TmcheckBtn.selected = false
        end
        self.HycheckBtn = LootPanel:GetChild("n3")
        self.HycheckBtn.onChanged:Add(self.onCheckHy,self)
        if self.execptFriend == 1 then
            self.HycheckBtn.selected = true
        else
            self.HycheckBtn.selected = false
        end
        local param = {reqType = self.reqType,execptGang = self.execptGang,execptFriend = self.execptFriend,page = self.page}
        proxy.ActivityProxy:send(1030132,param)
    end
end

function OnHookPanel:itemData( index,obj )
    -- body
    obj:GetChild("title").text = language.welfare22[index+1]
    obj.data = index
    obj.onClick:Add(self.onClickTurnTo,self)
end

-- function OnHookPanel:onClickTurnTo(context)
--     -- body
--     local cell = context.sender
--     local page = cell.data
--     self.c1.selectedIndex = page
-- end

function OnHookPanel:setData(data)
    self.data = data
    if self.c1.selectedIndex == 0 then
        self:initAwards()
    elseif self.c1.selectedIndex == 1 then
        self:initRecords()
    elseif self.c1.selectedIndex == 2 then
        self:initLoot()
    end
    self:refreshRed()
end
function OnHookPanel:toTimeString(timeValue)
    -- body
    local hour=math.floor(timeValue/3600);

    local minute=math.floor((timeValue%3600)/60);

    local second=(timeValue%3600)%60;
    
    return string.format("%02d时%02d分",hour,minute)
end
-- 变量名：outlineTime 说明：累计离线收益时间
-- 变量名：allOutlineTime  说明：总离线时间
-- 变量名：beRobbedExp 说明：被抢经验
-- 变量名：beRobbedTq  说明：被抢铜钱
-- 变量名：leftRobbedTimes 说明：今日剩余掠夺次数
-- 变量名：guajiExp    说明：今日挂机获得经验
-- 变量名：guajiTq 说明：今日挂机获得铜钱
-- 变量名：leftGuajiTime   说明：剩余离线挂机时间
-- 变量名：awardsEquip 说明：挂机获得装备<品质->数量>
-- 变量名：loseEquip   说明：被抢失去的装备<品质->数量>
-- 变量名：oldLevel    说明：收益前等级
-- 变量名：oldExp  说明：收益前经验
--离线挂机奖励panel
function OnHookPanel:initAwards()
    -- body
    local awardsPanel = self.panelObj:GetChild("n5")
    local outlineTime = awardsPanel:GetChild("n13")
    outlineTime.text = self:toTimeString(self.data.outlineTime or 0)
    local leftHookTime = awardsPanel:GetChild("n14")
    leftHookTime.text = language.welfare32..self:toTimeString(self.data.leftGuajiTime or 0).."）"
    awardsPanel:GetChild("n35").text = self:toTimeString(self.data.leftGuajiTime or 0)

    local oldLevel = self.data.oldLevel
    if oldLevel == 0 then oldLevel = 1 end
    local oldLvupExp = conf.RoleConf:getRoleExpById(oldLevel)
    local oldLvTxt = awardsPanel:GetChild("n15")
    local jiantouImg = awardsPanel:GetChild("n16")
    local nowLvTxt = awardsPanel:GetChild("n17")
    awardsPanel:GetChild("n16").visible = true
    local tipsTxt = awardsPanel:GetChild("n36")
    tipsTxt.visible = true
    local oldExp = self.data.oldExp
    if oldLvupExp > 0 then
        local nowLevel,nowExp = GGetLevelAfterAddExp( oldLevel,oldExp,self.data.guajiExp )
        local lvupExp = conf.RoleConf:getRoleExpById(nowLevel)
        oldLvTxt.text = oldLevel .. language.gonggong43 .. (math.floor((oldExp/oldLvupExp)*1000)/10).."%"
        nowLvTxt.text = nowLevel .. language.gonggong43 .. (math.floor((nowExp/lvupExp)*1000)/10).."%"
    else
        oldLvTxt.text = oldLevel .. language.gonggong43 .. "100%"
        nowLvTxt.text = oldLevel .. language.gonggong43 .. "100%"
    end
    if self.data.guajiExp <= 0 then
        oldLvTxt.text = ""
        nowLvTxt.text = ""
        tipsTxt.visible = false
        awardsPanel:GetChild("n16").visible = false
    end
    jiantouImg.x = oldLvTxt.x + oldLvTxt.width + 5
    nowLvTxt.x = jiantouImg.x + jiantouImg.width + 5
    -- --获得铜钱
    -- local tqTxt = awardsPanel:GetChild("n18")
    -- if self.data.guajiTq > 0 then
    --     tqTxt.text = language.money[MoneyType.copper] .."*".. self.data.guajiTq
    -- else
    --     tqTxt.text = ""
    -- end
    --获得装备
    local n = 0
    for k,v in pairs(self.data.awardsEquip) do
        awardsPanel:GetChild("n"..(n+18)).text = language.welfare27[k] .."*" ..v
        n = n + 1
    end
    -- --被抢夺铜钱
    -- local beRobbedTqTxt = awardsPanel:GetChild("n24")
    -- if self.data.beRobbedTq > 0 then
    --     beRobbedTqTxt.text = language.money[MoneyType.copper] .."*".. self.data.beRobbedTq
    -- else
    --     beRobbedTqTxt.text = ""
    -- end
    --被抢装备
    local m = 0
    for k,v in pairs(self.data.loseEquip) do
        awardsPanel:GetChild("n"..(m+24)).text = language.welfare27[k] .."*" ..v
        m = m + 1
    end
    local offTimeBtn = awardsPanel:GetChild("n31")
    offTimeBtn.onClick:Add(self.onClickGetTimes,self)
     --bxp自动吞噬装备按钮
    self.checkBtn = awardsPanel:GetChild("n40")
    self.checkBtn.onClick:Add(self.autoCheck,self)
    local tunshiTitle = awardsPanel:GetChild("n41")
    tunshiTitle.text = language.welfare63
    --bxp打开界面，请求是否自动吞噬信息
    local type = self.checkBtn.selected == true and 1 or 0
    proxy.PackProxy:sendMsgTunshi({reqType=1,type=type})
end
--勾选自动吞噬装备按钮
function OnHookPanel:autoCheck()
    local str = ""
    local Type 
    if self.checkBtn.selected then
        str = language.welfare57
        Type = 1
    else
        str = language.welfare58
        Type = 0
    end
    proxy.PackProxy:sendMsgTunshi({reqType=2,type=Type})
    GComAlter(str)
end
function OnHookPanel:setCheck(Type)
    -- body
    self.checkBtn.selected = Type == 1 and true or false
end
--获取额外离线挂机时间
function OnHookPanel:onClickGetTimes()
    -- body
    --EVE +离线挂机时间弹窗
    local param = {}
    param.mId = 221051011
    GGoBuyItem(param)


    -- mgr.ViewMgr:openView(ViewName.OfflineTimesBuy,function()
    -- end,{})
end

-- 时间#名字#1#经验#金钱#装备数量
-- 时间#名字#0
--离线仇人记录panel
function OnHookPanel:initRecords()
    -- body
    local recordPanel = self.panelObj:GetChild("n6")
    local listview = recordPanel:GetChild("n5")
    local logs = self.data.guajiLogs
    local listView = recordPanel:GetChild("n3")
    listView.numItems = 0
    for i=1,#logs do
        local url = UIPackage.GetItemURL("welfare" , "RecordItem")
        local obj = listView:AddItemFromPool(url)
        local recordTxt = obj:GetChild("n1")
        local str = string.split(logs[i],"#")
        if str[3] ~= "" then
            str[3] = "("..str[3]..")"
        end
        if tonumber(str[4]) == 1 then
            local textData = {
                {text=self:GTotimeString(str[1]) .. "  ",color = 15},
                {text=str[2],color = 7},
                {text=str[3],color = 7},
                {text=language.welfare28,color = 6},
                {text=not str[5] and "" or language.welfare29[1]..str[5],color = 7},
                -- {text=not str[6] and "" or language.welfare29[2]..str[6],color = 7},
                {text=not str[7] and "" or language.welfare29[3]..str[7],color = 7},
            }
            recordTxt.text = mgr.TextMgr:getTextByTable(textData)
        else
            local textData = {
                {text=self:GTotimeString(str[1]).."  ",color = 15},
                {text=str[2],color = 7},
                {text=str[3],color = 7},
                {text=language.welfare30,color = 6},
            }
            recordTxt.text = mgr.TextMgr:getTextByTable(textData)
        end
    end
end

function OnHookPanel:GTotimeString( curTime )
    -- body
    return os.date("%H:%M:%S",curTime)
end

--抢夺panel
function OnHookPanel:initLoot()
    -- body
    self.click = true
    self.page = self.data.page
    self.maxPage = self.data.maxPage
    local LootPanel = self.panelObj:GetChild("n7")
    self.listView = LootPanel:GetChild("n4")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:ListData(index, obj)
    end
    self.listView:SetVirtual()
    if self.data.robInfo then
        for k,v in pairs(self.data.robInfo) do
            table.insert(self.roleInfo,v)
        end
        self.listView.numItems = #self.roleInfo
    end
    --两个排序按钮
    local btnPowerSort = LootPanel:GetChild("n0")
    btnPowerSort.onClick:Add(self.onClickPowerSort,self)
    local btnOffLineSort = LootPanel:GetChild("n1")
    btnOffLineSort.onClick:Add(self.onClickOfflineSort,self)
    --剩余次数
    self.leftTimesTxt = LootPanel:GetChild("n11")
    self.leftTimesTxt.text = self.data.leftTimes
    --跳过
    self.checkTiaoGuo = LootPanel:GetChild("n24")
    self.checkTiaoGuo.onChanged:Add(self.onClickCheck,self)
    self.isTiaoguo = cache.PlayerCache:getHookTiaoguo()
    self.checkTiaoGuo.selected = self.isTiaoguo
end

--自动跳过勾选
function OnHookPanel:onClickCheck(context)
    local checkBtn = context.sender
    if checkBtn.selected then
        cache.PlayerCache:setHookTiaoguo(true)
        self.isTiaoguo = true
    else
        cache.PlayerCache:setHookTiaoguo(false)
        self.isTiaoguo = false
    end
end

--战力排序
function OnHookPanel:onClickPowerSort()
    -- body
    self.listView.numItems = 0
    self.roleInfo = {}
    self.reqType = 1
    cache.PlayerCache:setoffHookType(self.reqType)
    local param = {reqType = self.reqType,execptGang = self.execptGang,execptFriend = self.execptFriend,page = 1}
    proxy.RankProxy:sendRankMsg(1030132,param)
end
--离线排序
function OnHookPanel:onClickOfflineSort()
    -- body
    self.listView.numItems = 0
    self.roleInfo = {}
    self.reqType = 2
    cache.PlayerCache:setoffHookType(self.reqType)
    local param = {reqType = self.reqType,execptGang = self.execptGang,execptFriend = self.execptFriend,page = 1}
    proxy.RankProxy:sendRankMsg(1030132,param)
end
--同盟筛选
function OnHookPanel:onCheckTm()
    -- body
    if self.TmcheckBtn.selected then
        self.execptGang = 1
        cache.PlayerCache:setExecptGangType(self.execptGang)
        self.roleInfo = {}
        local param = {reqType = self.reqType,execptGang = self.execptGang,execptFriend = self.execptFriend,page = 1}
        proxy.RankProxy:sendRankMsg(1030132,param)
    else
        self.execptGang = 0
        cache.PlayerCache:setExecptGangType(self.execptGang)
        self.roleInfo = {}
        local param = {reqType = self.reqType,execptGang = self.execptGang,execptFriend = self.execptFriend,page = 1}
        proxy.RankProxy:sendRankMsg(1030132,param)
    end
end
--好友筛选
function OnHookPanel:onCheckHy()
    -- body
    if self.HycheckBtn.selected then
        self.execptFriend = 1
        cache.PlayerCache:setExecptFriendType(self.execptFriend)
        self.roleInfo = {}
        local param = {reqType = self.reqType,execptGang = self.execptGang,execptFriend = self.execptFriend,page = 1}
        proxy.RankProxy:sendRankMsg(1030132,param)
    else
        self.execptFriend = 0
        cache.PlayerCache:setExecptFriendType(self.execptFriend)
        self.roleInfo = {}
        local param = {reqType = self.reqType,execptGang = self.execptGang,execptFriend = self.execptFriend,page = 1}
        proxy.RankProxy:sendRankMsg(1030132,param)
    end
end
function OnHookPanel:ListData(index,obj)
    if index + 1 >= self.listView.numItems then
        if not self.roleInfo then
            return 
        end 
        -- print("self.maxPage , self.page",self.maxPage,self.page)
        if self.maxPage == self.page then 
            --return
        else
            local param = {reqType = self.reqType,execptGang = self.execptGang,execptFriend = self.execptFriend,page = self.page+1}
            proxy.RankProxy:sendRankMsg(1030132,param)
        end
    end
    local data = self.roleInfo[index+1]
    local nameTxt = obj:GetChild("n1")
    local powerTxt = obj:GetChild("n2")
    local outlineTimeTxt = obj:GetChild("n3")
    nameTxt.text = data.name
    powerTxt.text = GTransFormNum1(data.power)
    outlineTimeTxt.text = GTotimeString2(data.outlineTime)
    if data.isEnemy == 1 then
        obj:GetChild("n6").visible = true
    else
        obj:GetChild("n6").visible = false
    end
    local btnLoot = obj:GetChild("n5")
    btnLoot.data = data.roleId
    btnLoot.onClick:Add(self.onClickLoot,self)
    local beCareImg = obj:GetChild("n4")
    if data.canRob == 1 then
        btnLoot.visible = true
        beCareImg.visible = false
    else
        btnLoot.visible = false
        beCareImg.visible = true
    end
end

function OnHookPanel:sendMsg()
    -- body
    self:onController()
end

function OnHookPanel:setVisible(visible)
    -- body
    self.panelObj.visible = visible
end

--抢夺按钮可点击
function OnHookPanel:canClick()
    self.click = true
end

--抢夺按钮
function OnHookPanel:onClickLoot( context )
    -- body
    local cell = context.sender
    local id = cell.data
    local param = {roleId = id}
    if self.data.leftTimes and self.data.leftTimes > 0 then
        if self.click then
            if cache.PlayerCache:getHookTiaoguo() then
                proxy.ActivityProxy:sendMsg(1030135,{reqType = 1,roleId = id})
            else
                self.click = false
                cache.ArenaCache:setArenaFight(false)
                cache.ArenaCache:setOtherRoleId(id)
                proxy.ActivityProxy:send(1030133,param)
            end
        end
    else
        GComAlter(language.welfare31)
    end
end

return OnHookPanel