--
-- Author: EVE
-- Date: 2017-09-20 21:27:33
--

local Active1048 = class("Active1048", import("game.base.Ref"))

function Active1048:ctor(param)
    self.view = param
    self:initView()
end

function Active1048:initView()
    self.leftTime = self.view:GetChild("n16")  --倒计时
    self.leftTime.text = ""

    self.describe = self.view:GetChild("n15") --描述：展示/结束
    self.describe.text = ""

    -- self.firstConfData = conf.ActivityConf:getPowerRankRaward(1).awards --第一名的奖励物品
    -- local firstReward = self.view:GetChild("n9") 
    -- self:setAwards(firstReward,self.firstConfData)

    self.otherRankReward = self.view:GetChild("n4")--其他排行奖励
    self:initOtherRankReward()

    self.firstName = self.view:GetChild("n18")--第一名信息
    self.firstName.text = ""
    self.firstPower = self.view:GetChild("n19")
    self.firstPower.text = ""
    self.power = self.view:GetChild("n21")
    self.power.text = ""
    self.icon = self.view:GetChild("n20")
    self.icon.url = nil
    self.titleImg = self.view:GetChild("n27")
    self.btnRankingView = self.view:GetChild("n22")--前往排行榜
    self.btnRankingView.onClick:Add(self.onRankingView, self)

    -- self:initUpListView() --*升级途径
end
--快速升级途径
function Active1048:initUpListView()
    local confData = nil
    if self.id == 1048 then 
        confData = conf.ActivityConf:getUpChannel(1048)
    elseif self.id == 1049 then 
        confData = conf.ActivityConf:getUpChannel(1049)
    elseif self.id == 1051 then 
        confData = conf.ActivityConf:getUpChannel(1051)
    elseif self.id == 1075 then 
        confData = conf.ActivityConf:getUpChannel(1075)
    end 
    if confData then
        local upListView = self.view:GetChild("n25")
        upListView.itemRenderer = function(index,obj)
            obj.data = confData.formViews[index + 1]
            -- print("icons",self.id,confData.icons[index + 1])
            if self.id == 1051 then
                if tostring(confData.icons[index + 1]) == "woyaobianqiang_069" then 
                    obj.icon = UIPackage.GetItemURL("guide" , tostring(confData.icons[index + 1]))
                else
                    obj.icon = UIPackage.GetItemURL("_icons2" , tostring(confData.icons[index + 1]))
                end
            elseif self.id == 1048 then
                obj.icon = UIPackage.GetItemURL("main" , tostring(confData.icons[index + 1]))
            elseif self.id == 1075 then
                obj.icon = UIPackage.GetItemURL("_icons" , tostring(confData.icons[index + 1]))
            else
                obj.icon = UIPackage.GetItemURL("_icons2" , tostring(confData.icons[index + 1]))
            end
        end
        upListView.numItems = #confData.icons
        upListView.onClickItem:Add(self.onCallGoto,self)
    end
end
--跳转到对应系统
function Active1048:onCallGoto(context)
    local formView = context.data.data
    GOpenView({id = formView[1], childIndex = formView[2]})
end

function Active1048:initOtherRankReward()
    self.otherRankReward.numItems = 0
    self.otherRankReward.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.otherRankReward:SetVirtual()
end

function Active1048:itemData(index, obj)
    local tempIndex = 2+index
    local otherConfData = 0
    local setTextColor = ""

    if self.id == 1048 then 
        otherConfData = conf.ActivityConf:getPowerRankRaward(tempIndex)
        setTextColor = string.format(language.powerRanking03, otherConfData.ranking[1], otherConfData.ranking[2])
    elseif self.id == 1049 then 
        --TODO 跨服战力配表
        otherConfData = conf.ActivityConf:getServerPowerRankRaward(tempIndex)
        if tempIndex == 2 then 
            setTextColor = language.serverPowerRanking02
        else     
            setTextColor = string.format(language.serverPowerRanking01, otherConfData.ranking[1], otherConfData.ranking[2])
        end
    elseif self.id == 1051 then 
        otherConfData = conf.ActivityConf:getEquipRankRaward(tempIndex)
        setTextColor = string.format(language.equipPowerRanking02, otherConfData.ranking[1], otherConfData.ranking[2])
    elseif self.id == 1075 then
        otherConfData = conf.ActivityConf:getPetRankRaward(tempIndex)
        setTextColor = string.format(language.petPowerRanking02, otherConfData.ranking[1], otherConfData.ranking[2])
    end 
    local otherRankRewardItem = obj:GetChild("n2")
    -- self:setAwards
    GSetAwards(otherRankRewardItem,otherConfData.awards) 

    local otherRanking = obj:GetChild("n1")
    -- local setTextColor = string.format(language.powerRanking03, otherConfData.ranking[1], otherConfData.ranking[2])
    if tempIndex == 2 then
        otherRanking.text = mgr.TextMgr:getTextColorStr(setTextColor, 15)
    elseif tempIndex == 3 then 
        otherRanking.text = mgr.TextMgr:getQualityStr1(setTextColor, 3)
    else
        otherRanking.text = mgr.TextMgr:getTextColorStr(setTextColor, 7)
    end
end

-- --设置奖励物品的公共函数（你真棒）
-- function Active1048:setAwards(listView,confData)
--     listView.numItems = 0
--     for k,v in pairs(confData) do
--         local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
--         local obj = listView:AddItemFromPool(url)
--         local mId = v[1]
--         local amount = v[2]
--         local bind = v[3]
--         local info = {mid = mId,amount = amount,bind = bind}
--         GSetItemData(obj,info,true)
--     end
-- end

function Active1048:setOpenDay( day )  --蛋蛋用
    -- body
    -- self.c1.selectedIndex = day - 1 
end

--设置第一名的称号和战力(复制王显的代码)
function Active1048:setCurId(id)
    self.id = id
    -- plog("当前活动ID：",self.id)
    self:initUpListView() --*升级途径

    if self.id == 1048 then 
        self.firstConfData = conf.ActivityConf:getPowerRankRaward(1).awards --第一名的奖励物品
        local firstReward = self.view:GetChild("n9") 
        -- self:setAwards
        GSetAwards(firstReward,self.firstConfData)
        self.titleImg.url = UIPackage.GetItemURL("kaifu" , "kuafuzhanlipaihang_005")
    elseif self.id == 1049 then 
        --TODO 跨服战力第一名奖励
        self.firstConfData = conf.ActivityConf:getServerPowerRankRaward(1).awards --第一名的奖励物品
        local firstReward = self.view:GetChild("n9") 
        -- self:setAwards
        GSetAwards(firstReward,self.firstConfData)
        self.titleImg.url = UIPackage.GetItemURL("kaifu" , "kuafuzhanlipaihang_005")
    elseif self.id == 1051 then 
        --TODO 装备战力第一名奖励
        self.firstConfData = conf.ActivityConf:getEquipRankRaward(1).awards --第一名的奖励物品
        local firstReward = self.view:GetChild("n9") 
        -- self:setAwards
        GSetAwards(firstReward,self.firstConfData)
        self.titleImg.url = UIPackage.GetItemURL("kaifu" , "kaifupaihang_060")
    elseif self.id == 1075 then
        self.firstConfData = conf.ActivityConf:getPetRankRaward(1).awards --第一名的奖励物品
        local firstReward = self.view:GetChild("n9") 
        -- self:setAwards
        GSetAwards(firstReward,self.firstConfData)
        self.titleImg.url = UIPackage.GetItemURL("kaifu" , "kaifupaihang_063")
    end 

    local chenghao = nil 
    for k,v in pairs(self.firstConfData) do
        local itemdata = conf.ItemConf:getItem(v[1])   
        if itemdata.auto_use_type == 9 then --这个是称号
            chenghao = itemdata
            break
        end
    end
    if chenghao then
        local confdata = conf.RoleConf:getTitleData(chenghao.ext01)
        --printt(confdata)
        if not confdata then
            plog("@策划 ",chenghao.id,"称号配置里面没有",chenghao.ext01)
        else
            self.power.text = language.kaifuchongji03..confdata.power or language.kaifuchongji03..0
            self.icon.url = UIPackage.GetItemURL("head" , tostring(confdata.scr))
        end      
    else
        plog("@策划 称号配置不存在")
        self.power.text = 0
        self.icon.url = nil 
    end
end

function Active1048:onTimer()
    if not self.data or not self.data.lastTime then plog("@呼叫后端，服务器返回为空") return end
    self.data.lastTime = self.data.lastTime-1
    if self.data.lastTime > 0 then 
        if self.data.lastTime > 86400 then 
            self.leftTime.text = GTotimeString7(self.data.lastTime)
        else
            self.leftTime.text = GTotimeString2(self.data.lastTime)
        end
    else
        self.leftTime.text = language.kaifuchongji04
    end
end

function Active1048:onRankingView()
    local view = mgr.ViewMgr:get(ViewName.RankingPower)
    if not view then 
        local param = {data = self.data,id = self.id}
        mgr.ViewMgr:openView2(ViewName.RankingPower, param)
    end 
end

function Active1048:add5030148(data)

    self.data = data
    -- printt(self.data)
    -- printt("哈利路亚~~~~~~~~~~",self.data)
    if self.data.powerRankings[1] then
        self.firstName.text = self.data.powerRankings[1].roleName or language.powerRanking02
        self.firstPower.text = language.powerRanking01 .. self.data.powerRankings[1].power or 0 
        if 5030183 == data.msgId then
            self.firstPower.text = language.powerRanking01_1 .. self.data.powerRankings[1].power or 0 
        end
    else
        self.firstName.text = language.powerRanking02
        self.firstPower.text = language.powerRanking01 .. 0
        if 5030183 == data.msgId then
            self.firstPower.text = language.powerRanking01_1 .. 0 
        end
    end

    if self.data.isShowTime == 1 then 
        self.describe.text = language.powerRanking04[1]
    else
        self.describe.text = language.powerRanking04[2]
    end 

    self.otherRankReward.numItems = 3
end 

return Active1048