--
-- Author: ohf
-- Date: 2017-07-15 10:58:29
--
--战斗场景任务追踪
local TrackView = class("TrackView", base.BaseView)

local FubenTrack = import(".FubenTrack")

local BossTrack = import(".BossTrack")

local WenDingTrack = import(".WenDingTrack")

local GangBossTrack = import(".GangBossTrack")

local KuaFuTeamPanel = import(".KuaFuTeamPanel")

local MarryTrack = import(".MarryTrack")

local DuJieTrack = import(".DuJieTrack")

local KuaFuWar = import(".KuaFuWar")

local XianMoTrack = import(".XianMoTrack")

local AwakenTrack = import(".AwakenTrack")

local ShoutaTrack = import(".ShoutaTrack")

local MjxlTrack = import(".MjxlTrack")--秘境修炼和幻境镇妖

local XmzbTrack = import(".XmzbTrack")--秘境修炼和幻境镇妖

local Daytrack = import(".Daytrack")

local XdzzTrack = import(".XdzzTrack")

local CdmhTrack = import(".CdmhTrack")

local TeamInfoPanel = import("game.views.main.TeamInfo")--队伍区域

local CityWarTrack = import(".CityWarTrack")

local WanShenDianTrack = import(".WanShenDianTrack")

local WsjTrack = import(".WsjTrack")



function TrackView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheForever
end


function TrackView:initView()
    self.ctrl1 = self.view:GetController("c1")
    self.ctrl2 = self.view:GetController("c2")
    self.ctrl3 = self.view:GetController("c3")--任务栏操作
    self.ctrl4 = self.view:GetController("c4")
    self.t0 = self.view:GetTransition("t0")
    self.t1 = self.view:GetTransition("t1")
    self.t2 = self.view:GetTransition("t2")
    self.t3 = self.view:GetTransition("t3")
    self.t4 = self.view:GetTransition("t4")
    self.titlePanel = self.view:GetChild("n7")
    self:hidePanel()
    self.nameText = self.titlePanel:GetChild("n355")
    self.trackPanel = self.view:GetChild("n0")
    self.trackCtrl = self.trackPanel:GetController("c1")
    self.listView = self.trackPanel:GetChild("n0")
    self.listView.numItems = 0
    self.quitBtn = self.trackPanel:GetChild("n4")
    self.quitBtn.onClick:Add(self.onClickQuit,self)
    local bossBzBtn = self.view:GetChild("n8")--仙盟招募
    bossBzBtn.onClick:Add(self.onClickBossBz,self)
    self.zmCdImg = bossBzBtn:GetChild("n6").asImage
    self.zmCdImg.fillAmount = 0
    self.oldZmTime = 0--记录招募时间

    local fightingBtn = self.trackPanel:GetChild("n5")
    self.fightingBtn = fightingBtn
    self.fightingBtn.title = language.fuben113[1]
    fightingBtn.onClick:Add(self.onClickFight,self)
    local arrowBtn = self.view:GetChild("n5")
    arrowBtn.onClick:Add(self.onClickArrow,self)

    local expDrugBtn = self.view:GetChild("n13")--经验药水
    expDrugBtn.onClick:Add(self.onClickDrug,self)
    
    local lirenBtn = self.view:GetChild("n12")--利刃
    lirenBtn.onClick:Add(self.onClickLiren,self)

    self.ragePanel = self.view:GetChild("n16") --怒气值（仙域禁地）
    self.timeTxt = self.ragePanel:GetChild("n6")
    self.rageTime = -1--怒气值满后倒计时

    --EVE 点击怒气图标时
    self.angerBg = self.ragePanel:GetChild("n8")
    self.angerText = self.ragePanel:GetChild("n9")
    self.angerText.text = language.fuben212
    self.btnAnger = self.ragePanel:GetChild("n10")  
    self.btnAnger.onClick:Add(self.onClickAnger,self)

    self.topPanel2 = self.view:GetChild("n18")
    self.top2C1 = self.topPanel2:GetController("c1")--任务队伍控制器
    self.top2C1.onChanged:Add(self.onClickTop2,self)

    self.teamListView = self.view:GetChild("n19")

    local mapBtn = self.view:GetChild("n20")
    self.mapBtn = mapBtn
    mapBtn.onClick:Add(self.onClickMap,self)
    self.acttimeTxt1 = self.view:GetChild("n24")
    self.acttimeTxt2 = self.view:GetChild("n25")
    local quitBtn = self.view:GetChild("n26")
    quitBtn.onClick:Add(self.onClickQuit2,self)
    local rankBtn = self.view:GetChild("n27")
    rankBtn.onClick:Add(self.onClickRank,self)

    local wsjArrowBtn = self.view:GetChild("n39")
    wsjArrowBtn.onClick:Add(self.onClickArrow2,self)
    self.wsjNearPlayerList = self.view:GetChild("n32"):GetChild("n38")
    self.wsjNearPlayerList:SetVirtual()
    self.wsjNearPlayerList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.wsjNearPlayerList.onClickItem:Add(self.onCallBack,self)
    self.wsjNearPlayerList.numItems = 0

    self:initPanel()
end

function TrackView:initData(data)
    self.data = data
    self:appearPanel()
    self:setData(data)
    self:setAngerShow(false)                              --这是一个开关
    local index = data and data.index
    if index == 18 then
        self:initNearPlayer()
    end
end

function TrackView:initNearPlayer()
    local data = mgr.ThingMgr:objsByType(ThingType.player) or {}
    self.nearData = {}
    for k , v in pairs(data) do
        local player = mgr.ThingMgr:getObj(ThingType.player,k)
        if player then
            table.insert(self.nearData,clone(player.data))
        end
    end
    printt("附近人",self.nearData)
    self:setNearData()
end

function TrackView:setNearData()
    self.wsjNearPlayerList.numItems = #self.nearData
    local target = mgr.FightMgr.fuji_target
    if target and mgr.ThingMgr:getObj(ThingType.player, target.data.roleId) then
        for k , v in pairs(self.nearData) do
            if v.roleId == target.data.roleId then
                self.wsjNearPlayerList:AddSelection(k-1,false)
                break
            end
        end
    end
end

function TrackView:cellData(index,obj)
    local data = self.nearData[index+1]
    local name = obj:GetChild("n36")
    local lv = obj:GetChild("n37")
    if not data  then
        obj.touchable = false
    else
        name.text = data.roleName
        lv.text = data.lv
        obj.touchable = true
    end
    obj.data = data 
end

function TrackView:onCallBack( context)
    -- body
    local data = context.data.data
    if not data then
        return
    end
    self.selectdata = data 
    mgr.FightMgr:fightByTarget2(data)
end

function TrackView:addData(data)
    if mgr.FubenMgr:isWSJChuMo(cache.PlayerCache:getSId()) then
        local flag = true
        for k ,v in pairs(self.nearData) do 
            if v.roleId == data then
                flag = false
                break
            end
        end
        if flag then
            local player = mgr.ThingMgr:getObj(ThingType.player,data)
            if player then
                table.insert(self.nearData,clone(player.data))
            end
            self:setNearData()
        end
    end
end

function TrackView:removeData( data )
    if mgr.FubenMgr:isWSJChuMo(cache.PlayerCache:getSId()) then
        for k ,v in pairs(self.nearData) do 
            if v.roleId == data then
                table.remove(self.nearData,k)
                break
            end
        end
        self:setNearData()
    end
end

--各模块初始化
function TrackView:initPanel()
    self.fubenTrack = FubenTrack.new(self,self.listView)
    self.bossTrack = BossTrack.new(self,self.listView)
    self.wenDingTrack = WenDingTrack.new(self,self.listView)
    self.kuaFuTeamPanel = KuaFuTeamPanel.new(self,self.listView)
    self.marryTrack = MarryTrack.new(self,self.listView)
    self.dujieTrack = DuJieTrack.new(self,self.listView)
    self.gangBossTrack = GangBossTrack.new(self,self.listView)
    self.KuaFuWar = KuaFuWar.new(self,self.listView)
    self.xianMoTrack = XianMoTrack.new(self,self.listView)
    self.awakenTrack = AwakenTrack.new(self,self.listView)
    self.shoutaTrack = ShoutaTrack.new(self,self.listView)
    self.mjxlTrack = MjxlTrack.new(self,self.listView)
    self.xmzbTrack = XmzbTrack.new(self,self.listView)
    self.teamInfoPanel = TeamInfoPanel.new(self.teamListView)
    self.Daytrack = Daytrack.new(self,self.listView)
    self.xdzzTrack = XdzzTrack.new(self,self.listView)
    self.cdmhTrack = CdmhTrack.new(self,self.listView)
    self.cityWarTrack = CityWarTrack.new(self,self.listView)
    self.wanShenDianTrack = WanShenDianTrack.new(self,self.listView)
    self.wsjTrack = WsjTrack.new(self,self.listView)

end

--怒气值设置
function TrackView:setRage(anger)
    local bar = self.ragePanel:GetChild("n4")
    local rageTxt = self.ragePanel:GetChild("n7")

    local v = bar.value
    local maxAnger = conf.FubenConf:getBossValue("xyjd_max_anger")
    bar.max = maxAnger
    if anger >= maxAnger and v < maxAnger then
        rageTxt.text = maxAnger
        self.rageTime = 30
        self.timeTxt.text = self.rageTime
        self.timeTxt.visible = true
        self.ragePanel:GetChild("n1").visible = true
        self.ragePanel:GetChild("n5").visible = true
    else
        rageTxt.text = anger
    end
    bar.value = anger
    if bar.value < maxAnger then
        self.timeTxt.visible = false
        self.ragePanel:GetChild("n1").visible = false
        self.ragePanel:GetChild("n5").visible = false
    end
end

--EVE
function TrackView:onClickAnger()
    if self.switch == false then
        self:setAngerShow(true)
        
        if self.angerTimer then 
            self:removeTimer(self.angerTimer)
            self.angerTimer = nil
        end 
        self.angerTimer = self:addTimer(10, 1, function()
            self:setAngerShow(false)
        end)
    else
        self:setAngerShow(false)
    end
end
function TrackView:setAngerShow(isShow)
    self.angerBg.visible = isShow
    self.angerText.visible = isShow
    self.switch = isShow
end
--
function TrackView:getXianYuBossQuitTime()
    return self.rageTime
end
function TrackView:setXianYuBossQuitTime(rageTime)
    self.rageTime = rageTime
end
--设置倒计时显示
function TrackView:setTimeTxt( timer )
    self.timeTxt.text = timer
end

function TrackView:onClickArrow()
    if self.ctrl1.selectedIndex == 0 then
        self:hidePanel()
    else
        self:appearPanel()
    end
end
function TrackView:onClickArrow2()
    if self.ctrl4.selectedIndex == 0 then
        self:hideWsjPanel()
    else
        self:appearWsjPanel()
    end
end
--经验药水
function TrackView:onClickDrug()
    mgr.ViewMgr:openView2(ViewName.ExpdrugTipView, {})
end
--利刃
function TrackView:onClickLiren()
    mgr.ViewMgr:openView(ViewName.LirenTipView, function(view)
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isMjxlScene(sId) then--秘境修炼
            proxy.FubenProxy:send(1027304,{buyType = 0})
        elseif mgr.FubenMgr:isHjzyScene(sId) then
            proxy.FubenProxy:send(1027307,{buyType = 0})
        end
    end)
end
--隐藏面板
function TrackView:hidePanel()
    self.ctrl1.selectedIndex = 1
    self.t0:Play()
end
--出现面板
function TrackView:appearPanel()
    self.ctrl1.selectedIndex = 0
    self.t1:Play()
end

--隐藏万圣节附近面板
function TrackView:hideWsjPanel()
    self.ctrl4.selectedIndex = 1
    self.t3:Play()
end
--出现万圣节附近面板
function TrackView:appearWsjPanel()
    self.ctrl4.selectedIndex = 0
    self.t4:Play()
end

function TrackView:setData(data)
    self.ctrl2.selectedIndex = 0
    local index = data and data.index
    self.index = index
    if index then
        if index == 0 then--副本
            local sId = cache.PlayerCache:getSId()
            if mgr.FubenMgr:isDayTaskFuben(sId) then
                --一个傻逼策划的要求
                self:dayFubenTrack()
            else
                self:setFubenTrack()
            end
        elseif index == 1 then--boss
            self:setBossTrack()
        elseif index == 2 then--问鼎
            self:setWenDingTrack()
        elseif index == 3 then--跨服
            self:setKuaFuTeamTrack()
        elseif index == 4 then--情緣副本
            self:setMarryTrack()
        elseif index == 5 then--渡劫副本
            self:setDuJieTrack()
        elseif index == 6 then--仙盟boss
            self:setGangBossTrack()
        elseif index == 7 then-- 跨服 三界争霸
            self:initKuaFu3War()
            if data.data then
                self:setKuaFu3War(data.data)
            end
        elseif index == 8 then-- 仙魔战
            self:setXianMoTrack()
        elseif index == 9 then-- 剑神殿
            self:setAwakenTrack()
        elseif index == 10 then --仙域
            self:initSingle()
            if data.data then
                self:setSingle(data.data)
            end
        elseif index == 11 then--秘境修炼和幻境镇妖
            self:setMjxlTrack()
        elseif index == 12 then --组队
            self:initSingle()
            if data.data then
                self:setSingle(data.data)
            end
        elseif index == 13 then--仙盟争霸
            self:setXmzbTrack()
        elseif index == 14 then
            self:setXdzzTrack()
        elseif index == 15 then
            self:setCdmhTrack()
        elseif index == 16 then
            self:setCityWarTrack()
        elseif index == 17 then
            self:setWanShenDianTrack()
        elseif index == 18 then--万圣节
            self:setWsjTrack()
        end
    end
    local sId = cache.PlayerCache:getSId()
    local sceneData = conf.SceneConf:getSceneById(sId)
    local isOperationTeam = sceneData and sceneData.is_operation_team or 0
    if isOperationTeam > 0 then
        self.ctrl3.selectedIndex = 1
    else
        self.ctrl3.selectedIndex = 0
    end
    self:onClickTop2()
    G_SetMainView(false)
end
--是否处于队伍状态
function TrackView:getIsHaveTeam()
    if self.top2C1.selectedIndex == 1 then
        return true
    end
    return false
end
--任务栏操作
function TrackView:onClickTop2()
    local sId = cache.PlayerCache:getSId()
    if self.top2C1.selectedIndex == 0 then
        self.trackPanel.visible = true
        self.teamListView.visible = false
        local view = mgr.ViewMgr:get(ViewName.MainView)
        view:setTeamBtnVisible(false)
        if mgr.FubenMgr:isWanShenDian(sId) then
            self.topPanel2:GetChild("n6").icon = UIPackage.GetItemURL("track" , "shengyin_024")
        else
            self.topPanel2:GetChild("n6").icon = UIPackage.GetItemURL("track" , "bossdating_039")
        end
    else
        self.trackPanel.visible = false
        self.teamListView.visible = true
        self:refMyTeamData1()
        if mgr.FubenMgr:isWanShenDian(sId) then
            self.topPanel2:GetChild("n6").icon = UIPackage.GetItemURL("track" , "shengyin_025")
        else
            self.topPanel2:GetChild("n6").icon = UIPackage.GetItemURL("track" , "bossdating_040")
        end
    end
end

function TrackView:onClickMap()
    mgr.ViewMgr:openView(ViewName.MapView)
end
--刷新队伍1刷新全部
function TrackView:refMyTeamData1()
    self.teamInfoPanel:setData()
end
--刷新队伍2--刷新属性
function TrackView:refMyTeamData2()
    if self.top2C1.selectedIndex == 1 then
        self.teamInfoPanel:refMyTeamData()
    end
end

function TrackView:dayFubenTrack()
    -- body
    self.trackCtrl.selectedIndex = 0
    self.quitBtn.title = language.gonggong42[1]
    self.Daytrack:setdayFubenTrack()
end

--副本追踪
function TrackView:setFubenTrack()
    self.trackCtrl.selectedIndex = 0
    self.fubenTrack:setFubenTrack()
    self.quitBtn.title = language.gonggong42[1]
end
-- --设置副本进入时间
-- function TrackView:setFubenFirstTime(time)
--     self.fubenTrack:setFirstTime(time)
-- end
--刷新副本条件
function TrackView:setFubenData()
    if mgr.FubenMgr:isDayTaskFuben(cache.PlayerCache:getSId()) then
        --一个傻逼策划的要求
        self.Daytrack:setFubenData()
    else
        self.fubenTrack:setFubenData()
    end
    
end
--外部设置首通奖励（目前仅经验副本用到）
function TrackView:setFirstAward()
    self.fubenTrack:setFirstAward()
end

--boss追踪
function TrackView:setBossTrack()
    self.trackCtrl.selectedIndex = 0
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isWorldBoss(sId) 
        or mgr.FubenMgr:isBossHome(sId) 
        or mgr.FubenMgr:isKuafuWorld(sId) 
        or mgr.FubenMgr:isWuXingShenDian(sId) 
        or mgr.FubenMgr:isFsFuben(sId)
        or mgr.FubenMgr:isShenShou(sId)
        or mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu)
        or mgr.FubenMgr:isTaiGuXuanJing(sId)
        then
        self.ctrl2.selectedIndex = 1
        -- 太古玄境（策划要求第一层才显示仙盟按钮）
        if sId == 275002 or sId == 275003 then
            self.ctrl2.selectedIndex = 0
        end
    elseif mgr.FubenMgr:isXianyuJinDi(sId) or mgr.FubenMgr:isKuafuXianyu(sId) then
        self.ctrl2.selectedIndex = 5
        local xianYuBossData = cache.FubenCache:getXianYuJinDiData()
        local rage = xianYuBossData and xianYuBossData.anger or 0
        self:setRage(rage)
    elseif mgr.FubenMgr:isShangGuShenJi(sId) then
        self.ctrl2.selectedIndex = 5
        local shangGuBossData = cache.FubenCache:getShangGuData()
        local rage = shangGuBossData and shangGuBossData.anger or 0
        self:setRage(rage)
    end
    self.bossTrack:setBossTrack()
    self.quitBtn.title = language.gonggong42[1]
end
--刷新boss条件
function TrackView:setBossData()
    self.bossTrack:setBossData()
end
--降妖除魔boss
function TrackView:xycmBossData()
    self.wsjTrack:setBossData()
end

function TrackView:setWorldBossHate(hateRoleName)
    self.bossTrack:setWorldBossHate(hateRoleName)
end

function TrackView:updateBossHp()
    self.bossTrack:updateBossHp()
end

--问鼎追踪
function TrackView:setWenDingTrack()
    self.trackCtrl.selectedIndex = 1
    self.wenDingTrack:setWenDingTrack()
    self.quitBtn.title = language.gonggong42[3]
    self.fightingBtn.title = language.fuben113[1]
end

function TrackView:setWendingData()
    self.wenDingTrack:setWendingData()
end
--问鼎之战战旗持有者
function TrackView:setFlagHold(flagHoldRoleId)
    self.wenDingTrack:setFlagHold(flagHoldRoleId)
end

--跨服追踪
function TrackView:setKuaFuTeamTrack()
    self.trackCtrl.selectedIndex = 0
    self.quitBtn.title = language.gonggong42[1]
end

function TrackView:setKuaFuPassData(data)
    -- body
    self.kuaFuTeamPanel:setPassData(data)
end

function TrackView:kuaFuTeamMsg(data)
    self.kuaFuTeamPanel:initMsg(data)
end

function TrackView:resetRank(data)
    self.kuaFuTeamPanel:resetRank(data)
end
--情缘追踪
function TrackView:setMarryTrack()
    self.trackCtrl.selectedIndex = 0
    self.marryTrack:setMarryTrack()
    self.quitBtn.title = language.gonggong42[1]
    self.fightingBtn.title = language.fuben113[1]
end

function TrackView:endMarryTime()
    self.marryTrack:releaseTimer()
end

function TrackView:endCityWarTime()
    self.cityWarTrack:releaseTimer()
end

function TrackView:setMarryData()
    self.marryTrack:setMarryData()
end
--渡劫追踪
function TrackView:setDuJieTrack()
    self.dujieTrack:setDuJieTrack()
    self.quitBtn.title = language.gonggong42[1]
    self.fightingBtn.title = language.fuben113[1]
end

--仙盟boss追踪
function TrackView:setGangBossTrack()
    self.trackCtrl.selectedIndex = 2
    self.gangBossTrack:setGangBossTrack()
    self.quitBtn.title = language.gonggong42[3]
    self.fightingBtn.title = language.fuben113[1]
end

function TrackView:setGangBossData()
    self.gangBossTrack:setBossData()
end

function TrackView:gangBossData()
    self.gangBossTrack:bossDead()
end

--跨服 三界争霸
function TrackView:initKuaFu3War()
    -- body
    self.trackCtrl.selectedIndex = 0
    self.quitBtn.title = language.gonggong42[1]
    self.KuaFuWar:setKuaFu3Name()
end

function TrackView:setKuaFu3War(data)
    -- body
    self.KuaFuWar:initMsg(data)
end

--仙魔战
function TrackView:setXianMoTrack()
    self.trackCtrl.selectedIndex = 3
    self.quitBtn.title = language.gonggong42[1]
    self.fightingBtn.title = language.fuben113[1]
    self.xianMoTrack:setXianMoTrack()
end

function TrackView:setXianMoData()
    self.xianMoTrack:setXianMoData()
end
--剑神殿
function TrackView:setAwakenTrack()
    self.ctrl2.selectedIndex = 3
    self.trackCtrl.selectedIndex = 4
    self.quitBtn.title = language.gonggong42[1]
    self.fightingBtn.title = language.fuben113[2]
    self.awakenTrack:setAwakenTrack()
end

function TrackView:setAwakenData()
    self.awakenTrack:setAwakenData()
end

function TrackView:refAwakenTime()
    self.awakenTrack:refreshPlayTime()
end

function TrackView:initSingle()
    -- body
    --self.shoutaTrack:initms
    self.trackCtrl.selectedIndex = 0
    self.quitBtn.title = language.gonggong42[1]
end

function TrackView:setSingle(data)
    -- body
    self.shoutaTrack:initMsg(data)
end
--秘境修炼
function TrackView:setMjxlTrack()
    self.trackCtrl.selectedIndex = 0
    self.ctrl2.selectedIndex = 4
    self.quitBtn.title = language.gonggong42[1]
    self.mjxlTrack:setMjxlTrack()
    self.t2:Play()
    self:addTimer(1.5, 8, function( ... )
        self.t2:Play()
    end)
end

function TrackView:setMjxlData()
    self.mjxlTrack:setMjxlData()
end
--仙盟争霸
function TrackView:setXmzbTrack()
    -- self.ctrl2.selectedIndex = 6
    self.trackCtrl.selectedIndex = 3
    self.quitBtn.title = language.gonggong42[1]
    self.xmzbTrack:setXmzbTrack()
    self.mapBtn.visible = false
end

function TrackView:setXmzbData()
    self.xmzbTrack:setXmzbData()
end

function TrackView:endMjxl()
    self.mjxlTrack:endMjxl()
end
--雪地大作战
function TrackView:setXdzzTrack()
    self.ctrl2.selectedIndex = 7
    self.trackCtrl.selectedIndex = 5
    self.quitBtn.title = language.fuben128
    self.fightingBtn.title = language.gonggong116
    self.xdzzTrack:setXdzzTrack()
end
--答题
function TrackView:setCdmhTrack()
    self.ctrl2.selectedIndex = 0
    self.trackCtrl.selectedIndex = 5
    self.quitBtn.title = language.fuben128
    self.fightingBtn.title = language.gonggong116
    self.cdmhTrack:setCdmhTrack()
end
--城战追踪
function TrackView:setCityWarTrack()
    self.trackCtrl.selectedIndex = 0
    self.ctrl2.selectedIndex = 8
    self.cityWarTrack:setCityWarTrack()
end
--万神殿任务列表
function TrackView:setWanShenDianTrack()
    self.trackCtrl.selectedIndex = 0
    self.ctrl2.selectedIndex = 9
    self.wanShenDianTrack:setWsdTrack()
end
--刷新万神殿精力值
function TrackView:refreshJlValue()
    if self.wanShenDianTrack then
        self.wanShenDianTrack:refreshJlValue()
    end
end

--万圣节追踪
function TrackView:setWsjTrack()
    self.trackCtrl.selectedIndex = 5
    self.ctrl2.selectedIndex = 10
    self.wsjTrack:setWsjTrack()
end



function TrackView:setCdmhData(isNotCz)
    if self.cdmhTrack then
        self.cdmhTrack:setCdmhData(isNotCz)
    end
end

function TrackView:onClickFight()
    if self.trackCtrl.selectedIndex == 1 then
        mgr.ViewMgr:openView2(ViewName.WendingTipView)
    elseif self.trackCtrl.selectedIndex == 2 then
        mgr.ViewMgr:openView2(Vie1030181wName.GangBossInfoView,{})
    elseif self.trackCtrl.selectedIndex == 3 then
        mgr.ViewMgr:openView2(ViewName.XianMoTipView,{})
    elseif self.trackCtrl.selectedIndex == 4 then
        mgr.ViewMgr:openView2(ViewName.AwakenBossTipView,{})
    end
end
--（以前是宝藏，现在是招募）
function TrackView:onClickBossBz()
    -- mgr.ViewMgr:openView2(ViewName.BossIndianaView, {})
    if self.zmCdImg.fillAmount == 0 then
        if cache.PlayerCache:getGangId() ~= "0" then
            proxy.FubenProxy:send(1330204)
        else
            GComAlter(language.fuben117)
        end
        self.oldZmTime = mgr.NetMgr:getServerTime()
        local cdTime = conf.SysConf:getValue("gang_zm_cd")
        if not self.cdTimer then--整理cd
            self.cdActionTime = cdTime - (mgr.NetMgr:getServerTime() - self.oldZmTime)
            self:onZmTimer()
            self.cdTimer = self:addTimer(0.2, -1, handler(self,self.onZmTimer))
        end
    end
end

function TrackView:releaseTimer()
    if self.cdTimer then
        self:removeTimer(self.cdTimer)
        self.cdTimer = nil
    end
    self.zmCdImg.fillAmount = 0
    self.oldZmTime = 0
end
--招募cd倒计时
function TrackView:onZmTimer()
    local leftTime = mgr.NetMgr:getServerTime() - self.oldZmTime
    local cdTime = conf.SysConf:getValue("gang_zm_cd")
    if leftTime >= cdTime then
        self:releaseTimer()
        return
    end
    if self.cdActionTime then
        self.cdActionTime = self.cdActionTime - 0.2
        self.zmCdImg.fillAmount = self.cdActionTime / cdTime
    end
end

function TrackView:onClickQuit()
    if self.ctrl2.selectedIndex == 7 then--雪地大作战
        return
    end
    local param = {}
    param.type = 2
    param.sure = function()
        mgr.FubenMgr:quitFuben()
    end
    param.cancel = function()
        
    end
    if mgr.FubenMgr:isQingYuanFuben(cache.PlayerCache:getSId()) then
        param.richtext = language.kuafu101
        GComAlter(param)
    else
      
        self:quitFuben()
    end
end

function TrackView:quitFuben()
    local param = {}
    param.type = 14
    local sId = cache.PlayerCache:getSId()
    local str = language.gonggong96
    if mgr.FubenMgr:isXdzzWar(sId) then
        str = language.ydact016
    end
    param.richtext = mgr.TextMgr:getTextColorStr(str, 6)
    param.sure = function()
        if mgr.FubenMgr:isJianShengshouhu(cache.PlayerCache:getSId()) 
        or mgr.FubenMgr:isXianyu(cache.PlayerCache:getSId()) then
            --请求结算
            proxy.FubenProxy:send(1027204)   
        else
            mgr.FubenMgr:quitFuben()
        end
        
    end
    GComAlter(param)
end

function TrackView:onClickRank()
    if self.index == 14 then--元旦
        mgr.ViewMgr:openView2(ViewName.YdXdzzRankView)
    elseif self.index == 15 then--元宵
        mgr.ViewMgr:openView2(ViewName.LanternRankView)
    end
end

function TrackView:onClickQuit2()
    self:quitFuben()
end
--结束了当前战斗
function TrackView:endTrack()
    self.fubenTrack:endFuben()
    self.bossTrack:endBoss()
    self.wenDingTrack:endWenDing()
    self.kuaFuTeamPanel:endFuben()
    self.marryTrack:endMarryFuben()
    self.dujieTrack:endFuben()
    self.gangBossTrack:endGangBoss()
    self.KuaFuWar:endFuben()
    self.xianMoTrack:endXianMo()
    self.awakenTrack:endAwaken()
    self.mjxlTrack:endMjxl()
    self.xmzbTrack:endXmzb()
    self.xdzzTrack:endXdzz()
    self.cdmhTrack:endCdmh()
end

function TrackView:clear()
    self.rageTime = -1
    self.top2C1.selectedIndex = 0
    self.ctrl3.selectedIndex = 0
    self:releaseTimer()
    G_SetMainView(true)
    self:endTrack()
    self:closeView()
end

return TrackView