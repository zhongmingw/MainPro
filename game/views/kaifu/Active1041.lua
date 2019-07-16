--
-- Author: EVE
-- Date: 2017-08-24 14:55:17
--

local Active1041 = class("Active1041", base.BaseView)

function Active1041:ctor(param)
    self.view = param
    self:initView()
end

function Active1041:initView()
    self.leftTime = self.view:GetChild("n16")  --倒计时
    self.leftTime.text = ""

    self.firstConfData = conf.ActivityConf:getLevelRankReward(104101).awards --第一名的奖励物品
    local firstReward = self.view:GetChild("n9") 
    self:setAwards(firstReward,self.firstConfData)

    self.otherRankReward = self.view:GetChild("n4")--其他排行奖励
    self:initOtherRankReward()

    self.firstName = self.view:GetChild("n18")--第一名信息
    self.firstName.text = ""
    self.firstLevel = self.view:GetChild("n19")
    self.firstLevel.text = ""
    self.power = self.view:GetChild("n21")
    self.power.text = ""
    self.icon = self.view:GetChild("n20")
    self.icon.url = nil

    self.btnRankingView = self.view:GetChild("n22")--前往排行榜
    self.btnRankingView.onClick:Add(self.onRankingView, self)

    self:initUpListView() --*升级途径
end
--快速升级途径
function Active1041:initUpListView()
    local confData = conf.ActivityConf:getUpChannel(1041)
    local upListView = self.view:GetChild("n25")
    upListView.itemRenderer = function(index,obj)
        obj.data = confData.formViews[index + 1]
        obj.icon = UIPackage.GetItemURL("_icons2" , tostring(confData.icons[index + 1]))
    end
    upListView.numItems = #confData.icons
    upListView.onClickItem:Add(self.onCallGoto,self)
end
--跳转到对应系统
function Active1041:onCallGoto(context)
    local formView = context.data.data
    GOpenView({id = formView[1], childIndex = formView[2]})
end

function Active1041:initOtherRankReward()
    self.otherRankReward.numItems = 0
    self.otherRankReward.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.otherRankReward:SetVirtual()
end

function Active1041:itemData(index, obj)
    local tempIndex = 104102+index
    local otherConfData = conf.ActivityConf:getLevelRankReward(tempIndex)
    local otherRankRewardItem = obj:GetChild("n2")
    self:setAwards(otherRankRewardItem,otherConfData.awards) 

    local otherRanking = obj:GetChild("n1")
    local setTextColor = string.format(language.kaifuchongji01, otherConfData.ranking[1], otherConfData.ranking[2])
    if tempIndex == 104102 then
        otherRanking.text = mgr.TextMgr:getTextColorStr(setTextColor, 15)
    elseif tempIndex == 104103 then 
        otherRanking.text = mgr.TextMgr:getQualityStr1(setTextColor, 3)
    else
        otherRanking.text = mgr.TextMgr:getTextColorStr(setTextColor, 7)
    end
end

--设置奖励物品的公共函数（你真棒）
function Active1041:setAwards(listView,confData)
    listView.numItems = 0
    for k,v in pairs(confData) do
        local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
        local obj = listView:AddItemFromPool(url)
        local mId = v[1]
        local amount = v[2]
        local bind = v[3]
        local info = {mid = mId,amount = amount,bind = bind}
        GSetItemData(obj,info,true)
    end
end

function Active1041:setOpenDay( day )  --蛋蛋用
    -- body
    -- self.c1.selectedIndex = day - 1 
end

--设置第一名的称号和战力(复制王显的代码)
function Active1041:setCurId(id)
    self.id = id
    -- plog(self.id, "shengmumaliya ")

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

function Active1041:onTimer()
    if not self.data or not self.data.leftTime then plog("@呼叫后端，服务器返回为空") return end
    self.data.leftTime = self.data.leftTime-1
    if self.data.leftTime > 0 then 
        if self.data.leftTime > 86400 then --EVE 时间显示方式更改
            self.leftTime.text = GTotimeString7(self.data.leftTime)
        else
            self.leftTime.text = GTotimeString2(self.data.leftTime)
        end
    else
        self.leftTime.text = language.kaifuchongji04
    end
end

function Active1041:onRankingView()
    local view = mgr.ViewMgr:get(ViewName.RankingLevel)
    if not view then 
        mgr.ViewMgr:openView2(ViewName.RankingLevel, self.data)
    end 
end

function Active1041:add5030207(data)
    self.data = data
    -- printt(self.data)
    -- plog("哈利路亚~~~~~~~~~~")
    if self.data.rankInfos[1] then
        self.firstName.text = self.data.rankInfos[1].roleName or 0
        self.firstLevel.text = self.data.rankInfos[1].level .. language.kaifuchongji02 or 0
    else
        self.firstName.text = language.rank03
        self.firstLevel.text = 0
    end
    self.otherRankReward.numItems = 3
end 

return Active1041