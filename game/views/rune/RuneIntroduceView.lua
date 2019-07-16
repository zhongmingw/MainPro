--
-- Author: 
-- Date: 2018-02-26 20:19:33
--
--符文信息
local RuneIntroduceView = class("RuneIntroduceView", base.BaseView)

function RuneIntroduceView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function RuneIntroduceView:initView()
    local closeBtn = self.view:GetChild("n3")
    self:setCloseBtn(closeBtn)
    self.itemObj = self.view:GetChild("n2")
    self.nameText = self.view:GetChild("n4")
    self.view:GetChild("n5").text = language.rune13
    self.view:GetChild("n6").text = language.rune14

    self.attriText = self.view:GetChild("n8")
    self.desc = self.view:GetChild("n9")
end

function RuneIntroduceView:initData(data)
    local mid = data.mid or data.id
    local itemData = {mid = mid,amount = 1}
    GSetItemData(self.itemObj, itemData)
    self.nameText.text = mgr.TextMgr:getColorNameByMid(mid)

    local color = conf.ItemConf:getQuality(mid)
    local type = conf.ItemConf:getFwType(mid)
    local level = data.propMap and data.propMap[517] or 1
    local id = mgr.RuneMgr:getAttiId(color,type,level)
    local attriData = conf.RuneConf:getFuwenlevelup(id)
    local t = GConfDataSort(attriData)
    for k,v in pairs(t) do
        local str = conf.RedPointConf:getProName(v[1]).."+"..mgr.TextMgr:getTextColorStr(GProPrecnt(v[1],v[2]), 7)
        if k == 1 then
            self.attriText.text = str
        else
            self.attriText.text = self.attriText.text.."\n"..str
        end
    end
    local floor = conf.ItemConf:getTowerFloor(mid)
    self.desc.text = string.format(language.rune34, floor)
end

return RuneIntroduceView