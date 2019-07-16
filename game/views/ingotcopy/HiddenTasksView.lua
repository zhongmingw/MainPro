-- 
-- Author: EVE
-- Date: 2017-07-28 17:39:31
--

local HiddenTasksView = class("HiddenTasksView", base.BaseView)

function HiddenTasksView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    --self.openTween = ViewOpenTween.scale
    -- self.uiClear = UICacheType.cacheTime
end

function HiddenTasksView:initView()    
    local btnGo = self.view:GetChild("n3")
    btnGo.onClick:Add(self.onGo, self)
    self.rewardList = self.view:GetChild("n4")
    self:initListView()
end

function HiddenTasksView:initData()
    --奖励
    self.confData = conf.SysConf:getHiddenTasksReward()
    if self.confData then
        self.rewardList.numItems = #self.confData
    end
    --注释：触摸窗口外关闭窗口
    self.view.onClick:Add(self.onBtnClose,self)   
end

function HiddenTasksView:initListView()
    self.rewardList.numItems = 0
    self.rewardList.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.rewardList:SetVirtual()
end

function HiddenTasksView:itemData( index,obj )
    local data = self.confData[index+1]
    local itemId = data[1]
    local itemNum = data[2]
    local bind = data[3]
    local info = {mid=itemId,amount=itemNum,bind=bind}
    GSetItemData(obj,info,true)
end

function HiddenTasksView:onGo()
    local view01 = mgr.ViewMgr:get(ViewName.IngotCopy)
    if not view01 then 
        mgr.ViewMgr:openView2(ViewName.IngotCopy, {isGuide = self.isGuide})
    end 

    self:closeView()
end

function HiddenTasksView:onBtnClose()
    self:closeView()
end

return HiddenTasksView