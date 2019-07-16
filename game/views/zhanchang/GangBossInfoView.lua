--
-- Author: 
-- Date: 2017-07-25 17:19:57
--
--仙盟战信息界面
local GangBossRobPanel = import(".GangBossRobPanel")--仙盟boss抢夺

local GangRankPanel = import(".GangRankPanel")--仙盟战排行

local GangAwardsPanel = import(".GangAwardsPanel")--仙盟boss奖励

local GangBossInfoView = class("GangBossInfoView", base.BaseView)

function GangBossInfoView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function GangBossInfoView:initView()
    local closeBtn = self.view:GetChild("n2")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.ctrl1 = self.view:GetController("c1")
    -- self.ctrl1.onChanged:Add(self.onChangedCtrl,self)
    local index = 1
    for i=6,8 do
        local btn = self.view:GetChild("n"..i)
        btn.data = index - 1
        btn.title = language.gangwar20[index]
        btn.onClick:Add(self.onClickBtn,self)
        btn.selectedTitle = language.gangwar20[index]
        index = index + 1
    end
    self.gangBossRobPanel = GangBossRobPanel.new(self)
    self.gangRankPanel = GangRankPanel.new(self)
    self.gangAwardsPanel = GangAwardsPanel.new(self)
end

function GangBossInfoView:initData()
    self:onChangedCtrl()
end

function GangBossInfoView:setData(data)
    local selectedIndex = self.ctrl1.selectedIndex
    local msgId = data.msgId
    if selectedIndex == 0 and msgId == 5360105 then--请求仙盟战场景信息
        self.gangBossRobPanel:setData(data)
    elseif selectedIndex == 1 and msgId == 5360103 then--请求仙盟战场景排行榜
        self.gangRankPanel:setData(data)
    elseif selectedIndex == 2 and msgId == 5360104 then--请求仙盟战场景奖励信息
        self.gangAwardsPanel:setData(data)
    end
end

function GangBossInfoView:onClickBtn(context)
    local index = context.sender.data
    if self.ctrl1.selectedIndex ~= index then
        self.ctrl1.selectedIndex = index
    else
        self:onChangedCtrl()
    end
end

function GangBossInfoView:onChangedCtrl()
    local selectedIndex = self.ctrl1.selectedIndex
    if selectedIndex == 0 then
        self.gangBossRobPanel:sendMsg()
    elseif selectedIndex == 1 then
        self.gangRankPanel:sendMsg()
    elseif selectedIndex == 2 then
        self.gangAwardsPanel:sendMsg()
    end
end
--刷新boss
function GangBossInfoView:refreshBoss()
    self.gangBossRobPanel:refreshBoss()
end

function GangBossInfoView:onClickClose()
    self.ctrl1.selectedIndex = 0
    self:closeView()
end

return GangBossInfoView