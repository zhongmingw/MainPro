--
-- Author: ohf
-- Date: 2017-05-09 15:58:50
--
--快捷道具使用小窗
local QuickUseView = class("QuickUseView", base.BaseView)

function QuickUseView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function QuickUseView:initData(data)
    self.saveData = {}
    self:setSaveData(data)
    self:setData()
end

function QuickUseView:initView()
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

function QuickUseView:setData()
    self.mData = self.saveData[1]
    self.useNum = self.mData.amount
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

function QuickUseView:releaseTimer()
    if self.tipTimer then
        self:removeTimer(self.tipTimer)
        self.tipTimer = nil
    end
end

function QuickUseView:onTimer()
    if self.time <= 0 then
        self:clear()
        return
    end
    self.time = self.time - 1
end

function QuickUseView:setSaveData(data)
    local isFind = false
    for k,v in pairs(self.saveData) do
        if v.mid == data.mid then
            self.saveData[k] = data
            isFind = true
        end
    end
    if not isFind then
        table.insert(self.saveData, data)
    else
        if self.saveData[1].mid == data.mid then
            self:setData()
        end
    end
end
--设置道具显示
function QuickUseView:setProData()
    local data = self.mData
    local name = conf.ItemConf:getName(data.mid)
    local color = conf.ItemConf:getQuality(data.mid)
    self.itemName.text = mgr.TextMgr:getQualityStr1(name,color)
    GSetItemData(self.itemObj, data)
end
--减
function QuickUseView:onClickLess()
    self.useNum = self.useNum - 1
    self:setUseNum()
end
--累加
function QuickUseView:onClickAdd()
    self.useNum = self.useNum + 1
    self:setUseNum()
end
--设置使用数量
function QuickUseView:setUseNum()
    if self.useNum < 1 then
        self.useNum = 1
        GComAlter(language.pack18)
    end
    local amount = self.mData and self.mData.amount or 0
    if self.useNum > self.mData.amount then
        self.useNum = self.mData.amount
        GComAlter(language.pack21)
    end
    self.countText.text = self.useNum
end

function QuickUseView:onClickUse()
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

function QuickUseView:onClickClose()
    table.remove(self.saveData,1)
    self:releaseTimer()
    if #self.saveData > 0 then
        self.time = QuickUseTime
        self:setData()
    else
        self:clear()
    end
end

function QuickUseView:clear()
    self:releaseTimer()
    self.saveData = {}
    self:closeView()
end

return QuickUseView