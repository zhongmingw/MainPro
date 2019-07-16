--
-- Author: 
-- Date: 2017-03-07 20:54:32
--

local SetMemberPanel = class("SetMemberPanel", base.BaseView)

function SetMemberPanel:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function SetMemberPanel:initView()
    self.guoobject = self.view:GetChild("n4")
end

function SetMemberPanel:setData(data_)

end

function SetMemberPanel:setPosition(pos)
    -- body
    local btn = self.view:GetChild("n0") 
    self.guoobject.xy = pos --GRoot.inst:LocalToGlobal(Vector2(pos.x,pos.y) ) 
    plog(pos.x)
end

return SetMemberPanel