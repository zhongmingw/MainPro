 --
-- Author:
-- Date: 2017-04-12 15:51:59
--

local ModuleMgr = class("ModuleMgr")

local opent = {
    ["n404"] = 1064,--商城
    ["n402"] = 1029,--锻造
    ["n409"] = 1062,--剑神
    ["n407"] = 1001,--坐骑
    ["n406"] = 1006,--伙伴
    ["n408"] = 1013,--帮派
    --["n405"] = 1065,--好友
    --["n410"] = 1066,--拍卖
    ["n502"] = 1067,--活跃
    ["n403"] = 1068,--技能
    ["n301"] = 1070,--影卫
    ["n401"] = 1069,--角色
    ["marrygn"] = 1098,--结婚
    ["home"] = 1137,--家园
    ["pet"] = 1188,--宠物
    ["rune"] = 1213,--符文
    ["shenqi"] = 1238,--神器
}

function ModuleMgr:getBtnName(id)
    -- body
    for k ,v in pairs(opent) do
        if v == id then
            return k
        end
    end
end

function ModuleMgr:isInopent(name)
    -- body
    return opent[tostring(name)]
end

function ModuleMgr:ctor()
    self.olddata = {} --跳转前的界面
end

function ModuleMgr:setoldData(param)
    -- body
    self.olddata = param or {}
end

function ModuleMgr:backView()
    -- body
    if self.olddata and self.olddata.param then
        self:OpenView(self.olddata.param)
    end
end
--检测出现等级
function ModuleMgr:CheckSeeView(param)
    -- body
    if not param then
        return false
    end
    local id
    if  type(param) == "number" or type(param) == "String"  then --功能ID
        id = checkint(param)
    else
        id = checkint(param.id)
    end

    local confData = conf.SysConf:getModuleById(id)
    if not confData then
        print("没有模块配置")
        return false
    end
    local data = cache.ActivityCache:get5030111() or {}
    local openDay = data.openDay or 1
    local open_forbid_day = conf.QualifierConf:getValue("open_forbid_day")
    if id == 1169 or id == 1224 or id == 1266 then--跨服排位开服n天后开启
        -- print("排位赛开启",openDay,open_forbid_day)
        if id == 1224 then
            open_forbid_day = conf.CityWarConf:getValue("open_forbid_day")
        elseif id == 1266 then
            open_forbid_day = conf.FubenConf:getBossValue("open_forbid_day")
        end
        if openDay > open_forbid_day then
            if not confData.seelv and not confData.seetask then
                --没有出现等级限制
                return true
            end
            if confData.seelv then
                if cache.PlayerCache:getRoleLevel() >= confData.seelv then
                    return true
                else
                    return false
                end
            elseif confData.seetask then
                --print(cache.TaskCache:isfinish(confData.seetask),confData.seetask)
                return cache.TaskCache:isfinish(confData.seetask)
            end
            return true
        else
            return false
        end
    elseif id >= 1213 and id <= 1217 then--寻宝
        local openday = confData.openday or 0
        if openDay < openday then
            return false
        end
    end
    if not confData.seelv and not confData.seetask then
        --没有出现等级限制
        return true
    end
    if confData.seelv then
        if cache.PlayerCache:getRoleLevel() >= confData.seelv then
            return true
        else
            return false
        end
    elseif confData.seetask then
        --print(cache.TaskCache:isfinish(confData.seetask),confData.seetask)
        return cache.TaskCache:isfinish(confData.seetask)
    end
    return true
end

function ModuleMgr:CheckView( param )
    -- body
    if not param then
        return false
    end
    local return_flag = false
    local id
    local falg
    --local falg = false
    if  type(param) == "number" or type(param) == "String"  then --功能ID
        id = checkint(param)
    else
        id = checkint(param.id)
        falg = param.falg
    end

    local confData = conf.SysConf:getModuleById(id)
    --开启任务限制
    if confData and confData.openTask then
        --plog("confData.openTask",confData.openTask)
        if type(param) == "table" and param.taskId then
            if confData.openTask == param.taskId then
                return_flag = true
            end
        else
            local data=cache.TaskCache:getData()--任务信息
            if data and #data > 0 then
                if confData.openTask < data[1].taskId then
                    return_flag = true
                end
            else
                return_flag = true
            end
        end

        -- if not return_flag and falg then
        --     GComAlter(language.gonggong50)
        -- end
    elseif confData and confData.openday then
        --开服天数限制
        local data = cache.ActivityCache:get5030111()
        --print("confData.openday",confData.openday)
        if not data then
            return_flag = false
        else
            if confData.openday <= data.openDay then
                if confData.open_lev then
                    if confData.open_lev <= cache.PlayerCache:getRoleLevel() then
                        return_flag = true
                    else
                        return_flag = false
                    end
                else
                    return_flag = true
                end

            else
                return_flag = false
            end
        end
        --print("需要开服天数，等级条件",return_flag)
    else
        --开启等级限制
        if confData and confData.open_lev then
            if cache.PlayerCache:getRoleLevel() < confData.open_lev then
                return_flag =  false
                -- plog("开启等级限制",confData.open_lev)
            else
                return_flag =  true
            end
        else --表示读取不到配置
            return_flag =  true
        end

    end
    --提示开启等级
    if not return_flag and falg then
        if type(param) == "table" and param.tips then --优先提示传入的提示
            GComAlter(param.tips)
        elseif confData and confData.tips and confData.tips~="" then --特别提示
            GComAlter(confData.tips)
        elseif confData and confData.open_lev then --开放等级提示
            GComAlter( string.format(language.gonggong07,confData.open_lev))
        elseif confData and confData.openTask then --开放等级提示
            GComAlter(language.gonggong50)
        else --等级不足
            GComAlter(language.gonggong06)
        end
    end
    return return_flag
end
--[[id = 模块id，childIndex = 模块下某个子标签,data = 拓展传递的数据]]
function ModuleMgr:OpenView(param)
    -- body
    if not param then
        return
    end
    local data = { id = param.id , falg = true }
    if not GCheckView(data) then
        return
    end
    --如果模块未开放
    local moduleList = cache.PlayerCache:getModuleList()
    local flag = false
    for k,v in pairs(moduleList) do
        if param.id == v then
            flag = true
            break
        end
    end
    if flag then
        local confData = conf.SysConf:getModuleById(param.id)
        local str = confData.name .. language.gonggong73
        GComAlter(str)
        return
    end
    --成就id列表清空
    local view = mgr.ViewMgr:get(ViewName.AchieveGetItem)
    if view then
        view:refreshIdList()
    end
    --渡劫界面关闭发送拒绝请求
    local view = mgr.ViewMgr:get(ViewName.DujieView)
    -- print("关闭渡劫界面",view)
    if view then
        view:onCloseView()
    end
    --关闭其他界面
    mgr.ViewMgr:closeAllView2(param.viewopen)
    --如果打开的不是目标界面 清理信息
    if self.olddata then
        if self.olddata.tarindex and self.olddata.tarindex~= param.id then
            self.olddata = {}
        end
    end
     -- print(debug.traceback())
    print("跳转模块id>>>>>>>>>>>>>>>",param.id)
    if param.id == 1001
        or  param.id == 1002
        or  param.id == 1003
        or  param.id == 1004
        or  param.id == 1005
        or  param.id == 1287
        or  param.id == 1438 then
        --坐骑
        -- if true then
        --     mgr.ViewMgr:openView2(ViewName.KuaFuMainView, {index = 2})
        --     return
        -- end

        local t = {
            [1001] = 0,[1002] = 3,[1003] = 1,[1004] = 4,[1005] = 2,[1287] = 5, [1438] = 6
        }
        mgr.ViewMgr:openView(ViewName.ZuoQiMain,function(view)
            -- body
            view:setData()
        end, {index = t[param.id],childIndex = param.childIndex,grandson = param.grandson,suitId = param.suitId})--,suitId加上时装升星跳转模块bxp

    elseif param.id == 1011 then
         --聊天
        mgr.ViewMgr:openView(ViewName.ChatView,nil, {index = param.index,roleData = param.roleData})
    elseif param.id == 1006 or  param.id == 1007 or  param.id == 1008 or  param.id == 1009 or  param.id == 1010 then
        --伙伴
        local t = {
            [1006] = 0,[1007] = 1,[1008] = 2,[1009] = 4,[1010] = 3
        }

        mgr.ViewMgr:openView(ViewName.HuobanView,function(view)
            -- body
            view:setData()
        end,{index = t[param.id],childIndex = param.childIndex,grandson = param.grandson,suitId = param.suitId})--suitId加上时装升星跳转模块bxp
    elseif param.id == 1012 then
        --背包商店
        mgr.ViewMgr:openView(ViewName.PackView, nil,{index=2})
    elseif (param.id >= 1013 and param.id<=1018) or
        param.id == 1127 or
        param.id == 1139 or
        param.id == 3002 or
        param.id == 1140 then --EVE 添加圣火模块1127, 仙盟圣火BOSS可获得3002

        if param.id == 3002 then  --特殊判断，仙盟BOSS这个获得途径跳转同仙盟圣火
            param.id = 1127
        end
        --帮派
        -- local t = language.bangpai186

        if cache.PlayerCache:getGangId().."" ~= "0" then
            local actConf = conf.BangPaiConf:getGangActive(param.id)
            mgr.ViewMgr:openView(ViewName.BangPaiMain,function(view)
                -- body
                proxy.BangPaiProxy:sendMsg(1250104)
                view:setData()
            end,{index = param.id,childIndex = actConf and actConf.sort or 1})
        else
            mgr.ViewMgr:openView(ViewName.BangPaiFind,function(view)
                -- body
                local param = {}
                param.gangName = ""
                param.page = 1
                proxy.BangPaiProxy:sendMsg(1250102, param)
            end)
        end
    elseif param.id >= 1019 and param.id <= 1025
        or param.id >= 1130 and param.id <= 1133
        or param.id == 1218
        or param.id == 1448 then
        --副本
        mgr.ViewMgr:openView(ViewName.FubenView,nil,{index = param.id,childIndex = param.childIndex})
    elseif param.id == 1026 then
        --喇叭
        mgr.ViewMgr:openView(ViewName.ChatHornView)
    elseif param.id == 2001 then --日环任务
        local data=cache.TaskCache:getdailyTasks()--任务信息
        if data[1] and data[1].taskId then
            mgr.TaskMgr:setCurTaskId(data[1].taskId)
            mgr.TaskMgr.mState = 2 --设置任务标识
            mgr.TaskMgr:resumeTask()
        end
    elseif param.id == 2002 then --帮派任务
        local data=cache.TaskCache:getgangTasks()--任务信息
        if data[1] and data[1].taskId then
            mgr.TaskMgr:setCurTaskId(data[1].taskId)
            mgr.TaskMgr.mState = 2 --设置任务标识
            mgr.TaskMgr:resumeTask()
        else
            GOpenView({id = 1013})
        end
    elseif param.id == 2003 then --商会任务
        local data = cache.TaskCache:getshangHuiTasks()--商会任务
        if data[1] and data[1].taskId then
            local confData = conf.TaskConf:getTaskById(data[1].taskId)
            if confData.type == 6 then --商会任务
                local canget = true
                -- for k , v in pairs(confData.conditions) do
                --     local itemData = cache.PackCache:getPackDataById(v[1])
                --     if v[2]>itemData.amount then --不满足
                --         canget = false
                --         break
                --     end
                -- end
                if canget then
                    mgr.ViewMgr:openView2(ViewName.TaskSHView, data[1])
                else
                    GOpenView({id = 1016}) --帮派仓库
                end
            end
            return
        end
    elseif (param.id >= 1029 and param.id <= 1033) or param.id == 1134
        or param.id == 1153 or param.id == 1154 or param.id == 1412 then--鍛造界面
        mgr.ViewMgr:openView2(ViewName.ForgingView,{index = param.id,childIndex = param.childIndex})
    elseif param.id >= 1034 and param.id <= 1041 or param.id == 1136 or param.id == 1074 then--福利大厅
        mgr.ViewMgr:openView(ViewName.WelfareView,nil,{index = language.welfare11[param.id]})
    elseif param.id == 1042 then--vip充值
        if g_ios_test then
            mgr.ViewMgr:openView2(ViewName.VipChargeIOSView)
        else
            local id = param.index or param.childIndex
            if not id then id = 0 end
            mgr.ViewMgr:openView(ViewName.VipChargeView,function(view) --EVE IOS
                proxy.VipChargeProxy:sendRechargeList()
            end,{index = id })--param.id-1042
        end
    elseif param.id >= 1043 and param.id <= 1045 then--元宝商城 绑元商城 荣誉商城
        mgr.ViewMgr:openView(ViewName.ShopMainView,function(view)
        end,{index = param.index or param.id-1042})--1043改1042bxp
    elseif param.id == 1046 then
        --战场
        mgr.ViewMgr:openView(ViewName.ZhanChangMian,function(view)
            -- body
        end,{index = 0})
    elseif (param.id >= 1047 and param.id <= 1049)
    or param.id == 1123 or param.id == 1125 or param.id == 1128
    or param.id == 1135 or param.id == 3001 or param.id == 1151 or
    param.id == 1191 or param.id == 1221 or param.id == 1242 or
    param.id == 1266 or param.id == 1324 or param.id == 1337 or param.id == 1348
    or param.id == 1378 then--boss大厅
        mgr.ViewMgr:openView2(ViewName.BossView,{index = param.id,childIndex = param.childIndex,sceneId = data.sceneId})
    elseif param.id == 1050 then
        --仙尊卡
        -- if not g_ios_test then   --EVE 屏蔽仙尊卡
            mgr.ViewMgr:openView(ViewName.XianzunView,function(view)
                proxy.VipChargeProxy:sendVipPrivilege(0)
            end,{})
        -- end
    elseif param.id == 1028 then
        --开服活动
        if param.childIndex then
            param.index = param.childIndex
        end

        proxy.ActivityProxy:setActiveID(param.index) --设置跳转活动
        if param.index == 1026 or param.index == 1032 then--如果是特惠礼包则挑战到特惠抢购界面
            mgr.ViewMgr:openView2(ViewName.PanicBuyView,{index = param.index})
        else
            mgr.ViewMgr:openView(ViewName.KaiFuMainView,function(view)
                -- body
               -- local view  = mgr.ViewMgr:get(ViewName.KaiFuMainView)
                --设置活动
                view:setData(cache.ActivityCache:get5030111())
                --活动跳转
                local param = {id = proxy.ActivityProxy:getActiveID() }
                view:nextStep(param)
                --清理
                proxy.ActivityProxy:setActiveID()

                --proxy.ActivityProxy:sendMsg(1030111,{actType = 1})
            end)
        end

    elseif param.id == 1052 then
        --旺财
        -- print("请求")
        -- proxy.ActivityProxy:sendMsg(1030116, {reqType = 0,amount = 0,buyId = 0})
        mgr.ViewMgr:openView(ViewName.WangcaiView,function(view)
             proxy.WangcaiProxy:sendMsg(1320101)
        end)
    elseif param.id == 1053 then
        if not g_ios_test then  --EVE 屏蔽在线送首充
        --送首充
        -- if cache.PlayerCache:getAttribute(30104) == 1 then
            mgr.ViewMgr:openView(ViewName.FirstChargeView,function(view)
                proxy.ActivityProxy:sendMsg(1030125)
            end)
        -- else
        -- end
        end
        --离线挂机奖励
    elseif param.id == 1054 then --再充献礼
        if GGetFirstChargeState(1) and GGetFirstChargeState(2) and GGetFirstChargeState(3)
        and GGetFirstChargeState(4) and GGetFirstChargeState(5) and GGetFirstChargeState(6) then
            GComAlter(language.kaifu48)
        else
            mgr.ViewMgr:openView2(ViewName.RechargeAgain, {index = param.index or param.childIndex or 0})
        end
        -- mgr.ViewMgr:openView(ViewName.RechargeAgain,function(view)
        --     proxy.ActivityProxy:sendMsg(1030123,{reqType = 0, awardId = 1})
        -- end,{index = param.index or 0})
    elseif param.id == 1055 then --30天登录
        mgr.ViewMgr:openView(ViewName.LoginAwardView,function(view)
            -- body
            proxy.ActivityProxy:sendMsg(1030106,{reqType=0})
        end)
    elseif param.id == 1056 then --每日首充
        local data = cache.ActivityCache:get5030111()
        if data and data.openDay <= 7 then
            mgr.ViewMgr:openView(ViewName.DayFirstChargeView,function(view)

            end,{index = param.index or param.childIndex or 0})
        else
            mgr.ViewMgr:openView(ViewName.DayFirstChargeOther,function(view)

            end,{index = param.index or param.childIndex or 0})
        end
    elseif param.id == 1057 then --每日1元
        -- print("每日一元红点",cache.PlayerCache:getAttribute(30103))
        if cache.PlayerCache:getAttribute(30103) == 1 then
            mgr.ViewMgr:openView(ViewName.DayOneRmbView,function(view)
                proxy.ActivityProxy:sendMsg(1030124,{reqType = 0})
            end)
        else

        end
    elseif param.id == 1058 then --百倍豪礼
        -- if cache.PlayerCache:getAttribute(30102) == 1 then
            mgr.ViewMgr:openView(ViewName.BaibeiGiftView,function(view)
                local data = cache.ActivityCache:get5030111()
                if data.acts[1027] and data.acts[1027] == 1 then
                    view:sendMsg()
                else
                    GComErrorMsg(2030114)
                    view:closeView()
                end
            end,{index = 0})
        -- else
        --     GComErrorMsg(2030114)
        -- end
    elseif param.id == 1059 then --投资计划
        if param.childIndex then
            param.index = param.childIndex
        end
        --print("跳转id",param.index,param.childIndex)
        if cache.PlayerCache:getRedPointById(30105) and cache.PlayerCache:getRedPointById(30105) ~= 0 then
            mgr.ViewMgr:openView(ViewName.InvestView,function(view)
                -- proxy.ActivityProxy:sendMsg(1030111,{actType = 1})
                local data = cache.ActivityCache:get5030111()
                if data.acts[1029] and data.acts[1029] == 1 then
                    view:onController()
                else
                    view:hideOpenInvest()
                end
            end,{index = param.index or 0})
        else
            GComAlter(language.acthall02)
        end
    elseif param.id == 1060 then --元宝复制
        if cache.PlayerCache:getAttribute(30101) == 1 then
            mgr.ViewMgr:openView(ViewName.IngotCopy,function(view)
            --print("请求元宝复制")
            proxy.ActivityProxy:sendMsg(1030122,{reqType = 0, copyType = 1})
            end)
        else
            GComErrorMsg(2030114)
        end
    elseif param.id == 1061 then
        mgr.ViewMgr:openView2(ViewName.PanicBuyView,{index = 1034})
    elseif param.id == 1062 then
        --剑神
        local playLv = cache.PlayerCache:getRoleLevel()
        local openLv = conf.AwakenConf:getOpenLv()
        if playLv >= openLv then
            mgr.ViewMgr:openView(ViewName.AwakenView,function(view)
                view:setChildIndex(param.childIndex)
            end,{suitId = param.suitId})--bxp升星跳转
        else
            GComAlter(string.format(language.gonggong07, openLv))
        end
    elseif param.id == 1272 then
        mgr.ViewMgr:openView2(ViewName.AwakenView,{index = 3})
    elseif param.id == 1349 then
        mgr.ViewMgr:openView2(ViewName.AwakenView,{index = 4})
    elseif param.id == 1398 then
        mgr.ViewMgr:openView2(ViewName.AwakenView,{index = 6})
    elseif 1063 == param.id then
        --仙尊卡
        -- if not g_ios_test then   --EVE 屏蔽仙尊卡
            mgr.ViewMgr:openView(ViewName.XianzunView,function(view)
                proxy.VipChargeProxy:sendVipPrivilege(0)
            end,{})
        -- end
    elseif 1064 == param.id then
        --商城
        --mgr.ViewMgr:openView2(ViewName.PetMainView)
        mgr.ViewMgr:openView(ViewName.ShopMainView,function(view)
        end,{index = 1})--0改1bxp
    elseif 1220 == param.id then
        --商城
        --mgr.ViewMgr:openView2(ViewName.PetMainView)
        mgr.ViewMgr:openView(ViewName.ShopMainView,function(view)
        end,{index = 0})
    elseif 1065 == param.id then
        --好友
        mgr.ViewMgr:openView2(ViewName.FriendView,{index = 0})
    elseif 1066 == param.id then
        --拍卖
        if G_IsTransactionLimit() then
            GComAlter(language.sell39)
        else
            mgr.ViewMgr:openView(ViewName.MarketMainView,function(view)

            end,{index = 0})
        end
    elseif 1067 == param.id then --修仙
        --
        mgr.ViewMgr:openView(ViewName.JueSeMainView,function(view)
        -- body
        end,{notself = false,index = 7})
    elseif 1068 == param.id then
        mgr.ViewMgr:openView2(ViewName.SkillView, 0)
    elseif 1069 == param.id then
        mgr.ViewMgr:openView(ViewName.JueSeMainView,function(view)
        -- body
        end,{notself = false,index = 1})
    elseif 1325 == param.id then
        mgr.ViewMgr:openView(ViewName.JueSeMainView,function(view)
        -- body
        end,{notself = false,index = 9})
    elseif 1377 == param.id then
        mgr.ViewMgr:openView(ViewName.JueSeMainView,function(view)
        -- body
        end,{notself = false,index = 8,indexId = 1}) --indexId头饰特殊处理道具使用过后跳转到指定标签
    elseif 1070 == param.id
        or 1441 == param.id
        or 1442 == param.id then
        -- proxy.KageeProxy:send(1150101,{reqType = 0,ywId = 0})
        mgr.ViewMgr:openView2(ViewName.KageeViewNew, {moduleId = param.id})
    elseif 1071 == param.id then
        mgr.ViewMgr:openView(ViewName.GrowthView,function(view)
            proxy.GrowthProxy:send_1020301()
        end)
    elseif param.id == 1072 then
        --功勋商城
        mgr.ViewMgr:openView(ViewName.ShopMainView,function(view)
        end,{index = 5})--4改5bxp
    elseif param.id == 1073 then
        mgr.ViewMgr:openView(ViewName.RedBagView,function(view)

        end,{})
    elseif param.id == 1075 then
        --查看玩家信息
        --plog("ViewName.SeeOtherMsg",ViewName.SeeOtherMsg)
        mgr.ViewMgr:openView2(ViewName.SeeOtherMsg,param.data)
    elseif param.id == 1076 then
        mgr.ViewMgr:openView(ViewName.WelfareView,nil,{index = language.welfare11[param.id],childIndex = param.childIndex})
    elseif param.id == 1077 then
        mgr.ViewMgr:openView(ViewName.GrowthView,function(view)
            proxy.GrowthProxy:send_1020301()
        end)
    elseif param.id == 1078 then--皇陵之战
        mgr.ViewMgr:openView(ViewName.ZhanChangMian,function(view)
            -- body
        end,{index = 1})
    elseif param.id == 1079 then--问鼎之战
        mgr.ViewMgr:openView(ViewName.ZhanChangMian,function(view)
            -- body
        end,{index = 2})
    elseif param.id == 1080 then--仙盟战
        mgr.ViewMgr:openView(ViewName.ZhanChangMian,function(view)
            -- body
        end,{index = 3})
    elseif param.id == 1081 then--爬塔商店
        mgr.ViewMgr:openView(ViewName.ShopMainView,function(view)
        end,{index = 4})--3改4bxp
    elseif param.id == 1082 then--主线任务
        GgoToMainTask()
    elseif param.id == 1083 then--日常任务
        GgoToDialyTask()
    elseif param.id == 1084 then--野外挂机
        local sceneData = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
        local kind = sceneData and sceneData.kind
        if kind == SceneKind.field then
            mgr.HookMgr:enterHook()
        end
    elseif param.id == 1085 then--仙盟任务
        local gangId = tonumber(cache.PlayerCache:getGangId())
        if gangId <= 0 then
            GComAlter(language.chatGuild)
        else
            GgoToGangTask()
        end
    elseif param.id == 1086 then--商会任务
        local data = cache.TaskCache:getshangHuiTasks()--商会任务
        if data[1] and data[1].taskId then
            local confData = conf.TaskConf:getTaskById(data[1].taskId)
            if confData.type == 6 then --商会任务
                local canget = true
                if canget then
                    mgr.ViewMgr:openView2(ViewName.TaskSHView, data[1])
                else
                    local gangId = tonumber(cache.PlayerCache:getGangId())
                    if gangId <= 0 then
                        GComAlter(language.chatGuild)
                    else
                        GOpenView({id = 1016}) --帮派仓库
                    end
                end
            end
        end
    elseif param.id == 1087 then--打坐
        if gRole then gRole:sendsit() end
    elseif param.id == 1088 then--吞噬装备
        -- local t = {
        --     [1006] = 0,[1007] = 1,[1008] = 2,[1009] = 4,[1010] = 3
        -- }
        mgr.ViewMgr:openView(ViewName.HuobanView,function(view)
            view:setData()
        end,{index = 0,childIndex = 1})
    elseif param.id == 1089 then--在线累积
        mgr.ViewMgr:openView(ViewName.ImmortalityView,function(view)
            proxy.ImmortalityProxy:sendMsg(1290101)
        end,{})
    elseif param.id == 1090 then--下载有礼
        mgr.ViewMgr:openView2(ViewName.DownLoadView,{})
    elseif param.id == 1091 then--帮派签到
        if cache.PlayerCache:getGangId().."" ~= "0" then
            mgr.ViewMgr:openView(ViewName.BangPaiMain,function(view)
                -- body
                view:setData()
            end,{index = 1013, childIndex = 1})
        else
            mgr.ViewMgr:openView(ViewName.BangPaiFind,function(view)
                -- body
                local param = {}
                param.gangName = ""
                param.page = 1
                proxy.BangPaiProxy:sendMsg(1250102, param)
            end)
        end
    elseif param.id == 1092 then--每日活动
        mgr.ViewMgr:openView(ViewName.DayActiveView,function(view)
            -- proxy.ActivityProxy:sendMsg(1030111,{actType = 1})
            local data = cache.ActivityCache:get5030111()
            local flag = false
            for i=1009,1016 do
                if data.acts[i] and data.acts[i] == 1 then
                    flag = true
                    break
                end
            end
            if data.acts[1023] and data.acts[1023] == 1 then
                flag = true
            end
            -- print("当前活动是否还存在",flag)
            if flag then
                view:setData(data)
            else
                GComAlter(language.vip11)
                view:onBtnClose()
            end
        end,{childIndex = param.childIndex})
    elseif param.id == 1093 then
        if not mgr.FubenMgr:isSitDownSid() then
            GComAlter(language.gonggong77)
            return
        end
        mgr.ViewMgr:openView2(ViewName.FubenView, {index = param.id})
        --proxy.KuaFuProxy:sendMsg(1400101,{},0)
        --mgr.ViewMgr:openView2(ViewName.KuaFuMainView, {index = 0})
    elseif param.id == 1094 then
        if not mgr.FubenMgr:isSitDownSid() then
            GComAlter(language.gonggong77)
            return
        end
        mgr.ViewMgr:openView2(ViewName.ZhanChangMian, {index = 5})


        --mgr.ViewMgr:openView2(ViewName.KuaFuMainView, {index = 1})
        --proxy.KuaFuProxy:sendMsg(1400101,{},1)
        --mgr.ViewMgr:openView2(ViewName.KuaFuMainView, {index = 1})
    elseif param.id == 1095 then
        if not mgr.FubenMgr:isSitDownSid() then
            GComAlter(language.gonggong77)
            return
        end
        proxy.KuaFuProxy:sendMsg(1400101,{},2)
        --mgr.ViewMgr:openView2(ViewName.KuaFuMainView, {index = 2})
    elseif param.id == 1096 then
        mgr.ViewMgr:openView2(ViewName.MarryGuide)
        --mgr.ViewMgr:openView2(ViewName.MarryMainView, {index = 0})
    elseif param.id == 1110 then
        if cache.PlayerCache:getCoupleName() ~= "" then
            mgr.ViewMgr:openView2(ViewName.MarryMainView, {index = 4})
        else
            self:OpenView({id = 1096,index = 0})
        end
    elseif param.id == 1097 then
        mgr.ViewMgr:openView2(ViewName.MarrySongHuaView,param.data)
    elseif param.id == 1098 then
        mgr.ViewMgr:openView2(ViewName.MarryMainView, {index = 1})
    elseif param.id == 1304 then
        mgr.ViewMgr:openView2(ViewName.MarryMainView, {index = 7})
    elseif param.id == 1310 then
        mgr.ViewMgr:openView2(ViewName.MarryMainView, {index = 8})
    elseif param.id == 1402 then
        mgr.ViewMgr:openView2(ViewName.MarryMainView, {index = 10})
    elseif param.id == 1313 then
        local info = {}
        info.index = 9
        info.childIndex = param.childIndex
        mgr.ViewMgr:openView2(ViewName.MarryMainView, info)
    elseif param.id == 1102 then
        mgr.ViewMgr:openView2(ViewName.MarryKaiFuRank)
    elseif param.id == 1103 then

        -- local index = param.index or param.childIndex

        -- mgr.ViewMgr:openView2(ViewName.PanicBuyView,{index = index})
    -- elseif param.id == 1104 then
    --     if not g_ios_test then   --EVE ISO版属屏蔽隐藏任务
    --         mgr.ViewMgr:openView2(ViewName.HiddenTasksView,{})
    --     end
    elseif param.id == 1105 then
        mgr.ViewMgr:openView2(ViewName.ActivityHall,{childIndex = param.childIndex or 0})
    elseif param.id == 1106 then
        mgr.ViewMgr:openView2(ViewName.JueSeMainView,{index = 4,childIndex = param.childIndex,grandson = param.grandson})
    elseif param.id == 1107 then
        mgr.ViewMgr:openView2(ViewName.JueSeMainView,{index = 5,childIndex = param.childIndex,grandson = param.grandson})
    elseif param.id == 1108 then
        -- mgr.ViewMgr:openView2(ViewName.LuckyAdvanceView,{})
    elseif param.id == 1109 then
        mgr.ViewMgr:openView2(ViewName.JueSeMainView,{index = 3,childIndex = param.childIndex,grandson = param.grandson})
    elseif param.id == 1111 then--夏日抽奖
        local data = cache.ActivityCache:get5030111()
        if data.acts[1038] == 1 then
            mgr.ViewMgr:openView(ViewName.SummerActsView,function()
                proxy.ActivityProxy:sendMsg(1030205, {reqType = 1,buyType = 0,stage = 0})
            end)
        else
            GComAlter(language.acthall03)
        end
    elseif param.id == 1112 then
        if cache.PlayerCache:getCoupleName() ~= "" or param.isActHall then
            mgr.ViewMgr:openView2(ViewName.MarryMainView, {index = 6})
        else
            self:OpenView({id = 1096,index = 0})
        end
    elseif param.id == 1113 then--活跃红包
        local data = cache.ActivityCache:get5030111()
        if data.acts[1037] == 1 then
            mgr.ViewMgr:openView(ViewName.ActiveRedBag,function()
                proxy.ActivityProxy:sendMsg(1030204, {reqType = 1})
            end)
        else
            GComAlter(language.acthall03)
        end
    elseif param.id == 1114 then --0元购
        proxy.ActivityProxy:setActiveID(param.index or param.childIndex)
        proxy.ActivityProxy:sendMsg(1030206, {reqType = 0,cId = 0})
    elseif param.id == 1115 then  --宝树活动
        local data = cache.ActivityCache:get5030111()
        if data.acts[1042] == 1 then
            mgr.ViewMgr:openView(ViewName.ActiveTree,function()
                proxy.ActivityProxy:sendMsg(1030145, {reqType = 1})
            end)
        else
            GComAlter(language.acthall03)
        end
    elseif param.id == 1116 then --全民修炼
        mgr.ViewMgr:openView(ViewName.DoubleMajorView,function()
            proxy.PlayerProxy:send(1020411)
        end)
    elseif param.id == 1117 then --仙魔战
        mgr.ViewMgr:openView(ViewName.ZhanChangMian,function(view)
            -- body
        end,{index = 4})
    elseif param.id == 1118 then --威名商店
        mgr.ViewMgr:openView(ViewName.ShopMainView,function(view)
            -- body
        end,{index = 7})--6改7
    elseif param.id == 1119 then --声望商店
         mgr.ViewMgr:openView(ViewName.ShopMainView,function(view)
            -- body
        end,{index = 6})--5改6
    elseif param.id == 1120 then --7天登录
        local data = cache.ActivityCache:get5030111()
        if data.acts[1045] == 1 then
            mgr.ViewMgr:openView(ViewName.SevenDaysView,function(view)
                -- body
                proxy.ActivityProxy:sendMsg(1030147,{reqType=0})
            end)
        else
            GComAlter(language.acthall03)
        end
    elseif param.id == 1121 then --点石成金
        local data = cache.ActivityCache:get5030111()
        if data.acts[1046] == 1 then
            mgr.ViewMgr:openView(ViewName.MidasTouchView,function(view)
                -- body
                proxy.ActivityProxy:sendMsg(1030146,{reqType=1})
            end)
        else
            GComAlter(language.acthall03)
        end
    elseif param.id == 1122 then --疯狂砸蛋
        local data = cache.ActivityCache:get5030111()
        if data.acts[1047] == 1 then
            mgr.ViewMgr:openView(ViewName.SmashEggsView,function(view)
                -- body
                proxy.ActivityProxy:sendMsg(1030209,{reqType=1})
            end)
        else
            GComAlter(language.acthall03)
        end
    elseif param.id == 1124 then--分解系统
        mgr.ViewMgr:openView2(ViewName.ForgingView,{index = param.id})
    elseif param.id == 1129 then --仙盟驻地
        mgr.ViewMgr:openView(ViewName.FlameView,function()
            proxy.BangPaiProxy:send(1250501)
        end)
    elseif param.id == 2004 then--EVE 吞噬装备（直接打开装备选择面板）
        mgr.ViewMgr:openView(ViewName.HuobanExpPop,function(view)
            -- proxy.BangPaiProxy:send(1200201)
        end,{})
    elseif param.id == 1137 then
        --家人家园

        --如果尚未创建家园，则弹框提示
        --
        --您的家园尚未创建，是否消耗XXX绑元进行创建

        ---因长期无人打理，您的家园已荒废，是否花费XXX元宝/绑元重新解锁家园？

        mgr.ViewMgr:openView2(ViewName.HomeBeginView)
    elseif param.id == 1141 then --结婚场景
        proxy.MarryProxy:sendMsg(1390306,{reqType = 0})

    elseif param.id == 1150 then --封测返还
        mgr.ViewMgr:openView(ViewName.CloseTestView,function(view)
            proxy.ActivityProxy:sendMsg(1030211,{reqType=0})
        end)
    elseif param.id == 1152 then  --EVE 天书活动
        local data = cache.ActivityCache:get5030111()
        if data.acts[1055] == 1 then
            mgr.ViewMgr:openView(ViewName.HighGradePackageView,function()
                proxy.ActivityProxy:sendMsg(1030212, {reqType = 0})
            end)
        else
            GComAlter(language.acthall03)
        end

    elseif param.id == 1155 or param.id == 1163 or param.id == 1194 or param.id == 1217
      or param.id == 1239 or param.id == 1240 or param.id == 1267 or param.id == 1358
      or param.id == 1343 or param.id == 1362 or param.id == 1437
      or param.id == 1450 then --寻宝活动
        mgr.ViewMgr:openView(ViewName.XunBaoView,function(view)
            proxy.ActivityProxy:sendMsg(1030152)
        end,{index = language.xunbao08[param.id],moduleId = param.id})
    elseif param.id == 1156 then --日常活跃任务界面
        mgr.ViewMgr:openView(ViewName.DailyTaskView,function(view)

        end)
    elseif param.id == 1157 then --婚礼商城
        mgr.ViewMgr:openView2(ViewName.MarryStoreView)
    elseif 1158 == param.id then--仙法
        mgr.ViewMgr:openView2(ViewName.SkillView, 2)
    elseif 1138 == param.id then --天赋
        mgr.ViewMgr:openView2(ViewName.SkillView, 1)

    elseif param.id == 1159 then --EVE 家园商城
        mgr.ViewMgr:openView(ViewName.ShopMainView,function(view)
        end,{index = 8})--8改9bxp

    elseif param.id == 1160 or param.id == 1232 then  --EVE 幸运云购
        local data = cache.ActivityCache:get5030111()
        if data.acts[3017] == 1 then
           	mgr.ViewMgr:openView(ViewName.BuyCloudView,function()
                -- print("消息发送~~~~~~~~~")
                proxy.ActivityProxy:sendMsg(1030301, {reqType = 0})
            end,{actId = 3017})
        elseif data.acts[3054] == 1 then
            mgr.ViewMgr:openView(ViewName.BuyCloudView,function()
                -- print("消息发送~~~~~~~~~")
                proxy.ActivityProxy:sendMsg(1030401, {reqType = 0})
            end,{actId = 3054})
        else
            GComAlter(language.acthall03)
        end

    elseif param.id == 1162 then
        --种植灵种
        local sId = cache.PlayerCache:getSId()
        if not mgr.FubenMgr:isHome(sId) then
            --不是自己的家园
            self:OpenView({id = 1137})
            return
        end

        mgr.HomeMgr:goPosition(2)
    elseif param.id == 1161 then--圣诞节活动
        mgr.ViewMgr:openView(ViewName.ChristmasActView,function(view)
            local data = cache.ActivityCache:get5030111()
            local flag = false
            for i=3013,3016 do
                if data.acts[i] and data.acts[i] == 1 then
                    flag = true
                    break
                end
            end
            if flag then
                view:setData(data)
            else
                GComAlter(language.vip11)
                view:onBtnClose()
            end
        end,{childIndex = param.childIndex})
    -- elseif param.id >= 1164 and param.id <= 1167 then
    --     mgr.ViewMgr:openView2(ViewName.YdactMainView,{index = param.id})
    elseif param.id == 1168 then
        mgr.FubenMgr:gotoFubenWar(Fuben.beach)
    elseif param.id == 1169 then
        mgr.ViewMgr:openView(ViewName.ZhanChangMian,function(view)
            -- body
        end,{index = 6,childIndex = param.childIndex})
    elseif param.id == 1353 then
        mgr.ViewMgr:openView(ViewName.ZhanChangMian,function(view)
            -- body
        end,{index = 8,childIndex = param.childIndex})
    elseif param.id == 1170 then
        mgr.ViewMgr:openView2(ViewName.WeekendView,{index = param.id})
    elseif param.id >= 1180 and param.id <= 1186 then --腊八活动
        mgr.ViewMgr:openView2(ViewName.LabaMainView,{index = param.id})
    elseif param.id == 1187 then --腊八排行
        local data = cache.ActivityCache:get5030111()
        if data.acts[1067] == 1 then
            mgr.ViewMgr:openView(ViewName.LabaRankView,function()
                proxy.ActivityProxy:sendMsg(1030308)
            end)
        else
            GComAlter(language.acthall03)
        end
	elseif param.id == 1188 then
        mgr.ViewMgr:openView2(ViewName.PetMainView)
    elseif param.id == 1189 then --腊八 野外挂机
        if mgr.FubenMgr:checkScene() then
            GComAlter(language.gonggong41)
            return
        end
        local roleLv = cache.PlayerCache:getRoleLevel()
        local confData = conf.ActivityHallConf:getTrebleDataByLv(roleLv)
        if not confData.pos then return end
        local point = Vector3.New(confData.pos[1], gRolePoz, confData.pos[2])
        mgr.TaskMgr:goTaskBy(confData.sid,point,function()
            mgr.HookMgr:startHook()
        end)
    elseif param.id == 1190 or param.id == 1233 then
        mgr.ViewMgr:openView2(ViewName.TurntableView,param)
    elseif param.id == 1192 then--跳到主城月老
        if mgr.FubenMgr:checkScene() then
            GComAlter(language.gonggong41)
            return
        end

        mgr.TaskMgr:setCurTaskId(9003)
        mgr.TaskMgr.mState = 2
        mgr.TaskMgr:resumeTask()
    elseif param.id == 1195 then      --EVE 小年活动(登录豪礼)
        mgr.ViewMgr:openView2(ViewName.LunarYearMainView,{}) --index = param.id
    elseif param.id >= 1201 and param.id <= 1204 then

        mgr.ViewMgr:openView2(ViewName.ChunJieMainView,{index = param.id} )
    elseif param.id == 1207 then
        mgr.ViewMgr:openView(ViewName.CoupleSuitsView, function ()
            proxy.ActivityProxy:sendMsg(1030313,{reqType = 0,arg1 = 0})
        end)
    elseif param.id == 1205 or param.id == 1206 then
        mgr.ViewMgr:openView2(ViewName.ValentinesMainView,{index = param.id})
    -- elseif param.id >= 1208 and param.id <= 1212 then--元宵活动
    --     mgr.ViewMgr:openView2(ViewName.LanternMainView,{index = param.id})
    elseif param.id >= 1213 and param.id <= 1216 then--符文系统
        mgr.ViewMgr:openView2(ViewName.RuneMainView,{index = param.id})
    elseif param.id == 1222 then--成就
        mgr.ViewMgr:openView(ViewName.JueSeMainView,function(view)
        -- body
        end,{notself = false,index = 6})
    elseif param.id == 1224 then--跨服城战
        mgr.ViewMgr:openView(ViewName.ZhanChangMian,function(view)
            -- body
        end,{index = 7,childIndex = param.childIndex})
    -- elseif param.id == 1227 then--合服活动(废弃掉的)
    --     --开服活动
    --     if param.childIndex then
    --         param.index = param.childIndex
    --     end

    --     proxy.ActivityProxy:setActiveID(param.index) --设置跳转活动
    --     mgr.ViewMgr:openView(ViewName.HeFuMainView,function(view)
    --         -- body
    --         view:setData(cache.ActivityCache:get5030111())
    --         --活动跳转
    --         local param = {id = proxy.ActivityProxy:getActiveID() }
    --         view:nextStep(param)
    --         --清理
    --         proxy.ActivityProxy:setActiveID()
    --     end)
    elseif param.id == 1228 or param.id == 1229 or param.id == 1230 or param.id == 1231 or param.id == 1296 or param.id == 1297 then--充值消费排行活动
        local t = {
            [1228] = 1080,
            [1229] = 1081,
            [1230] = 1082,
            [1231] = 1083,
            [1296] = 1130,
            [1297] = 1131,
        }
        proxy.ActivityProxy:sendMsg(1030186,{actId = t[param.id],reqType = 0})
    elseif  param.id == 1260 then
        -- local actIdTable = {1084,3064}
        -- local actId
        -- for _,v in pairs(actIdTable) do
        --     local data = cache.ActivityCache:get5030111()
        --     if data.acts[v] and data.acts[v] == 1 then
        --         actId = v
        --         break
        --     end
        -- end
        -- if not actId then
        --     GComAlter(language.vip11)
        --     return
        -- end
        mgr.ViewMgr:openView(ViewName.ChouQianView,function ()
            proxy.ActivityProxy:sendMsg(1030251,{reqType = 0,times = 0})
        end)
    elseif param.id == 1234 then
        mgr.ViewMgr:openView(ViewName.ChouQianView,function ()
            proxy.ActivityProxy:sendMsg(1030315,{reqType = 0,actId = 1084})
        end)
    elseif param.id == 1237 then--夺宝奇兵
        mgr.ViewMgr:openView(ViewName.RobTreasureView,function (view)
            local data = cache.ActivityCache:get5030111()
            local flag = false
            if data.acts[1088] and data.acts[1088] == 1 then
                flag = true
            end
            -- print("当前活动是否还存在",flag)
            if flag then
                proxy.ActivityProxy:sendMsg(1030188,{reqType = 0})
            else
                GComAlter(language.vip11)
                view:closeView()
            end
        end)
    elseif param.id == 1235 or param.id == 1236 then--超值兑换
        mgr.ViewMgr:openView2(ViewName.DailyActivityView,{index = param.id})

    elseif param.id == 1238 then--神器
        mgr.ViewMgr:openView2(ViewName.ShenQiView,{index = param.id})
    elseif param.id == 1336 then--神兽
        mgr.ViewMgr:openView2(ViewName.ShenQiView,{index = param.id})
    elseif param.id == 1408 then--DiHun
        mgr.ViewMgr:openView2(ViewName.ShenQiView,{index = param.id})
    elseif param.id == 1410 then--面具
        mgr.ViewMgr:openView2(ViewName.ShenQiView,{index = param.id})
    elseif param.id == 1411 then--双十二

        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1193] and data.acts[1193] == 1) or
            (data.acts[1194] and data.acts[1194] == 1) or
            (data.acts[1195] and data.acts[1195] == 1)  then
            local idTab = {--跳转用 根据活动id跳转模块
                [1193] = 1001,
                [1194] = 1002,
                [1195] = 1003,
                [2] = 1002,
            }
            local childIndex = param.childIndex or 1001
            if param.childIndex then
                childIndex = idTab[param.childIndex]
            end
            mgr.ViewMgr:openView2(ViewName.ShuangShiErView,{id = childIndex})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1241 then--鲜花榜
        local actIdTable = {1089,1090}
        local actId
        for _,v in pairs(actIdTable) do
            local data = cache.ActivityCache:get5030111()
            if data.acts[v] and data.acts[v] == 1 then
                actId = v
                break
            end
        end
        if not actId then
            GComAlter(language.vip11)
            return
        else
            mgr.ViewMgr:openView(ViewName.FlowerRank,function()
                proxy.ActivityProxy:sendMsg(1030320,{actId = actId})
            end)
        end
    elseif param.id == 1335 then--魅力榜
        local data = cache.ActivityCache:get5030111()
        if data.acts[5003] and data.acts[5003] == 1 then
            mgr.ViewMgr:openView(ViewName.FlowerRank,function()
                proxy.ActivityProxy:sendMsg(1030320,{actId = 5003})
            end)
        else
            GComAlter(language.acthall03)
        end
    elseif param.id == 1354 then--全服鲜花榜
        local data = cache.ActivityCache:get5030111()
        if data.acts[5011] and data.acts[5011] == 1 then
            mgr.ViewMgr:openView(ViewName.FlowerRank,function()
                proxy.ActivityProxy:sendMsg(1030327)
            end)
        else
            GComAlter(language.acthall03)
        end
    elseif param.id == 1243 or param.id == 1244 then--精彩活动2
        mgr.ViewMgr:openView2(ViewName.DailyActivityView,{index = param.id})
    elseif param.id == 1248 then--合服折扣礼包
        mgr.ViewMgr:openView(ViewName.HeFuBagView,function ()
            proxy.ActivityProxy:sendMsg(1030411,{reqType = 0,cfgId = 0})
        end)
    elseif param.id >= 1245 and param.id <= 1247 then--世界杯
        mgr.ViewMgr:openView(ViewName.WorldCupView,function()
            proxy.ActivityProxy:sendMsg(1030501,{reqType = 0,field = 0,teamId = 0,confId = 0})
        end)
    elseif param.id == 1249 or param.id == 1250 then--神器排行
        mgr.ViewMgr:openView2(ViewName.ShenQiRankMain,{index = param.id})
    elseif param.id == 1251 then--充值翻牌
        local data = cache.ActivityCache:get5030111()
        if data.acts[1105] and data.acts[1105] == 1 then
            mgr.ViewMgr:openView(ViewName.RechargeDrawView,function()
                proxy.ActivityProxy:sendMsg(1030412,{reqType = 0})
            end)
        else
            GComAlter(language.acthall03)
        end
    elseif param.id == 1252 then  --合服首冲返利

        mgr.ViewMgr:openView2(ViewName.HeFuFanLi)
    elseif param.id == 1253 then  --充值返利
        mgr.ViewMgr:openView(ViewName.RechargeRebate,function()
            proxy.ActivityProxy:sendMsg(1030321)
        end)

    elseif param.id == 1255  or  param.id == 1261 then--山盟海誓
        local actIdTable = {1107,3061}
        local actId
        for _,v in pairs(actIdTable) do
            local data = cache.ActivityCache:get5030111()
            if data.acts[v] and data.acts[v] == 1 then
                actId = v
                break
            end
        end
        mgr.ViewMgr:openView(ViewName.MarryRank,function()
            proxy.ActivityProxy:sendMsg(1030322,{actId = actId})
        end)
    elseif param.id == 1256 then--神炉炼宝
        mgr.ViewMgr:openView(ViewName.ShenLuView,function()
            proxy.ActivityProxy:sendMsg(1030503,{reqType = 0})
        end)
    elseif param.id == 1257 or  param.id == 1262 then--三生三世
        local actIdTable = {1108,3062}
        local actId
        for _,v in pairs(actIdTable) do
            local data = cache.ActivityCache:get5030111()
            if data.acts[v] and data.acts[v] == 1 then
                actId = v
                break
            end
        end
        mgr.ViewMgr:openView(ViewName.MarryChengHao,function()
            proxy.ActivityProxy:sendMsg(1030323,{actId = actId,page = 1})
        end)
    elseif param.id == 1258 then--射门好礼
        local actIdTable = {1109,3063}
        local actId
        for _,v in pairs(actIdTable) do
            local data = cache.ActivityCache:get5030111()
            if data.acts[v] and data.acts[v] == 1 then
                actId = v
                break
            end
        end
        if actId then
            mgr.ViewMgr:openView(ViewName.SheQiuView,function()
                proxy.ActivityProxy:sendMsg(1030324,{actId = actId,reqType = 1})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1259 or param.id == 1279 then  --合服基金
        local t = {
            [1259] = 1111,
            [1279] = 1115,
        }
        local actId = t[param.id]
        local flag = false
        local data = cache.ActivityCache:get5030111()
        if data.acts[actId] and data.acts[actId] == 1 then
            flag = true
        end
        if flag then
            mgr.ViewMgr:openView(ViewName.HeFuFundView,function()
                if actId == 1111 then
                    proxy.ActivityProxy:sendMsg(1030325,{reqType = 0,invType = 0,invId = 0})
                elseif actId == 1115 then
                    proxy.ActivityProxy:sendMsg(1030326,{reqType = 0,invType = 0,invId = 0})
                end
            end)
        end
    elseif param.id == 1263 or param.id == 1271 or param.id == 1284
    or param.id == 1426 or param.id == 1427 or param.id == 1428 then--合服活动入口、开服活动入口、圣诞庆典(2018)、活动中心
        mgr.ViewMgr:openView2(ViewName.HeFuEntrance, {id = param.id})
    elseif param.id == 1264 then--摇钱树
        mgr.ViewMgr:openView(ViewName.GoldTreeView,function ()
            proxy.ActivityProxy:sendMsg(1030504,{reqType = 0})
        end)
    elseif param.id == 1265 then--追杀令
        mgr.ViewMgr:openView2(ViewName.ZhuiShaView,{})
    elseif param.id == 1268 then--寻仙探宝
        local data = cache.ActivityCache:get5030111()
        if data.acts[3066] and data.acts[3066] == 1 then
            mgr.ViewMgr:openView(ViewName.XunXianView,function ()
                proxy.ActivityProxy:sendMsg(1030213,{reqType = 0,tsIndex = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1269 or param.id == 1270 then--剑灵出时

        mgr.ViewMgr:openView2(ViewName.JianLingBorn,{moduleId = param.id })
    elseif param.id == 1273 then
        --充值回馈
        proxy.ActivityProxy:sendMsg(1030505,{reqType=0,cfgId=0})

    elseif param.id == 1274 then--神器寻主
        mgr.ViewMgr:openView(ViewName.ShenQiFindMaster,function ()
            proxy.ActivityProxy:sendMsg(1030217,{reqType = 0,awardId = 0})
        end)
    elseif param.id == 1275 then--法老秘宝
        local data = cache.ActivityCache:get5030111()
        if data.acts[3070] and data.acts[3070] == 1 then
            mgr.ViewMgr:openView(ViewName.FaLaoView,function ()
                proxy.ActivityProxy:sendMsg(1030218,{reqType = 0,times = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1276 then--充值豪礼
        local data = cache.ActivityCache:get5030111()
        if data.acts[3073] and data.acts[3073] == 1 then
            mgr.ViewMgr:openView(ViewName.RechargeGiftView,function ()
                proxy.ActivityProxy:sendMsg(1030222,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1277 then--机甲来袭
        local data = cache.ActivityCache:get5030111()
        if data.acts[3075] and data.acts[3075] == 1 then
            mgr.ViewMgr:openView(ViewName.JiJiaActiveView,function ()
                proxy.ActivityProxy:sendMsg(1030224,{reqType = 0,actId = 3075})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1480 then--开服机甲来袭
        local data = cache.ActivityCache:get5030111()
        if data.acts[1116] and data.acts[1116] == 1 then
            mgr.ViewMgr:openView(ViewName.JiJiaActiveView,function ()
                proxy.ActivityProxy:sendMsg(1030224,{reqType = 0,actId = 1116})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1278 then--帝王将相
        mgr.ViewMgr:openView(ViewName.DiWangView,function (view)
            view:nextSkip(param.index)
            proxy.DiWangProxy:sendMsg(1550101)
        end)
    elseif param.id == 1282 then
        local data = cache.ActivityCache:get5030111()
        if data.acts[5002] and data.acts[5002] == 1 then
            mgr.ViewMgr:openView2(ViewName.PetHelpActive,0)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1285 then
        local param = {}
        param.reqType = 0
        proxy.ActivityProxy:sendMsg(1030225,param)

    elseif param.id == 1280 then--仙侣pk
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1114] == 1 then
            mgr.ViewMgr:openView(ViewName.XianLvPKMainView,function ()
                proxy.XianLvProxy:sendMsg(1540101,{reqType = 0})
            end,{index = 1})
        elseif data.acts and data.acts[1135] == 1 then--预告
            mgr.ViewMgr:openView(ViewName.XianLvPKMainView,function ()
                proxy.XianLvProxy:sendMsg(1540101,{reqType = 1})
            end,{index = 1})
        end
    elseif param.id == 1351 then--仙侣pk(全服)
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[5010] == 1 then--IDTODO
            mgr.ViewMgr:openView(ViewName.XianLvPKMainView,function ()
                proxy.XianLvProxy:sendMsg(1540201,{reqType = 0})
            end,{index = 1})
        elseif data.acts and data.acts[5009] == 1 then--预告
            mgr.ViewMgr:openView(ViewName.XianLvPKMainView,function ()
                proxy.XianLvProxy:sendMsg(1540201,{reqType = 1})
            end,{index = 1})
        end
    elseif param.id == 1281 then--恶魔时装
        mgr.ViewMgr:openView(ViewName.DevilFashionView,function ()
            proxy.ActivityProxy:sendMsg(1030223,{reqType = 0,times=0})
        end)
        --end
    elseif param.id == 1283 then
        mgr.ViewMgr:openView2(ViewName.PetHelpActive,1)
    elseif param.id == 1288 or param.id == 1289 then--神臂擎天
        mgr.ViewMgr:openView2(ViewName.ShenBiActive,{moduleId = param.id })
    elseif param.id == 1290 then--趣味挖矿
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1117] == 1 then
            mgr.ViewMgr:openView(ViewName.ActWaKuangView, function()
                proxy.ActivityProxy:sendMsg(1030506,{reqType = 0,cfgId = 0})
            end)
        else
            GComAlter(language.vip11)
        end

    elseif param.id == 1291 then -- 聚划算
        proxy.ActivityProxy:sendMsg(1030228,{reqType = 0,cid=0})
        -- mgr.ViewMgr:openView(ViewName.JuHuaSuanView,function ()
        -- end)
    elseif param.id == 1293 then -- 连冲特惠
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1119] == 1 then
            mgr.ViewMgr:openView(ViewName.ContinueCharge, function()
                proxy.ActivityProxy:sendMsg(1030508,{reqType = 0,cfgId = 0})
            end)
        else
            GComAlter(language.vip11)
        end

	elseif param.id == 1294 then -- 开服累充入口
        mgr.ViewMgr:openView2(ViewName.KaiFuLeiji)
    elseif param.id == 1295 then -- 累充特惠
        --print("send 1295")
        proxy.ActivityProxy:sendMsg(1030507,{reqType = 0,cfgId = 0})
    elseif param.id == 1292 then -- 消费兑换
        mgr.ViewMgr:openView(ViewName.ConsumeChange, function()
            proxy.ActivityProxy:sendMsg(1030229,{reqType = 0,cfgId = 0})
        end)
    elseif param.id == 1298 then -- 狂欢大乐购
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1133] == 1 then
            mgr.ViewMgr:openView(ViewName.KuangHuanMainView, function()
                proxy.ActivityProxy:sendMsg(1030510,{reqType = 0,cfgId = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1299 then -- 猴王除妖
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3080] == 1 then
            mgr.ViewMgr:openView(ViewName.HouWangView, function()
                proxy.ActivityProxy:sendMsg(1030230,{reqType = 0,index = 0})
            end)
        else
            GComAlter(language.vip11)
        end
	elseif param.id == 1300 then
        -- print("请求摇钱树")
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1132] == 1 then
            proxy.ActivityProxy:sendMsg(1030509,{reqType = 0,cfgId = 0})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1301 then--光环系统
        mgr.ViewMgr:openView2(ViewName.JueSeMainView,{index = 8,childIndex = param.childIndex,grandson = param.grandson})
    elseif param.id == 1302 then
        proxy.ActivityProxy:sendMsg(1030511)
    elseif param.id == 1303 then
        proxy.ActivityProxy:sendMsg(1030231)
    elseif param.id == 1305 then --超值单笔
        mgr.ViewMgr:openView(ViewName.ChongZhiDanBiView, function()
            proxy.ActivityProxy:sendMsg(1030232,{reqType = 0,cfgId = 0})
        end)
    elseif param.id == 1306 then -- 充值抽抽乐
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3083] == 1 then
            mgr.ViewMgr:openView(ViewName.ChargePumpView, function()
                proxy.ActivityProxy:sendMsg(1030233,{reqType = 0,args = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1307 then -- 百发百中
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3084] == 1 then
            mgr.ViewMgr:openView(ViewName.ActShootingView, function()
                proxy.ActivityProxy:sendMsg(1030234,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1308 then --跨服充值榜
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[5005] == 1 then
            mgr.ViewMgr:openView(ViewName.KuaFuChargeMain, function()
                proxy.ActivityProxy:sendMsg(1030235,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif  param.id == 1309 then -- 洞房花烛
        if cache.PlayerCache:getCoupleName() ~= "" then
            mgr.ViewMgr:openView2(ViewName.XianTongtfhz)
        else
            GComAlter(language.xiantong10)
        end
    elseif param.id == 1311 then -- 仙童大比拼
        local data = cache.ActivityCache:get5030111()
        if data.acts[5006] and data.acts[5006] == 1 then
            mgr.ViewMgr:openView2(ViewName.XianWaDaBiPing,0)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1312 then  --仙童洞房返还
        local data = cache.ActivityCache:get5030111()
        if data.acts[3085] and data.acts[3085] == 1 then
        mgr.ViewMgr:openView2(ViewName.XianWaDaBiPing,1)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1314 then --刮刮乐
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3071] == 1 then
            mgr.ViewMgr:openView(ViewName.ScratchActive, function()
                proxy.ActivityProxy:sendMsg(1030219,{reqType = 0,arg = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1315 then  --聚宝盆
        local data = cache.ActivityCache:get5030111()
        if data.acts[3086] and data.acts[3086] == 1 then
            mgr.ViewMgr:openView(ViewName.JuBaoPen, function()
                proxy.ActivityProxy:sendMsg(1030238,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1318 then  --秘境淘宝
        local data = cache.ActivityCache:get5030111()
        if data.acts[3087] and data.acts[3087] == 1 then
            proxy.ActivityProxy:sendMsg(1030239,{reqType = 0,times = 0})
        else
            GComAlter(language.vip11)
        end
    elseif  param.id == 1316 then --顶部按钮月卡
        mgr.ViewMgr:openView2(ViewName.MonthCardView)
    elseif  param.id == 1317 then --充值界面月卡
        mgr.ViewMgr:openView2(ViewName.VipChargeView,{index = 2})
    elseif param.id == 1319 then--头像边框
        mgr.ViewMgr:openView2(ViewName.HeadChooseView, {index = 1,childIndex = param.childIndex})
    elseif param.id == 1320 then--聊天气泡
        mgr.ViewMgr:openView2(ViewName.HeadChooseView, {index = 2,childIndex = param.childIndex})
    elseif param.id == 1321 then --连消特惠
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1137] == 1 then
            mgr.ViewMgr:openView(ViewName.ContinueCost, function()
                proxy.ActivityProxy:sendMsg(1030513,{reqType = 0,cfgId = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1322 then  --今日累充奖励
        local data = cache.ActivityCache:get5030111()
        if data.acts[3088] and data.acts[3088] == 1 then
            mgr.ViewMgr:openView(ViewName.JinRiLeiChong, function()
                proxy.ActivityProxy:sendMsg(1030240,{reqType = 0 , awardId = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1323 then--天命卜卦
        local data = cache.ActivityCache:get5030111()
        if data.acts[3089] and data.acts[3089] == 1 then
           mgr.ViewMgr:openView(ViewName.TianMingBuGua,function ()
            proxy.ActivityProxy:sendMsg(1030241,{reqType = 0,args = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1326 then --步步高升
        local data = cache.ActivityCache:get5030111()
        if data.acts[1138] and data.acts[1138] == 1 then
            mgr.ViewMgr:openView(ViewName.BuBuGaoSheng, function()
                proxy.ActivityProxy:sendMsg(1030514,{reqType = 0})
            end)
        end

    elseif param.id == 1327 then--天晶洞窟
        mgr.FubenMgr:gotoFubenWar(Fuben.collect)
    elseif param.id == 1328 then--老师请点名
        local data = cache.ActivityCache:get5030111()
        if data.acts[3090] and data.acts[3090] == 1 then
            mgr.ViewMgr:openView(ViewName.SignInTeacher,function ()
                proxy.ActivityProxy:sendMsg(1030242,{reqType = 0,times = 0,index = 0,level = 1})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1329 then--限时连充
        local data = cache.ActivityCache:get5030111()
        print("data.acts[1140]",data.acts[1140])
        if data.acts[1140] and data.acts[1140] == 1 then
            mgr.ViewMgr:openView(ViewName.XianShiLianChong,function ()
                proxy.ActivityProxy:sendMsg(1030517,{reqType = 0,cfgId = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1331 then--限时礼包
        local data = cache.ActivityCache:get5030111()
        if data.acts[3092] and data.acts[3092] == 1 then
            proxy.ActivityProxy:sendMsg(1030515,{reqType = 0})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1330 then --无敌幸运星
        local data = cache.ActivityCache:get5030111()
        if data.acts[3091] and data.acts[3091] == 1 then
             mgr.ViewMgr:openView(ViewName.WuDiXinYunXing,function ()
                 proxy.ActivityProxy:sendMsg(1030243,{reqType = 0,args = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1332 then --灵虚宝藏
        local data = cache.ActivityCache:get5030111()
        if data.acts[1139] and data.acts[1139] == 1 then
             mgr.ViewMgr:openView(ViewName.LingXuBaoZangView,function ()
                 proxy.ActivityProxy:sendMsg(1030516,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1333 then
        local data = cache.ActivityCache:get5030111()
        if data.acts[1141] and data.acts[1141] == 1 then
            proxy.ActivityProxy:sendMsg(1030518)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1338 then --我要转转
        local data = cache.ActivityCache:get5030111()
        if data.acts[1142] and data.acts[1142] == 1 then
             mgr.ViewMgr:openView(ViewName.AroundView,function ()
                 proxy.ActivityProxy:sendMsg(1030519,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1334 then --悠讯特权
        local data = cache.ActivityCache:get5030111()
        if  g_var.yx_game_param and data.acts and data.acts[1146] == 1 then
            mgr.ViewMgr:openView2(ViewName.YouXunView)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1339 then --祈福灵泉
        local data = cache.ActivityCache:get5030111()
        if data.acts[1143] and data.acts[1143] == 1 then
            proxy.ActivityProxy:sendMsg(1030520,{reqType = 0,cfgId = 0})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1340 then --合服寻宝排行
        local data = cache.ActivityCache:get5030111()
        if data.acts[3095] and data.acts[3095] == 1 then
            proxy.ActivityProxy:sendMsg(1030249,{reqType = 0,cid = 0})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1342 then --元宝兑换活动
        local data = cache.ActivityCache:get5030111()
        if data.acts[1145] and data.acts[1145] == 1 then
            proxy.ActivityProxy:sendMsg(1030522,{reqType = 0,cid = 0})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1344 then --合服洞房排行
        local data = cache.ActivityCache:get5030111()
        if data.acts[3093] and data.acts[3093] == 1 then
             mgr.ViewMgr:openView(ViewName.DongFangRank,function ()
                 proxy.ActivityProxy:sendMsg(1030245,{reqType = 0,cid = 0})
            end)

        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1345 then --合服连续充值
        local data = cache.ActivityCache:get5030111()
        if data.acts[1144] and data.acts[1144] == 1 then
             mgr.ViewMgr:openView(ViewName.HeFuLianChong,function ()
                 proxy.ActivityProxy:sendMsg(1030521,{reqType = 0,cfgId = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1346 then --仙装排行
        local data = cache.ActivityCache:get5030111()
        if data.acts[5008] and data.acts[5008] == 1 then
             mgr.ViewMgr:openView(ViewName.XzphView,function ()
                 proxy.ActivityProxy:sendMsg(1030250)
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1347 then --神兽排行
        local data = cache.ActivityCache:get5030111()
        if data.acts[5007] and data.acts[5007] == 1 then
            proxy.ActivityProxy:sendMsg(1030244)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1350 then --中秋活动
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1148] and data.acts[1148] == 1) or
            (data.acts[1149] and data.acts[1149] == 1) or
            (data.acts[1150] and data.acts[1150] == 1) or
            (data.acts[1151] and data.acts[1151] == 1) or
            (data.acts[1152] and data.acts[1152] == 1) or
            (data.acts[1153] and data.acts[1153] == 1)  then
            --proxy.ActivityProxy:sendMsg(1030244)
            mgr.ViewMgr:openView2(ViewName.ZhongQiuView)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1352 then --中秋豪礼
        local data = cache.ActivityCache:get5030111()
        if data.acts[1147] and data.acts[1147] == 1 then
            mgr.ViewMgr:openView(ViewName.MidAuTumnView,function ()
                 proxy.ActivityProxy:sendMsg(1030607,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1355 then--国庆活动
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1157] and data.acts[1157] == 1) or
            (data.acts[1158] and data.acts[1158] == 1) or
            (data.acts[1159] and data.acts[1159] == 1) or
            (data.acts[1160] and data.acts[1160] == 1) or
            (data.acts[1161] and data.acts[1161] == 1) or
            (data.acts[3051] and data.acts[3051] == 1) or
            (data.acts[1058] and data.acts[1058] == 1) then
            local idTab = {--跳转用 根据活动id跳转模块
                [1157] = 1001,
                [1158] = 1002,
                [1159] = 1003,
                [1161] = 1004,
                [1160] = 1005,
                [3051] = 1006,
                [1058] = 1007,
            }
            local childIndex = 1001
            if param.childIndex then
                childIndex = idTab[param.childIndex]
            end
            mgr.ViewMgr:openView2(ViewName.ActGuoQingView,{id = childIndex})
        else
            GComAlter(language.vip11)
        end
    -- elseif param.id == 1425 then--记忆饺宴
    --     local data = cache.ActivityCache:get5030111()
    --    if (data.acts[1208] and data.acts[1208] == 1) then
    --            mgr.ViewMgr:openView(ViewName.JiYJiaoYanView,function ()
    --              proxy.DongZhiProxy:sendMsg(1030676,{reqType = 0,answer = {}})


    --         end)
    --     else
    --         GComAlter(language.vip11)
    --     end
    elseif param.id == 1420 or param.id == 1421 or param.id == 1422 or  param.id == 1425 then--冬至活动
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1196] and data.acts[1196] == 1) or
            (data.acts[1197] and data.acts[1197] == 1) or
            (data.acts[1198] and data.acts[1198] == 1) or
            (data.acts[1204] and data.acts[1204] == 1)  then
            local idTab = {--跳转用 根据活动id跳转模块
                [1196] = 1001,
                [1197] = 1002,
                [1198] = 1003,
                [1204] = 1004,

            }
            local childIndex = 1001
            print(param.childIndex)
            if param.childIndex then
                childIndex = idTab[param.childIndex]
            end
            mgr.ViewMgr:openView2(ViewName.DongZhiView,{id = childIndex})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1424 then--冬至连充活动
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1200] and data.acts[1200] == 1) then
               mgr.ViewMgr:openView(ViewName.DongZhiLianChong,function ()
                 proxy.ActivityProxy:sendMsg(1030667,{reqType = 0,cid = 0})
            end)
        else
            GComAlter(language.vip11)
        end

     elseif param.id == 1423 then--冬至抽奖活动
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1199] and data.acts[1199] == 1) then
               mgr.ViewMgr:openView(ViewName.DongZhiJiaoYan,function ()
                 proxy.ActivityProxy:sendMsg(1030666,{reqType = 0,cid = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1166 then--雪地作战
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1058] and data.acts[1058] == 1) then
            mgr.ViewMgr:openView2(ViewName.ActGuoQingView,{id = 1007})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1211 then--答题
        local data = cache.ActivityCache:get5030111()
        if (data.acts[3051] and data.acts[3051] == 1) then
            mgr.ViewMgr:openView2(ViewName.ActGuoQingView,{id = 1006})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1356 then
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1154] and data.acts[1154] == 1) or
            (data.acts[1155] and data.acts[1155] == 1) or
            (data.acts[1156] and data.acts[1156] == 1) then
            mgr.ViewMgr:openView2(ViewName.QuanMingView)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1357 then --圣印排行
        local data = cache.ActivityCache:get5030111()

        if (data.acts[5012] and data.acts[5012] == 1) then
            mgr.ViewMgr:openView(ViewName.ShengYinRank,function ()
                 proxy.ActivityProxy:sendMsg(1030252)

            end)
        elseif (data.acts[1191] and data.acts[1191] == 1) then
            mgr.ViewMgr:openView(ViewName.ShengYinRank,function ()
                 proxy.ActivityProxy:sendMsg(1030419)
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1359 then --圣印返还
        local data = cache.ActivityCache:get5030111()

        if (data.acts[1163] and data.acts[1163] == 1 )then
            mgr.ViewMgr:openView(ViewName.ShengYinReturn,function ()
                 proxy.ActivityProxy:sendMsg(1030625,{reqType = 0})

            end)
        elseif (data.acts[1189] and data.acts[1189] == 1 )then  --圣印返还
            mgr.ViewMgr:openView(ViewName.ShengYinReturn,function ()
                 proxy.ActivityProxy:sendMsg(1030417,{reqType = 0 })
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1361 then -- 珍稀乾坤
        local data = cache.ActivityCache:get5030111()
        if data.acts[1164] and data.acts[1164] == 1 then
            mgr.ViewMgr:openView(ViewName.ZhenXiQianKun,function ()
                 proxy.ActivityProxy:sendMsg(1030626,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1363 or param.id == 1364 then -- 剑神寻宝排行和返还
        mgr.ViewMgr:openView2(ViewName.JianShenMain,{moduleId = param.id})
    elseif param.id == 1366 then -- 幸运鉴宝
         mgr.ViewMgr:openView(ViewName.LuckyTreasureView,function ()
                 proxy.ActivityProxy:sendMsg(1030637,{reqType = 0})
            end)
    elseif param.id == 1367 then -- 烟花庆典
        local data = cache.ActivityCache:get5030111()
        if data.acts[1167] and data.acts[1167] == 1 then
            mgr.ViewMgr:openView(ViewName.YanHuaAct,function ()
                 proxy.ActivityProxy:sendMsg(1030635,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1368 then -- 累计消费
        local data = cache.ActivityCache:get5030111()
        -- print("累计消费活动",data.acts[1168])
        if data.acts[1168] and data.acts[1168] == 1 then
            mgr.ViewMgr:openView(ViewName.Cumulative,function ()
                 proxy.ActivityProxy:sendMsg(1030636,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1374 then -- 万圣节累充活动
        local data = cache.ActivityCache:get5030111()
        if data.acts[1170] and data.acts[1170] == 1 then
            mgr.ViewMgr:openView(ViewName.HalloweenRecharge,function ()
                 proxy.ActivityProxy:sendMsg(1030639,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1375 then -- 捣蛋南瓜田活动
        local data = cache.ActivityCache:get5030111()
        if data.acts[1171] and data.acts[1171] == 1 then
            mgr.ViewMgr:openView(ViewName.DaoDanNanGuaTian,function ()
                 proxy.ActivityProxy:sendMsg(1030640,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1376 then -- 双色球
        local data = cache.ActivityCache:get5030111()
        if data.acts[1175] and data.acts[1175] == 1 then
            mgr.ViewMgr:openView(ViewName.DoubleBall,function ()
                 proxy.ActivityProxy:sendMsg(1030645,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id >= 1369 and param.id <= 1372 then --万圣狂欢
        mgr.ViewMgr:openView2(ViewName.ActWSJMainView,{index = param.id})
    elseif param.id == 1373 then -- 捣蛋南瓜田活动
        local data = cache.ActivityCache:get5030111()
        if (data.acts[3096] and data.acts[3096] == 1) then
            mgr.ViewMgr:openView2(ViewName.AlertWSJView)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1379 then -- 脱单领称号
        local data = cache.ActivityCache:get5030111()
        if data.acts[3097] and data.acts[3097] == 1 then
            mgr.ViewMgr:openView(ViewName.TuoDanMain,function ()
                 proxy.ActivityProxy:sendMsg(1030254,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1382 then -- 情侣充值排行榜
        local data = cache.ActivityCache:get5030111()
        if data.acts[5014] and data.acts[5014] == 1 then
            mgr.ViewMgr:openView(ViewName.TuoDanRank,function ()
                proxy.ActivityProxy:sendMsg(1030255)
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1380 then -- 真假雪人
        local data = cache.ActivityCache:get5030111()
        if data.acts[1176] and data.acts[1176] == 1 then
            mgr.ViewMgr:openView(ViewName.SnowMan,function ()
                 proxy.ActivityProxy:sendMsg(1030646,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1381 then -- 满减活动
        local data = cache.ActivityCache:get5030111()
        if data.acts[1177] and data.acts[1177] == 1 then
            proxy.ActivityProxy:sendMsg(1030647,{reqType = 0})
            -- mgr.ViewMgr:openView(ViewName.FullReduction,function ()

            -- end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1383 or param.id == 1384 then--奇门遁甲
        mgr.ViewMgr:openView2(ViewName.QiMenDunJiaMain,{moduleId = param.id })
    elseif (param.id >= 1385 and param.id <= 1397) then
        mgr.ViewMgr:openView2(ViewName.JinJieRankMain,{id = param.id})
    elseif param.id == 1400 then -- 天天返利
        local data = cache.ActivityCache:get5030111()
        if data.acts[1179] and data.acts[1179] == 1 then
            mgr.ViewMgr:openView(ViewName.TianTianFanLiView,function ()
                 proxy.ActivityProxy:sendMsg(1030650,{reqType = 0,cfgId = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1399 then -- 水果消除
        local data = cache.ActivityCache:get5030111()
        if data.acts[1180] and data.acts[1180] == 1 then
            mgr.ViewMgr:openView(ViewName.FruitView,function ()
                 proxy.ActivityProxy:sendMsg(1030651,{reqType = 0,cid = 0,ids = {},count = 0})
            end)
        else
            GComAlter(language.vip11)
        end
     elseif param.id == 1401 then--感恩活动
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1181] and data.acts[1181] == 1) or
            (data.acts[1182] and data.acts[1182] == 1) or
            (data.acts[1183] and data.acts[1183] == 1)  then
            local idTab = {--跳转用 根据活动id跳转模块
                [1181] = 1001,
                [1182] = 1002,
                [1183] = 1003,
            }
            local childIndex = 1001
            if param.childIndex then
                childIndex = idTab[param.childIndex]
            end
            mgr.ViewMgr:openView2(ViewName.GanEnView,{id = childIndex})
        else
            GComAlter(language.vip11)
        end
     elseif param.id == 1403 then -- 幸运锦鲤
        local data = cache.ActivityCache:get5030111()
        if data.acts[1184] and data.acts[1184] == 1 then
            mgr.ViewMgr:openView(ViewName.XinYunLiJin,function ()
                 proxy.ActivityProxy:sendMsg(1030655,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1404 then -- 天降礼包
        local data = cache.ActivityCache:get5030111()
        if data.acts[1185] and data.acts[1185] == 1 then
            mgr.ViewMgr:openView(ViewName.TianJiangLiBao,function ()
                 proxy.ActivityProxy:sendMsg(1030656,{reqType = 0,cid = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1405 then--科举答题
        mgr.FubenMgr:gotoFubenWar(Fuben.keju)
    elseif param.id == 1406 then--月末狂欢（双倍充值）
        local data = cache.ActivityCache:get5030111()
        if data.acts[3098] and data.acts[3098] == 1 then
            proxy.ActivityProxy:sendMsg(1030328)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1409 then -- 帝魂召唤
        local data = cache.ActivityCache:get5030111()
        if data.acts[1192] and data.acts[1192] == 1 then
            mgr.ViewMgr:openView(ViewName.DiHunZhaoHuanView,function ()
                 proxy.ActivityProxy:sendMsg(1030659,{reqType = 0,type = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1407 then--帝魂任务
        mgr.ViewMgr:openView(ViewName.DiHunMainView,function ()
            proxy.DiHunProxy:sendMsg(1620108,{reqType = 0,cid = 0})
        end)
    elseif param.id >= 1413 and param.id <= 1417 then --2018圣诞
        mgr.ViewMgr:openView2(ViewName.ShengDanMainView,{index = param.id})
    elseif param.id == 1418 then -- 圣诞累充福利(2018)
        local data = cache.ActivityCache:get5030111()
        if data.acts[1201] and data.acts[1201] == 1 then
            mgr.ViewMgr:openView(ViewName.ShengDanCharge,function ()
                 proxy.ShengDanProxy:sendMsg(1030668,{reqType = 0,cfgId = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1419 then --许愿圣诞树(2018)
        local data = cache.ActivityCache:get5030111()
        if data.acts[1207] and data.acts[1207] == 1 then
            mgr.ViewMgr:openView(ViewName.XuYuanShengDanShu,function ()
                 proxy.ShengDanProxy:sendMsg(1030669,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1429 then --遗迹探索
        mgr.ViewMgr:openView2(ViewName.YiJiTanSuoView,{})
    elseif param.id == 1430 then --元旦祈福2018
        local data = cache.ActivityCache:get5030111()
        if data.acts[1212] and data.acts[1212] == 1 then
            mgr.ViewMgr:openView(ViewName.YuanDanQiFuView,function ()
                 proxy.YuanDanProxy:sendMsg(1030680,{reqType = 0,cid = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id >= 1431 and param.id <= 1434 then --2018元旦
        mgr.ViewMgr:openView2(ViewName.YuanDanMainView,{index = param.id})
    elseif param.id == 1435 then --元旦转盘2018
        local data = cache.ActivityCache:get5030111()
        if data.acts[1213] and data.acts[1213] == 1 then
            mgr.ViewMgr:openView(ViewName.YuanDanZhuanPan,function ()
                 proxy.YuanDanProxy:sendMsg(1030681,{reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1436 then --记忆花灯
        local data = cache.ActivityCache:get5030111()
        if data.acts[1208] and data.acts[1208] == 1 then
            proxy.DongZhiProxy:sendMsg(1030676,{reqType = 0,answer = {}})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1439 or param.id == 1440 then--奇兵降临
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1216] and data.acts[1216] == 1) or (data.acts[5016] and data.acts[5016] == 1) then
            mgr.ViewMgr:openView2(ViewName.QiBingActive,{moduleId = param.id })
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1446 then --腊八消费排行榜2019
        local data = cache.ActivityCache:get5030111()
        if(data.acts[1220] and data.acts[1220] ==1) then
            mgr.ViewMgr:openView(ViewName.LaBaRankView2019,function()
                proxy.ActivityProxy:sendMsg(1030691)
            end)
        else
            GComAlter(language.acthall03)
        end
    elseif param.id == 1458 then --冰雪节活动
        local data = cache.ActivityCache:get5030111()
        if(data.acts[1224] and data.acts[1224] ==1) or
          (data.acts[1225] and data.acts[1225] ==1) or
          (data.acts[1226] and data.acts[1226] ==1) or
          (data.acts[1227] and data.acts[1227] ==1) then
          --(data.acts[1228] and data.acts[1228] ==1) or
          --(data.acts[1058] and data.acts[1058] ==1) then
          local idTab = {--跳转用 根据活动id跳转模块
              [1224] = 1003,
              [1225] = 1004,
              [1226] = 1006,
              [1227] = 1007,
              [1058] = 1005,
              --[1228] = 1007,
          }
          local childIndex = 1003
          if param.childIndex then
              childIndex = idTab[param.childIndex]
          end
          mgr.ViewMgr:openView2(ViewName.BingXueMainView,{id = childIndex})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1457 then --消费抽抽乐活动
        local data = cache.ActivityCache:get5030111()
        if(data.acts[1228] and data.acts[1228] ==1) then
            mgr.ViewMgr:openView(ViewName.XiaoFeiView,function()
                proxy.ActivityProxy:sendMsg(1030702)
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1449 then--腊八活动2019
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1217] and data.acts[1217] == 1) or
            (data.acts[1218] and data.acts[1218] == 1) or
            (data.acts[1219] and data.acts[1219] == 1) or
            (data.acts[1220] and data.acts[1220] == 1)   then
            local idTab = {--跳转用 根据活动id跳转模块
                [1217] = 1001,
                [1218] = 1002,
                [1219] = 1003,
            }
            local childIndex = 1001
            if param.childIndex then
                childIndex = idTab[param.childIndex]
            end
            mgr.ViewMgr:openView2(ViewName.LaBaView2019,{id = childIndex})
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1447 then --腊八累抽
        local data = cache.ActivityCache:get5030111()
        if data.acts[1221] and data.acts[1221] == 1 then
            mgr.ViewMgr:openView(ViewName.LaBaLeiChou,function ()
                print("腊八累抽")
                proxy.ActivityProxy:sendMsg(1030692, {reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
     elseif param.id == 1451 then--小年活动2018
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1229] and data.acts[1229] == 1) or
            (data.acts[1230] and data.acts[1230] == 1) or
            (data.acts[1231] and data.acts[1231] == 1) or
            (data.acts[1232] and data.acts[1232] == 1)  then
            local idTab = {--跳转用 根据活动id跳转模块
                [1229] = 1001,
                [1230] = 1002,
                [1231] = 1003,
                [1232] = 1004,
            }
            local childIndex = 1001
            if param.childIndex then
                childIndex = idTab[param.childIndex]
            end
            mgr.ViewMgr:openView2(ViewName.XiaoNianView,{id = childIndex})
        else
            GComAlter(language.vip11)
        end
     elseif param.id == 1459 then --小年祭灶
        local data = cache.ActivityCache:get5030111()
        if data.acts[1233] and data.acts[1233] == 1 then
            mgr.ViewMgr:openView(ViewName.XiaoNianJiZhao,function ()
                proxy.XiaoNianProxy:sendMsg(1030707, {reqType = 0})
            end)
        else
            GComAlter(language.vip11)
        end
    elseif param.id == 1460 then --小年豪礼
        local data = cache.ActivityCache:get5030111()
        if data.acts[1234] and data.acts[1234] == 1 then
            mgr.ViewMgr:openView(ViewName.XiaoNianHaoLi,function ()
                proxy.XiaoNianProxy:sendMsg(1030708, {reqType = 0,cid = 0})
            end)
        else
            GComAlter(language.vip11)
        end
     elseif param.id == 1461 then--春节活动2019
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1235] and data.acts[1235] == 1) or
            (data.acts[1236] and data.acts[1236] == 1) or
            (data.acts[1237] and data.acts[1237] == 1) or
            (data.acts[1238] and data.acts[1238] == 1)  then
           
            local idTab = {--跳转用 根据活动id跳转模块
                [1235] = 1001,
                [1236] = 1002,
                [1237] = 1003,
                [1238] = 1004,
            }
            local childIndex = 1001
            if param.childIndex then
                childIndex = idTab[param.childIndex]
            end
            --检测第几阶段
            local daytype 
            if (data.acts[1236] and data.acts[1236] == 1) then
                daytype = 1
            elseif (data.acts[1238] and data.acts[1238] == 1) then
                daytype =2 
            elseif (data.acts[1242] and data.acts[1242] == 1) then
                daytype = 3 
            else
                daytype = 4
            end
            print("daytype",daytype)
            mgr.ViewMgr:openView2(ViewName.ChunJieView2019,{id = childIndex,type  = daytype})
        else
            GComAlter(language.vip11)
        end
    end
end

------------------------检测主界面的的功能是否开启
function ModuleMgr:check(var)
    -- body
    if not opent[var] then
        return false
    end
    if opent[var] == 1062 then --检测剑神看红点
        --plog("cache.PlayerCache:getRedPointById(10205)",cache.PlayerCache:getRedPointById(10205))
        if cache.PlayerCache:getRedPointById(10205) > 0 then
            return true
        end
        return false
    end

    return self:CheckSeeView(opent[var])
end

function ModuleMgr:checkById(var,id)
    -- body
    if not opent[var] then
        return false
    end
    if opent[var] == 1062 then --检测剑神看红点
        --plog("cache.PlayerCache:getRedPointById(10205)",cache.PlayerCache:getRedPointById(10205))
        if cache.PlayerCache:getRedPointById(10205) > 0 then
            return true
        end
        return false
    end
    --plog("var",var,id)
    return self:CheckSeeView({id = opent[var],taskId =  id})
end
--系统模块开启
function ModuleMgr:setModuleVisible(tMod,btnList,btnPos)
    local t = tMod
    local index = 1
    for k ,v in pairs(t) do
        local btn = btnList[k]
        btn.visible = self:CheckSeeView(v)
        if btn.visible then
            btn.y = btnPos[index]
            index = index + 1
        end
    end
end

--自动寻路中
function ModuleMgr:startFindPath(index)
    -- body
    local view = mgr.ViewMgr:get(ViewName.AutoFindView)
    if view then
        view:initData(index)
    else
        mgr.ViewMgr:openView2(ViewName.AutoFindView,index)
    end

end

function ModuleMgr:closeFindPath(index)
    -- body
    local view = mgr.ViewMgr:get(ViewName.AutoFindView)
    if view then
        if view.c1.selectedIndex == index then
            view:closeView()
            mgr.HookMgr:setHookState()
        end
    end

end

return ModuleMgr