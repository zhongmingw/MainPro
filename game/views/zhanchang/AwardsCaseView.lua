--战场奖励概况
local AwardsCaseView = class("AwardsCaseView",base.BaseView)

function AwardsCaseView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function AwardsCaseView:initView()
    local btnClose = self.view:GetChild("n7")
    btnClose.onClick:Add(self.onClickClose,self)
    self.listView = self.view:GetChild("n9")
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")
    self.timeTxt = self.view:GetChild("n8")
    self.titleIcon = self.view:GetChild("n11")
    
    self:initListView()
    self:initGangWarPanel()
    self:initWendingPanel()
    self:initXianMoPanel()
end

function AwardsCaseView:initListView()
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end
--问鼎战
function AwardsCaseView:initWendingPanel()
    local panel = self.view:GetChild("n14")
    self.wendingScore = panel:GetChild("n4")
    self.wendingFloor = panel:GetChild("n5")
    self.wendingRank = panel:GetChild("n6")
    self.wendingCount = panel:GetChild("n7")
    self.wendingListView = panel:GetChild("n11")
    self.wendingListView:SetVirtual()
    self.wendingListView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
end
--仙盟战
function AwardsCaseView:initGangWarPanel()
    local panel = self.view:GetChild("n13")
    self.gangListView = panel:GetChild("n4")
    self.gangListView:SetVirtual()
    self.gangListView.itemRenderer = function (index,obj)
        self:cellGangRankdata(index, obj)
    end
end
--仙魔战
function AwardsCaseView:initXianMoPanel()
    local panel = self.view:GetChild("n15")
    self.xianmoListView = panel:GetChild("n11")
    self.xianmoListView:SetVirtual()
    self.xianmoListView.itemRenderer = function (index,obj)
        self:cellXianMoRankdata(index, obj)
    end
    self.myKill = panel:GetChild("n13")--我的击杀
    self.xianmoScore = panel:GetChild("n4")--我的积分
    self.xianmoKill = panel:GetChild("n5")--最高连杀
    self.xianmoCamp = panel:GetChild("n6")--胜利阵营
end

function AwardsCaseView:initData(data)
    if not self or not self.c2 then
        return
    end
    
    self.data = data
    local type = data.type--1.皇陵 2.问鼎 3.仙盟战 4.仙魔 , 5 三界真把 ,7 再次获取bxp
    if type then
        self.c2.selectedIndex = type - 1
        if type == 2 then
            self.wendingScore.text = data.myScore
            self.wendingFloor.text = data.maxFloor
            local ranking = data.ranking
            if ranking <= 0 then
                ranking = language.rank04
            end
            self.wendingRank.text = ranking
            self.wendingCount.text = data.keepFlagTimes 
            self.wendingListView.numItems = #self.data.items
        elseif type == 3 then
            table.sort(self.data.ranks,function(a,b)
                return a.rank < b.rank
            end)
            self.gangListView.numItems = #self.data.ranks
        elseif type == 4 then
            self.xianmoScore.text = data.score
            self.myKill.text = data.killCount
            self.xianmoKill.text = data.maxConKillCount
            self.xianmoCamp.text = language.xianmoWar17[data.winCampId]
            self.xianmoListView.numItems = #self.data.items
        elseif type == 5 then
            self.listView.numItems = #data.items  
            self.view:GetChild("n16").text = data.richtext or ""
        elseif type == 6 then
            self.listView.numItems = #data.items  
            local ourGangName = cache.PlayerCache:getGangName()--我的仙盟
            local otherGangName = data.winGangName--敌人的仙盟
            if ourGangName == data.winGangName then
                otherGangName = data.failGangName
            end
            
            local campName1,campName2 = ourGangName,otherGangName
            local campUrl1,campUrl2 = 1,2
            if data.campType == 2 then
                campName1,campName2 = otherGangName,ourGangName
                campUrl1,campUrl2 = 2,1
            end
            self.view:GetChild("n17").url = UIItemRes.xmhd01[campUrl1]
            self.view:GetChild("n18").url = UIItemRes.xmhd01[campUrl2]
            self.view:GetChild("n19").text = campName1 or ""
            self.view:GetChild("n20").text = campName2 or ""
        elseif type == 7 then --再次挑战bxp
            self.listView.numItems = #data.items  
            self.view:GetChild("n16").text = data.richtext or ""
            self.view:GetChild("n23").url = UIItemRes.icon01[MoneyType.gold]
            self.view:GetChild("n24").text = data.cost
            local getAgain = self.view:GetChild("n22")
            getAgain.data = data 
            getAgain.onClick:Add(self.onGetAgain,self)

        end
    else
        self.c2.selectedIndex = 0
        local len = #data.items
        if len <= 0 and not data.show then--没有奖励就隐藏
            self.c1.selectedIndex = 1
        else
            self.c1.selectedIndex = 0
        end
        self.listView.numItems = len
    end
    self.titleIcon.url = data.titleUrl
    if self.effect then--出现特效
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    self.effect = self:addEffect(4020105, self.view:GetChild("n10"))

    self.timeNum = 9
    local msgId = self.data.msgId or 0
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil 
    end
    self.timeTxt.text = string.format(language.fuben11,self.timeNum)
    self.timer = self:addTimer(1,-1,handler(self, self.timeTick))
end

function AwardsCaseView:onGetAgain(context)
    local data = context.sender.data
    local ybAmount = cache.PackCache:getPackDataById(PackMid.gold).amount
    local roleLv = cache.PlayerCache:getRoleLevel()
    -- print("roleLv",roleLv,"开放等级",data.openLv)
    -- if data then 
    --     local param = {}
    --     param.sceneId = data.sceneId
    --     param.title = language.fuben201
    --     param.oneCost = data.cost
    --     param.times = data.leftCount  --剩余挑战次数
    --     param.costYb = data.leftCount * data.cost
    --     param.haveYb = ybAmount
    --     if data.leftCount <= 0 then
    --         GComAlter(language.fuben204)
    --     elseif data.openLv and roleLv < data.openLv then 
    --         GComAlter(string.format(language.fuben205,data.openLv))
    --     else
    --         mgr.ViewMgr:openView2(ViewName.GetAgainView,param)
    --     end
    -- end
    if data.leftCount <= 0 then
        GComAlter(language.fuben204)
    elseif data.openLv and roleLv < data.openLv then 
        GComAlter(string.format(language.fuben205,data.openLv))
    else
        proxy.FubenProxy:send(1027406,{sceneId = data.sceneId,times = 1})
        if self.data.sceneId and self.data.sceneId == 233001 then 
            proxy.FubenProxy:send(1027301)--刷新单人谧静
        else
            proxy.FubenProxy:send(1027401)--刷新组队仙域
        end
    end
    self:onClickClose()
end 


function AwardsCaseView:celldata( index,obj )
    local data = self.data.items[index+1]
    if data then
        GSetItemData(obj,data)
    end
end
--[[
结构体描述：仙盟战结束排名
结构体名：XianMengWarFinishRank
备注：备注：
1   int32   变量名: rank   说明: 排名
2   int32   变量名: zone   说明: 战区
3   int32   变量名: integral   说明: 积分
4   string  变量名: gang   说明: 仙盟]]
--仙盟战排行信息
function AwardsCaseView:cellGangRankdata(index,cell)
    local data = self.data.ranks[index + 1]
    local rank = data.rank
    cell:GetChild("n1").text = rank
    cell:GetChild("n2").text = data.gang
    cell:GetChild("n3").text = data.integral
    local listView = cell:GetChild("n0")
    local confData = conf.GangWarConf:getRankAwards(data.zone,rank)
    local awards = confData and confData.items or {}
    listView.itemRenderer = function(index,obj)
        local award = awards[index + 1]
        local itemData = {mid = award[1],amount = award[2], bind = award[3]}
        GSetItemData(obj, itemData)
    end
    listView.numItems = #awards
end

function AwardsCaseView:cellXianMoRankdata(index,obj)
    local data = self.data.items[index+1]
    if data then
        GSetItemData(obj,data)
    end
end

function AwardsCaseView:timeTick()
    if not self.data then
        return
    end
    if self.timeNum > 0 then
        self.timeNum = self.timeNum - 1
        self.timeTxt.text = string.format(language.fuben11,self.timeNum)
    else
        self:onClickClose()
    end
end

function AwardsCaseView:onClickClose()
    self.listView.numItems = 0
    if self.c2 then
        self.c2.selectedIndex = 0
    end
    self.titleIcon.url = ""
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isKuaFuWar(sId) then
        self:closeView()
        return 
    elseif mgr.FubenMgr:isKuaFuTeamFuben(sId)  then
        mgr.FubenMgr:quitFuben()
        self:closeView()
        return
    elseif mgr.FubenMgr:isWenDing(sId) then
        cache.WenDingCache:cleanSid()
    end
    local isQuit = false
    if mgr.FubenMgr:isWenDing(sId) 
        or mgr.FubenMgr:isXianMoWar(sId) 
        or mgr.FubenMgr:isGangWar(sId) 
        or mgr.FubenMgr:isHuangLing(sId) then
        isQuit = true
    end
    local msgId = self.data.msgId or 0
    if mgr.FubenMgr:isXianyu(sId) and msgId == 8180601 then
        isQuit = true
    end
    if mgr.FubenMgr:isMjxlScene(sId) and msgId == 8180702 then 
        isQuit = true 
    end
    if mgr.FubenMgr:isJianShengshouhu(sId) and msgId == 8180801 then
        isQuit = true 
    end
    if mgr.FubenMgr:isHjzyScene(sId) and msgId == 8180703 then
        isQuit = true 
    end
    if isQuit then
        mgr.FubenMgr:quitFuben()
    end
    self:closeView()
end

return AwardsCaseView