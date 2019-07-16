--
-- Author: Your Name
-- Date: 2018-09-18 10:50:35
--国庆活动
local GuoQingProxy = class("GuoQingProxy",base.BaseProxy)

function GuoQingProxy:init()
    self:add(5030617,self.addMsgCallBack)--登录领奖
    self:add(5030618,self.addMsgCallBack)--充值大礼
    self:add(5030619,self.addMsgCallBack)--消费豪礼
    self:add(5030620,self.addMsgCallBack)--欢乐兑换
    self:add(5030621,self.addMsgCallBack)--激战boss
end

function GuoQingProxy:sendMsg(msgId,param)
    self.param = param
    self:send(msgId,param)
end

function GuoQingProxy:addMsgCallBack( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ActGuoQingView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return GuoQingProxy