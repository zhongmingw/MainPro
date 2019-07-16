--
-- Author: 
-- Date: 2017-02-06 17:30:21
--

local RedBagProxy = class("RedBagProxy",base.BaseProxy)

function RedBagProxy:init()
    self:add(5250401,self.add5250401) --请求红包列表返回
    self:add(5250402,self.add5250402) --请求发送红包返回
    self:add(5250403,self.add5250403) --请求在抢红包列表
    self:add(5250404,self.add5250404) --请求抢红包返回
    -- self:add(5250405,self.add5250405)
end
--请求
function RedBagProxy:send_1250401(param)
    self:send(1250401,param)
end

function RedBagProxy:add5250401(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RedBagView)
        if view then
            view:add5250401(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function RedBagProxy:send_1250402(param)
    self:send(1250402,param)
end

function RedBagProxy:add5250402( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RedBagView)
        if view then
            view:add5250402(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function RedBagProxy:send_1250403(param)
    self:send(1250403,param)
end

function RedBagProxy:add5250403( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RedBagView)
        if view then
            view:add5250403(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function RedBagProxy:send_1250404(param)
    self:send(1250404,param)
end

function RedBagProxy:add5250404( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RedBagView)
        if view then
            view:add5250404(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function RedBagProxy:send_1250405(param)
    self:send(1250405,param)
end

-- function RedBagProxy:add5250405( data )
--     -- body
--     if data.status == 0 then
--         local view = mgr.ViewMgr:get(ViewName.RedBagView)
--         if view then
--             view:add5250405(data)
--         end
--     else
--         GComErrorMsg(data.status)
--     end 
-- end

return RedBagProxy