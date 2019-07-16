--
-- Author: 
-- Date: 2018-01-03 15:27:53
--

local BeachProxy = class("BeachProxy",base.BaseProxy)

function BeachProxy:init()
    self:add(5020421,self.add5020421)-- 请求魅力温泉显示信息
    self:add(5020422,self.add5020422)-- 请求魅力温泉排行
    self:add(5020423,self.add5020423)-- 请求魅力温泉收送礼物
    self:add(5020424,self.add5020424)-- 请求魅力温泉魅力奖励

    self:add(8190201,self.add8190201)-- 魅力温泉赠送广播
    self:add(8190202,self.add8190202)-- 魅力温泉刷新礼物广播
    self:add(8190203,self.add8190203)-- 魅力温泉刷新礼物广播
end

function BeachProxy:sendMsg(msgId,param)
    -- body
    self:send(msgId,param)
end

function BeachProxy:add5020421(data)
    -- body
    if data.status == 0 then
        cache.BeachCache:setData(data)
        local view = mgr.ViewMgr:get(ViewName.BeachMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BeachProxy:add5020422( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BeachRank)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BeachProxy:add5020423(data)
    -- body
    if data.status == 0 then
        if data.reqType == 1 then
            --送礼
            GComAlter(language.beach30)

            if data.cid == 1 then
                cache.BeachCache:reduceXiaoYazi()
            elseif data.cid == 2 then
                cache.BeachCache:reduceFeizhao()
            end

        elseif data.reqType == 2 then
            --赠送记录 
        elseif data.reqType == 3 then
            --收到记录
        end
        local view = mgr.ViewMgr:get(ViewName.BeachRecord)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.BeachSong)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BeachProxy:add5020424( data )
    -- body
    if data.status == 0 then
        GOpenAlert3(data.items)
        --立刻刷新一次
        self:sendMsg(1020421)
    else
        GComErrorMsg(data.status)
    end
end


function BeachProxy:add8190201( data )
    -- body
    if data.status == 0 then
        if not mgr.FubenMgr:isMeiliBeach(cache.PlayerCache:getSId()) then
            return
        end

        local condata = conf.BeachConf:getPresentcost(data.mid)
        if condata then
            GComAlter(string.format(language.beach31,data.tarName,condata.name))
        end
    else
        GComErrorMsg(data.status)
    end
end

function BeachProxy:add8190202(data)
    -- body
    if data.status == 0 then
        if not mgr.FubenMgr:isMeiliBeach(cache.PlayerCache:getSId()) then
            return
        end
        mgr.ViewMgr:openView2(ViewName.BeachTopTips, data)

        mgr.ViewMgr:openView2(ViewName.Alert15, 4020151)
    else
        GComErrorMsg(data.status)
    end
end

function BeachProxy:add8190203( data)
    -- body
    if data.status == 0 then
        if not mgr.FubenMgr:isMeiliBeach(cache.PlayerCache:getSId()) then
            return
        end
        if data.cid == 1 then
            cache.BeachCache:plusXiaoYazi()
        elseif data.cid == 2 then
            cache.BeachCache:plusFeizhao()
        end
        local condata = conf.BeachConf:getPresentcost(data.cid)
        if condata then
            local info = {text = condata.name,count = 1,color = 1}
            mgr.TipsMgr:addRightTip(info)--道具飘字
        end
    else
        GComErrorMsg(data.status)
    end
end

return BeachProxy