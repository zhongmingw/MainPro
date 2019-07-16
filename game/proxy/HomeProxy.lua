--
-- Author: 
-- Date: 2017-11-14 19:22:36
--

local HomeProxy = class("HomeProxy",base.BaseProxy)

function HomeProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5460101,self.add5460101)-- 请求家园拜访列表
    self:add(5460102,self.add5460102)--  请求家园温泉任务追踪信息
    self:add(5460103,self.add5460103)-- 请求家园场景任务追踪
    self:add(5460104,self.add5460104)-- 请求设置家园
    self:add(5460105,self.add5460105)-- 请求家园组件升级
    self:add(5460106,self.add5460106)-- 请求家园组件皮肤改变
    self:add(5460107,self.add5460107)-- 请求查看拜访记录
    self:add(5460108,self.add5460108)-- 请求家园拜访
    self:add(5460109,self.add5460109)-- 请求家园温泉操作
    self:add(5460110,self.add5460110)-- 请求家园开启
    self:add(5460111,self.add5460111)-- 请求家园灵田操作
    self:add(5460112,self.add5460112)-- 请求兽园场景任务追踪
    self:add(5460113,self.add5460113)-- 请求我的家园种子列表
    self:add(5460114,self.add5460114)-- 请求家园BOSS操作

    self:add(8220101,self.add8220101)-- 家园boss血量广播
    self:add(8220102,self.add8220102)-- 家园boss奖励
    self:add(8220103,self.add8220103)-- 家园BOSS任务追踪更新
end

function HomeProxy:sendMsg(mId,param)
    -- body
    self.param = param
    self:send(mId,param)
end
--请求家园拜访列表
function HomeProxy:add5460101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HomeSeeOther)
        if view then
            view:add5460101(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end
-- -- 请求家园温泉任务追踪信息
function HomeProxy:add5460102(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end
--请求家园场景任务追踪
function HomeProxy:add5460103(data)
    -- body
    if data.status == 0 then
        
        cache.HomeCache:setData(data)

        local view = mgr.ViewMgr:get(ViewName.HomeWelCome)
        if view then
            view:setData()
        end

        local view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function HomeProxy:add5460112( data )
    -- body
    if data.status == 0 then
        cache.HomeCache:setMonsterTrack(data)

        local view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end
--请求设置家园
function HomeProxy:add5460104( data )
    -- body
    if data.status == 0 then 
        if data.reqType == 1 then
            --改名
            cache.HomeCache:setName(data.name)
            --任务追踪名字改变
            local view = mgr.ViewMgr:get(ViewName.HomeMainView)
            if view then
                view:addMsgCallBack(data)
            end
        else
            --data.reqType == 0 then
            --0 设置信息
            local view= mgr.ViewMgr:get(ViewName.HomeSet)
            if view then
                view:add5460104(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end 
end
--请求家园组件升级
function HomeProxy:add5460105( data )
    -- body
    if data.status == 0 then
        
        local id = data.reqType*1000 +  data.lev
        if data.reqType == 1001 then            
            cache.HomeCache:setHomeLv(data.lev)

            --print("data.lev",data.reqType,id)
            self:sendMsg(1460106 ,{skins = {data.reqType,id}})
        elseif data.reqType == 2001 then 
            cache.HomeCache:setWallLv(data.lev)

            self:sendMsg(1460106 ,{skins = {data.reqType,id}})
        elseif data.reqType == 3001 then
            cache.HomeCache:sethotSpringLev(data.lev)

            self:sendMsg(1460106 ,{skins = {data.reqType,id}})


            --改任务追中
            local view = mgr.ViewMgr:get(ViewName.HomeMainView)
            if view then
                view:addMsgCallBack(data)
            end
        elseif data.reqType == 4001 then
            cache.HomeCache:setZoomLv(data.lev)

            local view = mgr.ViewMgr:get(ViewName.HomeMonster)
            if view then
                view:add5460105()
            end

            self:sendMsg(1460106 ,{skins = {data.reqType,id} })
        elseif data.reqType > 5000 then
            --灵田
            GComAlter(language.talent17)
            local monster = mgr.ThingMgr:objsByType(ThingType.monster)
            if monster then
                for k , v in pairs(monster) do
                    if v.data.kind == WidgetKind.home then
                        if v.data.ext01 == data.reqType then
                            v.data.ext02 = data.lev
                            v:setData(v.data)
                            break
                        end
                    end
                end
            end
        end
        --改任务追中
        local view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end
--请求家园组件皮肤改变
function HomeProxy:add5460106( data )
    -- body
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end 
end

-- 请求查看拜访记录
function HomeProxy:add5460107( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HomeRecord)
        if view then
            view:add5460107(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

--   请求家园拜访
function HomeProxy:add5460108( data )
    -- body
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end 
end
-- 请求家园温泉操作
function HomeProxy:add5460109( data )
    -- body
    if data.status == 0 then
        self:sendMsg(1460102)
        if data.reqType == 1 then
            if gRole then
                gRole:addSpringEffect()
            end
        end
    else
        GComErrorMsg(data.status)
    end 
end
-- 请求喂养灵兽
function HomeProxy:add5460110( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HomeBeginView)

        if data.homeSign == 0 then
            proxy.HomeProxy:sendMsg(1460108,{roleId = cache.PlayerCache:getRoleId()})
            if view then
                view:closeView()
            end
            --mgr.ViewMgr:openView2(ViewName.HomeBeginView)
        elseif data.homeSign == 1 then
            --1:未开启家园

            local var = conf.HomeConf:getValue("open_cost")[2]
            local cc = clone(language.home109)
            cc[2].text = string.format(cc[2].text ,var )
            if var <= 0 then
                self:sendMsg(1460110,{reqType = 1})
            else
                local param = {}
                param.type = 2
                param.richtext = mgr.TextMgr:getTextByTable(cc)
                param.sure = function()
                    -- body
                    self:sendMsg(1460110,{reqType = 1})
                end
                GComAlter(param)
            end
        elseif data.homeSign == 2 then
            --2:已荒废 
            local cc = clone(language.home110)
            cc[2].text = string.format(cc[2].text , conf.HomeConf:getValue("repair_cost")[2])

            local param = {}
            param.type = 2
            param.richtext = mgr.TextMgr:getTextByTable(cc)
            param.sure = function()
                -- body
                self:sendMsg(1460110,{reqType = 2})
            end
            GComAlter(param)
        end
    else
        GComErrorMsg(data.status)
    end 
end
-- 请求家园灵田操作
function HomeProxy:add5460111( data )
    -- body
    if data.status == 0 then
        if data.reqType == 1 then
            --种植
            --获取对应的田
            local param = {}
            local var = #data.confId
            for i = 1 , var , 2 do
                local c1 = data.confId[i]
                local c2 = data.confId[i+1]
                param[c1] = c2
            end
            for k ,v in pairs(param) do
                cache.HomeCache:reduceSeed(v)
            end
        elseif data.reqType == 2 then
            --浇水
            --GComAlter(language.home56)
            local param = {}
            for k , v in pairs(data.confId) do
                param[v] = true

                --做个特效
                mgr.HomeMgr:doWaterEffect(v)

                --浇水成功
                if cache.HomeCache:getisSelfHome() then
                    cache.HomeCache:setWaterSelf()
                else
                    cache.HomeCache:setOtherSelf()
                end
            end
            

            

        elseif data.reqType == 3 then
            --全体催熟
        elseif data.reqType == 4 then
            --收获
        elseif data.reqType == 5 then
            --偷窃
            --GComAlter("偷窃")
            cache.HomeCache:setSteal()
        elseif data.reqType == 6 then
            --清除
            local param = {}
            for k , v in pairs(data.confId) do
                param[v] = true
            end
        elseif data.reqType == 7 then
            --扩建
            local param = {}
            for k , v in pairs(data.confId) do
                param[v] = true
            end
        end

        local view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.HomeOS)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

--请求兽园场景任务追踪
function HomeProxy:ad5460112(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function HomeProxy:add5460113( data )
    -- body
    if data.status == 0 then
        cache.HomeCache:setSeedData(data.seeds)
        local view = mgr.ViewMgr:get(ViewName.HomePlantingChoose)
        if view then
            view:add5460113(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function HomeProxy:add5460114( data )
    -- body
    if data.status == 0 then
        cache.HomeCache:setHomeMonster(data)

        cache.HomeCache:setCallCount(data.callCount)

        local view = mgr.ViewMgr:get(ViewName.HomeMonster)
        if view then
            view:add5460114(data)
        end

        local _view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if _view then
            _view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end


function HomeProxy:add8220101(data)
    -- body
    if data.status == 0 then

        local info = cache.HomeCache:getHomeMonster()
        if  info then
            info.attris = data.attris
            info.hateRoleName = data.hateRoleName
            info.curHpPercent = data.curHpPercent
            info.hurtPercent = data.hurtPercent
            info.rankList = data.rankList
            info.roleId = data.roleId-------")
        end
        

        local view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if view then
            view:addMsgCallBack(data)
        end
        --print("add8220101",data.roleId)
        local monster = mgr.ThingMgr:getObj(ThingType.monster, data.roleId)
        if monster then
            --print("找不到")
            local _aa = clone(data)
            _aa.mId = monster.data.mId
            proxy.FubenProxy:refresBossHphView(_aa)
        end
        

        
    else
        GComErrorMsg(data.status)
    end 
end

function HomeProxy:add8220102(data)
    -- body
    if data.status == 0 then
        mgr.ViewMgr:openView(ViewName.BossDekaronView,function(view)
            view:setData(data,5)
        end)
    else
        GComErrorMsg(data.status)
    end
end

function HomeProxy:add8220103( data )
    -- body
    if data.status == 0 then
        cache.HomeCache:updateData(data)
        local view = mgr.ViewMgr:get(ViewName.HomeMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
return HomeProxy