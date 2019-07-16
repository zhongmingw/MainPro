--
-- Author:EVE 
-- Date: 2018-04-16 16:48:55
-- DESC: 变强提示
--

local GrowthTips = class("GrowthTips", base.BaseView)

function GrowthTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function GrowthTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onClickCloseView,self)

    self.growthList = self.view:GetChild("n3")
end

function GrowthTips:initData()
    -- body
    self.conf = conf.GrowthConf:getGrowthTipsConf()

    self:initList()
    self.growthList.numItems = #self.conf
end

function GrowthTips:initList()
    self.growthList.numItems = 0
    self.growthList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.growthList:SetVirtual()
end

function GrowthTips:cellData(index, obj)
    -- body
    local data = self.conf[index+1]

    local title = obj:GetChild("n2")
    title.text = data.title

    obj.data = {status = data.moduleId} --领取按钮
    obj.onClick:Add(self.onClickItem,self)
end

function GrowthTips:onClickItem(context)
    local itemObj = context.sender.data
    -- plog("跳转：", itemObj.status)  
    GOpenView({id = itemObj.status})
end

function GrowthTips:onClickCloseView()
    -- body
    self:closeView()
end

return GrowthTips