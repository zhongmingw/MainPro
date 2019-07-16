--
-- Author: Your Name
-- Date: 2018-09-03 21:52:12
--助战位置扩展提示
local ShenShouTips = class("ShenShouTips", base.BaseView)

function ShenShouTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ShenShouTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.c1 = self.view:GetController("c1")
    self.dec1 = self.view:GetChild("n3")
    self.dec2 = self.view:GetChild("n8")
    self.itemIcon = self.view:GetChild("n9")
    self.numTxt = self.view:GetChild("n6")
    self.itemNumTxt = self.view:GetChild("n11")
    local sureBtn = self.view:GetChild("n7")
    sureBtn.onClick:Add(self.onClickSure,self)
end

function ShenShouTips:initData(data)
    self.data = data
    local confData = data.confData
    if confData.open_cost then--道具解锁
        self.c1.selectedIndex = 1
        local needAmount = confData.open_cost[1][2]
        local itemInfo = {mid = confData.open_cost[1][1],amount = needAmount,bind = 1,hidenumber = true}
        GSetItemData(self.itemIcon, itemInfo, true)
        local amount = cache.PackCache:getPackDataById(confData.open_cost[1][1]).amount
        local t = {
            {text = amount,color = 10},
            {text = "/"..needAmount,color = 10},
        }
        if amount < needAmount then
            t[1].color = 14
        end
        self.itemNumTxt.text = mgr.TextMgr:getTextByTable(t)
        local itemName = conf.ItemConf:getName(confData.open_cost[1][1])
        local textData = clone(language.shenshou09)
        textData[2].text = string.format(textData[2].text,itemName)
        textData[3].text = string.format(textData[3].text,confData.open_cost[1][2])
        textData[5].text = string.format(textData[5].text,confData.id)
        self.dec2.text = mgr.TextMgr:getTextByTable(textData)
    else--等级达到自动解锁
        self.c1.selectedIndex = 0
        local textData = clone(language.shenshou08)
        textData[1].text = string.format(textData[1].text,confData.open_lev)
        textData[3].text = string.format(textData[3].text,confData.id)
        self.dec1.text = mgr.TextMgr:getTextByTable(textData)
    end

    self.numTxt.text = data.isBattleNum .. "/" .. data.holeCount
end

function ShenShouTips:onClickSure()
    if self.c1.selectedIndex == 0 then
        self:closeView()
    elseif self.c1.selectedIndex == 1 then
        local confData = self.data.confData
        local mId = confData.open_cost[1][1]
        local amount = cache.PackCache:getPackDataById(mId).amount
        if amount >= confData.open_cost[1][2] then
            proxy.ShenShouProxy:sendMsg(1590104)
        else
            GComAlter(language.gonggong11)
        end
        self:closeView()
    end
end

return ShenShouTips