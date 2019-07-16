--
-- Author: 
-- Date: 2018-07-02 12:04:02
--

local ShenQiRank = class("ShenQiRank",import("game.base.Ref"))

function ShenQiRank:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId
    self:initPanel()
end

function ShenQiRank:initPanel()
    self.view = self.mParent:getPanelObj(self.moduleId)
    self.leftTime = self.view:GetChild("n16")  --倒计时
    self.leftTime.text = ""

    self.describe = self.view:GetChild("n15") --描述：展示/结束
    self.describe.text = ""

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
function ShenQiRank:initUpListView()
    local actId 
    local activeData = cache.ActivityCache:get5030111()
    if activeData.acts and activeData.acts[1091] and activeData.acts[1091] == 1 then
        actId = 1091
    elseif activeData.acts and activeData.acts[1092] and activeData.acts[1092] == 1 then
        actId = 1092
     elseif activeData.acts and activeData.acts[1186] and activeData.acts[1186] == 1 then
        actId = 1186
    end
    local confData = conf.ActivityConf:getUpChannel(actId)
    print(actId)
    printt(confData)
    if confData then
        local upListView = self.view:GetChild("n25")
        upListView.itemRenderer = function(index,obj)
            obj.data = confData.formViews[index + 1]
            local url = UIPackage.GetItemURL("_icons" , tostring(confData.icons[index + 1]))
            if not url then 
                url = UIPackage.GetItemURL("_icons2" , tostring(confData.icons[index + 1]))
            end
            obj.icon = url
        end
        upListView.numItems = #confData.icons
        upListView.onClickItem:Add(self.onCallGoto,self)
    end
end

--跳转到对应系统
function ShenQiRank:onCallGoto(context)
    local formView = context.data.data
    GOpenView({id = formView[1], childIndex = formView[2]})
end
--其他排行奖励
function ShenQiRank:initOtherRankReward()
    self.otherRankReward.numItems = 0
    self.otherRankReward.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.otherRankReward:SetVirtual()
end

function ShenQiRank:cellData(index, obj)
    local tempIndex = 2+index
    local setTextColor = ""
    local otherConfData
    local activeData = cache.ActivityCache:get5030111()
    if activeData.acts and activeData.acts[1091] and activeData.acts[1091] == 1 then
        otherConfData = conf.ActivityConf:getShenQiRankRaward1(tempIndex)
    elseif activeData.acts and activeData.acts[1092] and activeData.acts[1092] == 1 then
        otherConfData = conf.ActivityConf:getShenQiRankRaward2(tempIndex)
    elseif activeData.acts and activeData.acts[1186] and activeData.acts[1186] == 1 then
        otherConfData = conf.ActivityConf:getShenQiRankRaward3(tempIndex) 
    end

    setTextColor = string.format(language.shenqirank03, otherConfData.ranking[1], otherConfData.ranking[2])
    
    local otherRankRewardItem = obj:GetChild("n2")

    GSetAwards(otherRankRewardItem,otherConfData.awards) 

    local otherRanking = obj:GetChild("n1")

    if tempIndex == 2 then
        otherRanking.text = mgr.TextMgr:getTextColorStr(setTextColor, 15)
    elseif tempIndex == 3 then 
        otherRanking.text = mgr.TextMgr:getQualityStr1(setTextColor, 3)
    else
        otherRanking.text = mgr.TextMgr:getTextColorStr(setTextColor, 7)
    end

end

function ShenQiRank:onTimer()
    -- if not self.data or not self.data.lastTime then plog("@呼叫后端，服务器返回为空") return end
    if self.data and self.data.lastTime then
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
end

function ShenQiRank:onRankingView()
    local view = mgr.ViewMgr:get(ViewName.RankingPower)
    if not view then 
        local param = {data = self.data,id = self.moduleId}
        mgr.ViewMgr:openView2(ViewName.RankingPower, param)
    end 
end

function ShenQiRank:setData(data)
     printt("神器排行",data)
    self.data = data
    if self.data.powerRankings[1] then--有第一名
        self.firstName.text = self.data.powerRankings[1].roleName or language.shenqirank05
        -- self.firstPower.text = language.shenqirank04 .. self.data.powerRankings[1].power or 0 

        -- if 5030409 == data.msgId then--开服
            self.firstPower.text = language.shenqirank06 .. self.data.powerRankings[1].power or 0 
        -- elseif 5030410 == data.msgId then--限时
            -- self.firstPower.text = language.shenqirank06 .. self.data.powerRankings[1].power or 0 
        -- end
    else
        self.firstName.text = language.shenqirank05
        -- self.firstPower.text = language.shenqirank04 .. 0
        -- if 5030183 == data.msgId then
            self.firstPower.text = language.shenqirank06 .. 0 
        -- end
    end

    if self.data.isShowTime == 1 then 
        self.describe.text = language.shenqirank07[1]
    else
        self.describe.text = language.shenqirank07[2]
    end 

    self.otherRankReward.numItems = 3
    self:setFirstAward()
end 

function ShenQiRank:setFirstAward()
    self:initUpListView() --*升级途径
    local activeData = cache.ActivityCache:get5030111()

    if activeData.acts and activeData.acts[1091] and activeData.acts[1091] == 1 then
        self.firstConfData = conf.ActivityConf:getShenQiRankRaward1(1).awards --第一名的奖励物品
    elseif activeData.acts and activeData.acts[1092] and activeData.acts[1092] == 1 then
        self.firstConfData = conf.ActivityConf:getShenQiRankRaward2(1).awards
    elseif activeData.acts and activeData.acts[1186] and activeData.acts[1186] == 1 then
        self.firstConfData = conf.ActivityConf:getShenQiRankRaward3(1).awards
    end

    local firstReward = self.view:GetChild("n9") 
    GSetAwards(firstReward,self.firstConfData)
    self.titleImg.url = UIPackage.GetItemURL("shenqirank" , "kaifupaihang_075")

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



return ShenQiRank