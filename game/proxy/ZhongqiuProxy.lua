--
-- Author: wx
-- Date: 2018-09-10 16:26:34
--

local ZhongqiuProxy = class("ZhongqiuProxy",base.BaseProxy)

function ZhongqiuProxy:init()
    self:add(5030613,self.addMsgCallBack)
    self:add(5030609,self.addMsgCallBack)
    self:add(5030611,self.addMsgCallBack)
    self:add(5030608,self.addMsgCallBack)
    self:add(5030610,self.addMsgCallBack)
    self:add(5030612,self.addMsgCallBack)
end

function ZhongqiuProxy:sendMsg(msgId,param)
    -- body
    self.param = param
    self:send(msgId,param)
end

function ZhongqiuProxy:addMsgCallBack(data)
    -- body
    print(data.status)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhongQiuView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return ZhongqiuProxy