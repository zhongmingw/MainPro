--
-- Author: 
-- Date: 2018-09-05 17:48:55
--

local YouXunProxy = class("YouXunProxy",base.BaseProxy)

function YouXunProxy:init()
    self:add(5030601,self.addMsgCallBack)
    self:add(5030602,self.addMsgCallBack)
    self:add(5030603,self.addMsgCallBack)
    self:add(5030604,self.addMsgCallBack)
    self:add(5030605,self.addMsgCallBack)
    self:add(5030606,self.addMsgCallBack)
    self:add(5030638,self.addMsgCallBack)

    --self:add(5020507)
end

function YouXunProxy:sendMsg(msgId,param)
    -- body
    self.param = param
    self:send(msgId,param)
end

function YouXunProxy:addMsgCallBack(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YouXunView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return YouXunProxy