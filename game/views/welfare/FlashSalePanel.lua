--
-- Author: EVE
-- Date: 2018-02-24 10:10:36
-- DESC: 限时特卖

local FlashSalePanel = class("FlashSalePanel", import("game.base.Ref"))

function FlashSalePanel:ctor(mParent,panelObj)
    self.mParent = mParent
    self.panelObj = panelObj
    self:initPanel() 
end

function FlashSalePanel:initPanel()
    self.curLevel = self.panelObj:GetChild("n10")
    --list 第一级列表
    self.listView = self.panelObj:GetChild("n3")
    self:initListView()

    --计算时间
    self.timeObj = {}       --时间组件
    self.timeId = {}        --时间id
    self.got = {}           --存储已领取的
    self.setHide = {}       --用于将还没到开服指定天数的隐藏掉 2018.03.28
end

function FlashSalePanel:initListView()
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function FlashSalePanel:celldata(index, obj)
    local data = self.confData[index+1]

    --需要等级
    local needLv = obj:GetChild("n22")
    needLv.text = data.level .. language.kaifuchongji02
    --物品
    local itemList = obj:GetChild("n8")
    GSetAwards(itemList,data.awards)
    --原价
    local originalPrice = obj:GetChild("n18")
    originalPrice.text = data.original
    --现价
    local presentPrice = obj:GetChild("n19")
    presentPrice.text = data.price
    --购买倒计时
    local countDown = obj:GetChild("n9")
    countDown.text = ""

    if self.curRoleLevel >= data.level then  --玩家等级大于或者等于配置等级，有倒计时
        countDown.visible = true

        table.insert( self.timeObj, countDown )
        table.insert( self.timeId, data.id) 

        self:onTimer()  --防止倒计时文字出现慢得问题
    else 
        countDown.visible = false            --玩家等级没有达到配置等级时，没有倒计时
    end 
    --折扣
    local discount = obj:GetController("c1")
    discount.selectedIndex = data.zk - 1
        
    local btnGet = obj:GetChild("n7")
    local isEnough = false              --大洋是否足够
    if self.curMoney >= data.price then 
        isEnough = true
    end 
    local openDay = 999                 --开服X天才可购买
    if data.open_day then               
        openDay = data.open_day     
    end 
    local data = {id = data.id, index = index, lv = data.level, goldCount = isEnough, openDayCanBuy = openDay} 
    btnGet.data = data --按钮的状态 
    btnGet.onClick:Add(self.onClickGet,self)
end

--倒计时
function FlashSalePanel:onTimer()  
    -- print("倒计时~~~~~~~~~~~~~~~")
    for k,v in pairs(self.timeId) do
        -- print(k,v) 
        local overTime = self:getOverTime(v)
        if overTime and overTime > 0 then 
            if not isHide then                                      --开始倒计时
                self.timeObj[k].text = language.flashsale01 .. GTotimeString(overTime)
            end 
    
        elseif not self.got[v] and overTime then 
            if not isHide then                               --倒计时结束的
                self:setRedPointByTime()             
                self.got[v] = true
                self:sendMsg()
            end 
        else                                                                    --时间还没到不能购买的
            self.timeObj[k].text = language.flashsale02 
            -- print("等级为：", openLv)
            -- if isHide and self.curRoleLevel and openLv < self.curRoleLevel then 
            --     table.insert( self.setHide, v, true)
            -- end 
        end         
    end
end

--获取物品的剩余时间
function FlashSalePanel:getOverTime(id)
        local serverTime = mgr.NetMgr:getServerTime()       --os.time()  --服务器时间
        local returnTime = self.data.start[id]              --服务器返回的是结束时间，尼玛币

        if returnTime then 
            local result = returnTime - serverTime              --剩余时间
            return result
        else
            -- print("self.data.start 返回结果为nil", id)
            return nil
        end 
end

--购买
function FlashSalePanel:onClickGet(context)
    local cell = context.sender
    local data = cell.data 
    
    local isCanBuy = self:getOverTime(data.id)
    if not isCanBuy and self.curRoleLevel >= data.lv and data.openDayCanBuy ~= 999 then    --判读是否能购买（SX的需求）
        local promptText = string.format(language.flashsale03, data.openDayCanBuy)
        GComAlter(promptText)
    else
        -- print("领取那个档的奖励",data.id) 
        proxy.ActivityProxy:send(1030318,{reqType = 1, cid = data.id}) --购买请求
    end 
end

function FlashSalePanel:setData(data)
    -- print("限时特卖消息返回成功~~~~~~~~~~~~~")
    -- printt(data)

    -- local var = cache.PlayerCache:getRedPointById(10258)
    -- print("是否买完：",var)
    -- for k,v in pairs(data.start) do
    --     print(k,v)
    -- end

    self.data = data

    --购买完成弹窗
    if data.items and #data.items>0 then
        GOpenAlert3(data.items)
    end

    --读取配置表
    local curLevel = cache.PlayerCache:getRoleLevel()
    self.confData = self:setConfData(curLevel)

    --当前等级
    self.curLevel.text = curLevel
    self.curRoleLevel = curLevel

    --当前元宝数量
    self.curMoney = cache.PlayerCache:getTypeMoney(MoneyType.gold)

    self.listView.numItems = #self.confData
    -- self.listView:ScrollToView(0)
end

--用于读取，并移除其中已购买的物品
function FlashSalePanel:setConfData(lv)
    local confData = conf.ActivityConf:getFlashSaleConf(lv)

    --判断是否已经领取   
    for _, v in pairs(self.data.got) do
        self.got[v] = true
    end

    local tempConf = {}
    for k,v in pairs(confData) do
        if not self.got[v.id] then                  --移除已购买了的
            local data = cache.ActivityCache:get5030111() or {}

            local overTime = self:getOverTime(v.id) --移除倒计时已结束的
            if not overTime or overTime > 0 then 
                if not v.open_day then
                    table.insert(tempConf, v)
                elseif v.open_day and data.openDay >= v.open_day then 
                    table.insert(tempConf, v)
                end 
            else
                -- print("已移除：",v.id,overTime)
            end 
        end 
    end

    return tempConf
end

--用于置空表
function FlashSalePanel:setEmpty()
    -- body
    for k,v in pairs(self.setHide) do
        if self.setHide[k] then 
            self.setHide[k] = nil
        end 
    end
end

function FlashSalePanel:setVisible(visible)
    self.panelObj.visible = visible   
end

function FlashSalePanel:sendMsg()
    -- 发送请求
    proxy.ActivityProxy:send(1030318, {reqType = 0})
end

return FlashSalePanel   