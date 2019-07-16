--
-- Author: 
-- Date: 2017-06-16 19:41:24
--

local ZuoqiTipView = class("ZuoqiTipView", base.BaseView)

function ZuoqiTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function ZuoqiTipView:initData()
    self:setData()
end

function ZuoqiTipView:initView()
    self.view:GetChild("n9").text = language.tip12
    self.icon = self.view:GetChild("n10")
    self.descText = self.view:GetChild("n6")
    local btn = self.view:GetChild("n3")
    btn.onClick:Add(self.onClickGoto,self)
    local closeBtn = self.view:GetChild("n4")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.sclectBtn = self.view:GetChild("n8")
    self.sclectBtn.onChanged:Add(self.onCheck,self)
end

function ZuoqiTipView:setData()
    local modelId = 1001
    self.icon.url = ResPath.iconRes(UIItemRes.advtip01[modelId])
    self.descText.text = language.tips08[modelId]
    if not self.tipTimer then
        self.time = AdvanceTipTime
        self:onTimer()
        self.tipTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function ZuoqiTipView:releaseTimer()
    if self.tipTimer then
        self:removeTimer(self.tipTimer)
        self.tipTimer = nil
    end
end

function ZuoqiTipView:onTimer()
    if self.time <= 0 then
        self:onClickClose()
        return
    end
    self.time = self.time - 1
end

function ZuoqiTipView:getData()
    return self.data
end

function ZuoqiTipView:onClickGoto()
    GOpenView({id = 1001,childIndex = 1})
    self:onClickClose()
end

function ZuoqiTipView:onCheck()
    cache.PackCache:setNotAdvancedTip(1001,self.sclectBtn.selected)
end

function ZuoqiTipView:onClickClose()
    self:releaseTimer()
    self:closeView()
end

return ZuoqiTipView