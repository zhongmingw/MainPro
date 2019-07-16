--
-- Author: 
-- Date: 2017-06-17 10:03:54
--

--特殊快捷道具使用小窗
local SQuickUseView = class("SQuickUseView", base.BaseView)

function SQuickUseView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
    self.useNum = 0
end

function SQuickUseView:initData(data)
    self:releaseTimer()
    self:setData(data)
end

function SQuickUseView:initView()
    self.mData = {}
    self.itemObj = self.view:GetChild("n3")
    self.itemName = self.view:GetChild("n6")
    local btn = self.view:GetChild("n4")
    btn.onClick:Add(self.onClickUse,self)
    local closeBtn = self.view:GetChild("n5")
    closeBtn.onClick:Add(self.onClickClose,self)
    local leftBtn = self.view:GetChild("n8")
    leftBtn.onClick:Add(self.onClickLess,self)
    local rightBtn = self.view:GetChild("n9")
    rightBtn.onClick:Add(self.onClickAdd,self)
    self.countText = self.view:GetChild("n10")
end

function SQuickUseView:setData(data)
    self.mData = data
    self.useNum = self.mData and self.mData.amount or 0
    if not self.tipTimer then
        self.time = QuickUseTime
        self:onTimer()
        self.tipTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    if self.useNum <= 0 then
        self:onClickClose()
    end
    self:setUseNum()
    self:setProData()
end

function SQuickUseView:releaseTimer()
    if self.tipTimer then
        self:removeTimer(self.tipTimer)
        self.tipTimer = nil
    end
end

function SQuickUseView:onTimer()
    if self.time <= 0 then
        cache.PackCache:cleanSPros()
        self:releaseTimer()
        self:closeView()
        return
    end
    self.time = self.time - 1
end

--设置道具显示
function SQuickUseView:setProData()
    local data = self.mData
    local name = conf.ItemConf:getName(data.mid)
    local color = conf.ItemConf:getQuality(data.mid)
    self.itemName.text = mgr.TextMgr:getQualityStr1(name,color)
    GSetItemData(self.itemObj, data)
end
--减
function SQuickUseView:onClickLess()
    self.useNum = self.useNum - 1
    self:setUseNum()
end
--累加
function SQuickUseView:onClickAdd()
    self.useNum = self.useNum + 1
    self:setUseNum()
end
--设置使用数量
function SQuickUseView:setUseNum()
    if self.useNum < 1 then
        self.useNum = 1
        GComAlter(language.pack18)
    end
    local amount = self.mData and self.mData.amount or 0
    if self.useNum > amount then
        self.useNum = amount
        GComAlter(language.pack21)
    end
    self.countText.text = self.useNum
end

function SQuickUseView:onClickUse()
    local packData = cache.PackCache:getPackDataById(self.mData.mid)
    if packData.index > 0 then
        local params = {
            index = packData.index,--背包的位置
            amount = self.useNum,--使用数量
            ext_arg = 0,
        }
        proxy.PackProxy:sendUsePro(params)
    end
    self:onClickClose()
end

function SQuickUseView:onClickClose()
    self.useNum = 0
    self:releaseTimer()
    cache.PackCache:cleanSPros(true)
    if #cache.PackCache:getSPros() > 0 then
        mgr.ItemMgr:checkSPros()
    else
        self:releaseTimer()
        self:closeView()
    end
end

return SQuickUseView