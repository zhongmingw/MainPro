--
-- Author: ohf
-- Date: 2017-05-16 17:35:46
--
--临时背包
local LimitPackView = class("LimitPackView", base.BaseView)

function LimitPackView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function LimitPackView:initData()
    proxy.PackProxy:sendLimitMsg()
end

function LimitPackView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    self.listView = self.view:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellPackData(index, obj)
    end
    local btn = self.view:GetChild("n3")
    btn.onClick:Add(self.onClickBtn,self)
    self.timeText = self.view:GetChild("n4")
end

function LimitPackView:setData()
    self.mData = {}
    for k,v in pairs(cache.PackCache:getLimitPackData()) do
        table.insert(self.mData, v)
    end
    table.sort(self.mData,function(a,b)
        return a.index < b.index
    end)
    local len = #self.mData
    self.listView.numItems = len
    self:setTimeStr()
end

function LimitPackView:setTimeStr()
    local time = cache.PlayerCache:getAttribute(attConst.limitPack) or 0
    local timeData = GGetTimeData(time)
    local str1 = mgr.TextMgr:getTextColorStr(string.format("%2d",timeData.hour), 14)
    local str2 = mgr.TextMgr:getTextColorStr("时", 7)
    local str3 = mgr.TextMgr:getTextColorStr(string.format("%2d",timeData.min), 14)
    local str4 = mgr.TextMgr:getTextColorStr("分", 7)
    local str5 = mgr.TextMgr:getTextColorStr(string.format("%2d",timeData.sec), 14)
    local str6 = mgr.TextMgr:getTextColorStr("秒", 7)
    local str7 = mgr.TextMgr:getTextColorStr(language.pack26, 7)
    self.timeText.text = string.format("%s%s%s%s%s%s%s",str1,str2,str3,str4,str5,str6,str7)
end

function LimitPackView:cellPackData(index,cell)
    local frame = cell:GetChild("n6")
    local proObj = cell:GetChild("n5")--item
    proObj.visible = false
    local data = self.mData[index + 1]--对应的数据
    if data then
        frame.visible = false
        GSetItemData(proObj,data,true)--设置道具信息
    else
        frame.visible = true
    end
end
--全部转移
function LimitPackView:onClickBtn()
    proxy.PackProxy:send(1040501,{indexs = {}})
end

return LimitPackView