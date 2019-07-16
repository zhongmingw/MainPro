--
-- Author: 
-- Date: 2017-09-06 10:52:14
--
--自选头像
local HeadChooseView = class("HeadChooseView", base.BaseView)
local AmendHeadPanel = import(".AmendHeadPanel")
local HeadFramePanel = import(".HeadFramePanel")
local BubblePanel = import(".BubblePanel")
function HeadChooseView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function HeadChooseView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
end

function HeadChooseView:initData(data)
    self.index = data and data.index or 0
    self.childIndex = data and data.childIndex
    self.c1.selectedIndex = self.index
    self:onController()
end

function HeadChooseView:onController()
    if self.c1.selectedIndex == 0 then
        if not self.AmendHeadPanel then
            self.AmendHeadPanel = AmendHeadPanel.new(self)
        end
        self.AmendHeadPanel:setData()
    elseif self.c1.selectedIndex == 1 then
        if not self.HeadFramePanel then
            self.HeadFramePanel = HeadFramePanel.new(self)
        end
        -- print("跳转索引>>>>>>>>>>>>",self.childIndex)
        self.HeadFramePanel:setIndex(self.childIndex)
        proxy.PlayerProxy:send(1020505,{reqType = 0,skinId = 0})
    elseif self.c1.selectedIndex == 2 then
        if not self.BubblePanel then
            self.BubblePanel = BubblePanel.new(self)
        end
        -- print("跳转索引>>>>>>>>>>>>",self.childIndex)
        self.BubblePanel:setIndex(self.childIndex)
        proxy.PlayerProxy:send(1020506,{reqType = 0,skinId = 0})
    end
end

--请求头像边框返回
function HeadChooseView:setHeadFrameData(data)
    if self.HeadFramePanel then
        self.HeadFramePanel:setData(data)
    end
    self.childIndex = nil
end

--请求聊天气泡返回
function HeadChooseView:setBubbleData(data)
    if self.BubblePanel then
        self.BubblePanel:setData(data)
    end
    self.childIndex = nil
end

--头像边框升星刷新
function HeadChooseView:refreshFrame()
    if self.HeadFramePanel then
        self.HeadFramePanel:setData()
    end
    self.childIndex = nil
end

--聊天气泡升星刷新
function HeadChooseView:refreshBubble()
    if self.BubblePanel then
        self.BubblePanel:setData()
    end
    self.childIndex = nil
end

function HeadChooseView:setData(data)
    
end

return HeadChooseView