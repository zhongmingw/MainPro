--[[--

]]

local BaseProxy = class("BaseProxy")


function BaseProxy:ctor()
    self.msgs = {}
    self:init()
end

function BaseProxy:init()

end

function BaseProxy:add(msgId,callBack)
	 mgr.NetMgr:add(msgId,handler(self,callBack))
end

function BaseProxy:send(msgId,data_)
  	if data_ == nil then data_ = {} end
  	mgr.NetMgr:send(msgId,data_)
end

function BaseProxy:isConnect()
	 return mgr.NetMgr.isConnect
end

return BaseProxy