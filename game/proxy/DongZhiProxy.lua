--
-- Author: 
-- Date: 2018-12-11 20:42:19
--

local DongZhiProxy = class("DongZhiProxy",base.BaseProxy)

function DongZhiProxy:init()
    self:add(5030665,self.addMsgCallBack)
    self:add(5030663,self.addMsgCallBack)
    self:add(5030664,self.addMsgCallBack)
    self:add(5030666,self.add5030666)
    self:add(5030667,self.add5030667)
     -- self:add(8240205,self.add8240205)--记忆排行刷新广播
     self:add(5030675,self.add5030675)--记忆排行

    self:add(5030676,self.add5030676)--记忆饺宴信息
    self:add(8240204,self.add8240204)--记忆刷新广播
    



end

function DongZhiProxy:sendMsg(msgId,param)
    -- body
    self.param = param
    self:send(msgId,param)
end
function DongZhiProxy:addMsgCallBack(data)
    -- body
   
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DongZhiView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


--请求冬至抽奖
function DongZhiProxy:add5030666(data)
    if data.status == 0 then
        -- plog("data.lastTime",data.lastTime)
        local view = mgr.ViewMgr:get(ViewName.DongZhiJiaoYan)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求冬至连冲
function DongZhiProxy:add5030667(data)
    if data.status == 0 then
        -- plog("data.lastTime",data.lastTime)
        local view = mgr.ViewMgr:get(ViewName.DongZhiLianChong)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求记忆饺宴
function DongZhiProxy:add5030676(data)
    -- print("记忆饺宴活动信息返回~~~~~~~~~",data.status)
    if data.status == 0 then

        local view = mgr.ViewMgr:get(ViewName.JiYiHuaDengView)
        if not view then
            mgr.ViewMgr:openView2(ViewName.JiYiHuaDengView,data)
        else
            view:addMsgCallBack(data)
        end
    elseif data.status == 2030125 then--非活动时间
        local view = mgr.ViewMgr:get(ViewName.JiYiHuaDengView)
        if view then
            view:releaseTimer()
            if view.timeBar then
                view.timeBar.value = 0
            end
        else
            GComErrorMsg(data.status)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求记忆排行
function DongZhiProxy:add5030675(data)
    if data.status == 0 then
        -- plog("data.lastTime",data.lastTime)
        local view = mgr.ViewMgr:get(ViewName.JiYJiaoYanView)
        if view then
           

            local data1 = cache.ActivityCache:getJyjyData()
            for k,v in pairs(data1.scoreRankings) do
               v.WSScoreRankingInfo.roleId = data.scoreRankings[k].WSScoreRankingInfo.roleId
                v.WSScoreRankingInfo.ranking = data.scoreRankings[k].WSScoreRankingInfo.ranking
                v.WSScoreRankingInfo.score = data.scoreRankings[k].WSScoreRankingInfo.score
                v.WSScoreRankingInfo.roleName = data.scoreRankings[k].WSScoreRankingInfo.roleName

            end
             cache.ActivityCache:setJyjyData(data1)
            view:refreshRankInfo()
        end
    else
        GComErrorMsg(data.status)
    end
end


--请求记忆刷新
function DongZhiProxy:add8240204(data)
    -- print("请求记忆刷新")
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JiYiHuaDengView)
        if view then
            view:refeshCurSec()
        end
    else
        GComErrorMsg(data.status)
    end
end

return DongZhiProxy