--旺财
-- Author: 
-- Date: 2017-04-12
--
local WangcaiProxy = class("WangcaiProxy",base.BaseProxy)

function WangcaiProxy:init()
    -- body
    self:add(5320101,self.add5320101)--请求旺财信息
    self:add(5320102,self.add5320102)--请求旺财领取收益
    self:add(5320103,self.add5320103)--请求旺财进阶
end

function WangcaiProxy:sendMsg(sendId,param)
    self:send(sendId,param)
end

function WangcaiProxy:add5320101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WangcaiView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function WangcaiProxy:add5320102(data)
    -- body
    if data.status == 0 then
        local mainview = mgr.ViewMgr:get(ViewName.MainView)
        if mainview then
            mainview:refreshRed()
        end
        if data.reqType == 0 then
            local view = mgr.ViewMgr:get(ViewName.WangcaiView)
            if view then
                view:updateEarnings(data)
            end
        else
            GOpenAlert3(data.items)
            proxy.WangcaiProxy:sendMsg(1320101)
        end
    else
        GComErrorMsg(data.status)
    end
end

function WangcaiProxy:add5320103(data)
    -- body
    if data.status == 0 then
        local mainview = mgr.ViewMgr:get(ViewName.MainView)
        if mainview then
            mainview:refreshRed()
        end
        local view = mgr.ViewMgr:get(ViewName.WangcaiView)
        if view then
            view:updateJinjie(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return WangcaiProxy