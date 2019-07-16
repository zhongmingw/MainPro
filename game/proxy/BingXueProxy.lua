--
-- Author: 
-- Date: 2019-01-02 11:58:45
--

local BingXueProxy = class("BingXueProxy",base.BaseProxy)

function BingXueProxy:init()
    self:add(5030698,self.addMsgCallBack)--冰雪节登录
    self:add(5030699,self.addMsgCallBack)--冰雪节登山
    self:add(5030700,self.addMsgCallBack)--冰雪节boss
    self:add(5030701,self.addMsgCallBack)--冰雪节兑换
    self:add(5030702,self.add5030702)--消费抽抽乐

end

function BingXueProxy:sendMsg(msgId,param)
    self.param = param
    self:send(msgId,param)
end

function BingXueProxy:addMsgCallBack( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BingXueMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--冰雪节消费抽抽乐
function BingXueProxy:add5030702( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XiaoFeiView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return BingXueProxy