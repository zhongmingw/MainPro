--
-- Author: 
-- Date: 2018-10-22 19:20:40
--

local WSJProxy = class("WSJProxy",base.BaseProxy)

function WSJProxy:init()
    self:add(5030642, self.addMsgCallBack) -- 万圣节登录奖励
    self:add(5030643, self.addMsgCallBack) -- 万圣节boss
    self:add(5030644, self.addMsgCallBack) -- 万圣节兑换
    self:add(5030641, self.addMsgCallBack) -- 万圣节兑换
    self:add(5028201, self.add5028201) -- 请求降妖除魔场景信息
    self:add(5028202, self.add5028202) -- 请求降妖除魔提交南瓜

end

function WSJProxy:sendMsg(msgId, param)
    -- body
    self.param = param
    self:send(msgId,param)
end

function WSJProxy:addMsgCallBack(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ActWSJMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function WSJProxy:add5028201(data)
    if data.status == 0 then
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 18})
    else
        GComErrorMsg(data.status)
    end
end

function WSJProxy:add5028202(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setWsjTrack()
        else
            mgr.ViewMgr:openView2(ViewName.TrackView, {index = 18})
        end
        GOpenAlert3(data.items)
    else
        GComErrorMsg(data.status)
    end
end

return WSJProxy