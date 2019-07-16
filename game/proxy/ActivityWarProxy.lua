--
-- Author: 
-- Date: 2017-12-26 14:23:05
--
--活动玩法
local ActivityWarProxy = class("ActivityWarProxy",base.BaseProxy)

function ActivityWarProxy:init()
    self:add(5470101,self.add5470101)--请求雪人入口信息
    self:add(5470102,self.add5470102)--请求雪人作战场景任务追踪
    self:add(5470103,self.add5470103)--请求雪人大战排行榜
    self:add(5030179,self.add5030179)--请求猜灯谜会活动信息
    self:add(5030180,self.add5030180)--请求灯谜答题面板信息
    self:add(5030181,self.add5030181)--请求灯谜排行信息
    self:add(5030182,self.add5030182)--请求灯谜答题信息

    self:add(8110304,self.add8110304)--雪战BOSS血量广播
    self:add(8110305,self.add8110305)--雪战BOSS血量广播
    self:add(8110306,self.add8110306)--雪战技能次数广播
    self:add(8110501,self.add8110501)--猜灯谜会答题刷新广播
    self:add(8110502,self.add8110502)--猜灯谜会答题刷新广播
end
--请求雪人入口信息
function ActivityWarProxy:add5470101(data)
    -- printt("请求雪人入口信息",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YdactMainView)
        if view then
            view:addServerCallback(data)
        end

        --EVE 小年活动
        local view = mgr.ViewMgr:get(ViewName.LunarYearMainView)
        if view then
            view:addMsgCallBack(data)
        end

        --国庆活动
        local view = mgr.ViewMgr:get(ViewName.ActGuoQingView)
        if view then
            view:addMsgCallBack(data)
        end

        --冰雪节活动
        local view = mgr.ViewMgr:get(ViewName.BingXueMainView)
        if view then
            --printt("雪地作战",data)
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求雪人作战场景任务追踪
function ActivityWarProxy:add5470102(data)
    -- printt("请求雪人作战场景任务追踪",data)
    if data.status == 0 then
        cache.ActivityWarCache:setXdzzData(data)
        cache.ActivityWarCache:setXdzzBoss(data.bossList)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 14})
        mgr.ViewMgr:openView2(ViewName.WarSkillView,data)
        mgr.TimerMgr:addTimer(1, 1, function()
            if gRole then
                gRole:setGangName(cache.PlayerCache:getGangName())--调用一下仙盟，让其可以隐藏
                gRole:createHead()
                gRole:refreshScore({[515] = data.score})
            end
        end)
        mgr.QualityMgr:setShieldAllPets(false)
    else
        GComErrorMsg(data.status)
    end
end
--请求雪人大战排行榜
function ActivityWarProxy:add5470103(data)
    -- printt("请求雪人大战排行榜",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YdXdzzRankView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求猜灯谜会活动信息
function ActivityWarProxy:add5030179(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LanternMainView)
        if view then 
            view:addServerCallback(data)
        end
        --国庆活动
        local view = mgr.ViewMgr:get(ViewName.ActGuoQingView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求灯谜排行信息
function ActivityWarProxy:add5030181(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LanternRankView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求灯谜答题信息
function ActivityWarProxy:add5030182(data)
    if data.status == 0 then
        if data.reqType == 2 then--答题
            local confData = conf.ActivityWarConf:getGuessQuestion(data.subjectId)
            if confData.answer == data.answer then
                local cacaheData = cache.ActivityWarCache:getCdmhData()
                local score = data.myScore - cacaheData.myScore
                GComAlter(string.format(language.lantern14, score))
            else
                GComAlter(language.lantern15)
            end
        end
        cache.ActivityWarCache:updateCdmhData(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setCdmhData(true)
        else
            cache.ActivityWarCache:setCdmhData(data)
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 15})
        end
        mgr.TimerMgr:addTimer(1, 1, function()
            if gRole then
                gRole:setGangName(cache.PlayerCache:getGangName())--调用一下仙盟，让其可以隐藏
                gRole:createHead()
                gRole:refreshScore({[516] = data.myScore})
            end
        end)
        local view = mgr.ViewMgr:get(ViewName.DaTiView)
        if view then
            view:setData(data)
        else
            mgr.ViewMgr:openView2(ViewName.DaTiView, data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--雪战BOSS血量广播
function ActivityWarProxy:add8110304(data)
    -- printt("雪战BOSS血量广播",data)
    if data.status == 0 then
        cache.ActivityWarCache:updateXdzzBoss(data.bossList)
    else
        GComErrorMsg(data.status)
    end
end
--
function ActivityWarProxy:add8110305(data)
    if data.status == 0 then
        mgr.ViewMgr:openView2(ViewName.XdzzTipView, data)
    else
        GComErrorMsg(data.status)
    end
end
--雪战技能次数广播
function ActivityWarProxy:add8110306(data)
    -- printt("雪战技能次数广播",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WarSkillView)
        if view then
            view:setSkillsCout(data.skills)
        end
    else
        GComErrorMsg(data.status)
    end
end
--猜灯谜会答题刷新广播
function ActivityWarProxy:add8110501(data)
    if data.status == 0 then
        cache.ActivityWarCache:updateCdmhData(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setCdmhData()
        end
        local view = mgr.ViewMgr:get(ViewName.DaTiView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--猜灯谜答题排行刷新广播
function ActivityWarProxy:add8110502(data)
    if data.status == 0 then
        cache.ActivityWarCache:updateRankData(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setCdmhData()
        end
    else
        GComErrorMsg(data.status)
    end
end

return ActivityWarProxy