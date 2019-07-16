--
-- Author: 
-- Date: 2017-02-20 11:22:17
--
--全局定时器
local TimerCache = class("TimerCache",base.BaseCache)
--[[

--]]
function TimerCache:init()
    self.refTop = false--是否要刷新顶部红点
    self.refBottom = false--是否要刷新右下角红点

end

function TimerCache:setTimer()
    self.xianzunTime = 0
    self.daySec = 0
    self.gridValue = 0--记录是不是安全区域
    if not self.timer then
        self.timer = mgr.TimerMgr:addTimer(1, -1, handler(self, self.update),"TimerCache")
    end
end

function TimerCache:releaseTimer()
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
end
--监听方法
function TimerCache:update()
    self:updateSec()
    -- self:updatePack()
    -- self:updateWare()
    self:updateFashion()
    self:updateTitle()   
    self:updateXianzun()
    self:updateLimitTime()
    -- self:updataFirstCharge()
    self:updateOnlineFuli()
    -- self:setHuanglingTime()
    self:updateXianMoTime()
    self:updateWendingTime()
    self:updateGangWarTime()
    self:judeGridValue()
    self:actShow() --活动预告
    -- self:updateZuoqi()
    self:updateXmzbTime()
    self:updateSSSYTime()
    ---
    self:updateTimer()
    self:updateCopperTimer()
    -- self:updateHeadTimer()
    self:updateThqg()----特惠抢购
    self:updateTree()
    -- self:updateGrowthTips() --变强提示
    self:updateGangCombineTime()--仙盟合并倒计时限制
    if self.refTop then
        mgr.GuiMgr:refreshRedTop()
    end
    self.refTop = false

    if self.refBottom then
        mgr.GuiMgr:refreshRedBottom()
    end
    self.refBottom = false

    self:updateFreeTimer()
end

function TimerCache:updateFreeTimer()
    -- body
    local actData = cache.ActivityCache:get5030111()
    if actData.acts[1139] and actData.acts[1139] == 1 then 
        local data = cache.PlayerCache:getRedPointById(30176)
        if not data then return end
        data = data - 1
        cache.PlayerCache:setRedpoint(30176,data)
        if data <= 0 and cache.PlayerCache:getRedPointById(30173)<= 0 then
            mgr.GuiMgr:redpointByVar(30173,1,1)
        end
    end
end

--仙盟合并倒计时限制
function TimerCache:updateGangCombineTime()
    local time = cache.BangPaiCache:getCombineTime()
    if time > 0 then
        cache.BangPaiCache:setCombineTime(time-1)
    else
        cache.BangPaiCache:setCombineTime(0)
    end
end
--结算今天多少秒
function TimerCache:updateSec()
    local timeTab = os.date("*t",mgr.NetMgr:getServerTime())
    local s = 0
    s = s + tonumber(timeTab.hour) * 3600
    s = s + tonumber(timeTab.min) * 60
    s = s + tonumber(timeTab.sec)
    self.daySec = s
end

function TimerCache:updateHeadTimer()
    -- body
    local t = cache.PlayerCache:getHeadData()
    local flag = false
    if t.headImgs then
        for k , v in pairs(t.headImgs) do
            local condata = conf.RoleConf:getHeadConfByid(v.headId)
            if condata and condata.time and condata.time~=0 then
                --plog(v.headId,"headId")
                local var = mgr.NetMgr:getServerTime() - v.gotTime
                if var >= condata.time then
                    flag = true
                    break
                end
            end
        end
    end
    --请求刷新列表
    if flag then
        --plog("有头像过期请求一下头像列表")
        proxy.PlayerProxy:send(1020202)
    end
    --当前头像过期时间
    local data = cache.PlayerCache:getData()
    local splitedata = GGetMsgByRoleIcon(data.roleIcon)
    local id = tonumber(splitedata.icon)

    local condata = conf.RoleConf:getHeadConfByid(id)
    if not condata then
        return
    end

    if not condata.time or condata.time == 0 then
        return 0
    end

    local var = mgr.NetMgr:getServerTime() - cache.PlayerCache:getRedPointById(10319)
    if var>= condata.time then
        --切换成默认头像
         proxy.PlayerProxy:send(1020203,{headImgId = 0})
    end
end

--竞技场倒计时
function TimerCache:updateTimer()
    -- body
    local data = cache.ArenaCache:getData()
    if data and data.leftColdTime then
        data.leftColdTime = data.leftColdTime - 1 
        if data.leftColdTime<0 then
            data.leftColdTime = 0
        end

        if data.leftColdTime == 0 and data.leftChallengeCount>0 then
            if cache.PlayerCache:getRedPointById(50109)<=0 then
                mgr.GuiMgr:redpointByVar(50109,data.leftChallengeCount)
            end
        end
    end
end
--铜钱副本倒计时
function TimerCache:updateCopperTimer()
    local lastTime = cache.FubenCache:getCopperLastTime()
    local redKey = attConst.A50103
    if lastTime then
        local sceneConfig = conf.SceneConf:getSceneById(Fuben.copper)
        local diffTime = sceneConfig and sceneConfig.diff_time or 0
        local severTime = mgr.NetMgr:getServerTime()
        local time = severTime - lastTime--已经过了多少时间
        if time >= diffTime then
            cache.PlayerCache:setRedpoint(redKey,2)
            mgr.GuiMgr:redpointByID(redKey,1)
            cache.FubenCache:setCopperLastTime(nil)
            local view = mgr.ViewMgr:get(ViewName.FubenView)
            if view and view.mainController.selectedIndex == 2 then
                view.copperPanel:refreshRed()
            end
        end
    end
end

--刷新背包格子
function TimerCache:updatePack()
    local curTime = mgr.NetMgr:getServerTime()
    if curTime then
        local packTime = cache.PackCache:getGridKeyData(attConst.packTime)--上一次开启背包的时间
        local packSec = cache.PackCache:getGridKeyData(attConst.packSec)--背包格子累計秒數
        local timeInterval = curTime - packTime + packSec - 2
        local girdOpenNum = cache.PackCache:getGridKeyData(attConst.packNum)--已经开放的格子数
        local num = girdOpenNum or 0
        -- plog("当前开了几个格子",num,"配置总格子",nums)
        if girdOpenNum and girdOpenNum < Pack.packGridNum then
            local girdData = conf.PackConf:getPackGird(girdOpenNum + 1)
            -- plog(curTime,"上一次开启背包的时间",packTime,"背包格子累計秒數",packSec, "当前开了几个格子", girdOpenNum,"时间差",timeInterval,"当前格子开放时间",girdData.cost_sec)
            local view = mgr.ViewMgr:get(ViewName.PackView)
            if view then
                view:setTimeInterval(timeInterval,girdData.cost_sec)
            end
            if girdData and timeInterval >= girdData.cost_sec then
                proxy.PackProxy:sendOpenGird({reqType = 1})
            end
        end
    end
end
--刷新仓库格子
function TimerCache:updateWare()
    local curTime = mgr.NetMgr:getServerTime()
    if curTime then
        local wareTime = cache.PackCache:getGridKeyData(attConst.wareTime)
        local wareSec = cache.PackCache:getGridKeyData(attConst.wareSec)
        local timeInterval = curTime - wareTime + wareSec
        local girdOpenNum = cache.PackCache:getGridKeyData(attConst.wareNum)--已经开放的格子数
        if girdOpenNum then
            local girdData = conf.PackConf:getPackGird(girdOpenNum + 1)
            if girdData and timeInterval >= girdData.cost_sec then
                proxy.PackProxy:sendOpenGird({reqType = 3})
            end
        end
    end
end
--时装时效监听
function TimerCache:updateFashion()
    local curTime = mgr.NetMgr:getServerTime()
    for k,gotTime in pairs(cache.PlayerCache:getFashions()) do
        if gotTime then
            local confTime = conf.RoleConf:getFashData(k).time or 0
            local time = confTime - (curTime - gotTime)
            if time <= 0 then
                proxy.PlayerProxy:send(1270104)--请求时装列表
            end
        end
    end
end
--称号时效监听
function TimerCache:updateTitle()
    local curTime = mgr.NetMgr:getServerTime()
    for k,gotTime in pairs(cache.PlayerCache:getTitles()) do
        if gotTime then
            local confTime = conf.RoleConf:getTitleData(k).time or 0
            local time = confTime - (curTime - gotTime)
            if time <= 0 then
                print("称号时间到了")
                proxy.PlayerProxy:send(1270101)--请求称号列表
            end
        end
    end
end
--白银仙尊体验卡显隐控制
function TimerCache:updateXianzun()
    -- body
    local curTime = cache.VipChargeCache:getXianzunTyTime()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        if curTime then
            if self.xianzunTime < 10 then
                self.xianzunTime = self.xianzunTime + 1
            else
                self.xianzunTime = 0
                proxy.VipChargeProxy:sendXianzunTy(1,2)
            end
            if curTime == 9999 then
                view:setXianzunTips(true)
                view:setXianzunBgVisible(false)
            elseif curTime > 0 then
                view:setXianzunTips(true)
                view:XianzunTipsTime(curTime)
                curTime = curTime - 1
                cache.VipChargeCache:setXianzunTyTime(curTime)
            elseif curTime ~= -1 then
                cache.VipChargeCache:setXianzunTyTime(nil)
                proxy.VipChargeProxy:sendXianzunTy(1,2)
                view:setXianzunTips(false)
                view.BtnFight:checkHuoban()
                local view2 = mgr.ViewMgr:get(ViewName.VipExperienceView)
                if view2 then
                    view2:setEndImg()
                else
                    if not g_ios_test then   --EVE 屏蔽白银仙尊卡面板
                        mgr.ViewMgr:openView(ViewName.VipExperienceView,function(view)
                            view:setEndImg()
                        end)
                    end 
                end
            elseif curTime == -1 then
                view:setXianzunTips(false)
            end
        else
            local _view = mgr.ViewMgr:get(ViewName.GuideLayer)
            if _view and _view.data and _view.data.btn and _view.data.btn.name == "n345" then
            else
                if view.BtnFight then
                    view.BtnFight:checkHuoban()
                end
                view:setXianzunTips(false)
            end
        end
    end
end
--在线送首充时间监听
function TimerCache:updataFirstCharge()
    -- body
    local confdata=conf.VipChargeConf:getVipAwardById(1)
    local onlineTime = GgetOnLineTime()
    if onlineTime > confdata.online_time then
        -- local view = mgr.ViewMgr:get(ViewName.MainView)
        -- if view then
        --     view:refreshRedTop()
        -- end
        self.refTop = true
    end
end
function TimerCache:update24()
    -- body
    --cache.PlayerCache:setonLineTime()
    --清理特别的缓存
    GClearUPlayerPrefs()
    --排位赛红点 周一全清
    local netTime = mgr.NetMgr:getServerTime()
    local day = GGetWeekDayByTimestamp(netTime)
    if day == 1 then
        for i=1,7 do
            cache.PlayerCache:setRedpoint(i+50120,0)
        end
    end
    --清除所有红点
    local data = cache.PlayerCache:getRedPoint()
    if data then
        for k ,v in pairs(data) do
            local confdata = conf.RedPointConf:getDataById(k)
            if confdata and confdata.isclear and confdata.isclear == 1 then
            else
                cache.PlayerCache:setRedpoint(k,0)
            end
        end
        mgr.GuiMgr:updateRedPointPanels()
        mgr.GuiMgr:refreshRedBottom()
    end
    
    --元宝复制、百倍礼包、投资计划红点清零
    cache.PlayerCache:setAttribute(30101,0)
    cache.PlayerCache:setAttribute(30102,0)
    cache.PlayerCache:setAttribute(30105,0)
    --仙尊卡打折红点
    cache.PlayerCache:setAttribute(10310,-1)
    cache.VipChargeCache:setXianzunTyTime(cache.PlayerCache:getAttribute(10310))
    --仙盟战开启红点
    cache.PlayerCache:setAttribute(50111,0)
    --修仙界面关闭
    local view = mgr.ViewMgr:get(ViewName.ImmortalityView)
    if view then
        view:onClickClose()
    end
    --帮派重置
    local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
    if view then
        if view.view:GetController("c1").selectedIndex == 4 then
            proxy.FubenProxy:send(1024501)
        end
    end
    --副本重置
    local view = mgr.ViewMgr:get(ViewName.FubenView)
    if view then
        view:refresh()
    end
    --开服活动
    --plog("24点请求检测")
    
    proxy.ActivityProxy:sendMsg(1030111,{actType = 1})
    print("发送1030111请求活动列表哦!!!!!!!!!!!!!!!!!!!!!~__~~")
    local view = mgr.ViewMgr:get(ViewName.KaiFuMainView)
    if view then
        view:update24()
    end

    --每日活动
    local view = mgr.ViewMgr:get(ViewName.DayActiveView)
    if view then
        view:update24()
    end
    --开服投资
    local view = mgr.ViewMgr:get(ViewName.InvestView)
    if view then
        view:onController()
    end
    --活动祝福值界面
    local view = mgr.ViewMgr:get(ViewName.Alert7)
    if view then
        view:onBtnClose()
    end
    --祝福值清零
    for i=30119,30123 do
        cache.PlayerCache:setAttribute(i, 0)
    end
    --每日一元
    local view = mgr.ViewMgr:get(ViewName.DayOneRmbView)
    if view then
        proxy.ActivityProxy:sendMsg(1030124,{reqType = 0})
    end
    --商城重置
    local shopView = mgr.ViewMgr:get(ViewName.ShopMainView)
    if shopView then
        proxy.ShopProxy:sendStore(shopView:getStoreType())
    end
    --福利大厅
    local welfareView = mgr.ViewMgr:get(ViewName.WelfareView)
    if welfareView then
        if welfareView.classObj[4] and welfareView.classObj[4].visible then
            proxy.ActivityProxy:send(1030103,{reqType = 0,awardId = 0})
        elseif welfareView.classObj[9] and welfareView.classObj[9].visible then
            local var1 = cache.PlayerCache:getRedPointById(attConst.A20127)
            if var1 > 100 then
                welfareView:removeItemById(9)
            end
        end
    end
    --竞技场
    local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
    if view then
        view:update24()
    end
    --7天登陆
    local view = mgr.ViewMgr:get(ViewName.SevenDaysView)
    if view then
        proxy.ActivityProxy:sendMsg(1030147,{reqType=0})
    end
    --练级谷
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isLevel(sId) then
        proxy.FubenProxy:send(1025104)
    end
    --每日首充
    proxy.ActivityProxy:sendMsg(1030121,{reqType = 0})
    --仙尊卡打折活动
    proxy.VipChargeProxy:sendVipPrivilege(0)
    --0元购
    local view = mgr.ViewMgr:get(ViewName.LingyuanView)
    if view then
        proxy.ActivityProxy:sendMsg(1030206, {reqType = 0,cId = 0})
    end
    --重新请求任务信息 必须放在最后面
    --plog("24点请求检测")
    cache.BangPaiCache:setTaskReset(true)
    proxy.TaskProxy:send(1050101)
    local view = mgr.ViewMgr:get(ViewName.BossView)
    if view then
        view:onController1()
    end
    --商城重置
    local _view_ = mgr.ViewMgr:get(ViewName.HomeMainView)
    if _view_ then
        mgr.TimerMgr:addTimer(2,1,function()
            -- body
            _view_:onController1()
        end)
    end
    cache.PlayerCache:setAttribute(attConst.A20129,0)--在线奖励红点清0
    cache.PlayerCache:setAttribute(attConst.A20130,0)--在线奖励红点清0
    cache.PlayerCache:setAttribute(attConst.A20111,0)--在线奖励红点清0
    mgr.GuiMgr:refreshMainRed()
    local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
    if view then--刷新仙盟争霸红点
        view:refreshActivity()
    end
    proxy.ActivityProxy:send(1030168)
    --限时折扣特卖 
    local view = mgr.ViewMgr:get(ViewName.WelfareView)
    if view and view.FlashSalePanel then
        view.FlashSalePanel:sendMsg()
    end
    -- --经验任务
    local view = mgr.ViewMgr:get(ViewName.DailyTaskView)
    if view then 
        -- print("跨0点更新")
        view:onbtnController()
    end
    local view = mgr.ViewMgr:get(ViewName.VipChargeView)
    if view then 
        print("跨0点更新")
        proxy.ActivityProxy:sendMsg(1030512,{reqType = 0,pos = 1,awardId = 0})
    end
    --今日累充
    local view = mgr.ViewMgr:get(ViewName.JinRiLeiChong)
    if view then 
        print("今日累充跨0点更新")
         proxy.ActivityProxy:sendMsg(1030240,{reqType = 0 , awardId = 0})
    end
    --合服连续充值
    local view = mgr.ViewMgr:get(ViewName.HeFuLianChong)
    if view then 
        print("合服连续充值更新")
         proxy.ActivityProxy:sendMsg(1030521,{reqType = 0 , cfgId = 0})
    end
    --中秋
    local view = mgr.ViewMgr:get(ViewName.ZhongQiuView)
    if view then 
        print("中秋")
        local param = {id = view.param.showId}
        view:initData(param)

    end
    --万圣节
    local view = mgr.ViewMgr:get(ViewName.ActWSJMainView)
    if view then
        proxy.WSJProxy:send(1030642,{reqType = 0})
    end
    --各种进阶排行
    local view = mgr.ViewMgr:get(ViewName.JinJieRankMain)
    if view then
        view:onBtnClose()
    end
        --合服连续充值
    local view = mgr.ViewMgr:get(ViewName.TianTianFanLiView)
    if view then 
        print("天天返利更新")
         proxy.ActivityProxy:sendMsg(1030650,{reqType = 0 , cfgId = 0})
    end
         --幸运锦鲤
    local view = mgr.ViewMgr:get(ViewName.XinYunLiJin)
    if view then 
        print("幸运锦鲤")
       proxy.ActivityProxy:sendMsg(1030655,{reqType = 0})
    end
 
         --冬至连冲
    local view = mgr.ViewMgr:get(ViewName.DongZhiLianChong)
 
    if view then 
        print("冬至连冲")
       proxy.DongZhiProxy:sendMsg(1030667,{reqType = 0,cid = 0})
    end

     --冬至
    local view = mgr.ViewMgr:get(ViewName.DongZhiView)
    if view then 
        print("冬至")
        local param = {id = view.param.showId}
        view:initData(param)

    end
    --腊八活动（2019）
    local view = mgr.ViewMgr:get(ViewName.LaBaView2019)
    if view then
        print("腊八活动（2019）")
        proxy.LaBaProxy2019:sendMsg(1030688,{reqType = 0})
    end

    local view = mgr.ViewMgr:get(ViewName.YuanDanMainView)
    if view then 
        -- print("元旦界面0点刷星")
        view:sendMsg()
    end

    --冰雪节活动
    local view = mgr.ViewMgr:get(ViewName.BingXueMainView)
    if view then
        print("冰雪节登陆有礼活动")
        proxy.LaBaProxy2019:sendMsg(1030698,{reqType = 0})
    end

end
---临时背包倒计时
function TimerCache:updateLimitTime()
    local time = cache.PlayerCache:getAttribute(attConst.limitPack)
    local function refresh()
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:setLimitPack()
        end
        local view = mgr.ViewMgr:get(ViewName.LimitPackView)
        if view then
            view:setTimeStr()
        end
    end
    if time > 0 then
        refresh()
        local time = cache.PlayerCache:getAttribute(attConst.limitPack)
        if not cache.PackCache:getIsOpenLimitTip1() and time > 0 and time <= 3600 and mgr.SceneMgr.loginFinsh then
            mgr.ViewMgr:openView2(ViewName.LimitPackTips, {})
        end
        self.updateLimit = false
    else
        if not self.updateLimit then
            refresh()
            local view = mgr.ViewMgr:get(ViewName.LimitPackView)
            if view then
                view:closeView()
            end
            self.updateLimit = true

             --清理缓存
            cache.PackCache:clearLimitPackData()
            proxy.PackProxy:sendLimitMsg()
        end
    end
    cache.PlayerCache:setLimitPackTime(time - 1)
end
--在线福利在线时间
function TimerCache:updateOnlineFuli()
    local key = attConst.A20129
    local onlineTime = cache.PlayerCache:getAttribute(key)
    cache.PlayerCache:setAttribute(key,onlineTime + 1)
    local data = cache.ActivityCache:getOnlineAward()
    if not data then return end
    local redNum = 0
    for k,v in pairs(data) do
        local onlineTime = v.online_time
        local time = cache.PlayerCache:getAttribute(key) or 0
        if time >= onlineTime then
            redNum = redNum + 1
        end
    end
    local redKey = attConst.A20111--在线奖励红点
    local oldRedNum = cache.PlayerCache:getRedPointById(redKey)
    local onLineNum = cache.PlayerCache:getAttribute(attConst.A20130) or 0
    -- plog("onLineNum",onLineNum)
    cache.PlayerCache:setRedpoint(redKey,redNum - onLineNum)--设置红点
    local newNum = cache.PlayerCache:getRedPointById(redKey)
    if newNum > oldRedNum then--如果新红点大于旧红点就刷新
        self.refTop = true
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:nextStep()
        end
    end
end
--皇陵开启时间判断
-- function TimerCache:setHuanglingTime()
--     local curTime = mgr.NetMgr:getServerTime()
--     local nowTime = GGetSecondBySeverTime(curTime)
--     local confData = conf.ActivityShowConf:getActDataById(1078)
--     if not confData then return end
--     if tonumber(nowTime) > confData.proceed_time[1] and tonumber(nowTime) < confData.proceed_time[2] then
--         if cache.HuanglingCache:getHuanglingRedPoint() == 0 then
--             cache.HuanglingCache:setHuanglingRedPoint(1)
--             self.refTop = true
--         end
--     else
--         if cache.HuanglingCache:getHuanglingRedPoint() == 1 then
--             cache.HuanglingCache:setHuanglingRedPoint(0)
--             self.refTop = true
--         end
--     end
-- end
--主界面活动预告
function TimerCache:actShow()
    local actData = conf.ActivityShowConf:getactData()
    local curTime = mgr.NetMgr:getServerTime()
    local nowTime = GGetSecondBySeverTime(curTime)
    local view = mgr.ViewMgr:get(ViewName.MainView)
    local data = nil
    -- local lvLimit = conf.SysConf:getValue("activity_limit")
    local roleLv = cache.PlayerCache:getRoleLevel()
    if view then
        for k,v in pairs(actData) do
            data = nil
            -- print("仙盟战",v.proceed_time[2],nowTime,v.proceed_time[1],v.proceed_time,v.red_point)
            if v.red_point then
                local endtime = cache.PlayerCache:getRedPointById(v.red_point)
                if v.module_id == 1139 then--仙盟战特殊
                    if v.proceed_time[2]-nowTime>0 and (v.proceed_time[1]-nowTime)<=v.show_time then
                        if v.red_open then--仙魔战
                            local isOpen = cache.PlayerCache:getAttribute(v.red_open)
                            -- print("仙盟战是否开启",isOpen)
                            if isOpen == 1 then
                                data = v
                                break
                            end
                        end
                    end
                elseif v.proceed_time and v.openLv <= roleLv then
                        -- print("排位赛处理",v.module_id ,endtime,curTime-endtime,v.proceed_time[1]-nowTime,v.show_time)
                    if (endtime > 0 and curTime-endtime <= 0) or (v.proceed_time[1]-nowTime>0 and (v.proceed_time[1]-nowTime)<=v.show_time) then
                        -- print("000000000000000000000")
                        if v.red_open then--仙魔战
                            local isOpen = cache.PlayerCache:getAttribute(v.red_open)
                            if isOpen == 1 then
                                data = v
                                break
                            end
                        elseif v.module_id == 1079 and cache.PlayerCache:getRedPointById(50128)>0 then--九重天特殊处理
                            local confData = conf.SysConf:getModuleById(1169)
                            local actData = cache.ActivityCache:get5030111() or {}
                            local openDay = actData.openDay or 1
                            local open_forbid_day = conf.QualifierConf:getValue("open_forbid_day")
                            -- print("当前等级",roleLv,confData.open_lev,openDay,open_forbid_day)
                            if roleLv >= confData.open_lev and openDay > open_forbid_day then
                                data = nil
                            else
                                data = v
                                break
                            end 
                        elseif v.module_id == 1169 then
                            -- print("999999999999",cache.PlayerCache:getRedPointById(50128))
                            if mgr.ModuleMgr:CheckSeeView(1169) and v.proceed_time[2]-nowTime>0 and (v.proceed_time[1]-nowTime)<=v.show_time
                            and cache.PlayerCache:getRedPointById(50128) > 0 then
                                data = v
                                break
                            else
                                data = nil
                            end
                        elseif v.module_id == 1127 and mgr.ModuleMgr:CheckView(v.module_id) then--仙盟圣火特殊处理(神兽圣域开启时加等级判断)
                            -- print("111111")
                            if mgr.ModuleMgr:CheckView(1353) and cache.PlayerCache:getRedPointById(50134)>0 then
                                data = nil
                            else
                                data = v
                                break
                            end
                        elseif mgr.ModuleMgr:CheckView(v.module_id) then
                            -- print("活动预告>>>>>>>>>>>>>>",endtime,v.module_id)
                            data = v
                            break
                        end
                    else
                        if v.module_id == 1168 or v.module_id == 1405 then--魅力沙滩特、科举答题
                            if endtime > 0 and curTime - endtime > 0 then
                                local var = cache.PlayerCache:getRedPointById(v.red_point)
                                if var ~= 0 then
                                    cache.PlayerCache:setRedpoint(v.red_point,0)
                                    view.TopActive:checkOpen()
                                end
                                -- print("沙滩、科举>>>>>>>>",v.module_id,endtime)
                                data = v
                                break
                            end
                        end
                    end
                end
            else
                if (v.proceed_time[1]-nowTime>0 and (v.proceed_time[1]-nowTime)<=v.show_time) 
                   or (v.proceed_time[2]-nowTime>0 and v.proceed_time[1]-nowTime<0) then
                    data = v
                    break
                end
            end
        end
        -- view:actForeshow(data)
        -- print("是否进入战斗场景",mgr.FubenMgr:checkScene())
        local roleId = cache.PlayerCache:getRoleId()
        local buffData = {roleId = roleId,buffInfo={buffId=999999,modelId=6020203,reserves=0}}
        local removeData = {roleId = roleId,buffId = buffData.buffInfo.buffId}
        local removeBuff = function(Data)
            mgr.BuffMgr:removeBuff(Data)
            local  buffView = mgr.ViewMgr:get(ViewName.BuffView)
            if buffView then
                buffView:removeBuff(Data)
            end
        end
        if mgr.FubenMgr:checkScene() then
            if cache.PlayerCache:getIsTrebleExp() then--野外三倍刷怪buff移除
                removeBuff(removeData)
                cache.PlayerCache:setIsTrebleExp(false)
            end
            view:actForeshow(nil)
        else
            if data and data.openLv <= roleLv then
                -- if data.red_point == 10249 and GIsYeWaiScene() then--野外三倍刷怪buff添加(假的buff！)
                --     if not cache.PlayerCache:getIsTrebleExp() then
                --         cache.PlayerCache:setIsTrebleExp(true)
                --         mgr.BuffMgr:addBuff(buffData)
                --         local  buffView = mgr.ViewMgr:get(ViewName.BuffView)
                --         if buffView then
                --             buffView:addBuff(buffData)
                --         end
                --     end
                --     view:actForeshow(data)
                -- else
                --     if cache.PlayerCache:getIsTrebleExp() then
                --         removeBuff(removeData)
                --         cache.PlayerCache:setIsTrebleExp(false)
                --     end
                --     view:actForeshow(data)
                -- end
                if data.red_point == 20150 and GIsXianMengStation() then
                    local FlameView = mgr.ViewMgr:get(ViewName.FlameView)
                    if FlameView then
                        FlameView:setSkip(1)
                    end
                    view:actForeshow(nil)
                else
                    local FlameView = mgr.ViewMgr:get(ViewName.FlameView)
                    if FlameView then
                        FlameView:setSkip(0)
                    end
                    view:actForeshow(data)
                end
            else
                if cache.PlayerCache:getIsTrebleExp() then
                    removeBuff(removeData)
                    cache.PlayerCache:setIsTrebleExp(false)
                end
                view:actForeshow(nil)
            end
        end
    end
end

--坐騎時間
function TimerCache:updateZuoqi()
    if mgr.FubenMgr:checkScene() then
        return
    end
    local timeKey2 = attConst.A10243--坐骑当前在线时间
    cache.PlayerCache:setAttribute(timeKey2,cache.PlayerCache:getAttribute(timeKey2) + 1)
    local time = conf.ZuoQiConf:getValue("day_sec_max",0) or 10800
    if cache.PlayerCache:getAttribute(timeKey2) >= time then
        return
    end
    
    if g_is_banshu then
        return
    end
    if not cache.TaskCache:isfinish(ZuoqiTask) or not mgr.ViewMgr:get(ViewName.MainView) then return end
    local isCheck = mgr.ModuleMgr:CheckView({id = 1001})--检测模块配置
    local isNotOpen = cache.PackCache:getNotAdvancedTip(1001)--不能再次打开
    if isNotOpen or not isCheck then return end
    local exp = cache.PlayerCache:getAttribute(attConst.A10240)--坐骑经验值
    local timeKey = attConst.A10242
    cache.PlayerCache:setAttribute(timeKey,cache.PlayerCache:getAttribute(timeKey) + 1)--坐骑在线时间计时
    local lv = cache.PlayerCache:getAttribute(attConst.A10241)--坐骑等级
    if lv > cache.ZuoQiCache:getZuoqiCurLv() or not cache.ZuoQiCache:getZuoqiIsTip() then
        local confData = conf.ZuoQiConf:getDataByLv(lv,0)
        if confData.jie > 6 then return end
        local sec = 0
        if cache.PlayerCache:VipIsActivate(2) then-- 黄金
            sec = confData.sec_ze
        else
            sec = confData.sec
        end
        if cache.PlayerCache:getAttribute(timeKey) >= sec then
            local sumExp = exp + confData.exp * (cache.PlayerCache:getAttribute(timeKey) / sec)
            local need_exp = confData and confData.need_exp or 0
            -- plog("经验",sumExp,need_exp)
            if mgr.ViewMgr:get(ViewName.ZuoQiMain) then
                return
            end
            if sumExp >= need_exp then
                local view = mgr.ViewMgr:get(ViewName.ZuoqiTipView)
                if not view then
                    if not g_ios_test then   --EVE 屏蔽坐骑进阶小弹窗
                        mgr.ViewMgr:openView2(ViewName.ZuoqiTipView,{})
                    end
                end
                cache.ZuoQiCache:setZuoqiCurLv(lv)
                cache.ZuoQiCache:setZuoqiIsTip(true)
            end
        else
            -- plog("时间",cache.PlayerCache:getAttribute(timeKey),sec)
        end
    end
end
--特惠抢购
function TimerCache:updateThqg()
    local timeTab = os.date("*t",mgr.NetMgr:getServerTime())
    local s = 0
    s = s + tonumber(timeTab.hour) * 3600
    s = s + tonumber(timeTab.min) * 60
    s = s + tonumber(timeTab.sec)
    if s > 79200 then
        local redNum = cache.PlayerCache:getRedPointById(attConst.A30109) or 0
        if redNum > 0 then
            mgr.GuiMgr:redpointByID(attConst.A30109,redNum)
        end
    end
end
--刷新姻缘树种子红点
function TimerCache:updateTree()
    if self.daySec == 36000 then
        local redNum = cache.PlayerCache:getRedPointById(attConst.A10247) or 0
        if redNum <= 0 then
            cache.PlayerCache:setRedpoint(attConst.A10247, 1)
            local view = mgr.ViewMgr:get(ViewName.MarryMainView)
            if view then
                view:refreshTreeRed()
            end
            mgr.GuiMgr:updateRedPointPanels(attConst.A10247)
            self.refBottom = true--是否要刷新顶部红点
        end
    end
end

function TimerCache:updateGrowthTips()
    -- body
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:setGrowthTips()
    end
end

--仙魔战开启时间判断
function TimerCache:updateXianMoTime()
    local redTime = cache.PlayerCache:getRedPointById(attConst.A20142)--活动是否开启了
    if redTime <= 0 then
        cache.XianMoCache:setXianMoRedPoint(0)
        self.refTop = true
        return
    end
    local openTimes = conf.XianMoConf:getValue("open_time")
    if tonumber(self.daySec) < openTimes[2] and tonumber(self.daySec) > openTimes[1] then
        if cache.XianMoCache:getXianMoRedPoint() == 0 then
            cache.XianMoCache:setXianMoRedPoint(1)
            self.refTop = true
        end
    else
        if cache.XianMoCache:getXianMoRedPoint() == 1 then
            cache.XianMoCache:setXianMoRedPoint(0)
            self.refTop = true
        end
    end
end

--问鼎战开启时间判断
function TimerCache:updateWendingTime()
    local redTime = cache.PlayerCache:getRedPointById(attConst.A20131)--活动是否开启了
    if redTime <= 0 then
        cache.WenDingCache:setWendingRedPoint(0)
        self.refTop = true
        return
    end
    local openTimes = conf.WenDingConf:getValue("wending_open_time")
    if tonumber(self.daySec) < openTimes[2] and tonumber(self.daySec) > openTimes[1] then
        if cache.WenDingCache:getWendingRedPoint() == 0 then
            cache.WenDingCache:setWendingRedPoint(1)
            self.refTop = true
        end
    else
        if cache.WenDingCache:getWendingRedPoint() == 1 then
            cache.WenDingCache:setWendingRedPoint(0)
            self.refTop = true
        end
    end
end
--仙盟战开启时间判断
function TimerCache:updateGangWarTime()
    local redTime = cache.PlayerCache:getRedPointById(attConst.A20133)--活动是否开启了
    if redTime <= 0 then
        cache.GangWarCache:setGangWarRedPoint(0)
        self.refTop = true
        return
    end
    local openTimes = conf.GangWarConf:getValue("open_times")
    if tonumber(self.daySec) < openTimes[2] and tonumber(self.daySec) > openTimes[1] then
        if cache.GangWarCache:getGangWarRedPoint() == 0 then
            cache.GangWarCache:setGangWarRedPoint(1)
            self.refTop = true
        end
    else
        if cache.GangWarCache:getGangWarRedPoint() == 1 then
            cache.GangWarCache:setGangWarRedPoint(0)
            self.refTop = true
        end
    end
end
--判断是不是安全区域
function TimerCache:judeGridValue()
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isXianMoWar(sId) or mgr.FubenMgr:isGangWar(sId) 
        or mgr.FubenMgr:isKuafuWorld(sId) or mgr.FubenMgr:isKuafuXianyu(sId) 
        or mgr.FubenMgr:isCollectTreasure(sId) then
        if gRole then
            local gridValue = gRole:getGridValue()
            if gridValue ~= 7 then
                gridValue = 1
            end
            if self.gridValue == gridValue then
                return
            end
            if self.gridValue > 0 then
                if gridValue == 7 then
                    --进入了安全区域
                    GComAlter(language.xianmoWar18[1])
                else
                    --离开了安全区域
                    GComAlter(language.xianmoWar18[2])
                end
            end
            self.gridValue = gridValue
        end
    else
        self.gridValue = 0
    end
end
--仙盟争霸红点
function TimerCache:updateXmzbTime()
    local redTime = cache.PlayerCache:getRedPointById(attConst.A20133)
    if redTime > 0 then
        if mgr.NetMgr:getServerTime() >= redTime then
            mgr.GuiMgr:redpointByVar(attConst.A20133,0)--清理红点
            local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
            if view then
                view:refreshActivity()
            end
        end
    end
end
--神兽圣域红点计算
function TimerCache:updateSSSYTime()
    -- body
    local endTime = cache.PlayerCache:getRedPointById(attConst.A50133) --神兽圣域开始时间
    if endTime > 0 then
        if  cache.ActivityCache:get5030111() then
            if mgr.NetMgr:getServerTime() > endTime or not mgr.ModuleMgr:CheckView(1353)  then
                mgr.GuiMgr:redpointByVar(attConst.A50133,0,3)
            end
        end
    end

end

return TimerCache