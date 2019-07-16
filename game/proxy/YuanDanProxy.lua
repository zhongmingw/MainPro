--
-- Author: 
-- Date: 2018-12-17 22:43:45
--

local YuanDanProxy = class("YuanDanProxy",base.BaseProxy)

function YuanDanProxy:init()
    self:add(5030680, self.add5030680)-- 请求元旦祈福
    self:add(5030677, self.addMsgCallBack)-- 请求元旦登录
    self:add(5030678, self.addMsgCallBack)-- 请求元旦投资
    self:add(5030679, self.addMsgCallBack)-- 请求元旦boss
    self:add(5030681, self.add5030681)-- 请求元旦转盘
    self:add(5030682, self.addMsgCallBack)-- 请求元旦探索


end
function YuanDanProxy:sendMsg(msgId, param)
    -- body
    self.param = param
    self:send(msgId,param)
end
function YuanDanProxy:add5030680(data )
    if data.status == 0 then
        if data.reqType ~= 0 then
            GOpenAlert3(data.items)
        end
        local view = mgr.ViewMgr:get(ViewName.YuanDanQiFuView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function YuanDanProxy:addMsgCallBack(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YuanDanMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function YuanDanProxy:add5030681(data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YuanDanZhuanPan)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


return YuanDanProxy