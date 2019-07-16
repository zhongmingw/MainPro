--
-- Author: 
-- Date: 2017-11-29 14:28:45
--
--仙盟活动（仙盟争霸，主宰神殿等）
local XmhdProxy = class("XmhdProxy",base.BaseProxy)

function XmhdProxy:init()
    self:add(5360201,self.add5360201)--请求参战资格列表
    self:add(5360202,self.add5360202)--请求主宰仙盟信息以及奖励
    self:add(5360203,self.add5360203)--请求仙盟战追踪信息
    self:add(5360204,self.add5360204)--请求分配奖励
    self:add(5360205,self.add5360205)--请求仙盟各个玩家位置信息
    self:add(5360206,self.add5360206)--请求仙盟战场日志
    self:add(5360207,self.add5360207)--请求场景中任意一个玩家位置

    self:add(8140103,self.add8140103)--仙盟战追踪信息广播
    self:add(8140104,self.add8140104)--仙盟战结束广播
    self:add(8140105,self.add8140105)--仙盟战水晶状态广播
end
--请求参战资格列表
function XmhdProxy:add5360201(data)
    -- printt("请求参战资格列表")
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end  
end
--请求主宰仙盟信息以及奖励
function XmhdProxy:add5360202(data)
    printt("请求主宰仙盟信息以及奖励",data)
    if data.status == 0 then
        if data.reqType == 2 then--领取后
            local redNum = cache.PlayerCache:getRedPointById(attConst.A20154)
            local num = math.max(redNum - 1,0)
            mgr.GuiMgr:redpointByVar(attConst.A20154 ,num)--清理红点
        end
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end  
end
--请求仙盟战追踪信息
function XmhdProxy:add5360203(data)
    -- printt("请求仙盟战追踪信息",data)
    if data.status == 0 then
        cache.FubenCache:setFubenModular(1139)
        cache.XmzbCache:setTrackData(data)
        mgr.ViewMgr:openView2(ViewName.XmzbMapView)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 13})
        mgr.ViewMgr:openView2(ViewName.MiniMapView)
    else
        GComErrorMsg(data.status)
    end  
end
--请求分配奖励
function XmhdProxy:add5360204(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FinalWinView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.WinAwardsView)
        if view then
            view:addMsgCallBack(data)
        end
        local isClear = false
        if data.reqType == 1 then
            data.winFp = 0
            isClear = true
        elseif data.reqType == 2 then
            data.killFp = 0
            isClear = true
        end
        if isClear then
            local redNum = cache.PlayerCache:getRedPointById(attConst.A20154)
            local num = math.max(redNum - 1,0)
            mgr.GuiMgr:redpointByVar(attConst.A20154 ,num)--清理红点
        end
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end  
end
--请求仙盟各个玩家位置信息
function XmhdProxy:add5360205(data)
    -- printt("请求仙盟各个玩家位置信息",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MapView)
        if view then
            view:updateXmzbMap(data)
        end
        local view = mgr.ViewMgr:get(ViewName.MiniMapView)
        if view then
            view:updateXmzbMap(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end
--请求仙盟战场日志
function XmhdProxy:add5360206(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RecordJsRankView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end
--请求场景中任意一个玩家位置
function XmhdProxy:add5360207(data)
    if data.status == 0 then
        -- mgr.HookMgr:xmzbHook(data)
    else
        GComErrorMsg(data.status)
    end 
end
--仙盟战追踪信息广播
function XmhdProxy:add8140103(data)
    -- printt("仙盟战追踪信息广播",data)
    if data.status == 0 then
        cache.XmzbCache:updateTrackData(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setXmzbData()
        end
    else
        GComErrorMsg(data.status)
    end 
end
--仙盟战结束广播
function XmhdProxy:add8140104(data)
    -- printt("仙盟战结束广播",data)
    if data.status == 0 then
        mgr.ViewMgr:openView2(ViewName.RecordJsRankView,data)
    else
        GComErrorMsg(data.status)
    end 
end
--仙盟战水晶状态广播
function XmhdProxy:add8140105(data)
    -- printt("仙盟战水晶状态广播",data)
    if data.status == 0 then
        cache.XmzbCache:updateCrystalStatusMap(data)
        for k,v in pairs(mgr.ThingMgr:objsByType(ThingType.monster)) do
            v:updateCrystalSkin(true)
        end
        mgr.HookMgr:crystalChange()
    else
        GComErrorMsg(data.status)
    end
end

return XmhdProxy