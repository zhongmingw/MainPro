--
-- Author:
-- Date: 2017-01-04 14:31:47
--
local PlayerCache = class("PlayerCache",base.BaseCache)
local opent = {
    [1001] = 0,--坐骑
    [1002] = 3,--仙羽
    [1003] = 1,--神兵
    [1004] = 4,--仙器
    [1005] = 2,--法宝
    [1006] = 0,--灵童
    [1007] = 1,--灵羽
    [1008] = 2,--灵兵
    [1009] = 4,--灵器
    [1010] = 3,--灵宝
    [1287] = 5,--麒麟臂

}
function PlayerCache:init()
    self.data = {}--玩家登陆时， 初始需要的数据都在这里返回 协议 1010102
    self.redpoint = {}--红点信息
    --记录玩家登陆时间
    self.onLineTime = self.onLineTime
    --是否在主界面刷新
    self.mianReset = false
    --玩家的登录令牌
    self.loginSign = nil

    self.zhanChang = {}

    self.headdata = {}

    self.moduleList = {} --模块关闭列表

    self.moduleJies = {} --模块对应的阶

    self.djCdLeftTime = 0 --渡劫CD时间

    self.marryTime = 0--前往结婚时间

    self.mSkinsData = {}--缓存获得的弹窗外观

    self.hookTiaoguo = true --离线挂机默认跳过

    self.skillData = {} --10个系统的技能等级
    self.setneedskilBook = {}
    self.__allbook = {} --作弊看所有需要的书

    self.isTrebleExp = false--野外刷怪3倍经验

    self.skinStarMap = {}

    --主界面活动按钮假显示红点(登陆时显示，点击按钮后消失)
    self.actFakeRed = {
        [1428] = 1,--活动中心
        [1263] = 1,--合服活动
        [1284] = 1,--精彩活动
        [1271] = 1,--开服活动
    }
end

--获取假显示红点
function PlayerCache:getActFakeRed(id)
    return self.actFakeRed[id]
end
--假显示红点修改值
function PlayerCache:setActFakeRed(id,var)
    self.actFakeRed[id] = var
end

function PlayerCache:setIsTrebleExp( flag )
    self.isTrebleExp = flag
end
function PlayerCache:getIsTrebleExp()
    return self.isTrebleExp
end

function PlayerCache:setDataSkill( data )
    -- body
    self.skillData = data.modules

    --计算一次所需要的技能书
    self:setNeedSkilBook()
end

function PlayerCache:setNeedSkilBook()
    -- body
    if not self.skillData then
        return
    end

    for k ,v in pairs(self.skillData) do
        local skillid = tonumber(string.sub(k,5))
        local module_id = tonumber(string.sub(k,1,4))
        --print("k",k,module_id,skillid,v)
        --self:setSkilBook(module_id,skillid,v)
        self:updateSkillLevel(module_id,skillid,v)
    end
end

function PlayerCache:updateSkillLevel(module_id,skillid,level)
    -- body
    if not module_id or not skillid or not level then
        return
    end

    --需要分区 多余(已经学过) 需要(当前需要) 未学(之后需要)
    --已经学过
    for i = 0 , level - 1  do
        self:setSkilBook(module_id,skillid,i,1)
    end
    --需要(当前需要)
    self:setSkilBook(module_id,skillid,level,2)
    --未学(之后需要)
    for i = level + 1 , 10  do
        self:setSkilBook(module_id,skillid,i,3)
    end



    -- local key = module_id..skillid
    -- self.skillData[tonumber(key)] = level
    -- --重新计算需要
    -- self:setSkilBook(module_id,skillid,level-1,true)
    -- self:setSkilBook(module_id,skillid,level)
end

function PlayerCache:setSkilBook( module_id,skillid,level,flag)
    -- body
    --就按当前需要的书
    local confdata
    if module_id < 1006 or module_id == 1287 then
        confdata = conf.ZuoQiConf:getSkillByLev(skillid,level,opent[module_id])
    else
        confdata = conf.HuobanConf:getSkillLevData(skillid,level,opent[module_id])
    end
    if confdata and confdata.cost_items then
        self.setneedskilBook[confdata.cost_items[1][1]] = flag
    end

    -- if delete then
    --     if confdata and confdata.cost_items then
    --         self.setneedskilBook[confdata.cost_items[1][1]] = nil
    --         --作弊的
    --         self.__allbook[confdata.cost_items[1][1]] = nil
    --     end
    -- else
    --     if confdata and confdata.cost_items then
    --         self.setneedskilBook[confdata.cost_items[1][1]] = true
    --     end
    -- end
end

--是否需要
function PlayerCache:getIsNeed(mId)
    -- body
    return self.setneedskilBook[mId]
    -- if self.setneedskilBook[mId] then
    --     if not flag then
    --         --排除背包
    --         if cache.PackCache:getPackDataById(mId).amount > 0 then
    --             return false
    --         else
    --             return true
    --         end
    --     else
    --         --只要需要 不管是否在
    --         return self.setneedskilBook[mId]
    --     end
    -- end
    --return false
end

function PlayerCache:__getIsNeed(mId)
    -- body
    if self.__allbook[mId] then
        if cache.PackCache:getPackDataById(mId).amount > 0 then
            return false
        else
            return true
        end
    end
    return false
end

--作弊的时候判定技能书
function PlayerCache:__setIsNeed(mId)
    -- body
    if not self.skillData then
        return
    end

    local function jcsb(module_id,skillid,level)
        -- body
        for i = level,10 do
            local confdata
            if module_id < 1006 or module_id == 1287  then
                confdata = conf.ZuoQiConf:getSkillByLev(skillid,i,opent[module_id])
            else
                confdata = conf.HuobanConf:getSkillLevData(skillid,i,opent[module_id])
            end

            if confdata and confdata.cost_items then
                self.__allbook[confdata.cost_items[1][1]] = true
            end
        end
    end

    for k ,v in pairs(self.skillData) do
        local skillid = tonumber(string.sub(k,5))
        local module_id = tonumber(string.sub(k,1,4))
        jcsb(module_id,skillid,v)
    end
end


function PlayerCache:setHookTiaoguo( flag )
    self.hookTiaoguo = flag
end
function PlayerCache:getHookTiaoguo(  )
    return self.hookTiaoguo
end


function PlayerCache:setDujieCD( djCdLeftTime )
    self.djCdLeftTime = djCdLeftTime
end
function PlayerCache:getDujieCD()
    return self.djCdLeftTime
end

--离线挂机排序缓存
function PlayerCache:setoffHookType( reqType )
    -- body
    self.offHookType = reqType
end
function PlayerCache:getoffHookType()
    -- body
    return self.offHookType or 1
end
--离线挂机同盟筛选缓存
function PlayerCache:setExecptGangType( execptGang )
    -- body
    self.execptGang = execptGang
end
function PlayerCache:getExecptGangType()
    -- body
    return self.execptGang or 0
end
--离线挂机好友筛选缓存
function PlayerCache:setExecptFriendType( execptFriend )
    -- body
    self.execptFriend = execptFriend
end
function PlayerCache:getExecptFriendType()
    -- body
    return self.execptFriend or 0
end

function PlayerCache:setModuleList(list)
    self.moduleList = {}
    for k,v in pairs(list) do
        table.insert(self.moduleList,v)
    end
end

function PlayerCache:getModuleList()
    return self.moduleList
end

function PlayerCache:setHeadData(data)
    -- body
    self.headdata = data
end

function PlayerCache:getHeadData()
    -- body
    return self.headdata
end

function PlayerCache:setReset(var)
    -- body
    self.mianReset = var
end

function PlayerCache:getReset(var)
    -- body
    return self.mianReset
end

--設置玩家称号
function PlayerCache:setChenghao(wearTitle)
    -- body
    self.data.wearTitle = wearTitle
end

function PlayerCache:getChenghao()
    -- body
    return self.data.wearTitle
end

--这个时间再 5010102 这条消息返回时候保存一次 24点TimerCache:check24 改变一次
function PlayerCache:setonLineTime()
    self.onLineTime = mgr.NetMgr:getServerTime()
end

function PlayerCache:getonLineTime()
    return self.onLineTime
end

function PlayerCache:setBuffsData(buffs)
    -- body
    if self.data then
        self.data.buffs = buffs
    end
end

function PlayerCache:setData(data)
    local firstLogin = nil
    --每日首次登陆红点
    if self.data and self.data.attris and self.data.attris[10322] then
        firstLogin = self.data.attris[10322]
    end
    self.data = data
    if firstLogin then
        self.data.attris[10322] = firstLogin
    end
    self:updataAttris(data.attris)--更新玩家属性
end

function PlayerCache:getData()
    return self.data
end
--更新玩家属性
function PlayerCache:updataAttris(data,isRef)
    local oldExp = cache.PlayerCache:getRoleExp()
    local oldLv = cache.PlayerCache:getRoleLevel()
    local newExp = 0
    local isRefRed = false
    local curHp = -1
    for k ,v in pairs(data) do
        if k == 50120 then
            local view = mgr.ViewMgr:get(ViewName.BingXueMainView)
            if view then
                view:refreshList()
            end
        end
        if k == 104 then--记录当前血
            curHp = v

        elseif k == 105 then--先刷新最大血
            local hp = self:getAttribute(104)
            if gRole then
                gRole:setMaxHp(v)
                gRole:setHp(hp)
            end
        elseif k <= 100 then
            self:setSkins(k,v)
        elseif k == 101 then--经验
            newExp = v
        elseif k == 501 then --EVE 战斗力变化
            self:setOldPower(self:getRolePower())   --将原有战力设为旧战力
            local temp = v - self:getOldPower()
            -- v 新战力 self:getRolePower() 旧战力
            if isRef and temp > 0 and self:getOldPower()~=0 then
                --打开一个界面显示
                local view = mgr.ViewMgr:get(ViewName.PowerChangeView)
                if view then
                    view:closeSelf()
                end
                mgr.ViewMgr:openView2(ViewName.PowerChangeView,v)
            end
        elseif k == 10202 then --红包
            -- print("红包",v,UPlayerPrefs.GetInt("RedBag"))
            if UPlayerPrefs.GetInt("RedBag")==11 then
                local view=mgr.ViewMgr:get(ViewName.MainView)
                if view then
                    view:setRedBag(v)
                end
            end
        elseif k == 10108 then --角色在线时间
            local severTime = mgr.NetMgr:getServerTime()
            cache.VipChargeCache:setOnlineTime(severTime)
            self:setRedpoint(k,v)
            isRefRed = true
        elseif k == attConst.packNum or k == attConst.packTime or k == attConst.wareNum or k == attConst.wareTime or k == attConst.packSec or k == attConst.wareSec then
            cache.PackCache:setGridKeyData(k,v)--部分再缓存到背包里面
        elseif k == 10302 then--白银vip
            local view = mgr.ViewMgr:get(ViewName.SitDownView)
            if view then
                view:setData()
            end
        elseif k == 10306 then  --这个是通知24点
            --plog("24dian ")
            cache.TimerCache:update24()
        elseif k == 30140 then --经验任务，五色塔bxp
            local var = cache.PlayerCache:getRedPointById(30140)
            -- print("升级更新30140红点值",var)
            self:setRedpoint(k,v)
        elseif k == 10309 then
            if cache.PlayerCache:getAttribute(10309) > 0 and isRef then
                if g_ios_test then  --EVE 屏蔽处理
                    GComAlter(string.format(language.map07,v))
                else
                    if not self:VipIsActivate(1) then--白银仙尊时屏蔽飘字
                        GComAlter(string.format(language.map06,v))
                    end
                end
            end
        elseif k == 10310 then
            --if v > 0 then
                cache.VipChargeCache:setXianzunTyTime(v)
            --else
                --cache.VipChargeCache:setXianzunTyTime(nil)
            --end
        elseif k == 511 then  --pk模式
            --gRole:changePkState()
        elseif k == 510 then
            local var = v - self:getAttribute(510)
            --mgr.TipsMgr:addRightTip({text=language.gonggong37, count=var, color = 1})
        elseif k == 10227 then --申请
            if v > 0 then
                local view = mgr.ViewMgr:get(ViewName.MainView)
                if view then
                    view:setFriendTip()
                end
            end
        elseif k == 20131 or k == 20132 or k == 20133 or k == 50111 then--问鼎、皇陵、仙盟战结束时间
            --50111为仙盟战开启时间戳
            if v > 0 then
                self:setAttribute(k,v)
            end
        elseif k == 30107 then
            self:setDownloadGift()
        elseif k == 10314 then --服务器时间
            mgr.NetMgr._serverTime = v
            mgr.NetMgr._saveTime = os.time()
        elseif k == attConst.A10316 then--练级谷
            -- local view = mgr.ViewMgr:get(ViewName.MainView)
            -- if view then
            --     view:setTaskList()
            -- end
        elseif k == 10317 then
            --竞技场刷新一下
            local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
            if view then
                if view.c1.selectedIndex == 0 then
                    proxy.ArenaProxy:send(1310101)
                end
            end
        elseif 10320 == k then
            --离婚请求
            GlihunRequst()
        elseif 30108 == k then
            --/** 通知客户端刷新活动列表 **/
            proxy.ActivityProxy:sendMsg(1030111,{actType = 1})
        elseif 10321 == k then
            self.marryTime = mgr.NetMgr:getServerTime()
        elseif k == 10315 then --充值成功刷新
            local view = mgr.ViewMgr:get(ViewName.VipChargeView)  --EVE IOS
            if view then
                proxy.VipChargeProxy:sendRechargeList()
            end
        elseif k == 10318 then --完成成就红点推送
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:achieveGet(v)
            end
        elseif k == 30103 then
            --print("每日一元红点更新",v)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview.TopActive:checkActive()
            end
        elseif k == 20137 then --离线挂机
            local view = mgr.ViewMgr:get(ViewName.WelfareView)
            if view then
                if v > 0 then
                    view:refHookRed()
                end
            end
        elseif k == 50118 then--婚礼开启红点
            self:setAttribute(k,v)
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view.TopActive:checkOpen()
            end
        elseif k == 30127 then  --EVE 天书活动的坑爹红点
            -- print("每日一元红点31231231231更新",v)
            self:setRedpoint(k,v)
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview.TopActive:checkActive()
            end
        elseif k == 30131 then--圣诞袜掉落播放特效
            -- local sId = self:getSId()
            -- print("圣诞袜刷新",v,sId)
            -- if sId == 201001 then
                if v == 1 then
                    mgr.ViewMgr:openView2(ViewName.Alert15,4020150)
                end
            -- end
        elseif k == 30130 then
            self:setRedpoint(k,v)
            -- print("30130",k,v)
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view:refreshGradePackge()
            end
        elseif k == 20153 then --EVE 刷新主界面的等级礼包入口
            self:setRedpoint(k,v)
            -- print("20153",k,v)
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view:refreshGradePackge()
            end
        elseif k == 10251 then--仙盟boss喂养红点刷新
            self:setRedpoint(k,v)
            local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
            if view and view.panelActivity then
                view.panelActivity:refreshRedPoint()
            end
        elseif k == 10256 then --限时特卖的冒泡打开
            -- print("开启限时特卖~~~~~~~~~~~~~~~~~！！@##@")
            local mainView = mgr.ViewMgr:get(ViewName.MainView)
            if mainView then
                mainView.bubblePanel:appearBtn(7)
            end
        elseif k == attConst.A20167 then--boss战斗信息
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                if v > 0 then
                    view:setBossNews()
                else
                    view:hideBossNews()
                end
            end
        elseif k == attConst.A20168 then--城战开启红点刷新
            local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
            if view then
                proxy.CityWarProxy:sendMsg(1510101,{awardGot = 0})
            end
        elseif k == attConst.A20169 then--城战领取红点、宣战红点刷新
            local view = mgr.ViewMgr:get(ViewName.CityWarAwards)
            if view then
                view:refreshRed(v)
            end
        elseif k == 20215 then--记忆花灯下开启时间
            self:setRedpoint(k,v)
            local view = mgr.ViewMgr:get(ViewName.YuanDanMainView)
            if view then
                view:refresh20215()
                view:refeshList()
            end
        elseif k == 30257 then-- 生肖宝藏红点
            if v > 0 then
                proxy.ShengXiaoProxy:sendGetBaoZangInfo(0)
            end
        end
        -- if k == 50108 then
        --     plog("推送 帮派扫荡红点 > 0 表示能扫荡",v)
        -- elseif k == 50110 then
        --     plog("推送 帮派领取红点 >0 表示有奖励领取",v)
        -- end

        if conf.RedPointConf:getDataById(k) then --这个是红点
            self:setRedpoint(k,v)
            if isRef then
                mgr.GuiMgr:updateRedPointPanels(k)
            end
            isRefRed = true
        else
            self:setAttribute(k,v)
        end
        if k == 30142 or k == 30143 or k == 30144 or k == 30145 then--充值消费排行活动刷新
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view.TopActive:checkOpen()
            end
        end
    end
    for k,v in pairs(data) do--在服务器时间更新之后设置
        if conf.RedPointConf:getDataById(k) then
            self:checkZhanChang(k,v)
        end
    end
    if curHp >= 0 then--如果记录的当前血大于0
        local maxHp = self:getAttribute(105)
        if curHp > maxHp then
            curHp = maxHp
        end
        if gRole then
            gRole:setHp(curHp)
        end
    end
    if isRefRed then
        mgr.GuiMgr:refreshMainRed()
    end
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view.TopActive:checkActive()
        view:refreshRedTop()
    end
    self:vipRedPoint()
    self:tipsExp(oldExp,oldLv,newExp)
end
--计算vip升星红点
function PlayerCache:vipRedPoint()
    local vipLv = self:getVipLv()
    local vipStars = self:getVipStars()
    local vipExp = self:getVipExp()
    local id = vipLv*1000+vipStars
    if vipLv >= 1 then
        local vipAttConf = conf.VipChargeConf:getVipAttrDataById(id)
        local nextId = id
        if vipStars == 10 or vipLv == 1 then
            nextId = (vipLv+1)*1000+1
        else
            nextId = id+1
        end
        local nextVipConf = conf.VipChargeConf:getVipAttrDataById(nextId)
        -- print("VIP红点",nextVipConf,vipExp,needVipExp)
        if nextVipConf then
            local needVipExp = nextVipConf.vip_exp - vipAttConf.vip_exp
            if vipExp-vipAttConf.vip_exp >= needVipExp then
                cache.VipChargeCache:setVipGradeUpRedPoint(1)
            else
                cache.VipChargeCache:setVipGradeUpRedPoint(0)
            end
        else
            cache.VipChargeCache:setVipGradeUpRedPoint(0)
        end
    else
        local lv = self:getRoleLevel()
        if lv >= 30 then
            cache.VipChargeCache:setVipGradeUpRedPoint(1)
        else
            cache.VipChargeCache:setVipGradeUpRedPoint(0)
        end
    end
end
--飘经验
function PlayerCache:tipsExp(oldExp,oldLv,newExp)
    --飘经验
    local exp = 0
    local newLv = cache.PlayerCache:getRoleLevel()
    if newLv > oldLv then
        for i=oldLv,newLv - 1 do
            local data = conf.RoleConf:getByRoleLevel(i)
            local attExp = data and data.att_101 or 0
            if i == oldLv then
                exp = attExp
            else
                exp = exp + attExp
            end
        end
        exp = exp + newExp - oldExp
        --升级特效
        -- local parent = UnitySceneMgr.pStateTransform
        if gRole then
            local effect = mgr.EffectMgr:playCommonEffect(4040102, gRole:getRoot())
            effect.LocalPosition = Vector3.zero
        end
        --升级刷新主界面信息
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            mgr.SoundMgr:playSound(Audios[4])
            view:updateMaininfo()
            view:setLevelTask(oldLv)
            --
            view:checkOpen({btnfight = true})
            if view.BtnFight and view.c3.selectedIndex == 0 then
                view.BtnFight:isSee(true)
                --view.BtnFight:checkTwoBtn()
            end
            --print("升级刷新红点")
            view:refreshRed()
        end
        --升级记录等级
        mgr.HttpMgr:RecordAccSer(nil)
        --SDK 上传数据
        if gRole then
            mgr.SDKMgr:submitData(3003)
        end






        --

        --EVE 聚宝盆活动提醒(当玩家等级提升时)
        local sceneId = cache.PlayerCache:getSId()  --是否在竞技场中
        local roleLv = cache.PlayerCache:getRoleLevel()
        local mainView = mgr.ViewMgr:get(ViewName.MainView)
        if mainView then
            mainView:refMyTeamData()
        end

        if mgr.FubenMgr:isKuaFuWar(sceneId) then
            --如果是三界争霸
            local _view = mgr.ViewMgr:get(ViewName.TrackView)
            if _view and _view.KuaFuWar then
                _view.KuaFuWar:initMsg()
            end
        elseif mgr.FubenMgr:isArena(sceneId) then
            --在竞技场
            --比较难出现
            mgr.FubenMgr:quitFuben()
        end

        mgr.ViewMgr:openView2(ViewName.RoleUpgradeView,{lv = newLv})
        --升级检测新手预告
        mgr.XinShouMgr:updateLevel()
        --升级检测是否需要请求任务
        mgr.TaskMgr:checkLevelTask()
        -- -- plog("场景ID",sceneId,roleLv)
        -- if cache.TaskCache:isfinish(1099) and sceneId ~= 214001 and roleLv <= 80 then
        --     local view = mgr.ViewMgr:get(ViewName.RemindCopy)
        --     if not view and not g_ios_test then
        --         if mainView then
        --             local pairs = pairs
        --             local topos
        --             for k ,v in pairs(mainView.TopActive.btnlist) do
        --                 for i , j in pairs(v) do
        --                     if j.data and j.data.id == 1060 then
        --                         mgr.ViewMgr:openView2(ViewName.RemindCopy, {})
        --                         break
        --                     end
        --                 end
        --             end
        --         end
        --     end
        -- end
    else
        exp = newExp - oldExp
    end
    --经验条刷新
    local roleExp = cache.PlayerCache:getRoleExp()
    local roleLv = cache.PlayerCache:getRoleLevel()
    local mainView = mgr.ViewMgr:get(ViewName.MainView)
    if mainView then
        mainView:initRoleExpBar(roleExp,roleLv,oldExp,oldLv)
    end
    if exp > 0 then
        local info = {text = conf.RedPointConf:getProName(101),count = exp,color = 1}
        mgr.TipsMgr:addRightTip(info)
    end
end
--检测战场
function PlayerCache:checkZhanChang(redKey,redValue)
    if g_ios_test then   --EVE 屏蔽活动预告小弹窗
        return
    end
    -- local modelId = 0
    -- if k == attConst.A20131 then--问鼎开启
    --     modelId = 1079
    -- elseif k == attConst.A20132 then--皇陵开启
    --     modelId = 1078
    -- elseif k == attConst.A20133 and tonumber(self:getGangId()) > 0 then--仙盟开启
    --     modelId = 1080
    -- elseif k == attConst.A20134 then--世界boss
    --     modelId = 1049
    -- elseif k == attConst.A20142 then--仙魔战
    --     modelId = 1117
    -- elseif k == attConst.A20141 then--全民修炼
    --     modelId = 1116
    -- elseif k == attConst.A20143 then--浪漫姻缘
    --     modelId = 1112
    -- elseif k == attConst.A20146 then--三界争霸
    --     modelId = 1094
    -- end
    if redValue <= 0 then
        return
    end



    local confData = conf.ActivityShowConf:getactData()
    local modelId = 0
    local roleLv = cache.PlayerCache:getRoleLevel()
    for k,v in pairs(confData) do
        if v.red_point_tips == redKey then
            if v.module_id == 1139 then
                if tonumber(self:getGangId()) > 0 then
                    if roleLv >= v.openLv then
                        local isOpen = cache.PlayerCache:getAttribute(v.red_open)
                        if isOpen == 1 then
                            modelId = v.module_id
                            break
                        end
                    end
                end
            else
                if roleLv >= v.openLv then
                    if v.red_open then--仙魔战、三界争霸
                        local isOpen = cache.PlayerCache:getAttribute(v.red_open)
                        if isOpen == 1 then
                            modelId = v.module_id
                            break
                        end
                    elseif v.module_id == 1079 and cache.PlayerCache:getRedPointById(50128)>0 then--九重天特殊处理
                        -- print("九重天",cache.PlayerCache:getRedPointById(50128))
                        local pwsData = conf.SysConf:getModuleById(1169)
                        local data = cache.ActivityCache:get5030111() or {}
                        local openDay = data.openDay or 1
                        local open_forbid_day = conf.QualifierConf:getValue("open_forbid_day")
                        -- print("排位赛",actData.proceed_time[2],nowTime,actData.proceed_time[1],curTime)
                        if roleLv >= pwsData.open_lev and openDay > open_forbid_day then
                            modelId = 0
                        else
                            modelId = v.module_id
                            break
                        end
                    elseif v.module_id == 1169 then
                        if mgr.ModuleMgr:CheckSeeView(1169) then
                            local actData = conf.ActivityShowConf:getActDataById(1169)
                            local curTime = mgr.NetMgr:getServerTime()
                            local nowTime = GGetSecondBySeverTime(curTime)
                            if actData.proceed_time[2]>=nowTime-1 and actData.proceed_time[1]<=nowTime+1 then
                                modelId = v.module_id
                                break
                            else
                                modelId = 0
                            end
                        else
                            modelId = 0
                        end
                    else
                        modelId = v.module_id
                        break
                    end
                end
            end
        end
    end

    if redKey == 50133 then
        --神兽圣域
        if mgr.ModuleMgr:CheckView(1353) then
            modelId = 1353
        end
    end

    if modelId > 0 then
        table.insert(self.zhanChang, modelId)
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view and modelId == 1168 then--魅力温泉
            view.TopActive:checkOpen()
        end
        if view and not mgr.FubenMgr:checkScene() then
            if not mgr.ViewMgr:get(ViewName.ZhanChangTipView) then
                if cache.PlayerCache:getSId() ~= SceneKind.XianmengZhudi then--仙盟圣火
                    mgr.ViewMgr:openView2(ViewName.ZhanChangTipView, self:getZhanChangMod())
                end
            end
        end
    end
end

function PlayerCache:getZhanChangMod()
    return table.remove(self.zhanChang,1)
end

-- id 1 衣服 ，2 武器 3仙羽 4.坐骑 ,5 神兵 ， 6 法宝
--7 仙器 8 伙伴 9 伙伴仙羽 10 伙伴神兵 11 伙伴法宝 12伙伴仙器
-- 11 伙伴仙器 13.称号 14.修仙等级,16.剑神
function PlayerCache:getSkins(id)
    -- body
    if not self.data or not self.data.skins then
        return nil
    end

    if id then
        return self.data.skins[id]
    else
        return self.data.skins
    end
end

function PlayerCache:setSkins(id,var)
    if self.data and self.data.skins then
        self.data.skins[id] = var
    end
end

function PlayerCache:getData()
    return self.data
end

function PlayerCache:getRoleId()
    return self.data.roleId
end

function PlayerCache:getSId()
    return self.data.sceneId
end
function PlayerCache:setSId(id)
    self.data.sceneId = id
end
function PlayerCache:getServerId()
    return self.data.mainSvrId
end
--地图id
function PlayerCache:getMapModelId()
    return self.data.mapModelId
end
function PlayerCache:setMapModelId(id)
    self.data.mapModelId = id
end
--roleicon
function PlayerCache:getRoleIcon()
   return self.data.roleIcon
end
function PlayerCache:setRoleIcon(var)
    -- body
    self.data.roleIcon = var
end
--人物当前经验
function PlayerCache:getRoleExp()
    return self.data.attris and self.data.attris[101] or 0
end
--战斗力
function PlayerCache:getRolePower()
    -- body
    return self.data.attris and self.data.attris[501] or 0
end
function PlayerCache:setOldPower(power)
    self.oldPower = power
end
--旧的战斗力
function PlayerCache:getOldPower()
    return self.oldPower or self:getRolePower()
end
--等级
function PlayerCache:getRoleLevel()
    return  self.data.attris and  self.data.attris[502] or 1
end
--VIP等级
function PlayerCache:getVipLv()
    if g_ios_test then
        return self.data.attris  and self.data.attris[503] or 1   --EVE 屏蔽处理，VIP默认等级修改为1
    end

    return self.data.attris  and self.data.attris[503] or 0
end
--VIP经验
function PlayerCache:getVipExp()
    return self.data.attris  and self.data.attris[508] or 0
end
--VIP星级
function PlayerCache:getVipStars()
    return self.data.attris and self.data.attris[509] or 1
end
--pk模式
function PlayerCache:getPKState()
    return self.data.attris and self.data.attris[511] or PKState.peace
end
function PlayerCache:setPKState(s)
    if self.data.attris then
        self.data.attris[511] = s
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:setMoshiState()
        end
    end
end
--名字
function PlayerCache:getRoleName()
    return self.data.roleName
end
function PlayerCache:setRoleName( var )
    -- body
    self.data.roleName = var
end
--伙伴名字
function PlayerCache:setPetName( var)
    -- body
    self.data.partnerName = var
end
function PlayerCache:getPetName()
    -- body
    return self.data.partnerName
end
function PlayerCache:setPartnerLevel(var)
    -- body
    self.data.partnerLevel = var
end

function PlayerCache:getPartnerLevel()
    -- body
    return self.data.partnerLevel
end

--改变金钱
function PlayerCache:updateMoneyInfo(moneys)
    for k,v in pairs(moneys) do
        self.data.moneys[k] = v
    end
end

--根据类型获取金钱值
function PlayerCache:getTypeMoney(type)
    --策划删除铜钱
    if type == MoneyType.copper then
        return 0
    end

    return (self.data and self.data.moneys) and  self.data.moneys[type] or 0
end
--玩家性别
function PlayerCache:getSex()
    return math.floor(self.data.roleIcon / 100000000)
end
--主角技能信息
function PlayerCache:getSkillInfo()
    return self.data.activeSkillInfos
end
----红点信息
function PlayerCache:setRedpoint(id,var)
    -- body
    if not conf.RedPointConf:getDataById(id) and id ~= 10108 then --id 10108为角色在线时间
        return
    end
    self.redpoint[id] = var or 0
end

function PlayerCache:getRedPointById(id)
    -- body
    return self.redpoint[id] or 0
end

function PlayerCache:getRedPoint()
    -- body
    return self.redpoint
end

--属性
function PlayerCache:getAttribute(id)
    -- body
    if self.data.attris and self.data.attris[id] then
        return self.data.attris[id]
    end

    if self.data.attris64 and self.data.attris64[id] then
        return self.data.attris64[id]
    end
    return 0
end

function PlayerCache:setAttribute(id,var)
    -- body
    if not var then
        plog("属性设置必须传入参数")
        return
    end

    if not self.data.attris then
        self.data.attris = {}
    end
    self.data.attris[id] = var
end

function PlayerCache:updatePosition(x, y)
    if x then
        self.data.pox = x
    end
    if y then
        self.data.poy = y
    end
end

function PlayerCache:getGangId()
    -- body
    return self.data.gangId
end
function PlayerCache:setGangId( var )
    -- body
    self.data.gangId = var
end

function PlayerCache:getGangName()
    -- body
    return self.data.gangName
end

function PlayerCache:setGangName( var )
    -- body
    self.data.gangName = var
end
-----------
function PlayerCache:getGangJob()
    -- body
    return self.data.gangJob
end

function PlayerCache:setGangJob( var )
    -- body
    self.data.gangJob = var
end

function PlayerCache:clearGang()
    -- body
    self:setGangName("")
    self:setGangId(0)
end
--判断是否激活（白银、黄金、钻石）VIP
function PlayerCache:VipIsActivate( vipStage )  --vipStage 1 白银 2 黄金 3 钻石
    -- body 10302 10303 10304
    vipStage = 10301+vipStage
    local stage = self:getAttribute(vipStage)
    -- print("白银仙尊开启状态",stage,vipStage,self.data.attris[vipStage])
    if stage == 1 then
        return true
    else
        return false
    end
end
--时装
function PlayerCache:getFashions()
    return self.data and self.data.fashions or {}
end

function PlayerCache:setFashions(fashions)
     self.data.fashions = fashions
end
--称号
function PlayerCache:getTitles()
    return self.data and self.data.titles or {}
end

function PlayerCache:setTitles(titles)
    self.data.titles = titles
end
--判断有没有好友
function PlayerCache:getIsFriend()
    local friend = self:getAttribute(10307)
    if friend > 0 then
        return true
    end
end
--主界面红包状态缓存
function PlayerCache:setRedBagTag(tag)
    -- body
    self.redBagTag = tag or 0
end
function PlayerCache:getRedBagTag(tag)
    -- body
    return self.redBagTag or 0
end
--临时背包时间
function PlayerCache:setLimitPackTime(time)
    if self.data and self.data.attris then
        if time <= 0 then
            self.data.attris[attConst.limitPack] = nil
        else
            self.data.attris[attConst.limitPack] = time
        end

    end
end

--玩家的登录令牌
function PlayerCache:setLoginSign(sign)
    self.loginSign = sign
end
function PlayerCache:getLoginSign()
    return self.loginSign
end

--记录下载有礼是否有领取过
function PlayerCache:setDownloadGift()
    print("@下载礼包未领取")
    self.downloadGift = true
end
function PlayerCache:getDownloadGift()
    return self.downloadGift
end
--伴侣的名字
function PlayerCache:getCoupleName()
    -- body
    return self.data.coupleName
end

function PlayerCache:setCoupleName(var)
    -- body
    self.data.coupleName = var
end

--婚礼的等级
function PlayerCache:getCoupleGrade()
    -- body
    return self.data.grade
end

function PlayerCache:setCoupleGrade(var)
    -- body
    if var == 0 then
        self.data.grade = var
    elseif var > self.data.grade then--只记录最高等级的呢称
        self.data.grade = var
    end
end
--各成长系统的阶
function PlayerCache:setDataJie(modelId,jie)
    --print("modelId , jie",modelId,jie)
    self.moduleJies[modelId] = jie
end

function PlayerCache:getDataJie(modelId)
    return self.moduleJies[modelId] or 1
end
--缓存获得的外观
function PlayerCache:addSkinsList(list)
    for k,v in pairs(list) do
        local data = {k,v}
        table.insert(self.mSkinsData, data)
    end
end

function PlayerCache:setSkinsList(list)
    self.mSkinsData = list
end


function PlayerCache:getSkinsList()
    return self.mSkinsData or {}
end

function PlayerCache:cleanSkinsList(all)
    if all then
        self.mSkinsData = {}
    else
        table.remove(self.mSkinsData,1)
    end
end
--人物皮肤对应的星数
function PlayerCache:setSkinStarLv(k,v)
    self.skinStarMap[k] = v
end

function PlayerCache:getSkinStarLv(k)
    return self.skinStarMap[k] or 0
end


return PlayerCache