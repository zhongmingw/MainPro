--
-- Author: 
-- Date: 2019-01-09 20:13:02
--

local ChunJieProxy2019 = class("ChunJieProxy2019",base.BaseProxy)

function ChunJieProxy2019:init()
     self:add(5030709,self.addMsgCallBack) -- 请求活动日程
     self:add(5030710,self.addMsgCallBack) -- 请求春节一阶段登录
     self:add(5030711,self.addMsgCallBack) -- 请求春节节节高升
     self:add(5030712,self.addMsgCallBack) -- 请求春节二阶段登录
     self:add(5030713,self.addMsgCallBack) -- 请求春节二阶段年年有余


end

function ChunJieProxy2019:sendMsg(msgId,param)
    -- body
    self.param = param
    self:send(msgId,param)
end

function ChunJieProxy2019:addMsgCallBack(data)
    -- body
   
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ChunJieView2019)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return ChunJieProxy2019