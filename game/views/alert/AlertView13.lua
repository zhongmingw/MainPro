--
-- Author: 
-- Date: 2017-04-10 14:50:43
--

local AlertView13 = class("AlertView13", base.BaseView)

function AlertView13:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function AlertView13:initData()
    -- body
    self.param = {} --需要传递的参数

    self.Arenacout = nil 
    self.Arena = nil 
end

function AlertView13:initView()
    local btnClose = self.view:GetChild("n2")
    btnClose.onClick:Add(self.onCloseView,self)

    self.btnCancel = self.view:GetChild("n3")
    self.btnCancel.onClick:Add(self.onCancel,self)

    self.btnSure = self.view:GetChild("n4")
    self.btnSure.onClick:Add(self.onSure,self)

    self.dec1 = self.view:GetChild("n6")
    self.dec1.text = ""

    self.dec2 = self.view:GetChild("n7")
    self.dec2.text = ""

    self.dec3 = self.view:GetChild("n8")
    self.dec3.text = ""

    -- self.dec4 = self.view:GetChild("n16")
    -- self.dec4.text = ""

    self.icon = self.view:GetChild("n9") 
    -- self.icon2 = self.view:GetChild("n15")
    self.money = self.view:GetChild("n10") 
    -- self.money2 = self.view:GetChild("n17")
    -- self.money2.text = ""
    self.labcount = self.view:GetChild("n14")  

    self.btnReduce = self.view:GetChild("n12")
    self.btnReduce.onClick:Add(self.onReduce,self)

    self.btnPlus = self.view:GetChild("n13")
    self.btnPlus.onClick:Add(self.onPlus,self)
end

function AlertView13:setData(data_)
    --竞技场扫荡
    self.Arenacout = true

    self.data = data_


    self.dec1.text = language.arena21
    self.dec2.text = language.arena22
    self.dec3.text = language.arena23
    -- self.dec4.text = ""
    self.icon.url = nil 
    -- self.icon2.url = nil
    self.money.x = self.dec3.x + self.dec3.actualWidth
    -- self.money2.text = ""
    self.countMax = self.data.leftChallengeCount
    -- if  cache.PlayerCache:VipIsActivate(3) then
    --     self.countMax = self.data.leftChallengeCount
    -- else  
    --     --是否需要冷却到0,1表示是
    --     if self.data.coldToZero == 1 and self.data.leftColdTime>0 then  
    --         self.countMax = 0
    --     else
    --         if self.data.leftColdTime<= 0 then
    --             self.countMax = 4
    --         elseif self.data.leftColdTime <= 10*60 then --10分钟内
    --             self.countMax = 3
    --         elseif self.data.leftColdTime <= 20*60 then --20分钟内
    --             self.countMax = 2
    --         elseif self.data.leftColdTime <= 30*60 then --30分钟内
    --             self.countMax = 1
    --         end
    --     end

    --     self.countMax = math.min(self.countMax,self.data.leftChallengeCount)
    -- end
    self.price = 1
    self.count = 1
    
    self:initMoney()
end

function AlertView13:setDataArenaBuy(data)
    -- body
    self.Arena = true
    self.data = data


    
    self.dec2.text = language.arena14
    self.dec3.text = language.arena15

    self.icon.url = UIItemRes.moneyIcons[MoneyType.bindGold]
    -- self.icon2.url = UIItemRes.moneyIcons[MoneyType.bindGold]
    self.money.x = self.icon.x + self.icon.actualWidth
    -- self.money2.x = self.icon2.x + self.icon.actualWidth
    --上限次数
    self.countMax = conf.ArenaConf:getValue("day_challege_count_buy_max") - self.data.dayChallengeCountBuy
    --价格
    self.price = conf.ArenaConf:getValue("challege_count_buy_cost")

    --当前
    self.count = 1
    self.labcount.text = tostring(self.count)
    self:initMoney()
end

function AlertView13:initExp()
    -- body
    local exp = 600 * cache.PlayerCache:getRoleLevel() + 60000
    exp = exp * self.count
    self.money.text = exp
end

function AlertView13:initMoney()
    -- body
    self.labcount.text = tostring(self.count)
    local var = tonumber(self.count)*tonumber(self.price)
    self.money.text = var
    
    if self.Arena then
        -- self.money2.text = var
        -- self.dec4.text = language.gonggong40
        if cache.PlayerCache:getTypeMoney(MoneyType.gold) < var then
            self.money.text = mgr.TextMgr:getTextColorStr(var, 14)
            -- self.money2.text = mgr.TextMgr:getTextColorStr(var, 14)
        end

        local t = clone(language.arena13)
        t[2].text = string.format(t[2].text,self.data.leftChallengeCount)
        t[4].text = string.format(t[4].text,tostring(var))
        self.dec1.text = mgr.TextMgr:getTextByTable(t)
    elseif self.Arenacout then
        self:initExp()
    end
end

function AlertView13:onReduce()
    -- body
    if self.count <= 1 then
        if self.Arena  then
            GComAlter(language.arena17)
        elseif self.Arenacout then
            GComAlter(language.arena17)
        end
        return
    end

    self.count = self.count - 1
    self:initMoney()
end

function AlertView13:onPlus()
    -- body
    if self.count>= self.countMax  then
        if self.Arena then
            GComAlter(language.arena16)
        elseif self.Arenacout then
            GComAlter(language.arena16)
        end
        return
    end

    local  money = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    money = money + cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
    
    if self.Arena and (self.count + 1 )*self.price>money  then
        GComAlter(language.arena18)
        return
    end

    self.count = self.count + 1
    self:initMoney()
end

function AlertView13:onSure()
    -- body
    if self.data.sure then
        self.data.sure(self.param)
    end

    if self.Arena then
        proxy.ArenaProxy:send(1310201,{buyCount = self.count})
    elseif self.Arenacout then
        for k ,v in pairs (self.data.arenaRoles) do
            if v.rank > self.data.rank  then
                proxy.ArenaProxy:send(1310106,{rank = v.rank,count = self.count})
                break
            end
        end  
    end
    self:onCloseView()
end

function AlertView13:onCancel()
    -- body
    self:onCloseView()
end

function AlertView13:onCloseView()
    -- body
    self:closeView()
end

return AlertView13