local GanEnProxy = class("GanEnProxy",base.BaseProxy)

function GanEnProxy:init()
    self:add(5030652,self.addMsgCallBack)
    self:add(5030653,self.addMsgCallBack)
    self:add(5030654,self.addMsgCallBack)
    -- self:add(5030608,self.addMsgCallBack)
    -- self:add(5030610,self.addMsgCallBack)
    -- self:add(5030612,self.addMsgCallBack)
end

function GanEnProxy:sendMsg(msgId,param)
    -- body
    self.param = param
    self:send(msgId,param)
end

function GanEnProxy:addMsgCallBack(data)
    -- body

    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.GanEnView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return GanEnProxy