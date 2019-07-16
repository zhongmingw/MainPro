--
-- Author: 
-- Date: 2018-01-12 14:58:13
--
local Equipchange = import(".Equipchange")
local Equipup = import(".Equipup")
local PetEquipView = class("PetEquipView", base.BaseView)

function PetEquipView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end

function PetEquipView:initView()
    local btnclose = self.view:GetChild("n1")
    self:setCloseBtn(btnclose)

    local btn1 = self.view:GetChild("n15")
    btn1.title = language.pet06
    local btn1 = self.view:GetChild("n16")
    btn1.title = language.pet02

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.setItemMsg,self)
end

function PetEquipView:initData(data)
    -- body
    self.data = data
    if (data.index or 0) == self.c1.selectedIndex then
        self:setItemMsg()
    else
        self.c1.selectedIndex =  data.index or 0
    end
    
end

function PetEquipView:setData(data_)

end

function PetEquipView:setItemMsg()
    -- body
    if self.c1.selectedIndex == 0 then
        --装备替换
        if not self.equipchange then
            self.equipchange = Equipchange.new(self.view:GetChild("n29"))
        end
        self.equipchange:setData(self.data.data)
    elseif self.c1.selectedIndex == 1 then
        --装备升级
        if not self.equipup then
            self.equipup = Equipup.new(self.view:GetChild("n53"))
        end
        self.equipup:setData(self.data.data)
    end
end

function PetEquipView:addMsgCallBack(data)
    -- body
    if self.c1.selectedIndex == 0 then
        if data.msgId == 5490104 or data.msgId == 5040403 then
            --装备穿戴
            if self.equipchange then
                self.equipchange:addMsgCallBack(data)
            end
        end
    elseif self.c1.selectedIndex == 1 then
        if data.msgId == 5490105 or data.msgId == 5040403 then
            --装备吞噬
            if self.equipup then
                self.equipup:addMsgCallBack(data)
            end
        end
    end
end

return PetEquipView