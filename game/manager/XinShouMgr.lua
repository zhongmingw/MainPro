--
-- Author: yr
-- Date: 2017-03-20 22:17:20
--

local XinShouMgr = class("XinShouMgr")

local donet = {
    [1001] = Skins.zuoqi,--坐骑
    [1002] = Skins.xianyu,--仙羽
    [1003] = Skins.shenbing,--神兵
    [1004] = Skins.xianqi,--仙器
    [1005] = Skins.fabao,--法宝
    [1006] = Skins.huoban,--伙伴
    [1007] = Skins.huobanxianyu,--灵羽
    [1008] = Skins.huobanshenbing,--灵兵
    [1009] = Skins.huobanxianqi,--灵器
    [1010] = Skins.huobanfabao,--灵宝
    [1287] = Skins.qilinbi,--灵宝
}
function XinShouMgr:ctor()
    self.gomiji = nil
    self.guiddata = nil
end

function XinShouMgr:enterGame()
    --右边即将开启模块预告
    if g_is_banshu then
        return
    end
    if g_ios_test then 
        return
    end
    self:checkRemindModule()
end

function XinShouMgr:updateLevel()--不走等级了
    if g_ios_test then 
        return
    end
    self:checkRemindModule()
    --self:checkModuleOpen() --新手激活

    --功能开启引导
    local id = {
        [1132] = 1129,--单人刷波
        [1133] = 1130,--组队刷波
        [1093] = 1131,--跨服组队
        [1130] = 1132,--单人守塔
        [1131] = 1133,--组队守塔
        [1125] = 1135,--仙尊boss
        [1128] = 1136,--boss之家
        [1049] = 1134,--世界boss
        [1134] = 1137,--装备套装
        [1033] = 1138,--装备合成
        [1138] = 1139,--技能天赋
        [1137] = 1140,--家园开启
        [1098] = 1121,--结婚系统
        [1188] = 1141,--宠物系统
        [1213] = 1142,--符文系统
        [1152] = 1146,--天书寻主
    }
    -- local data = conf.XinShouConf:getOpenModule(1129)
    -- self:checkXinshou(data)
    

    local level = cache.PlayerCache:getRoleLevel()
    for k ,v in pairs(id) do
        local condata = conf.SysConf:getModuleById(k)
        local data
        if level == condata.open_lev then
            data = conf.XinShouConf:getOpenModule(v)
            print("找到模块",k)
        end
        if data then
            self:checkXinshou(data)
            break
        end
    end

    

    -- 
    -- local condata = conf.SysConf:getModuleById(1094)
    -- if level == condata.open_lev then
    --     local data = conf.XinShouConf:getOpenModule(1128)
    --     self:checkXinshou(data)
    -- end

    --self:checkRemindModule()
    --检测是否升级到30级的强制引导
    -- local level = cache.PlayerCache:getRoleLevel()
    -- if level ~= 30 then
    --     return
    -- end
    -- --加一个特效 --花瓣
    -- mgr.TaskMgr:stopTask()
    -- --
    -- --mgr.ViewMgr:openView2(ViewName.Alert15, 4020127)
    -- --开始引导
    -- local data = conf.XinShouConf:getOpenModule(1118)
    -- self:checkXinshou(data)
    --希望击昏系统特效完成之后 jixu 
    --cache.GuideCache:setMarry(true)
end

--主界面初始化的时候读取配置检查功能是否开启
--新模块开启，飘图标，弹出模块
function XinShouMgr:checkNewModule(data)
    
end

function XinShouMgr:checkModuleOpen()
    -- body
    local view = mgr.ViewMgr:get(ViewName.XinShouView)
    local data = cache.ActivityCache:get5030111()
    if not data then
        --意外情况获取不到开服天数
        if view then
            view:dispose()
        end
        return
    end
    -- id 1 衣服 ，2 武器 3仙羽 4.坐骑 ,5 神兵 ， 6 法宝
--7 仙器 8 伙伴 9 伙伴仙羽 10 伙伴神兵 11 伙伴法宝 12伙伴仙器
-- 13.称号 14.修仙称号
    
    local openDay = data.openDay 
    --人物等级
    local level = cache.PlayerCache:getRoleLevel()
    --配置信息
    local info = conf.XinShouConf:getRemindModule()
    for k , v in pairs(info) do
        if v.openday and v.res_type ~= 3 then
            if openDay >= v.openday and level >= v.level then
                local ccc = cache.PlayerCache:getSkins(donet[v.module_id])
                if not ccc or ccc == 0 then
                    local condata = conf.XinShouConf:getOpenModule(v.guideid)
                    self:checkXinshou(condata)
                    break
                end
            end
        end
    end


end

--右边即将开启模块预告
function XinShouMgr:checkRemindModule()
    --配置信息
    local view = mgr.ViewMgr:get(ViewName.XinShouView)
    if g_ios_test then
        if view then
            view:dispose()
        end
        return
    end

    if mgr.FubenMgr:checkScene() then
        --副本的时候不检查
        return
    end
     
    local data = cache.ActivityCache:get5030111()
    if not data then
        --意外情况获取不到开服天数
        if view then
            view:dispose()
        end
        return
    end
    ----开服第几天
    local openDay = data.openDay 
    --人物等级
    local level = cache.PlayerCache:getRoleLevel()
    --配置信息
    local info = conf.XinShouConf:getRemindModule()

    local minInfo
    for k , v in pairs(info) do
        if v.taskid then
            if not cache.TaskCache:isfinish(v.taskid) then
                --任务相关
                minInfo = v
                break
            end
        elseif v.openday and v.level then
            -- 开服天数 和 等级相关
            if not donet[v.module_id] then
                if openDay < v.openday or level < v.level then
                    minInfo = v
                    break
                end
            else
                local ccc = cache.PlayerCache:getSkins(donet[v.module_id])
                if not ccc or ccc == 0 then
                    if openDay < v.openday or level < v.level then
                        minInfo = v
                        break
                    end
                end
            end
        else
            -- 等级相关
            if level < v.level then
                minInfo = v
                break
            end
        end
        
    end

    if minInfo then
        local data = {type=1, info=minInfo}
        if not view then
            mgr.ViewMgr:openView2(ViewName.XinShouView, data)
        else
            view:initData(data)
        end
    else
        if view then
            view:dispose()
        end
    end
end
--根据任务id 获取判定是否获得仙法技能
function XinShouMgr:getXianFaSkill(taskid)
    -- body
    if not taskid then
        return false
    end
    local condata = conf.TaskConf:getTaskById(taskid)
    if not condata then
        return false
    end
    local skillinfo = condata.skill_pre
    if not skillinfo then
        return false
    end
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view.c3.selectedIndex = 1
    else
        return false
    end
    mgr.ViewMgr:openView2(ViewName.GuideSkill, {id = skillinfo ,guide = true} )
    return true
end

--习得技能
function XinShouMgr:openNewSkill(taskconf,xinconf)
    mgr.ViewMgr:closeAllView2()

    local sex = cache.PlayerCache:getSex()
    local skillinfo = xinconf.param[sex]
    mgr.ViewMgr:openView2(ViewName.GuideSkill, {data = skillinfo ,guide = true} )
    
   
    --local t = {"n305","n306","n307"}
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view.c3.selectedIndex = 0
        --plog("111",xinconf.guideid)
        -- if xinconf.guideid == 1007 then
        --     view.view:GetChild("n305").visible = false
        -- elseif xinconf.guideid == 1009 then
        --     view.view:GetChild("n306").visible = false
        -- else
        --     view.view:GetChild("n307").visible = false
        -- end
    end

    

end

--装备获得弹窗
function XinShouMgr:equipAlert(data)
    --mgr.ViewMgr:closeAllView2()
    local view = mgr.ViewMgr:get(ViewName.EquipWearTipView)
    if view then
        mgr.TimerMgr:addTimer(0.6, 1, function()
            -- body
            view:startGuide(data)
        end)
        
    else
        GgoToMainTask()
    end
end
--特效完成后穿戴装备
function XinShouMgr:equipEff(taskconf,xinconf)
    -- body
    if xinconf.param then --
        --先领取
        local view = mgr.ViewMgr:openView2(ViewName.GuideZuoqi,{index = 13,callback=function()
            -- body
            local t = {
                effect = xinconf.param,
                tar = gRole,
                nextguideid = xinconf.nextguideid
            }
            mgr.ViewMgr:openView2(ViewName.GuideLayer,t)
            local effectConf = conf.EffectConf:getEffectById(xinconf.param)
            mgr.TimerMgr:addTimer(effectConf.durition_time , 1, function()
                -- body
                local mId = taskconf.finish_items[1][1]
                local packinfo = cache.PackCache:getPackDataById(mId) 
                if packinfo.index ~= 0 then
                    local toIndex = Pack.equip + conf.ItemConf:getPart(mId)
                    local params = {
                        opType = 0,--穿
                        indexs = {packinfo.index},--背包的位置
                        toIndexs = {toIndex},--目标位置
                    }
                    proxy.PackProxy:sendWearEquip(params)
                end  

                GgoToMainTask()
            end)
        end})   
    else
        --获得已经穿戴的装备
        local _before = cache.PackCache:getEquipData()
        local mId = taskconf.finish_items[1][1]
        mgr.ViewMgr:openView2(ViewName.GuideEquip2,{data = clone(_before),mId = mId,nextguideid = xinconf.nextguideid})

        local packinfo = cache.PackCache:getPackDataById(mId) 
        if packinfo.index ~= 0 then
            local toIndex = Pack.equip + conf.ItemConf:getPart(mId)
            local params = {
                opType = 0,--穿
                indexs = {packinfo.index},--背包的位置
                toIndexs = {toIndex},--目标位置
            }
            proxy.PackProxy:sendWearEquip(params)
        end
        --策划要求 获得装备的时候人要继续任务
        GgoToMainTask()
    end
end

--各种活动弹框| 首充、福利
function XinShouMgr:welfareAlert(data)
    if not data then
        return
    end

    if not data.id then
        return 
    end

    local isOpen = true
    if data.id == 1058 then --百倍礼包
        if cache.PlayerCache:getAttribute(30102) ~= 1 then
            isOpen = false
        end
    elseif data.id == 1063 then --仙尊卡
        if cache.PlayerCache:VipIsActivate(3) then
            isOpen = false
        end
    -- elseif data.id == 1059 then --投资计划
    --     if cache.PlayerCache:getAttribute(30105) and cache.PlayerCache:getAttribute(30105) ~= 0 then
    --         isOpen = true
    --     else
    --         isOpen = false
    --     end
    elseif data.id == 1054 then
        --再充献礼
        local view = mgr.ViewMgr:get(ViewName.MainView)
        local topos
        if view then
            local pairs = pairs
            for k ,v in pairs(view.TopActive.btnlist) do
                for i , j in pairs(v) do
                    if j.data and j.data.id == 1054 then
                        topos = j.xy + j.parent.xy
                        break
                    end
                end
            end
        end
        if not GIsCharged() and topos then
            isOpen = true
        else
            isOpen = false
        end 
        if not g_ios_test and isOpen then
            mgr.ViewMgr:openView2(ViewName.GuideActive, data)
        end

    -- elseif data.id == 1114 then
    --     if cache.PlayerCache:getAttribute(30111) > 0 then
    --         isOpen = true
    --     else
    --         isOpen = false
    --     end
    -- elseif data.id == 1060 then
    --     isOpen = false
        -- if cache.PlayerCache:getAttribute(30101) ~= 1 then
        --     isOpen = false
        -- end
    end
    -- if not g_ios_test and isOpen then
    --     --聚宝盆，投资计划
    --     local t = {[1059] = 1}
    --     if t[data.id] then
    --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, data)
    --     else
    --         mgr.ViewMgr:openView2(ViewName.GuideActive, data)
    --     end

    -- end
    GgoToMainTask()
end

function XinShouMgr:checkWssb(data)
    -- body
end

--各种可以强化、进阶、升级提示
function XinShouMgr:growUpAlert(data)
    if data.guideid == 1119 then
        mgr.ViewMgr:openView2(ViewName.Alert15, 4020127)
        GOpenView({id = 1096})
        return
    end

    if data.guideid == 1046 then
        cache.BangPaiCache:setGuide(true)
    elseif data.guideid == 1105 then
        cache.VipChargeCache:setXianzunTyTime(9999)
    elseif data.guideid == 1039 then
        local var = cache.PlayerCache:getRedPointById(30117)
        if  not var or var == 0 then
            GgoToMainTask()
            return
        end

    end

    local view = mgr.ViewMgr:get(data.module_name)
    if view then
        if data.module_name == "main.MainView"  then
            mgr.ViewMgr:closeAllView2()
            view.c3.selectedIndex = data.param or 0 

            if data.guideid == 1107 then --非强制加手指
                --plog("111")
                cache.GuideCache.shouzhi = true
            end
        elseif data.module_name == "zuoqi.ZuoQiMain" then
            view.c1.selectedIndex = data.param or 0 
        elseif data.module_name == "forging.ForgingView" then
            view.mainController.selectedIndex = data.param or 0 
        elseif data.module_name == "huoban.HuobanView" then
            view.c1.selectedIndex = data.param or 0 
        elseif data.module_name == "loginaward.LoginAwardView" then

        elseif data.module_name == "bangpai.BangPaiFind" then
            
        end
        cache.GuideCache:setData(nil)
        view:startGuide(data)
    else
        cache.GuideCache:setData(data)
    end    


end
--开界面
function XinShouMgr:openView(data)
    -- body
    if g_ios_test then
        return
    end
    if data.module_name == ViewName.VipExperienceView  then
        if not cache.PlayerCache:VipIsActivate(1) then
            --plog("激活白银")
            --cache.GuideCache:setData(data)
            
            local view = mgr.ViewMgr:get(data.module_name)
            if view then
                --开始引导
                --proxy.VipChargeProxy:sendXianzunTy(1,1)
                view:startGuide(data)
                return
            end

            mgr.ViewMgr:openView(ViewName.VipExperienceView,function(view)
                --消息
                --proxy.VipChargeProxy:sendXianzunTy(1,1)
                view:startGuide(data)
            end,{})
        end
    elseif data.module_name == ViewName.HiddenTasksView then
        if cache.PlayerCache:getAttribute(30101) == 1 then
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view and view.TopActive then
                view.TopActive:checkActive(1060)
            end
            if not g_ios_test then  --EVE IOS版属屏蔽隐藏任务
                mgr.ViewMgr:openView(ViewName.HiddenTasksView,function(view)
                    --开始引导
                    view:startGuide(data)
                end,{})
            end 
        else
            GgoToMainTask()
        end
    else
        GgoToMainTask()
    end
end
--g购买道具
function XinShouMgr:openBuyItem(data)
    -- body
    --
    if not data.param then
        return
    end
    if type(data.param)~= "table" then
        return
    end
    if #data.param~= 2 then
        return
    end

    local param = {
        mId = data.param[1],
        index = data.param[2],
        isGuide = true,
    }
    GGoBuyItem(param)
end
--主界面顶部按钮
function XinShouMgr:openTopActive(data)
    -- body
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if not view then
        return
    end
    view.TopActive:checkActive()
    local pairs = pairs
    for k ,v in pairs(view.TopActive.btnlist) do
        for i , j in pairs(v) do
            --plog(j.data.id,data.id,"fubenCount")
            if j.data and tonumber(j.data.id) ==tonumber(data.id) then
                data.guide = {"n326."..j.name} 
                if view.topJianTou.visible then
                    mgr.ViewMgr:closeAllView2()
                    view.c4.selectedIndex = 0
                    view:startGuide(data)
                end
                return
            end
        end
    end

    GgoToMainTask()
end

--坐骑开启
function XinShouMgr:openZuoqi( taskconf,xinconf )
    --EVE 激活主界面左下角坐骑按钮
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:onClickUseMounts()
    end
    --EVE END

    -- body
    --主动激活一次
    local index 
    if xinconf.type == 7 then --坐骑
        index = 0
        proxy.ZuoQiProxy:send(1120102,{auto = 0})
        local param = {}
        param.skinId = xinconf.param
        param.reqType = 1
        proxy.ZuoQiProxy:send(1120105,param)
    elseif xinconf.type == 8 then --神兵
        index = 1
        proxy.ZuoQiProxy:send(1160102,{reqType = 0})
        proxy.ZuoQiProxy:send(1160105,{skinId = xinconf.param})
    elseif xinconf.type == 9 then --仙羽
        index = 3
        proxy.ZuoQiProxy:send(1140102,{reqType = 0})
        proxy.ZuoQiProxy:send(1140105,{skinId = xinconf.param})
    elseif xinconf.type == 10 then--仙器
        index = 4
        proxy.ZuoQiProxy:send(1180102,{reqType = 0})
        proxy.ZuoQiProxy:send(1180105,{skinId = xinconf.param})
    elseif xinconf.type == 11 then --法宝
        index = 2
        proxy.ZuoQiProxy:send(1170102,{reqType = 0})
        proxy.ZuoQiProxy:send(1170105,{skinId = xinconf.param})
    elseif xinconf.type == 15 then --伙伴
        index = 5
        --proxy.HuobanProxy:send(1200107,{skinId = xinconf.param}) --领取
        proxy.HuobanProxy:send(1200201,{reqType = 1}) --激活
        proxy.HuobanProxy:send(1200105,{skinId = xinconf.param,reqType = 0}) --出战
    elseif xinconf.type == 16 then --伙伴神兵开启
        index = 6
        proxy.HuobanProxy:send(1220103,{reqType = 0})
        proxy.HuobanProxy:send(1220106,{skinId = xinconf.param})
    elseif xinconf.type == 17 then --伙伴仙羽开启
        index = 7
        proxy.HuobanProxy:send(1210102,{reqType = 0})
        proxy.HuobanProxy:send(1210105,{skinId = xinconf.param})
    elseif xinconf.type == 18 then --伙伴仙器开启
        index = 8
        proxy.HuobanProxy:send(1240102,{reqType = 0})
        proxy.HuobanProxy:send(1240105,{skinId = xinconf.param})
    elseif xinconf.type == 19 then --伙伴法宝开启
        index = 9
        proxy.HuobanProxy:send(1230102,{reqType = 0})
        proxy.HuobanProxy:send(1230105,{skinId = xinconf.param})
    end

    local data = {id = xinconf.param ,taskId = taskconf and  taskconf.task_id,index = index,nextguideid=xinconf.nextguideid} --坐骑ID\
    if not g_ios_test then  --EVE 屏蔽引导过程中的弹窗(获得坐骑)
        mgr.ViewMgr:openView2(ViewName.GuideZuoqi, data)
    end 
end
--新功能开启
function XinShouMgr:newModuleOpen(taskconf,data)
    -- body
    if not data then
        return
    end

    if not data.id then
        --plog("2")
        plog("注意配置模块id 新手")
        return 
    end

    if not taskconf then
        taskconf = {}
    end

    local view = mgr.ViewMgr:get(ViewName.MainView)
    if not view then
        return
    end

    --找位置
    --优先找底部按钮
    local topos 
    local condata = conf.ActivityConf:getBottomByid(data.id)
    local btn 
    if condata then
        if view.isFightbtn.visible then
            view.c3.selectedIndex = 1
        elseif data.guideid == 1080 then
        else
            return
        end

        view:chenkOpenById(taskconf.task_id)
        
        if  data.guideid == 1080 then
            btn = view.view:GetChild("n303")
            btn.visible = false
            topos = btn.xy+btn:GetChild("icon").xy
        elseif data.guideid == 1104 then
            if not cache.PlayerCache:VipIsActivate(1) then
                btn = view.view:GetChild("n345")
                --view:setXianzunTips(false)
                view.view:GetChild("marry").x = 271


                
                btn.visible = false
                topos = btn.xy+btn:GetChild("icon").xy
            end
        elseif data.guideid == 1118 then
            btn = view.view:GetChild("marry")
            btn.visible = false
            topos = btn.xy+btn:GetChild("icon").xy
        else
            btn = view.view:GetChild(mgr.ModuleMgr:getBtnName(data.id))
            btn.visible = false
            topos = btn.xy
        end
         
        
    else --这里基本不出现
        if view.topJianTou.visible then
            if view.c4.selectedIndex == 1 then
                view.topJianTou.onClick:Call()
            end
        end
        --找到对应位置
        --print(data.id,"55") 
        if data.id == 1053 or data.id == 1054 or 1057 == data.id or 1060 == data.id 
            or data.id == 1055 or data.id == 1152 then
            view.TopActive:checkActive(data.id)
        else
            if taskconf.task_id then
                view.TopActive:chenkOpenById(taskconf.task_id,false)
            end
        end


        local pairs = pairs
        for k ,v in pairs(view.TopActive.btnlist) do
            for i , j in pairs(v) do
                if j.data and j.data.id == data.id then
                    topos = j.xy + j.parent.xy
                    if j.data.id == 1094 then
                        j.visible = false
                        --开好等级的时候请求任务信息
                        mgr.TimerMgr:addTimer(0.4,1,function()
                            -- body
                            j.visible = false
                        end)

                    end 
                    break
                end
            end
        end
    end
    if topos  then --如果存在
        mgr.ViewMgr:closeAllView2()
        if not g_ios_test then     --EVE 屏蔽引导弹窗
            mgr.ViewMgr:openView2(ViewName.GuideViewOpen,
            {data = data,btn = btn,topos = topos,task_id = taskconf.task_id})
        end
    else
        if taskconf.task_id then
            mgr.TaskMgr:completeTask(taskconf.task_id)
        end
    end
end
--
function XinShouMgr:newBianshen(falg)
    -- body
    --检测变身系统
    if cache.PlayerCache:getRedPointById(10205)<=0 then
        if cache.PlayerCache:getRedPointById(10206) > 0 then 
            local view = mgr.ViewMgr:get(ViewName.GuideBianSheng)
            if not view then
                -- if not g_ios_test then    --EVE 屏蔽变身开启倒计时
                    mgr.ViewMgr:openView2(ViewName.GuideBianSheng,falg)
                -- end 
            end
        end
    end
end
--对话
function XinShouMgr:openDialog(data)
    -- body

    if data.guideid == 2003 then
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view.view:GetChild("n303").visible = false
        end
    end

    mgr.ViewMgr:openView2(ViewName.GuideDialog2, {id = data.param,callback = function()
        -- body
        if data.nextguideid then
            self:checkXinshou(conf.XinShouConf:getOpenModule(data.nextguideid))
        else
            GgoToMainTask()
        end
        
        return
    end})
    --GgoToMainTask()
end

function XinShouMgr:checkXinshou(data)
    -- body
    if not data then
        return
    end
    if g_ios_test then 
        return
    end
    if not data.type then
        plog("新手配置缺失type@策划",self.confData.guideid)
        return
    end

    self.guiddata = data

    if data.type == 1 then
        self:equipAlert(data)
    elseif data.type == 3 then
        self:openDialog(data)
    elseif data.type == 4 then
        self:equipEff(self.confData,data)
    elseif data.type == 6 then
        self:openNewSkill(self.confData,data)
    elseif data.type >= 7 and data.type <= 11 then
        self:openZuoqi(self.confData,data)
    elseif data.type == 12 then
        self:growUpAlert(data)
    elseif data.type == 13 then 
        self:openBuyItem(data)
    elseif data.type == 14 then 
        self:openTopActive(data)
    elseif data.type >= 15 and data.type <= 19 then
        self:openZuoqi(self.confData,data)
    elseif data.type == 20 then --新功能开启
        self:newModuleOpen(self.confData,data)
    elseif data.type == 21 then 
        self:welfareAlert(data)
    elseif data.type == 23 then
        self:newBianshen(data)
    elseif data.type == 24 then
        --打开viwe
        self:openView(data)
    elseif data.type == 25 then
        mgr.ViewMgr:openView2(ViewName.GuideZuoqi,data)
    elseif data.type == 26 then
        --
        self:runtoNpc(data)
    elseif data.type == 28 then
        --天书寻主
        cache.GuideCache:setGuide(data)
    end
end

function XinShouMgr:MijingGuilde()
    -- body
    if self.gomiji then
        self.gomiji = nil 
        mgr.ViewMgr:openView2(ViewName.MijinguideView)
    end
       
end

function XinShouMgr:runtoNpc(data)
    -- body
    local npcId = data.param
    if not npcId then
        plog("缺少npcID")
        return
    end

    local npcConf = conf.NpcConf:getNpcById(npcId)
    local nPos = npcConf.pos
    local point = Vector3.New(nPos[1], gRolePoz, nPos[2])
    mgr.JumpMgr:findPath(point,100,function(  )
        -- body
        if data.nextguideid then
            mgr.XinShouMgr:checkXinshou(conf.XinShouConf:getOpenModule(data.nextguideid))
        end
    end)
end

--当一个主线任务完成
function XinShouMgr:checkTaskFinsh(id)
    -- body
    if not g_is_guide then
        return false
    end
    local confData = conf.TaskConf:getTaskById(id) 
    if not confData then
        return false
    end
    self.confData = confData
    local data = conf.XinShouConf:getOpenModule(confData.guideid)
    if not data then --没有引导
        return false
    end
    --获得装备引导穿戴
    if confData.guideid and not data then
        plog("在新手配置里面找不到@策划",confData.guideid)
        return false
    end
    self:checkXinshou(data)
    return true
end
--副本离开
function XinShouMgr:effectOutFuben(id)
    -- body
    --mgr.EffectMgr:playCommonEffect
    local parent = UnitySceneMgr.pStateTransform
    local e ,durition= mgr.EffectMgr:playCommonEffect(4020115, parent)
    e.LocalPosition = gRole:getPosition()
    cache.GuideCache:setGuide(nil)
    return durition 
end
--副本进入
function XinShouMgr:effectinFuben(id)
    -- body
    -- local d = -6 --方向 Y
    -- local s = 0.4 --倍数
    -- local t = 1 --时间
    --gRole:scaleTo(d,s,t)
    local parent = UnitySceneMgr.pStateTransform
    local e ,durition= mgr.EffectMgr:playCommonEffect(4020115, parent)
    e.LocalPosition = gRole:getPosition()

    -- mgr.TimerMgr:addTimer(durition-0.5, 1, function()
    --     -- body
    --     local pos = Vector3.New(e.LocalPosition.x+40, gRolePoz, e.LocalPosition.z)
    --     mgr.JumpMgr:findPath(pos,0,nil)
    -- end)
    

    return durition 
end

--当主角抵达任务目标 --param 当前执行的任务 , firstguide 抵达时候的引导
function XinShouMgr:runNearTar(param)
    -- body
    if not param or not param.firstguide then
        return false
    end
    plog("当主角抵达任务目标",param.task_id)

    local condata = conf.XinShouConf:getOpenModule(param.firstguide)
    if condata and condata.type==3 and condata.param then --NPC对话
        mgr.ViewMgr:openView2(ViewName.GuideDialog2, {id = condata.param,callback = function()
            -- body
            mgr.ViewMgr:openView(ViewName.TaskView,function( view )
                -- body
                view:setData(param.task_id,true)
            end)
        end})
    elseif condata and condata.type==26 and condata.param then --杀怪对话
        --plog("function  爱的")
        mgr.ViewMgr:openView2(ViewName.GuideDialog2, {id = condata.param,callback = function()
            -- body
            mgr.HookMgr:startHook()
        end})
    elseif condata and condata.type==5 then
        local npcId = param.conditions[1][1]
        local _npc = mgr.ThingMgr:getObj(ThingType.npc,npcId)
        if _npc then
            _npc:dead()
        end
        proxy.TaskProxy:send(1050103,{taskId = param.task_id})
    elseif param.task_type == 4 then
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view and view.taskorTeam then
            view.taskorTeam.c2.selectedIndex = 1
        end

        gRole:inFuben()
        local time = self:effectinFuben(param.firstguide)
        cache.GuideCache:setGuide(param.firstguide)
        --特效完成之后
        mgr.TimerMgr:addTimer(time, 1, function()
            -- body
            gRole:flyUp(function()
                -- body
                mgr.TimerMgr:addTimer(0.2, 1, function()
                    mgr.FubenMgr:gotoFubenWar(param.conditions[1][1])
                end)
            end)
        end)
    else
        return false
    end

    return true
end

function XinShouMgr:PlayEffect(TaskId)
    -- body
    local condata = conf.TaskConf:getTaskById(TaskId)
    if condata and condata.effectId then 
        mgr.ViewMgr:openView2(ViewName.Alert15, condata.effectId)
    end
end


return XinShouMgr