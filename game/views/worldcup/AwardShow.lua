--
-- Author: 
-- Date: 2018-06-30 14:54:40
--奖励展示

local AwardShow = class("AwardShow",import("game.base.Ref"))

function AwardShow:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end
function AwardShow:initPanel()
    self.view = self.mParent.view:GetChild("n13")
    self.footballPanel = self.view:GetChild("n1")
    
    self.cheerleaderPanel = self.view:GetChild("n2")

    local yazhuBtn = self.view:GetChild("n0")
    yazhuBtn.onClick:Add(self.goYaZhu,self)

    -- self:initModel()
end

function AwardShow:initData()
    self:initModel()
end
function AwardShow:initModel()
    local footballSuit = conf.ActivityConf:getValue("football_suit_id")
    local cheerleader = conf.ActivityConf:getValue("cheerleader_suit_id")

    local modelObj1 = self.mParent:addModel(footballSuit[1],self.footballPanel)
    modelObj1:setSkins(footballSuit[1], footballSuit[2])
    modelObj1:setScale(160)
    modelObj1:setRotationXYZ(0,166,0)
    modelObj1:setPosition(45,-250,100)

    local modelObj2 = self.mParent:addModel(cheerleader[1],self.cheerleaderPanel)
    modelObj2:setSkins(cheerleader[1], cheerleader[2])
    modelObj2:setScale(160)
    modelObj2:setRotationXYZ(0,166,0)
    modelObj2:setPosition(45,-250,100)

end

function AwardShow:goYaZhu()
   self.mParent:goYaZhu()
end

return AwardShow