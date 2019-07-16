--
-- Author: 
-- Date: 2019-01-02 15:19:50
--
--登陆有礼
local Cj1003 = class("Cj1003",import("game.base.Ref"))

function Cj1003:ctor(parent,id)
    self.moduleId = id
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Cj1003:onTimer()
    -- body

    if not self.data then return end
    -- local severTime =  mgr.NetMgr:getServerTime()
    -- if severTime >= self.data.actEndTime then
    --     local  view = mgr.ViewMgr:get(ViewName.ChunJieView2019)
    --     if view then
    --         view:closeView()
    --     end
    -- end
end

function Cj1003:addMsgCallBack( data )
    self.data = data
    printt("春节节节高升",data)
    
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self.parent:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function Cj1003:initView()
    self.btn = {}
    for i=18,21 do
        local btn = self.view:GetChild("n"..i)
        table.insert(self.btn, btn)
    end
end
  

function Cj1003:onClickGet( context )
    local data = context.sender.data
    local reqType = data.reqType
    proxy.GuoQingProxy:sendMsg(1030688,{reqType = reqType})

end




return Cj1003