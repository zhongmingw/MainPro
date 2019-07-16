--
-- Author: 
-- Date: 2017-10-12 16:26:10
--

local BossTiredTipView = class("BossTiredTipView", base.BaseView)

function BossTiredTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function BossTiredTipView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self.timeText = self.view:GetChild("n4")
    closeBtn.onClick:Add(self.onClickQuit,self)
    self.quitBtn = self.view:GetChild("n3")
    self.quitBtn.onClick:Add(self.onClickQuit,self)
end

function BossTiredTipView:initData(data)
    self.isShenShouOver = data and data.isShenShouOver--神兽岛所有的次数消耗完
    local title = self.view:GetChild("n2")
    self.sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isShenShou(self.sId) then --神兽岛
        if self.isShenShouOver then--神兽岛所有的次数消耗完
            title.text = language.fuben239
            self.quitBtn.icon = UIPackage.GetItemURL("tips","bossdating_037")
        else
            title.text = language.fuben238
            self.quitBtn.icon = UIPackage.GetItemURL("_imgfonts","haoyou_009")
        end
    elseif mgr.FubenMgr:isWanShenDian(self.sId)  then --万神殿
        title.text = language.fuben116_1
        self.quitBtn.icon = UIPackage.GetItemURL("tips","bossdating_037")
    -- elseif mgr.FubenMgr:isTaiGuXuanJing(self.sId) then --太古玄境
    --     title.text = language.fuben116_1
    --     self.quitBtn.icon = UIPackage.GetItemURL("tips","bossdating_037")
    else
        title.text = language.fuben116
        self.quitBtn.icon = UIPackage.GetItemURL("tips","bossdating_037")
    end
    if self.tipTimer then
        self:removeTimer(self.tipTimer)
        self.tipTimer = nil
    end
    self.time = BossTiredTipTime
    self:onTimer()
    self.tipTimer = self:addTimer(1, -1, handler(self, self.onTimer))
end

function BossTiredTipView:onTimer()
    self.timeText.text = mgr.TextMgr:getTextColorStr(self.time, 7)..language.tips07
    if self.time <= 0 then
        self:onClickQuit()
        return
    end
    self.time = self.time - 1
end

function BossTiredTipView:onClickQuit()
    if mgr.FubenMgr:isShenShou(self.sId) then --神兽岛
        if self.isShenShouOver then--神兽岛所有的次数消耗完
            mgr.FubenMgr:quitFuben()
        else
            self:closeView()
        end
    else
        mgr.FubenMgr:quitFuben()
        self:closeView()
    end
end

return BossTiredTipView