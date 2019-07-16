--皇陵之战
local HuanglingProxy = class("HuanglingProxy",base.BaseProxy)

function HuanglingProxy:ctor()
    -- body
    self:add(5340101,self.add5340101) --请求皇陵之战是否开启
    self:add(5340102,self.add5340102) --请求皇陵之战场景信息
end

function HuanglingProxy:sendMsg(msgId, param)
    -- body
    self:send(msgId,param)
end

function HuanglingProxy:add5340101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangMian)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function HuanglingProxy:add5340102(data)
    -- body
    if data.status == 0 then
        cache.FubenCache:setFubenModular(1078)
        -- print("皇陵之战场景返回",data.nextBossRefreshTime)
        cache.HuanglingCache:setBossNum(data.refreshBossNum)
        cache.HuanglingCache:setBossTimeCache(data.nextBossRefreshTime)
        cache.HuanglingCache:setTaskCache(data.taskList)
        cache.HuanglingCache:setBossCache(data.bossList)
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end

return HuanglingProxy