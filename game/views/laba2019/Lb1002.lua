--
-- Author: 
-- Date: 2019-01-02 15:51:54
--

local Lb1002 = class("Lb1002",import("game.base.Ref"))

function Lb1002:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]

    self:initView()
end

function Lb1002:onTimer()
    -- body
    if not self.data then 
        return 
    end
end

function Lb1002:addMsgCallBack( data )
    -- body
    self.data =data
end

function Lb1002:initView()
    -- body

    local goBossBtn = self.view:GetChild("n28")
    goBossBtn:GetChild("red").visible =false
    goBossBtn.onClick:Add(self.onClickGoBoss,self)

    local decText =self.view:GetChild("n27")
    decText.text=mgr.TextMgr:getTextByTable(language.labaDlhl2019_10)
end

function Lb1002:onClickGoBoss()
    -- body
    GOpenView({id = 1049})
end
return Lb1002

