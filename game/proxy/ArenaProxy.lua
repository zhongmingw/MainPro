--
-- Author: 
-- Date: 2017-04-07 10:55:24
--

local ArenaProxy = class("ArenaProxy",base.BaseProxy)

function ArenaProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5310101,self.add5310101)-- 请求竞技场信息
    self:add(5310102,self.add5310102)-- 请求竞技场换一批
    self:add(5310103,self.add5310103)-- 请求竞技场排行榜
    self:add(5310104,self.add5310104)-- 请求竞技场排名奖励领取
    self:add(5310105,self.add5310105)-- 请求竞技场挑战
    self:add(5310106,self.add5310106)-- 请求竞技场扫荡
    self:add(5310107,self.add5310107)-- 请求竞技场跳过战斗
    self:add(5310202,self.add5310202)-- 请求竞技场清除挑战时间
    self:add(5310201,self.add5310201)-- 请求购买挑战次数
    self:add(5310202,self.add5310202)-- 请求竞技场清除挑战时间

    --竞技场进入场景广播
    self:add(8100101,self.add8100101)-- 竞技场广播进入场景
    self:add(8100102,self.add8100102)--  竞技场结束广播
end

function ArenaProxy:add5310101(data)
    -- body
    if data.status == 0 then
        cache.ArenaCache:setData(data)

        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ArenaProxy:add5310102(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ArenaProxy:add5310103(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ArenaRank)
        if view then
            view:add5310103(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ArenaProxy:add5310104(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ArenaRank)
        if view then
            view:add5310104(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ArenaProxy:add5310105(data)
    -- body
    if data.status == 0 then
        mgr.ViewMgr:closeAllView2()
    else
        GComErrorMsg(data.status)
    end
end

function ArenaProxy:add5310106(data)
    -- body
    if data.status == 0 then
        mgr.ViewMgr:openView(ViewName.ArenaSaoDown,function(view)
            -- body
            view:add5310106()
        end,data)

        self:send(1310101)
    else
        GComErrorMsg(data.status)
    end
end

function ArenaProxy:add5310107(data)
    -- body
    if data.status == 0 then


    else
        GComErrorMsg(data.status)
    end
end

function ArenaProxy:add5310201(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


function ArenaProxy:add5310202(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ArenaProxy:add8100101(data)
    -- body
    if data.status == 0 then
        --plog("8100101",8100101)
        mgr.FubenMgr:gotoFubenWar(ArenaScene)
    else
        GComErrorMsg(data.status)
    end
end

function ArenaProxy:add8100102(data)
    -- body
    if data.status == 0 then
        --plog("add8100102 add8100102 add8100102")
        if data.type == 0 then
            local view = mgr.ViewMgr:get(ViewName.ArenaFightView)
            if view then
                view:add8100102(data)
            end
        elseif data.type == 1 then--离线挂机抢夺
            mgr.ViewMgr:openView(ViewName.ArenaSaoDown,function(view)
                -- body
                view:add8100102()
            end,data)
            -- print("离线挂机抢夺广播")
            local view = mgr.ViewMgr:get(ViewName.WelfareView)
            if view then
                local view2 = mgr.ViewMgr:get(ViewName.ArenaSaoDown)
                if view2 then
                    view2:setHookTiaoguo()
                end
            end
        end       
    else
        GComErrorMsg(data.status)
    end
end


return ArenaProxy