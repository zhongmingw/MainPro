local ShuangShiErProxy = class("ShuangShiErProxy",base.BaseProxy)

function ShuangShiErProxy:init()
    self:add(5030660,self.addMsgCallBack)
    self:add(5030661,self.addMsgCallBack)
    self:add(5030662,self.addMsgCallBack)
    -- self:add(5030608,self.addMsgCallBack)
    -- self:add(5030610,self.addMsgCallBack)
    -- self:add(5030612,self.addMsgCallBack)
end

function ShuangShiErProxy:sendMsg(msgId,param)
    -- body
    self.param = param
    self:send(msgId,param)
end

function ShuangShiErProxy:addMsgCallBack(data)
    -- body

    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShuangShiErView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return ShuangShiErProxy