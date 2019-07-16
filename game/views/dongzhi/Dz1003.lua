--
-- Author: 
-- Date: 2018-12-11 17:57:44
--

local Dz1003 = class("Dz1003",import("game.base.Ref"))

function Dz1003:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end




function Dz1003:addMsgCallBack(data)
    -- body
    printt("1111111",data)
    self.data  = data
     self.Btn.visible = true
       self.DaoJiShiText.visible = true


    if data.curRound == 0 then 
        local severTime = mgr.NetMgr:getServerTime()
        self.time = GTotimeString13( data.actStartTime -severTime )
        self.time = tonumber(self.time)+60
          print(self.time)
        --  倒计时
        self:releaseTimer()
        if not self.actTimer then
            self:onTimer()
            self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
        end
    else
        self.Btn.visible = true
       self.DaoJiShiText.visible = false

    end
end

function Dz1003:onClickGet(context)

    self.parent:closeView()
    GOpenView({id = 1425})
end

function Dz1003:initView()
    
   
    self.Btn = self.view:GetChild("n4")
    self.Btn.onClick:Add(self.onClickGet,self)

    local Text = self.view:GetChild("n3")
    Text.text = language.dz05
  
     self.DaoJiShiText = self.view:GetChild("n5")
   self.DaoJiShiText.text = ""

end


function Dz1003:onTimer()
    if self.data then
        self.DaoJiShiText.text = tostring(self.time) or ""
        if self.data.curRound == 0 and self.time <= 0 then
            self:releaseTimer()
           self.Btn.visible = true
           self.DaoJiShiText.visible = false
         self.time = self.time - 1
        end
    end
   
end

function Dz1003:releaseTimer()
    if self.actTimer then
        self.parent:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end
return Dz1003