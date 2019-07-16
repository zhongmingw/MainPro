local MainView = class("MainView", base.BaseView)
---组队 or 任务 界面信息
local TaskorTeam = import(".TaskorTeam")
--右下角战斗按钮
local BtnFight = import(".BtnFight")
--战场任务（皇陵）
local ZhanChangTrack = import(".ZhanChangTrack")
--顶部按钮
local TopActive = import(".TopActive")
--
local ChatVoice = import(".ChatVoice")
--下方冒泡提示
local BubblePanel = import(".BubblePanel")
--主界面聊天区域
local ChatPanel = import(".ChatPanel")

local redt = {
    ["n502"] = {1156}, --活跃任务红点
    ["n407"] = {1001,1002,1003,1004,1005,1287,1438}, --战骑红点
    ["n406"] = {1006,1007,1008,1009,1010}, --伙伴红点
    ["n409"] = {1062}, --剑圣红点
    ["n301"] = {1070, 1441, 1442}, --影卫红点
    ["n403"] = {1068},--技能红点
    ["n408"] = {1013,1014,1015,1017,1018,1127,1139,1353},--仙盟 --1016 策划要求屏蔽
    ["friend"] = {1065},--好友
    ["n3111"] = {1073},--红包
    ["n402"] = {1029},--鍛造
    ["n401"] = {1069},--角色
    ["sale"] = {1066},--拍卖
    ["marrygn"] = {1100,1112,1304,1313},--结婚
    ["home"] = {1137},
    ["pet"] = {1188},--宠物
    ["rune"] = {1213,1214,1215,1216},--符文
    ["shenqi"] = {1238,1336,1408},--神器
}

--需要记录的按钮
local opent = {
    ["n404"] = 1,
    ["n403"] = 2,
    ["n402"] = 3,
    ["n408"] = 4,
    ["n407"] = 5,
    ["n409"] = 6,
    ["n301"] = 7,
    ["n401"] = 9,
    ["n406"] = 10,
    ["marrygn"] = 11,
    ["home"] = 8,
    ["pet"] = 13,
    ["rune"] = 12,
    ["shenqi"] = 14,
}
--动画
local anim = {"n303","n305","n306","n307"}
local animpos = {}

function MainView:ctor()
    self.super.ctor(self)
end

function MainView:initParams()
    self.uiLevel = UILevel.level1           --窗口层级
    self.uiClear = UICacheType.cacheForever
end

function MainView:initView()
    --位置记录
    self.position = {}
    self.oldRoleIcon = 0--缓存旧的roleicon
    self.openChat = true
    for k ,v in pairs(opent) do
        self.position[v] = self.view:GetChild(k).xy
    end
    self.animpos = {}
    for k ,v in pairs(anim) do
        self.animpos[v] = self.view:GetChild(v).xy
    end

    self.sitCount = 0
    --固定可见的按钮
    self.seetable = {}
    --所有参与引导的是否可见的按钮
    self.allseetable = {}
    --固定可见的按钮
    for i = 1 , 4 do
        local key = "n50"..i
        local btn = self.view:GetChild(key)
        if g_ios_test and i == 4 then   --EVE 屏蔽VIP特权入口LOGO
            btn.scaleX = 0
            btn.scaleY = 0
        end
        btn.data = key
        btn.onClick:Add(self.onClickSkillEvent, self)
        if i~= 2 then --背包,充值，Vip特权
            self.seetable[key] = btn
        else
            self.allseetable[key] = btn
        end
    end
    --self.view:GetChild("view").onClick:Add(self.onClickView,self)
    --仙尊卡按钮
    local XianzunBtn = self.view:GetChild("n5041")
    self.hideXianzun = XianzunBtn
    XianzunBtn.data = "n5041"
    XianzunBtn.onClick:Add(self.onClickSkillEvent, self)
    self.seetable["n5041"] = XianzunBtn
    --小地图，
    local mapBtn = self.view:GetChild("n358")
    mapBtn.onClick:Add(self.onClickMap, self)
    self.seetable["n358"] = mapBtn
    self.hideMapBtn = mapBtn
    --结婚预告
    self.marrybtn = self.view:GetChild("marry")
    self.marrybtn.data = "marry"
    self.marrybtn.onClick:Add(self.onClickSkillEvent, self)


    local shieldBtn = self.view:GetChild("n135")
    self.shieldBtnIcon = shieldBtn:GetChild("icon")
    shieldBtn.onClick:Add(self.onClickShield, self)
    --音效
    local musicBtn = self.view:GetChild("n136")
    self.musicBtnIcon = musicBtn:GetChild("icon")
    musicBtn.onClick:Add(self.onClickMusic, self)
    self.seetable["n136"] = musicBtn
    --设置，
    local siteBtn = self.view:GetChild("n137")
    siteBtn.onClick:Add(self.onClickSite, self)
    self.seetable["n137"] = siteBtn
    self.hideSiteBtn = siteBtn   --EVE
    --功能和战斗切换控制
    self.isFightbtn = self.view:GetChild("n3081")
    self.isFightbtn.data = "n3081"
    self.redImg = self.view:GetChild("bottomRed")

    self.isFightbtn.onClick:Add(self.onClickSkillEvent, self)
    self.n3081Effect01 = self.view:GetTransition("t7")
    --self.n3081Effect02 = self.view:GetTransition("t8")
    self.tabBtn = self.view:GetChild("nchangetar") --EVE 为了控制tab的显示和隐藏

    self.seetable["n3081"] = self.isFightbtn
    --其他按钮
    for i = 1 , 10 do
        local key = "n"..(400+i)
        local btn = self.view:GetChild(key)
        if btn then
            btn.data = key
            btn.onClick:Add(self.onClickSkillEvent, self)

            if key == "n401" or key == "n403" then --角色,技能
                self.seetable[key] = btn
            else
                self.allseetable[key] = btn
            end
        end
    end
    local btnMarry = self.view:GetChild("marrygn")
    btnMarry.data = "marrygn"
    btnMarry.onClick:Add(self.onClickSkillEvent, self)
    self.allseetable["marrygn"] = btnMarry

    local btnMarry = self.view:GetChild("home")
    btnMarry.data = "home"
    btnMarry.onClick:Add(self.onClickSkillEvent, self)
    self.allseetable["home"] = btnMarry

    local btnMarry = self.view:GetChild("pet")
    btnMarry.data = "pet"
    btnMarry.onClick:Add(self.onClickSkillEvent, self)
    self.allseetable["pet"] = btnMarry

    local btnRune = self.view:GetChild("rune")
    btnRune.data = "rune"
    btnRune.onClick:Add(self.onClickSkillEvent, self)
    self.allseetable["rune"] = btnRune

    local btnShenqi = self.view:GetChild("shenqi")
    btnShenqi.data = "shenqi"
    btnShenqi.onClick:Add(self.onClickSkillEvent, self)
    self.allseetable["shenqi"] = btnShenqi
    --排行帮
    local btnBang = self.view:GetChild("n134")
    btnBang.onClick:Add(self.onbtnBang,self)
    self.allseetable["n134"] = btn
    self.hideBang = btnBang

    local btn = self.view:GetChild("n301")
    btn.data = "n301"
    btn.onClick:Add(self.onClickSkillEvent, self)
    self.allseetable["n301"] = btn
    --好友
    local btnFriend = self.view:GetChild("friend")
    self.btnFriend = btnFriend
    btnFriend.data = "friend"
    btnFriend.onClick:Add(self.onClickSkillEvent, self)
    --拍卖
    local btnsale = self.view:GetChild("sale")
    btnsale.data = "sale"
    btnsale.onClick:Add(self.onClickSkillEvent, self)

    --主界面背景
    --战斗上升的箭头
    self.btnPowerJiantou = self.view:GetChild("n123")
    self.btnPowerJiantou.onClick:Add(self.onBtnJiantou,self)
    --战斗，功能，副本切换
    self.c3 = self.view:GetController("c3")
    self.c3.onChanged:Add(self.onController3,self)
    --EVE 添加组件显示/隐藏动效
    self.c4 = self.view:GetController("c4")--显示隐藏顶部
    self.c6 = self.view:GetController("c6")--显示隐藏任务
    self.c7 = self.view:GetController("c7")--显示隐藏vip按钮
    self.c4.onChanged:Add(self.onControlChangeOfC4,self)
    self.c7.onChanged:Add(self.onControlChangeOfC7,self)
    self.c4Effect = self.view:GetTransition("t9")   --EVE 顶部按钮显隐
    self.c7Effect01 = self.view:GetTransition("t5")   --EVE VIP栏按钮显
    self.c7Effect02 = self.view:GetTransition("t12")   --EVE VIP栏按钮隐

    --仙尊体验卡按钮
    self.XianzunExpBtn = self.view:GetChild("n345")
    self.xianzunBg = self.view:GetChild("n346")
    self.leftMarryPos = true
    --等级礼包组合
    self.lvGiftBtn = self.view:GetChild("n394")

    local btn = self.view:GetChild("n386") --EVE 图形代替n247，作用：扩大点击范围
    btn.data = "n386"
    btn.onClick:Add(self.onClickSkillEvent, self)
    self.topJianTou = btn

    --[[--新顶部按钮 刚加了又要改回之前的样子 艹
    -- self.topBtnIndex = 1
    -- local topbtn = self.view:GetChild("n418")
    -- topbtn.onClick:Add(self.onClickTopBtn,self)
    -- self.topbtnRedImg = self.view:GetChild("n419")
    -- self.topbtnRedImg.visible = false
    -- self.c8 = self.view:GetController("c8")--新顶部按钮控制
    -- self.c8.onChanged:Add(self.onControlChangeOfC8,self)
    ]]--

    local btn = self.view:GetChild("n362")
    btn.data = "n362"
    btn.onClick:Add(self.onClickSkillEvent, self)

    self.btnnear =  self.view:GetChild("n414")
    self.btnnearchouren =  self.view:GetChild("n415")
    self.btnnearchouren:GetChild("n6").visible = false
    self.btnnearchouren.onClick:Add(self.onClickFight, self)
    --初始化操作杆
    local joysTick = self.view:GetChild("n211")
    UJoystick:InitJoystick(joysTick)
    --飘字挂件
    self.pendant = self.view:GetChild("n229")
    --玩家信息 左上角
    self.roleNameLabel = self.view:GetChild("n126")
    self.rolePowerLabel = self.view:GetChild("n259")
    self.view:GetChild("n357").onClick:Add(self.onBtnJiantou,self)
    self.roleLevelLabel = self.view:GetChild("n125")
    self.roleIcon = self.view:GetChild("n212")
    self.roleBloodBar = self.view:GetChild("n127")
    self.roleBloodText = self.view:GetChild("n356")
    self.roleBloodFrame = self.view:GetChild("n363")
    local btnRole = self.view:GetChild("n212")
    btnRole.onClick:Add(self.onRoleinfo,self)
    --战力
    self.effectpower = self.view:GetChild("eff_power")

    self.redBagBtn = self.view:GetChild("n803")
    self.redBagBtn.onClick:Add(self.onClickRedBagBtn, self)
    self.redBagBtn.visible=false

    for i=1,3 do
        if i ~= 2 then
            local key = "n22"..i
            local btn = self.view:GetChild(key)
            btn.data = key
            btn.onClick:Add(self.onClickSkillEvent, self)
        end
    end
    --经验条
    self.expBar = self.view:GetChild("n182")
    local roleExp = cache.PlayerCache:getRoleExp()
    local roleLv = cache.PlayerCache:getRoleLevel()

    self.rolepos = self.view:GetChild("n133")

    --战斗按钮
    self.BtnFight = BtnFight.new(self)
    --任务选择
    self.taskorTeam = TaskorTeam.new(self)
    self.taskorTeam:setSelect(1)
    --顶部按钮
    self.TopActive = TopActive.new(self)
    self.TopActive:checkRedGift()
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"MainView2")

    self.osTimeText = self.view:GetChild("n130")
    self.netWorkLoader = self.view:GetChild("n131")--网络
    self.networkState = 0
    self:updateNetworkState()
    self.batteryPro = self.view:GetChild("n132")--电池
    self.batteryPro.onClick:Add(self.onBatteryClick, self)
    self:setBatteryLevel()
    self.batteryTime = os.time()
    self:addTimer(0.5,-1,handler(self, self.updateTimer),"MainView1")
    --打坐
    local btnDazuo = self.view:GetChild("n279")
    btnDazuo.onClick:Add(self.onDazuo,self)
    --btnDazuo.visible = false
    self.dazuoBtn = btnDazuo
    --红包
    self.btnRedBag = self.view:GetChild("n3111")
    self.btnRedBag.onClick:Add(self.onClickRedBagBtn,self)
    --EVE 坐骑使用按钮
    self.btnMounts = self.view:GetChild("n367")
    self.btnMounts.onClick:Add(self.onClickUseMounts, self)
    self.isHaveMount = false    --EVE 是否拥有坐骑标志位
    self.voiceBtn = self.view:GetChild("n221") --EVE 语音按钮 和坐骑一起显隐
    self.gangChatBtn = self.view:GetChild("n4081")--仙盟聊天跳转
    self.gangChatBtn.onClick:Add(self.onClickGangChat,self)
    -- self.btnState = false

    --buff 栏
    self.buffList = self.view:GetChild("bufflist")
    --self.buffList:SetVirtual()
    self.buffList.itemRenderer = function(index,obj)
        self:buffItemRenderer(index, obj)
    end
    self.buffList.numItems = 0
    self.buffList.onClick:Add(self.onBuffItemClick,self)


    self.firendTipBtn = self.view:GetChild("n801")--好友提示按钮

    self.firendTipBtn.onClick:Add(self.onClickFriend,self)
    self.mailTipBtn = self.view:GetChild("n802")--邮件提示按钮
    self.mailTipBtn.onClick:Add(self.onClickMail,self)
    --聊天
    self.bubblePanel = BubblePanel.new(self)
    self:initChat()
    self:initTrack()
    self.moshiList = {}
    local btn = self.view:GetChild("n330")
    btn.visible = true
    self.moshiBtn = btn
    btn.onClick:Add(self.onbtnroleMoShi,self)
    --检测板书
    self:checkIsbanshu()
    --主角信息
    self:updateRoleInfo()
    self:initRoleExpBar(roleExp,roleLv) --经验条信息
    --调试窗口
    self:initDebug()
    --刷新人物坐标消息
    self:setRolePos()
    --变强提示标志位初始化
    self:setBubblePanelVisible()

    self:setOthersee()
    self:setVisible()
    self:setMusicBtn()
    self:setShieldBtn()
    self.limitBtn = self.view:GetChild("n667")--临时背包icon
    self.limitBtn.onClick:Add(self.onClickLimit,self)
    self.limitTimer = self.view:GetChild("n668")--临时背包时间
    self.packEffPanel = self.view:GetChild("n501"):GetChild("n6")
    self.packEffPanel.visible = true
    self.limitEffPanel = self.limitBtn:GetChild("n6")
    self.limitEffPanel.visible = true
    self.packTime = os.time()
    self.limitTime = os.time()
    mgr.FubenMgr:checkFuben(cache.PlayerCache:getSId())
    mgr.ViewMgr:openView2(ViewName.ItemTipView)--道具飘显示层
    mgr.ViewMgr:openView2(ViewName.DanMuTipsView)--弹幕显示层

    --self:checkIsbanshu()

    if g_ios_test then   --EVE 屏蔽
        for k,v in pairs(opent) do      --右下角功能 (下一行，需要优化代码)
            if k ~= "n403" and k ~= "n401" and k ~= "n404" and k ~= "n406" and k ~= "n409" and k ~= "n407" then
                self.view:GetChild(k).scaleX = 0
                self.view:GetChild(k).scaleY = 0
            end
            -- plog("摩擦摩擦，是魔鬼的步伐，是魔鬼的步伐~！")
        end

        -- self.hideXianzun.scaleX = 0                     --仙尊卡
        -- self.hideXianzun.scaleY = 0
        -- self.view:GetChild("n339").scaleX = 0       --仙尊卡打折
        -- self.view:GetChild("n339").scaleY = 0
        self.hideBang.scaleX = 0                          --排行榜
        self.hideBang.scaleY = 0
        self.hideSiteBtn.scaleX = 0                       --设置按钮
        self.hideSiteBtn.scaleY = 0
        self.hideMapBtn.scaleX = 0                     --地图按钮
        self.hideMapBtn.scaleY = 0
        self.view:GetChild("n502").scaleX = 0       --修仙
        self.view:GetChild("n502").scaleY = 0
        self.btnRedBag.scaleX = 0                        --红包
        self.btnRedBag.scaleY = 0
        self.redBagBtn.scaleX = 0
        self.redBagBtn.scaleY = 0
        -- btnDazuo.scaleX = 0                                --打坐
        -- btnDazuo.scaleY = 0
        btnsale.scaleX = 0                                   --拍卖行
        btnsale.scaleY = 0
        self.view:GetChild("n3570").scaleX = 0      --地图下的小提示
        self.view:GetChild("n3570").scaleY = 0
        self.marrybtn.scaleX = 0                             --结婚预告
        self.marrybtn.scaleY = 0
        self.view:GetChild("n206").scaleX = 0        --左侧队伍栏位
        self.view:GetChild("n206").scaleY = 0
        self.view:GetChild("n2801").scaleX = 0        --聊天栏设置按钮
        self.view:GetChild("n2801").scaleY = 0
        self.view:GetChild("n361").scaleX = 0
        self.view:GetChild("n361").scaleY = 0
        self.view:GetChild("n221").scaleX = 0          --世界LOGO
        self.view:GetChild("n221").scaleY = 0
        self.view:GetChild("n123").scaleX = 0          --我要变强LOGO
        self.view:GetChild("n123").scaleY = 0
        -- self.view:GetChild("n222").scaleX = 0          --仙盟LOGO
        -- self.view:GetChild("n222").scaleY = 0
        btn.touchable = false              --强制和平模式
        -- self.XianzunExpBtn.scaleX = 0             --屏蔽免费体验卡
        -- self.XianzunExpBtn.scaleY = 0
        -- self.xianzunBg.scaleX = 0
        -- self.xianzunBg.scaleY = 0
        -- self.marrybtn.scaleX = 0 --80级脱单
        -- self.marrybtn.scaleY = 0
    end

    --队伍按钮
    self.teamBtnList = {}
    for i=382,384 do
        local team = self.view:GetChild("n"..i)
        team.visible = false
        team.data = i - 381
        team.onClick:Add(self.onClickTeam,self)
        table.insert(self.teamBtnList, team)
    end
    self:setMoshiState(cache.PlayerCache:getPKState())--断线重连时要重新设置模式bxp

end

-- function MainView:onClickTopBtn()
--     self.topBtnIndex = self.topBtnIndex + 1
--     if self.topBtnIndex > 2 then
--         self.topBtnIndex = 0
--     end
--     self.c8.selectedIndex = self.topBtnIndex
-- end

-- function MainView:onControlChangeOfC8()
--     if self.c8.selectedIndex == 0 then
--         -- print("全收>>>>>>>>>>>>>>>>>>>>",self.topBtnIndex)
--         self.TopActive:moveBtnToHide()
--         self.topbtnRedImg.visible = true
--     elseif self.c8.selectedIndex == 1 then
--         -- print("半收>>>>>>>>>>>>>>>>>>>>",self.topBtnIndex)
--         self.TopActive:initBtn()
--         self.topbtnRedImg.visible = true
--         self.TopActive:moveBtnToShow()
--     elseif self.c8.selectedIndex == 2 then
--         -- print("全显>>>>>>>>>>>>>>>>>>>>",self.topBtnIndex)
--         self.TopActive:initBtn()
--         self.topbtnRedImg.visible = false
--         self.TopActive:moveBtnToShow()
--     end
--     self.topBtnIndex = self.c8.selectedIndex
-- end

--组队按钮点击
function MainView:onClickTeam(context)
    local index = context.sender.data
    local isNotTeam = cache.TeamCache:getIsNotTeam()
    if index == 1 then--前往组队
        local sId = cache.PlayerCache:getSId()
        local isOpen = false
        if mgr.FubenMgr:isLevel(sId) then
            if isNotTeam then
                isOpen = true
            end
        else
            isOpen = true
        end
        if isOpen then
            mgr.ViewMgr:openView2(ViewName.TeamView,{index = 1})
        end
    elseif index == 2 then--创建队伍
        local lv = conf.SysConf:getValue("team_limit_lvl") or 0   --EVE 添加创建队伍等级不足飘字提示
        if cache.PlayerCache:getRoleLevel() < lv then
            GComAlter(string.format(language.team26, lv))
            return
        end
        if isNotTeam then
            local sceneData = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
            local targetId = sceneData and sceneData.team_target or 2
            local confData = conf.TeamConf:getTeamConfig(targetId)
            proxy.TeamProxy:send(1300104,{targetId = confData.id,minLvl = confData.lv_section[1],maxLvl = confData.lv_section[2]})
        end
    elseif index == 3 then--附近队伍
        mgr.ViewMgr:openView2(ViewName.TeamView,{index = 2})
    end
end

function MainView:setTeamBtnVisible(visible)
    if self.teamBtnList then
        for k,v in pairs(self.teamBtnList) do
            v.visible = visible
        end
    end
end

--EVE VIP栏，添加开关动效
function MainView:onControlChangeOfC7()
    if self.c7.selectedIndex == 0 then
        self.c7Effect01:Play()
    elseif self.c7.selectedIndex == 1 then
        self.c7Effect02:Play()
    end
end


function MainView:onControlChangeOfC4()
    if self.c4.selectedIndex == 0 then
        self.c4Effect:PlayReverse()
    elseif self.c4.selectedIndex == 1 then
        -- local view = mgr.ViewMgr:get(ViewName.GuideWSSB)
        -- if view then
        --     view:closeView()
        -- end
        self.c4Effect:Play()
    end
end

function MainView:onBatteryClick(context)
    if g_var.auth == 3 then
        mgr.ViewMgr:openView2(ViewName.DebugTestView)
        self.view:GetChild("n381").text = ""
        GameUtil.LogInit(98)
    end
end
--默认设置不可见
function MainView:setOthersee()
    -- body
    for k ,v in pairs(self.allseetable) do
        v.visible = false
    end
end
--设置那些按钮可见
function MainView:setSeeInfo(flag)
    -- body
    --如果当前场景是副本
    if mgr.FubenMgr:isFuben(cache.PlayerCache:getSId()) then
        return
    end
    for k ,v in pairs(self.seetable) do
        v.visible = flag
    end
end

--请求任务信息 检测功能开启
function MainView:checkOpen(param)
    -- body
    -- plog("检测任务信息")
    self.TopActive:checkOpen()
    if not mgr.ViewMgr:get(ViewName.GuideViewOpen) then
        if mgr.FubenMgr:checkScene() then
            self.c4.selectedIndex = 1
        end
    end
    if g_is_banshu then
        return
    end

    local data=cache.TaskCache:getData()--任务信息
    local delete = {}
    local flag = false
    if  g_is_guide and data and #data > 0 then
        for k ,v in pairs(self.allseetable) do
            if not self.seetable[k] then
                if mgr.ModuleMgr:check(k) then
                    flag = true
                    self.seetable[k] = v
                    table.insert(delete,k)
                end
            end
        end
    else --全部开启了
        for k ,v in pairs(self.allseetable) do
            if not self.seetable[k] then
                flag = true
                self.seetable[k] = v
                table.insert(delete,k)
            end
        end
        self.view:GetChild("n502").visible = true
    end

    for k ,v in pairs(delete) do
        self.allseetable[v] = nil
    end
    if not param or not param.btnfight then
        self.BtnFight:checkFight()
    end


    if self.seetable["n502"] and mgr.ModuleMgr:check("n502") then --修仙
        if not g_ios_test then --EVE 屏蔽修仙
            self.seetable["n502"].visible = true
        end
    end


    self:checkMarry()
    --设定按钮位置
    self:initBtn()

end



--当某条任务完成的时候
function MainView:chenkOpenById(id)
    -- body
    if g_is_banshu then
        return
    end



    self.TopActive:chenkOpenById(id,true)
    self.TopActive:checkOpen()
    for k ,v in pairs(self.allseetable) do
        if not self.seetable[k] then
            if mgr.ModuleMgr:checkById(k,id) then
                self.seetable[k] = v
                self.allseetable[k] = nil
                self:initBtn()
                if self.c3.selectedIndex == 1 then
                    self:onController3()
                end
                if k == "marrygn" then
                    self:checkMarry()
                end
                break
            end
        end
    end
end
--当剑神激活的时候
function MainView:checkJianshen()
    -- body
    if g_is_banshu then
        return
    end
    local key = "n409"
    if mgr.ModuleMgr:check(key) and not self.seetable[key] then
        self.seetable[key] = self.allseetable[key]
        self:initBtn()
        self:onController3()
    end
end
function MainView:initEffect(flag)
    -- body
    if self.effect4020128 then
        return
    end
    local panel = self.marrybtn:GetChild("n6")
    panel.visible = flag
    if panel.visible then
        self.effect4020128 = self:addEffect(4020128,panel)
        --self.effect4020128.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight/2)
    end
end

--检测结婚系统是否开启
function MainView:checkMarry()
    if g_ios_test then   --EVE IOS版属屏蔽结婚
        return
    end
    -- body
    --检测结婚系统的功能
    local panel = self.marrybtn:GetChild("n6")
    if mgr.FubenMgr:checkScene() then
        self.marrybtn.visible = false
        panel.visible = false
        return
    else
        self.marrybtn:SetScale(1,1)
        self.marrybtn.visible = true
        panel.visible = true
    end

    if mgr.ModuleMgr:CheckView(1096) and not self.seetable["marrygn"] then
        self.marrybtn:SetScale(1,1)
        self.marrybtn.visible = true
        panel.visible = true
        self:initEffect(true)
    else
        if self.effect4020128 then
            self:removeUIEffect(self.effect4020128)
            self.effect4020128 = nil
        end
        self.marrybtn.visible = false
        panel.visible = false
        self.marrybtn:SetScale(0,0)
    end
end

function MainView:initBtn()
    -- body
    local t = table.keys(opent)
    table.sort(t,function(a,b)
        -- body
        return opent[tostring(a)]<opent[tostring(b)]
    end)
    --已经展位
    local havedone = {}
    --local index =
    local pairs = pairs
    for k ,v in pairs(t) do
        if self.seetable[v] then
            --检测当前行的空位置
            if opent[tostring(v)]<=4 then
                for i = 1 , 4 do
                    if not havedone[i] then
                        havedone[i] = true
                        self.seetable[v].xy = self.position[i]
                        break
                    end
                end
            elseif opent[tostring(v)]<=8 then
                for i = 5 , 8 do
                    if not havedone[i] then
                        --需要继续检测
                        local id = i
                        if not havedone[i-4] then
                            id = i - 4
                        end
                        havedone[id] = true
                        self.seetable[v].xy = self.position[id]
                        break
                    end
                end
            else
                for i = 9 , 14 do
                    if not havedone[i] then
                        local id = i
                        if not havedone[id-4] then
                            id = id - 4
                            if not havedone[id-4] then
                                id = id - 4
                            end
                        end
                        havedone[id] = true
                        self.seetable[v].xy = self.position[id]
                        break
                    end
                end
            end
        end
    end
end

function MainView:setVisible415()
    -- body
    if true then
        self.btnnearchouren.visible = false
        return --多余的
    end
    if self.c3.selectedIndex == 1  then
        self.btnnearchouren.visible = false
    else
        if self.btnnearchouren.data then
            local player = mgr.ThingMgr:getObj(ThingType.player, self.btnnearchouren.data)
            if not player then
                self.btnnearchouren.data = nil
                self.btnnearchouren.visible = false
            else
                self.btnnearchouren.visible = true
                --print("GGetMsgByRoleIcon(player.data.roleIcon).headUrl",GGetMsgByRoleIcon(player.data.roleIcon).headUrl)

                local t = GGetMsgByRoleIcon(player.data.roleIcon,player.data.roleId)
                self.btnnearchouren:GetChild("n1"):GetChild("n3").url = t.headUrl
            end
        else
            self.btnnearchouren.visible = false
        end
    end
end

function MainView:CheckFuJinNum()
    -- body
    local data = mgr.ThingMgr:objsByType(ThingType.player) or {}
    local lab = self.btnnear:GetChild("n7")
    local numerb = table.nums(data)
    self.btnnear:GetChild("n5").visible = numerb>0
    lab.visible = numerb>0
    lab.text = tostring(numerb)
end

function MainView:isnearsee()
    -- body
    local sId = cache.PlayerCache:getSId()
    local sConf = conf.SceneConf:getSceneById(sId)
    local pkOptions = sConf and sConf.pk_options or {0}
    if sConf and pkOptions then
        for k , v in pairs(pkOptions) do
            if v ~= PKState.peace then
                return  true
            end
        end
    end
    return false
end

function MainView:onController3(flag)
    -- body
    --功能按钮
    local t = {"n401","n402","n403","n404","n406","n407","n408","n409","n301","marrygn","home","rune","pet","shenqi"}  --EVE "n502"已移除

    if self.c3.selectedIndex == 0 then --战斗
        self.topJianTou.visible = true
        self.isFightbtn.visible = true
        self.tabBtn.scale = Vector3.one
        self.BtnFight:isSee(true)
        for k ,v in pairs(t) do
            if self.seetable[v] then
                self.seetable[v].visible = false
            end
        end
        self.btnnear.visible = mgr.ModuleMgr:CheckView({id = 1286}) and self:isnearsee()

    elseif self.c3.selectedIndex == 1 then --功能
        self.topJianTou.visible = true
        self.isFightbtn.visible = true
        self.tabBtn.scale = Vector3.zero
        self.BtnFight:isSee(false)
        for k ,v in pairs(t) do
            if self.seetable[v] then
                self.seetable[v].visible = true
            end
        end
        self.btnnear.visible = false
    else --战斗场景)

        self.btnnear.visible = mgr.ModuleMgr:CheckView({id = 1286}) and self:isnearsee()

        self.isFightbtn.visible = true --不给切换 战斗场景中需要可切换战斗、非战斗功能按钮 策划要求
        self.topJianTou.visible = true
        self.tabBtn.scale = Vector3.one
        self.BtnFight:isSee(true)
        --不给看功能按钮
        for k ,v in pairs(t) do
            if self.seetable[v] then
                self.seetable[v].visible = false
            end
        end
    end
    self:setVisible415()
end


--升级刷新主界面信息
function MainView:updateMaininfo()
    --打坐按钮是否可见
    self:setVisible()
end

function MainView:setVisible()
    -- body
    if cache.PlayerCache:getRoleLevel() < conf.SysConf:getValue("sit_lev")
    or mgr.FubenMgr:isArena(cache.PlayerCache:getSId()) then
        self.dazuoBtn.visible = false
        return
    end
    self.dazuoBtn.visible = true -- mgr.FubenMgr:isSitDownSid()
end
---------------------------------------------buff 信息 start -----------------
--刷新buff
function MainView:updateBuffs(arr)
    self.buffList.numItems = 0
    self.buffs = arr
    -- printt("当前buff列表",arr)
    self.buffList.numItems = #arr
end
--设置buff-item
function MainView:buffItemRenderer(index, cell)
    cell:GetChild("icon").url = ResPath.buffRes(self.buffs[index+1].icon)
end
--buff 点击
function MainView:onBuffItemClick()
    local data =  mgr.BuffMgr:getBuffByid(cache.PlayerCache:getRoleId())
    if table.nums(data) ~= 0 then
        mgr.ViewMgr:openView(ViewName.BuffView,function(view)
            -- body
            view:setData()
        end)
    end
end
---------------------------------------------buff 信息 end -----------------
function MainView:setTeamData()
    local view = mgr.ViewMgr:get(ViewName.TrackView)
    if view then
        view:refMyTeamData1()
    else
        self.taskorTeam:onController1()
    end
end
--设置任务列表
function MainView:setTaskList()
    self.taskorTeam:setTaskList()
end
--设置当前位置信息
function MainView:setRolePos()
    if not gRole then
        return
    end
    local sId = cache.PlayerCache:getSId()
    if gRole and self.rolepos then
        local t = gRole:getPosition()
        local condata = conf.SceneConf:getSceneById(sId)
        local str = ""
        if condata and condata.name then
            str = str .. condata.name --.."\n"
        else

        end
        self.rolepos.text = str .. "("..math.floor(t.x)..","..math.floor(t.z)..")"
    end
end

--配置时间打坐
function MainView:autoSit()
    if not gRole then return end
    --plog("gRole:isFight()",gRole:isFight())
    if gRole:getStateID() == 0 and not gRole:isFight() then --待机状态中
        local confdata = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
        if not confdata then
            return
        end
        if confdata.kind ~= SceneKind.mainCity and confdata.kind ~= SceneKind.field then
            return
        end
        self.sitCount = self.sitCount + 0.5
        if self.sitCount >= conf.SysConf:getValue("into_sit_keep") then --在一个位置超过10
            self.sitCount = 0
            local view = mgr.ViewMgr:get(ViewName.SitDownView)
            if not view then
                gRole:sendsit()
            end
        end
    else
        self.sitCount = 0
    end
end

function MainView:checkAutoPath()
    -- body
    -- if not gRole then
    --     return
    -- end

    -- if (gRole:getStateID() == 5 or gRole:getStateID() == 6) and not UJoystick.IsJoystick then
    --     mgr.ModuleMgr:startFindPath(0)
    -- elseif gRole:getStateID() == 1 and mgr.HookMgr.isHook and not UJoystick.IsJoystick then
    --     mgr.ModuleMgr:startFindPath(1)
    -- else
    --     mgr.ModuleMgr:closeFindPath()
    -- end
end

function MainView:updateTimer()
    self:updateOsTime()
    self:updateBatteryLevel()
    self:updateChat()
    self:setRolePos()
    self:autoSit()
     --是否自动寻路
    --self:checkAutoPath()
end
--改变当前时间
function MainView:updateOsTime()
    local timeTab = os.date("*t",mgr.NetMgr:getServerTime())
    local hour = string.format("%02d", timeTab.hour)
    local min = string.format("%02d", timeTab.min)
    -- local sec = string.format("%02d", timeTab.sec) --EVE 不显示秒了
    self.osTimeText.text = hour..":"..min          --..":"..sec
end
--网络
function MainView:updateNetworkState()
    if self.networkState ~= GameUtil.GetNetworkState() then
        if g_ios_test then
            self.netWorkLoader.url = UIItemRes.iosMainIossh01[GameUtil.GetNetworkState()]
        else
            self.netWorkLoader.url = UIItemRes.main05[GameUtil.GetNetworkState()]
        end
        self.networkState = GameUtil.GetNetworkState()
    end
end
--电池百分比
function MainView:updateBatteryLevel()
    if os.time() - self.batteryTime >= 180 then
        self:setBatteryLevel()
        self.batteryTime = os.time()
    end
end

function MainView:setBatteryLevel()
    local level = mgr.SDKMgr:getBatteryLevel()
    if level < 0 then
        level = 100
    end
    self.batteryPro.value = level
    self.batteryPro.max = 100
end

--加载人物经验条信息
function MainView:initRoleExpBar(roleExp,roleLv,oldExp,oldLv)
    -- body
    local oldExp = oldExp or roleExp
    local oldLv = oldLv or roleLv
    local expTxt = self.view:GetChild("n195")
    local lvupExp = conf.RoleConf:getRoleExpById(roleLv)
    if lvupExp > 0 then
        expTxt.text = GTransFormNum(roleExp) .. "/" .. GTransFormNum(lvupExp)--(math.floor(roleExp*1000/lvupExp)/10) .."%"
        self.expBar.value = roleExp
        self.expBar.max = lvupExp
        --经验条增加特效
        local node = self.view:GetChild("n343")
        node.x = self.expBar.x + self.expBar.width*(roleExp/lvupExp)
        -- print("roleLv,oldLv,roleExp,oldExp",roleLv,oldLv,roleExp,oldExp)
        if ((roleExp-oldExp)/lvupExp)*100 > 1 or roleLv > oldLv then
            local effect = self:addEffect(4020121,node)
        end
    else--顶级的时候
        local leftLvUpExp = conf.RoleConf:getRoleExpById(roleLv-1)
        expTxt.text = GTransFormNum(roleExp) .. "/" .. GTransFormNum(leftLvUpExp)--(math.floor(roleExp*1000/lvupExp)/10) .."%"
        -- expTxt.text = "100%"
        self.expBar.value = roleExp
        self.expBar.max = roleExp
    end
end

--红包
function MainView:onClickRedBagBtn( context )
    -- print("==========红包===========")
    GOpenView({id = 1073})
end

function MainView:AnimationBtnFight( ... )
    -- body
    local xy = self.view:GetChild("n302").xy
    for k ,v in pairs(self.animpos) do
        local btn = self.view:GetChild(k)
        btn.xy = xy
        -- btn:TweenMove(Vector2(v.x + 99, v.y + 38),0.13) --EVE 动画优化
        btn:TweenMove(v,0.15)
        mgr.TimerMgr:addTimer(0.15, 1, function()
            -- btn:TweenMove(v,0.08) --EVE
            btn:TweenScale(Vector2.New(1.1, 1.1), 0.08)

            mgr.TimerMgr:addTimer(0.08, 1, function()
                btn:TweenScale(Vector2.New(1, 1), 0.08)
            end)
        end)
    end
end

function MainView:onClickSkillEvent(context)
    local btn = context.sender
    local key = btn.data
    local sex = cache.PlayerCache:getSex()
    --plog("key",key)
    if key == "n301" then--影卫
        GOpenView({id = 1070})
    elseif key == "n3081" then
        --plog("key",key)
        if self.c3.selectedIndex == 0 then
            self.c3.selectedIndex = 1
            self.n3081Effect01:Play()
        else
            self.c3.selectedIndex = 0
            self.n3081Effect01:PlayReverse()

            self:AnimationBtnFight()
            --self.n3081Effect02:Play()
        end
    elseif key == "n386" then
        if 0 == self.c4.selectedIndex then
            self.c4.selectedIndex = 1
        else
            self.c4.selectedIndex = 0
        end
    elseif key == "n362" then
        if self.c7.selectedIndex == 0 then
            self.c7.selectedIndex = 1
        else
            self.c7.selectedIndex = 0
        end
    elseif key == "n401" then --角色
        GOpenView({id = 1069})
    elseif key == "n402" then --锻造
        GOpenView({id = 1029})
    elseif key == "n403" then --技能
        GOpenView({id = 1068})
    elseif key == "n404" then --商城
        GOpenView({id = 1220})--1064改1220bxp
    elseif key == "friend" then --好友
        GOpenView({id = 1065})
    elseif key == "n406" then --伙伴
        GOpenView({id = 1006,index = 0})
    elseif key == "n407" then --战骑
        GOpenView({id = 1001,index = 0})
    elseif key == "n408" then --帮派
        GOpenView({id = 1013,index = 0})
    elseif key == "n409" then --剑神
        GOpenView({id = 1062})

    elseif key == "n410" then --拍卖
        GOpenView({id = 1066})
    elseif key == "n501" then --背包
        mgr.ViewMgr:openView(ViewName.PackView,nil,{index = 1})
    elseif key == "n502" then --活跃

        if not g_ios_test then --EVE 屏蔽修仙
            GOpenView({id = 1156})
        end
    elseif key == "n503" then --充值
        mgr.ModuleMgr:OpenView({id = 1042})
        -- mgr.ViewMgr:openView(ViewName.VipChargeView,function(view) --EVE IOS
        --     proxy.VipChargeProxy:sendRechargeList()
        -- end,{index = 0})
    elseif key == "n504" then --vip
        mgr.ViewMgr:openView(ViewName.VipChargeView,function(view) --EVE IOS
            proxy.VipChargeProxy:sendRechargeList()
        end,{index = 1})
    elseif key == "n5041" then --仙尊卡
        -- if not g_ios_test then --EVE 屏蔽仙尊卡入口
            GOpenView({id = 1063})
        -- end
    elseif  key == "sale" then
        GOpenView({id = 1066})
    elseif key == "marry" then
        GOpenView({id = 1096})
    elseif key == "marrygn" then
        GOpenView({id = 1098})
    elseif key == "home" then
        if mgr.FubenMgr:isHome(cache.PlayerCache:getSId()) then
            GComAlter(language.home107)
            return
        end
        GOpenView({id = 1137})
    elseif key == "pet" then
        GOpenView({id = 1188})
    elseif key == "rune" then
        GOpenView({id = 1213})
    elseif key == "shenqi" then
        GOpenView({id = 1238})
    end
end
--打开好友
function MainView:onClickFriend()
    -- self.firendTipBtn.visible = false
    self.bubblePanel:hideBtn(1)
    GOpenView({id = 1065})
end
--打开邮件
function MainView:onClickMail()
    local param = {id = 1011,index = 9}
    GOpenView(param)
end

--技能按钮进入刷新时间
function MainView:coolDown(key)
    if self.BtnFight then
        self.BtnFight:coolDown(key)
    end
end

--更新血量
function MainView:updateBlood(hp, maxHp)
    self:checkBlood(hp, maxHp)
    self.oldValue = clone(self.roleBloodBar.value)
    self.hpBarValue = hp
    self.roleBloodBar.value = hp
    self.roleBloodBar.max = maxHp
    self.roleBloodText.text = hp.."/"..maxHp
    -- self:releaseHpTimer()
    self.roleBloodFrame.max = maxHp
    if hp >= maxHp then
        self.roleBloodFrame.value = hp
        return
    end

    self.hpValue = hp
    self.hpTime = HpAdvTime
    self.timeBegan = Time.getTime()
    if not self.hpTimer then
        self.hpTimer = self:addTimer(RoleDeleyTime2,-1,handler(self, self.onHpTimer),"MainView2")
    end
end
--血包提示
function MainView:checkBlood(hp, maxHp)
    -- if cache.PlayerCache:getRoleLevel() < BloodBggTipLv then return end
    -- if hp <= 0 then
    --     GCloseBloodBuyView()
    --     self.isBlood = false
    --     return
    -- end
    -- if hp / maxHp <= 0.5 then
    --     if not self.isBlood then
    --         local buffList = {6010201,6010203,6010204}
    --         local isNotFind = true
    --         for k,v in pairs(buffList) do
    --             local buff = mgr.BuffMgr:getBuffByModelId(v,cache.PlayerCache:getRoleId())
    --             if buff then
    --                 isNotFind = false
    --                 break
    --             end
    --         end
    --         if isNotFind then
    --             if hp > 0 then
    --                 mgr.ViewMgr:openView2(ViewName.BloodBuyView, {})
    --             else
    --                 GCloseBloodBuyView()
    --             end
    --             self.isBlood = true
    --         end
    --     end
    -- else
    --     self.isBlood = false
    -- end
end

function MainView:onTimer()
    -- body
    if self.TopActive then
        self.TopActive:onTimer()
    end

    if g_var.auth == 3 then --当时开发人员时
        local errorCount = GameUtil.LogErrorCount()
        if errorCount >0 then
            self.view:GetChild("n381").visible =true
            if not self.errorTxt then
                self.errorTxt = ""
            end
            self.errorTxt = GameUtil.LogErrorStr()
            self.view:GetChild("n381").text = self.errorTxt
        end
    end
end

function MainView:releaseHpTimer()
    if self.hpTimer then
        self:removeTimer(self.hpTimer)
        self.hpTimer = nil
    end
end

function MainView:onHpTimer()
    if Time.getTime() - self.timeBegan >= RoleDeleyTime1 then
        local value = self.oldValue - self.hpValue
        if self.hpTime <= 0 then
            self.roleBloodFrame.value = self.hpBarValue
            self:releaseHpTimer()
            return
        end
        local var = value * (1 - self.hpTime / HpAdvTime)
        self.roleBloodFrame.value = self.oldValue - var
        self.hpTime = self.hpTime - RoleDeleyTime2
    end
end

--刷新人物信息
function MainView:updateRoleInfo()
    -- body
    local data = cache.PlayerCache:getData()
    self.roleLevelLabel.text = cache.PlayerCache:getRoleLevel()
    local strList = string.split(data.roleName,".")--分离服务器名字
    if strList then
        self.roleNameLabel.text = strList[#strList]
    else
        self.roleNameLabel.text = data.roleName
    end
    if self.oldRoleIcon ~= data.roleIcon then
        local vardata = GGetMsgByRoleIcon(data.roleIcon)
        self.roleIcon.url = vardata.headUrl
        self.oldRoleIcon = data.roleIcon
    end
    self.rolePowerLabel.text = GTransFormNum(cache.PlayerCache:getAttribute(501))
    self.btnPowerJiantou.x = self.rolePowerLabel.x + self.rolePowerLabel.width

    -- local hp = cache.PlayerCache:getAttribute(104)
    -- local maxHp = cache.PlayerCache:getAttribute(105)
    -- self:updateBlood(hp, maxHp)
end

--人物信息
function MainView:onRoleinfo()
    mgr.ViewMgr:openView(ViewName.JueSeMainView,function(view)
        -- body
    end,{notself = false,index = 1})
end


---------------------------------------------------------------------------------------------
function MainView:onClickView()

end

--当前战模式
function MainView:onbtnroleMoShi(context)
    mgr.ViewMgr:openView2(ViewName.PkStateView, {})
end
--0-和平,1-杀戮,2-帮派,3-跨服
function MainView:setMoshiState(pkState)
    if self.moshiBtn then
        if g_ios_test then
            self.moshiBtn.icon = UIPackage.GetItemURL(UICommonResIos , tostring(UIItemRes.main01[cache.PlayerCache:getPKState()]))
        else
            self.moshiBtn.icon = UIPackage.GetItemURL("main" , tostring(UIItemRes.main01[cache.PlayerCache:getPKState()]))
        end
    end
end

--战斗力箭头
function MainView:onBtnJiantou()
    -- body
    -- GComAlter("完成主线任务后开启")
    mgr.ViewMgr:openView(ViewName.GrowthView,function(view)
        proxy.GrowthProxy:send_1020301()
    end)
end
--榜
function MainView:onbtnBang( )
    -- body
    -- plog("榜")
    local lv = cache.PlayerCache:getRoleLevel()
    if lv >= 90 then
        mgr.ViewMgr:openView(ViewName.RankMainView,function()end)
    else
        GComAlter(language.rank08)
    end
end
--打开地图界面
function MainView:onClickMap()
    if g_extend_res == false then
        mgr.ViewMgr:openView(ViewName.MapView,function(view) end)
    else
        local check = PathTool.CheckResDown("res/ui/map@.unity3d")
        if check then
            mgr.ViewMgr:openView(ViewName.MapView,function(view) end)
        end
    end
end
--屏蔽设置
function MainView:onClickShield()
    local shield = false
    if mgr.QualityMgr:getAllPlayer() or
        mgr.QualityMgr:getAllPets() or
        mgr.QualityMgr:getAllFaQi() or
        mgr.QualityMgr:getAllWing() or
        mgr.QualityMgr:getAllMonsters() or
        mgr.QualityMgr:getAllChenghao() then
         shield = false
    else
        shield = true
    end
    mgr.QualityMgr:hitAllPlayers(shield)
    mgr.QualityMgr:hitAllFaQi(shield)
    mgr.QualityMgr:hitAllPets(shield)
    mgr.QualityMgr:hitAllWing(shield)
    mgr.QualityMgr:hitAllMonsters(shield)
    mgr.QualityMgr:hitAllChenghao(shield)
    self:setShieldBtn()
end
--设置音效按钮
function MainView:setShieldBtn()
    if not mgr.QualityMgr:getAllPlayer() and
        not mgr.QualityMgr:getAllPets() and
        not mgr.QualityMgr:getAllFaQi() and
        not mgr.QualityMgr:getAllWing() and
        not mgr.QualityMgr:getAllMonsters() and
        not mgr.QualityMgr:getAllChenghao() then
        if g_ios_test then
            self.shieldBtnIcon.url = UIItemRes.iosMainIossh.."zhujiemian_194"
        else
            self.shieldBtnIcon.url = UIItemRes.main06[2]
        end
    else
        if g_ios_test then
            self.shieldBtnIcon.url = UIItemRes.iosMainIossh.."zhujiemian_193"
        else
            self.shieldBtnIcon.url = UIItemRes.main06[1]
        end
    end
end
--音效设置
function MainView:onClickMusic()
    if mgr.SoundMgr:getSoundEnable() or mgr.SoundMgr:getMusicEnable() then--如果音效已经开了
        mgr.SoundMgr:setSoundEnable(false)
        mgr.SoundMgr:setMusicEnable(false)
    else
        mgr.SoundMgr:setSoundEnable(true)
        mgr.SoundMgr:setMusicEnable(true)
    end

    self:setMusicBtn()
end

--设置音效按钮
function MainView:setMusicBtn()
    if mgr.SoundMgr:getSoundEnable() or mgr.SoundMgr:getMusicEnable() then--如果音效已经开了
        self.musicBtnIcon.url = UIItemRes.main04[1]
    else
        self.musicBtnIcon.url = UIItemRes.main04[2]
    end
end
--打开设置界面
function MainView:onClickSite()
    mgr.ViewMgr:openView(ViewName.SiteView,function(view)
        view:nextStep(1)
    end)
end
--飘字挂件
function MainView:getTipsPendant()
    return self.pendant
end

function MainView:onClickFight( context)
    -- body
    local data = context.sender.data
    if not data then
        return
    end
    local player = mgr.ThingMgr:getObj(ThingType.player, data)
    if player then
        if cache.PlayerCache:getPKState() ~= PKState.kill then
            proxy.PlayerProxy:send(1020106,{pkState = PKState.kill})
        end
        mgr.FightMgr:fightByTarget(player.data)
    else
        mgr.FightMgr:fujingAttOver()
    end
end

function MainView:getPackPos()
    local btn = self.view:GetChild("n501")
    return {x = btn.x + btn.width / 2, y = btn.y + btn.height / 2}
end

function MainView:getLimitPackPos()
    local btn = self.limitBtn
    return {x = btn.x + btn.width / 2, y = btn.y + btn.height / 2}
end

function MainView:playPackEff()
    local effectId = 4020106
    local cdTime = os.time() - self.packTime
    local confEffectData = conf.EffectConf:getEffectById(effectId)
    local confTime = confEffectData and confEffectData.durition_time or 0
    if cdTime >= confTime then
        self:addEffect(effectId, self.packEffPanel)
        -- mgr.SoundMgr:playSound(Audios[2])
        self.packTime = os.time()
    end
end

function MainView:playLimitEff()
    local effectId = 4020106
    local cdTime = os.time() - self.limitTime
    local confEffectData = conf.EffectConf:getEffectById(effectId)
    local confTime = confEffectData and confEffectData.durition_time or 0
    if cdTime >= confTime then
        self:addEffect(effectId, self.limitEffPanel)
        -- mgr.SoundMgr:playSound(Audios[2])
        self.limitTime = os.time()
    end
end
--调试窗口
function MainView:initDebug()
    if g_debug_view ~= false then
        mgr.ViewMgr:openView2(ViewName.DebugView)
    end

    -- local debugPanel = self.view:GetChild("n215")
    -- if g_debug_view ~= false then
    --     debugPanel.visible = true
    --     local text = debugPanel:GetChild("title")
    --     text.visible = true
    --     debugPanel.onClick:Add(function()
    --         --plog("cache.PlayerCache:getSId()",cache.PlayerCache:getSId())

    --         if not mgr.ViewMgr:get(ViewName.DebugTestView) then
    --             mgr.ViewMgr:openView(ViewName.DebugTestView)
    --         end
    --     end)

    --     local add = self.view:GetChild("add")
    --     add.onClick:Add(function()
    --         mgr.ThingMgr:addAIPlayer()
    --     end)

    --     local del = self.view:GetChild("del")
    --     del.onClick:Add(function()
    --         mgr.ThingMgr:removeAIPlayer()
    --     end)

    --     self:initKeyEvent()
    -- else
    --     debugPanel.visible = false
    -- end
end
function MainView:setFps(value)
    -- local label = self.view:GetChild("n267")
    -- if label then
    --     label.text = string.format("FPS:%.2f",value)..GameUtil.GetGameProfiler()
    -- end

end
--打坐
function MainView:onDazuo()
    -- body
    gRole:sendsit(true)
end


--任务追踪----------------------------------------------------------------------
function MainView:initTrack()
    self.zhanChangTrack = ZhanChangTrack.new(self)
end
--初始化某些战斗场景的追踪（副本，boss，问鼎等）
function MainView:initFuben()
    if self.c3.selectedIndex ~= 2 then
        self.c3.selectedIndex = 2
    else
        self:onController3()
    end

end

function MainView:setGangChatVisible()
    local gangId = cache.PlayerCache:getGangId()
    if tonumber(gangId) > 0 then
        self.gangChatBtn.visible = true
    else
        self.gangChatBtn.visible = false
    end
end

function MainView:setGangChatBtnRed(visible)
    self.gangChatBtn:GetChild("n5").visible = visible
end
function MainView:getGangChatBtnRed()
    return self.gangChatBtn:GetChild("n5").visible
end

--恢复主场景
function MainView:recoveryMain()
    for i = 0 , self.view.numChildren-1 do
        local var = self.view:GetChildAt(i)
        if var then
            var.visible = true
        end
    end
    self.bubblePanel:setAllVisble()
    self.bubblePanel:checkPrivate()
    self:setLimitPack()
    --活动开启提示隐藏
    self.view:GetChild("n3570").visible = false

    self.view:GetChild("n381").visible = false

    -- self.firendTipBtn.visible = false
    self:setOthersee()
    self:setVisible()
    self:setMoshiState(cache.PlayerCache:getPKState())
    local num = cache.PlayerCache:getAttribute(10202)
    num = num + cache.PlayerCache:getRedPointById(10238)
    num = num + cache.PlayerCache:getRedPointById(10239)
    if not cache.TaskCache:isfinish(1121) then
        self:setRedBag(0)
    else
        self:setRedBag(num)
    end

    self:setXianzunDiscount()--仙尊卡活动提示
    --仙尊体验卡
    self.XianzunExpBtn.visible = false
    self.xianzunBg.visible = false
    self.view:GetChild("n359").visible = false
    if 0 ==  self.c3.selectedIndex then
        self:onController3()
    else
        self.c3.selectedIndex = 0
    end
    self.c4.selectedIndex = 0
    self.c6.selectedIndex = 0
    self.c7.selectedIndex = 0
    local view = mgr.ViewMgr:get(ViewName.PlotDialogView)
    if view then
        view:releaseTimer()
        view:closeView()
    end
    mgr.FubenMgr:endWar()
    self.zhanChangTrack:setVisible(false)
    self:add5050101()

    --仙盟聊天按钮
    self:setGangChatVisible()
    -- if cache.TaskCache:getTaskBack() then
    --     cache.TaskCache:setTaskBack(false)
    --     self:checkOpen()
    --     mgr.XinShouMgr:enterGame()
    -- end
    self:refreshRed()
    self:checkIsbanshu()
    --self:updateBuffs(mgr.BuffMgr.buffIcons)

    --EVE 隐藏坐骑按钮
    if not cache.TaskCache:isfinish(1008) then
        self.btnMounts.visible = false
    else
        self.btnMounts.visible = true
        self.isHaveMount = true
    end
    -- self:btnStateUseMounts()    --刷新坐骑按钮状态
    --EVE END

    if g_ios_test then --EVE 屏蔽
        self.btnPowerJiantou.touchable = false        --我要变强1
        self.view:GetChild("n357").touchable = false --我要变强2

        mgr.SoundMgr:setSoundEnable(false)           --音效/音乐关闭
        mgr.SoundMgr:setMusicEnable(false)
        self.musicBtnIcon.url = UIItemRes.iosMainIossh.."zhujiemian_195"

        self.XianzunExpBtn.scaleX = 0             --屏蔽免费体验卡
        self.XianzunExpBtn.scaleY = 0
        self.xianzunBg.scaleX = 0
        self.xianzunBg.scaleY = 0

        -- self.marrybtn.scaleX = 0             --结婚预告
        -- self.marrybtn.scaleY = 0
    end

    --EVE 皇陵战按钮的图片
    local sId = cache.PlayerCache:getSId()
    local cell = self.view:GetChild("n207")
    if not mgr.FubenMgr:isHuangLing(sId) then
        -- plog("皇陵战按钮的图片已切换")
        if not g_ios_test then
            cell.icon = UIPackage.GetItemURL("main", "zhujiemian_213")
            cell.selectedIcon = UIPackage.GetItemURL("main", "zhujiemian_181")
        end
    end

    -- print("恢复主场景！！！！",cache.PlayerCache:getRedPointById(10256))
    self:setFlashSale() --限时活动特卖冒泡
    self:setBubblePanelVisible()
end
--皇陵之战
function MainView:setHuanglingTask()
    -- body
    self.c3.selectedIndex = 0
    self.c4.selectedIndex = 1
    self.c7.selectedIndex = 1
    self.c6.selectedIndex = 0
    self.view:GetChild("n225").visible = false
    self.view:GetChild("n208").visible = false
    self.view:GetChild("n311").visible = false
    self.view:GetChild("n501").visible = true
    self.view:GetController("c1").selectedIndex = 1
    self.zhanChangTrack:setType(1)
    self.zhanChangTrack:setVisible(true)

    local cell = self.view:GetChild("n207")
    if not g_ios_test then
        cell.icon = UIPackage.GetItemURL("main", "huanglingzhizhan_015")
        cell.selectedIcon = UIPackage.GetItemURL("main", "huanglingzhizhan_016")
    end
end
--练級谷
function MainView:setLevelPanel()
    self.c6.selectedIndex = 0
    self.c4.selectedIndex = 1
    self.c7.selectedIndex = 1
    -- self.view:GetChild("n502").visible = false
    -- self.view:GetChild("n503").visible = false
    -- self.view:GetChild("n504").visible = false
    -- self.view:GetChild("n5041").visible = false
    -- self.view:GetChild("n339").visible = false
    if self.taskorTeam then
        --背景框大小
        -- self.view:GetChild("n202").height = 229
        self.taskorTeam:setSelect(1)
    end
end
--刷新练级谷信息
function MainView:setLevelData()
    if self.taskorTeam then
        self.taskorTeam:setLevelData()
    end
end
--刷新练级谷特权信息
function MainView:setTempData()
    if self.taskorTeam then
        self.taskorTeam:setTempData()
    end
end

--EVE 刷新等级礼包信息
function MainView:refreshGradePackge()
    if self.taskorTeam then
        self.taskorTeam:setItemMsg()
    end
end

function MainView:setInfoArena()
    -- body
    for i = 0 , self.view.numChildren-1 do
        local var = self.view:GetChildAt(i)
        if var then
            var.visible = false
        end
    end
end

function MainView:setInfoVisble(t)
    for i = 0 , self.view.numChildren-1 do
        local var = self.view:GetChildAt(i)
        if var then
            if not t[var.name] then
                var.visible = false
            end
        end
    end
    self:setLimitPack()
end
--EVE 隐藏仙盟驻地顶部按钮
function MainView:setFlameScene()
    -- print("仙盟驻地~~~~~~@@@@@@@@@@@@@@@")
    self.c4.selectedIndex = 1
    local visible = false
    self.view:GetChild("n208").visible = visible
    self.view:GetChild("n209").visible = visible
    self.view:GetChild("n224").visible = visible
    -- self:setTeamBtnVisible(visible)
    local selectedIndex = 1
    if visible then
        selectedIndex = 0
    end
    self.c6.selectedIndex = selectedIndex
    self.c4.selectedIndex = selectedIndex
    self.c7.selectedIndex = selectedIndex
    if self.taskorTeam then
        self.taskorTeam:gotoWar()
    end
    self:onControlChangeOfC4()
end

--婚宴场景
function MainView:setWeddingScene()
    self.view:GetChild("n208").visible = false
    self.view:GetChild("n209").visible = false
    self.view:GetChild("n224").visible = false
    -- self:setTeamBtnVisible(visible)
    self.c6.selectedIndex = 1
    self.c4.selectedIndex = 1
    self.c7.selectedIndex = 1
    if self.taskorTeam then
        self.taskorTeam:gotoWar()
    end
    self:onControlChangeOfC4()
end

----------------------------------------------------------------------
----任务列表
function MainView:add5050101()
    -- body
    if mgr.FubenMgr:checkScene() then
        return
    end
    --
    if not cache.TaskCache:isfinish(1008) then
        self.voiceBtn.visible = false
    else
        self.voiceBtn.visible = false--屏蔽语音按钮2018/06/26bxp
    end


    if self.taskorTeam then
        self.taskorTeam:setSelect(1)
    end
end
--刷新练级谷收益
function MainView:add8090101(data)
    if self.taskorTeam then
        self.taskorTeam:setLevelAward(data)
    end
end

function MainView:add8060101()
    -- body
    if mgr.FubenMgr:checkScene() then
        return
    end
    if self.taskorTeam then
        self.taskorTeam:onController1()
    end
end

function MainView:setLevelTask(oldLv)
    if self.taskorTeam then
        self.taskorTeam:setLevelTask(oldLv)
    end
end


function MainView:setRedBag(num)
    -- body
    local tag = UPlayerPrefs.GetInt("RedBag")
    if tag > 0 then
        if num>0 then
            -- print("显示红包")
            -- self.redBagBtn.visible=true
            self.bubblePanel:appearBtn(3)
        else
            -- self.redBagBtn.visible=false
            self.bubblePanel:hideBtn(3)
        end
    else
        -- self.redBagBtn.visible=false
        self.bubblePanel:hideBtn(3)
    end
end

--帝王将相仙位被抢提示
function MainView:setDiWangLootedTip()
    local var = cache.PlayerCache:getRedPointById(attConst.A50131)
    if self.bubblePanel then
        if var > 0 then
                self.bubblePanel:appearBtn(10)
        else
            self.bubblePanel:hideBtn(10)
        end
    end
end

--EVE 设置限时特卖冒泡
function MainView:setFlashSale()
    -- bodys
    if not self.bubblePanel then  return end

    local view = mgr.ViewMgr:get(ViewName.ArenaFightView)
    if view then
        self.bubblePanel:hideBtn(7)
        return
    end

    local var = cache.PlayerCache:getRedPointById(10256)
    if var>0 then
        self.bubblePanel:appearBtn(7)
    else
        self.bubblePanel:hideBtn(7)
    end
end

--设置变强提示冒泡
function MainView:setGrowthTips()
    -- print("这是一个正经的打印~~~~~~~~~~~~~~")

    local view = mgr.ViewMgr:get(ViewName.ArenaFightView)
    if view then
        self.bubblePanel:hideBtn(9)
        return
    end

    if self.isShow ~= 2 then
        self.bubblePanel:hideBtn(9)
        return
    end

    local conf = conf.GrowthConf:getIsShowRedPointByConf()

    local confSize = 0
    for k,v in pairs(conf) do
        confSize = confSize + 1
    end

    -- print("冒泡长度，", confSize)

    if confSize > 0 then
        self.bubblePanel:appearBtn(9)
    else
        self.bubblePanel:hideBtn(9)
    end
end
--本方法用于控制冒泡面板的显示
function MainView:setBubblePanelVisible()
    --标志位
    self.isShow = nil

    local view = mgr.ViewMgr:get(ViewName.ArenaFightView)
    if view then
        self.isShow = 1
    else
        self.isShow = 2
    end
end

--主界面仙尊卡是否开启打折提示
function MainView:setXianzunDiscount()
    if GXianzunDiscount() and not g_ios_test then
        self.view:GetChild("n339").visible = true
    else
        self.view:GetChild("n339").visible = false
    end
end
--仙尊体验卡主界面tips显隐
function MainView:setXianzunTips(flag)
    -- body
    local view = mgr.ViewMgr:get(ViewName.GuideViewOpen)
    if view then
        return
    end

    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:checkScene() then
        self.XianzunExpBtn.visible = false
        self.xianzunBg.visible = false
        return
    end
    local data = cache.ActivityCache:get5030111()
    local openDay = data and data.openDay or 1
    local c1 = self.xianzunBg:GetController("c1")
    local var = cache.PlayerCache:getAttribute(10310)
    -- print("111111111111",flag,var,openDay,self.marrybtn.visible)
    if var == -1 and flag == false and openDay <= 1 and not cache.PlayerCache:VipIsActivate(1) then
        c1.selectedIndex = 1
        if not self.XianzunExpBtn.visible then
            self.marrybtn.x = self.XianzunExpBtn.x + 76
            self.XianzunExpBtn.visible = true
            self.xianzunBg.visible = true
        end
    else
        c1.selectedIndex = 0
        if not flag then
            if self.marrybtn.x ~= self.XianzunExpBtn.x + 2 then
            --print("2222222222",self.leftMarryPos)
                self.marrybtn.x = self.XianzunExpBtn.x + 2
            end
        else
            if self.marrybtn.x ~= self.XianzunExpBtn.x + 76 then
                self.marrybtn.x = self.XianzunExpBtn.x + 76
            --print("111111111111",self.leftMarryPos)
            end
        end
        self.XianzunExpBtn.visible = flag
        self.xianzunBg.visible = flag
    end
    -- if (not self.marrybtn.visible or self.marrybtn.scale == Vector2.zero) and not self.XianzunExpBtn.visible then
    --     self.lvGiftBtn.x = 186
    --     self.lvGiftBtn.y = 73
    -- elseif (self.marrybtn.visible and self.marrybtn.scale ~= Vector2.zero) and not self.XianzunExpBtn.visible then
    --     self.lvGiftBtn.x = 290
    --     self.lvGiftBtn.y = 73
    -- elseif (not self.marrybtn.visible or self.marrybtn.scale == Vector2.zero) and self.XianzunExpBtn.visible then
    --     self.lvGiftBtn.x = 290
    --     self.lvGiftBtn.y = 73
    -- else
    --     self.lvGiftBtn.x = 223
    --     self.lvGiftBtn.y = 178
    -- end
    self.XianzunExpBtn.data = c1.selectedIndex
    self.XianzunExpBtn.onClick:Add(self.onClickXianzunTy,self)
end
function MainView:setXianzunBgVisible( flag )
    self.xianzunBg.visible = flag
end
--仙尊体验卡倒计时设置
function MainView:XianzunTipsTime(time)

    local hour=math.floor(time/3600);
    local minute=math.floor((time%3600)/60);
    local second=(time%3600)%60;

    local timeTxt1 = self.xianzunBg:GetChild("n1")
    local timeTxt2 = self.xianzunBg:GetChild("n2")

    timeTxt1.text = string.format("%02d",minute)
    timeTxt2.text = string.format("%02d",second)
end
function MainView:onClickXianzunTy(context)
    -- if not g_ios_test then    --EVE 屏蔽处理仙尊卡
    --     return
    -- end
    -- body
    local data = context.sender.data
    if data == 1  then
        mgr.ViewMgr:openView(ViewName.VipExperienceView,function(view)
            view:setEndImg()
        end)
    else
        mgr.ViewMgr:openView2(ViewName.VipExperienceView)
    end
end

--刷新主界面的红点
function MainView:refreshRed()
    self:refreshRedTop()
    self:refreshRedBottom()
    self:bottomRedImg()
    -- self:setGrowthTips()
    if not self.bubblePanel then return end
    local num = cache.PlayerCache:getRedPointById(attConst.A10201)
    if num > 0 and cache.PlayerCache:getSId() ~= ArenaScene then
        -- self.mailTipBtn.visible = true
        self.bubblePanel:appearBtn(2)
    else
        -- self.mailTipBtn.visible = false
        self.bubblePanel:hideBtn(2)
    end
end
function MainView:refreshRedTop()
    -- body

    if self.TopActive then--顶部按钮
        self.TopActive:setRedPoint()
    end
    --vip升级红点
    local var = cache.VipChargeCache:getVipGradeUpRedPoint()
    if var > 0 then
        self.view:GetChild("n504"):GetChild("n5").visible = true
    else
        self.view:GetChild("n504"):GetChild("n5").visible = false
    end

    --月卡红点
    local var = cache.PlayerCache:getRedPointById(20201)

    if var > 0 then
        self.view:GetChild("n504"):GetChild("n5").visible = true
    else
        self.view:GetChild("n504"):GetChild("n5").visible = false
    end

    --限时特卖
    local var = cache.PlayerCache:getRedPointById(10256)
    if var<=0 then
        if self.bubblePanel then
            self.bubblePanel:hideBtn(7)
        end
    end
    --帝王将相仙位被抢
    self:setDiWangLootedTip()
end
--右下角
function MainView:refreshRedBottom()
    -- body
    --红点
    --模块id
    if g_is_banshu then
        return
    end


    local pairs = pairs
    for k ,v in pairs(redt) do
        local btn = self.view:GetChild(k)
        local redimg = btn:GetChild("n5")
        if k == "n408" and tostring(cache.PlayerCache:getGangId())=="0" then
            redimg.visible = false
        else
            local number = 0
            if k == "n401" then
                --计算潜力点
                number = cache.PlayerCache:getAttribute(attConst.A504)
            elseif k == "n402" then
                --锻造计算合成红点
                number = number + GGetCompseNum()
                if mgr.ModuleMgr:CheckView(1153) then
                    number =  number +  G_equip_jie()
                end
                if mgr.ModuleMgr:CheckView(1154) then
                    number =  number +  G_equip_zhuxin()
                end
                --抛光红点
                if mgr.ModuleMgr:CheckView(1412) then
                    number =  number + cache.PackCache:getPaoGuangRed()
                end

                local c1 = conf.ForgingConf:getItemCompose(58)
                if c1.openlv <= cache.PlayerCache:getRoleLevel() then
                    number = number + GGetCompseXianNum(5) + GGetCompseXianNum(6) + GGetCompseNum2(1) +  GGetCompseNum2(2)
                end

                local c1 = conf.ForgingConf:getItemCompose(21)
                if c1.openlv <= cache.PlayerCache:getRoleLevel() then
                    number = number + GGetCompseNum1(9) +  GGetCompseNum1(10)
                end
                local c2 = conf.ForgingConf:getItemCompose(25)
                if c2.openlv <= cache.PlayerCache:getRoleLevel() then
                    number = number + GGetCompseNum1(11) + GGetCompseNum1(12)
                end

                local c3 = conf.ForgingConf:getItemCompose(31)
                if c3.openlv <= cache.PlayerCache:getRoleLevel() then
                    number = number + GGetCompsePetNum()
                end

                local c4 = conf.ForgingConf:getItemCompose(43)
                if c4.openlv <= cache.PlayerCache:getRoleLevel() then
                    for i = 1 , 5 do
                        number = number + GGetCompseWuxingNum(i,5)
                    end
                end

                local c5 = conf.ForgingConf:getItemCompose(48)
                if c5.openlv <= cache.PlayerCache:getRoleLevel() then
                    for i = 1 , 5 do
                        number = number + GGetCompseWuxingNum(i,6)
                    end
                end

                local c6 = conf.ForgingConf:getItemCompose(53)
                if c6.openlv <= cache.PlayerCache:getRoleLevel() then
                    for i = 1 , 5 do
                        number = number + GGetCompseWuxingNum_1(i)
                    end
                end
                local c7openlv = conf.ForgingConf:getComposeOpenLvByType(21)--神装

                if c7openlv <= cache.PlayerCache:getRoleLevel() then
                    number = GGetCompseGod1() + number
                end

                local c8openlv = conf.ForgingConf:getComposeOpenLvByType(22)--神兽神装
                if c8openlv <= cache.PlayerCache:getRoleLevel() then
                    number = GGetCompseShenShouGod() + number
                end
                local c9openlv = conf.ForgingConf:getComposeOpenLvByType(23)--神兽三星
                if c9openlv <= cache.PlayerCache:getRoleLevel() then
                    number = GGetCompseShenShouNum() + number
                end

                local c10openlv = conf.ForgingConf:getComposeOpenLvByType(24)--元素三星
                if c10openlv <= cache.PlayerCache:getRoleLevel() then
                    number = GGetElementCompse() + number
                end


                local c11openlv = conf.ForgingConf:getComposeOpenLvByType(25)--仙装神装
                if c11openlv <= cache.PlayerCache:getRoleLevel() then
                    for i = 1 , 12 do
                        number = number + GGetCompseXianGodNum(i)
                    end
                end




                number = GGetCompseSY() + number

                number = GGetCompseJS() + number


            elseif k == "n408" then
                if GIsXianMengFlameTime() then
                    number = number + 1
                end
                if GFeedBoss() then
                    cache.PlayerCache:setRedpoint(10251,1)
                    -- print("11111111",cache.PlayerCache:getRedPointById(10251))
                end
            elseif k == "shenqi" then
                local num = cache.ShenQiCache:getFenJieRed()
                local flag = cache.ShenShouCache:isCanPromote()--神兽装备穿戴
                if flag then
                    num = num + 1
                end
                   --帝魂红点
                local diHunRed = cache.DiHunCache:getRed()

                number = number + num + diHunRed

                --面具红点
                local mianJuRed = cache.MianJuCache:getRed()
                number = number  + mianJuRed


            elseif k == "n409" then
                --计算一下 强化红点
                number = number + G_isJSRed() + G_RedWuXingQianghua() + GGetShengHunRed() +
                GGetSYstrengRed()+GStrongShengYinRedNum()+GCanPutShengYin() + GGetBMRed()
            end

            if number <= 0 then

                for i ,j in pairs(v) do
                    if mgr.ModuleMgr:CheckView(j) then
                        local condata = conf.SysConf:getModuleById(j)
                        if condata.repoint then
                            for _,var in pairs(condata.repoint) do
                                number = number + cache.PlayerCache:getRedPointById(var)
                                if number>0 then
                                    break
                                end
                            end
                        end

                        if number>0 then
                            break
                        end
                    end

                    if number>0 then
                        break
                    end
                end
            end
            -- if k == "n502" then --修仙特殊处理
                -- local var = cache.PlayerCache:getAttribute(10246)
                -- if var > 0 then
                --     number = number - cache.PlayerCache:getRedPointById(10245)
                -- else
                --     --可渡劫
                --     local activeLv = cache.PlayerCache:getSkins(14) or 0
                --     local sign = cache.PlayerCache:getAttribute(20139)
                --     local nextConf = conf.ImmortalityConf:getAttrDataByLv(activeLv+1)
                --     if nextConf then
                --         -- print("1111111111111111",cache.PlayerCache:getAttribute(20139))
                --         if sign == 0 and activeLv > 1 and activeLv%10 == 0 then
                --             number = number - cache.PlayerCache:getRedPointById(10245)
                --             number = number + 1
                --             -- print("可渡劫",number,sign)
                --         -- else
                --             -- print("不可渡劫",number,cache.PlayerCache:getRedPointById(10245))
                --         end
                --     end
                -- end
            -- end
            -- plog(k,number)
            if number > 0 then

                redimg.visible = true
            else
                redimg.visible = false
            end
            --友好申请没有了默认
            if k == "friend" then
                if number <= 0 then
                    -- self.firendTipBtn.visible = false
                    self.bubblePanel:hideBtn(1)
                end
            end
        end
    end
end

--功能&技能切换按钮红点 bxp
function MainView:bottomRedImg()
    -- body
    if g_ios_test then return end
    local bangpaiNum = 0
    local number = 0
    for k,v in pairs(redt) do
        if k == "n408" and tostring(cache.PlayerCache:getGangId())=="0" then
            bangpaiNum = 0
        else
            if k ~= "n502" and k ~="n3111" and k ~= "friend" then --红包和日常任务,好友不算
                for _,j in pairs(v) do
                    if mgr.ModuleMgr:CheckView(j) then
                        local condata = conf.SysConf:getModuleById(j)
                        if condata.repoint then
                            for _,var in pairs(condata.repoint) do
                                local rednum = cache.PlayerCache:getRedPointById(var)
                                number = number + rednum
                                -- print(var,number,rednum)
                            end
                        end
                    end
                end
            end
        end
    end
    -- print("number~~~~~~~~~~~~~~~~~",(number+bangpaiNum))
    if (number+bangpaiNum)  > 0 and not mgr.FubenMgr:isXdzzWar(cache.PlayerCache:getSId()) then
        self.redImg.visible = true
    else
        self.redImg.visible = false
    end
end

function MainView:setFriendTip()
    self.bubblePanel:appearBtn(1)
end
--私聊来了
function MainView:setPrivateChat(data)
    self.bubblePanel:setPrivateChat(data)
end
--有队伍邀请
function MainView:setTeamJoin(data)
    self.bubblePanel:setTeamJoin(data)
end
--隐藏队伍提示
function MainView:hideTeamJoin()
    self.bubblePanel:hideBtn(6)
end
--有Boss战斗信息
function MainView:setBossNews()
    self.bubblePanel:appearBtn(8)
end
--隐藏Boss战斗信息
function MainView:hideBossNews()
    self.bubblePanel:hideBtn(8)
end

--设置临时背包
function MainView:setLimitPack()
    if not self.limitBtn or not self.limitTimer then return end
    local time = cache.PlayerCache:getAttribute(attConst.limitPack)
    local sId = cache.PlayerCache:getSId()
    if time and time > 0 and (sId ~= ArenaScene and sId ~= DiWangScene and sId ~= YiJiScene) and not mgr.FubenMgr:isXdzzWar(sId) then
        self.limitBtn.visible = true
        self.limitBtn:GetChild("n5").visible = true
        self.limitTimer.visible = true
        self.limitTimer.text = GTotimeString(time)
    else
        self.limitBtn:GetChild("n5").visible = false
        self.limitBtn.visible = false
        self.limitTimer.visible = false
    end
end
--打开临时背包
function MainView:onClickLimit()
    mgr.ViewMgr:openView2(ViewName.LimitPackView, {})
end

--活动预告
function MainView:actForeshow(data)
    if data then
        self.view:GetChild("n3570").visible = true
        local icon = self.view:GetChild("n3570"):GetChild("n1")
        icon.url = UIPackage.GetItemURL("main" , data.icon)
        local curTime = mgr.NetMgr:getServerTime()
        local nowTime = GGetSecondBySeverTime(curTime)
        local nameTxt = self.view:GetChild("n3570"):GetChild("n3")
        local timeTxt = self.view:GetChild("n3570"):GetChild("n2")
        nameTxt.text = data.name
        if data.red_point then
            local endtime = cache.PlayerCache:getRedPointById(data.red_point)
            if data.module_id == 1139 or data.module_id == 1169 then--仙盟战和排位赛
                if data.proceed_time[1] - nowTime <= data.show_time and data.proceed_time[1] - nowTime > 0 then
                    endtime = -1
                else
                    endtime = 1
                end
            end
            -- print("活动预告  活动结束时间>>>>>>>>",endtime,data.name)
            if endtime > 0 then
                timeTxt.text = language.gonggong60
                local sId = cache.PlayerCache:getSId()
                local view = mgr.ViewMgr:get(ViewName.DoubleMajorView)
                if sId == 201001 and data.module_id == 1116 then
                    if not view then
                        data.majorOpen = 1
                        GOpenView({id = data.module_id})
                    end
                else
                    if view then
                        view:onCloseView()
                    end
                end
            else
                -- self.view:GetChild("n3570").onClick:Clear()
                timeTxt.text = data.dec
            end
        else
            if (data.proceed_time[1]-nowTime>0 and (data.proceed_time[1]-nowTime)<data.show_time) then
                timeTxt.text = data.dec
                -- self.view:GetChild("n3570").onClick:Clear()
            else
                timeTxt.text = language.gonggong60
            end
        end
        self.view:GetChild("n3570").data = data
        self.view:GetChild("n3570").onClick:Add(self.onClickGoto,self)
    else
        self.view:GetChild("n3570").onClick:Clear()
        self.view:GetChild("n3570").visible = false
        local view = mgr.ViewMgr:get(ViewName.DoubleMajorView)
        if view then
            view:onCloseView()
        end
    end
end
--跳转
function MainView:onClickGoto( context )
    local cell = context.sender
    local data = cell.data
    if data.module_id then
        local sId = cache.PlayerCache:getSId()
        if data.module_id == 1116 or data.module_id == 1112 or data.module_id == 1126 then
            GOpenView({id = 1105,childIndex = data.module_id})
            -- if sId == 201001 and data.majorOpen then
            --     local view = mgr.ViewMgr:get(ViewName.DoubleMajorView)
            --     if not view then
            --         GOpenView({id = data.module_id})
            --     end
            -- elseif sId ~= 201001 then
            --     GOpenView({id = 1105,childIndex = 1116})
            -- end
        else
            GOpenView({id = data.module_id})
        end
    end
end
--完成成就弹框
function MainView:achieveGet(id)
    local view = mgr.ViewMgr:get(ViewName.AchieveGetItem)
    if view then
        view:setData({id = id})
    else
        mgr.ViewMgr:openView(ViewName.AchieveGetItem,function(view)
            view:setData({id = id})
        end)
    end
end

function MainView:onClickGangChat()
    print("打开仙盟聊天>>>>>>>>>>>>")
    GOpenView({id = 1011,index = 4})
end

function MainView:checkIsbanshu()
    -- body
    if not g_is_banshu then
        return
    end

    --屏蔽按钮点击 并且设置透明度未0
    local t = {"n504","n5041","n134","n135","n136","n137","n330","n309"
    ,"n502","n281","n667","n221","n222","n2801","n279","sale","n3111"
    ,"n803","n346","n345","n801","n802","n339","n3570",}
    for k ,v in pairs(t) do
        local btn = self.view:GetChild(v)
        if btn then
            btn:SetScale(0,0)
        end
    end
    local t = {"n401","n402","n403","n404","n408","n407"}
    self.seetable = {}
    for k , v in pairs(t) do
        local btn = self.view:GetChild(v)
        self.seetable[v] = btn
    end
end

--EVE 坐骑使用
function MainView:onClickUseMounts()
    if not self.isHaveMount then
        self.isHaveMount = true
        self.btnMounts.visible = true
        return
    end

    if gRole:isMajor() then
        GComAlter(language.dazuo16)
        return
    end

    if not gRole:isMount() then
        mgr.InputMgr:useMountsUpper()
        -- self.btnMounts.selected = false
    else
        if gRole:isMount() then
            mgr.InputMgr:useMountsLower()
            -- self.btnMounts.selected = true
        end
    end
    -- plog(self.btnMounts.selected, gRole:isMount(), "~~~~~~~~~22222222222222")
end
--EVE END

function MainView:refMyTeamData()
    if self.taskorTeam then
        self.taskorTeam:refMyTeamData()
    end
    local view = mgr.ViewMgr:get(ViewName.TrackView)
    if view then
        view:refMyTeamData2()
    end
end
--==============================================主界面聊天==============================================
function MainView:initChat()
    self.chatPanel = ChatPanel.new(self)
    self.chatVoice = ChatVoice.new(self)
end

--实时改变主界面聊天
function MainView:updateChat()
    self.chatPanel:updateChat()


end

--附近聊天
function MainView:setNearChat()
    self.chatPanel:setNearChat()
end
--==============================================主界面聊天==============================================
function MainView:clearEvent()
    if self.chatVoice then
        self.chatVoice:clearEvent()
    end
end

return MainView