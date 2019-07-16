-- 跨服城战协议
-- Author: Your Name
-- Date: 2018-04-17 15:15:29
--

local CityWarProxy = class("CityWarProxy",base.BaseProxy)

function CityWarProxy:init()
    self:add(5510101,self.add5510101) --请求跨服城战占领信息
    self:add(5510102,self.add5510102) --请求宣战城池
    self:add(5510103,self.add5510103) --请求跨服城战战报
    self:add(5510104,self.add5510104) --请求面板状态信息
    self:add(5510105,self.add5510105) --请求跨服城战每日奖励领取
    self:add(5510106,self.add5510106) --请求跨服城战连胜
    self:add(5510107,self.add5510107) --请求跨服城战终结

    self:add(8140201,self.add8140201) --跨服城战结束广播
    self:add(8140202,self.add8140202) --跨服城战追踪信息广播
end

function CityWarProxy:sendMsg(msgId,param)
    self.param = param
    self:send(msgId,param)
end
--请求跨服城战占领信息
function CityWarProxy:add5510101(data)
    if data.status == 0 then
        --连胜、终结红点刷新
        cache.PlayerCache:setRedpoint(attConst.A20204,0)
        cache.PlayerCache:setRedpoint(attConst.A20205,0)
        for k,v in pairs(data.otherReds) do
            cache.PlayerCache:setRedpoint(k,v)
        end
        cache.CityWarCache:setCityData(data.occupyInfos)
        cache.CityWarCache:setWarSceneId(data.warSceneId)
        cache.CityWarCache:setisXz(data.isXz)
        cache.CityWarCache:setAwardGot(data.awardGot)
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.CityWarAwards)
        if view then
            view:setCityInfos()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求宣战城池
function CityWarProxy:add5510102(data)
    if data.status == 0 then
        self:sendMsg(1510101,{awardGot = 0})
    else
        GComErrorMsg(data.status)
    end
end
--请求跨服城战战报
function CityWarProxy:add5510103(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.CityWarAwards)
        if view then
            view:setWarReports(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求面板状态信息
function CityWarProxy:add5510104(data)
    if data.status == 0 then
        cache.CityWarCache:setCityWarTrackData(data.cityStatuInfos)
        cache.CityWarCache:setCityDoorState(data.breakCity)
        -- printt("跨服城战追踪面板信息",data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setData({index = 16})
        else
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 16})
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求跨服城战每日奖励领取
function CityWarProxy:add5510105(data)
    if data.status == 0 then
        if data.items and #data.items > 0 then
            GOpenAlert3(data.items)
        end
        cache.PlayerCache:setRedpoint(attConst.A20169,0)
        local view = mgr.ViewMgr:get(ViewName.CityWarAwards)
        if view then
            view:refreshRed()
        end
        mgr.GuiMgr:updateRedPointPanels(attConst.A20169)
        self:sendMsg(1510101,{awardGot = 0})
    else
        GComErrorMsg(data.status)
    end
end

--请求跨服城战连胜
function CityWarProxy:add5510106(data)
    -- printt("连胜打印>>>>>>>>>>>>>",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.CityWarAwards)
        if view then
            view:setWinAwards(data)
            if data.reqType == 1 then
                cache.PlayerCache:setRedpoint(attConst.A20204,0)
                view:refreshRed()
                mgr.GuiMgr:updateRedPointPanels(attConst.A20204)
                self:sendMsg(1510101,{awardGot = 0})
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求跨服城战终结
function CityWarProxy:add5510107(data)
    -- printt("终结打印>>>>>>>>>>>>>",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.CityWarAwards)
        if view then
            view:setEndAwards(data)
            if data.reqType == 1 then
                cache.PlayerCache:setRedpoint(attConst.A20205,0)
                view:refreshRed()
                mgr.GuiMgr:updateRedPointPanels(attConst.A20205)
                self:sendMsg(1510101,{awardGot = 0})
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function CityWarProxy:add8140201(data)
    if data.status == 0 then
        -- print("跨服城战结束广播>>>>>>>>>>>>>>>")
        mgr.ViewMgr:openView2(ViewName.CityWarOverView, data.reports)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:endCityWarTime()
        end
    else
        GComErrorMsg(data.status)
    end
end

function CityWarProxy:add8140202(data)
    if data.status == 0 then
        -- printt("跨服城战广播追踪面板信息",data)
        cache.CityWarCache:setCityWarTrackData(data.cityStatuInfos)
        cache.CityWarCache:setCityDoorState(data.breakCity)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setData({index = 16})
        else
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 16})
        end
    else
        GComErrorMsg(data.status)
    end
end

return CityWarProxy