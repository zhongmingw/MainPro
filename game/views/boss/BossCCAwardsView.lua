--
-- Author: 
-- Date: 2017-12-19 16:26:07
--

local BossCCAwardsView = class("BossCCAwardsView", base.BaseView)

function BossCCAwardsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function BossCCAwardsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end

function BossCCAwardsView:initData(data)
    local mosterId = data.mosterId
    local mConf = conf.MonsterConf:getInfoById(mosterId)
    self.monsterItems = mConf and mConf.monster_items or {}
    self.descList = conf.FubenConf:getBossValue("boss_awards_desc")
    self.listView.numItems = #self.monsterItems
    self.listView:ScrollToView(0)
end

function BossCCAwardsView:cellData(index, obj)
    local sort = index + 1
    obj:GetChild("n0").text = self.descList[sort]
    local awards = self.monsterItems[sort]
    local listView = obj:GetChild("n1")
    listView.itemRenderer = function(index,itemObj)
        local awardData = awards[index + 1]
        local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
        GSetItemData(itemObj, itemData, true)
    end
    listView.numItems = #awards
end

return BossCCAwardsView