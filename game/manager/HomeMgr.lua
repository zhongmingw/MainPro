--
-- Author: wx
-- Date: 2017-11-29 14:57:41
-- 
-- 
--605 开始种植时间
--606 成熟需要时间
--607 被浇水的次数
--608 被偷的次数
--609 家园组价使用的皮肤

local HomeMgr = class("HomeMgr")
local pairs = pairs
function HomeMgr:ctor()
    self:initData()
end
function HomeMgr:initData()
    -- body
    self.buycount = 0
    self.continueplant = false --购买后继续种植
end
--
--BUG #7061 灵田的弹窗同时只能出现一个
function HomeMgr:visibleOther(monster)
    -- body
    if not monster then
        self.oldmonster = nil 
        return
    end
    if self.oldmonster then
        if self.oldmonster.componeents and self.oldmonster.componeents["home2"] then
            self.oldmonster.componeents["home2"].visible = false
        end
    end
    if monster.componeents["home2"] then
        monster.componeents["home2"].visible = true
    end
    self.oldmonster = monster
end
--是否有种植东西
function HomeMgr:isHavePlant()
    -- body
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind == WidgetKind.home then
                local condata = conf.HomeConf:getHomeThing(v.data.ext01)
                if condata.type == 5  then
                    if v.data.attris and v.data.attris[605] and v.data.attris[605]>0 then
                        return true
                    end 
                end
            end
        end
    end

    return false
end
--是否召唤了怪兽
function HomeMgr:getIsCallMonster()
    -- body
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind ~= WidgetKind.home then
                if v.data.kind == 0 then
                    local mConf = conf.MonsterConf:getInfoById(v.data.mId)
                    if mConf.kind ~= MonsterKind.homedog then--家园狗
                        return true
                    end
                end
            end
        end
    end
    return false
end


--跑到某个点
function HomeMgr:goPosition(id)
    -- body
    local v = conf.HomeConf:getScenesInfoById(id)
    local point = Vector3.New(v.ponit[1][1], gRolePoz, v.ponit[1][2])
    local dis = GMath.distance(point, gRole:getPosition())
    if dis > v.ponit[1][3] then
        mgr.JumpMgr:findPath(point,0)
    end
end
--获取当前使用的皮肤
function HomeMgr:getSelectSkin()
    -- body
    local selected = {}
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind == WidgetKind.home then
                local condata = conf.HomeConf:getHomeThing(v.data.ext01)
                if condata.type <= 4  then
                    selected[v.data.ext01] = v.data.attris[609]
                end
            end
        end
    end
    -- for k ,v in pairs(selected) do
    --     print("使用皮肤",k,v)
    -- end
    return selected
end

--检测家园组件升级条件
function HomeMgr:checkComponentCon(condata,data,flag)
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
--获取剩余浇水次数
function HomeMgr:getWater()
    -- body
    local cc = 0
    if cache.HomeCache:getisSelfHome() then
        cc = conf.HomeConf:getValue("water_self_count") - cache.HomeCache:getWaterSelf()
    else
        cc = conf.HomeConf:getValue("water_other_count") - cache.HomeCache:getOtherSelf()
    end
    return cc 
end
--获取剩余偷窃次数
function HomeMgr:getSteal()
    -- body
    local cc = 0
    cc = conf.HomeConf:getValue("day_steal_farm_max") - cache.HomeCache:getSteal()
    return cc
end

--获取一块可种植的田
function HomeMgr:getOneCanPlant(var)
    -- body
    local _t = {}
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind == WidgetKind.home then
                local condata = conf.HomeConf:getHomeThing(v.data.ext01)
                if condata.type == 5 and v.data.ext02 > 0 then
                    --是灵田 并且已开启
                    if not v.data.attris or  not v.data.attris[605] or  v.data.attris[605]<=0 then
                        table.insert(_t,v.data)
                    end 
                end
            end
        end
    end

    if #_t <= 0 then 
        return nil 
    end

    table.sort(_t,function(a,b)
        -- body
        return a.ext01 < b.ext01
    end)

    return _t
end

--获取已经成熟的灵田
function HomeMgr:getMature()
    -- body
    local _t = {}
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind == WidgetKind.home then
                local condata = conf.HomeConf:getHomeThing(v.data.ext01)
                if condata.type == 5 and v.data.mId ~= 0 then
                    local var = v.data.attris[605]+v.data.attris[606]- mgr.NetMgr:getServerTime()
                    --print("var",var)
                    if var <= 0 then
                        table.insert(_t,v)
                    end
                end
            end
        end
    end
    return _t
end
--获取所有有农作物的田
function HomeMgr:getAllCrops()
    -- body
    local _t = {}
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind == WidgetKind.home then
                local condata = conf.HomeConf:getHomeThing(v.data.ext01)
                if condata.type == 5 and v.data.mId ~= 0 then
                    table.insert(_t,v)
                end
            end
        end
    end
    return _t
end
--获取指定组件
function HomeMgr:getComponentById(id)
    -- body
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind == WidgetKind.home then
                if tonumber(v.data.ext01) == tonumber(id) then
                    return v 
                end
            end
        end
    end
    return nil
end
--指定的组件等级
function HomeMgr:getComponentLevel(id)
    -- body
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind == WidgetKind.home then
                if v.data.ext01 == id then
                    return v.data.ext02
                end
            end
        end
    end

    local condata = conf.HomeConf:getHomeThing(id)
    return condata and condata.lev or 0
end
--升级田
function HomeMgr:updateTian(data,callback)
    -- body
    
    local _nextdata = conf.HomeConf:getHomeLev(data.ext01,data.ext02+1)
    if not _nextdata then
        GComAlter(language.home132)
        return
    end
    --
    if not self:checkComponentCon(_nextdata,cache.HomeCache:getData(),true) then
        return
    end

    local _confdata = conf.HomeConf:getHomeLev(data.ext01,data.ext02)
    local t = clone(language.home58)
    t[2].text = string.format(t[2].text,_confdata.cost[2])

    local param = {}
    param.type = 2 
    param.richtext = mgr.TextMgr:getTextByTable(t)
    param.sure = function()
        -- body
        local param = {}
        param.reqType = data.ext01
        proxy.HomeProxy:sendMsg(1460105,param)
        if callback then
            callback()
        end
    end
    param.cancel = function()
        -- body
        if callback then
            callback()
        end
    end
    GComAlter(param)
end
--扩建田
function HomeMgr:doKuoJian(data,callback)
    -- body
    if true then
        --策划要求 --家园灵田变成自动有 屏蔽拓建
        return
    end

    if self:getComponentLevel(data.ext01-1) == 0 then
        GComAlter(language.home137)
        return
    end

    local _t = clone(language.home48)
    local condata = conf.HomeConf:getHomeLev(data.ext01,0)
    _t[2].text = string.format(_t[2].text,condata.cost[2])
    _t[3].text = language.gonggong115[condata.cost[1]] .. _t[3].text
    ---table.insert(_t,3,{text = ,color = 6})

    local param = {}
    param.type = 2
    param.richtext = mgr.TextMgr:getTextByTable(_t)
    param.sure = function()
        -- body
        if callback then
            callback()
        end
        
        local sendParam = {}
        sendParam.reqType = 7
        sendParam.confId = {}
        table.insert(sendParam.confId,data.ext01)
        proxy.HomeProxy:sendMsg(1460111,sendParam)
    end
    param.cancel = function()
        -- body
        if callback then
            callback()
        end
    end
    GComAlter(param)
end

--种植
function HomeMgr:doPlant(data)
    -- body
    local var = cache.HomeCache:getPlantChoose()
    if var then
        if cache.HomeCache:getseedAmountById(var) <= 0 then
            --种子数量不足
            GComAlter(language.home91)
            return
        else
            local _seedcondata = conf.HomeConf:getSeedByid(var)
            if not data then
                --默认选择一块可种植的田
                local info = self:getOneCanPlant()
                if info then
                    for k , v in pairs(info) do
                        if v.ext02 >= _seedcondata.level then
                            data = v
                            break
                        end
                    end
                end
            end
            if not data then
                GComAlter(language.home131)
                return
            end
            
            if _seedcondata.level > data.ext02 then
                --种子等级高过田
                GComAlter(language.home90)
                return
            end
            local condata = conf.HomeConf:getSeedByid(var)
            local index = cache.PackCache:getPackDataById(condata.item_mid).index
            --发送种植信息
            local info = {}
            info.reqType = 1
            info.confId = {}
            table.insert(info.confId,data.ext01)
            table.insert(info.confId,index)
            proxy.HomeProxy:sendMsg(1460111,info)
        end
    else
        print("意外情况,有操作类型,但是没有选择种子!!!")
    end
end

function HomeMgr:shopBuyCall()
    -- body
    if not mgr.FubenMgr:isHome(cache.PlayerCache:getSId()) then
        return
    end
    --print("send shop back")
    if self.continueplant then
        self.buycount = self.buycount  - 1
        if self.buycount == 0 then
            self:doOneKeyPlant()
            self.continueplant = false
        end
    end
end

--一件种植
function HomeMgr:doOneKeyPlant()
    -- body
    if not mgr.FubenMgr:isHome(cache.PlayerCache:getSId()) then
        return
    end

    if self.buycount > 0 then
        print("点击太快了")
        return
    end

    local _tiandata = self:getOneCanPlant()
    if not _tiandata then
        return GComAlter(language.home52)
    end
    local _tiannumber = #_tiandata
    if _tiannumber == 0 then
        --没有空闲的田
        return GComAlter(language.home52)
    end

    table.sort(_tiandata,function(a,b)
        -- body
        if a.ext02 == b.ext02 then
            return a.ext01 < b.ext01
        else
            return a.ext02 < b.ext02
        end
    end)    
    local _plant = {} --种植的
 
    local donet = {} --一件消耗的种子数量
    local jyb = cache.PlayerCache:getTypeMoney(MoneyType.home)
    local _m = {}
    local shopdata = conf.ShopConf:getJiaYuanShopData()
    for k ,v in pairs(shopdata) do
        _m[v.mid] = v
    end
    local lastbuy = {}
    
    for k , v in pairs(_tiandata) do
        local confdata = conf.HomeConf:getSeedByLevel(v.ext02)
        if not confdata then
            return
        end
        local _var = cache.HomeCache:getseedAmountById(confdata.id)
        local _pack = cache.PackCache:getPackDataById(confdata.item_mid)
        if _pack.amount - (donet[confdata.item_mid] or 0) > 0 then
            --有种子
            if not donet[confdata.item_mid] then
                donet[confdata.item_mid] = 0
            end
            donet[confdata.item_mid] = donet[confdata.item_mid] + 1

            _plant[v.ext01] = _pack.index

        else
            --计算是否可以购买
            local _nn =math.min(1,math.floor(jyb / _m[confdata.item_mid].price))
            if _nn <= 0 then
                break --家园币不足了
            end
            if not lastbuy[_m[confdata.item_mid].id] then
                lastbuy[_m[confdata.item_mid].id] = 0
                self.buycount = self.buycount + 1
            end
            lastbuy[_m[confdata.item_mid].id] = lastbuy[_m[confdata.item_mid].id] + 1
            jyb = jyb - _nn * _m[confdata.item_mid].price
        end
    end

    if self.buycount == 0 then


        local _cnumber =0
        for k ,v in pairs(_plant) do
            local info = {}
            info.reqType = 1
            info.confId = {}
            table.insert(info.confId,k)
            table.insert(info.confId,v)
          
            proxy.HomeProxy:sendMsg(1460111,info)

            _cnumber = _cnumber + 1
        end
        if _cnumber > 0 then
            GComAlter(language.home140)
        else
            GComAlter(language.store15[14])
        end
    else
        --发送购买消息
        for k ,v in pairs(lastbuy) do
            proxy.ShopProxy:sendByItemsByStore(9,k,v)
        end
        self.continueplant = true
    end
end

--浇水
function HomeMgr:doWater(data)
    -- body
    if not data then
        return
    end
    if not data.mId then
        print("错误选择")
        return   
    end
    --没有次数
    local cc = self:getWater()
    if cc <= 0 then
        --退出浇水
        local _view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if _view then
            _view:onOScancel()
        end
        GComAlter(language.home88)
        return
    end
    if not self:isHavePlant() then
        --压根东西可浇水
        local _view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if _view then
            _view:onOScancel()
        end
        GComAlter(language.home128)
        return
    end

    if data.attris and data.attris[607] then

        local var = data.attris[605] + data.attris[606]- mgr.NetMgr:getServerTime()
        local _condata = conf.HomeConf:getSeedByid(data.mId)
        if var <= 0 then
            --已经成熟了
            GComAlter(language.home87)
        elseif data.attris[607] >= _condata.water_count then
            --被浇水的次数满了
            GComAlter(language.home55)
        else
            
            local param = {}
            param.reqType = 2
            param.confId = {}
            table.insert(param.confId,data.ext01)
            proxy.HomeProxy:sendMsg(1460111,param)
        end
    else
        plog("是否浇水没有返回@宝爷")
    end   
end
--一键浇水
function HomeMgr:doOneKeyWater()
    -- body
    local cc = self:getWater()
    if cc <= 0 then
        GComAlter(language.home88)
        return
    end
    if not self:isHavePlant() then
        --压根东西可浇水
        GComAlter(language.home128)
        return
    end

    local param = {}
    param.reqType = 2
    param.confId = {}
    local info = self:getAllCrops()
	table.sort(info,function(a,b)
        -- body
        return a.data.ext01 < b.data.ext01
    end)
    for k ,v in pairs(info) do
        if cc <= 0 then
            break
        end
        data = v.data
        if data.attris and data.attris[607] then
            local var = data.attris[605] + data.attris[606]- mgr.NetMgr:getServerTime()
            local _condata = conf.HomeConf:getSeedByid(data.mId)
            if var <= 0 then
            elseif data.attris[607] >= _condata.water_count then
            else
				table.insert(param.confId,data.ext01)
                cc = cc - 1 
                --[[local number = _condata.water_count - data.attris[607]  
                for i = 1 , number do
                    table.insert(param.confId,data.ext01)
                    cc = cc - 1 
					if cc <= 0 then
						break
					end
                end
				if cc <= 0 then
					break
				end]]--
            end
        else
            plog("是否浇水没有返回@宝爷")
        end   
    end

    if #param.confId > 0 then
	print("#param.confId",#param.confId)
		printt("param",param)
        proxy.HomeProxy:sendMsg(1460111,param)
    else
        GComAlter(language.home141)
    end
end

--催熟
function HomeMgr:doAccelerate(param)
    -- body
    if not param then
        print("使用错误")
        return
    end
    if #param <= 0 then
        GComAlter(language.home61)
        return
    end

    local sendparam = {}
    sendparam.reqType = 3
    sendparam.confId = {}

    local time = 0
    for k ,v in pairs(param) do
        table.insert(sendparam.confId,v.ext01)
        local var = v.attris[605]+v.attris[606]- mgr.NetMgr:getServerTime()
        time = time + math.max(var,0)
    end

    if time <= 0 then
        GComAlter(language.home61)
        return
    end
    local _sss = ""
    if #sendparam.confId > 1 then
        _sss = clone(language.home62)
    else
        _sss = clone(language.home130)
    end

    local _condata = conf.HomeConf:getValue("farm_time_money")
    local str = math.ceil(time/_condata[1])*_condata[3]
    

    _sss[2].text = string.format(_sss[2].text,str)
    local info = {}
    info.type = 2
    info.richtext = mgr.TextMgr:getTextByTable(_sss)
    info.sure = function()
        -- body
        proxy.HomeProxy:sendMsg(1460111,sendparam)
    end
    GComAlter(info)
end

--收获
function HomeMgr:doHarvest(param)
    -- body
    if not param then
        print("使用错误")
        return
    end
    --print("#param",#param)
    if #param <= 0 then
        GComAlter(language.home63)
        return
    end
    local sendParam = {}
    sendParam.reqType = 4
    sendParam.confId = {}

    local jyb = 0
    local items = {}
    for k ,v in pairs(param) do
        if v.attris and v.attris[606] and v.attris[605] then
            local var = v.attris[605]+v.attris[606]- mgr.NetMgr:getServerTime()
            if var <= 0 then
                table.insert(sendParam.confId,v.ext01)
                --计算产出
                local _t = {}
                local cc = conf.HomeConf:getSeedByid(v.mId)
                --计算被偷走的家园币
                jyb = jyb + cc.jyb - cc.steal_jyb * (v.attris[608] or 0)
            end
        end
    end

    local iteminfo = {}
    --家园币
    if jyb > 0 then
        local _t = {mid = MoneyPro2[MoneyType.home],amount = jyb ,bind = 0}
        table.insert(iteminfo,_t)
    end
    
    proxy.HomeProxy:sendMsg(1460111,sendParam)
    return iteminfo
end

function HomeMgr:doClear(data,callback)
    -- body
    local var = data.attris[605]+data.attris[606]- mgr.NetMgr:getServerTime()
    local info = {}
    info.type = 2
    info.sure = function()
        -- body
        local param = {}
        param.reqType = 6
        param.confId = {}
        table.insert(param.confId,data.ext01)
        proxy.HomeProxy:sendMsg(1460111,param)
        if callback then
            callback()
        end
    end
    if var > 0 then
        info.richtext = string.format(language.home95,GTotimeString4(var))
    else
        info.richtext = language.home96
    end
    GComAlter(info)
end
--偷窃
function HomeMgr:doSteal(data)
    -- body
    if not data then
        return
    end

    --检测偷窃上限
    if self:getSteal()<= 0 then
        GComAlter(language.home136)
        return
    end

    local confseed = conf.HomeConf:getSeedByid(data.mId)
    if data.attris and data.attris[606] then
        local var = data.attris[605]+data.attris[606]- mgr.NetMgr:getServerTime()
        if var > 0 then
            GComAlter(language.home60)
        elseif data.attris[608] >= confseed.max_steal_count then
            GComAlter(language.home129)
            return
        else
            local sendParam = {}
            sendParam.reqType = 5
            sendParam.confId = {}
            table.insert(sendParam.confId,data.ext01)
            proxy.HomeProxy:sendMsg(1460111,sendParam)
        end
    else
        plog("偷窃没606有返回@宝爷")
    end 
end
--泡温泉
function HomeMgr:doSpring(data)
    -- body
    if not data then
        return
    end
    if cache.HomeCache:gethotSpringLev()<=0 then
        GComAlter(language.home106)
        return
    end
    if data.startHotSpringTime > 0 then
        GComAlter(language.home111)
        return
    end
    if data.leftHotSpringSec <= 0 then
        GComAlter(language.home118)
        return
    end


    
    --泡温泉
    local sendParam = {}
    sendParam.reqType = 1
    proxy.HomeProxy:sendMsg(1460109,sendParam)
end
--建造温泉
function HomeMgr:doBuildSpring()
    -- body
    if not cache.HomeCache:getisSelfHome() then
        GComAlter(language.home45)
        return
    end
    local data = cache.HomeCache:getData()
    if data.hotSpringLev > 0 then
        mgr.ViewMgr:openView2(ViewName.HomeSpringView)
        return
    end
    local _cid = 3001
    local condata = conf.HomeConf:getHomeLev(_cid,data.hotSpringLev)
    --print("_cid",self.data.hotSpringLe)
    if self:checkComponentCon(conf.HomeConf:getHomeLev(_cid,data.hotSpringLev+1),data,true) then

        local ss = clone(language.home85)
        ss[2].text = string.format(ss[2].text,condata.cost[2])
        local _param = {}
        _param.type = 2
        _param.richtext = mgr.TextMgr:getTextByTable(ss)
        _param.sure = function()
            -- body
            local sendParam = {}
            sendParam.reqType = _cid
            proxy.HomeProxy:sendMsg(1460105,sendParam)
        end
        GComAlter(_param)
    end
end
--浇水成功来个特效
function HomeMgr:doWaterEffect(data)
    -- body
    if not data then
        return
    end
    --检测是否有这田
    local  monster = self:getComponentById(data)
    if not monster then
        return
    end
    local effect = conf.HomeConf:getValue("water_effid")
    if not effect then
        return
    end
    local parent = UnitySceneMgr.pStateTransform

    local e = mgr.EffectMgr:playCommonEffect(effect, parent)
    if e then
        local effectConf = conf.EffectConf:getEffectById(effect)
        if effectConf.scale then
            e.Scale = Vector3.New(effectConf.scale,effectConf.scale,effectConf.scale) 
        end
        e.LocalRotation = Vector3.New(40,0,180)

        local pos = monster:getPosition()
        pos.y = -1800
        e.LocalPosition = pos
    end
end
--计算是否有成熟的灵田
function HomeMgr:getTianRedPoint()
    -- body
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind == WidgetKind.home then
                local condata = conf.HomeConf:getHomeThing(v.data.ext01)
                if condata.type == 5  then
                    if v.data.attris and v.data.attris[605] and v.data.attris[605]>0 then
                        local var = v.data.attris[605]+v.data.attris[606]- mgr.NetMgr:getServerTime()
                        if var <= 0 then
                            return 1
                        end
                    end 
                end
            end
        end
    end
    return 0
end

--检测是否有空田 和 种子
function HomeMgr:isEmtyTianAndSeed()
    -- body
    local flag = false
    local _tiandata = self:getOneCanPlant()
    if not _tiandata then
        return flag
    end
    local _tiannumber = #_tiandata
    if _tiannumber == 0 then
        --没有空闲的田
        return flag
    end
    table.sort(_tiandata,function(a,b)
        -- body
        if a.ext02 == b.ext02 then
            return a.ext01 < b.ext01
        else
            return a.ext02 < b.ext02
        end
    end)    
    for k , v in pairs(_tiandata) do
        for i = 1 , v.ext02 do
            local confdata = conf.HomeConf:getSeedByLevel(i)
            if confdata and confdata.id then
                local _var = cache.HomeCache:getseedAmountById(confdata.id)
                if _var > 0 then
                    flag = true 
                    return flag
                end
            end
        end
    end
end

return HomeMgr