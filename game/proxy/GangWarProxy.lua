--
-- Author: 
-- Date: 2017-05-12 11:19:43
--
--仙盟战
local GangWarProxy = class("GangWarProxy",base.BaseProxy)

function GangWarProxy:init()
    self:add(5360101,self.add5360101)--请求仙盟战信息
    self:add(5360102,self.add5360102)--请求仙盟战上一次积分排名
    self:add(5360103,self.add5360103)--请求仙盟战场景排行榜
    self:add(5360104,self.add5360104)--请求仙盟战场景奖励信息
    self:add(5360105,self.add5360105)--请求仙盟战场景信息

    self:add(8140101,self.add8140101)--仙盟战血条广播
    self:add(8140102,self.add8140102)--仙盟战结束广播
    self.bossDeadNum = 0
end
--请求仙盟战信息
function GangWarProxy:add5360101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙盟战上一次积分排名
function GangWarProxy:add5360102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ScoreRankView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙盟战场景排行榜
function GangWarProxy:add5360103(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.GangBossInfoView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙盟战场景奖励信息
function GangWarProxy:add5360104(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.GangBossInfoView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function GangWarProxy:add5360105(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.GangBossInfoView)
        if view then
            view:setData(data)
        end
        cache.GangWarCache:setBossList(data.bossInfos)

        if not mgr.ViewMgr:get(ViewName.TrackView) then
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 6})
        end
    else
        GComErrorMsg(data.status)
    end
end
--仙盟战血条广播
function GangWarProxy:add8140101(data)
    if data.status == 0 then
        cache.GangWarCache:setBossList(data.bossList)
        local num = 0
        for k,v in pairs(data.bossList) do
            if v.x == 0 and v.y == 0 then
                num = num + 1
            end
        end
        if self.bossDeadNum ~= num then--boss有死亡就检测下一个boss
            -- plog(self.bossDeadNum,num)
            -- printt(data.bossList)
            mgr.HookMgr:enterHook()
            -- mgr.TimerMgr:addTimer(0.5, 1, function()
            --     mgr.HookMgr:gangBossHook() 
            -- end)
            self.bossDeadNum = num
        end
        local view = mgr.ViewMgr:get(ViewName.GangBossInfoView)
        if view then
            view:refreshBoss()
        end

        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setGangBossData()
        end
    else
        GComErrorMsg(data.status)
    end
end
--仙盟战结束广播
function GangWarProxy:add8140102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:gangBossData()
        end
        local t = {ranks = data.ranks,titleUrl = UIItemRes.gangwar01,type = 3}
        mgr.ViewMgr:openView2(ViewName.AwardsCaseView,t)
    else
        GComErrorMsg(data.status)
    end
end

return GangWarProxy