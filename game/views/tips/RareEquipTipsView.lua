--
-- Author: 
-- Date: 2017-12-06 17:01:54
--
--稀有装备获得提示
local RareEquipTipsView = class("RareEquipTipsView", base.BaseView)

function RareEquipTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function RareEquipTipsView:initView()
    self.item = self.view:GetChild("n1")
    self.t0 = self.view:GetTransition("t0")
end

function RareEquipTipsView:initData()
    self:onTimer()
end

function RareEquipTipsView:onTimer()
    local equipData = cache.PackCache:getRareEquipData()
    if equipData then
        GSetItemData(self.item:GetChild("n1"),equipData)
        self.item:GetChild("n2").text = mgr.TextMgr:getColorNameByMid(equipData.mid,equipData.amount)
        self.t0:Play()
        self:addTimer(1.25, 1, function( ... )
            cache.PackCache:cleanRareEquipData()
            self:onTimer()
        end)
    else
        self:closeView()
    end
end
--创建item
function RareEquipTipsView:createItem()
    if self.obj then
        self.obj.alpha = 100
        return self.obj
    end
    return UIPackage.CreateObject("tips" , "RareEquip")
end

function RareEquipTipsView:dispose(clear)
    cache.PackCache:cleanRareEquipData(true)
    self.super.dispose(self,clear)
end

return RareEquipTipsView