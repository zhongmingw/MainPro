--
-- Author: 
-- Date: 2017-07-27 20:02:37
--
--限时抢购活动
local PanicBuyPanel = class("PanicBuyPanel",import("game.base.Ref"))

local actId = 1035

function PanicBuyPanel:ctor(mParent,panel)
    self.mParent = mParent
    self.panelObj = panel
    self:initPanel()
end

function PanicBuyPanel:sendMsg()
    --self:releaseTimer()
    proxy.ActivityProxy:send(1030203,{reqType = 0, buyType = 0, buyId = 0, amount = 0, actId = actId})
end

function PanicBuyPanel:initPanel()
    self.timeText = self.panelObj:GetChild("n5")
    self.buyList = {}
    for i=8,10 do
        local item = self.panelObj:GetChild("n"..i)
        table.insert(self.buyList, item)
    end
    self.panelObj:GetChild("n3").text = language.thqg01
    local czBtn = self.panelObj:GetChild("n4")
    czBtn.title = language.kaifu14
    czBtn.onClick:Add(self.onClickCz,self)
end

function PanicBuyPanel:onClickCz()
    GOpenView({id = 1042})
end

function PanicBuyPanel:setVisible(visible)
    self.panelObj.visible = visible
    if not visible then
        self:clear()
    end
end

function PanicBuyPanel:setData(data)
    plog("活动状态",data.state)
    self.mData = data
    if data.state == 0 or data.state == 3 then--0未开启，1已开启，2即将结束，3.当天抢购活动已结束，4.抢购活动已结束
        self.timeText.text = mgr.TextMgr:getTextByTable(language.thqg02)
    elseif data.state == 4 then
        self.timeText.text = mgr.TextMgr:getTextColorStr(language.thqg18, 14)
    end
    self.leftTime = data.leftTime or 0
    -- if not self.timer and self.leftTime > 0 then
    --     self:onTimer()
    --     self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    -- end
    self:setBuyItemData()
end
--设置三个抢购信息
function PanicBuyPanel:setBuyItemData()
    local items = {}
    for k,v in pairs(self.mData.buyCountMap) do
        local data = {buyId = k,buyCount = v}
        table.insert(items, data)
    end
    table.sort(items,function(a,b)
        return a.buyId < b.buyId
    end)
    if #items <= 0 then
        for k=1,3 do
            local cell = self.buyList[k]
            if cell then
                cell:GetController("c2").selectedIndex = 0
                cell:GetChild("n1").url = UIPackage.GetItemURL("panicbuy" , UIItemRes.thqg01[k])--底板1.铜钱 
            end
        end
    else
        local arleayBuyNum = 0
        for k,v in pairs(items) do
            local buyId = v.buyId
            local confData = conf.ActivityConf:getSpecialPanic(buyId)
            local moneyType = BuyMoneyType[confData.money_type][1]
            local cell = self.buyList[k]
            if cell then
                cell:GetChild("n1").url = UIPackage.GetItemURL("panicbuy" , UIItemRes.thqg01[k])--底板1.铜钱 2.绑定元宝 3.元宝
                local iconUrl = UIItemRes.moneyIcons[moneyType]
                cell:GetChild("n7").url = iconUrl
                cell:GetChild("n8").url = iconUrl
                
                cell:GetChild("n9").text = confData and confData.old_price--原价
                cell:GetChild("n10").text = confData and confData.price--原价
                local zekouCtrl = cell:GetController("c1")
                zekouCtrl.selectedIndex = confData.zekou - 1
                local c2 = cell:GetController("c2")
                local state = self.mData.state
                c2.selectedIndex = 1
                if confData.zekou and confData.zekou == 10 then
                    cell:GetChild("n15").visible = false
                end

                local itemObj = cell:GetChild("n4")
                local itemData = confData and confData.items[1] or {}
                local mId = itemData[1]
                local data = {mid = itemData[1],amount = 1,bind = itemData[3]}
                GSetItemData(itemObj, data, true)
                local name = conf.ItemConf:getName(mId).."X"..itemData[2]--道具信息
                local color = conf.ItemConf:getQuality(mId)
                cell:GetChild("n11").text = mgr.TextMgr:getQualityStr1(name, color)

                local count = confData.all_count - v.buyCount--全服剩余次数
                local arleayBuy = cell:GetChild("n18")
                cell:GetChild("n17").text = count
                local buyBtn = cell:GetChild("n12")
                local count = self.mData.buyRecord and self.mData.buyRecord[buyId] or 0
                if count >= confData.limit_count then
                    arleayBuyNum = arleayBuyNum + 1
                    arleayBuy.visible = true
                    buyBtn.visible = false
                else
                    arleayBuy.visible = false
                    buyBtn.visible = true
                end
                if state == 0 or state >= 3 then
                    buyBtn.enabled = false
                else
                    buyBtn.enabled = true
                end
                -- printt("活动id "..buyId.." ",itemData)
                buyBtn:RemoveEventListeners()
                buyBtn.data = buyId
                buyBtn.onClick:Add(self.onClickBuy,self)
            end
        end
        if arleayBuyNum >= 3 then
            local redNum = cache.PlayerCache:getRedPointById(attConst.A30109) or 0
            mgr.GuiMgr:redpointByID(attConst.A30109,redNum)
        end
    end
end

function PanicBuyPanel:onClickBuy(context)
    local buyId = context.sender.data
    if self.leftTime <= 0 and self.mData.state == 0 then
        GComAlter(language.thqg05)
    else
        proxy.ActivityProxy:send(1030203,{reqType = 1, buyId = buyId, amount = 1, actId = actId})
    end
end

function PanicBuyPanel:onTimer()
    if not self.mData or not self.leftTime then
        return
    end

    if self.leftTime <= 0 then
        self:sendMsg()
        return
    end
    local state = self.mData.state
    if state == 0 then--未开启
        self.timeText.text = mgr.TextMgr:getTextByTable(language.thqg02)
    elseif state == 1 then--已开启
        local richText =  {
            {color = 5,text = language.thqg03},
            {color = 10,text = GTotimeString2(self.leftTime)},
        }
        self.timeText.text = mgr.TextMgr:getTextByTable(richText)
    elseif state == 2 then--即将结束
        local richText =  {
            {color = 5,text = language.thqg04},
            {color = 10,text = GTotimeString2(self.leftTime)},
        }
        self.timeText.text = mgr.TextMgr:getTextByTable(richText)
    end
    self.leftTime = self.leftTime - 1
end

function PanicBuyPanel:releaseTimer()
    -- if self.timer then
    --     self.mParent:removeTimer(self.timer)
    --     self.timer = nil
    -- end
end

function PanicBuyPanel:clear()
    --self:releaseTimer()
end

return PanicBuyPanel