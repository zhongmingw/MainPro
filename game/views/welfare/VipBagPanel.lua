--
-- Author: ohf
-- Date: 2017-03-27 12:03:55
--
--vip礼包
local VipBagPanel = class("VipBagPanel",import("game.base.Ref"))

function VipBagPanel:ctor(mParent,panel)
    self.mParent = mParent
    self.panelObj = panel
    self:initPanel()
end

function VipBagPanel:initPanel()
    self.confData = conf.ActivityConf:getAllVipGift()
    self.listView = self.panelObj:GetChild("n2")
    self.listView.itemRenderer = function(index,obj)
        self:cellGiftData(index, obj)
    end

    self.getBtn = self.panelObj:GetChild("n3")--一键领取
    self.getBtn.onClick:Add(self.onClickYjGet,self)
end

function VipBagPanel:initRed()
    local param = {panel = self.getBtn:GetChild("red"), ids = {attConst.A20115},notnumber = true}
    mgr.GuiMgr:registerRedPonintPanel(param,self.mParent:viewName())
end

function VipBagPanel:sendMsg()
    self.mIndex = nil
    self.viplv = cache.PlayerCache:getVipLv()--自己的vip
    self.listView.numItems = 0
    proxy.ActivityProxy:send(1030107)
end

function VipBagPanel:judgeVip()
    local num = 0--判断可领取的数量
    for k,v in pairs(self.confData) do
        if self.viplv >= v.vip_level and not self:isGotVipDay(v.vip_level) then
            num = num + 1
        end
    end
    if num > 0 then
        self.getBtn.enabled = true
    else
        self.getBtn.enabled = false
        self.getBtn:GetChild("red").visible = false
    end
end
--礼包数据
function VipBagPanel:cellGiftData(index,cell)
    local data = self.confData[index + 1]
    local vipLevel = data.vip_level

    local desc1 = cell:GetChild("n5")
    local desc2 = cell:GetChild("n14")
    local arleayGet = cell:GetChild("n15")--已领取字
    local getBtn = cell:GetChild("n3")
    getBtn.data = data
    getBtn.onClick:Add(self.onClickBuyOrGet,self)--领取
    local goCzBtn = cell:GetChild("n16")--去充值
    goCzBtn.onClick:Add(self.onClickCz,self)--去充值
    local awards = data.daily_awards
    local viplv = vipLevel - self.viplv
    desc1.text = string.format(language.welfare05, vipLevel)
    local isGot = self:isGotVipDay(vipLevel)
    arleayGet.visible = isGot
    if viplv == 1 and vipLevel > 1 then
        local needCost = GGetVipNeedCost()
        if needCost > 0 then
            desc2.text = string.format(language.welfare16, needCost)
        else
            desc2.text = language.welfare35
        end
    else
        desc2.text = string.format(language.welfare07, vipLevel)
    end
    if self.viplv < vipLevel then
        getBtn.visible = false
        goCzBtn.visible = true
        desc2.visible = true
    else
        getBtn.visible = true
        goCzBtn.visible = false
        desc2.visible = false
    end
    getBtn.visible = (not isGot)
    local awardsList = cell:GetChild("n2")
    awardsList.visible = true
    awardsList.itemRenderer = function(index,obj)
        local awardData = awards[index + 1]
        local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
        GSetItemData(obj, itemData, true)
    end
    awardsList.numItems = #awards
end

function VipBagPanel:setData(data)
    self.vipDaySigns = data.vipDaySigns or {}
    self:judgeVip()
    self.listView.numItems = #self.confData
    self.listView:ScrollToView(0)
end
--vip每日领取标识
function VipBagPanel:isGotVipDay(id)
    for k,v in pairs(self.vipDaySigns) do
        if v and v == id then
            return true
        end
    end
end

function VipBagPanel:setVisible(visible)
    self.panelObj.visible = visible
end

function VipBagPanel:onClickBuyOrGet(context)
    local cell = context.sender
    local data = cell.data
    if self.viplv >= data.vip_level then
        proxy.ActivityProxy:send(1030108,{reqType = 1,vipId =   data.vip_level})
    else
        if g_ios_test then    --EVE 屏蔽处理，提示字符更改
            GComAlter(language.gonggong76)
        else
            GComAlter(language.gonggong27)
        end
    end
end

function VipBagPanel:onClickCz()
    GOpenView({id = 1042})
end
--一键领取
function VipBagPanel:onClickYjGet()
    proxy.ActivityProxy:send(1030108,{reqType = 3,vipId = 0})
end

function VipBagPanel:onClickYjBuy()
    local text = string.format(language.welfare10, self.money)
    local param = {type = 9,richtext = mgr.TextMgr:getTextColorStr(text, 11),sure = function()
        proxy.ActivityProxy:send(1030108,{reqType = 4,vipId = 0})
    end}
    GComAlter(param)
end

return VipBagPanel