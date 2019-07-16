--
-- Author: Your Name
-- Date: 2018-12-17 11:54:27
--

local YiJiCityInfoView = class("YiJiCityInfoView", base.BaseView)

function YiJiCityInfoView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function YiJiCityInfoView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    --城池名字
    self.cityName = self.view:GetChild("n3")
    --城池内探索玩家数量
    self.playerNum = self.view:GetChild("n4")
    --当前剩余探索或掠夺次数
    self.countTxt = self.view:GetChild("n5")
    --剩余掠夺次数
    self.lueduoCountTxt = self.view:GetChild("n23")
    --当前剩余探索或掠夺时间
    self.timeDecTxt = self.view:GetChild("n6")
    self.timeTxt = self.view:GetChild("n7")
    --所选玩家战力
    self.powerTxt = self.view:GetChild("n13")
    --所选玩家模型
    self.modelPanel = self.view:GetChild("n22")
    --剩余血量
    self.hpBar = self.view:GetChild("n15")
    --奖励列表
    self.listView = self.view:GetChild("n19")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()  

    --地图区域
    self.mapPanel = self.view:GetChild("n1"):GetChild("n1")
    --探索掠夺按钮
    self.exploreBtn = self.view:GetChild("n20")
    self.exploreBtn.onClick:Add(self.onClickExplore,self)
    --减冷却按钮
    self.cutBtn = self.view:GetChild("n8")
    self.cutBtn.onClick:Add(self.onClickCut,self)
    --增加剩余次数按钮
    self.addBtn = self.view:GetChild("n9")
    self.addBtn.onClick:Add(self.onClickAdd,self)
end

function YiJiCityInfoView:initData(data)
    self.timeNum = 0--倒计时
    self.info = nil--保存玩家信息
    self.kengId = nil
    self.cityId = data.cityId
    local confData = conf.YiJiTanSuoConf:getCityInfoById(self.cityId)
    self.cityName.text = confData.name

    self.mapPanel:RemoveChildren()
    self.bg = UIPackage.CreateObject("yiji","Component5")
    if self.bg then
        local imgPath = UIItemRes.zhanchang..confData.bg_img
        self.mapPanel:AddChild(self.bg)
        self.bg.xy = Vector2.New(0,0)
        self:setLoaderUrl(self.bg:GetChild("n0"),imgPath)
    end
    self.kengTab = {}--保存当前地图坑位
    for i=1,confData.max_size do
        local obj = UIPackage.CreateObject("yiji", "Component3")
        self.mapPanel:AddChildAt(obj,i)
        local pos = confData.pos[i]
        local kengImg = obj:GetChild("n1")
        local selectImg = obj:GetChild("n2")
        kengImg.url = UIPackage.GetItemURL("yiji" , confData.keng_img)
        selectImg.url = UIPackage.GetItemURL("yiji" , confData.keng_selectImg)
        obj.x = pos[1]
        obj.y = pos[2]
        obj.data = i
        obj.onClick:Add(self.onClickCheck,self)
        table.insert(self.kengTab,obj)
    end
    proxy.YiJiTanSuoProxy:sendMsg(1640103,{cityId = self.cityId})
end

--设置坑位panel
function YiJiCityInfoView:setKengPanel()
    for k,v in pairs(self.kengTab) do
        local decTxt = v:GetChild("n0")
        local kengId = v.data
        local flag,info = self:isHasPlayer(kengId)
        if flag then
            decTxt.text = info.roleName .. language.yjts23
        else
            decTxt.text = language.yjts24
        end
    end
end

function YiJiCityInfoView:celldata(index,obj)
    local data = self.awardsData[index+1]
    local itemObj = obj:GetChild("n5")
    if data then
        itemObj.visible = true
        GSetItemData(itemObj, data, true)
    else
        itemObj.visible = false
    end
end

-- array<YjtsPlayerInfo>   变量名：playerInfos 说明：玩家信息
-- YjtsPlayerInfo  变量名：myInfo  说明：我的探索信息
-- 变量名：startTime   说明：探索开始时间，若0，则没有探索
-- 变量名：lastRobTime 说明：上次掠夺时间
function YiJiCityInfoView:setData(data)
    -- printt("城池场景信息返回>>>>>>>",data)
    self.playerInfos = data.playerInfos
    self.myInfo = data.myInfo
    self.startTime = data.startTime
    self.lastRobTime = data.lastRobTime
    if not self.info or self.info.roleId == self.myInfo.roleId then
        self.info = self.myInfo
    else
        local flag = false
        local info = nil
        for k,v in pairs(self.playerInfos) do
            if self.info.roleId == v.roleId then
                flag = true
                info = v
                break
            end
        end
        if flag then
            self.info = info
        else
            self.info = self.myInfo
        end
    end
    self:setRightInfo()
    local confData = conf.YiJiTanSuoConf:getCityInfoById(self.cityId)
    local num = self.playerInfos and #self.playerInfos or 0
    self.playerNum.text = string.format(language.yjts22,num,confData.max_size)
    --
    self:setKengPanel()
end

--判断当前坑位是否有人
function YiJiCityInfoView:isHasPlayer(kengId)
    local flag = false
    local info = nil--坑位玩家信息
    for k,v in pairs(self.playerInfos) do
        if v.holeId == kengId then
            flag = true
            info = v
            break
        end
    end
    return flag,info
end

--点击城池查看
function YiJiCityInfoView:onClickCheck(context)
    local kengId = context.sender.data
    if not kengId then
        return
    end
    for k,v in pairs(self.kengTab) do
        if kengId == v.data then
            v.selected = true
        else
            v.selected = false
        end
    end
    self.kengId = kengId
    local flag,info = self:isHasPlayer(kengId)
    -- print("坑位id>>>>>>>>",kengId,flag)
    if flag then
        -- print("info>>>>>",info)
        self.info = info
        self:setRightInfo()
    else
        self.info = self.myInfo
        self:setRightInfo()
    end
end

--设置右侧信息
function YiJiCityInfoView:setRightInfo()
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
        self.timeNum = 0
    end
    local data = self.info
    local kengId = self.kengId
    local robbing_times = conf.YiJiTanSuoConf:getYiJiGlobal("robbing_times")
    local robbingCount = cache.YiJiTanSuoCache:getRobbingCount()
    local robbingBuyCount = cache.YiJiTanSuoCache:getRobbingBuyCount()
    local find_times = conf.YiJiTanSuoConf:getYiJiGlobal("find_times")
    local exploreCount = cache.YiJiTanSuoCache:getExploreCount()
    local buyCount = cache.YiJiTanSuoCache:getBuyCount()
    self.countTxt.text = string.format(language.yjts03,exploreCount,(buyCount+find_times))
    self.lueduoCountTxt.text = string.format(language.yjts06,robbingCount,(robbingBuyCount+robbing_times))
    self.addBtn.data = {type = 1}
    if data.roleId == self.myInfo.roleId then
        self.timeDecTxt.text = language.yjts04
        self.exploreBtn.data = {type = 1,kengId = kengId}--探索
        self.cutBtn.data = {type = 1}
        if self.startTime == 0 then
            self.timeTxt.text = language.yjts07
        else
            local find_time = conf.YiJiTanSuoConf:getYiJiGlobal("find_time")
            local netTime = mgr.NetMgr:getServerTime()
            self.timeNum = (self.startTime + find_time) - netTime
            self.timeTxt.text = GGetTimeData4(self.timeNum)
            self.timeCount = 10--用来计时 每10秒钟发一次请求刷新奖励背包
            self.timer = self:addTimer(1, -1, handler(self,self.timeTick))
        end
        self.exploreBtn.icon = UIPackage.GetItemURL("yiji","yijitaunshuo_014")
        if (data.packItems and #data.packItems > 0 and self.startTime == 0) or self.timeNum > 0 then
            self.exploreBtn.icon = UIPackage.GetItemURL("yiji","yijitaunshuo_016")
        end
    else
        self.timeDecTxt.text = language.yjts05
        self.exploreBtn.data = {type = 2,roleId = data.roleId}--掠夺
        self.cutBtn.data = {type = 2}
        -- self.addBtn.data = {type = 2}
        self.exploreBtn.icon = UIPackage.GetItemURL("yiji","yijitaunshuo_015")

        local robbing_cooling_time = conf.YiJiTanSuoConf:getYiJiGlobal("robbing_cooling_time")
        local netTime = mgr.NetMgr:getServerTime()
        local coldingTime = (self.lastRobTime + robbing_cooling_time) - netTime
        if coldingTime <= 0 then
            self.timeTxt.text = language.yjts08
        else
            --掠夺冷却时间
            self.timeNum = coldingTime
            self.timeTxt.text = GGetTimeData4(self.timeNum)
            self.timer = self:addTimer(1, -1, handler(self,self.timeTick))
        end
    end
    self.powerTxt.text = data.power
    local skinId = data.skins[Skins.clothes]
    local wuqiId = data.skins[Skins.wuqi]
    if data.roleId == self.myInfo.roleId and not skinId then
        skinId = cache.PlayerCache:getSkins(Skins.clothes)
        wuqiId = cache.PlayerCache:getSkins(Skins.wuqi)
    end
    local modelObj = self:addModel(skinId, self.modelPanel)
    modelObj:setSkins(nil,wuqiId,nil)
    modelObj:setScale(90)
    modelObj:setPosition(0,-400,1100)
    modelObj:setRotationXYZ(0,150,0)
    --血条显示
    self.hpBar.value = data.currHp
    self.hpBar.max = data.maxHp
    --奖励背包
    self.awardsData = data.packItems
    local awardsNum = self.awardsData and #self.awardsData or 0
    self.listView.numItems = math.max((math.ceil(awardsNum/4)*4),8)
end

function YiJiCityInfoView:timeTick()
    if self.timeNum > 0 then
        self.timeNum = self.timeNum - 1
        self.timeTxt.text = GGetTimeData4(self.timeNum)
        if self.timeCount then
            self.timeCount = self.timeCount - 1
            if self.timeCount == 0 then
                self.timeCount = 10
                -- print("刷新奖励>>>>>>>>>>>>>")
                self:refreshView()
            end
        end
    else
        -- self.timeTxt.text = language.yjts07
        if self.timer then
            self:removeTimer(self.timer)
            self.timer = nil
            self.timeNum = 0
            self.timeCount = 10
            self:refreshView()
        end
    end
end

--探索掠夺
function YiJiCityInfoView:onClickExplore(context)
    local data = context.sender.data
    if not data then
        return
    end
    if data.type == 1 then--探索
        local exploreCount = cache.YiJiTanSuoCache:getExploreCount()
        local awardsNum = self.awardsData and #self.awardsData or 0
        if awardsNum > 0 and self.startTime == 0 then--领取奖励
            proxy.YiJiTanSuoProxy:sendMsg(1640106)
        else
            if self.timeNum > 0 then
                GComAlter(language.yjts09)
            elseif exploreCount <= 0 then
                GComAlter(language.yjts10)
            elseif not data.kengId then
                GComAlter(language.yjts13)
            else
                proxy.YiJiTanSuoProxy:sendMsg(1640104,{cityId = self.cityId,holeId = data.kengId})
            end
        end
    elseif data.type == 2 then--掠夺
        if mgr.FubenMgr:checkScene() then
            GComAlter(language.gonggong41)
            return
        end
        local confData = conf.YiJiTanSuoConf:getCityInfoById(self.cityId)
        if confData.cross_type and confData.cross_type == 2 then--跨服的才可以掠夺
            local robbingCount = cache.YiJiTanSuoCache:getRobbingCount()
            local find_time = conf.YiJiTanSuoConf:getYiJiGlobal("find_time")
            local netTime = mgr.NetMgr:getServerTime()
            local tansuoTime = (self.startTime + find_time) - netTime
            if tansuoTime > 0 then
                GComAlter(language.yjts12)
            elseif robbingCount <= 0 then
                GComAlter(language.yjts11)
            elseif self.timeNum > 0 then
                GComAlter(language.yjts14)
            else
                proxy.YiJiTanSuoProxy:sendMsg(1640107,{cityId = self.cityId,roleId = data.roleId})
            end
        else
            GComAlter(language.yjts25)
        end
    end
end

--减少冷却按钮
function YiJiCityInfoView:onClickCut(context)
    local data = context.sender.data
    if not data then
        return
    end
    local exploreCost = conf.YiJiTanSuoConf:getYiJiGlobal("qick_find_cost")
    local lueduoCost = conf.YiJiTanSuoConf:getYiJiGlobal("cooling_remove_cost")
    local costMoney = lueduoCost[1]
    local myMoney = 0
    for k,v in pairs(BuyMoneyType[lueduoCost[2]]) do
        local money = cache.PlayerCache:getTypeMoney(v)
        myMoney = money + myMoney
    end
    local param = {}
    local textData = clone(language.yjts16)
    textData[2].text = string.format(textData[2].text,costMoney)
    if data.type == 1 then
        myMoney = 0
        for k,v in pairs(BuyMoneyType[exploreCost[3]]) do
            local money = cache.PlayerCache:getTypeMoney(v)
            myMoney = money + myMoney
        end
        costMoney = math.ceil(self.timeNum/exploreCost[1]) * exploreCost[2]
        textData = clone(language.yjts17)
        textData[2].text = string.format(textData[2].text,costMoney)
    end
    local str = mgr.TextMgr:getTextByTable(textData)
    param.richText = str
    param.func = function()
        if data.type == 1 then
            if myMoney >= costMoney then
                proxy.YiJiTanSuoProxy:sendMsg(1640105,{cityId = self.myInfo.cityId})
            else
                GComAlter(language.gonggong18)
            end
        else
            if myMoney >= costMoney then
                proxy.YiJiTanSuoProxy:sendMsg(1640108)
            else
                GComAlter(language.gonggong18)
            end
        end
    end
    if self.timeNum > 0 then
        mgr.ViewMgr:openView2(ViewName.YiJiTanSuoTips, param)
    else
        if data.type == 1 then
            GComAlter(language.yjts07)
        else
            GComAlter(language.yjts18)
        end
    end
end

--增加次数按钮
function YiJiCityInfoView:onClickAdd(context)
    local data = context.sender.data
    if not data then
        return
    end
    local costNum = conf.YiJiTanSuoConf:getYiJiGlobal("yjts_buy_count_price")
    local costType = conf.YiJiTanSuoConf:getYiJiGlobal("buy_count_money_type")
    local myMoney = 0
    for k,v in pairs(BuyMoneyType[costType]) do
        local money = cache.PlayerCache:getTypeMoney(v)
        myMoney = myMoney + money
    end
    local vipLv = cache.PlayerCache:getVipLv()
    if data.type == 1 then--探索次数
        local buyTimes = cache.YiJiTanSuoCache:getBuyCount()
        local canBuyTimes = conf.VipChargeConf:getYiJiTanSuoBuyTimes(vipLv)
        print("可购买次数>>>>>>",canBuyTimes)
        if canBuyTimes <= buyTimes then
            GComAlter(language.yjts19)
        elseif myMoney < costNum[1] then
            GComAlter(language.gonggong18)
        else
            local param = {}
            local textData = clone(language.yjts15)
            textData[2].text = string.format(textData[2].text,costNum[1])
            textData[7].text = string.format(textData[7].text,canBuyTimes - buyTimes)
            local str = mgr.TextMgr:getTextByTable(textData)
            param.richText = str
            param.func = function()
                proxy.YiJiTanSuoProxy:sendMsg(1640102,{reqType = 0})
            end
            mgr.ViewMgr:openView2(ViewName.YiJiTanSuoTips, param)
        end
    else--掠夺次数
        local buyTimes = cache.YiJiTanSuoCache:getRobbingBuyCount()
        local canBuyTimes = conf.VipChargeConf:getYiJiLueDuoBuyTimes(vipLv)
        if canBuyTimes <= buyTimes then
            GComAlter(language.yjts19)
        elseif myMoney < costNum[2] then
            GComAlter(language.gonggong18)
        else
            local param = {}
            local textData = clone(language.yjts15_1)
            textData[2].text = string.format(textData[2].text,costNum[2])
            textData[7].text = string.format(textData[7].text,canBuyTimes - buyTimes)
            local str = mgr.TextMgr:getTextByTable(textData)
            param.richText = str
            param.func = function()
                proxy.YiJiTanSuoProxy:sendMsg(1640102,{reqType = 1})
            end
            mgr.ViewMgr:openView2(ViewName.YiJiTanSuoTips, param)
        end
    end
end

--刷新场景
function YiJiCityInfoView:refreshView()
    --开始探索后请求刷新场景信息
    proxy.YiJiTanSuoProxy:sendMsg(1640103,{cityId = self.cityId})
end

function YiJiCityInfoView:clear()
    if g_var.gameFrameworkVersion >= 2 then
        UnityResMgr:ForceDelAssetBundle(UIItemRes.zhanchang.."yijitaunshuo_009")
    end
    self.bg = nil
    print("YiJiCityInfoView>>>>>>>>clear()")
end

return YiJiCityInfoView