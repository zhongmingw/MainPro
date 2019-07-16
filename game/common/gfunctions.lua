--公共方法 | 用G开头
--清理当前缓存
function GClearUPlayerPrefs()
    -- body
    local key = g_var.accountId.."1026buy"
    UPlayerPrefs.SetString(key,"")
    local key = g_var.accountId.."1030buy"
    UPlayerPrefs.SetString(key,"")
end


--创建一个道具icon
--position 位置
function GCreateItem( data )
    local itemObj = UIPackage.CreateObject(UICommonRes[1] , "ComItemBtn")--创建一个item
    itemObj.position = data.position
    return itemObj
end

--设置道具icon信息
--amount 数量 or 等级,mid 道具编号,isClick是否有点击事件,isChatPro是否聊天栏道具
function GSetItemData(itemObj,data,isClick,isChatPro)
    mgr.ItemMgr:setItemData(itemObj,data,isClick,isChatPro)
end

function GSeeLocalItem( data , info)
    local viewName = ViewName.PropMsgView
    local index = data and  data.index or 0
    -- --如果是宠物蛋要做其他处理
    -- --print("data",data.mid,data.mId)
    -- if data.mid then
    --     local condata = conf.ItemConf:getItem(data.mid)
    --     if condata and condata.petindex then
    --         mgr.PetMgr:seeLocalPet(condata.petindex,data)
    --         return
    --     end
    -- end

    if mgr.ItemMgr:isLimitItem(index) then--是不是临时背包
        viewName = ViewName.PropMsgView
    else
        --EVE 优化时装TIPS
        local isSuit = conf.ItemConf:getSuitmodel(data.mid) --是不是时装
        local type = conf.ItemConf:getType(data.mid)
        if type == Pack.runeType then
            mgr.ViewMgr:openView2(ViewName.RuneIntroduceView, data)
            return
        end
        if isSuit and type ~= Pack.equipawkenType then
            viewName = ViewName.FashionTipsView
        else
            if type == Pack.equipType then
                viewName = ViewName.EquipTipsView
            elseif type == Pack.equipawkenType then
                local isSub = conf.ItemConf:getSubType(data.mid) --是不是碎片
                if isSub == 2 then
                    viewName = ViewName.PropMsgView
                else
                   viewName = ViewName.EquipShengZhuang
                end
            elseif type == Pack.equippetType or type == Pack.shenshouEquipType then
                viewName = ViewName.EquipPetTipsView
                local cc
                if data then
                    cc = clone(data)
                    if cc.notsenddata then
                        cc = nil --宠物装备需要的特殊p
                    end
                end

                mgr.ViewMgr:openView(viewName,function(view)
                    view:setData(cc,info)
                end)
                return
            elseif type == Pack.wuxing then
                viewName = ViewName.EquipWuXing
            elseif  type == Pack.xianzhuang then
                viewName = ViewName.EquipXianZhuangTipsView
            elseif type == Pack.shengYinType then
                viewName = ViewName.EquipShengYin
            elseif type == Pack.elementType then
                local isSub = conf.ItemConf:getSubType(data.mid) --八门道具
                if isSub == 15 then
                    viewName = ViewName.PropMsgView
                else
                    viewName = ViewName.EightGatesElementTips
                end
            elseif type == Pack.dihunType then
                viewName = ViewName.HunShiTipsView
            elseif type == Pack.shengXiaoType then
                viewName = ViewName.EquipShengXiaoTipsView
            end
        end
    end

    mgr.ViewMgr:openView(viewName,function(view)
        view:setData(data,info)
    end)
end
--[[
公共弹窗  GComAlte(lang.faaa)
--]]
function GComAlter(param)
    -- body
    if not param then
        return
    end
    local data
    --plog(type(param),"ssssssssssssssssssss")
    if type(param)== "string" then
        data = {}
        data.richtext = param
        data.speed = 0--速度，目前只有走马灯用到
        data.type = 1
    else
        data = param
    end
    if not data or not next(data) then
        return
    end
    --按参数类型打开公用弹窗
    if data.type == 2 then
        if data.close then
            local view = mgr.ViewMgr:get(ViewName.Alert2)
            if view then
                view:closeView()
            end
        else
            mgr.ViewMgr:openView(ViewName.Alert2,function(view)
                -- body
                --plog(data.richtext,"richtext")
                -- printt(data)
                view:setData(data)
            end)--有两个按钮
        end

    elseif data.type == 3 then--走马灯
        mgr.ViewMgr:openView(ViewName.Alert4,nil,data)
    elseif data.type == 5 then --中间一个按钮的
        mgr.ViewMgr:openView(ViewName.Alert5,function(view)
            view:setData(data)
        end)
    elseif data.type == 8 then
        mgr.ViewMgr:openView(ViewName.Alert8,function(view)
            view:setData(data)
        end)
    elseif data.type == 7 then
        mgr.ViewMgr:openView(ViewName.Alert7,function(view)
            view:setData(data)
        end)
    elseif data.type == 9 then
        mgr.ViewMgr:openView(ViewName.Alert9,function(view)
            view:setData(data)
        end)
    elseif data.type == 11 then
        mgr.ViewMgr:openView(ViewName.Alert11,function(view)
            view:setData(data.awards)
        end)
    elseif data.type == 12 then
        mgr.ViewMgr:openView(ViewName.Alert12,nil,data)
    elseif data.type == 13 then  --EVE 断线重连新逻辑
        mgr.ViewMgr:openView(ViewName.ReconnectView,nil,data)
    elseif data.type == 14 then  --EVE 断线重连新逻辑
        mgr.ViewMgr:openView2(ViewName.Alert14,data)
    elseif data.type == 16 then  --购买次数
        mgr.ViewMgr:openView2(ViewName.Alert16,data)
    elseif data.type == 17 then
        mgr.ViewMgr:openView2(ViewName.Alert17,data)
    elseif data.type == 18 then
        mgr.ViewMgr:openView2(ViewName.Alert18,data)
    elseif data.type == 19 then
        mgr.ViewMgr:openView2(ViewName.Alert19,data)
    elseif data.type == 20 then
        mgr.ViewMgr:openView2(ViewName.Alert20,data)
    elseif data.type == 21 then
        mgr.ViewMgr:openView2(ViewName.Alert21,data)
    else
        local view = mgr.ViewMgr:get(ViewName.Alert1)
        if view then
            view:setData(data)
        else
            mgr.ViewMgr:openView(ViewName.Alert1,function( view )
                -- body
                view:setData(data)
            end)--只有飘个字
        end
        if data.richtext == language.gonggong18 then
            local view = mgr.ViewMgr:get(ViewName.DeadView)
            if not view then
                if g_ios_test then   --EVE 屏蔽元宝不足跳转
                    return
                else
                    GOpenView({id = 1042})
                end
            end
        elseif data.richtext == language.arena10 then
            GOpenView({id = 1063})
        elseif data.richtext == language.gonggong22 then
            --绑元不足
            local view = mgr.ViewMgr:get(ViewName.ShopMainView)
            if view then
                local param = {}
                param.mId = MoneyPro2[MoneyType.bindGold]
                GGoBuyItem(param)
            end
        elseif data.richtext == language.gonggong05 then
            --铜钱不足
            local view = mgr.ViewMgr:get(ViewName.ShopMainView)
            if view then
                local param = {}
                param.mId = MoneyPro2[MoneyType.bindCopper]
                GGoBuyItem(param)
            end
        elseif data.richtext == language.gonggong46 then
            local view = mgr.ViewMgr:get(ViewName.ShopMainView)
            if view then
                local param = {}
                param.mId = MoneyPro2[MoneyType.gongxun]
                GGoBuyItem(param)
            end
        elseif data.richtext == language.gonggong44 then
            local view = mgr.ViewMgr:get(ViewName.ShopMainView)
            if view then
                local param = {}
                param.mId = MoneyPro2[MoneyType.ry]
                GGoBuyItem(param)
            end
        elseif data.richtext == language.gonggong45 then
            local view = mgr.ViewMgr:get(ViewName.ShopMainView)
            if view then
                local param = {}
                param.mId = MoneyPro2[MoneyType.pt]
                GGoBuyItem(param)
            end
        elseif data.richtext == language.gonggong90 then
            local view = mgr.ViewMgr:get(ViewName.ShopMainView)
            if view then
                local param = {}
                param.mId = MoneyPro2[MoneyType.sw]
                GGoBuyItem(param)
            end
        elseif data.richtext == language.gonggong91 then
            local view = mgr.ViewMgr:get(ViewName.ShopMainView)
            if view then
                local param = {}
                param.mId = MoneyPro2[MoneyType.wm]
                GGoBuyItem(param)
            end
        end
    end
end

--接到错号提示
function GComErrorMsg(status)
    -- body
    if not status then
        return
    end
    --需要特殊操作
    if 20010102 == status then
        mgr.NetMgr:onNetError(status)
        return
    elseif 21100001 == status then --木有角色需要跳转至创建角色
        mgr.ViewMgr:openView(ViewName.CreateRoleView) --打开创建角色模块
        mgr.ViewMgr:closeView(ViewName.LoginView)
        return
    elseif status == 22010001 then--背包已满
        local view = mgr.ViewMgr:get(ViewName.ChatView)
        if view then
            proxy.ChatProxy:send(1080101,{page = view.mailPanel:getPage()})
        end
    elseif status == 2206017 then --对方已经是其他帮派成员
        proxy.BangPaiProxy:send(1250105,{page= 1})
    elseif status == 2001003 or status == 21090010 then--服务器关闭
        mgr.NetMgr:onNetError(status)
        return
    elseif 2290006 == status then
        --快速加入队伍的时候,如果队伍满员 有这个错误号
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            local param = {
                msgId = 8010101,
                status = status
            }
            view:setData(param)
        end

        -- local view = mgr.ViewMgr:get(ViewName.KuaFuMainView)
        -- if view then
        --     local param = {
        --         msgId = 8010101,
        --         status = status
        --     }
        --     view:addMsgCallBack(param)
        -- end
        return
    end
    if status == -1 and not g_error_illegal then--
        return
    end
    if status == 2208004 or status == 2208012 or status == 2250004 then
        plog(mgr.FubenMgr.sceneId,status)
        local sceneId = mgr.FubenMgr.sceneId
        local func = function()
            local sceneConfig = conf.SceneConf:getSceneById(sceneId)
            local lvl = sceneConfig and sceneConfig.lvl or 1
            local playLv = cache.PlayerCache:getRoleLevel()
            if playLv >= lvl then
                proxy.ThingProxy:sChangeScene(sceneId,0,0,3,mgr.FubenMgr.diffId)
            else
                GComAlter(string.format(language.gonggong07, lvl))
            end
        end
        if mgr.FubenMgr:checkSingleScene(sceneId) then
            local text = language.team25
            local param = {type = 14,richtext = mgr.TextMgr:getTextColorStr(text, 6),sure = function()
                    proxy.TeamProxy:send(1300107)
                    func()
                end}
            GComAlter(param)
        end
        return
    elseif 2290005 == status then
        local view = mgr.ViewMgr:get(ViewName.FubenView)
        if view then
            local param = {}
            param.msgId = 8010101
            param.status = status
            view:setData(param)
        end

        -- local view = mgr.ViewMgr:get(ViewName.KuaFuMainView)
        -- if view then
        --     local param = {}
        --     param.msgId = 8010101
        --     param.status = status
        --     view:addMsgCallBack(param)
        -- end
    elseif 2030108 == status then--特权未激活统一跳仙尊卡
        GOpenView({id = 1050})
    end
    --其他情况 飘个字
    GComAlter(message.errorID[tonumber(status)])

    --元宝不足强行跳转
    if tonumber(status) == 22020003 then
        local view = mgr.ViewMgr:get(ViewName.DeadView)
        if not view then
            if g_ios_test then --EVE 屏蔽元宝不足跳转
                return
            else
                GOpenView({id = 1042})
            end
        end
    end
end

--设置金钱数据
function GSetMoneyPanel(panel,vName)
    mgr.GuiMgr:registerMoneyPanel(panel,vName)
end
--刷新金钱数据
function GRefreshMoney()
    mgr.GuiMgr:updateMoneyPanels()
end
--恭喜获得弹窗isOk是否有确认按钮
function GOpenAlert3(items,isOk)
    if items and #items>0 then
        local isNotOpen = false
        if mgr.ViewMgr:get(ViewName.WelfareView) then--福利大厅
            isNotOpen = true
        end
        -- if isNotOpen then return end
        local view = mgr.ViewMgr:get(ViewName.Alert3)
        if view then
            view:setData(items,isOk)
        else
            mgr.ViewMgr:openView(ViewName.Alert3, function(view)
                view:setData(items,isOk)
            end)
        end
    end
end
--按roleIcon 获取信息
function GGetMsgByRoleIcon(roleicon,roleId,func)
    -- body
    local t = {}
    local temp = 100000000
    t.sex = math.floor(roleicon / temp)
    local iconId = roleicon%100
    t.icon = iconId
    -- print(t.sex,t.icon,"######")
    --头像边框icon
    local frameId = math.floor((roleicon%10000)/100)
    local frameIcon = conf.RoleConf:getFrameIconById(frameId)
    if frameIcon then
        t.frameUrl = UIPackage.GetItemURL("_others" , frameIcon)
    else
        t.frameUrl = UIPackage.GetItemURL("_panels" , "gonggongsucai_050")
    end
    if g_ios_test then
        local url = ""
        local path  = "ui://mainios/"
        local sexs = {"100","200"}
        if tonumber(g_var.packId) > 2009 then
            url = "res/bgs/login/mainios_"..g_var.packId..sexs[t.sex]
            local check = PathTool.CheckResDown(url..".unity3d")
            if not check then
                url = path.."0"..sexs[t.sex]
            end
        else
            local check = ResPath.iconload(tostring(g_var.packId..sexs[t.sex]),"mainios")
            if not check then
                url = path.."0"..sexs[t.sex]
            else
                url = check
            end
        end
        t.headUrl = url
    else
        if g_var.gameFrameworkVersion >= 3 then
            if iconId >= 50 and iconId <= 99 then--是否自定义
                local id = roleId or cache.PlayerCache:getRoleId()
                local name = id..iconId..".jpg"
                local path = "photo/"..name
                local check = PathTool.CheckResDown(path)
                if check then--用本地的
                    t.headUrl = "@"..path
                else--从php那边下载一个
                    t.headUrl = ResPath.iconRes(t.sex.."00")
                    mgr.SDKMgr:downloadImage(name, function(data)
                        if data == "suc" then--成功下载
                            t.headUrl = "@"..path
                            if func then
                                func(t,id)
                            end
                        else
                            -- plog("php下载失败",ResPath.iconRes(t.sex.."00"))
                        end
                    end)
                end
            else
                t.headUrl = ResPath.iconRes(t.sex.."00")
            end
        else
            t.headUrl = ResPath.iconRes(t.sex.."00")
        end
    end
    t.viplv = math.floor(roleicon %  temp/ 1000000)--vip
    t.privilege =  tonumber(string.sub(roleicon,5,5))--仙尊
    t.pid =  tonumber(string.sub(roleicon,6,7)) --个性
    if t.pid and (t.pid < 1 or t.pid>2) then
        t.pid = 1
    end
    return t
end

function GGetMsgByRoleSex(roleicon)
    -- body
    local t = {}
    local temp = 100000000
    return math.floor(roleicon / temp)
end
--人物头像框，好友列表 实例 local t = { roleIcon,level }
function GBtnGongGongSuCai_050(obj,data,callback,target)
    -- body
    local roleicon = obj:GetChild("icon"):GetChild("n3")
    local frameIcon = obj:GetChild("n1")
    local t = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(t)
        if roleicon then
            roleicon.url = t.headUrl
        end
    end)
    roleicon.url = t.headUrl
    frameIcon.url = t.frameUrl
    local level = obj:GetChild("title")
    level.text = data.level or ""
    level.sortingOrder = 2

    local c1 = obj:GetController("c1")
    c1.selectedIndex = data.isget or 0

    --obj.data = data
    -- if callback then --此处不要注册事件！
    --     obj.onClick:Clear()
    --     obj.onClick:Add(callback,target)
    -- end
end
--去掉字符串中某些字符 如("11:22:33:44",":")
-- function GLuaReomve(str,remove)
--     local returnStr = ""
--     local data = string.split(str,remove)
--     for k,v in pairs(data) do
--          returnStr = returnStr..v
--     end
--     return returnStr
-- end
-- 查看玩家信息预留接口
function GSeePlayerInfo(pdata)
    --data 必须包含的信息 roleId  可选择传递 svrId  服务器id=0 表示自己的服务器
    local param = {
        roleId = pdata.roleId,
        svrId = pdata.svrId or 0
    }

    if tonumber(pdata.roleId)<10000 then
        GComAlter(language.gonggong58)
        return
    elseif pdata.roleId == cache.PlayerCache:getRoleId() then
        GComAlter(language.gonggong57)
        return
    end
    --printt("param",param)
    GOpenView({id = 1075,data = param,viewopen = {ViewName.TeamView} })
end

--服务器id转换
function GTransformServerId(id)
    local serverId = id
    local areaId = serverId%100000 - 10000
    -- local areaTab = { [1] = "S",
    --                   [2] = "A",
    --                   [3] = "C",
    --                   [4] = "D",
    --                   [5] = "E",
    --                   [6] = "F" }
    return (areaId%1000)..language.gonggong130;
end

--游戏清理
function GGameClear(isThorough)
    UnityCamera:CameraEctSwitch(false) --关闭尽头光晕
    mgr.TimerMgr:dispose()
    mgr.HurtMgr:dispose(isThorough)
    mgr.ViewMgr:dispose(isThorough)
    mgr.TipsMgr:dispose()
    mgr.ThingMgr:dispose(true)
    mgr.SceneMgr:dispose()
    mgr.ItemMgr:dispose()
    --UGameMgr:Dispose(isThorough)
    GameFacade:Dispose()
end
--判断该种类下有多少可合成的道具
function GGetSuitProNum(fuse,buildReds)
    local num = 0
    if fuse then
        for _,item in pairs(fuse) do
            if GIsHcData(item,buildReds) then
                num = num + 1
            end
        end
    end
    return num
end
--判断拥有该套装的哪些道具（合成）
function GGetProId(suits,buildReds)
    local items = {}
    for k,v in pairs(suits) do
        if GIsHcData(v,buildReds) then
            table.insert(items, v)
        end
    end
    return items
end
--判断可合成
function GIsHcData(data,buildReds)
    -- if data.type == 9 then
    --     return false
    -- end

    local materId = data.cost_items[1][1]
    local materData = cache.PackCache:getPackDataById(materId)
    local cost_money = data.cost_money or 0
    local bmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
    local money = cache.PlayerCache:getTypeMoney(MoneyType.copper) or 0
    local amount = materData.amount--背包数量
    local confNum = data.cost_items[1][2]
    local needlvl = data.need_lvl or 0
    local playerLv = cache.PlayerCache:getRoleLevel()
    local isHc = false
    if amount >= confNum and (money >= cost_money or bmoney >= cost_money) and playerLv >= needlvl then
        isHc = true
    end
    if data.type == 1 then
        local red = buildReds and buildReds[data.id] or 0
        if red > 0 and isHc then
            return true
        else
            return false
        end
    end
    return isHc
end
--返回星级阶数和对应星数--装备部位升星（1阶0星公式）
function GGetStarLev(starLev)
    local lev1 = math.floor(math.abs(starLev / 10)) + 1--阶数
    local lev2 = starLev % 10--星数
    if starLev > 0 and starLev / 10 == 20 then
        lev1 = 10
        lev2 = 10
    end
    return {lev1, lev2}
end
--返回星级阶数和对应星数--影卫升星（0阶0星公式）
function GGetStarLev2(starLev)
    local lev1 = 0
    local lev2 = 0
    if starLev > 0 then
        lev1 = math.floor(math.abs((starLev - 1) / 10)) --阶数
        lev2 = starLev % 10--星数
        if lev2 == 0 then
            lev2 = 10
        end
        if starLev == 100 then
            lev1 = 10
        end
    end
    return {lev1, lev2}
end
--属性按照策划设置的排序 return_t = { [1] = {102,100000},[2] = {103,100000} }
function GConfDataSort(data)
    -- body
    local return_t = {}
    if not data then
        return return_t
    end

    for k ,v in pairs(data) do
        if string.find(k,"att_") then --这个是属性
            local pro = string.split(k, "_")
            if tonumber(pro[2]) ~= 512 then
                table.insert(return_t,{tonumber(pro[2]),tonumber(v or 0)})
            end
        end
    end

    table.sort(return_t,function(a,b)
        -- body
        local asort = conf.RedPointConf:getProSort(a[1])
        local bsort = conf.RedPointConf:getProSort(b[1])
        if asort == bsort then
            return a[1]<b[1]
        else
            return asort < bsort
        end
    end)

    return return_t
end
--相同属性相加
function G_composeData(data,param)
    -- body
    for k ,v in pairs(param) do
        local falg = false
        for i , j in pairs(data) do
            if j[1] == v[1] then
                data[i][2] = j[2] + v[2]
                falg = true
            end
        end
        if not falg then
            table.insert(data,v)
        end
    end
end

--跳转指定vip
--index: 0 充值 1vip属性 2特权
--page: 特权类型 0白银 1黄金 2钻石
function GGoVipTequan(index,page)
    if g_ios_test then
        GOpenView({id = 1042})
        return
    end
    if index ~= 2 then
        mgr.ViewMgr:openView(ViewName.VipChargeView,function(view)  --EVE IOS
            proxy.VipChargeProxy:sendRechargeList()
        end,{index = index})
    else
        GOpenView({id = 1050})
    end
    --plog("前往vip特遣",index)
end

--购买指定的Item弹窗
function GGoBuyItem(data)
    -- body
    mgr.ViewMgr:openView(ViewName.Alert6,function(view)
        -- body
    end, data)
end

function GGetTimeData(time)
    local d = math.floor(time / 86400)
    local h = math.floor((time % 86400 ) / 3600)
    local m = math.floor((time % 3600) / 60)
    local s = time % 60
    return {day = d,hour = h,min = m,sec = s}
end

function GGetTimeData2(time)
    local d = math.floor(time / 86400)
    local h = math.floor((time % 86400 ) / 3600)
    local m = math.floor((time % 3600) / 60)
    local s = time % 60
    return string.format("%2d天%02d时%02d分%02d秒",d,h,m,s)
end

function GGetTimeData3(time)
    local d = math.floor(time / 86400)
    local h = math.floor((time % 86400 ) / 3600)
    local m = math.floor((time % 3600) / 60)
    local s = time % 60
    return string.format("%2d天%02d时%02d分",d,h,m)
end

function GGetTimeData4(time)

    local h = math.floor((time % 86400 ) / 3600)
    local m = math.floor((time % 3600) / 60)
    local s = time % 60
    return string.format("%02d时%02d分%02d秒",h,m,s)
end

function GTotimeString(nowtime)
    -- body
    local hour=math.floor(nowtime/3600);

    local minute=math.floor((nowtime%3600)/60);

    local second=(nowtime%3600)%60;

    return string.format("%02d:%02d:%02d",hour,minute,second)
end

function GTotimeString2(nowtime)
    -- body
    local hour=math.floor(nowtime/3600);

    local minute=math.floor((nowtime%3600)/60);

    local second=(nowtime%3600)%60;

    return string.format("%02d时%02d分%02d秒",hour,minute,second)
end

function GTotimeString3(nowtime)
    -- body
    local minute=math.floor((nowtime%3600)/60);

    local second=(nowtime%3600)%60;

    return string.format("%02d:%02d",minute,second)
end

function GTotimeString4(nowtime)
    -- body
    local hour=math.floor(nowtime/3600);

    local minute=math.floor((nowtime%3600)/60);

    local second=(nowtime%3600)%60;

    return string.format("%02d时%02d分",hour,minute)
end

function GTotimeString5(nowtime)
    -- body
    local hour=math.floor(nowtime/3600);

    local minute=math.floor((nowtime%3600)/60);

    local second=(nowtime%3600)%60;

    return string.format("%02d分%02d秒",minute,second)
end

--EVE 时间戳转换为年月日
function GTotimeString6(nowtime)
    local curTime = {}

    local timeData = os.date("*t", nowtime)

    for k,v in pairs(timeData) do
        if k == "day" or k == "year" or k == "month" then
            curTime[k] = v
        end
    end

    return curTime
end

--EVE
function GTotimeString7(time)
    local d = math.floor(time / 86400)
    local h = math.floor((time % 86400 ) / 3600)
    local m = math.floor((time % 3600) / 60)
    return string.format("%2d天%02d时%02d分",d,h,m)
end
--bxp 传时间戳转换
function GToTimeString8(time)
    local timeTab = os.date("*t",time)
    return string.format("%s年%s月%s日 %02d:%02d", timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

function GToTimeString9(time)
    local timeTab = os.date("*t",time)
    return string.format("%s/%s/%s %02d:%02d", timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

function GTotimeString10(nowtime)
    -- body
    local hour=math.floor(nowtime/3600);

    local minute=math.floor((nowtime%3600)/60);

    return string.format("%02d:%02d",hour,minute)
end

function GToTimeString11(time)
    local timeTab = os.date("*t",time)
    return string.format("%s年%s月%s日", timeTab.year,timeTab.month,timeTab.day)
end

function GToTimeString12(time)
    local timeTab = os.date("*t",time)
    return string.format("%s.%s.%s", timeTab.year,timeTab.month,timeTab.day)
end

function GTotimeString13(nowtime)
    -- body


    local second=(nowtime%3600)%60;

    return string.format("%02d",second)
end

function GToTimeString14(time)
    local timeTab = os.date("*t",time)
    return string.format("%s/%s/%s %02d:%02d:%02d", timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min),tonumber(timeTab.sec))
end
--根据年月日转换当天时间戳
function GToTimestampByDayTime(day,month,year,hour,minute)
    return os.time({day=day, month=month, year=year, hour=hour, min=minute, second=0})
end
--根据时间戳判断当前为周几
--蔡勒（Zeller）公式：w=y+[y/4]+[c/4]-2c+[26(m+1)/10]+d-1
--周日返回值为0
function GGetWeekDayByTimestamp(time)
    local timeTab = os.date("*t",time)
    local year = timeTab.year
    local y = year%100
    local c = math.floor(y/100)
    local m = timeTab.month
    local d = timeTab.day
    if m == 1 then
        m = 13
        y = y - 1
    elseif m == 2 then
        m = 14
        y = y - 1
    end
    local w = y+math.floor(y/4)+math.floor(c/4)-2*c+math.floor(26*(m+1)/10)+d-1
    return w%7
end

--判断排位赛是否到了可以组队的时间
function GPwsCanCreateTeam()
    local netTime = mgr.NetMgr:getSeverTime()
    local weekDay = GGetWeekDayByTimestamp(netTime)
    if weekDay >= 5 then

    end
end

function GOpenRuleView(id)
    local view=mgr.ViewMgr:openView(ViewName.RuleView, function(view)
        view:setData(id)
    end)
end



-----------------------------------------------功能开放等级---------------------------
--[[
    默认返回 未开启 ,不提示开放等级

    M-模块系统配置 1001 --坐骑
    --两种调用方法
    1.只检测是否开放
        local flag = GCheckView(1001)
    2.检测到未开放的时候后 是否有提示
        local param = { id = 1001 , falg = true }
        local flag = GCheckView(param)
]]
function GCheckView(param)---检测功能是否开启
    -- body
    return mgr.ModuleMgr:CheckView(param)
end
---功能跳转
--[[
    param.id 跳转系统 index 默认跳转页面
]]
function GOpenView(param)
    -- body
    mgr.ModuleMgr:OpenView(param)
end

--格式化单位算法
function GTransFormNum(num)
    if not num then return 0 end
    num = tonumber(num)
    if type(num) ~= 'number' then return num end
    local w=1000000 --万
    local y=100000000 --亿
    if num >= y then
        return string.format("%.1f",num/y)..language.gonggong53
    elseif num >= w then
        local w = math.floor(num/(w/100))

        local q = math.floor((num-w*10000)/1000)
        if q == 0 then
            return w..language.gonggong52
        else
            if num >= w then
                return w..language.gonggong52
            end
            return w.."."..q..language.gonggong52
        end
    elseif num > 0 then
        return num
    end
    return 0
end

--保留小数点后一位小数
function GTransFormNumX(num)
    if type(num) ~= 'number' then return num end
    local w=1000000 --万
    local y=100000000 --亿
    if num >= y then
        return string.format("%.1f",num/y)..language.gonggong53
    elseif num >= w then
        local w = math.floor(num/(w/100)*10)/10

        local q = math.floor((num-w*10000)/100)/10
        if q == 0 then
            return w..language.gonggong52
        else
            if num >= w then
                return w..language.gonggong52
            end
            return w.."."..q..language.gonggong52
        end
    elseif num > 0 then
        return num
    end
    return 0
end

--<=10W <=1000W
function GTransFormNum1(num)
    -- bodyplog
    --plog("需要转的数",num)
    if type(num) == 'string' then
        local len = string.utf8len(num)
        --plog("len",len)
        --local p10w = string.sub(num,-6,-1)
        --local p1000w = string.sub(num,-len,-7)

        if len<6 then
            return num
        elseif len < 8 then
            --local h1000w = string.sub(num,-len,-7) --最高位置
            --local l1000w = string.sub(num,-6,-1)
            return string.format("%.1f",tonumber(num)/10000)..language.gonggong52
        else
            --local h1000w = string.sub(num,-len,-8) --最高位置
            return math.floor(tonumber(num)/10000)..language.gonggong52
        end
    end

    if type(num) ~= 'number' then return num end
    if num <= 100000 then
        return num
    elseif num<=10000000 then
        return string.format("%.1f",num/10000000)..language.gonggong52
    else
        return math.floor(num/10000000)..language.gonggong52
    end
end

--EVE 格式化单位算法 (道具数量显示，达到6位以万a为单位)
function GTransFormNum2(num)
    if type(num) ~= 'number' then return num end
    local w = 100000 --万

    if num >= w then
        local w = math.floor(num/(w/10))

        local q = math.floor((num-w*10000)/1000)  --保留两位小数
        if q == 0 then
            return w.."a"
        else
            -- if num >= w then
            --     return w.."a"
            -- end
            return w.."."..q.."a"
        end
    elseif num > 0 then
        return num
    end
end

--EVE 用于经验丹的经验值显示
function GTransFormNumEXP(num)
    if type(num) ~= 'number' then return num end

    local a = 10000      --一万
    local w = 100000     --十万
    local b = 100000000  --一亿
    local y = 1000000000 --十亿

    if num < w then                    --小于十万，实际数量显示
        return num
    elseif w <= num and num < y then   --大于等于十万，小于十亿，用万为单位，无小数
        local temp = math.floor(num/a)
        return temp .. language.gonggong52
    else                               --大于十亿，用亿为单位，一位小数
        return string.format("%.1f", num/b)..language.gonggong53
    end
end

--为单位取整
function GTransFormNum3( num )
    -- body
    if type(num) ~= 'number' then return num end
    local w = 100000 --万

    if num >= w then
        local num = math.floor(num/(w/10)).."a"
        return num
    elseif num > 0 then
        return num
    end
    return num
end

--总属性初始值
function GAllAttiData()
    local data = {att_102 = 0, att_103 = 0, att_105 = 0, att_106 = 0, att_107 = 0, att_108 = 0}
    local t = GConfDataSort(data)
    return t
end

------时分秒
-- language.friend08 = {
--     "离线%d分钟",
--     "离线%d小时",
--     "离线%d天",
--     "离线3天以上"
-- }
--language.friend07 = 在线
function GChangeToHMS(offLineTime)

    -- body
    local textonline
    if offLineTime == 0 then
        textonline = language.friend07
    else
        if offLineTime<3600 then
            textonline = string.format(language.friend08[1],math.ceil(offLineTime/60))
        elseif offLineTime<3600*24 then
            textonline = string.format(language.friend08[2],math.ceil(offLineTime/3600))
        elseif offLineTime<3600*24*3 then
            textonline = string.format(language.friend08[3],math.ceil(offLineTime/(3600*24)))
        else
            textonline = language.friend08[4]
        end
    end
    return textonline
end
--领取经验副本首通奖励
function GFirstAwards1(passId)
    proxy.FubenProxy:send(1024102,{passId = passId})
end
--获取在线时间 单位:秒
function GgetOnLineTime()
    -- body
    local leftSeverTime = cache.VipChargeCache:getOnlineTime()--缓存的记录点
    local nowSeverTime = mgr.NetMgr:getServerTime() --当前服务器的时间点
    --在线时间
    local time= cache.PlayerCache:getRedPointById(10108)+nowSeverTime-leftSeverTime
    return time
end
--进入主线任务
function GgoToMainTask()
    if mgr.FubenMgr:isFuben(cache.PlayerCache:getSId()) then
        mgr.TaskMgr.mState = 0 --设置任务标识
        return
    end

    local data=cache.TaskCache:getData()--任务信息
    if data and #data > 0 then
        mgr.TaskMgr:setCurTaskId(data[1].taskId)
        mgr.TaskMgr.mState = 2 --设置任务标识
        mgr.TaskMgr:resumeTask()
    end
end


function GCheckMainTask()
    -- body
    if not mgr.FubenMgr:isSitDownSid() then --只有在主城，野外 和 新手地图才继续检测主线
        return false
    end

    local data=cache.TaskCache:getData()--任务信息
    if data and data[1] then
        local confData = conf.TaskConf:getTaskById(data[1].taskId)
        if not confData then
            return false
        elseif not confData.trigger_lev then
            return true
        end
        if cache.PlayerCache:getRoleLevel() < confData.trigger_lev  then
            return false
        else
            return true
        end
    else
        return false
    end

end


--进入日常任务
function GgoToDialyTask()
    if mgr.FubenMgr:isFuben(cache.PlayerCache:getSId()) then
        mgr.TaskMgr.mState = 0 --设置任务标识
        return
    end

    local data=cache.TaskCache:getdailyTasks()--任务信息
    if data and #data > 0 then
        mgr.TaskMgr:setCurTaskId(data[1].taskId)
        mgr.TaskMgr.mState = 2 --设置任务标识
        mgr.TaskMgr:resumeTask()
    end
end
--进入帮派任务
function GgoToGangTask()
    if mgr.FubenMgr:isFuben(cache.PlayerCache:getSId()) then
        mgr.TaskMgr.mState = 0 --设置任务标识
        return
    end

    local data=cache.TaskCache:getgangTasks()--任务信息
    if data and #data > 0 then
        mgr.TaskMgr:setCurTaskId(data[1].taskId)
        mgr.TaskMgr.mState = 2 --设置任务标识
        mgr.TaskMgr:resumeTask()
    end
end
--进入商会任务
function GgoToShangHuiTask()
    if mgr.FubenMgr:isFuben(cache.PlayerCache:getSId()) then
        mgr.TaskMgr.mState = 0 --设置任务标识
        return
    end

    local data=cache.TaskCache:getshangHuiTasks()--任务信息
    if data and #data > 0 then
        mgr.TaskMgr:setCurTaskId(data[1].taskId)
        mgr.TaskMgr.mState = 2 --设置任务标识
        mgr.TaskMgr:resumeTask()
    end
end

--获取下一等级的vip所需充值元宝数
function GGetVipNeedCost()
    local vipLv = cache.PlayerCache:getVipLv()
    local vipExp = cache.PlayerCache:getVipExp()
    local nextVipLv = vipLv+1
    local nextVipId = nextVipLv*1000+1
    local needCost = 0
    if nextVipLv <= 11 then
        local nextVipConf = conf.VipChargeConf:getVipAttrDataById(nextVipId)
        needCost = (nextVipConf.vip_exp - vipExp) > 0 and (nextVipConf.vip_exp - vipExp) or 0
    end
    if nextVipLv == 1 then

    end
    return needCost
end
--判断是否有特权
function GIsHaveTequan()
    for i=1,3 do
        if cache.PlayerCache:VipIsActivate(i) then
            return true
        end
    end
end
--时间转换
function GtimeTransition( timeValue )
    local day = math.floor(timeValue/(3600*24))
    local hour = math.floor((timeValue%(3600*24))/3600)
    local min = math.floor(((timeValue%(3600*24))%3600)/60)
    local second = ((timeValue%(3600*24))%3600)%60
    local str = ""
    str = string.format("%d天%d时%d分%d秒",day,hour,min,second)
    return str
end
--练级谷收益--key->1经验,key->2小伙伴经验,key->3铜钱,key->itemId
function GGetLevelAwards(incomeMap)
    local awards = {}
    for k,v in pairs(incomeMap) do--key->1经验,key->2小伙伴经验,key->3铜钱,key->itemId
        local data = {}
        if k == 1 or k == 2 then
            data = {mid = 221061001,amount = v,bind = 1}
        elseif k == 3 then
            data = {mid = 221051004,amount = v,bind = 1}
        else
            data = {mid = k, amount = v, bind = 1}
        end
        table.insert(awards, data)
    end
    return awards
end
--是否开启了首充-------现在全部返回true 不需要判断送首充是否开启
function GFirstChargeIsOpen()
    -- body
    local bol = true
    -- if cache.PlayerCache:getAttribute(30104) == 1 then
    --     bol = false
    -- end
    return bol
end

--是否充值过
function GIsCharged()
    --目前没用了
end

--获取再充献礼各档次状态 step 档次 1.2.3  返回值为true和false
function GGetFirstChargeState(step)
    -- body
    return cache.ActivityCache:get5030123(step)
end
--获取每日首充的开启时间为第几天
function GGetDayChargeDayTimes()
    local data = cache.ActivityCache:get5030121()
    return data.day
end
--获取每日首充各档次状态 step 档次 1.2.3  返回值为true和false
function GGetDayChargeState(step)
    -- body
    local data = cache.ActivityCache:get5030121()
    local bol = true
    local confData = {}
    for k,v in pairs(conf.ActivityConf:getDaliyChargeData()) do
        if data.day == v.day then
            table.insert(confData,v)
        end
    end
    table.sort(confData,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    if confData[step] then
            -- print("每日首充状态id,state",confData[step].id,data.ItemStatus[confData[step].id])
        if data.ItemStatus[confData[step].id] and data.ItemStatus[confData[step].id]== 2 then
            bol = false
        end
    end
    return bol
end
--仙尊卡是否打折
function GXianzunDiscount()
    local actData = conf.ActivityConf:getActiveById(1022)
    local time = cache.PlayerCache:getAttribute(20126) or 0
    local data = cache.ActivityCache:get5030111() or {}
    local openDay = data.openDay or 3
    if time > 0 and openDay <= actData.openDay then
        return true
    else
        return false
    end
end
--按属性的key 对应转为百分比
function GProPrecnt(key,var)
    -- body
    if not key or not var then
        return 0
    end

    local isprecent = conf.RedPointConf:getIsPrcent(key)

    if isprecent and isprecent == 1 then
        if tonumber(var)%100 == 0 then
            return tostring(tonumber(var)/100).."%"
        else
            local v = string.format("%.2f",tonumber(var)/100)
            return tonumber(v).."%"
        end
    else
        return var
    end
end

--获得一部分经验之后的等级
function GGetLevelAfterAddExp( leftLevel,leftExp,exp )
    local lvlupExp = conf.RoleConf:getRoleExpById(leftLevel)
    local exp = leftExp + exp
    while exp > lvlupExp do
        leftLevel = leftLevel + 1
        exp = exp - lvlupExp
        lvlupExp = conf.RoleConf:getRoleExpById(leftLevel)
    end
    return leftLevel,exp
end
--获取背包的装备并排序(伙伴吞噬用)
function GGetEquipData()
    -- body
    local packData = cache.PackCache:getPackData()
    local data = {}
    local colorNum = 4
    local roleLv = cache.PlayerCache:getRoleLevel()
    if roleLv >= 90 then
        colorNum = 4
    else
        colorNum = 3
    end
    local function checkHas(v)
        if not v.stage_lvl then
            return true
        else
            if v.color < colorNum then
                return true
            elseif v.color == colorNum then
                if colorNum == 4 and v.colorBNum <= 0 then
                    return true
                elseif colorNum == 3 then
                    return true
                end
            end
            return false
        end
    end
    for k,v in pairs(packData) do
        local itemType = conf.ItemConf:getType(v.mid)
        local part = conf.ItemConf:getPart(v.mid)
        if itemType == Pack.equipType  then
            local confData = clone(conf.ItemConf:getItem(v.mid))
            local flag = true
            if part == 11 or part == 12 then
                --可手动选择紫色戒指手镯
                flag = confData.color <= 4
            end
            if confData.color == 7 then--神装不能吞噬
                flag = false
            end
            if flag then
                confData.index = v.index
                confData.bind = v.bind
                confData.colorAttris = v.colorAttris
                confData.isArrow = true
                confData.colorBNum = GGetEquipMaxColorNum(v.colorAttris)
                if checkHas(confData) then
                    confData.isSelected = true
                else
                    confData.isSelected = false
                end
                table.insert(data,confData)
            end
        else
            --灵童经验丹也算入
            local _t = {PackMid.lingtong,PackMid.lingtong1,PackMid.lingtong2}
            for _,var in pairs(_t) do
                if v.mid == var then
                    local confData = clone(conf.ItemConf:getItem(v.mid))
                    confData.index = v.index
                    confData.bind = v.bind
                    confData.mid = v.mid
                    confData.amount = v.amount
                    confData.partner_exp = confData.args.arg2
                    confData.isSelected = true
                    -- for i = 1 , v.amount do
                    table.insert(data,confData)
                    break
                end
            end
        end
    end

    table.sort(data,function(a,b)
        if a.type ~= b.type then
            return a.type > b.type
        elseif a.bind ~= b.bind then
            return a.bind > b.bind
        elseif a.stage_lvl ~= b.stage_lvl then
            return a.stage_lvl > b.stage_lvl
        elseif a.color ~= b.color then
            return a.color > b.color
        elseif a.colorBNum ~= b.colorBNum then
            return a.colorBNum > b.colorBNum
        elseif a.part ~= b.part then
            return a.part < b.part
        end
    end)
    return data
end

function GGetWuXingEquipData()
    -- body
    local r_table = {}
    local data = cache.PackCache:getPackData()
    for k ,v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata.type == Pack.wuxing then
            local confData = clone(condata)
            confData.index = v.index
            confData.bind = v.bind
            confData.colorAttris = v.colorAttris
            confData.isArrow = true
            confData.colorBNum = GGetEquipMaxColorNum(v.colorAttris)
            table.insert(r_table,confData)
        end
    end
    return r_table
end

--装备极品属性星数
function GGetEquipMaxColorNum(colorAttris)
    local colorBNum = 0
    local maxColor = conf.ItemConf:getEquipColorGlobal("max_color")
    if colorAttris then
        for k,v in pairs(colorAttris) do
            local confData = conf.ItemConf:getEquipColorAttri(v.type)
            local colorAtt = confData and confData.color or 0
            if colorAtt == maxColor then--最高属性品质
                colorBNum = colorBNum + 1
            end
        end
    end
    return colorBNum
end
--时间戳转换成当天秒数
function GGetSecondBySeverTime(curTime)
    local h = os.date("%H",curTime)
    local min = os.date("%M",curTime)
    local s = os.date("%S",curTime)

    return (s+min*60+h*60*60)
end

function CClearPickView()
    --取消采集
    mgr.ViewMgr:closeView(ViewName.PickAwardsView)
end

function GCancelPick()
    if mgr.HookMgr:getPickRoleId() ~= "0" then
        print("取消采集id",mgr.HookMgr:getPickRoleId())
        proxy.FubenProxy:send(1810302,{roleId = mgr.HookMgr:getPickRoleId(),reqType = 2})
    end
    mgr.HookMgr:finishPick()
    -- mgr.HookMgr:cancelHook()
end
function CClearRankView()
    local view = mgr.ViewMgr:get(ViewName.RankMainView)
    if view then
        view:onClickClose()
    end
end

--关闭系统引导
function GCloseXinshouView()
    local v = mgr.ViewMgr:get(ViewName.XinShouView)
    if v then
        v.data = nil
        v.modelId = nil
        v:closeView()
    end
end

function GCharsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
         return 3
    elseif char > 192 then
         return 2
    else
         return 1
    end
end

function GUtf8sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + GCharsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
       local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + GCharsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

function GCloseAdvTip(modelId)
    local view = mgr.ViewMgr:get(ViewName.AdvancedTipView)
    if view then
        view:closeModule(modelId)
    end
end

function GlihunRequst()
    -- body
    local param = {}
    param.type = 2
    param.richtext = string.format(language.kuafu46,cache.PlayerCache:getCoupleName())
    param.sure = function()
        -- body
        proxy.MarryProxy:sendMsg(1390105, {reqType = 1})
    end
    param.sureIcon = "ui://alert/jiehun_079"
    --
    param.cancel = function()
        -- body
        proxy.MarryProxy:sendMsg(1390105, {reqType = 2})
    end
    param.cancelIcon = "ui://alert/jiehun_080"
    param.closefun = function()
        -- body
        proxy.MarryProxy:sendMsg(1390105, {reqType = 2})
    end
    GComAlter(param)
end

--全民修炼传送坐标点随机
function GGetMajorPoint()
    local pointConf = conf.SysConf:getValue("practice_transfer_point")
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    local point = pointConf[math.random(1,#pointConf)]
    return point
end

--判断是否打开祝福弹框
function GIsOpenWishPop(id)
    local scoreAwards = conf.ActivityConf:getValue("dscj_score_consume_award")
    local max = {
        [30119] = conf.ActivityConf:getValue("active_red_bag_top"),--活跃红包进度
        [30120] = 12,--夏日抽奖进度
        [30121] = conf.ActivityConf:getValue("smash_egg_limit_count"),--砸蛋进度
        [30122] = 7,--宝树进度
        [30123] = scoreAwards[2][5],--点石成金进度
    }

    if cache.PlayerCache:getAttribute(id) > 0 and cache.PlayerCache:getAttribute(id) < max[id] and not cache.TaskCache:isOnlyMain() then
        local param = {}
        param.type = 7
        param.index = id--
        -- param.max = conf.ActivityConf:getValue("active_red_bag_top")
        param.radio = cache.ActivityCache:getIsZhuFu(param.index)
        param.sure = function(flag)
            -- body
            local data = {}
            data.index = param.index
            cache.ActivityCache:setIsZhuFu(data.index,flag)

            data.id = language.activetips1[param.index][2]

            GOpenView(data)
        end
        param.cancel = function( flag )
            -- body
            cache.ActivityCache:setIsZhuFu(param.index,flag)
        end
        if not param.radio then
            GComAlter(param)
        end
    end
end
--计算仙装神装能否合成
function GGetCompseXianGodNum(_part)
    local color = 6--背包内品质是6--合成配置品质是7
    local xianGodNeedpart = conf.ForgingConf:getXianGodNeedPart()
    local xianGod = cache.ComposeCache:getXianGodData()
    if not xianGod then
        return 0
    end
    if not xianGod[_part] then
        return 0
    end
    if not xianGod[_part][color] then
        return 0
    end
    --部位同阶的个数
    local partJieNum = {}--{"部位"={"阶"="个数"}}
    if not partJieNum[_part] then
        partJieNum[_part] = {}
    end
    for k,needpart in pairs(xianGodNeedpart[_part]) do
        if xianGod[needpart] and xianGod[needpart][color] then
            for i,j in pairs(xianGod[needpart][color]) do--i是阶
                if not partJieNum[_part][i] then
                    partJieNum[_part][i] = #j
                else
                    partJieNum[_part][i] = partJieNum[_part][i]+ #j
                end
            end
        end
    end
    for jie,sameJieNum in pairs(partJieNum[_part]) do
        if sameJieNum >= 3 then
            local id = ((((100+Pack.xianzhuang)*100+color+1)*100+jie)*100+_part)
            local godEquipCost = conf.ForgingConf:getXianEquipCompose(id)
            if not godEquipCost then
                return
            end
            local listnumber = {}
            if godEquipCost.cost_item then
                for _,j in pairs(godEquipCost.cost_item) do
                    local _packdata = cache.PackCache:getPackDataById(j[1])
                    table.insert(listnumber,math.floor(_packdata.amount/j[2]))
                end
                local canComposeNum = math.min(unpack(listnumber))
                if canComposeNum > 0 then
                    return canComposeNum
                end
            end
        end
    end
    return 0
end
--计算普通神兽装备能否合成
function GGetCompseShenShouNum(p_color)
    -- body
    local data = cache.PackCache:getPackDataByType(Pack.shenshouEquipType)
    local count = {}
    local gg = conf.ForgingConf:getComposeValue("shenshou_equip_color_xin_jie")
    for k , v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata
        and condata.color >= gg[1]
        and condata.stage_lvl >= gg[3]
        and  mgr.ItemMgr:getColorBNum(v) == gg[2] then
            local flag = false
            if not p_color then
                flag = true
            elseif p_color and p_color == condata.color then
                flag = true
            end
            if flag then
                if not count[condata.color] then
                    count[condata.color] = 0
                end
                count[condata.color] = count[condata.color] + 1

                if count[condata.color] >= 3 then
                    return 1
                end
            end
        end
    end
    return 0
end
--计算神兽神装能否合成
function GGetCompseShenShouGod()
    local aa = conf.ForgingConf:getComposeValue("shenshou_god_equip_color_xin_jie")
    local data = cache.PackCache:getPackDataByType(Pack.shenshouEquipType)
    local count = {}
    for k,v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata and condata.color == aa[1] and condata.stage_lvl >= aa[3] and  mgr.ItemMgr:getColorBNum(v) == aa[2] then
            if not count[condata.color] then
                count[condata.color] = 0
            end
            count[condata.color] = count[condata.color] + 1
            if count[condata.color] >= 3 then--同品质大于3件
                local id = ((100+condata.color+1)*100+condata.stage_lvl)--目标品质是7所以color+1
                local godEquipCost = conf.ShenShouConf:getShenShouGodEquipCompose2(id)
                if not godEquipCost then
                    print("@策划  神兽配置神装表没有",id,"此id不包含部位")
                    return 0
                end
                for _,j in pairs(godEquipCost) do
                    local mid = j.cost_item[1][1]
                    local packData = cache.PackCache:getPackDataById(mid)
                    if packData.amount >= j.cost_item[1][2] then
                        return 1
                    end
                end

            end
        end
    end
    return 0
end
--计算能神装4合1能否合成
function GGetCompseGod1()
    local _cc = conf.ForgingConf:getComposeValue("compose_new_part")
    local _t = {}
    for k ,v in pairs(_cc) do
        _t[v] = true --需要是指定的部位
    end
    local data = cache.PackCache:getPackData()
    local _aa = conf.ForgingConf:getComposeValue("compose_god_color_xin_jie")
    local count = {}
    for k , v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata and condata.type == Pack.equipType
        and not _t[condata.part]
        and condata.color == _aa[1]
        and condata.stage_lvl >= _aa[3]
        and mgr.ItemMgr:getColorBNum(v) == _aa[2] then
            if not count[condata.color] then
                count[condata.color] = {}
            end
            if not count[condata.color][condata.stage_lvl] then
                count[condata.color][condata.stage_lvl] = 0
            end
            count[condata.color][condata.stage_lvl] = count[condata.color][condata.stage_lvl] + 1
            if count[condata.color][condata.stage_lvl] >= 3 then--同阶的装备大于3个
                local id = ((100+condata.color+1)*100+condata.stage_lvl)
                local godEquipCost = conf.ForgingConf:getGodEquipCompose2(id)
                if not godEquipCost then
                    print("@策划  合成配置神装表没有",id,"此id不包含部位")
                    return 0
                end
                for k,v in pairs(godEquipCost) do
                    local mid = v.cost_item[1][1]
                    local packData = cache.PackCache:getPackDataById(mid)
                    if packData.amount >= v.cost_item[1][2] then
                        return 1
                    end
                end
            end
        end
    end
    return 0
end
--计算能否合成3星元素
function GGetElementCompse()
    local count = {}
    local _ff = conf.ForgingConf:getComposeValue("compose_eight_gates_color_xin_jie")
    local data = cache.PackCache:getElementPackData()
    for k,v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata and condata.color >= _ff[1] and mgr.ItemMgr:getColorBNum(v) == _ff[2] and condata.stage_lvl >= _ff[3] then--元素
            if not count[condata.color] then
                count[condata.color] = 0
            end
            count[condata.color] = count[condata.color] + 1
            if count[condata.color] >= 3 then
                return 1
            end
        end
    end
    return 0
end
--计算能否合成
function GGetCompseNum(p_color)
    -- body
    local _cc = conf.ForgingConf:getComposeValue("compose_new_part")
    local _t = {}
    for k ,v in pairs(_cc) do
        _t[v] = true --需要是指定的部位
    end
    local data = cache.PackCache:getPackData()
    local count = {}
    for k , v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)

        if condata and condata.type == Pack.equipType
        and not _t[condata.part]
        and condata.color >= conf.ForgingConf:getComposeValue("equip_compose_min_color")
        and  condata.stage_lvl >= conf.ForgingConf:getComposeValue("equip_compose_min_jie")
        and  mgr.ItemMgr:getColorBNum(v) == conf.ForgingConf:getComposeValue("equip_compose_min_star") then
            --橙色基本条件
            local flag = false
            if not p_color then
                flag = true
            elseif p_color and p_color == condata.color then
                flag = true
            end
            if flag then
                if not count[condata.color] then
                    count[condata.color] = {}
                end
                if not count[condata.color][condata.stage_lvl] then
                    count[condata.color][condata.stage_lvl] = 0
                end
                count[condata.color][condata.stage_lvl] = count[condata.color][condata.stage_lvl] + 1
                if count[condata.color][condata.stage_lvl] >= 5 then
                    return 1
                end
            end
        end
    end
    return 0
end

--计算能否合成
function GGetCompseXianNum(p_color)
    -- body
    local _cc = conf.ForgingConf:getComposeValue("compose_new_part_xian")
    local _t = {}
    for k ,v in pairs(_cc) do
        _t[v] = true --需要是指定的部位
    end
    local data = cache.PackCache:getPackDataByType(Pack.xianzhuang)
    local count = {}
    for k , v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)

        if condata and condata.type == Pack.xianzhuang
        and not _t[condata.part]
        and condata.color >= conf.ForgingConf:getComposeValue("equip_compose_min_color_xian")
        and  condata.stage_lvl >= conf.ForgingConf:getComposeValue("equip_compose_min_jie_xian")
        and  mgr.ItemMgr:getColorBNum(v) == conf.ForgingConf:getComposeValue("equip_compose_min_star_xian") then
            --橙色基本条件
            local flag = false
            if not p_color then
                flag = true
            elseif p_color and p_color == condata.color then
                flag = true
            end
            if flag then
                if not count[condata.color] then
                    count[condata.color] = {}
                end
                if not count[condata.color][condata.stage_lvl] then
                    count[condata.color][condata.stage_lvl] = 0
                end
                count[condata.color][condata.stage_lvl] = count[condata.color][condata.stage_lvl] + 1
                if count[condata.color][condata.stage_lvl] >= 3 then
                    return 1
                end
            end
        end
    end
    return 0
end

--计算能否合成
function GGetCompsePetNum(p_color)
    -- body
    local data = cache.PackCache:getPackDataByType(Pack.equippetType)
    local count = {}
    local gg = conf.ForgingConf:getComposeValue("compose_pet_color_xin")
    for k , v in pairs(data) do

        local condata = conf.ItemConf:getItem(v.mid)
        --print("k",k,condata.color,condata.stage_lvl,mgr.ItemMgr:getColorBNum(v))
        if condata
        and condata.color >= gg[1]
        and  mgr.ItemMgr:getColorBNum(v) == gg[2] then
            --橙色基本条件
            local flag = false
            if not p_color then
                flag = true
            elseif p_color and p_color == condata.color then
                flag = true
            end
            --print("ddd",flag)
            if flag then
                if not count[condata.color] then
                    count[condata.color] = 0
                end
                count[condata.color] = count[condata.color] + 1

                if count[condata.color] >= 5 then
                    return 1
                end
            end
        end
    end
    return 0
end

function GGetCompseWuxingNum_1( part )
    -- body
    local data = {}
    local wuxingdata = cache.PackCache:getPackDataByType(Pack.wuxing)
    for k ,v in pairs(wuxingdata) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata.color == 6 and mgr.ItemMgr:getColorBNum(v) == 3 then
            if not data[condata.part] then
                data[condata.part] = 0
            end
            data[condata.part] = data[condata.part] + 1
        end
    end

    if data[part] and data[part]>=2 then
        --计算消耗
        local _compose = conf.WuxingConf:getEquipCompose(2,6,3)
        if _compose.cost_money[2] > cache.PlayerCache:getTypeMoney(_compose.cost_money[1]) then
            return 0
        end
        return 1
    end

    return 0
end

--计算能五行否合成
function GGetCompseWuxingNum(part,color)
    -- body
    local data = {}
    local wuxingdata = cache.PackCache:getPackDataByType(Pack.wuxing)

    local checkinfowuxing =  {}
    local _dd = conf.ForgingConf:getComposeValue("compose_wuxing_color_xin")
    for k , v in pairs(_dd) do
        checkinfowuxing[v[1]] = v
    end
    for k ,v in pairs(wuxingdata) do
        local condata = conf.ItemConf:getItem(v.mid)
        if checkinfowuxing[condata.color]
        and condata.color >= checkinfowuxing[condata.color][1]
        and mgr.ItemMgr:getColorBNum(v) == checkinfowuxing[condata.color][2] then
            if not data[condata.part] then
                data[condata.part] = {}
            end
            if not data[condata.part][condata.color] then
                data[condata.part][condata.color] = {}
            end
            table.insert(data[condata.part][condata.color],v)

            if part == condata.part and color == condata.color then
                if #data[condata.part][condata.color] >= 5 then
                    --计算消耗
                    local _compose = conf.WuxingConf:getEquipCompose(1,condata.color,2)
                    local need = cache.PackCache:getPackDataById(_compose.cost_item[1])
                    if _compose.cost_item[2] >  need.amount then
                        return 0
                    end
                    return 1
                end
            end
        end
    end

    return 0
end
--计算项链护符合成、戒指手镯合成 是否有红点
function GGetCompseNum1(part)
    -- body
    --项链护符合成2、合成规则
-- //5件同阶的蓝色手镯（戒指），可合成同阶的紫色手镯（戒指）
-- //紫色不可合成橙色
-- //5件同阶的橙色2星手镯（戒指），可合成同阶的红色2星手镯
-- //5件同阶的红色2星手镯（戒指），可合成同阶的红色3星手镯
-- // 神装项链，护符 材料道具B+三件同阶同部位红色三星装备
-- // 神装戒指手镯 材料道具C+材料道具D+一件同阶同部位红色三星装备
    local _t = {}
    if part then
        --只检测指定部位
        _t[part] = true
    else
        local _cc = conf.ForgingConf:getComposeValue("compose_new_part")
        for k ,v in pairs(_cc) do
            _t[v] = true --需要是指定的部位
        end
    end
    local _info =  {}
    local _dd = conf.ForgingConf:getComposeValue("compose_new_color_xin_jie")
    for k , v in pairs(_dd) do
        _info[v[1]] = v
    end

    local _aa = conf.ForgingConf:getComposeValue("compose_god_color_xin_jie")
    local data = cache.PackCache:getPackData()
    local count = {}
    for k , v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata and condata.type == Pack.equipType and _t[condata.part]
            and condata.color == _aa[1]
            and condata.stage_lvl >= _aa[3]
            and mgr.ItemMgr:getColorBNum(v) == _aa[2] then
                if not count[condata.color] then
                    count[condata.color] = {}
                end
                if not count[condata.color][condata.stage_lvl] then
                    count[condata.color][condata.stage_lvl] = 0
                end
                count[condata.color][condata.stage_lvl] = count[condata.color][condata.stage_lvl] + 1
                local _num = 1
                if condata.part == 11 or condata.part == 12 then
                    _num = 1
                elseif condata.part == 9 or condata.part == 10 then
                    _num = 3
                end
                if count[condata.color][condata.stage_lvl] >= _num then--同阶的装备大于3个
                    local id = ((100+condata.color+1)*100+condata.stage_lvl)*100+condata.part
                    local godEquipCost = conf.ForgingConf:getGodEquipCompose(id)
                    if not godEquipCost then
                        print("@策划  合成配置神装表没有",id)
                        return 0
                    end
                    local listnumber = {}
                    for _,j in pairs(godEquipCost.cost_item) do
                        local _packdata = cache.PackCache:getPackDataById(j[1])
                        table.insert(listnumber,math.floor(_packdata.amount/j[2]))
                    end
                    local canComposeNum = math.min(unpack(listnumber))
                    if canComposeNum > 0 then--只有找到符合条件的合成选项才能renturn
                        return canComposeNum
                    end
                    -- return math.min(unpack(listnumber))
                end
        else
            if condata and condata.type == Pack.equipType and _t[condata.part]  then
                if _info[condata.color]
                and condata.stage_lvl >= _info[condata.color][3]
                and mgr.ItemMgr:getColorBNum(v) == _info[condata.color][2] then
                    if condata.color == 3
                    and (condata.part == 9 or condata.part == 10) then
                        -- 9 10 号部位不能合紫色的
                    else
                        if not count[condata.color] then
                            count[condata.color] = {}
                        end
                        if not count[condata.color][condata.stage_lvl] then
                            count[condata.color][condata.stage_lvl] = 0
                        end
                        count[condata.color][condata.stage_lvl] = count[condata.color][condata.stage_lvl] +1
                        if count[condata.color][condata.stage_lvl] >= 5 then
                            return 1
                        end
                    end
                end
            end
        end
    end
    return 0
end

function GGetCompseNum2(part)
    -- body
    local _t = {}
    if part then
        --只检测指定部位
        _t[part] = true
    else
        local _cc = conf.ForgingConf:getComposeValue("compose_new_part_xian")
        for k ,v in pairs(_cc) do
            _t[v] = true --需要是指定的部位
        end
    end
    local _info =  {}
    local _dd = conf.ForgingConf:getComposeValue("compose_new_color_xin_jie_xian")
    for k , v in pairs(_dd) do
        _info[v[1]] = v
    end

    local data = cache.PackCache:getPackDataByType(Pack.xianzhuang) --cache.PackCache:getPackData()
    local count = {}
    for k , v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata and condata.type == Pack.xianzhuang and _t[condata.part]  then
            if _info[condata.color]
            and condata.stage_lvl >= _info[condata.color][3]
            and mgr.ItemMgr:getColorBNum(v) == _info[condata.color][2] then
                if not count[condata.color] then
                    count[condata.color] = {}
                end
                if not count[condata.color][condata.stage_lvl] then
                    count[condata.color][condata.stage_lvl] = 0
                end
                count[condata.color][condata.stage_lvl] = count[condata.color][condata.stage_lvl] +1
                if count[condata.color][condata.stage_lvl] >= 3 then
                    return 1
                end
            end
        end
    end
    return 0
end



function GCloseBossHpView()
    local view = mgr.ViewMgr:get(ViewName.BossHpView)
    if view then
        view:close()
    end
end

--是否是野外场景
function GIsYeWaiScene()
    local sId = cache.PlayerCache:getSId()
    local sceneConfig = conf.SceneConf:getSceneById(sId)
    if sceneConfig.kind == 2 then
        return true
    else
        return false
    end
end

--是否是仙盟驻地且开启圣火活动
function GIsXianMengStation()
    local sId = cache.PlayerCache:getSId()
    local endtime = cache.PlayerCache:getRedPointById(20150)
    local curTime = mgr.NetMgr:getServerTime()
    local sceneConfig = conf.SceneConf:getSceneById(sId)
    if sceneConfig.kind == 22 and (endtime > 0 and curTime-endtime <= 0) then
        return true
    else
        return false
    end
end
--仙盟圣火活动是否开启
function GIsXianMengFlameTime()
    local endtime = cache.PlayerCache:getRedPointById(20150)
    local curTime = mgr.NetMgr:getServerTime()
    if endtime > 0 and curTime-endtime <= 0 then
        return true
    end
    return false
end
--EVE 奖励物品列表。listView:列表   confData:奖励配置 (只能用于只显示物品icon的列表)
function GSetAwards(listView,confData)
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
--获取可吞噬装备
function GCheckTunShiEquip()
    local colorNum = 4
    local roleLv = cache.PlayerCache:getRoleLevel()
    if roleLv >= 90 then
        colorNum = 4
    else
        colorNum = 3
    end
    local function checkHas(v)
        if not v.stage_lvl then
            return true
        else
            if v.color < colorNum then
                return true
            elseif v.color == colorNum then
                if colorNum == 4 and v.colorBNum <= 0 then
                    return true
                elseif colorNum == 3 then
                    return true
                end
            end
        end
    end
    local packData = cache.PackCache:getPackData()
    for k,v in pairs(packData) do
        local itemType = conf.ItemConf:getType(v.mid)
        local condata = conf.ItemConf:getItem(v.mid)
        if itemType == Pack.equipType then
            -- printt("背包装备",v)
            packData[k].stage_lvl = condata.stage_lvl
            packData[k].color = condata.color
            packData[k].colorBNum = GGetEquipMaxColorNum(v.colorAttris)
            if checkHas(v) then
                return true
            end
        else
            --灵童经验丹也算入
            local _t = {PackMid.lingtong,PackMid.lingtong1,PackMid.lingtong2}
            for _,var in pairs(_t) do
                if v.mid == var then
                    if checkHas(v) then
                        return true
                    end
                    break
                end
            end
        end
    end
    return false
end

--仙盟boss喂养红点判断
function GFeedBoss()
    local confData = conf.BangPaiConf:getExpAndRewardById(1)
    local ownedCount = cache.PackCache:getPackDataById(confData.cost_item[1]).amount --已经拥有的道具数量
    if ownedCount >= confData.cost_item[2] then
        return true
    end
    return false
end

function GGetDujieSceneId()
    local activeLv = cache.PlayerCache:getSkins(14) or 0
    local confData = conf.ImmortalityConf:getAttrDataByLv(activeLv+1)
    local step = confData and confData.step or 0
    local period = confData and confData.period or 0
    local sceneId = Fuben.dujie + (step - 1) * 3 + period - 2
    local sign = cache.PlayerCache:getAttribute(20139)
    if confData then
        if sign == 0 and activeLv > 1 and activeLv%10 == 0 then
            return sceneId
        end
    end
    return 0
end

function GGetisOperationTeam()
    local sId = cache.PlayerCache:getSId()
    local sceneData = conf.SceneConf:getSceneById(sId)
    local isOperationTeam = sceneData and sceneData.is_operation_team or 0
    return isOperationTeam
end

--EVE 判断场景中是否有怪物
function GAreThereMonsters()
    local things = mgr.ThingMgr:objsByType(ThingType.monster)
    for k, v in pairs(things) do
        if v:canBeSelect() then
            -- return v.data.mId, v:getPosition(), k
            return true
        end
    end
    return false
end
--关闭血包提示界面
function GCloseBloodBuyView()
    local view = mgr.ViewMgr:get(ViewName.BloodBuyView)
    if view then
        view:closeView()
    end
end

--断引导的时候做的事情
function GGuildeLevel()
    -- body
    mgr.ViewMgr:openView2(ViewName.TaskGuide, data)
end

--家园组件升级条件判定 --flag 是否飘字
function G_HomeComponstCon(condata,data,flag)
    -- body
    if condata.con then
        for k ,v in pairs(condata.con) do
            if v[1] == 1001 then
                if data.houseLev < v[2] then
                    if flag then
                        GComAlter(language.home68.. string.format(language.home65[v[1]], v[2]) )
                    end
                    return false
                end
            elseif v[1] == 2001  then
                --围墙
                if data.wallLev < v[2] then
                    if flag then
                        GComAlter(language.home68.. string.format(language.home65[v[1]], v[2]) )
                    end
                    return false
                end
            elseif v[1] == 3001 then
                --温泉
                if data.hotSpringLev < v[2] then
                    if flag then
                        GComAlter(language.home68.. string.format(language.home65[v[1]], v[2]) )
                    end
                    return false
                end
            elseif v[1] == 4001 then
                --兽园
                if data.zooLev < v[2] then
                    if flag then
                        GComAlter(language.home68.. string.format(language.home65[v[1]], v[2]) )
                    end
                    return false
                end
            end
        end
    end

    return true
end

function G_HomeWater()
    -- body
    local cc = 0
    if cache.HomeCache:getisSelfHome() then
        cc = conf.HomeConf:getValue("water_self_count") - cache.HomeCache:getWaterSelf()
    else
        cc = conf.HomeConf:getValue("water_other_count") - cache.HomeCache:getOtherSelf()
    end
    return cc

end

--计算进阶红点
function G_equip_jie(part)
    -- body
    local equip_jinjie_min_cfg = conf.ForgingConf:getValue("equip_jinjie_min_cfg")
    local list = conf.ForgingConf:getDataByType(2)
    for h , g in pairs(list) do
        local flag = false
        if part then
            if g.part == part then
                flag = true
            end
        else
            flag = true
        end
        if flag then
            local data = cache.PackCache:getEquipDataByPart(g.part)
            if data then
                local condata = conf.ItemConf:getItem(data.mid)
                --进阶消耗
                if condata.stage_lvl+1 <= 9
                and condata.stage_lvl >= equip_jinjie_min_cfg[1]
                and condata.color >= equip_jinjie_min_cfg[2]
                and mgr.ItemMgr:getColorBNum(data) >= equip_jinjie_min_cfg[3] then
                    local needconf = conf.ForgingConf:getJingjieById(data.mid)
                    if needconf then
                        local mid = needconf.cost_item[1][1]
                        local amount = needconf.cost_item[1][2]

                        local _cc = conf.ItemConf:getItem(needconf.upmid)
                        if _cc.lvl <= cache.PlayerCache:getRoleLevel() then
                            local packdata = cache.PackCache:getPackDataById(mid)
                            if packdata.amount>= amount then
                                return 1
                            end
                        end
                    end
                end
            end
        end
    end

    return 0
end

function G_equip_zhuxin(part)
    -- body
    local equip_zuxing_min_cfg = conf.ForgingConf:getValue("equip_zuxing_min_cfg")
    local list = conf.ForgingConf:getDataByType(1)
    for h , g in pairs(list) do
        local flag = false
        if part then
            if g.part == part then
                flag = true
            end
        else
            flag = true
        end
        if flag then
            local data = cache.PackCache:getEquipDataByPart(g.part)
            if data then
                local condata = conf.ItemConf:getItem(data.mid)

                if condata.stage_lvl >= equip_zuxing_min_cfg[1]
                and condata.color >= equip_zuxing_min_cfg[2]
                and mgr.ItemMgr:getColorBNum(data) == equip_zuxing_min_cfg[3] then
                    local needconf = conf.ForgingConf:getZhuxinById(data.mid)
                    if needconf then
                        local mid = needconf.cost_item[1][1]
                        local amount = needconf.cost_item[1][2]
                        local packdata = cache.PackCache:getPackDataById(mid)
                        if packdata.amount>= amount then
                            --道具足够
                            local pack = cache.PackCache:getPackData()
                            for k ,v in pairs(pack) do
                                local _confdata = conf.ItemConf:getItem(v.mid)
                                if Pack.equipType == _confdata.type
                                and _confdata.part == condata.part
                                and mgr.ItemMgr:getColorBNum(v) == 1
                                and condata.stage_lvl == _confdata.stage_lvl
                                and condata.color == _confdata.color then
                                    return 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return 0
end
--魅力沙滩赠送道具是否足够
function G_BeachItem( )
    -- body
    return cache.BeachCache:isEnough()
end
--主界面任务面板显隐
function G_SetMainView(visible)
    local mv = mgr.ViewMgr:get(ViewName.MainView)
    if mv then
        mv.view:GetChild("n208").visible = visible
        mv.view:GetChild("n209").visible = visible
        mv.view:GetChild("n224").visible = visible
        -- mv:setTeamBtnVisible(visible)
        local selectedIndex = 1
        if visible then
            selectedIndex = 0
        end
        mv.c6.selectedIndex = selectedIndex
        mv.c4.selectedIndex = selectedIndex
        mv.c7.selectedIndex = selectedIndex
        if mv.taskorTeam then
            mv.taskorTeam:gotoWar()
        end
    end
end

--平台是否有聊天限制
function G_AgentChatLimit()
    local confData = conf.ChatConf:getAgentChatById(g_var.channelId)
    if confData and confData.open_lev then
        return true
    end
    return false
end
--平台是否有交易行限制
function G_IsTransactionLimit()
    local var = cache.PlayerCache:getRedPointById(10327)
    local limitData = conf.SysConf:getValue("trade_plat_limit")
    local flag = false
    for k,v in pairs(limitData) do
        if var == v then
            flag = true
            break
        end
    end
    return flag
end

--判断是否是工会平台id
function G_IsGongHuiID(varId)
    if varId >= 300 and varId <= 400 then
        return true
    else
        return false
    end
end

--计算五行强化红点
function G_RedWuXingQianghua(part)
    -- body
    local data = cache.PackCache:getJianLingquipData(Pack.JianLing)
    local partdata = {}
    local maxConf = conf.WuxingConf:getValue("color_max_streng_lev")
    for k ,v in pairs(data) do
        local confdata = conf.ItemConf:getItem(v.mid)
        local info = cache.AwakenCache:getJianLingByPart(confdata.part)
        --计算是否能够升级
        local curstrenLev = info.strenLev
        local nextstrenLev = curstrenLev + 1
        local maxstrenLev = 0
        for k ,v in pairs(maxConf) do
            if v[1] == confdata.color then
                maxstrenLev = v[2]
                break
            end
        end
        if nextstrenLev < maxstrenLev then
            local curdata = conf.WuxingConf:getStrenInfo(confdata.part,confdata.color,curstrenLev)
            if cache.PlayerCache:getTypeMoney(MoneyType.lj) >= curdata.cost_lhjj then
                partdata[confdata.part] = 1
            end
        end
    end

    if part then
        return partdata[part] or 0
    else
        for i = 1 , 5 do
            if partdata[i] then
                return 1
            end
        end
        return 0
    end
end
--    local bindset = CreateBindingSet()
--    bindset:bind("var_name",function(new,old)
--        -- body
--        print("old",old)
--        print("new",new)
--    end)
--    bindset:just_set("var_name",10) --赋值但是没有 function 的回调
--    bindset.var_name = 10 --赋值 会进入function
--    bind:paramer_set("var_name",10,...)--赋值但是没有 function 的回调 额外传递参数
function CreateBindingSet()
    local class_get_set = require "game.util.class_get_set"
    local bindingset = class_get_set("BindingSet")
    return bindingset.new()
end

function CheckifKuaFu(roleId) -- 检测玩家是否跨服 roleId:角色id
    local uId = string.sub(roleId,1,3)
    if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
        return true
    else
        return false
    end
end
--根据圣印id获取已经激活的具有递进关系的套装件数
function GGetActShengYinSuitByid(id)
    local data = cache.PackCache:getShengYinEquipData()
    local extType = conf.ItemConf:getRedBagType(id)
    local suitType = math.floor(extType/100)
    local suitId = extType % 100
    local openSuitNum = 0--已激活套装件数
    if extType ~= 0 then--存在套装
        for k,v in pairs(data) do
            local tempExtType = conf.ItemConf:getRedBagType(v.mid)--已装备的
            if tempExtType and tempExtType ~= 0 then
                local equippedExtType = math.floor(tempExtType/100)
                local equippedSuitId = tempExtType % 100
                if suitType == equippedExtType and suitId <= equippedSuitId  then
                    openSuitNum = openSuitNum + 1
                end
            end
        end
    end
    return openSuitNum
end
--根据圣印套装类型获取已经激活的具有递进关系的套装件数
function GGetActShengYinSuitByExtType(type)
    local actSuitNum = 0--已激活套装件数
    local suitType = math.floor(type/100)
    local suitId = type % 100
    local data = cache.PackCache:getShengYinEquipData()
    for k,v in pairs(data) do
        local tempExtType = conf.ItemConf:getRedBagType(v.mid)--已装备的
        if tempExtType and tempExtType ~= 0 then
            local equippedExtType = math.floor(tempExtType/100)
            local equippedSuitId = tempExtType % 100
            if equippedExtType == suitType and suitId <= equippedSuitId then
                actSuitNum = actSuitNum + 1
            end
        end
    end
    return actSuitNum
end

--根据圣装星數返回激活件数
function CGActShengZhuangSuitBystartNum(startNum)
    local  data = cache.PackCache:getShengZhuangEquipData()
    local t = {}
    t.num0 = 0
    t.num1 = 0
    t.num2 = 0
    t.num3 = 0
    for k,v in pairs(data) do
       -- local start = conf.ItemConf:getEquipStar(v.mid) or 0
        local start = mgr.ItemMgr:getColorBNum(v)
        t.num0 = t.num0 + 1
        t.num1 = t.num1 + (start >= 1 and 1 or 0)
        t.num2 = t.num2 + (start >= 2 and 1 or 0)
        t.num3 = t.num3 + (start >= 3 and 1 or 0)
    end
    if startNum then
        return t["num"..startNum]
    end
    return t
end

function GGetCompseSZByMid(mid) -- 根據圣裝背包寸的碎片數量計算可以合成多少個
    -- body
    local packdata = cache.PackCache:getShengZhuangById(mid) --圣装背包存了多少个该id的碎片数据
    if packdata.amount == 0 then
        return 0
    end
    local number = packdata.amount
    local condata = conf.AwakenConf:getJScompose(mid)
    number = math.floor(number/condata.need_num[2])

    return number
end
function GGetCompseSYByMid(mid)
    -- body
    local packdata = cache.PackCache:getShengYinById(mid)
    if packdata.amount == 0 then
        return 0
    end
    local number = packdata.amount
    local condata = conf.ShengYinConf:getSycompose(mid)
    number = math.floor(number/condata.need_num)
    --检测合成材料
    if condata.cost_item then
        local listnumber = {}
        for k , v in pairs(condata.cost_item) do
            local _packdata = cache.PackCache:getPackDataById(v[1])
            table.insert(listnumber,math.floor(_packdata.amount/v[2]))
        end
        number = math.min(unpack(listnumber),number)
    end

    if condata.cost_money and condata.cost_money>0 then
        local var = cache.PlayerCache:getTypeMoney(MoneyType.copper) + cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)
        number = math.min(math.floor(var/condata.cost_money),number)
    end
    return number
end

function GGetCompseSY()
    -- body
    local condata = conf.ForgingConf:getSuitFuseData(19)
    for k ,v in pairs(condata) do
        if GGetCompseSYByMid(v.id)>0 then
            return 1
        end
    end
    return 0
end
--生魂红点
function GGetShengHunRed()
    local redNum = 0

    local shData = conf.ShengYinConf:getShengHunData()

    local roleLv = cache.PlayerCache:getRoleLevel()
    local temp = {}
    for k,v in pairs(shData) do
        table.sort(v.use_max ,function (a,b)
            return a[1] > b[1]
        end)
        for i,j in pairs(v.use_max) do
            if roleLv >= j[1] then
                max = j[2]
                table.insert(temp,{v.id,max})
                break
            end
        end
    end
    -- printt("gfunction",temp)
    local shInfos = cache.AwakenCache:getShenghunInfo()
    for k,v in pairs(temp) do
        local amount = cache.PackCache:getPackDataById(v[1]).amount
        if shInfos and shInfos[v[1]] then
            local used = shInfos[v[1]]
            if used < v[2] then
                redNum = redNum + amount
            end
        else
            redNum = redNum + amount
        end
    end
    -- print("生魂红点",redNum)
    return redNum
end
--圣印强化红点
function GGetSYstrengRed()
    local redNum = 0
    local equipData = cache.PackCache:getShengYinEquipData()
    local partInfo = cache.AwakenCache:getShengYinPartInfo()
    local syScore = cache.AwakenCache:getSyScore()
    local colorData = conf.ShengYinConf:getValue("sy_stren_max_color")

    for k,v in pairs(equipData) do
        local confdata = conf.ItemConf:getItem(v.mid)
        local lv = 0
        if partInfo and next(partInfo)~=nil then
            for i , j in pairs(partInfo) do
                if j.part == confdata.part then
                    lv = j.strenLev
                    break
                end
            end
        else
            lv = 0
        end
        local quality = conf.ItemConf:getQuality(v.mid)
        local limLvColor = 0--品质强化上限
        for _,q in pairs(colorData) do
            if q[1] == quality then
                limLvColor = q[2]
                break
            end
        end

        local strengInfo = conf.ShengYinConf:getStrenInfo(confdata.part,lv)
        if strengInfo.need_cost then
            if syScore >= strengInfo.need_cost and lv < limLvColor then
                redNum = redNum + 1
            end
        end

    end
    -- print("圣印强化红点",redNum)
    return redNum

end
--存在比身上更高阶的圣印
function GStrongShengYinRedNum()
    local redNum = 0
    local roleLV = cache.PlayerCache:getRoleLevel()
    --已装备
    local equipData = cache.PackCache:getShengYinEquipData()
    --圣印背包
    local packData = cache.PackCache:getShengYinData()
    local flag = false
    for k,v in pairs(equipData) do
        local equipConf = conf.ItemConf:getItem(v.mid)
        local equipPart = equipConf.part
        -- local equipColor = equipConf.color
        local equipJie = equipConf.stage_lvl
        for i,j in pairs(packData) do
            local packConf = conf.ItemConf:getItem(j.mid)
            local packPart = packConf.part
            -- local packColor = packConf.color
            local packJie = packConf.stage_lvl
            local packLv = packConf.lvl
            if roleLV >= packLv then
                --  local data = cache.PackCache:getShengYinEquipDataByPart(packPart)
                -- if not data or #data == 0 then
                --     redNum = redNum + 1
                -- end
                --身上和背包内有同部位的
                if equipPart == packPart then
                    if equipJie < packJie then
                        redNum = redNum  + 1
                    end
                end
            end
        end
    end
    return redNum
end
--可穿戴圣印
function GCanPutShengYin()

    local redNum = 0
    local roleLV = cache.PlayerCache:getRoleLevel()

    local equipData = cache.PackCache:getShengYinEquipData()
    local havePart = {}
    for k,v in pairs(equipData) do
        local equipConf = conf.ItemConf:getItem(v.mid)
        local equipPart = equipConf.part
        havePart[equipPart] = 1
    end
    -- printt("havePart",havePart)
    -- for k,v in pairs(havePart) do
    --     print(k,v)
    -- end
    --圣印背包
    local packData = cache.PackCache:getShengYinData()

    for k,v in pairs(packData) do
        local packConf = conf.ItemConf:getItem(v.mid)
        local packLv = packConf.lvl
        local packPart = packConf.part
        if roleLV >= packLv then
            -- local data = cache.PackCache:getShengYinEquipDataByPart(packPart)
            -- print("背包内",packPart)
            if not havePart[packPart] then
                redNum = redNum + 1
            end
        end
    end

    return redNum
end

function GGetCompseJSByMid(mid)
    -- body
     local condata = conf.AwakenConf:getJScomposeInfo(mid)

    local packdata = cache.PackCache:getShenZhuangDebrisNum(condata.need_item[1])

    if packdata.amount == 0 then
        return 0
    end
    local number = packdata.amount

    number = math.floor(number/condata.need_item[2])

    return number
end

function GGetCompseJS()
    -- body
    local condata = conf.ForgingConf:getSuitFuseData(20)
    for k ,v in pairs(condata) do
        if GGetCompseJSByMid(v.id)>0 then
            return 1
        end
    end
    return 0
end

function GJSsynScore(data)
    local synScore = 0--综合战斗力
    local colorAttris = data.colorAttris
    if colorAttris and #colorAttris > 0 then--系统生成属性
        for k,v in pairs(colorAttris) do
            synScore = synScore + mgr.ItemMgr:birthAttScore(v.type,v.value)--计算综合评分
        end
    else
        local birthAtt = conf.ItemConf:getBaseBirthAtt(data.mid)--推荐属性
        local isTuijian = true
        if not birthAtt then--固定生成的属性不走推荐
            isTuijian = false
            birthAtt = conf.ItemConf:getBirthAtt(data.mid) or {}
        end

        for k,v in pairs(birthAtt) do
            if k % 2 == 0 then--值
                local type,value = birthAtt[k - 1],birthAtt[k]
                if not isTuijian then--如果是固定生成的
                    synScore = synScore + mgr.ItemMgr:birthAttScore(type,value)--计算综合评分
                end
            end
        end
    end
    return synScore
end
--是否有更好的剑神装备可替换
function G_isJSRed()
    -- body
    local packdata = cache.PackCache:getShenZhuangData()
    local bestpart = {}
    for k ,v in pairs(packdata) do
        --print("??")
        local confdata = conf.ItemConf:getItem(v.mid)
        local star = mgr.ItemMgr:getColorBNum(v)
        if not bestpart[confdata.part] then
            bestpart[confdata.part] = star
        else
            bestpart[confdata.part] = math.max(bestpart[confdata.part],star)
        end
    end

    --printt("bestpart",bestpart)

    for part = 1 , 10 do
        if bestpart[part] then
            local equipData = cache.PackCache:getShengZhuangEquipDataByPart(part)
            if not equipData then
                return 1
            else
                local star = mgr.ItemMgr:getColorBNum(equipData)
                if star < bestpart[part] then
                    return 1
                end
            end
        end
    end


    return 0
end
--table逆序
function reverseTable(tab)
    local tmp = {}
    for i = 1, #tab do
        local key = #tab
        tmp[i] = tab[#tab-i+1]
    end
    return tmp
end
function GGetBMRed()
    -- print("孔位开启红点",GGetBMOpenRed(),"空孔可以镶嵌",GGetBMCanInsertRed(),"强化&进阶",GGetBMStrengRed())
    return GGetBMOpenRed() + GGetBMCanInsertRed() + GGetBMStrengRed()
end

--八门孔位开启红点
function GGetBMOpenRed()
    local redNum = 0
    local data = cache.AwakenCache:getEightGatesData()
    if not data then return 0 end
    for k,v in pairs(data.info) do
        if v.state == 0 then
            local condition = conf.EightGatesConf:getGatesInfoById(k)
            if condition.item and cache.PlayerCache:getRoleLevel() >= condition.level then
                 local packData = cache.PackCache:getPackDataById(condition.item[1])
                 if packData.amount >= condition.item[2] then
                    redNum = redNum + 1
                    break
                 end
            end
        end
    end
    return redNum
end
--八门空孔可以镶嵌
function GGetBMCanInsertRed()
    local isOpen = false
    local data = cache.AwakenCache:getEightGatesData()
    if not data then return 0 end
    for k,v in pairs(data.info) do
        if v.state == 1 then
            isOpen = true
            break
        end
    end
    --有空的孔位
    if isOpen then
        local equipData = cache.PackCache:getElementEquipData()
        local packData = cache.PackCache:getElementPackData()
        if not equipData or not packData then return 0 end
        for k,v in pairs(packData) do
            local subType = conf.ItemConf:getSubType(v.mid)
            local mData = cache.PackCache:getEleByType(subType)
            if not mData and subType~= 15 then--身上没有subType类型的元素
                return 1
            end
        end
    end
    return 0
end
--八门强化&进阶红点
function GGetBMStrengRed()
    local score = cache.AwakenCache:getBMScore()
    local equipData = cache.PackCache:getElementEquipData()
    if not equipData or not score then
        return 0
    end
     --进阶间隔等级
    local stepLevel = conf.EightGatesConf:getValue("bm_jinjie_level")
     --强化上限
    local data = conf.EightGatesConf:getValue("bm_stren_max_color")
    local strengByColor = {}
    for k,v in pairs(data) do
        strengByColor[v[1]] = v[2]
    end
    for k,v in pairs(equipData) do
        local confData = conf.ItemConf:getItem(v.mid)
        if not confData then return 0 end
        --当前接
        local curstageLv = confData.stage_lvl
        --下次升阶等级
        local nextStepLv = curstageLv*stepLevel
        if v.level < strengByColor[confData.color] and v.level < nextStepLv  then--还没有到强化上限
            local _t = conf.EightGatesConf:getStrengInfo(confData.sub_type,v.level)
            if not _t.need_cost then return 0 end
            local needCost = _t.need_cost
            if score >= _t.need_cost then
                return 1
            end
        end
    end
    -- print("不能强化")
    --品质对应进阶上限
    local mData = conf.EightGatesConf:getValue("bm_jinjie_max")
    local stepByColor = {}
    local stepByColor = {}
    for k,v in pairs(mData) do
        stepByColor[v[1]] = v[2]
    end
    for k,v in pairs(equipData) do
        local confData = conf.ItemConf:getItem(v.mid)
        if not confData then return 0 end
        local curstageLv =  confData.stage_lvl
         --下次升阶等级
        local nextStepLv = curstageLv*stepLevel
        -- print("v.mid",conf.ItemConf:getName(v.mid),"stepByColor[confData.color]",stepByColor[confData.color],
            -- "当前等级",v.level,"下次升阶等级",nextStepLv,"品质对应进阶上限",stepByColor[confData.color])
        if curstageLv < stepByColor[confData.color] and v.level == nextStepLv then----还没有到进阶上限
            local _t = conf.EightGatesConf:getStepCost(curstageLv)
            local listnumber = {}
            if not _t.items then return 0 end
            for _,n in pairs(_t.items) do
                local _packdata = cache.PackCache:getElementById(n[1])
                table.insert(listnumber,math.floor(_packdata.amount/n[2]))
            end
            local num = math.min(unpack(listnumber))
            return num
        end
    end
    return 0
end

--根据皮肤模块id和皮肤id获取皮肤信息
function GGetSkinInfoByModuleIdAndSkinId(moduleId,skinId)
    local skinInfo = {}
    if moduleId == 1001 then--坐骑
        skinInfo = conf.ZuoQiConf:getSkinsByIndex(skinId, 0)
    elseif moduleId == 1002 then--仙羽
        skinInfo = conf.ZuoQiConf:getSkinsByIndex(skinId, 3)
    elseif moduleId == 1003 then--神兵
        skinInfo = conf.ZuoQiConf:getSkinsByIndex(skinId, 1)
    elseif moduleId == 1004 then--仙器
        skinInfo = conf.ZuoQiConf:getSkinsByIndex(skinId, 4)
    elseif moduleId == 1005 then--法宝
        skinInfo = conf.ZuoQiConf:getSkinsByIndex(skinId, 2)
    elseif moduleId == 1006 then--灵童
        skinInfo = conf.HuobanConf:getSkinsByIndex(skinId,0)
    elseif moduleId == 1007 then--灵羽
        skinInfo = conf.HuobanConf:getSkinsByIndex(skinId,1)
    elseif moduleId == 1008 then--灵兵
        skinInfo = conf.HuobanConf:getSkinsByIndex(skinId,2)
    elseif moduleId == 1009 then--灵器
        skinInfo = conf.HuobanConf:getSkinsByIndex(skinId,4)
    elseif moduleId == 1010 then--灵宝
        skinInfo = conf.HuobanConf:getSkinsByIndex(skinId,3)
    elseif moduleId == 1011 then--人物时装
        skinInfo = conf.RoleConf:getFashData(skinId)
    elseif moduleId == 1012 then--剑神
        skinInfo = conf.AwakenConf:getJsImageData(skinId)
    elseif moduleId == 1013 then--光环
        skinInfo = conf.RoleConf:getHaloData(skinId)
    elseif moduleId == 1014 then--头像框
        skinInfo = conf.RoleConf:getFrameById(skinId)
    elseif moduleId == 1015 then--聊天气泡
        skinInfo = conf.RoleConf:getBubbleById(skinId)
    elseif moduleId == 1016 then--头饰
        skinInfo = conf.RoleConf:getHeadData(skinId)
    end
    return skinInfo
end