--
-- Author: wx
-- Date: 2017-01-04 14:36:07
--

local PlayerProxy = class("PlayerProxy",base.BaseProxy)

function PlayerProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5010102,self.add5010102)
    self:add(5010103,self.add5010103)
    self:add(5020201,self.add5020201)
    self:add(5020202,self.add5020202)--头像列表
    self:add(5020203,self.add5020203)
    self:add(5020204,self.add5020204)--改名
    self:add(5020205,self.add5020205)--请求人物信息返回
    self:add(5270101,self.add5270101)--请求称号列表
    self:add(5270102,self.add5270102)--请求佩戴称号
    self:add(5270104,self.add5270104)--请求时装列表
    self:add(5270105,self.add5270105)--请求时装佩戴
    self:add(5270106,self.add5270106)--请求时装升星
    self:add(5270107,self.add5270107)--请求称号佩戴数量购买
    self:add(5270201,self.add5270201)--请求成就信息
    self:add(5270202,self.add5270202)--请求成就领取
    self:add(5270203,self.add5270203)--请求成就进阶
    self:add(5020401,self.add5020401)--请求开始打坐
    self:add(5020402,self.add5020402)--请求取消打坐
    self:add(5020403,self.add5020403)--： 请求打坐经验池累加
    self:add(5020411,self.add5020411)--请求开始修炼返回
    self:add(5020412,self.add5020412)--请求双修返回
    self:add(5020413,self.add5020413)--请求修炼经验池返回
    self:add(5020414,self.add5020414)--请求附近单身列表返回
    self:add(5020415,self.add5020415)--请求双修回复返回

    self:add(5020206,self.add5020206)--请求场景人物操作信息
    self:add(5020501,self.add5020501)--请求个性设置
    self:add(5020106,self.add5020106)--请求修改pk模式
    self:add(5020502,self.add5020502)--请求10个成长系统对应的阶数
    self:add(5020503,self.add5020503)--请求10个成长系统对应的技能等级
    self:add(5020504,self.add5020504)--人物皮肤对应的星数
    self:add(5331001,self.add5331001)--请求boss刷新关注

    self:add(8010101,self.add8010101)--错误通知广播
    self:add(8020201,self.add8020201)--更新玩家属性
    self:add(8020202,self.add8020202)--更新外观
    self:add(8020208,self.add8020208)--更新称号广播
    self:add(8030103,self.updateMoneyInfo)--主动广播修改金钱信息
    self:add(8030106,self.add8030106)--获得外观

    self:add(8160101,self.add8160101) --模块开关广播

    self:add(8200101,self.add8200101)--双修邀请广播
    self:add(8200102,self.add8200102)--双修状态广播

    self:add(5570101,self.add5570101)--请求光环列表
    self:add(5570102,self.add5570102)--请求光环佩戴


    self:add(5570201,self.add5570201)--请求头饰列表
    self:add(5570203,self.add5570203)--请求头饰穿脱
    self:add(5570202,self.add5570202)--请求头饰升级


    self:add(5020505,self.add5020505)--请求头像边框
    self:add(5020506,self.add5020506)--请求聊天气泡

    self:add(5270301,self.add5270301)--请求时装藏品信息


end

--请求角色信息
function PlayerProxy:add5010102(data)
    -- printt("请求角色信息###############################################",data)
    -- body
    if data.status == 0 then
        --用于判定是否是同一天。，24 小时刷新问题
        cache.PlayerCache:setonLineTime()
        local day = UPlayerPrefs.GetInt("dayTime")
        if day and day == 0 then
            GClearUPlayerPrefs()
        else
            local temp = os.date("*t",day)
            local temp2 = os.date("*t",cache.PlayerCache:getonLineTime())
            if temp.day ~= temp2.day or temp.month ~=  temp2.month or temp.year ~= temp2.year then
                GClearUPlayerPrefs()
            end
        end
        UPlayerPrefs.SetInt("dayTime",cache.PlayerCache:getonLineTime())

        --缓存
        if data.attris64 and data.attris64[101] then--经验值
            data.attris[101] = data.attris64[101]
        end
        cache.PlayerCache:setData(data)
        --创号登陆 特殊情况 服务器没有推送
        local severTime = mgr.NetMgr:getServerTime()
        cache.VipChargeCache:setOnlineTime(severTime)
        if not data.attris[10108] then
            mgr.SDKMgr:submitData(3002)
        end
        mgr.SDKMgr:submitData(3001)
        --角色数据获取完毕进入主场景
        if mgr.SceneMgr:getCurScene() ~= SceneRes.MAIN_SCENE then
            mgr.SceneMgr:loadScene(SceneRes.MAIN_SCENE)
        end
        --记录上次登录信息
        mgr.HttpMgr:RecordAccSer(data)
        cache.PlayerCache:setReset(true)
        cache.TimerCache:setTimer()
        if gRole then
            --初始化pk模式
            local pkState = data.attris and data.attris[511] or 0
            gRole:changePkState(pkState)
            --初始化buff信息
            mgr.BuffMgr:addThingBuff(cache.PlayerCache:getData())
        end

        mgr.HttpMgr:chargeBack()
    else
        GComErrorMsg(data.status)
    end
end
--请求角色面板信息
function PlayerProxy:add5010103(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            if data.attris64 and data.attris64[101] then--经验值
                data.attris[101] = data.attris64[101]
            end
            view:setPropsData(data)
        end

    else
        GComErrorMsg(data.status)
    end
end
--修改金钱信息
function PlayerProxy:updateMoneyInfo(data)
    if data.status == 0 then
        local isTipStren = false
        local updataItems = {}
        local refreshRed = false
        for k,v in pairs(data.moneyMap) do
            local value = v - cache.PlayerCache:getTypeMoney(k)
            if value > 0 and k ~= MoneyType.copper then
                if k == MoneyType.bindCopper then--绑定铜钱
                    isTipStren = true
                end
                local info = {text = language.money[k],count = value,color = 1}
                mgr.TipsMgr:addRightTip(info)
                if k == MoneyType.gold or k == MoneyType.bindGold then
                    if not mgr.ViewMgr:get(ViewName.ResEffectView) then
                        mgr.ViewMgr:openView2(ViewName.ResEffectView, {})
                    end
                elseif k == MoneyType.lj then
                    refreshRed = true
                elseif k == MoneyType.syjh then
                    refreshRed = true
                    cache.AwakenCache:setSyScore(data.moneyMap[MoneyType.syjh])
                elseif k == MoneyType.ysjh then
                    refreshRed = true
                    cache.AwakenCache:setBMScore(data.moneyMap[MoneyType.ysjh])
                elseif k == MoneyType.dh1 or
                        k == MoneyType.dh2 or
                        k == MoneyType.dh3 or
                        k == MoneyType.dh4 then
                    refreshRed = true
                    cache. DiHunCache:setScoreByMoneyType(k,data.moneyMap[k])

                 elseif k == MoneyType.sxss then
                    refreshRed = true
                    cache.ShengXiaoCache:updateSxScore(data.moneyMap[k])
                end
            end
        end
        cache.PlayerCache:updateMoneyInfo(data.moneyMap)
        -- mgr.ItemMgr:checkStreng(isTipStren)
        GRefreshMoney()
        if refreshRed then
            mgr.GuiMgr:refreshRedBottom()
            local view = mgr.ViewMgr:get(ViewName.AwakenView)
            if view then
                view:refreshRed()
            end

            local view1 = mgr.ViewMgr:get(ViewName.KageeViewNew)
            if view1 then
                view1:flush()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--潜力点修改 ，洗髓 或者点击加减
function PlayerProxy:add5020201( data )
    -- body
    if data.status == 0 then
         local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:add5020201(data)
        end

        --

        cache.PlayerCache:setAttribute(attConst.A504,data.pot)
        mgr.GuiMgr:updateRedPointPanels(attConst.A504)
        mgr.GuiMgr:refreshRedBottom()

    else
        GComErrorMsg(data.status)
    end
end
--头像列表
function PlayerProxy:add5020202(data)
    -- body
    if data.status == 0 then
        --保存数据
        --printt(data)
        cache.PlayerCache:setHeadData(data)
        --自定义头像：屏蔽选系统头像的弹窗2018/06/25 bxp
        -- local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        -- if view then
        --     view:add5020202(data)
        -- end
    else
        GComErrorMsg(data.status)
    end
end
--头像修改
function PlayerProxy:add5020203(data)
    -- body
    if data.status == 0 then

        local roleIcon =  math.floor(cache.PlayerCache:getRoleIcon()/100)*100+data.headImgId

        cache.PlayerCache:setRoleIcon(roleIcon)

        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:setRoleIcon(data)
        end
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:updateRoleInfo()
        end
        local view = mgr.ViewMgr:get(ViewName.HeadChooseView)
        if view then
            view:closeView()
        end
        GComAlter(language.juese29)
    else
        GComErrorMsg(data.status)
    end
end
--更新玩家属性
function PlayerProxy:add8020201( data )
    if data.status == 0 then
        --TODO yr备注：这个判断有效果？cache.PlayerCache:getData()非nil的呀
        -- 现在牵扯太多都不好修改了。都不知会不会引发其他问题。
        if cache.PlayerCache:getData() then--只有返回了属性之后
            if data.attris then
                if data.attris64 and data.attris64[101] then
                    -- print(">>>>>>>>>>>>>>经验值",data.attris64[101],data.attris[101])
                    data.attris[101] = data.attris64[101]
                end
                cache.PlayerCache:updataAttris(data.attris,true)
            elseif data.attris64 then
                cache.PlayerCache:setAttribute64(data.attris64,true)
            end
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view:updateRoleInfo()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function PlayerProxy:updateSkins(player,skinMap)
    -- body
    --武器
    if skinMap[Skins.wuqi] then
        player:setSkins(nil, skinMap[Skins.wuqi], nil)
    end
    local view = mgr.ViewMgr:get(ViewName.MainView)    --EVE
    --坐骑
    if skinMap[Skins.zuoqi] and skinMap[Skins.zuoqi] ~= 0 then
        if not player:isMount() then
            local confdata = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
            if confdata.kind ~= SceneKind.mainCity  and confdata.kind ~= SceneKind.field and  confdata.kind ~= SceneKind.xinshou then

            else
                player:handlerMount(ResPath.mountRes(skinMap[Skins.zuoqi]))
            end
        else
            --马的皮肤改变
            player:sitMount()
        end
    end
    --仙羽
    if skinMap[Skins.xianyu] then
        local roleId = player.data and player.data.roleId or 0
        if roleId ~= cache.PlayerCache:getRoleId() then
            if not mgr.QualityMgr:getAllWing() and not mgr.QualityMgr:getAllPlayer() then
                player:setSkins(nil,nil,skinMap[Skins.xianyu])
            end
        else
            player:setSkins(nil,nil,skinMap[Skins.xianyu])
        end
    end
    --神兵
    if skinMap[Skins.shenbing] and skinMap[Skins.shenbing]~=0 then
        player:updateWeaponEct(skinMap[Skins.shenbing])
    end
    --法宝
    if skinMap[Skins.fabao] and skinMap[Skins.fabao]~=0 then
        player:addFaBao(skinMap[Skins.fabao])
    end
    --仙器
    if skinMap[Skins.xianqi] and skinMap[Skins.xianqi]~= 0 then
        player:addXianQi(skinMap[Skins.xianqi])
    end
    --麒麟臂
    if skinMap[Skins.qilinbi] and skinMap[Skins.qilinbi]~= 0 then
        player:addBodyEct(skinMap[Skins.qilinbi])
    end
    --伙伴
    if skinMap[Skins.huoban] and skinMap[Skins.huoban]~= 0 then
        player:addRolePet()
    end
    --伙伴仙羽
    if skinMap[Skins.huobanxianyu] and skinMap[Skins.huobanxianyu]~= 0 then
        player:addPetXianyu(skinMap[Skins.huobanxianyu])
    end
    --伙伴神兵
    if skinMap[Skins.huobanshenbing] and skinMap[Skins.huobanshenbing]~= 0 then
        player:addPetShenbing(skinMap[Skins.huobanshenbing])
    end
    --伙伴法宝
    if skinMap[Skins.huobanfabao] and skinMap[Skins.huobanfabao]~= 0 then
        player:addPetFabao(skinMap[Skins.huobanfabao])
    end
    --伙伴仙器
    if skinMap[Skins.huobanxianqi] and skinMap[Skins.huobanxianqi]~= 0 then
        player:addPetXiqian(skinMap[Skins.huobanxianqi])
    end
    --宠物
    if skinMap[Skins.newpet] and skinMap[Skins.newpet]~= 0 then
        player:addNetPet(skinMap[Skins.newpet])
    end
    --仙童
    if skinMap[Skins.xiantong] and skinMap[Skins.xiantong]~= 0 then
        player:addXiantong(skinMap[Skins.newpet])
    end
    -- --称号
    -- if skinMap[Skins.title] then
    --     player:setChenghao(skinMap[Skins.title])
    -- end
    --光环
    if skinMap[Skins.halo] then
        player:addHaloEct(skinMap[Skins.halo])
    end
    --时装
    if skinMap[Skins.clothes] then
        player:setSkins(skinMap[Skins.clothes])

        --特殊场景
        if mgr.FubenMgr:isMeiliBeach(cache.PlayerCache:getSId()) then
            local view = mgr.ViewMgr:get(ViewName.BeachMainView)
            if view then
                view:resetPlayer(player)
            end
        end
    end
    --活跃称号
    if skinMap[Skins.activeTitle] then
        player:setActiveTitle(skinMap[Skins.activeTitle])
    end
    --头饰
    if skinMap[Skins.headwear] then
        player:addHeadEct(skinMap[Skins.headwear])
    end
     --面具
    if skinMap[Skins.mianju] then
        player:addMianJuEct(skinMap[Skins.mianju])
    end

    -- 奇兵
    if skinMap[Skins.qibing] then
        player:addQiBingEct(skinMap[Skins.qibing])
    end
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isWenDing(sId) then--问鼎战
        player:setWenDing()
    end
    if mgr.FubenMgr:isXianMoWar(sId) then--仙魔战
        player:setXianMo()
    end
end

--更新外观
function PlayerProxy:add8020202(data)
    if data.status == 0 then
        local skinMap = data.skinMap
        local function deleteSome(param)
            -- body
            -- for k ,v in pairs(param) do
            --     if v == skinMap[k] then
            --         skinMap[k] = nil
            --     end
            -- end
        end

        if  data.roleId == cache.PlayerCache:getRoleId()  then--自己
            deleteSome(cache.PlayerCache:getSkins())
            for k ,v in pairs(skinMap) do
                if v then
                    cache.PlayerCache:setSkins(k,v)
                end
            end
            if gRole then
                self:updateSkins(gRole,skinMap)
                if skinMap[Skins.huoban] and skinMap[Skins.huoban]~= 0 then
                    -- --刷新伙伴列表
                    proxy.HuobanProxy:send(1200101)
                end
            end
        else
            local player = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
            if player then
                local pdata = player:getData()
                deleteSome(pdata.skins)
                for k, v in pairs(skinMap) do
                    if v then
                        pdata.skins[k] = v
                    end
                end
                self:updateSkins(player,skinMap)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--获得外观
function PlayerProxy:add8030106(data)
    if data.status == 0 then
        local list = {}
        printt("data.skinMap>>>>>>>",data.skinMap)
        for key,v in pairs(data.skinMap) do
            local confData = nil
            local skinId = v
            if key == Skins.clothes or key == Skins.wuqi then--时装
                confData = conf.RoleConf:getFashData(skinId)
            elseif key == Skins.huoban then--伙伴
                confData = conf.HuobanConf:getSkinsData(skinId)
            elseif key == Skins.title then--称号
                if tonumber(skinId) == 1001011 then
                    return
                end
                confData = conf.RoleConf:getTitleData(skinId)
            elseif key == Skins.zuoqi then--特殊坐骑
                --print(k,v,"########")
                confData = conf.ZuoQiConf:getSkinsByIndex(skinId,0)
            elseif key == Skins.shenbing then--特殊神兵
                confData = conf.ZuoQiConf:getSkinsByIndex(skinId,1)
            elseif key == Skins.fabao then--特殊法宝
                confData = conf.ZuoQiConf:getSkinsByIndex(skinId,2)
            elseif key == Skins.xianyu then--特殊仙羽
                confData = conf.ZuoQiConf:getSkinsByIndex(skinId,3)
            elseif key == Skins.xianqi then--特殊仙器
                confData = conf.ZuoQiConf:getSkinsByIndex(skinId,4)
            elseif key == Skins.huobanxianyu then--特殊伙伴仙羽
                confData = conf.HuobanConf:getSkinsByIndex(skinId,1)
            elseif key == Skins.huobanshenbing then--特殊伙伴神兵
                confData = conf.HuobanConf:getSkinsByIndex(skinId,2)
            elseif key == Skins.huobanfabao then--特殊伙伴法宝
                confData = conf.HuobanConf:getSkinsByIndex(skinId,3)
            elseif key == Skins.huobanxianqi then--特殊伙伴仙器
                confData = conf.HuobanConf:getSkinsByIndex(skinId,4)
            elseif key == Skins.newpet then --宠物系统皮肤
                confData = conf.PetConf:getPetItem(skinId)
            end
            local autoDress = confData and confData.auto_dress
            if not autoDress then--自动穿戴的不提示
                list[key] = v
            end
        end
        if mgr.FubenMgr:checkScene() then
            cache.FubenCache:setObtainSkins(list)
        else
            cache.PlayerCache:addSkinsList(list)
            if mgr.ViewMgr:get(ViewName.MainView) and not g_ios_test then   --EVE ios版属 屏蔽皮肤获得小弹窗
                mgr.ViewMgr:openView2(ViewName.SkinTipsView,{})
            else
                cache.FubenCache:setObtainSkins(list)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--改名
function PlayerProxy:add5020204(data)
    -- body
    if data.status == 0 then
        if data.reqType == 0 then --请求信息
            local view = mgr.ViewMgr:get(ViewName.JueSeName)
            if view then
                view:add5020204(data)
            end
        elseif data.reqType == 3 then
            --帮派改名
            cache.PlayerCache:setGangName(data.name)

            if gRole then
                gRole:setGangName(data.name)
            end

            local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
            if view then
                view:addMsgCallBack(data)
            end
        else
            cache.PlayerCache:setRoleName(data.name)
            local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
            if view then
                view:add5020204()
            end
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view:updateRoleInfo()
            end
            if gRole then
                gRole:setTitleName(data.name)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求人物信息返回
function PlayerProxy:add5020205( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RankMainView)
        if view then
            view.RankInfoPanel:setTopOneInfo(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--称号列表
function PlayerProxy:add5270101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateTitleList(data)
        end

        local titles = {}
        for k,v in pairs(data.titleInfos) do
            if v then
                local confData = conf.RoleConf:getTitleData(v.titleId)
                if confData and confData.time > 0 then
                    titles[v.titleId] = v.gotTime
                end
            end
        end
        cache.PlayerCache:setTitles(titles)
    else
        GComErrorMsg(data.status)
    end
end
--请求佩戴称号（1:穿戴 2:脱下）
function PlayerProxy:add5270102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateTitleData(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.VipExperienceView)
        if view2 then
            view2:setBtnState()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求称号佩戴数量购买
function PlayerProxy:add5270107(data)

    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateNumData(data)
        end

    else
        GComErrorMsg(data.status)
    end
end
--请求时装列表
function PlayerProxy:add5270104(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateFashList(data)
        end

        local fashions = {}
        for k,v in pairs(data.fashionInfos) do
            if v then
                local confData = conf.RoleConf:getFashData(v.fashionId)
                if confData and confData.time > 0 then
                    fashions[v.fashionId] = v.gotTime
                end
            end
        end
        cache.PlayerCache:setFashions(fashions)
    else
        GComErrorMsg(data.status)
    end
end
--请求时装穿戴
function PlayerProxy:add5270105(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateFashData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求时装升星
function PlayerProxy:add5270106(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FashionStarView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求光环列表
function PlayerProxy:add5570101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateAureoleData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求光环穿戴
function PlayerProxy:add5570102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateHaloData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求头饰列表
function PlayerProxy:add5570201(data)

    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateHeadWearListData(data)
        end

    else
        GComErrorMsg(data.status)
    end
end
--请求头饰升级
function PlayerProxy:add5570202(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
             view:updateHeadWearLevelData(data)
        end

    else
        GComErrorMsg(data.status)
    end
end
--请求头饰穿戴
function PlayerProxy:add5570203(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateHeadWearData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求头像边框
function PlayerProxy:add5020505(data)
    if data.status == 0 then
        -- printt("请求头像边框返回>>>>>>>>>>>>>",data)
        cache.PlayerCache:setRoleIcon(data.roleIcon)
        local view = mgr.ViewMgr:get(ViewName.HeadChooseView)
        if view then
            view:setHeadFrameData(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view2 then
            view2:refreshFrame()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求聊天气泡
function PlayerProxy:add5020506(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HeadChooseView)
        if view then
            view:setBubbleData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求时装藏品信息
function PlayerProxy:add5270301(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateCollectionInfo(data)
            if data.reqType == 1 then--激活刷新红点
                local var = cache.PlayerCache:getRedPointById(attConst.A10267)
                cache.PlayerCache:setRedpoint(attConst.A10267, var-1)
                view:updateCollectionRed()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--更新称号广播
function PlayerProxy:add8020208(data)
    printt("更新称号广播~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",data)
    if data.status == 0 then
        if  data.roleId == cache.PlayerCache:getRoleId()  then--自己
            cache.PlayerCache:setChenghao(data.wearTitle)
            if gRole then
                gRole:setChenghao(data.wearTitle)
            end
        else
            local player = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
            if player then
                player:setChenghao(data.wearTitle)
            end
        end
        --称号
        -- if  data.roleId == cache.PlayerCache:getRoleId()  then--自己
        --     for k ,v in pairs(skinMap) do
        --         if v then
        --             cache.PlayerCache:setSkins(k,v)
        --         end
        --     end
        --     if gRole then
        --         self:updateSkins(gRole,skinMap)
        --         if skinMap[Skins.huoban] and skinMap[Skins.huoban]~= 0 then
        --             -- --刷新伙伴列表
        --             proxy.HuobanProxy:send(1200101)
        --         end
        --     end
        -- else
        --     local player = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
        --     if player then
        --         local pdata = player:getData()
        --         deleteSome(pdata.skins)
        --         for k, v in pairs(skinMap) do
        --             if v then
        --                 pdata.skins[k] = v
        --             end
        --         end
        --         self:updateSkins(player,skinMap)
        --     end
        -- end

        -- player:setChenghao(skinMap[Skins.title])
    else
        GComErrorMsg(data.status)
    end
end


--请求成就信息返回
function PlayerProxy:add5270201( data )
    if data.status == 0 then
        -- print("成就请求")
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updataAchieveData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求成就领取返回
function PlayerProxy:add5270202( data )
    if data.status == 0 then
        -- print("成就领取请求")
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view and view.AchievementPanel then
            view.AchievementPanel:updataAchieveAtt(data)
        end
        --获得奖励
        -- for k,v in pairs(data.items) do
        --     -- print("奖励道具id",v.mid,v.amount)
        --     local itemData = {mid = v.mid,amount = v.amount,index = Pack.pack}
        --     mgr.ItemMgr:addItem(itemData)
        -- end
    else
        GComErrorMsg(data.status)
    end
end

--请求成就进阶返回
function PlayerProxy:add5270203( data )
    if data.status == 0 then
        -- print("成就进阶请求")
        -- mgr.GuiMgr:redpointByID(10203)
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view.AchievementPanel:advanceRefresh(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function PlayerProxy:add8010101(data)
    if data.errorId == 2208008 or data.status == 2208009 then --未采集成功
        local sId = cache.PlayerCache:getSId()
        if sId == HuangLingScene then--皇陵采集中断后继续
            local taskList = cache.HuanglingCache:getTaskCache()
            for k,v in pairs(taskList) do
                local presentTaskId = cache.HuanglingCache:getPresentTaskId()
                if v.taskFlag ~= 1 and v.taskId == presentTaskId then
                -- print("剩下的未完成任务id",v.taskId)
                    local taskData = conf.HuanglingConf:getTaskAwardsById(v.taskId)
                    mgr.HookMgr:HuanglingTaskHook(taskData)
                    break
                end
            end
        else
            GComErrorMsg(data.errorId)
        end
    else
        GComErrorMsg(data.errorId)
        if data.errorDes and data.errorDes ~= "" then
            GComAlter(data.errorDes)
        end
    end
end

function PlayerProxy:add5020401(data)
    if data.status == 0 then
        --开始打坐
        --清理掉默默认打坐时间

        local view = mgr.ViewMgr:get(ViewName.SitDownView)
        if view then
            view:add5020401(data)
        else
            mgr.ViewMgr:openView(ViewName.SitDownView,function(view)
                -- body
                view:add5020401(data)
            end)
        end
    else
        GComErrorMsg(data.status)
    end
end

function PlayerProxy:add5020402( data )
    -- body
    if data.status == 0 then
        --取消打坐
        -- if gRole then
        --     gRole:cancelSit()
        -- end
    else
        if data.status ~= -1 then
            GComErrorMsg(data.status)
        end
    end
end

function PlayerProxy:add5020403( data )
    -- body
    if data.status == 0 then
        -- 请求打坐经验池累加
        local view = mgr.ViewMgr:get(ViewName.SitDownView)
        if view then
            view:add5020403(data)
        end
    else
        if data.status ~= -1 then
            GComErrorMsg(data.status)
        end
    end
end

--请求开始修炼
function PlayerProxy:add5020411( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DoubleMajorView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求双修
function PlayerProxy:add5020412( data )
    -- body
    if data.status == 0 then
        if data.match then
            local view = mgr.ViewMgr:get(ViewName.MajorSelectView)
            if view then
                view:setAutoMatch(data.match)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求修炼经验池
function PlayerProxy:add5020413( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DoubleMajorView)
        if view then
            view:add5020413(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求附近单身列表
function PlayerProxy:add5020414( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MajorSelectView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求双修回复
function PlayerProxy:add5020415( data )
    if data.status == 0 then
        -- mgr.SceneMgr:changeMap2(sId, data.pox+100, data.poy)
        -- print("坐标点",data.pox,data.reqType)
        if data.reqType == 1 then
            local view = mgr.ViewMgr:get(ViewName.MajorSelectView)
            if view then
                view:onClickClose()
            end
            local view2 = mgr.ViewMgr:get(ViewName.DoubleMajorView)
            if view2 then
                view2:setMajorBtnState(1)
            end
        else
            local view2 = mgr.ViewMgr:get(ViewName.DoubleMajorView)
            if view2 then
                view2:setMajorBtnState(0)
            end
        end
        -- gRole:setMajorState(2)
    else
        GComErrorMsg(data.status)
    end
end

--双修请求广播返回
function PlayerProxy:add8200101( data )
    if data.status == 0 then
        if data.type == 1 then--被邀请的人弹框确认
            local param = {}
            param.type = 2
            param.sure = function()
                self:send(1020415,{reqType = 1,roleId = data.reqRoleId})
            end
            param.closefun = function()
                self:send(1020415,{reqType = 2,roleId = data.reqRoleId})
            end
            param.cancel = function()
                self:send(1020415,{reqType = 2,roleId = data.reqRoleId})
            end
            local textData = {
                                {text = data.reqRoleName,color = 7},
                                {text = language.dazuo12,color = 6},
                            }
            param.richtext = mgr.TextMgr:getTextByTable(textData)
            GComAlter(param)
        elseif data.type == 2 then--自动匹配
            local roleId = cache.PlayerCache:getRoleId()
            -- print("自动匹配",data.reqRoleId,roleId)
            if roleId == data.reqRoleId then
                -- gRole:setMajorState(1)
                local sId = cache.PlayerCache:getSId()
                proxy.ThingProxy:send(1020101, {sceneId=sId, pox=data.pox-100, poy=data.poy, type=5})
                local view = mgr.ViewMgr:get(ViewName.DoubleMajorView)
                if view then
                    view:setMajorBtnState(1)
                end
            else
                local view = mgr.ViewMgr:get(ViewName.DoubleMajorView)
                if view then
                    view:setMajorBtnState(1)
                end
            end
            GComAlter(language.dazuo13)
            local view = mgr.ViewMgr:get(ViewName.MajorSelectView)
            if view then
                view:onClickClose()
            end
        elseif data.type == 3 then--邀请方收到通知
            -- gRole:setMajorState(1)
            local sId = cache.PlayerCache:getSId()
                -- print("坐标点",data.pox,data.poy)
            proxy.ThingProxy:send(1020101, {sceneId=sId, pox=data.pox-100, poy=data.poy, type=5})
            local view = mgr.ViewMgr:get(ViewName.DoubleMajorView)
            if view then
                view:setMajorBtnState(1)
            end
            GComAlter(language.dazuo13)
            local view = mgr.ViewMgr:get(ViewName.MajorSelectView)
            if view then
                view:onClickClose()
            end
        elseif data.type == 4 then
            --print("停止玩家列表",#data.roleList)
            --printt(data.roleList)
            local roleId = cache.PlayerCache:getRoleId()
            for k,v in pairs(data.roleList) do
                if roleId == v then
                    local view = mgr.ViewMgr:get(ViewName.DoubleMajorView)
                    if view then
                        view:setMajorBtnState(0)
                        gRole:cancelSit()
                        gRole:setMajorState(0)
                    end
                else
                    local p = mgr.ThingMgr:getObj(ThingType.player, v)
                    if p then
                        p:cancelSit()
                        p:setMajorState(0)
                    end
                end
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--双修状态广播
function PlayerProxy:add8200102( data )
    if data.status == 0 then
        local roleId = cache.PlayerCache:getRoleId()
        if roleId == data.roleId then
            -- print("role",data.practice,data.roleId,roleId)
            gRole:setMajorState(data.practice)
        else
            local p = mgr.ThingMgr:getObj(ThingType.player, data.roleId)
            -- print("player",data.practice,data.roleId,p)
            if p then
                p:setMajorState(data.practice)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求场景人物操作信息
function PlayerProxy:add5020206( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FriendTips)
        if view then
            view:add5020206(data)
            view:gangItem(data)   -- EVE 目的：为了显示玩家的仙盟归属
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求个性设置
function PlayerProxy:add5020501(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SiteView)
        if view then
            view:setKidneyData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function PlayerProxy:add5020106(data)
    -- body
    if data.status == 0 then
        if cache.PlayerCache:getPKState() ~= PKState.team then
            --停止最反击
            -- mgr.FightMgr:fightByTarget()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求10个成长系统对应的阶数
function PlayerProxy:add5020502(data)
    if data.status == 0 then
        for k,v in pairs(data.modules) do
            cache.PlayerCache:setDataJie(k,v)
        end
    else
        GComErrorMsg(data.status)
    end
end

function PlayerProxy:add5020503(data)
    -- body
    if data.status == 0 then
        cache.PlayerCache:setDataSkill(data)
    else
        GComErrorMsg(data.status)
    end
end
--人物皮肤对应的星数
function PlayerProxy:add5020504(data)
    printt(data)
    if data.status == 0 then
        for k,v in pairs(data.map) do
            cache.PlayerCache:setSkinStarLv(k,v)
        end
    else
        GComErrorMsg(data.status)
    end
end

--模块开关广播
function PlayerProxy:add8160101(data)
    if data.status == 0 then
        -- print("模块开关广播")
        cache.PlayerCache:setModuleList(data.moduleLists)
    else
        GComErrorMsg(data.status)
    end
end

function PlayerProxy:add5331001( data )
    -- body
     if data.status == 0 then
        -- print("模块开关广播")
        local view = mgr.ViewMgr:get(ViewName.SiteView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return PlayerProxy