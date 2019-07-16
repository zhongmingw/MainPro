--
-- Author: 
-- Date: 2018-10-29 15:11:59
--

local TaiGuXuanJingProxy = class("TaiGuXuanJingProxy", base.BaseProxy)

function TaiGuXuanJingProxy:init()
    self:add(5331501,self.add5331501)--请求太古玄境信息
    self:add(5331502,self.add5331502)--请求太古玄镜boss场景信息
    self:add(5331503,self.add5331503)--请求太古玄镜boss关注
    self:add(8240101,self.add8240101)--太古玄镜boss血量变化广播
    self:add(8240102,self.add8240102)--太古玄镜BOSS疲劳值退出广播
    self:add(8240103,self.add8240103)--太古玄镜结算广播
end

function TaiGuXuanJingProxy:add5331501( data )
    if data.status == 0 then
        cache.TaiGuXuanJingCache:setLTValue(data.leftTired)
        local view = mgr.ViewMgr:get(ViewName.BossView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function TaiGuXuanJingProxy:add5331502( data )
   
    if data.status == 0 then
        local sId = cache.PlayerCache:getSId()
        local modular = sId
        if mgr.FubenMgr:isTaiGuXuanJing(sId) then--
            modular = BossScene.tgxj
        end
        cache.FubenCache:setFubenModular(1378)
        -- cache.TaiGuXuanJingCache:setWorldHateName(nil)
        printt(data)
        cache.TaiGuXuanJingCache:setTaiGuData(data)
        -- --第一次进入太古 bxp
        -- if data.first and data.first == 1 then
        --     local data = {}
        --     data.cancel = function ()
        --         mgr.HookMgr:enterHook()
        --     end 
        --     mgr.ViewMgr:openView2(ViewName.WorldBossExplainView,data)
        -- else
        -- end
        mgr.HookMgr:enterHook()
        --刷新任务追踪
        local t = {index = 1}
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setData(t)
        else
            mgr.ViewMgr:openView2(ViewName.TrackView, t)
        end
    else
        GComErrorMsg(data.status)
    end
end

function TaiGuXuanJingProxy:add5331503( data )
    if data.status == 0 then
    else
        GComErrorMsg(data.status)
    end
end

function TaiGuXuanJingProxy:add8240101( data )
    if data.status == 0 then
        cache.TaiGuXuanJingCache:updateTaiGuData(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setBossData()
        end
    else
        GComErrorMsg(data.status)
    end
end
function TaiGuXuanJingProxy:add8240102( data )
    if data.status == 0 then
        mgr.ViewMgr:openView2(ViewName.BossTiredTipView, {})
    else
        GComErrorMsg(data.status)
    end
end
function TaiGuXuanJingProxy:add8240103( data )
    print("太古玄境结算广播~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    if data.status == 0 then
        mgr.TimerMgr:addTimer(6, 1, function()
            if mgr.FubenMgr:isTaiGuXuanJing(cache.PlayerCache:getSId()) then
                mgr.ViewMgr:openView(ViewName.BossDekaronView,function(view)
                    view:setData(data,2)
                end)
            else
                local view = mgr.ViewMgr:get(ViewName.BossDekaronView)
                if view then
                    view:onClickClose()
                end
            end
        end)
    else
        GComErrorMsg(data.status)
    end
end
return TaiGuXuanJingProxy