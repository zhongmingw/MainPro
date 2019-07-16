--
-- Author: 
-- Date: 2018-01-30 15:56:39
--
--花灯兑换
local ActiveHddh = class("ActiveHddh",import("game.base.Ref"))

function ActiveHddh:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ActiveHddh:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1209)
    --商品信息配置
    self.shopConf = conf.ActivityConf:getLanternGoods()
    --时间
    self.timeText = panelObj:GetChild("n9")   
    --描述
    panelObj:GetChild("n10").text = language.lantern04
    --商店列表
    self.listView = panelObj:GetChild("n15")
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function ActiveHddh:getTime(time)
    local timeTab = os.date("*t",time)
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

function ActiveHddh:setData(data)
    self.data = data
    if not self.flag then 
        self.flag = true
        self.timeText.text = self:getTime(self.data.actStartTime).."—"..self:getTime(self.data.actEndTime)
    end
    self.listView.numItems = #self.shopConf 
end

function ActiveHddh:cellData(index, obj)
    local data = self.shopConf[index+1]
    --icon
    local item = obj:GetChild("n1")
    local confData = data.awards[1]
    local info = {mid = confData[1], amount = confData[2], bind = confData[3]}
    GSetItemData(item,info,true)

    --名称
    local itemName = obj:GetChild("n4")
    itemName.text = conf.ItemConf:getName(confData[1])

    local msg,enabled = self:getCount(data)
    obj:GetChild("n5").text = msg

    --价格
    local price = obj:GetChild("n11")
    local priceConf = data.cost[1]
    price.text = priceConf[2]

    --兑换按钮
    local buyBtn = obj:GetChild("n12")
    buyBtn.enabled = enabled
    
    local data = {id = data.id, itemId = priceConf[1], buyPrice = priceConf[2]} 
    buyBtn.data = data --按钮的状态 
    buyBtn.onClick:Add(self.onClickGet,self)
end

function ActiveHddh:getCount(data)
    local num = 0
    local enabled = false
    if data.pnum then --个人次数
        if data.pnum == 9999 then
            return "",true
        end
        if self.data.pgots[data.id] then
            local temp = data.pnum - self.data.pgots[data.id]
            num = temp
            if temp > 0 then 
                enabled = true
            else
                enabled = false
            end
        else
            num = data.pnum
            enabled = true
        end 
        return string.format(language.lantern07, num), enabled
    elseif data.anum then --全服次数
        if self.data.agots[data.id] then
            num = temp
            if temp > 0 then 
                enabled = true
            else
                enabled = false
            end
        else
            num = data.anum
            enabled = true
        end
        return string.format(language.lantern06, num),enabled
    else
        print("@策划 兑换年货个人和全服次数配错")
    end
end

--兑换
function ActiveHddh:onClickGet(context) 
    local cell = context.sender
    local data = cell.data   

    local cachedata = cache.PackCache:getPackDataById(data.itemId)
    if cachedata.amount >= data.buyPrice then
        proxy.ActivityProxy:send(1030316,{reqType = 1, cid = data.id}) --兑换请求
    else
        GComAlter(language.gonggong11)
    end 
end

return ActiveHddh

