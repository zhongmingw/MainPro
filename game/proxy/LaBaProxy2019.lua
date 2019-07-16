--
-- Author: 
-- Date: 2019-01-02 11:58:45
--

local LaBaLaBaProxy2019 = class("LaBaLaBaProxy2019",base.BaseProxy)

function LaBaLaBaProxy2019:init()
    self:add(5030688,self.addMsgCallBack)--登录领奖
    self:add(5030689,self.addMsgCallBack)--请求腊八boss剩余时间
    self:add(5030690,self.addMsgCallBack)--请求腊八粥
    --self:add(5030691,self.addMsgCallBack)--请求腊八消费排行榜
 
end

function LaBaLaBaProxy2019:sendMsg(msgId,param)
    self.param = param
    self:send(msgId,param)
end

function LaBaLaBaProxy2019:addMsgCallBack( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LaBaView2019)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return LaBaLaBaProxy2019