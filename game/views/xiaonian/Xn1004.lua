--
-- Author: 
-- Date: 2019-01-02 15:51:54
--

local Xn1004 = class("Xn1004",import("game.base.Ref"))

function Xn1004:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]

    self:initView()
end

function Xn1004:onTimer()
    -- body
    if not self.data then 
        return 
    end
    self.leftTime =  self.leftTime -1
    if self.leftTime <= 0 then
        local  view = mgr.ViewMgr:get(ViewName.XiaoNianView)
        if view then
            view:closeView()
        end
    end
end

function Xn1004:addMsgCallBack( data )
    -- body
    self.data =data
    self.leftTime = self.data.leftTime
end

function Xn1004:initView()
    -- body

    local goBossBtn = self.view:GetChild("n28")
    goBossBtn:GetChild("red").visible = false
    goBossBtn.onClick:Add(self.onClickGoBoss,self)

    local decText = self.view:GetChild("n27")
    decText.text = mgr.TextMgr:getTextByTable(language.xiaonian2019_02)
end

function Xn1004:onClickGoBoss()
    -- body
    GOpenView({id = 1049})
end
return Xn1004
