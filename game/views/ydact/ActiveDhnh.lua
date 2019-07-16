--
-- Author: EVE
-- Date: 2017-12-26 11:09:56
--
--兑换年货
local ActiveDhnh = class("ActiveDhnh",import("game.base.Ref"))

function ActiveDhnh:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ActiveDhnh:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1165)

    --时间
    self.timeText = panelObj:GetChild("n9")   
    --描述
    local descText = panelObj:GetChild("n10")
    descText.text = language.activeDhnh02
    --商店列表
    self.shopList = panelObj:GetChild("n15")
    self:initList()
    --商品信息配置
    self.shopConf = conf.ActivityConf:getAnnualGoods()
end

function ActiveDhnh:getTime(time)
    local timeTab = os.date("*t",time)
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

function ActiveDhnh:initList()
    self.shopList.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.shopList:SetVirtual()
    self.shopList.numItems = 0
end

function ActiveDhnh:celldata(index, obj)
    local data = self.shopConf[index+1]

    --icon
    local item = obj:GetChild("n1")
    local confData = data.awards[1]
    local info = {mid = confData[1], amount = confData[2], bind = confData[3]}
    GSetItemData(item,info,true)

    --名称
    local itemName = obj:GetChild("n4")
    itemName.text = conf.ItemConf:getName(confData[1])

    --全服限量
    local num = obj:GetChild("n5") 
    local countData, isGray = self:setCount(data)
    if data.pnum == 9999 then 
        num.text = ""
    else
        num.text = countData
    end 
    -- printt(countData,isGray)

    --价格
    local price = obj:GetChild("n11")
    local priceConf = data.cost[1]
    price.text = priceConf[2]

    --兑换按钮
    local buyBtn = obj:GetChild("n12")

    self:setBtnIsGray(isGray, buyBtn) --判断是否为灰色
   
    local data = {id = data.id, itemId = priceConf[1], buyPrice = priceConf[2]} 
    buyBtn.data = data --按钮的状态 
    buyBtn.onClick:Add(self.onClickGet,self)
end

--兑换
function ActiveDhnh:onClickGet(context) 
    local cell = context.sender
    local data = cell.data   
    -- print("购买档位：",data.id) 

    local cachedata = cache.PackCache:getPackDataById(data.itemId)
    if cachedata.amount >= data.buyPrice then
        proxy.ActivityProxy:send(1030303,{reqType = 1, cid = data.id}) --兑换请求
    else
        -- print("东西不够了")
        GComAlter(language.gonggong11)
    end 
end

--设置剩余次数,第二个返回参数表示是否为灰色按钮
function ActiveDhnh:setCount(data)
    if data.pnum then --个人次数
        if self.data.pgots[data.id] then
            local temp = data.pnum - self.data.pgots[data.id]
            -- if data.pnum == 9999 and temp > 0 then
            --     return "", false
            -- elseif data.pnum == 9999 and temp <= 0 then 
            --     return "", true
            -- end

            if temp > 0 then 
                return string.format(language.activeDhnh04, temp),false
            else
                return string.format(language.activeDhnh04, 0),true
            end
        else
            return string.format(language.activeDhnh04, data.pnum),false
        end 

    elseif data.anum then --全服次数
        if self.data.agots[data.id] then
            local temp = data.anum - self.data.agots[data.id]
            if temp > 0 then 
                return string.format(language.activeDhnh03, temp),false
            else
                return string.format(language.activeDhnh03, 0),true
            end 
        else
            return string.format(language.activeDhnh03, data.anum),false
        end

    else
        print("@策划 兑换年货个人和全服次数配错")
    end
end

--设置购买按钮是否为灰色，返回true为灰色
function ActiveDhnh:setBtnIsGray(isGray, btn)
    if isGray then     
        btn.touchable = false
    else
        btn.touchable = true
    end 

    btn.grayed = isGray
end

function ActiveDhnh:setData(data)
    -- print(data.actStartTime," ~~~~~~~~~~~",data.actEndTime)
    -- print("活动时间那~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    self.data = data

    if not self.flag then 
        self.flag = true
        self.timeText.text = self:getTime(self.data.actStartTime).."-"..self:getTime(self.data.actEndTime)
    end

    self.shopList.numItems = #self.shopConf 
end

return ActiveDhnh