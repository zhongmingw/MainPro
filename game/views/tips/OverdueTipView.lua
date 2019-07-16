--
-- Author: ohf
-- Date: 2017-06-14 20:48:41
--
--限时道具提示
local OverdueTipView = class("OverdueTipView", base.BaseView)

function OverdueTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function OverdueTipView:initData(data)
    if self.tipTimer then
        self:removeTimer(self.tipTimer)
        self.tipTimer = nil
    end
    self:setData(data)
end

function OverdueTipView:initView()
    local closeBtn = self.view:GetChild("n4")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.itemObj = self.view:GetChild("n11")
    self.itemName = self.view:GetChild("n7")
    self.descTips = self.view:GetChild("n8")
    local btn = self.view:GetChild("n3")
    btn.onClick:Add(self.onClickGoto,self)
end

function OverdueTipView:setData(list)
    self.mList = list
    local data = self.mList[1]
    self.data = data
    GSetItemData(self.itemObj, data, true)
    local name = conf.ItemConf:getName(data.mid)
    local color = conf.ItemConf:getQuality(data.mid)
    self.itemName.text = mgr.TextMgr:getQualityStr1(name,color)
    if not self.tipTimer then
        self:onTimer()
        self.tipTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function OverdueTipView:onTimer()
    local propTime = self.data.propMap and self.data.propMap[attConst.packAging] or 0
    local time = mgr.NetMgr:getServerTime() - propTime
    local limitTime = conf.ItemConf:getlimitTime(self.data.mid) or 0
    if time >= limitTime then
        return
    end
    local timeStr = mgr.TextMgr:getTextColorStr(GTotimeString(limitTime - time), 7)
    self.descTips.text = language.pack19[1]..timeStr..language.pack19[2]
end

function OverdueTipView:onClickGoto()
    mgr.ViewMgr:openView(ViewName.PackView,nil,{index = 1})
    table.remove(self.mList,1)
    if #self.mList <= 0 then
        self:closeView()
        return
    end
end

function OverdueTipView:onClickClose()
    table.remove(self.mList,1)
    if #self.mList <= 0 then
        self:closeView()
        return
    end
    self:setData(self.mList)
end

return OverdueTipView